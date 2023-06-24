function cvh = est_mask_cvhull(im,th)
%EST_MASK_CVHULL Estimate a mask from convexhull of the objects
%   im: 3D (or  2D) image
%   th: threshold for dumb masking
    immask = im > th;
    Nz = size(im, 3);
    cvh = zeros(size(im));
    for z_i = 1:Nz
        cvh(:,:,z_i) = bwconvhull(immask(:,:,z_i), 'objects');
    end
end

