robot = prismaticMonopod();
tspan = [0,2];
tr = Terrain;
tr = tr.flatGround();
% tr = tr.uniformIncline(5*(pi/180));
% tr = tr.randomBumpy(0.1,0.1);
tr.interpolationMethod = 'pchip';

addpath('Analysis_Animation');
addpath('Controllers/Impulse');
load('lookupTable.mat');
clear impulseController;
des_vel = 0.5; %m/s
% forceProfile = generateForceProfile( robot, 0, 0, -0.3, 0.7 ); %robotobj, td angle, x dot, y dot, resting leg length
ctrl = @(obj,q,qdot,t) impulseController(obj,q,qdot,t,lookupTable,des_vel);

robot = RK4Integrate(robot,tspan,ctrl,tr);
ctrlNames = impulseControllerParamLabels( );

%%
robot = prismaticMonopod();
tspan = [0,4];
tr = Terrain;
tr = tr.flatGround();
% tr = tr.uniformIncline(5*(pi/180));
% tr = tr.randomBumpy(0.1,0.1);
tr.interpolationMethod = 'pchip';

addpath('Analysis_Animation');
addpath('Controllers/EGB');
load('lookupTable.mat');
clear EGBcontroller;
des_vel = 0.5; %m/s
% forceProfile = generateForceProfile( robot, 0, 0, -0.3, 0.7 ); %robotobj, td angle, x dot, y dot, resting leg length
ctrl = @(obj,q,qdot,t) EGBcontroller(obj,q,qdot,t,lookupTable,des_vel);

robot = RK4Integrate(robot,tspan,ctrl,tr);
ctrlNames = impulseControllerParamLabels( );
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
aObj = monopedAnimation(robot,tr);
for i = 1:length(robot.t)
%    aObj.dispAtIndex(i);
%    keyboard
end
aObj.runAnimation();

%%

plotRobotData( robot,ctrlNames,{'ctrlParams','ctrlParams','ctrlParams','ctrlParams'},[5,6,8,9])
plotRobotData( robot,ctrlNames,{'q','q'},[5,6])

