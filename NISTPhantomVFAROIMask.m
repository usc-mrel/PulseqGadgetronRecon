addpath(genpath('src/'))
%% Parameters
clear; close all;
filepath = 'outputs/NIH/FreeMax/30000023062914545529800000009/vfagre3_vfa_MID256';

gscale = 0.5; % For 2mm resolution (1mm/2mm)
nrots = 0;
erode_px = 1;
edge_threshold = 0.05;

load(filepath)

%% Extract
addpath('src/register_rrsg2020-v1.0.2')

[Nx, Ny, Nz, Neco] = size(D, [1 2 3 4]);
img = fliplr(rot90(reshape(D, [Nx, Ny, Nz, Neco]), nrots));

init_slc = 5;
slc_nicl2 = init_slc      + (0:5);
slc_mncl2 = init_slc + 20 + (0:5);

img_mncl2 = sum(img(:,:,slc_mncl2,:),4);
img_nicl2 = sum(img(:,:,slc_nicl2,:),4);

nvial = 14;
Nslc = size(D, 3);

union_mask = zeros(Nx, Ny, Nz);
vial_masks_mncl2 = zeros(Nx, Ny, Nz, nvial);
vial_masks_nicl2 = zeros(Nx, Ny, Nz, nvial);

itype = 2; % MnCl2
[vial_masks_mncl2_,union_mask_mncl2] = extract_vial_masks(img_mncl2, edge_threshold, itype, gscale, erode_px, false);


itype = 1; % NiCl2
[vial_masks_nicl2_,union_mask_nicl2] = extract_vial_masks(img_nicl2, edge_threshold, itype, gscale, erode_px, false);

union_mask(:,:,slc_mncl2) = union_mask_mncl2;
union_mask(:,:,slc_nicl2) = union_mask_nicl2;
union_mask = fliplr(union_mask);

vial_masks_mncl2(:,:,slc_mncl2,:) = fliplr(vial_masks_mncl2_);
vial_masks_nicl2(:,:,slc_nicl2,:) = fliplr(vial_masks_nicl2_);

%% Save Data
save(filepath, 'union_mask', 'vial_masks_mncl2', 'vial_masks_nicl2', '-append')
