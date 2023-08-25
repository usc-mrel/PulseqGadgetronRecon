function FitResults = t1irse_qmr(D,TI, TR)
%T2_QMRLAB Summary of this function goes here
%   Detailed explanation goes here


%% Setup qMRLab model
Neco = size(D, 4);
Model = inversion_recovery;
% FlipAngle is a vector of [NX1]
% TR is a vector of [NX1]
Model.Prot.IRData.Mat = TI.';
Model.Prot.TimingTable.Mat = TR;
% Model.lb = [0 0];
% Model.ub = [2e3 0.5];

T1map_struct = struct();
% VFAData.nii.gz contains [128  128    1    N] data.
T1map_struct.IRData=double(D);
% B1map.nii.gz contains [128  128] data.


% Mask.nii.gz contains [128  128] data.
T1map_struct.Mask = est_mask_cvhull(D(:,:,:,1), mean(D(:,:,:,1), 'all'));

FitResults = FitData(T1map_struct,Model,0);

% qMRshowOutput(FitResults,data,Model);

% T2 = FitResults.T2;
% M0  = FitResults.M0;

% save(fullfile("input_data", filename), 'FitResults', "T2", "M", '-append');


end

