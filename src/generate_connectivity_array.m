function connection_array = generate_connectivity_array(lens_coordinates,scale,resolution)
%GENERATE_CONNECTIVITY_ARRAY Generates an array used for the interpolation used in generation of sub-aperture images. 
%   Calculation of a sub-aperture image from a light-field image
%   necessarily involves some sort of interpolation as it involves
%   assigning to a rectangular array colours that are defined on an
%   hexagonal array (since lenslets are arranged in an hexagonal array.
%   The interpolation used in this toolbox is convex interpolation and
%   requires knowledge of which three lenslets are `closest' to a given
%   pixel. As finding the nearest lenslets to a given rectangular
%   grid-point is computationally expensive, precalculating this array
%   results in a significant speed-up of computation of sub-aperture
%   images.
%   Inputs: lens_coordinates (see: generate_lens_coordinates)
%           scale :: Double (approximate true size of lenslets in pixels)
%           resolution :: 1x2 Int (size of light-field image)

connection_array = zeros(round(resolution(1)/scale),round(resolution(2)/scale),2,3);
for m = 1:round(resolution(1)/scale)
    for n = 1:round(resolution(2)/scale)
        [100*m/round(resolution(1)/scale),100*n/round(resolution(2)/scale)]
        dists = sqrt(sum(bsxfun(@minus,lens_coordinates,[n,m]*scale).^2,2));
        [sorted_dists,indices] = sort(dists);
        nearest_indices = indices(1:3);
        ratios = zeros(1,3);
        for k = 1:3
            ratios(k) = prod(sorted_dists([(1:k-1),(k+1:3)]));
        end
        ratios = ratios/(sum(ratios));
        connection_array(m,n,:,:) = [nearest_indices';ratios];
    end
end
end
