classdef SLIPdynamics
    %SLIPDYNAMICS This is a dynamic simulation of a nondimensionalized
    % spring loaded inverted pendulum (SLIP) on flat ground. It is used to
    % create a lookup table for touchdown angle
    
    properties      
        %     Nondimensional Values
        %Gravity []
        g = 1;
        %Leg Spring Constant []
        K = 1;
        %Relative y velocity []
        yDot = -1;
        %Leg Touchdown Angle
        alphaTD = 0;
 
    end %properties
    
    methods
        
        function obj = SLIPdynamics() 
            %Potentially used in the future for Graphics init?
        end
        
        function [alphaLiftOff] = simulate(o)
        %simulate Run a simulation with specified controller
            dyn = @(t,y) [y(2);y(1)*o.K*(1-sqrt(y(1)^2 + y(3)^2))/(sqrt(y(1)^2 + y(3)^2));...
                          y(4);y(3)*o.K*(1-sqrt(y(1)^2 + y(3)^2))/(sqrt(y(1)^2 + y(3)^2))-o.g];

            options = odeset('Events',@(t,y) (stanceTransitions(t,y,o)));
            y0 = [-sin(o.alphaTD);1;cos(o.alphaTD);o.yDot];
               
            [~,y_out,~,~,~] = ode45(dyn,[0,20],y0,options);
            
            alphaLiftOff = atan2(-y_out(1),y_out(3));  
        end 
    end %Methods
    
end %Class

function [value,isterminal,direction] = stanceTransitions(t,y,o)
%ODE Event function sensing foot liftoff during stance while moving upward

%On a pure elastic leg zero force on the foot is identical to when the 
%leg length reaches the unstretched length
value = sqrt(y(1)^2 + y(3)^2) - o.L0 + min(y(4),0);
isterminal = 1;
direction = [];
end %function stanceTransitions




