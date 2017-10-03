function plotRobotData( robot,names,dataType,index )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
figure
entries = [];
for i = 1:length(dataType)
    xData = [];
    label = [];
    if strcmp(dataType{i},'q')
        xData = robot.q(:,index(i));
        label = ['q_',num2str(index(i))];
    end    
    if strcmp(dataType{i},'qdot')
        xData = robot.qdot(:,index(i));
        label = ['\dot{q}_',num2str(index(i))];
    end
    if strcmp(dataType{i},'u')
        xData = robot.u(:,index(i));
        label = ['u_',num2str(index(i))];
    end
    if strcmp(dataType{i},'ctrlParams')
        xData = robot.ctrlParams(:,index(i));
        label = names{index(i)};
    end
    plot(robot.t,xData)
    hold on
    entries{i} = label;
end

legend(entries);
end

