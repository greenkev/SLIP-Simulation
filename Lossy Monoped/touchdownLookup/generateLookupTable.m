xDot = -4:0.25:4;
yDot = -0.1:-0.1:-3;

[dX,dY] = meshgrid(xDot,yDot);

for i = 1:size(dX,1)
   for j = 1:size(dX,2)
       alpha(i,j) = findNeutralAngle(0, dX(i,j), dY(i,j));
   end
   i
end

%%

surf(dX,dY,alpha)