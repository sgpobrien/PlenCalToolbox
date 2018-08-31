function lens_coordinates = generate_lens_coordinates 
%GENERATE_LENS_COORDINATES Generates a set of cartesian coordinates representing the centres of the subimages of each lenslet in pixels. 
%   This is an approximate method which may be automated in future by
%   examining the white-images for the specific camera and optimising for
%   offset and scaling parameters. For the time being, users must find
%   these parameters themselves by adjusting these parameters until the
%   coordinates of the lenslets are positioned directly in the centres of
%   the subimages. 
%   Input: N/A
%   Output: lens_coordinates :: (N*M)x2 Double where:
%   N*M is the total number of lenslets and 2 is for the pixel coordinates 
%   of that lenslet. 

    M = floor(221/3);
    N = floor(176);
    x = zeros(M,N);
    y = zeros(M,N);
    % The following constructs an hexagonal grid of M by N lenslets. 
    for m=1:M
    for n = 1:N 
    x(m,n) = m + 0.25*(-1)^n;
    y(m,n) = n;
    end
    end
    
    % The following scaling and offset parameters were found by eye. 
    % There are 3 sets of X and Ys: one for each lenslet type. 
    X1 = 3*17.4636*x-(39-10.5);
    Y1 = 15.12*y+3.88;
    X2 = (3*17.4636*x-(39-10.5)+17.4636);
    Y2 = (15.12*y+3.88);
    X3 = 3*17.4636*x-(39-10.5)+2*17.4636;
    Y3 = 15.12*y+3.88;

    L = zeros(M,N,2);

    for m=1:M
    for n=1:N
    L(m,n,:) = [X2(m,n),Y2(m,n)];
    end
    end

    % Added refined scaling of the coordinates by 1.9995.
    lens_coordinates = reshape(1.9995*L,numel(L)/2,2);
end


