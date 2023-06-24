function FitResults = t2mono_qmr(D,TE)
%T2_QMRLAB Summary of this function goes here
%   Detailed explanation goes here


%% Setup qMRLab model
Neco = size(D, 4);
Model = mono_t2;
% FlipAngle is a vector of [NX1]
% TR is a vector of [NX1]
Model.Prot.SEdata.Mat = (1:Neco)'.*TE;
Model.options.OffsetTerm = false;
Model.options.FitType = 'Exponential'; % 'Exponential', 'Linear'
Model.options.DropFirstEcho = true;
% Model.lb = [0 0];
% Model.ub = [2e3 0.5];

T2map_struct = struct();
% VFAData.nii.gz contains [128  128    1    N] data.
T2map_struct.SEdata=double(D);
% B1map.nii.gz contains [128  128] data.


% Mask.nii.gz contains [128  128] data.
T2map_struct.Mask = est_mask_cvhull(D(:,:,:,1), mean(D(:,:,:,1), 'all'));

FitResults = FitData(T2map_struct,Model,0);

% qMRshowOutput(FitResults,data,Model);

% T2 = FitResults.T2;
% M0  = FitResults.M0;

% save(fullfile("input_data", filename), 'FitResults', "T2", "M", '-append');


end

