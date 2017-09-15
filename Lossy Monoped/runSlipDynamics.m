% close all
clear raibertController
obj = SLIPdynamics();
obj.dataTimeStep = 0.02;  %Output timestep (sec)
des_vel = 0.2; %m/s

obj = simulate(obj,@raibertController,[0,11],des_vel);
%%
figure(9)
subplot(2,1,1)
hold off
plot(obj.t,obj.q(:,2));
ylabel('Body Vertical Position (m)');
xlabel('time (sec)');
title(['SLIP Raibert Hopper, Desired Speed ',num2str(des_vel),' m/sec']);
axis([-inf,inf,-0.2,2])

subplot(2,1,2)
hold off
plot(obj.t,obj.qdot(:,1));
hold on
plot(obj.t,des_vel*ones(size(obj.t)),'--r');
legend('Simulation','Desired');
ylabel('Body Horizontal velocity (m/sec)');
xlabel('time (sec)');
%%
% % close all
aObj = monopedAnimation(obj);
for i = 1:length(obj.t)
%    aObj.dispAtIndex(i);
%    keyboard
end
aObj.runAnimation();

%%