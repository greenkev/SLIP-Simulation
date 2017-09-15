% close all
obj = SLIPdynamics();
obj.dataTimeStep = 0.008;  %Output timestep (sec)
des_vel = 0.5; %m/s

obj = simulate(obj,@raibertHopperCtrl,[0,6],des_vel);

figure(9)
subplot(2,1,1)
hold off
plot(obj.t,obj.y_body);
ylabel('Body Vertical Position (m)');
xlabel('time (sec)');
title(['SLIP Raibert Hopper, Desired Speed ',num2str(des_vel),' m/sec']);

subplot(2,1,2)
hold off
plot(obj.t,obj.dx_body);
hold on
plot(obj.t,des_vel*ones(size(obj.t)),'--r');
legend('Simulation','Desired');
ylabel('Body Horizontal velocity (m/sec)');
xlabel('time (sec)');

animateSlip( obj )