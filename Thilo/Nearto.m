function [Inrange] = Nearto(Num1, Num2, tolerance)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
   dif = abs(Num1-Num2)
   if dif <=tolerance
       Inrange = true
   else
       Inrange = false
end

