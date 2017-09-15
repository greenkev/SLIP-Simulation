classdef monopedAnimation
    %monopedAnimation Animation class for a prismatic monoped
    %   Detailed explanation goes here
    
    properties
        fig
        obj
        patches %Container of patch objects plotted in fig
        bodyPoints
        slider
        
        visSpring = 0.5;
        
        
    end
    
    methods
        function animObj = monopedAnimation(o)
            animObj.obj = o;
            animObj.fig = figure(74);
            cla
            grid on;
            axis equal;
            title('Monoped Animation');
            animObj.visSpring = 0.5;
            animObj.bodyPoints = [-0.2, 0.1,1;...
                          0.2, 0.1,1;...
                          0.2, -0.1,1;...
                          -0.2, -0.1,1;];
                      
            animObj.patches.ground = patch([-50,-50,50,50],[0,-10,-10,0],[0.8,0.8,0.8]);
            animObj.patches.body_patch = patch(zeros(4,1),zeros(4,1),[70,216,226]./255);
            
            animObj.patches.body_patch.Vertices = ([cos(animObj.obj.q(1,3)), -sin(animObj.obj.q(1,3)), animObj.obj.q(1,1);...
                                       sin(animObj.obj.q(1,3)),  cos(animObj.obj.q(1,3)), animObj.obj.q(1,2);]...
                                       *(animObj.bodyPoints'))';
                                   
            animObj.patches.thigh_patch = patch(zeros(36,1),zeros(36,1),'k');
            
            animObj.patches.thigh_patch.Vertices = ...
                ([cos(animObj.obj.q(1,4)), -sin(animObj.obj.q(1,4)), animObj.obj.q(1,1);... %Rotation Matrix
                  sin(animObj.obj.q(1,4)),  cos(animObj.obj.q(1,4)), animObj.obj.q(1,2);]...
               *( [0.03*[1,1,-1,-1,1*cos(0:0.1:pi)];... %Points
                   0   ,-animObj.obj.q(1,5)+animObj.visSpring,-animObj.obj.q(1,5)+animObj.visSpring,0,0.03*sin(0:0.1:pi);...
                   ones(1,36);]))';
               hold on
               springPts = ([cos(animObj.obj.q(1,4)), -sin(animObj.obj.q(1,4)), animObj.obj.q(1,1);... %Rotation Matrix hip joint
                  sin(animObj.obj.q(1,4)),  cos(animObj.obj.q(1,4)), animObj.obj.q(1,2);]...
                  *[0.05*[0,0, -1, 1, -1, 1, -1, 0,0];...
                   -(1/6)*(animObj.obj.q(1,6)-animObj.obj.q(1,5)+animObj.visSpring)*[0,0.5,1,2,3,4,5,5.5,6]-animObj.obj.q(1,5)+animObj.visSpring;...
                   ones(1,9);]);
               animObj.patches.spring = plot(springPts(1,:),springPts(2,:),'linewidth',3,'color',[255,128,0]/255);
            
            ylim([-0.1,1.4]);
            xlim([-1,1]+round(animObj.obj.q(1,1)*2)/2);
            drawnow
            animObj.patches.timeText = text(min(xlim) + 0.05*(max(xlim)-min(xlim)),min(ylim) + 0.95*(max(ylim)-min(ylim)),['t = ',num2str(animObj.obj.t(1))]);
            
            animObj.slider = uicontrol('Style','slider','Min',1,'Max',length(animObj.obj.t),'SliderStep',[1/length(animObj.obj.t),5/length(animObj.obj.t)],...
                'Value',1,'Units','normalized','Position',[0.1250 0.0167 0.7804 0.0476],...
                'Callback',@(source,event) updateSlider(animObj,source,event));
        end
        
        function runAnimation(animObj)
            
            for i = 1:length(animObj.obj.t)
                animObj.patches.body_patch.Vertices = ([cos(animObj.obj.q(i,3)), -sin(animObj.obj.q(i,3)), animObj.obj.q(i,1);...
                                       sin(animObj.obj.q(i,3)),  cos(animObj.obj.q(i,3)), animObj.obj.q(i,2);]...
                                       *(animObj.bodyPoints'))';
                                   
                                   
                animObj.patches.thigh_patch.Vertices = ...
                ([cos(animObj.obj.q(i,4)), -sin(animObj.obj.q(i,4)), animObj.obj.q(i,1);... %Rotation Matrix
                  sin(animObj.obj.q(i,4)),  cos(animObj.obj.q(i,4)), animObj.obj.q(i,2);]...
               *( [0.03*[1,1,-1,-1,1*cos(0:0.1:pi)];... %Points
                   0   ,-animObj.obj.q(i,5)+animObj.visSpring,-animObj.obj.q(i,5)+animObj.visSpring,0,0.03*sin(0:0.1:pi);...
                   ones(1,36);]))';
               
               hold on
               springPts = ([cos(animObj.obj.q(i,4)), -sin(animObj.obj.q(i,4)), animObj.obj.q(i,1);... %Rotation Matrix hip joint
                  sin(animObj.obj.q(i,4)),  cos(animObj.obj.q(i,4)), animObj.obj.q(i,2);]...
                  *[0.05*[0,0, -1, 1, -1, 1, -1, 0,0];...
                   -(1/6)*(animObj.obj.q(i,6)-animObj.obj.q(i,5)+animObj.visSpring)*[0,0.5,1,2,3,4,5,5.5,6]-animObj.obj.q(i,5)+animObj.visSpring;...
                   ones(1,9);]);     
               
               animObj.patches.spring.XData = springPts(1,:);
               animObj.patches.spring.YData = springPts(2,:);
               
                animObj.patches.timeText.Position = [min(xlim) + 0.05*(max(xlim)-min(xlim)),min(ylim) + 0.95*(max(ylim)-min(ylim))];
                animObj.patches.timeText.String = ['t = ',num2str(animObj.obj.t(i)),'   Dynamic State ',num2str(animObj.obj.dynamic_state_arr(i))];
            
                
                xlim([-1,1]+round(animObj.obj.q(i,1)*2)/2);

                %Increment the screen by 0.5 m increments
                drawnow;
            end
        end
        
        function dispAtIndex(animObj,i)
            animObj.patches.body_patch.Vertices = ([cos(animObj.obj.q(i,3)), -sin(animObj.obj.q(i,3)), animObj.obj.q(i,1);...
                                       sin(animObj.obj.q(i,3)),  cos(animObj.obj.q(i,3)), animObj.obj.q(i,2);]...
                                       *(animObj.bodyPoints'))';
                                   

            animObj.patches.leg_patch.Vertices = ([cos(animObj.obj.q(i,4)), -sin(animObj.obj.q(i,4)), animObj.obj.q(i,1);...
                                   sin(animObj.obj.q(i,4)),  cos(animObj.obj.q(i,4)), animObj.obj.q(i,2);]...
                                   *( [0.01,0.01,-0.01,-0.01;...
                                       0   ,-animObj.obj.q(i,6),-animObj.obj.q(i,6),0;1,1,1,1;]))';     

            animObj.patches.timeText.Position = [min(xlim) + 0.05*(max(xlim)-min(xlim)),min(ylim) + 0.95*(max(ylim)-min(ylim))];
            animObj.patches.timeText.String = ['t = ',num2str(animObj.obj.t(i)),'   Dynamic State ',num2str(animObj.obj.dynamic_state_arr(i))];
            ylim([-0.1,1.4]);

            %Increment the screen by 0.5 m increments
            drawnow;
        end
        
        function updateSlider(animObj,source,event)
%             keyboard
            dispAtIndex(animObj,round(source.Value))
        end
        
    end
    
end

