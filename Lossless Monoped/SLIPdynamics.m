classdef SLIPdynamics
    %SLIPDYNAMICS This is a dynamic simulation of a spring loaded inverted
    %pendulum (SLIP) on flat ground. It is controlled via a controller
    %function that is called at the start of each flight phase and is
    %expected to alter the desired touchdown Leg Angle (phi_td)
    
    properties      
        %     Fixed Values
        %Gravity (m/s^2)
        g = 9.81;
        %Body Mass (kg)
        M = 10;
        %Resting leg lenth (m)
        L0 = 0.7; 
        %Leg Spring Constant (N/m)
        K = 2000;
        %time step between data points (sec)
        %Only affects ODE45 output, not calculations
        dataTimeStep = 0.05
        
        %State: 0=flight, 1=Stance
        dynamic_state = 0;
        %Desired Touchdown Leg Angle
        phi_td = 0;
        
        %Time
        t = [];
        %Recorded State
        dynamic_state_arr = 0;
        %Body Position (m)
        x_body = 0;
        y_body = 1;
        %Body Velocity (m/s)
        dx_body = 0;
        dy_body = 0;
        %Leg Angle (foot to body from vertical) (rads)
        phi = 0;
        dphi = 0;
        %Leg Length
        L = 0.7;
        dL = 0;
        
        %foot x position (m)
        xf = 0;
    end %properties
    
    methods
        
        function obj = SLIPdynamics() 
            %Potentially used in the future for Graphics init?
        end
        
        function o = simulate(o,controller,tspan,des_vel)
        %simulate Run a simulation with specified controller
        
           o.t = tspan(1);
           while o.t(end) < max(tspan)
            switch o.dynamic_state
                case 0 %flight
                    dyn = @(t,y) [y(2);0;...
                                  y(4);-o.g];
                              
                    options = odeset('Events',@(t,y) (flightTransitions(t,y,o)));
                    
                    y0 = [o.x_body(end);o.dx_body(end);o.y_body(end);o.dy_body(end)];
                    
                case 1 %Stance
                    dyn = @(t,y) [y(2);y(1)*o.K*(o.L0-sqrt(y(1)^2 + y(3)^2))/(sqrt(y(1)^2 + y(3)^2)*o.M);...
                                  y(4);y(3)*o.K*(o.L0-sqrt(y(1)^2 + y(3)^2))/(sqrt(y(1)^2 + y(3)^2)*o.M)-o.g];
                              
                    options = odeset('Events',@(t,y) (stanceTransitions(t,y,o)));
                    y0 = [o.x_body(end) - o.xf(end);o.dx_body(end);o.y_body(end);o.dy_body(end)];
            end %switch
             
            %Adjust to pick up next simulation at where the last one ended
            tspan = o.t(end):o.dataTimeStep:tspan(end);
                
            [t_out,y_out,~,~,~] = ode45(dyn,tspan,y0,options);
              
            o = fillSimData(o,t_out,y_out);
            o = switchMode(o);
            o = controller(o,des_vel); %update leg touchdown angle
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
value = y(3) - o.L0*cos(o.phi_td) + max(y(4),0);
isterminal = 1;
direction = [];
end %function flightTransitions

function [value,isterminal,direction] = stanceTransitions(t,y,o)
%ODE Event function sensing foot liftoff during stance while moving upward

%On a pure elastic leg zero force on the foot is identical to when the 
%leg length reaches the unstretched length
value = norm([y(1),y(3)]) - o.L0 + min(y(4),0);
isterminal = 1;
direction = [];
end %function stanceTransitions


function o = fillSimData(o,t,y)
%fillSimData This function copies the state data (y) into the object
%members. What the state variables represent is different depending on the
%dynamic state (stance, flight).

    o.dynamic_state_arr = [o.dynamic_state_arr;o.dynamic_state*ones(size(t))];
    switch o.dynamic_state
        case 0 %Flight phase
            o.t = [o.t;t];
            o.x_body = [o.x_body; y(:,1)];
            o.y_body = [o.y_body; y(:,3)];
            
            o.dx_body = [o.dx_body; y(:,2)];
            o.dy_body = [o.dy_body; y(:,4)];
             
            new_phi = o.phi_td*ones(size(t));
            new_phi(y(:,4) > 0) = o.phi(end);
            o.phi = [o.phi;new_phi];
            o.dphi = [o.dphi;zeros(size(t))];
            o.L = [o.L;o.L0*ones(size(t))];
            o.dL = [o.dL;zeros(size(t))];

            o.xf = [o.xf; y(:,1) + o.L0*sin(o.phi_td)];   
            
        case 1 %Left Leg Single Stance
            o.t = [o.t;t];
            o.x_body = [o.x_body; y(:,1) + o.xf(end)];
            o.y_body = [o.y_body; y(:,3)];
            
            o.dx_body = [o.dx_body; y(:,2)];
            o.dy_body = [o.dy_body; y(:,4)];
             
            o.phi = [o.phi;atan2(-y(:,1),y(:,3))];
            o.dphi = [o.dphi;zeros(size(t))]; %Todo fix
            o.L = [o.L;sqrt(y(:,1).^2 + y(:,3).^2)];
            o.dL = [o.dL;y(:,2).*y(:,1)./sqrt(y(:,1).^2 + y(:,3).^2) + y(:,4).*y(:,3)./sqrt(y(:,1).^2 + y(:,3).^2)];
                        
            o.xf =  [o.xf; o.xf(end)*ones(size(t))];
    end %switch
end %Function fillSimData


