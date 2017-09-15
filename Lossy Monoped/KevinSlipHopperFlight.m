classdef KevinSlipHopperFlight < Auto.Dynamics
    
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
        k_leg = 1000;
        b_leg = 0;
        %Toe
        m_toe = 0.1;
    end
    properties (Constant,Hidden)
        domainRank = 6; 
        % [x, y, theta, alpha, L_0, L]
        % [Body X Position, Body Y position, Body Pitch, Leg Angle, resting
        % leg length, actual leg length]
        
    end
    methods
        function sys = KevinSlipHopperFlight(o)
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
            copyfile('dynamics.m','dynamicsFlight.m');
            copyfile('massMatrix.m','massMatrixFlight.m');
        end
        function joints = eval(o,q) 
        %I think this generates a foot/joint jacobian for use in applying external forces (eg. ground reaction)
        %I am not using it in the implementation
            joints = []';
        end
        
        function T = kineticEnergy(o,q,qdot)
            T =   0.5 * o.m_body * (qdot(1)^2 + qdot(2)^2) ... %Body Linear KE
                + 0.5 * o.I_body * qdot(3)^2 ... %Body Rotational KE
                + 0.5 * o.m_thigh * ((qdot(1) + o.r_thigh*qdot(4)*cos(q(4)))^2 + (qdot(2) + o.r_thigh*qdot(4)*sin(q(4)))^2) ... %Thigh Linear KE
                + 0.5 * o.I_thigh * qdot(4)^2 ... %Thigh Rotational KE
                + 0.5 * o.m_toe * ((qdot(1) + qdot(6)*sin(q(4)) + q(6)*qdot(4)*cos(q(4)))^2 + (qdot(2) - qdot(6)*cos(q(4)) + q(6)*qdot(4)*sin(q(4)))^2) ... %Toe KE (point mass)
                + 0.5 * o.m_rot * qdot(5)^2; %Leg Actuator reflected interia KE   
        end
        
        function V = potentialEnergy(o,q)
            V =   o.grav * o.m_body * q(2) ... %Body Grav Potential
                + o.grav * o.m_thigh * (q(2) - o.r_thigh*cos(q(4)))... %Thigh Grav Potential
                + o.grav * o.m_toe * (q(2) - q(6)*cos(q(4)))... %Foot/toe Grav Potential
                + 0.5 * o.k_leg * (q(6) - q(5))^2; %Leg Spring Potential
        end
        
        function f_d = dampingForces(o,q,qdot)
            f_d = [ -o.b_rot * qdot(5) * sin(q(4)); ... %Rotor damping
                    -o.b_rot * qdot(5) * cos(q(4)); ... %Rotor damping
                    -o.b_hip * (qdot(3) - qdot(4)); ... %Hip Joint Damping
                    -o.b_hip * (qdot(4) - qdot(3)); ... %Hip Joint Damping
                    -o.b_rot * qdot(5) * sin(q(4)) - o.b_leg * (qdot(5) - qdot(6)); ... %Rotor Damping and Leg Spring Damping
                    - o.b_leg * (qdot(6) - qdot(5)); ]; %Leg spring damping
        end
        
        function f_c = controlForces(o,q,u)
            f_c = [ -sin(q(4)),  0; ...
                    cos(q(4)),	0; ...
                    0,          -1;...
                    0,          1;...
                    1,          0;...
                    0,          0;]*u;
        end
    end
end

