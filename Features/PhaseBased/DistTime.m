% simple, yet powerful features when combined acc to Weka
% based on total target trajectory
% very fast running dogs exceed the radar's max speed rating
% so the normal features break because the events are too 
% short lived.

% Out2, out3, Out4 meaningless if the data is not for only moving period,
% but including all the time even there are no moving targets

function [Out1, Out2, Out3, Out4] = DistTime(Data)

% lambda = 3e8/5.8e9;
% Range = UnWrap(angle(Data)/2/pi, -0.5, 0.5)* lambda/2;
Range = UnWrap(angle(Data)/2/pi, -0.5, 0.5)* 2*pi*4096;

% total distance traversed 
Out1 = sum(abs(diff(Range)));

% total time in field of view
Out2 = length(Range)/64;  % in terms of step (1/4 s)

% time * dist 
Out3 = Out1 * Out2;

% not instantaneous speed but average speed
Out4 = Out1/Out2;