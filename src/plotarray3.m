function plotarray3(array,opts)
    x = array(:,1);
    y = array(:,2);
    z = array(:,3);
    switch nargin
        case 2
            plot3(x,y,z,opts);
        otherwise
            plot3(x,y,z);
    end
end
