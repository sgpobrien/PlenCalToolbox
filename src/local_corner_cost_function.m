function error = local_corner_cost_function(A)
[m,~] = size(A);
h = fspecial('gaussian', m, m/2);
error = sum(sum(h.*(abs(A-(1-flip(A',1)))+abs(A-(1-flip(A',2)))+abs(A+(-flip(flip(A',1)',1))))));
end