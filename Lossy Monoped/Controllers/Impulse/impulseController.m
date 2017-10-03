function [ u,ctrlParams ] = impulseController(obj,q,qdot,t,lookupTable,desVel)


loadingCompression = 0.05; %Amount of compression for Loading and Unloading phases (m)
liftOffClearance = 0.05; %Distance toe must rise before the leg can be swung forward during flight (m)
k_legAngle = 0.05; %m/(m/s) foot distance 
L_flight = 0.7; %unstretched leg length during compression and flight (m)
L_extension = 0.72; %unstretched leg length during thrust (m)
des_vel = desVel; %m/s
phi_des = 0; %Rads

%Low Level controller gains, UNTUNED
kp_swing = 500;
kv_swing = 10;
kp_hip = 100;
kv_hip = 10;
kp_L0 = 50000;
kv_L0 = 1000;
%Impulse Controller Gains
Ks = [0, 0, 0]; %State Matrix, Integral, proportional, derivative
Ke = [100, 30, 0]; %Feedback Matrix, Integral, proportional, derivative

%States: 1= Loading, 2= Compression, 3= Thrust, 4= Unloading, 5=Flight
persistent stateMachine stanceFInt tPrev forceProfile
if isempty(stateMachine) || isempty(stanceFInt) || isempty(tPrev)
    stateMachine = 5; %Simulation starts by dropping robot
    stanceFInt = 0;
    tPrev = t;
    disp('initialized persistents in raibert controller');
end

Fmeasured = footForce(obj,q,qdot);
dFmeasured  = footForceDot(obj,q,qdot);
%If the state vector is smaller because of stance, calculate the missing
% elements
if length(q) == 4
    ydot = qdot;
    y = q;
    alpha = atan2(-y(1),y(2));
    alphadot = ( y(1)*ydot(2)/(y(2)^2) - ydot(1)/y(2) ) / ( 1 + (y(1)/y(2))^2 ); 
    %Leg Length: toe is at (0,0)
    L = sqrt(y(1)^2 + y(2)^2);
    Ldot = ( y(1)*ydot(1) + y(2)*ydot(2) ) / sqrt(y(1)^2 + y(2)^2);       
    q =       [y(1:3)   ;alpha   ;y(4)   ;L]; 
    qdot =    [ydot(1:3);alphadot;ydot(4);Ldot]; 
end


%Check for a chance in the state and update the integration 
switch stateMachine
    case 1 %Loading
        %Transition once the leg has compressed a small amount
        if q(5) - q(6) >= loadingCompression
            stateMachine = 2;
        end  
        stanceFInt = stanceFInt + Fmeasured*obj.T_ctrl;
    case 2 %Compression
        %Transition if the leg begins to extend
        if qdot(6) >= 0
            stateMachine = 3;
        end  
        stanceFInt = stanceFInt + Fmeasured*obj.T_ctrl;
    case 3 %Thrust
        %Transition once the leg compression is less than the threshold
        if q(5) - q(6) <= loadingCompression
            stateMachine = 4;
        end 
        stanceFInt = stanceFInt + Fmeasured*obj.T_ctrl;
    case 4 %Unloading
        %Transition when the foot has sufficient clearance 
        if q(2) - q(6)*cos(q(4)) >= liftOffClearance
            stateMachine = 5;
        end
    case 5 %Flight
        %Transition if the foot touches the ground
        if q(2) - q(6)*cos(q(4)) <= 0
            stateMachine = 1;
            stanceFInt = 0;
            tPrev = t;
            forceProfile = generateForceProfile( obj, q(4), qdot(1), qdot(2), L_flight);
        end
end

%Force and Torque Controllers depending on state
ctrlParams = zeros(1,10);

switch stateMachine
    case 10 %Loading
        u(1,1) = -kp_L0*(q(5) - L_flight) - kv_L0*qdot(5);
        u(2,1) = 0; %Zero Hip Torque
        
        ctrlParams(1) = L_flight;
    case {1,2,3} %Compression and Thrust
        Fdes = [interp1(forceProfile.t,forceProfile.Fint,t-tPrev);...
                interp1(forceProfile.t,forceProfile.F,t-tPrev);...
                interp1(forceProfile.t,forceProfile.Fdot,t-tPrev);];
            
        Fcurr = [stanceFInt;...
                Fmeasured;...
                dFmeasured;];
            
            
        u(1,1) = Fdes(2) + Ks*Fcurr + Ke*(Fdes - Fcurr);
        u(2,1) = kp_hip*(q(3) - phi_des) + kv_hip*qdot(3);
        
        ctrlParams(1) = L_flight;
        ctrlParams(2) = phi_des;
        
        ctrlParams(5:7) = Fcurr';
        ctrlParams(8:10) = Fdes';
    case 4 %Unloading
        u(1,1) = -kp_L0*(q(5) - L_flight) - kv_L0*qdot(5);
        u(2,1) = 0; %Zero Hip Torque
        
        ctrlParams(1) = L_extension;
    case 5 %Flight
        xDot =clamp(qdot(1),min(lookupTable.xDot),max(lookupTable.xDot));
        yDot =clamp(qdot(2),min(lookupTable.yDot),max(lookupTable.yDot));
        
        footTDAngle = interp2(lookupTable.dX,lookupTable.dY,lookupTable.alpha,xDot,yDot);
        ctrlParams(4) = footTDAngle;
        footTDAngle = footTDAngle + k_legAngle*(qdot(1) - des_vel);
        if isnan(footTDAngle)
           keyboard 
        end
        u(1,1) = -kp_L0*(q(5) - L_flight) - kv_L0*qdot(5);
        u(2,1) = -kp_swing*(q(4) - footTDAngle) - kv_swing*qdot(4); %Swing leg forward
         
        ctrlParams(1) = L_flight;
        ctrlParams(3) = footTDAngle;
end
 
    if sum(imag(q)) + sum(imag(qdot)) ~= 0
        keyboard
    end
    
end

function var_out = clamp(var,min_in,max_in)

var_out = min(max(var,min_in),max_in);
end



