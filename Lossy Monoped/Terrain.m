classdef Terrain
    %Terrain allows for a encapsulated description of the rigid ground over
    % which a robot locomotes. The implementation restricts the ground to 
    % be defined by a set of increasing x locations and their corresponding
    %  heights. This disallows vertical walls and overhangs.
    
    properties
        groundPoints
        interpolationMethod = 'linear';
        extrapolationMethod = 0;
        visualStep = 0.1; %X distance between points in visual data
    end
    
    methods
        
        function dist = groundHeight(terrain,xFootPos)
        %FOOTTOUCHDOWNDIST This function returns the ground height below a
        %given x position
                   
            %Find the ground height directly below the foot
            dist = interp1(terrain.groundPoints(:,1), terrain.groundPoints(:,2),...
                              xFootPos, terrain.interpolationMethod, terrain.extrapolationMethod);

        end
        
        function [x,y] = getVisualPoints(terrain,xMin,xMax)
        %GETVISUALPOINTS This returns an evenly spaced (in x) set of points
        %to use for visualizations using the same method of interpolation
        %as the touchdown detection
        
            if nargin < 3
                xMin = min(terrain.groundPoints(:,1));
                xMax = max(terrain.groundPoints(:,1));
            end
            
            x = xMin:terrain.visualStep:xMax;
            y = interp1(terrain.groundPoints(:,1), terrain.groundPoints(:,2),...
                        x, terrain.interpolationMethod, terrain.extrapolationMethod);
        end
        
        function tr = flatGround(tr)
        %FLATGROUND Set all points to 0 height
        
        %Interpolation structure requires at least 2 points
        %Extrapolation will return zeros so x values are not important
            tr.groundPoints = [-1, 0;...
                                1, 0;];
                            
            tr.extrapolationMethod = 0;
        end
        
        function tr = uniformIncline(tr,angle)
        %UNIFORMINCLINE Sets the terrain to be a fixed angle with the zero
        %height at zero x. Positive is uphill to the right
            tr.groundPoints = [ 0, 0;...
                                1, sin(angle);];
                            
            tr.extrapolationMethod = 'extrap';            
        end
        
        
        
    end
    
end

