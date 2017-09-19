classdef liftOffSimulation
    %SLIPDYNAMICS This is a dynamic simulation of a nondimensionalized
    % spring loaded inverted pendulum (SLIP) on flat ground. It is used to
    % create a lookup table for touchdown angle
    
    properties      
        % Parameters
        %Gravity
        g = 9.81; 
        %Leg Spring Constant
        K = 2000;
        %Body Mass
        M = 10;
        %Resting Leg Length
        L0 = 0.7;
        %y velocity 
        yDot = -1;
        %x velocity
        xDot = 0;
 
    end %properties
    
    methods
        
        function obj = liftOffSimulation(inputObj) 
            %Potentially used in the future for Graphics init?
            obj.g = inputObj.g;
            obj.K = inputObj.k_leg;
            obj.M =  inputObj.m_body + inputObj.m_thigh;
            obj.L0 = 0.7;
        end
        
        function [r2] = simulate(o,alphaTD)
        %simulate Run a simulation return the deviation from symetric
        %squared.
            dyn = @(t,y) [y(2);y(1)*o.K*(o.L0-sqrt(y(1)^2 + y(3)^2))/(o.M*sqrt(y(1)^2 + y(3)^2));...
                          y(4);y(3)*o.K*(o.L0-sqrt(y(1)^2 + y(3)^2))/(o.M*sqrt(y(1)^2 + y(3)^2))-o.g];

            options = odeset('Events',@(t,y) (stanceTransitions(t,y,o)));
            y0 = [-o.L0*sin(alphaTD);o.xDot;o.L0*cos(alphaTD);o.yDot];
               
            [~,y_out,~,~,~] = ode45(dyn,[0,20],y0,options);
            
            r2 = (atan2(-y_out(end,1),y_out(end,3)) + alphaTD)^2;  
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




