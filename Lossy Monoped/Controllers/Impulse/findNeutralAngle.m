function [ alphaTD ] = findNeutralAngle(simObject, xDot, yDot)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
persistent obj;
if isempty(obj)
    obj = liftOffSimulation(simObject,0.7);
end
obj.xDot = xDot;
obj.yDot = yDot;
% options = optimset('Display','iter');
alphaTD = fminbnd(@(x)obj.simulate(x),-pi/2,pi/2);
% keyboard
end



