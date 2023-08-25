addpath('src/')
%% Parameters
clear; close all;
filepath = 'outputs/NIH/Aera/54383215/mcse2d_t2stimfit_MID382';
gscale = 0.5; % For 2mm resolution (1mm/2mm)
nrots = 0;
erode_px = 1;
edge_threshold = 0.05;
itype = 1; % MnCl2=2, NiCl2=1

load(filepath)
figure; imshow(D(:,:,1), []);
%% Extract
addpath('src/register_rrsg2020-v1.0.2')

[Nx, Ny, Nz, Neco] = size(D, [1 2 3 4]);
img = fliplr(rot90(reshape(D, [Nx, Ny, Nz, Neco]), nrots));

img = sum(img,4);

[vial_masks,union_mask] = extract_vial_masks(img, edge_threshold, itype, gscale, erode_px, true);

union_mask = fliplr(union_mask);
vial_masks = fliplr(vial_masks);

%% Save
save(filepath, 'union_mask', 'vial_masks', '-append')
