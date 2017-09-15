classdef Dynamics < Auto.Jacobian
    %AUTODYNAMICS Subclass this to generate symbolic equations of motion. Inherits from AutoJacobian.
    %   Copyright 2017 Andy Abate (abatea@oregonstate.edu)
    
    % subclasses must implement these
    methods (Abstract)
        T = kineticEnergy(o,x,xdot)
        V = potentialEnergy(o,x)
    end
    
    methods
        function o = Dynamics()
            o.runBuildRule({'massMatrix','dynamics'},@()build(o,'massMatrix','dynamics'));
        end
        
        function [t,x,xdot,f] = simulate(o,x0,xdot0,tspan,controller)
            if ~exist('controller','var')
                controller = @(t,x,xdot) 0;
            end
            n = o.domainRank;
            opts = odeset('reltol',1e-8,'abstol',1e-8);
            dyn = @(t,y) [y(n+1:end); o.massMatrix(y(1:n))\(controller(t,y(1:n),y(n+1:end))-o.dynamics(y(1:n),y(n+1:end)))];
            y0 = [x0;xdot0];
            [t,y] = ode45(dyn,tspan,y0,opts);
            t = t';
            y = y';
            x = y(1:n,:);
            xdot = y(n+1:end,:);
            f = nan(size(x));
            for i = 1:numel(t)
                f(:,i) = controller(t(i),x(:,i),xdot(:,i));
            end
        end
        
        function [ u,qdot,qddot ] = inverseDynamics(o, dt,q )
            %INVERSEDYNAMICS Estimates velocity, acceleration, and required force for the path of a system.
            %  dt: fixed timestep
            %   x: row of column vectors of position coordinates
            %   Uses central differencing to approximate velocity
            %   Uses forward/backward differencing to approximate acceleration
            %   Forward differencing does not work as well. Central seems to work best.
            
            M = @o.massMatrix;
            h = @o.dynamics;
            
            % estimate velocity and acceleration from position
            qdot = cdiff(q)/dt;
            qddot = ddiff(q)/dt^2;
            
            [m,n] = size(q);
            
            % preallocate torque vector
            u = zeros(m,n);
            
            for i = 1:n
                qi = q(:,i);
                qdoti = qdot(:,i);
                qddoti = qddot(:,i);
                u(:,i) = M(qi)*qddoti + h(qi,qdoti);
            end
            
        end

    end
    
end

function build(o,massname,dynamicsname)
fprintf(['Creating massMatrix(x) and dynamics(x,xdot) for ' class(o) '...\n']);

[o,params] = o.makeFieldsSymbolic();
[x,xdot,xddot] = o.symbolicStateVariables();

T = o.kineticEnergy(x,xdot);
V = o.potentialEnergy(x);
L = T - V;

lhs = jacobian(gradient(L,xdot),[x;xdot]) * [xdot;xddot]; % d/dt [part L wrt qdot]
rhs = gradient(L,x); % part L wrt q
eq = simplify(lhs-rhs,'ignoreanalyticconstraints',true);
[M,h] = equationsToMatrix(eq,xddot); % M(x)*xddot = b(x,xdot)


% export symbolic methods
o.writeMethod(M,x,params,massname);
o.writeMethod(-h,{x,xdot},params,dynamicsname); % M*xddot + b(x,xdot) = u

assert(rank(M)==o.domainRank, ['Deficient mass matrix for class ' class(o)])
end

