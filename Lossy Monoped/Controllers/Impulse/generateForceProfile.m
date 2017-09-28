function forceProfile = generateForceProfile( robot, alphaTD, xDot, yDot, L0 )
%generateSLIPForceProfile for a given initial condition and leg touchdown
%angle
    tstep = 1/1000;
    o.L0 = L0;
    o.M = robot.m_body + robot.m_thigh;
    o.K = robot.k_leg;
    o.grav = robot.grav;
    
    dyn = @(t,y) stanceDynamics(o,y);

    options = odeset('Events',@(t,y) (stanceTransitions(t,y,o)));
    y0 = [-o.L0*sin(alphaTD);o.L0*cos(alphaTD);xDot;yDot;];

    [t,y_out,~,~,~] = ode45(dyn,0:tstep:20,y0,options);
    force = o.K*(o.L0 - sqrt(y_out(:,1).^2 + y_out(:,2).^2));
    
    forceProfile.t = t;
    forceProfile.F = force;
    forceProfile.Fdot = o.K*sqrt(y_out(:,3).^2 + y_out(:,4).^2);
    forceProfile.Fint = cumtrapz(t,force);
end

function dX = stanceDynamics(o,y)
%Dynamics for SLIP in stance with foot at (0,0)
    dX = [y(3); y(4);...
          y(1)*o.K*(o.L0-sqrt(y(1)^2 + y(2)^2))/(sqrt(y(1)^2 + y(2)^2)*o.M);...
          y(2)*o.K*(o.L0-sqrt(y(1)^2 + y(2)^2))/(sqrt(y(1)^2 + y(2)^2)*o.M)-o.grav];
end

function [value,isterminal,direction] = stanceTransitions(t,y,o)
%ODE Event function sensing foot liftoff during stance while moving upward

    %On a pure elastic leg zero force on the foot is identical to when the 
    %leg length reaches the unstretched length
    value = sqrt(y(1)^2 + y(2)^2) - o.L0;
    isterminal = 1;
    direction = 1;
    
end %function stanceTransitions