function [ obj ] = raibertHopperCtrl( obj, des_vel )
%RAIBERTHOPPERCTRL Simple Raibert hopper Controler for SLIP monoped
%This controller is called at lift off to adjust desired leg touchdown
%angle to maintain a desired forward velocity

k_ctrl = 0.05; % m/(m/s) foot disp per velocity error

if obj.dynamic_state == 0 %Entering Flight Phase
    
    %Desired forward foot displacement
    % 0.225 (sec) is a hard coded stance duration. This converges faster
    % than using the measured stance duration
    x_f0 = 0.5*obj.dx_body(end)*0.225 + k_ctrl*(obj.dx_body(end) - des_vel);
    
    %Desired touchdown leg angle
    obj.phi_td = asin(x_f0/obj.L0);
    
end %If entering stance, no need for the controller to run

end

