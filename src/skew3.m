function matrix = skew3(v)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

x = v(1);
y = v(2);
z = v(3);

matrix = [0, -z, y; z, 0, -x; -y, x, 0];

end

