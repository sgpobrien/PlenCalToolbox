function parameters = optimise_calibration_parameters(window_data,data_scale,grid_size,calibration_init)
%OPTIMISE_CALIBRATION_PARAMETERS Refines the initial calibration estimate.
%   This function is a wrapper for Matlab's lsqnonlin function with several
%   pre-set optimisation options. These options may need to be changed in 
%   order to obtain good convergence properties. Pre-scaling of the
%   paramters is not currently automated, and is handled by the data_scale
%   input. The data_scale input is an array the same type and size as the
%   calibration parameter array. Each calibration parameter is scaled by
%   the corresponding parameter in the data_scale array in the
%   optimisation. 
%   Inputs: window_data (see format_window_data)
%           data_scale :: (4+2*T)x3 Double (see
%                          linear_estimate_calibration_parameters)
%           grid_size :: Double
%           calibration_init :: (4+2*T)x3 Double (see
%                          linear_estimate_calibration_parameters)
%   Outputs: parameters :: (4+2*T)x3 Double (see
%                          linear_estimate_calibration_parameters)
    options = optimoptions(@lsqnonlin);
    options.Algorithm = 'levenberg-marquardt';
    options.ScaleProblem = 'jacobian';
    options.OptimalityTolerance = 1e-4;
    options.Display = 'iter';
    options.FunctionTolerance = 1e-12;
    options.StepTolerance = 0;
    options.MaxFunctionEvaluations=100000;
    options.MaxIterations = 1000;
    parameters = lsqnonlin(@(x) optimise_calibration_parameters_error(window_data,data_scale,grid_size,x),calibration_init,[],[],options);
end
function error = optimise_calibration_parameters_error(window_data,data_scale,grid_size,calibration_parameters)
%OPTIMISE_CALIBRATION_PARAMETERS_ERROR An implementation of mean plenoptic reprojection error. 
%   Calculates the mean plenoptic reprojection error given a set of window
%   data and an estimate of the calibration parameters. Calibration
%   parameters are pre-scaled by data_scale. 
    [K,~,T] = size(window_data);
    errors = zeros(K,3,T);

    centre_pixel = calibration_parameters(2,1:2);
    cx = centre_pixel(2)/data_scale(2,1);
    cy = centre_pixel(1)/data_scale(2,2);

    K1 = calibration_parameters(1,1)/data_scale(1,1);
    K2 = calibration_parameters(1,2)/data_scale(1,2);
    fx = calibration_parameters(1,3)/data_scale(1,3);
    fy = calibration_parameters(2,3)/data_scale(2,3);
    A = -1/K2;
    B = -K1/K2;
    
    c1 = calibration_parameters(3,1)/data_scale(3,1);
    c2 = calibration_parameters(3,2)/data_scale(3,2);
    c3 = calibration_parameters(3,3)/data_scale(3,3);
    c4 = calibration_parameters(4,1)/data_scale(4,1);
    c5 = calibration_parameters(4,2)/data_scale(4,2);
    c6 = calibration_parameters(4,3)/data_scale(4,3);

    for t = 1:T
        disp_t = calibration_parameters(2*t+3,:)./data_scale(2*t+3,:);
        ang_t = calibration_parameters(2*t+4,:)./data_scale(2*t+4,:);
        rot_t = expm(skew3(ang_t));
        for k = 1:K
            P = (rot_t'*(grid_size*[window_data(k,4:5,t),0]-disp_t)')'; 
            Px = P(1);  
            Py = P(2); 
            Pz = P(3); 
            wx = fx*Px/Pz;
            wy = fy*Py/Pz;
            r = wx^2+wy^2;
            R = (1/(A*Pz)) - B/A;
            wx = wx*(1+c1*r)+cx;
            wy = wy*(1+c1*r)+cy;
            reproj_error = ([R,wx,wy]-window_data(k,1:3,t));
            errors(k,:,t) = reproj_error;
        end
    end
    error = errors;
end
