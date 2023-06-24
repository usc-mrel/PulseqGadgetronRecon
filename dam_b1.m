function sdam_b1(connection)
    
    tic;
    addpath(genpath('./src'))

    [recon_data, D] = recv_prep_data(connection);

    %% Estimate and send the map

    % TODO: Get with xml config
    FlipAngle = 30;

    FitResults = b1dam_qmr(D, FlipAngle);

    save(sprintf('b1dam_out/b1dam_fit_MID%i_%s_%s', ...
        recon_data(1).header.measurement_uid, ...
        replace(connection.header.acquisitionSystemInformation.systemModel, ' ', '_'), ...
        replace(connection.header.acquisitionSystemInformation.institutionName, ' ', '_')), ...
        'FitResults', 'D');
    
%     Prep for DICOM
    B1raw_fin = prep_for_dicom(FitResults.B1map_raw*1e3);
    B1filt_fin = prep_for_dicom(FitResults.B1map_filtered*1e3);

    Nslc = size(D, 3);
    recon_B1raw = recon_data(1);
    recon_B1raw.data(:,:,:,:) = B1raw_fin;
    recon_B1raw.header.image_index = 1;
    recon_B1raw.meta('GADGETRON_ImageNumber') = num2str(recon_B1raw.header.image_index);
    recon_B1raw.meta('GADGETRON_ImageComment') = "B1_raw_filtered";
    recon_B1raw.meta('GADGETRON_SeqDescription') = "b1maps";

    recon_B1filt = recon_data(1);
    recon_B1filt.data(:,:,:,:) = B1filt_fin;
    recon_B1filt.header.image_index = Nslc+1;
    recon_B1filt.header.image_series_index = 2;
    recon_B1filt.meta('GADGETRON_ImageNumber') = num2str(recon_B1filt.header.image_index);

    connection.send(recon_B1raw)
    connection.send(recon_B1filt)

    toc;
end
