function FitResults = t2_stimfit_(D,seq_info)
%T2_STIMFIT_ Summary of this function goes here
%   Detailed explanation goes here

%% Load Data

%   Unpack sequence info and predefined options structure

TE      = seq_info.TE;
rfe     = seq_info.rfe;
t_rfe   = seq_info.t_rfe;
rfr     = seq_info.rfr;
t_rfr   = seq_info.t_rfr;
Ge      = seq_info.Ge;
Gr      = seq_info.Gr;
Dz      = seq_info.slice_thickness;

[Nx, Ny, Neco] = size(D, [1 2 4]);


% Fill opt struct
opt = StimFit_optset('s');

%opt.mode = 's';
opt.Dz = [-Dz/2 Dz/2]; % [cm]
opt.Nz = 20;
opt.Nrf = length(rfe);
opt.esp = TE*1e-3; % [s]
opt.etl = Neco;
% opt.T1 = @(T2) 1;

opt.debug = 0;
opt.th = 20;%0;
opt.th_te = 2:6;
opt.FitType = 'lsq';

% Excitation
opt.RFe.path = "";
opt.RFe.RF = 1e4*rfe./(42.58e6*10);
opt.RFe.tau = t_rfe(end); % [s]
opt.RFe.G = Ge;
opt.RFe.phase = 0;
opt.RFe.angle = 90;
opt.RFe.ref = 1;

% Refocusing
opt.RFr.path = "";
opt.RFr.RF = 1e4*rfr./(42.58e6*10);
opt.RFr.tau = t_rfr(end); % [s]
opt.RFr.G = Gr;
opt.RFr.phase = 90;
opt.RFr.angle = 180;
opt.RFr.ref = 0;

% LSQ options

opt.lsq.Ncomp = 1;

opt.lsq.Icomp.X0   = [0.060 1e-1 0.99];      %   Starting point (1 x 3) [T2(s) amp(au) B1(fractional)]
opt.lsq.Icomp.XU   = [5.000 1e+3 1.00];      %   Upper bound (1 x 3)
opt.lsq.Icomp.XL   = [0.005 0.00 0.30];      %   Lower bound (1 x 3)

%%% FIT SINGLE VOXEL %%%
% S = squeeze(img(70,69,1,:));
% opt.debug = 1;
% opt.FitType = 'lsq';
% [T2,B1,amp] = StimFit(S,opt);


%%% FIT ENTIRE IMAGE %%%

[T2,B1,amp, opt] = StimFitImgPulseq(D, opt);

FitResults.T2 = T2;
FitResults.M0 = B1;
FitResults.amp = amp;
FitResults.opt = opt;
end

