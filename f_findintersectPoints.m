function [x0 y0] = intersectPoints(l1,l2)
% Insersection point of two lines with known slope and constant
% parameters.
% [x0 y0] = intersectPoints(m1,m2,b1,b1)
% where m's are slope, and b's are constants.
%pos=[x1,y1;x2,y2]
pos1=l1.Position;
pos2=l2.Position;
m1=(pos1(2,2)-pos1(1,2))./(pos1(2,1)-pos1(1,1));
b1=pos1(2,2)-m1.*pos1(2,1);
m2=(pos2(2,2)-pos2(1,2))./(pos2(2,1)-pos2(1,1));
b2=pos2(2,2)-m2.*pos2(2,1);
x0 = (b2-b1)/(m1-m2); %find the x point
y0 = m1*x0+b1;
end