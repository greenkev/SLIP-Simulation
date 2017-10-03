function [ fCM, fLeg, jLeg ] = forcePostCalc( robot )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
fCM.x = (diff(robot.qdot(:,1))./diff(robot.t))./robot.m_body;
fCM.y = (diff(robot.qdot(:,2))./diff(robot.t))./robot.m_body;

fLeg = robot.k_leg.*(robot.q(:,5) - robot.q(:,6)) + ...
       robot.b_leg.*(robot.qdot(:,5) - robot.qdot(:,6));
   
jLeg = cumtrapz(robot.t,fLeg);
end

