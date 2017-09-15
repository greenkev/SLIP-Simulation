function [  ] = animateSlip( obj )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

figure(7);
cla
ylim([-0.1,1.4]);
xlim([-0.3,2.3]);
grid on;
axis equal;
title('SLIP Monoped Animation');
%Create visual patches
ground_patch = patch([-50,-50,50,50],[0,-10,-10,0],[0.8,0.8,0.8]);

body_patch = patch(obj.x_body(1) + 0.1*sin(0:0.1:2*pi),obj.y_body(1) + 0.1*cos(0:0.1:2*pi),[70,216,226]./255);

leg_patch = patch(obj.x_body(1) + [0.01,0.01,-0.01,-0.01]*cos(obj.phi(1)) + obj.L(1)*[0,1,1,0]*sin(obj.phi(1)),...);
                       obj.y_body(1) - [0.01,0.01,-0.01,-0.01]*sin(obj.phi(1)) + obj.L(1)*[0,-1,-1,0]*cos(obj.phi(1)),'k');
  
%Loop through the data updating the graphics
for i = 1:length(obj.t)
    body_patch.Vertices = [obj.x_body(i) + 0.1*sin(0:0.1:2*pi);obj.y_body(i) + 0.1*cos(0:0.1:2*pi)]';
    
    leg_patch.Vertices = [obj.x_body(i) + [0.01,0.01,-0.01,-0.01]*cos(obj.phi(i)) + obj.L(i)*[0,1,1,0]*sin(obj.phi(i));...);
                       obj.y_body(i) + [0.01,0.01,-0.01,-0.01]*sin(obj.phi(i)) + obj.L(i)*[0,-1,-1,0]*cos(obj.phi(i))]';

    ylim([-0.1,1.4]);
    
    %Increment the screen by 0.5 m increments
    xlim([-1,1]+round(obj.x_body(i)*2)/2);
    drawnow;
end

end

