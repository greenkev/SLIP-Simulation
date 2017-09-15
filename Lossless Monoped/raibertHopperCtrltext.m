function [ obj ] = raibertHopperCtrl( obj, des_vel )
%RAIBERTHOPPERCTRL Simple Raibert hopper Controler for SLIP monoped
%This controller is called at lift off to adjust desired leg touchdown
%angle to maintain a desired forward velocity

k_ctrl = 0.05; % m/(m/s) foot disp per velocity error

if obj.dynamic_state == 0 %%Entering Flight Phase
    touchdown_index = find(diff(obj.dynamic_state_arr),1,'last');
    Ts = obj.t(end) - obj.t(touchdown_index(end)+1); %Length of stance
    
    %Calculate the mean velocity of the last step. If we don't have enough
    %data just use current velocity
%     dx_bar = (obj.x_body(end)-obj.x_body(touchdown_index))/Ts;
    
    %Desired forward foot displacement
    % 0.225 (sec) is a hard coded stance duration
    x_f0 = 0.5*obj.dx_body(end)*0.225 + k_ctrl*(obj.dx_body(end) - des_vel);
    %Desired touchdown leg angle
    obj.phi_td = asin(x_f0/obj.L0);
    
end %If entering stance, no need for the controller to run

end

