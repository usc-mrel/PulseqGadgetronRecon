function t2_mono(connection)
    
    tic;
    addpath(genpath('./src'))

    Neco = double(connection.header.encoding.encodingLimits.set.maximum+1);
    [recon_data, D] = recv_prep_data(connection);


    %% Estimate and send the map

    FitResults = t2mono_qmr(D, connection.header.sequenceParameters.TE);

    save(sprintf('t2mono_out/t2mono_fit_MID%i_%s_%s', ...
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

