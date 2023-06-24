function t2_stimfit(connection)
    
    tic;
    addpath(genpath('./src'))

    Neco = double(connection.header.encoding.encodingLimits.set.maximum+1);
    [recon_data, D] = recv_prep_data(connection);


    %% Estimate and send the map

    rfinf = load('t2_mese_rfinfo.mat');
    seq_info.TE                 = connection.header.sequenceParameters.TE;
    seq_info.slice_thickness    = connection.header.encoding.reconSpace.fieldOfView_mm.z*0.1; % [mm] -> [cm]
    seq_info.t_rfr              = rfinf.t_rfr;
    seq_info.rfr                = rfinf.rfr;
    seq_info.t_rfe              = rfinf.t_rfe;
    seq_info.rfe                = rfinf.rfe;
    seq_info.Ge                 = rfinf.Ge;
    seq_info.Gr                 = rfinf.Gr;

    FitResults = t2_stimfit_(D, seq_info);

    save(sprintf('t2stimfit_out/t2stimfit_fit_MID%i_%s_%s', ...
        recon_data(1).header.measurement_uid, ...
        replace(connection.header.acquisitionSystemInformation.systemModel, ' ', '_'), ...
        replace(connection.header.acquisitionSystemInformation.institutionName, ' ', '_')), ...
        'FitResults', 'D');
    % Prep for DICOM
    T2_fin = prep_for_dicom(FitResults.T2);
    M0_fin = prep_for_dicom(FitResults.M0);

    recon_T2 = recon_data(1);
    recon_T2.data(:,:,:,:) = T2_fin;
    recon_T2.header.image_index = 1;
    recon_T2.header.image_series_index = 2;
    recon_T2.meta('GADGETRON_ImageNumber') = "1";
    recon_T2.meta('GADGETRON_ImageComment') = "T2_M0";
    recon_T2.meta('GADGETRON_SeqDescription') = "t2map";

    recon_M0 = recon_data(1);
    recon_M0.data(:,:,:,:) = M0_fin;
    recon_M0.header.image_index = 2;
    recon_M0.header.image_series_index = 2;
    recon_M0.meta('GADGETRON_ImageNumber') = "2";

    connection.send(recon_T2)
    connection.send(recon_M0)

    toc;
end

