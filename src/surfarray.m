function surfarray(array,opts)
    x = array(:,1);
    y = array(:,2);
    z = array(:,3);
    xlin = linspace(min(x),max(x),min(max(x)-min(x),100));
    ylin = linspace(min(y),max(y),min(max(y)-min(y),100));
    [X,Y] = meshgrid(xlin,ylin);
    f = scatteredInterpolant(x,y,z);
    Z = f(X,Y);
    switch nargin
        case 2
            surf(X,Y,Z,opts);
        otherwise
            surf(X,Y,Z);
    end
end
