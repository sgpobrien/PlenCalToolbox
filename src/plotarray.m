function plotarray3(array,opts)
    x = array(:,1);
    y = array(:,2);
    switch nargin
        case 2
            plot(x,y,opts);
        otherwise
            plot(x,y);
    end
end
