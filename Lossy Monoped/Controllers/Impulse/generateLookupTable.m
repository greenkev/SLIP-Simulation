xDot = -2:0.1:2;
yDot = -0.3:-0.1:-3;

[dX,dY] = meshgrid(xDot,yDot);

for i = 1:size(dX,1)
   for j = 1:size(dX,2)
       alpha(i,j) = findNeutralAngle(0, dX(i,j), dY(i,j));
   end
end

%%

surf(dX,dY,alpha)

interp2(dX,dY,alpha,xq,yq)