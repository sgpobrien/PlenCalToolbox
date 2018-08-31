function windowsurf(window_array,opts)
    wx = window_array(:,2);
    wy = window_array(:,3);
    R = window_array(:,1);
    Px = window_array(:,4);
    Py = window_array(:,5);
    X = reshape(wx,max(Px)-min(Px)+1,max(Py)-min(Py)+1);
    Y = reshape(wy,max(Px)-min(Px)+1,max(Py)-min(Py)+1);
    f = scatteredInterpolant(wx,wy,R);
    Z = f(X,Y);
    switch nargin
        case 2
            surf(X,Y,Z,opts);
        otherwise
            surf(X,Y,Z);
    end
end
