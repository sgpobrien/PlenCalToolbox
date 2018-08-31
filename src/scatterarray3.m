function scatterarray3(array,opts1,opts2)
    x = array(:,1);
    y = array(:,2);
    z = array(:,3);
    switch nargin
        case 2
            scatter3(x,y,z,opts1);
        case 3
            scatter3(x,y,z,opts1,opts2);
        otherwise
            scatter3(x,y,z);
    end
end
