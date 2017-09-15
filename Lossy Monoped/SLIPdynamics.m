classdef SLIPdynamics
    %SLIPDYNAMICS This is a dynamic simulation of a spring loaded inverted
    %pendulum (SLIP) on flat ground. It is controlled via a controller
    %function that is called every physics update. It has control authority
    % on hip torque and leg force (through motor inertia) (phi_td)
    
    properties      
        %Model params
        g = 9.81
        %Main Body
        m_body = 10;
        I_body = 0.1;  % Confirmed Realistic
        %Hip Joint
        b_hip = 0;
        %Thigh
        m_thigh = 0;
        r_thigh = 0.2;
        I_thigh = 0.01; % Confirmed Realistic
        %Leg Length Rotor
        b_rot = 0;
        m_rot = 3;  %Effective reflective interia on linear leg length
        %Leg Spring
        k_leg = 1000;
        b_leg = 10;
        %Toe
        m_toe = 0.3;
        %time step between data points (sec)
        %Only affects ODE45 output, not calculations
        dataTimeStep = 0.05;
        
        %State: 0=flight, 1=Stance
        dynamic_state = 0;
        
        %Time
        t = [];
        %Recorded State
        dynamic_state_arr = 0;
        %World Frame state data
        q = [0,1,0,0,0.7,0.7]; %Some basic initial state data
        qdot = zeros(1,6);
    end %properties
    
    methods
        
        function obj = SLIPdynamics() 
            %Potentially used in the future for Graphics init?
        end
        
        function o = simulate(o,controller,tspan,des_vel)
        %simulate Run a simulation with specified controller
       
            %Create the object that generates the flight equations of
            %motion. It will grab parameters from the passes in object.
            sysFlight = KevinSlipHopperFlight(o);
            sysStance = KevinSlipHopperStance(o);
           
           o.t = tspan(1);
           while o.t(end) < max(tspan)
            switch o.dynamic_state
                case 0 %flight
                    dyn = @(t,q) flightODEDynamics(t,q,sysFlight,o,controller);
                              
                    options = odeset('Events',@(t,y) (flightTransitions(t,y,o)));
                    
                    y0 = [o.q(end,:),o.qdot(end,:)];
                    
                case 1 %Stance
                    dyn = @(t,q) stanceODEDynamics(t,q,sysStance,o,controller);
                              
                    options = odeset('Events',@(t,y) (stanceTransitions(t,y,o)));
                    %These are the reduced states necessary to describe 
                    %the robot when the foot is on the ground at (0,0)
                    reducedStates = [1,2,3,5]; 
                    xFootLocation = o.q(end,1) + o.q(end,6)*sin(o.q(end,4));
                    %Set the initial condition with the foot fixed at (0,0)
                    y0 = [o.q(end,reducedStates) - [xFootLocation,0,0,0],o.qdot(end,reducedStates)];
            end %switch
             
            %Adjust to pick up next simulation at where the last one ended
            tspan = o.t(end):o.dataTimeStep:tspan(end);
                
            [t_out,y_out,~,~,~] = ode45(dyn,tspan,y0,options);
              
            o = fillSimData(o,t_out,y_out);
            o = switchMode(o);
           end %while
            
        end %function simulate

    end %Methods
    
end %Class

function [o] = switchMode(o)
%This controls the state machine for the simulation. For a SLIP monoped it
%is very simple. The structure is the same as would be used for more
%complicated state transitions

switch o.dynamic_state
    case 0
        o.dynamic_state = 1; %Flight can only enter stance
    case 1
        o.dynamic_state = 0; %Stance can only enter flight
end %switch

end %function switchMode

function [value,isterminal,direction] = flightTransitions(t,y,o)
%ODE Event function sensing foot touchdown during flight when moving
%downward
value = y(2) - y(6)*cos(y(4)) + max(0,y(8));
isterminal = 1;
direction = [];
end %function flightTransitions

function [value,isterminal,direction] = stanceTransitions(t,y,o)
%ODE Event function sensing foot liftoff during stance while moving upward
%Note: y only contains 8 elements instead of the full 12

%This is when the force on the ground is zero, which is not equivalent to
%when the leg spring is unstretched
value = o.k_leg*(sqrt(y(1)^2 + y(2)^2) - y(4)) - o.b_leg*(sqrt(y(5)^2 + y(6)^2) - y(8)) + min(y(4),0);
isterminal = 1;
direction = [];
end %function stanceTransitions

function dy = flightODEDynamics(t,y,sys,o,controller)
    %Seperate states into positions and velocities for readability
    q = y(1:6);
    qdot = y(7:12);
    
    dy(1:6,1) = qdot;
    %The Second Order dynamics M*q_ddot + h = Bu + f_damping
    dy(7:12,1) = massMatrixFlight(sys,q)\(dampingForces(sys,q,qdot) + controlForces(sys,q,controller(o,q,qdot)) - dynamicsFlight(sys,q,qdot));

%     if sum(imag(q)) + sum(imag(qdot)) ~= 0
%         keyboard
%     end
end

function dy = stanceODEDynamics(t,y,sys,o,controller)
    %Seperate states into positions and velocities for readability
    q = y(1:4);
    qdot = y(5:8);
    
    dy(1:4,1) = qdot;
    %The Second Order dynamics M*q_ddot + h = Bu + f_damping
    if t>4.3
%         keyboard
    end
    dy(5:8,1) = massMatrixStance(sys,q)\(dampingForces(sys,q,qdot) + controlForces(sys,q,controller(o,q,qdot)) - dynamicsStance(sys,q,qdot));
end

function o = fillSimData(o,t,y_in)
%fillSimData This function copies the state data (y) into the object
%members. What the state variables represent is different depending on the
%dynamic state (stance, flight).


    o.dynamic_state_arr = [o.dynamic_state_arr;o.dynamic_state*ones(size(t))];
    switch o.dynamic_state
        case 0 %Flight phase
            o.t =       [o.t;      t];
            o.q =       [o.q;      y_in(:,1:6)]; 
            o.qdot =    [o.qdot;   y_in(:,7:12)]; 
            
        case 1 %Stance            
            %States that are driven when the foot is on the ground
            %Leg Angle: toe is at (0,0)
            ydot = y_in(:,5:8);
            y = y_in(:,1:4);
            alpha = atan2(-y(:,1),y(:,2));
            alphadot = ( y(:,1).*ydot(:,2)./(y(:,2).^2) - ydot(:,1)./y(:,2) ) ./ ( 1 + (y(:,1)./y(:,2)).^2 ); 
            %Leg Length: toe is at (0,0)
            L = sqrt(y(:,1).^2 + y(:,2).^2);
            Ldot = ( y(:,1).*ydot(:,1) + y(:,2).*ydot(:,2) ) ./ sqrt(y(:,1).^2 + y(:,2).^2);
            
            %Foot Location needed to move from a coordinate system relative
            %to the foot to a global coordinate system
            xFootLocation = o.q(end,1) + o.q(end,6)*sin(o.q(end,4));
            
            o.t =       [o.t;       t];            
            o.q =       [o.q;       (y(:,1) + xFootLocation),y(:,2:3),alpha,y(:,4),L]; 
            o.qdot =    [o.qdot;    ydot(:,1:3),alphadot,ydot(:,4),Ldot]; 
    end %switch
end %Function fillSimData


