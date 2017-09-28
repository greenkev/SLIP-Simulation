robot = prismaticMonopod();
tspan = [0,10];
tr = Terrain;
tr = tr.flatGround();
% tr = tr.uniformIncline(5*(pi/180));
% tr = tr.randomBumpy(0.1,0.1);
tr.interpolationMethod = 'pchip';
load('lookupTable.mat');
clear EGBcontroller;
des_vel = 0.5; %m/s

addpath('Controllers/EGB');
ctrl = @(obj,q,qdot) EGBcontroller(obj,q,qdot,lookupTable,des_vel);


robot = RK4Integrate(robot,tspan,ctrl,tr);

%%
% Regenerate the loopup Table
addpath('touchdownLookup');

lookupTable.xDot = 0:0.1:2;
lookupTable.yDot = -0.3:-0.1:-3;

[lookupTable.dX,lookupTable.dY] = meshgrid(lookupTable.xDot,lookupTable.yDot);
lookupTable.alpha = zeros(size(lookupTable.dX));
H = waitbar(0,'Running Lookup Table Generation');
for i = 1:size(lookupTable.dX,1)
   for j = 1:size(lookupTable.dX,2)
       lookupTable.alpha(i,j) = findNeutralAngle(robot, lookupTable.dX(i,j), lookupTable.dY(i,j));
   end
   waitbar(i/size(lookupTable.dX,1),H);
end
close(H);
save('lookupTable.mat','lookupTable');
%%
figure(9)
subplot(3,1,1)
hold off
plot(robot.t,robot.q(:,2));
ylabel('Body Vertical Position (m)');
xlabel('time (sec)');
title(['SLIP Raibert Hopper, Desired Speed ',num2str(des_vel),' m/sec']);
% axis([-inf,inf,-0.2,2])

subplot(3,1,2)
hold off
plot(robot.t,robot.qdot(:,1));
hold on
plot(robot.t,des_vel*ones(size(robot.t)),'--r');
legend('Simulation','Desired');
ylabel('Body Horizontal velocity (m/sec)');
xlabel('time (sec)');

subplot(3,1,3)
hold off
plot(robot.t,robot.q(:,4));
hold on
plot(robot.t,0.1*robot.dynamic_state_arr);
legend('Leg Angle','0.1*state');
ylabel('Leg angle ');
xlabel('time (sec)');
%%
aObj = monopedAnimation(robot,tr);
for i = 1:length(robot.t)
%    aObj.dispAtIndex(i);
%    keyboard
end
aObj.runAnimation();

%%
figure(10)
hold off
plot(robot.t,robot.q(:,4))
hold on
plot(robot.t,robot.ctrlParams(:,3));
plot(robot.t,robot.ctrlParams(:,4));
title('Leg angle tracking during swing');
legend({'Leg Angle','Desired Swing Leg Angle','Lookup Table Leg Angle'})


figure(11)
hold off
plot(robot.t,robot.q(:,5))
hold on
plot(robot.t,robot.ctrlParams(:,1));
title('Leg Length tracking');
% legend({'Leg Angle','Desired Swing Leg Angle'})