classdef liftOffSimulation
    %SLIPDYNAMICS This is a dynamic simulation of a nondimensionalized
    % spring loaded inverted pendulum (SLIP) on flat ground. It is used to
    % create a lookup table for touchdown angle
    
    properties      
        %y velocity 
        yDot = -1;
        %x velocity
        xDot = 0;
        robot;
        L0 = 0.7;
 
    end %properties
    
    methods
        
        function obj = liftOffSimulation(inputObj,L0) 
            %Potentially used in the future for Graphics init?
            obj.robot = inputObj;
            obj.L0 = L0;
        end
        
        function r2 = simulate(o,alphaTD)
        %simulate Run a simulation return the deviation from symetric
        %squared.
            dyn = @(t,y) stanceDynamics(o,o.robot,y);

            options = odeset('Events',@(t,y) (stanceTransitions(t,y,o)));
            y0 = [-o.L0*sin(alphaTD);o.L0*cos(alphaTD);0;o.L0;o.xDot;o.yDot;0;0];
               
            [~,y_out,~,~,~] = ode45(dyn,[0,20],y0,options);
            
            r2 = (atan2(-y_out(end,1),y_out(end,2)) + alphaTD)^2;  
        end 
    end %Methods
    
end %Class

function [value,isterminal,direction] = stanceTransitions(t,y,o)
%ODE Event function sensing foot liftoff during stance while moving upward

%On a pure elastic leg zero force on the foot is identical to when the 
%leg length reaches the unstretched length
value = sqrt(y(1)^2 + y(3)^2) - o.L0;
isterminal = 1;
direction = 1;
end %function stanceTransitions

function [dX] = stanceDynamics(obj,robot,X)
        %No applied forces
        u = [0;0];
        q = X(1:4);
        qdot = X(5:8);
    
        dX(1:4) = qdot;
        
        M = robot.massMatrixStance(q);
        f_d = robot.dampingStance(q,qdot);
        B = robot.controlStance(q);
        h = robot.dynamicsStance(q,qdot);        
        %The Second Order dynamics M*q_ddot + h = Bu + f_damping
        dX(5:8) = M\(B*u + f_d - h); 
        
        %Fix the leg resting length
        dX(4) = 0;
        dX(8) = 0;
        
        dX = dX';
end

        


