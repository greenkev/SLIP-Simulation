function [ u,ctrlParams ] = EGBcontroller(obj,q,qdot,lookupTable,desVel)


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
kp_hip = 0;%100;
kv_hip = 0;%10;
kp_L0 = 50000;
kv_L0 = 1000;

%States: 1= Loading, 2= Compression, 3= Thrust, 4= Unloading, 5=Flight
persistent stateMachine footTDAngle
if isempty(stateMachine) || isempty(footTDAngle)
    stateMachine = 5; %Simulation starts by dropping robot
    footTDAngle = 0;
    disp('initialized persistents in raibert controller');
end

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

%Check for a chance in the state 
switch stateMachine
    case 1 %Loading
        %Transition once the leg has compressed a small amount
        if q(5) - q(6) >= loadingCompression
            stateMachine = 2;
            disp('Controller End Loading');
        end  
    case 2 %Compression
        %Transition if the leg begins to extend
        if qdot(6) >= 0
            stateMachine = 3;
            disp('Controller End Compression');
        end  
    case 3 %Thrust
        %Transition once the leg compression is less than the threshold
        if q(5) - q(6) <= loadingCompression
            stateMachine = 4;
            disp('Controller End Thrust');
        end 
    case 4 %Unloading
        %Transition when the foot has sufficient clearance 
        if q(2) - q(6)*cos(q(4)) >= liftOffClearance
            stateMachine = 5;
            disp(['New TD Angle ',num2str(footTDAngle)]);
        end
    case 5 %Flight
        %Transition if the foot touches the ground
        if q(2) - q(6)*cos(q(4)) <= 0
            stateMachine = 1;
            disp('Controller has Landed');
        end
end

%Force and Torque Controllers depending on state
ctrlParams(4) = 0;
switch stateMachine
    case 1 %Loading
        u(1,1) = -kp_L0*(q(5) - L_flight) - kv_L0*qdot(5);
        u(2,1) = 0; %Zero Hip Torque
        
        ctrlParams(1) = L_flight;
        ctrlParams(2) = 0;
        ctrlParams(3) = 0;
    case 2 %Compression
        u(1,1) = -kp_L0*(q(5) - L_flight) - kv_L0*qdot(5);
        u(2,1) = kp_hip*(q(3) - phi_des) + kv_hip*qdot(3);
        
        ctrlParams(1) = L_flight;
        ctrlParams(2) = phi_des;
        ctrlParams(3) = 0;
    case 3 %Thrust
        u(1,1) = -kp_L0*(q(5) - L_extension) - kv_L0*qdot(5);
        u(2,1) = kp_hip*(q(3) - phi_des) + kv_hip*qdot(3);
        
        ctrlParams(1) = L_extension;
        ctrlParams(2) = phi_des;
        ctrlParams(3) = 0;
    case 4 %Unloading
        u(1,1) = -kp_L0*(q(5) - L_flight) - kv_L0*qdot(5);
        u(2,1) = 0; %Zero Hip Torque
        
        ctrlParams(1) = L_extension;
        ctrlParams(2) = 0;
        ctrlParams(3) = 0;
    case 5 %Flight
        xDot =clamp(qdot(1),min(lookupTable.xDot),max(lookupTable.xDot));
%         xDot = qdot(1);
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
        ctrlParams(2) = 0;
        ctrlParams(3) = footTDAngle;
end
 
    if sum(imag(q)) + sum(imag(qdot)) ~= 0
        keyboard
    end
    
end

function var_out = clamp(var,min_in,max_in)

var_out = min(max(var,min_in),max_in);
end



