function [t_out,y_out,u_out] = RK4Integrate(robot,tspan,q0,dq0,controller,terrain)
%RK4INTEGRATE This is a fixed timestep RK4 integrator with zero order hold
%controller function

t = tspan(1);
tstop = tspan(2);
Ts = robot.T_ctrl;
ratio = robot.T_ratio;
X = [q0,dq0];
dynamicState = robot.dynamic_state_arr(end);

while t < tstop
    
    u = controller(robot, X(1:(length(X)/2)), X((length(X)/2+1):end));
    
    for i = 1:ratio
        X1 = X;
        dX1 = monopod_dynamics(X1, u, robot, dynamicState);
        
        X2 = rs_add(X1, rs_smul(dX1, Ts/2));
        dX2 = monopod_dynamics(X2, u, robot, dynamicState);
        
        X3 = rs_add(X1, rs_smul(dX2, Ts/2));
        dX3 = monopod_dynamics(X3, u, robot, dynamicState);
        
        X4 = rs_add(X1, rs_smul(dX3, Ts));
        dX4 = monopod_dynamics(X4, u, robot, dynamicState);
        
        X = rs_add(X1, rs_smul(rs_add(rs_add(dX1, rs_smul(dX2, 2)), rs_add(rs_smul(dX3, 2), dX4)), Ts/6));
        t = t + Ts;
    end
    
    
    f = 1e-2;
    noiseval = (1 - f) * noiseval + f * noise * randn(4, 1);
    
    u.right.l_eq     = u.right.l_eq + noiseval(1);
    u.right.theta_eq = u.right.theta_eq + noiseval(2);
    u.left.l_eq      = u.left.l_eq + noiseval(3);
    u.left.theta_eq  = u.left.theta_eq + noiseval(4);
    
    % Stop if crashed
    if X.body.y < min(terrain.height)
        break
    end
end


end

function height = footTouchdownDist(robot, X, terrain)
%FOOTTOUCHDOWNDIST This returns the distance the robot's foot is above the
% ground. This will cross zero (from positive to negative) when touchdown 
% should happen
    xFootPos = X(1) + X(6)*sin(X(4));
    yFootPos = X(2) - X(6)*cos(X(4));
    groundHeight = terrain.groundHeight(xFootPos);
    
    height = yFootPos - groundHeight;  
end

function dX = monopod_dynamics(X, u, robot, dynamicState)

switch dynamicState
    
    case 0 %Flight
        q = X(1:6);
        qdot = X(7:12);
    
        dX(1:6,1) = qdot;
        
        M = robot.massMatrixFlight(q);
        f_d = robot.dampingFlight(sys,q,qdot);
        B = robot.controlFlight(q);
        h = dynamicsFlight(sys,q,qdot);        
        %The Second Order dynamics M*q_ddot + h = Bu + f_damping
        dX(7:12,1) = M\(B*u + f_d - h);
        
    case 1 %Stance
        q = X(1:4);
        qdot = X(5:8);
    
        dX(1:4,1) = qdot;
        
        M = robot.massMatrixStance(q);
        f_d = robot.dampingStance(sys,q,qdot);
        B = robot.controlStance(q);
        h = dynamicsStance(sys,q,qdot);        
        %The Second Order dynamics M*q_ddot + h = Bu + f_damping
        dX(5:8,1) = M\(B*u + f_d - h); 
end %switch
end

function c = rs_add(a, b)
    c = a + b;
end

function c = rs_smul(a, b)
    c = a.*b;
end

