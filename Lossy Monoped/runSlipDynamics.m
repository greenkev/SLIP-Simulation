robot = prismaticMonopod();
tspan = [0,5];
tr = Terrain;
% tr = tr.flatGround();
% tr = tr.uniformIncline(5*(pi/180));
tr = tr.randomBumpy(0.1,0.2);
tr.interpolationMethod = 'pchip';
clear raibertController;
robot = RK4Integrate(robot,tspan,@raibertController,tr);

%%
% Regenerate the loopup Table
obj = SLIPdynamics();
obj.dataTimeStep = 0.005;  %Output timestep (sec)
des_vel = 0.2; %m/s

lookupTable.xDot = 0:0.25:2;
lookupTable.yDot = -0.3:-0.25:-3;

[lookupTable.dX,lookupTable.dY] = meshgrid(lookupTable.xDot,lookupTable.yDot);
lookupTable.alpha = zeros(size(lookupTable.dX));

for i = 1:size(lookupTable.dX,1)
   for j = 1:size(lookupTable.dX,2)
       lookupTable.alpha(i,j) = findNeutralAngle(obj, lookupTable.dX(i,j), lookupTable.dY(i,j));
   end
end

save('lookupTable.mat','lookupTable');
%%
figure(9)
subplot(3,1,1)
hold off
plot(robot.t,robot.q(:,2));
ylabel('Body Vertical Position (m)');
xlabel('time (sec)');
% title(['SLIP Raibert Hopper, Desired Speed ',num2str(des_vel),' m/sec']);
% axis([-inf,inf,-0.2,2])

subplot(3,1,2)
hold off
plot(robot.t,robot.qdot(:,1));
hold on
% plot(robot.t,des_vel*ones(size(robot.t)),'--r');
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