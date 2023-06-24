function FitResults = t1vfa_qmr(D, FlipAngle, TR, B1map)
%T1VFA_QMR Summary of this function goes here
%   Detailed explanation goes here


%% Setup qMRLab model

Model = vfa_t1;
% FlipAngle is a vector of [NX1]
% TR is a vector of [NX1]
Model.Prot.VFAData.Mat = [FlipAngle' repelem(TR, length(FlipAngle))'];


% Model.lb = [0 0];
% Model.ub = [2e3 0.5];

%          |- vfa_t1 object needs 3 data input(s) to be assigned:
%          |-   VFAData
%          |-   B1map
%          |-   Mask

T1map_struct = struct();
% VFAData.nii.gz contains [128  128    1    N] data.
T1map_struct.VFAData=double(D);
% B1map.nii.gz contains [128  128] data.
T1map_struct.B1map = B1map;
% Mask.nii.gz contains [128  128] data.
% T1map_struct.Mask=double(sum(T1map_struct.VFAData, 4) > 1e-4).*union_mask;
T1map_struct.Mask = est_mask_cvhull(D(:,:,:,end), mean(D(:,:,:,end), 'all')); % TODO: Observe if mean is good.

FitResults = FitData(T1map_struct,Model,0);

% qMRshowOutput(FitResults,data,Model);

% T2 = FitResults.T2;
% M0  = FitResults.M0;

% save(fullfile("input_data", filename), 'FitResults', "T2", "M", '-append');


end

