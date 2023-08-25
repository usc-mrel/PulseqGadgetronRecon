function FitResults = b1sdam_qmr(D, FlipAngle)
%B1VFA_QMR Summary of this function goes here
%   Detailed explanation goes here


%% Setup qMRLab model

Model = b1_dam;
% FlipAngle is a vector of [NX1]
% TR is a vector of [NX1]
Model.Prot.Sequence.Mat = FlipAngle;

% Model.lb = [0 0];
% Model.ub = [2e3 0.5];

%          |- vfa_t1 object needs 3 data input(s) to be assigned:
%          |-   VFAData
%          |-   B1map
%          |-   Mask

b1_data = struct();
% VFAData.nii.gz contains [128  128    1    N] data.
b1_data.SFalpha  = double(D(:,:,:,1));
b1_data.SF2alpha = double(D(:,:,:,2));
% B1map.nii.gz contains [128  128] data.
% Mask.nii.gz contains [128  128] data.
% T1map_struct.Mask=double(sum(T1map_struct.VFAData, 4) > 1e-4).*union_mask;
b1_data.Mask = sum(D, 4) > 40;

FitResults = FitData(b1_data,Model,0);

% qMRshowOutput(FitResults,data,Model);

% T2 = FitResults.T2;
% M0  = FitResults.M0;

% save(fullfile("input_data", filename), 'FitResults', "T2", "M", '-append');


end

