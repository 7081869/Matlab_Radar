function [Inrange] = Nearto(Num1, Num2, tolerance)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
   dif = Num1-Num2;
   z=abs(dif);
   if z <=tolerance
       Inrange = true;
   else
       Inrange = false;
   end
end

