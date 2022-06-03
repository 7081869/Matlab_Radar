function [Inrange] = Nearto(range1, range2, tolerancerange, angle1, angle2, toleranceangle)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
   difrange = range1-range2;
   difangle = angle1 - angle2;
   z=abs(difrange);
   s=abs(difangle);
   if ((z<=tolerancerange)&(s<=toleranceangle))
       Inrange = true;
   else
       Inrange = false;
   end
end

