function plot = scatterarray(array,opts)
    if numel(array) > 0
        x = array(:,1);
        y = array(:,2);
    else
        x = [];
        y = [];
    end
    switch nargin
        case 2
            plot = scatter(x,y,opts);
        otherwise
            plot = scatter(x,y);
    end
end
