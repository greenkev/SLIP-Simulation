classdef monopedAnimation
    %monopedAnimation Animation class for a prismatic monoped
    %   This is constructed with the SLIPdynamics object following a
    %   successful simulation. It allows for interactive time step
    %   traversal via a slider.
    
    properties
        fig
        obj %SLIPdynamics Object, contains state data and more
        patches %Container of patch objects plotted in fig
        bodyPoints
        slider %UIelement time index slider handle
        visSpring %Visual spring length when undeflected (double)
        exportAnimationButton
        tr %terrain Object
    end
    
    methods
        function animObj = monopedAnimation(o,terrain)
        %MONOPEDANIMATION constructor using SLIPdynamics Object and terrain
            animObj.obj = o;
            animObj.tr = terrain;
            animObj.fig = figure(74);
            cla
            grid on;
            axis equal;
            title('Monoped Animation');
            animObj.visSpring = 0.5;
            
            %The column of ones are neccesary for the use of the SE(2) offset matrix
            animObj.bodyPoints = [-0.2,  0.1, 1;...
                                   0.2,  0.1, 1;...
                                   0.2, -0.1, 1;...
                                  -0.2, -0.1, 1;];
                      
            [xGround,yGround] = terrain.getVisualPoints(min(animObj.obj.q(:,1))-2,max(animObj.obj.q(:,1))+2);
            animObj.patches.ground = patch([xGround,max(xGround),min(xGround)],[yGround,min(yGround)-10,min(yGround)-10],[0.8,0.8,0.8]);
            
            %Create a body patch object with the correct size and color
            animObj.patches.body_patch = patch(zeros(4,1),zeros(4,1),[70,216,226]./255);
            
            %Create a body patch object with the correct size and color                       
            animObj.patches.thigh_patch = patch(zeros(11,1),zeros(11,1),'k');
            
            hold on            
            %Create the spring plot object with the correct size, color and line attributes  
            animObj.patches.spring = plot(zeros(9,1),zeros(9,1),'linewidth',3,'color',[255,128,0]/255);
            %Create the text object to display time
            animObj.patches.timeText = text(0,0,'t = ?');
            %Create the slider object such that arrows increment by 1 and
            %clicking the area increments by 5
            animObj.slider = uicontrol('Style','slider','Min',1,'Max',length(animObj.obj.t),'SliderStep',[1/length(animObj.obj.t),5/length(animObj.obj.t)],...
                'Value',1,'Units','normalized','Position',[0.1250 0.0167 0.7804 0.0476],...
                'Callback',@(source,event) updateSlider(animObj,source,event));
            
            animObj.exportAnimationButton = uicontrol('style','pushbutton','String','Export Video','Units','normalized','Position',[0.1250 0.0658 0.2020 0.0522],'Callback',@(source,event) exportVideo(animObj,source,event));
            
            %here is where the initial state is actually written to the
            %visuals
            updateVisuals(animObj,animObj.obj.q(1,:),animObj.obj.t(1),animObj.obj.dynamic_state_arr(1));
        end
        
        function runAnimation(animObj)
            dataFrameRate = 1/animObj.obj.T_ctrl;
            for i = 1:round(dataFrameRate/120):length(animObj.obj.t)
                updateVisuals(animObj,animObj.obj.q(i,:),animObj.obj.t(i),animObj.obj.dynamic_state_arr(i));
            end
        end
        
        function updateSlider(animObj,source,event)
            %UPDATESLIDER Callback function, updates visuals to match new
            %slider index            
            index = round(source.Value); %Read the closest whole step of the slider
            %Write the selected index's state to the model
            updateVisuals(animObj,animObj.obj.q(index,:),animObj.obj.t(index),animObj.obj.dynamic_state_arr(index));
        end
        
        function exportVideo(animObj,source,event)
            disp('called Export Video');
            animObj.fig.Position = [100,100,1280,720];
            v = VideoWriter('newfile.mp4','MPEG-4');
            v.Quality = 100;
            v.FrameRate = 60;
            open(v);
            
            dataFrameRate = 1/animObj.obj.T_ctrl;
            
            for i = 1:round(dataFrameRate/v.FrameRate):length(animObj.obj.t)
                updateVisuals(animObj,animObj.obj.q(i,:),animObj.obj.t(i),animObj.obj.dynamic_state_arr(i));
                frame = getframe(animObj.fig);
                writeVideo(v,frame);
            end
            close(v);
        end
        
        function updateVisuals(animObj,q,t,dynamic_state)
        %UPDATEVISUALS this function updates the patches in the animObj Object
        %   It uses the state, time and state passed in, even though all
        %   state information should be contained in the animObj object.
        
            animObj.patches.body_patch.Vertices = ...
            ([cos(q(3)), -sin(q(3)), q(1);... %Body SE(2) Movement Matrix
              sin(q(3)),  cos(q(3)), q(2);]...
            *(animObj.bodyPoints'))';
                                   
                                   
            animObj.patches.thigh_patch.Vertices = ...
                ([cos(q(4)), -sin(q(4)), q(1);... %Leg SE(2) Movement Matrix
                  sin(q(4)),  cos(q(4)), q(2);]...
               *( [0.03*[1,1,-1,-1,1*cos(0:0.5:pi)];... %Leg Points X
                   0   ,-q(5)+animObj.visSpring,-q(5)+animObj.visSpring,0,0.03*sin(0:0.5:pi);... %Leg Points Y
                   ones(1,11);]))';
               
            springPts = ([cos(q(4)), -sin(q(4)), q(1);... %Leg SE(2) Movement Matrix
                          sin(q(4)),  cos(q(4)), q(2);]...
                  *[0.05*[0,0, -1, 1, -1, 1, -1, 0,0];...
                   -(1/6)*(q(6)-q(5)+animObj.visSpring)*[0,0.5,1,2,3,4,5,5.5,6]-q(5)+animObj.visSpring;...
                   ones(1,9);]);     

            animObj.patches.spring.XData = springPts(1,:);
            animObj.patches.spring.YData = springPts(2,:);

            animObj.patches.timeText.String = ['t = ',num2str(t),'   Dynamic State ',num2str(dynamic_state)];
                            
            %Increment the screen by 0.5 m increments
            xlim([-1,1]+round(q(1)*2)/2);
            ylim([-0.1,1.4] + animObj.tr.groundHeight(q(1)));
            %Place the text at the top left corner of the screen
            animObj.patches.timeText.Position = [min(xlim) + 0.05*(max(xlim)-min(xlim)),min(ylim) + 0.95*(max(ylim)-min(ylim))];
            %Update visuals
            drawnow;
        end
        
    end
    
end

