function [vial_masks,union_mask] = extract_vial_masks(img, edge_threshold, itype, gscale, erode_px, ifplot)
%EXTRACT_VIAL_MASKS Summary of this function goes here
%   Detailed explanation goes here
[Nx, Ny, Nslc] = size(img, [1 2 3]);

nvial = 14;
vial_masks = zeros(Nx, Ny, Nslc, nvial);
union_mask = zeros(Nx, Ny, Nslc);
for z_i=1:Nslc
    P = register_phantom2d(img(:,:,z_i,:), edge_threshold, itype, gscale);
    
    %% Find and save vial masks
    
    % extract all regions
    minradii = min(P.roi_radii_geo);
    for id = 1:nvial
        vial_masks(:,:,z_i,id) = cmask(Nx, minradii-erode_px,...
                  P.roi_centers_geo(id,1),P.roi_centers_geo(id,2)); % individual vial masks
    end
    union_mask(:,:,z_i) = max(vial_masks(:,:,z_i,:), [], 4); % all vial masks
end


%% Plot rois

% 
% dx = P.dx
% dy = P.dy
% phi = P.phi;
% phi_degrees = phi * 180/pi
% 
% roi_centers = P.roi_centers_geo
% roi_radii = P.roi_radii_geo


if( ifplot )

    figure;
    subplot(221)
    imagesc(double(P.Y))
    colormap(jet)
    colorbar
    title('Image for registration')
    axis image;
    
    subplot(222)
    imagesc(P.Za)
    colormap(jet)
    colorbar
    title('Edges')
    axis image;
    
    subplot(223)
    
    imagesc(P.phantom_mask_init)
    colormap(jet)
    colorbar
    title('Phantom mask, reference')
    axis image;
    
    subplot(224)
    imagesc(P.phantom_mask_match)
    colormap(jet)
    colorbar
    title('Phantom mask, matched')
    axis image;
    
    figure;
    subplot(221)
    imagesc(P.phantom_mask_match .* P.Y )
    colormap(jet)
    colorbar
    title('Image, masked')
    axis image;
    
    subplot(222);
    imagesc(P.phantom_mask_match .* P.Za )
    colormap(jet)
    colorbar
    title('Edges, masked')
    axis image;
    
    % extract all regions
    c = zeros(Nx);
    for id = 1:14
    d = cmask(Nx,P.roi_radii_geo(id)*1.2,...
              P.roi_centers_geo(id,1),P.roi_centers_geo(id,2));
    c = c + d .* P.Za;
    end
    
    subplot(223)

    imagesc(c)
    colormap(jet)
    colorbar
    title('Edges (detected ROIs, tight)')
    axis image;
    
    % extract all regions
    c = zeros(Nx);
    for id = 1:14
    b = cmask(Nx,P.mask_radius,...
              P.roi_centers_geo(id,1),P.roi_centers_geo(id,2));
    c = c + b .* P.Y;
    end
    
    subplot(224)
    imagesc(c)
    colormap(jet)
    colorbar
    title('Image (detected ROIs)')
    axis image;
    
    % extract all regions
    c = zeros(Nx);
    for id = 1:14
        b = cmask(Nx,P.roi_radii_geo(id),...
                  P.roi_centers_geo(id,1),P.roi_centers_geo(id,2));
        c = c + b .* P.Y;
    end
    
    figure;
    imagesc(c)
    title('tight rois')
    colormap(jet)
    colorbar
    title('Image (detected ROIs, tight)')
    axis image;
 
end
end

