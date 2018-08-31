function parameters = linear_estimate_calibration_parameters(window_data,nfiles,grid_size,centre_pixel,checkerboard,positions,rotations,showPlots)
%LINEAR_ESTIMATE_CALIBRATION_PARAMETERS Generates an initial estimate of the calibration parameters of the camera. 
%   This function generates an initial estimate of the calibration
%   parameters of the plenoptic camera by solving a linear system that
%   these calibration parameters should satisfy in the least-squares
%   sense. 
%   The calibration parameters are an array formatted in the following way:
%   [I;E] where I is a 4x3 block representing intrinsic parameters of the
%   camera (note that some of these parameters are not used) and E is a
%   (2*T)x3 block representing the extrinsic parameters of the camera.
%   The entries of the intrinsic block are as follows:
%   parameters(1,1) = K1 (intrinsic factor 1)
%   parameters(1,2) = K2 (intrinsic factor 2)
%   parameters(1,3) = fx (focal distance x coordinate)
%   parameters(2,1) = fy (focal distance y coordinate)
%   parameters(2,2) = cx (optical centre x coordinate)
%   parameters(2,3) = cy (optical centre y coordinate)
%   parameters(3,1) = k1 (radial distortion parameter)
%   The remaining intrinsic parameters are place-holders and are not
%   currently used in this implementation. The extrinsics are then
%   formatted in the following way: 
%   parameters(t+4,:) = [tx,ty,tz] position of camera for frame t
%   parameters(t+5,:) = [wx,wy,wz] skew parameters of orientation of camera
%   at frame t. 
%   Inputs: window_data :: Kx5xT Double (see: format_window_data) 
%           nfiles      :: Int
%           grid_size   :: Double
%           centre_pixel :: 1x2 Double 
%           checkerboard :: Kx3 Double
%           positions :: Tx3 Double
%           rotations :: Tx3 Double
%           showPlots :: Bool
%   Outputs: parameters :: (4+2*T)x3 Double (see above)
    
    [K,~,~] = size(window_data);

    for t = 1:nfiles
        window_map = window_data(:,:,t);
        for k=1:K
            i = grid_size*window_map(k,4);
            j = grid_size*window_map(k,5);
            R = window_map(k,1);
            lx = window_map(k,2)-centre_pixel(2);
            ly = window_map(k,3)-centre_pixel(1);
            indices = ((((k-1)*3+1)):(((k-1)*3+3)));
            data_map(indices,:)=[[lx;ly;R]*[i,j,1],kron(eye(3),[i,j,1])];
        end
        [~,~,V] = svd(data_map);
        singularvector(:,t)=V(:,end);
    end
    
    f_ = zeros(1,nfiles);
    for t = 1:nfiles
        v = singularvector(:,t);
        f_(t) = sqrt(abs(-(v(4)*v(5)+v(7)*v(8))/(v(1)*v(2))));
    end

    f=median(f_(imag(f_)==0));

    lambda_ = zeros(1,nfiles);
    K1_ = zeros(1,nfiles);
    K2_ = zeros(1,nfiles);
    RT = zeros(1,nfiles*6);
    for t=1:nfiles
        v=singularvector(:,t);

        if v(3) < 0
            v = -v;
        end
        
        r1=[-v(4)/f_(t);-v(7)/f_(t);v(1)];
        lambda_(t)=norm(r1);
        r1=r1/lambda_(t);
        r2=[-v(5)/f_(t);-v(8)/f_(t);v(2)];
        r3=cross(r1,r2);
        r3=r3/norm(r3);
        r2=cross(r3,r1);
        R=[r1,r2,r3];
        T=[-v(6)/f_(t);-v(9)/f_(t);v(3)]/lambda_(t);
        
        K1_(t)=(v(10)+v(11))/(v(1)+v(2));
        K2_(t)=v(12)/lambda_(t)-K1_(t)*v(3)/lambda_(t);

        pos = (R'*(-T))';
        rot = R'; 
        rot_est(:,:,t) = rot;
        pos_est(:,:,t) = pos;
        skew = logm(rot);
        ang_est(:,:,t) = [skew(3,2),skew(1,3),skew(2,1)];
    end
       
    K1=median(K1_);
    K2=median(K2_);
    A = -1/K2;
    B = -K1/K2;
    
    A_ = -1./K2_;
    B_ = -K1_./K2_;
    
%     parameters = [A,B,f;centre_pixel(1),centre_pixel(2),f;0,0,0;0,0,0];
    parameters = [K1,K2,f;centre_pixel(1),centre_pixel(2),f;0,0,0;0,0,0];
    for t = 1:nfiles
        parameters(2*t+3,:) = pos_est(:,:,t);
        parameters(2*t+4,:) = ang_est(:,:,t);
    end    
    
    %% Test Functions
    
    if showPlots
        figure;
        hold on;

        for t = 1:nfiles
            scale = 10*grid_size;
            rot = rot_est(:,:,t);
            pos = pos_est(:,:,t);
            scatter3(pos(1),pos(2),pos(3),'ko');
            ax1 = [pos;pos + scale*rot(:,1)'];
            ax2 = [pos;pos + scale*rot(:,2)'];
            ax3 = [pos;pos + scale*rot(:,3)'];
            plot3(ax1(:,1),ax1(:,2),ax1(:,3),'c');
            plot3(ax2(:,1),ax2(:,2),ax2(:,3),'m');
            plot3(ax3(:,1),ax3(:,2),ax3(:,3),'k');
        end

        switch nargin 
            case 8
                for t = 1:nfiles
                    rot = rotations(:,:,t);
                    pos = positions(:,:,t);
                    scatterarray3(pos,'k*');
                    plotarray3([pos;pos+scale*rot(:,1)'],'r');
                    plotarray3([pos;pos+scale*rot(:,2)'],'g');
                    plotarray3([pos;pos+scale*rot(:,3)'],'b');
                end
                scatterarray3(checkerboard,'k');
                axis equal
        end
    end

    for t = 1:nfiles
        window_map = window_data(:,:,t);
        rot = rot_est(:,:,t);
        pos = pos_est(:,:,t);
        for k=1:K
            R = window_map(k,1);
            lx = window_map(k,2)-centre_pixel(2);
            ly = window_map(k,3)-centre_pixel(1);
            Pz = 1/(B_(t) + A_(t)*R);
            Px = Pz*lx/f_(t);
            Py = Pz*ly/f_(t);
            P = pos+(rot*[Px;Py;Pz])';
            if showPlots
                scatterarray3(P,'r');
            end
            point_err(k) = norm(P - [grid_size*window_map(k,4),grid_size*window_map(k,5),0]);
        end
    end
    mean(point_err)
    
end
