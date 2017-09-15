classdef KevinSlipHopperStance < Auto.Dynamics
    
    properties
        %All units are SI
        
        %General params
        grav = 9.81     
        %Main Body
        m_body = 1;
        I_body = 0.1;  %Calc realistic
        %Hip Joint
        b_hip = 0;
        %Thigh
        m_thigh = 0.1;
        r_thigh = 0.2;
        I_thigh = 0.2; %Calc realistic
        %Leg Length Rotor
        b_rot = 0;
        m_rot = 0.5;  %Effective reflective interia on linear leg length
        %Leg Spring
        k_leg = 2000;
        b_leg = 0;
        %Toe
        m_toe = 0.1;
    end
    properties (Constant,Hidden)
        domainRank = 4; 
        % [x, y, theta, L_0]
        % [Body X Position, Body Y position, Body Pitch, resting leg length]
        
    end
    methods
        function sys = KevinSlipHopperStance(o)
            %Copy over model parameters if specified
            if( nargin == 1)
                sys.grav = o.g;
                sys.m_body = o.m_body;
                sys.I_body = o.I_body;
                sys.b_hip = o.b_hip;
                sys.m_thigh = o.m_thigh;
                sys.r_thigh = o.r_thigh;
                sys.I_thigh = o.I_thigh;
                sys.b_rot = o.b_rot;
                sys.m_rot = o.m_rot;
                sys.k_leg = o.k_leg;
                sys.b_leg = o.b_leg;
                sys.m_toe = o.m_toe;
            end
            %Copy the files to the correct name (to differential flight and
            %stance
            copyfile('dynamics.m','dynamicsStance.m');
            copyfile('massMatrix.m','massMatrixStance.m');
        end
        function joints = eval(o,q) 
        %I think this generates a foot/joint jacobian for use in applying external forces (eg. ground reaction)
        %I am not using it in the implementation
            joints = []';
        end
        
        function T = kineticEnergy(o,q,qdot)
            %States that are driven when the foot is on the ground
            %Leg Angle: toe is at (0,0)
            alphadot = ( q(1)*qdot(2)/(q(2)^2) - qdot(1)/q(2) ) / ( 1 + (q(1)/q(2))^2 );
            
            T =   0.5 * o.m_body * (qdot(1)^2 + qdot(2)^2) ... %Body Linear KE
                + 0.5 * o.I_body * qdot(3)^2 ... %Body Rotational KE
                + 0.5 * o.m_thigh * (qdot(1) - o.r_thigh*(qdot(1)*(q(1)^2 + q(2)^2) - q(1)^2*qdot(1) - q(1)*q(2)*qdot(2))/(q(1)^2 + q(2)^2)^(3/2)) ...
                + 0.5 * o.m_thigh * (qdot(2) - o.r_thigh*(qdot(2)*(q(1)^2 + q(2)^2) - q(2)^2*qdot(2) - q(1)*q(2)*qdot(1))/(q(1)^2 + q(2)^2)^(3/2)) ...
                + 0.5 * o.I_thigh * alphadot^2 ... %Thigh Rotational KE
                + 0.5 * o.m_rot * qdot(4)^2; %Leg Actuator reflected interia KE 
            
%             + 0.5 * o.m_thigh * ((qdot(1) + o.r_thigh*alphadot*(q(2)/sqrt(q(1)^2 + q(2)^2)))^2 + (qdot(2) + o.r_thigh*alphadot*(-q(1)/sqrt(q(1)^2 + q(2)^2)))^2) ... %Thigh Linear KE

        end
        
        function V = potentialEnergy(o,q)            
            %States that are driven when the foot is on the ground
            %Leg Angle: toe is at (0,0)
            %Leg Length: toe is at (0,0)
            
            V =   o.grav * o.m_body * q(2) ... %Body Grav Potential
                + o.grav * o.m_thigh * (q(2) - o.r_thigh*(q(2)/sqrt(q(1)^2 + q(2)^2)))... %Thigh Grav Potential
                + 0.5 * o.k_leg * (sqrt(q(1)^2 + q(2)^2) - q(4))^2; %Leg Spring Potential
        end
        
        function f_d = dampingForces(o,q,qdot)
            %States that are driven when the foot is on the ground
            %Leg Angle: toe is at (0,0)
            alphadot = ( q(1)*qdot(2)/(q(2)^2) - qdot(1)/q(2) ) / ( 1 + (q(1)/q(2))^2 ); 
            %Leg Length: toe is at (0,0)
            L = sqrt(q(1)^2 + q(2)^2);
            Ldot = ( q(1)*qdot(1) + q(2)*qdot(2) ) / sqrt(q(1)^2 + q(2)^2);
            
            f_d = [ -o.b_rot * qdot(4) * (-q(1)/sqrt(q(1)^2 + q(2)^2)); ... %Rotor damping
                    -o.b_rot * qdot(4) * (q(2)/sqrt(q(1)^2 + q(2)^2)); ... %Rotor damping
                    -o.b_hip * (qdot(3) - alphadot); ... %Hip Joint Damping
                    -o.b_rot * qdot(4) * (-q(1)/sqrt(q(1)^2 + q(2)^2)) - o.b_leg * (qdot(4) - L);]; %Rotor Damping and Leg Spring Damping
                    
        end
        
        function f_c = controlForces(o,q,u)            
            %States that are driven when the foot is on the ground
            %Leg Angle: toe is at (0,0)
            alpha = atan2(-q(1),q(2));
            %Leg Length: toe is at (0,0)
            L = sqrt(q(1)^2 + q(2)^2);
            
            f_c = [ (q(1)/sqrt(q(1)^2 + q(2)^2)),  0; ...
                    (q(2)/sqrt(q(1)^2 + q(2)^2)),	0; ...
                    0,          -1;...
                    1,          0;]*u;
        end
    end
end

