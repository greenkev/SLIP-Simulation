function [robot] = RK4Integrate(robot,tspan,controller,terrain)
%RK4INTEGRATE This is a fixed timestep RK4 integrator with zero order hold
%controller function

t = tspan(1);
tstop = tspan(2);
Ts = robot.T_ctrl;
ratio = robot.T_ratio;
X = [robot.q,robot.qdot];
dynamicState = 0; %Must start in flight
stanceFootPos = [0,0]; %Only important while in stance, assumed to starts in flight

while t < tstop
    
    u = controller(robot, X(1:(length(X)/2))', X((length(X)/2+1):end)');
    
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
        
        [X,dynamicState,stanceFootPos] = checkHybridTransition(robot,X,dynamicState,terrain,stanceFootPos);
    end
    
    robot = fillSimData(robot,t,X,u,dynamicState);
    
    % Stop if crashed TODO
%     if X(2) < terrain.minHeight()
%         break
%     end
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

function [Xout,dynamicState,stanceFootPos] = checkHybridTransition(robot,X,dynamicState,terrain,stanceFootPos)
%CHECKHYBRIDTRANSITION
Xout = X;
switch dynamicState
    case 0 %Flight
        %Check if the new foot position is below the ground
        if footTouchdownDist(robot,X,terrain) < 0
            stanceFootPos(1) = X(1) + X(6)*sin( X(4) );
%             stanceFootPos(2) = X(2) - X(6)*cos( X(4) );
            stanceFootPos(2) = terrain.groundHeight(stanceFootPos(1));
            dynamicState = 1;
            Xout = [X(1)-stanceFootPos(1), X(2)-stanceFootPos(2), X(3), X(5), X(7),X(8),X(9),X(11)];
        end        
    case 1 %Stance
        %Check if foot force no longer pushed into the groun
        if robot.footForce(X(1:4),X(5:8)) > 0
            dynamicState = 0;   
            
            alpha = atan2(-X(1),X(2));
            alphadot = ( X(1).*X(6)./(X(2).^2) - X(5)./X(2) ) ./ ( 1 + (X(1)./X(2)).^2 );
            L = sqrt(X(1).^2 + X(2).^2);
            Ldot = ( X(1).*X(5) + X(2).*X(6) ) ./ sqrt(X(1).^2 + X(2).^2);
            
            Xout = [X(1) + stanceFootPos(1), X(2) + stanceFootPos(2),...
                    X(3), alpha, X(4), L,...
                    X(5),X(6),X(7),alphadot,X(8),Ldot];
        end
end
end

function dX = monopod_dynamics(X, u, robot, dynamicState)

switch dynamicState
    
    case 0 %Flight
        q = X(1:6)';
        qdot = X(7:12)';
    
        dX(1:6) = qdot;
        
        M = robot.massMatrixFlight(q);
        f_d = robot.dampingFlight(q,qdot);
        B = robot.controlFlight(q);
        h = robot.dynamicsFlight(q,qdot);        
        %The Second Order dynamics M*q_ddot + h = Bu + f_damping
        dX(7:12) = M\(B*u + f_d - h);
        
    case 1 %Stance
        q = X(1:4)';
        qdot = X(5:8)';
    
        dX(1:4) = qdot;
        
        M = robot.massMatrixStance(q);
        f_d = robot.dampingStance(q,qdot);
        B = robot.controlStance(q);
        h = robot.dynamicsStance(q,qdot);        
        %The Second Order dynamics M*q_ddot + h = Bu + f_damping
        dX(5:8) = M\(B*u + f_d - h); 
end %switch
end

function c = rs_add(a, b)
    c = a + b;
end

function c = rs_smul(a, b)
    c = a.*b;
end

