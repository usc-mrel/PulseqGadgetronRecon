function t1_vfa(connection)
    
    tic;
    addpath(genpath('./src'))

    Neco = double(connection.header.encoding.encodingLimits.set.maximum+1);

    [recon_data, D] = recv_prep_data(connection);

    %% Estimate and send the map
    
    % TODO: Get with xml config
    FlipAngle = [1.0, 1.7627, 3.1072, 5.4772, 9.6549, 17.019, 30.0];
    TR =  connection.header.sequenceParameters.TR;

    % TODO: Use B1map
    b1filename = 'b1afi_fit_MID22_MAGNETOM_eMeRge-XL_NATIONAL_INSTITUTES_OF_HEALTH';
    b1mat = load(sprintf('b1afi_out/%s', b1filename));
    B1map = imresize3(b1mat.FitResults.B1map_filtered, 2, 'method', 'linear');%ones(size(D));
    FitResults = t1vfa_qmr(D, FlipAngle, TR*1e-3, B1map);

    save(sprintf('t1vfa_out/t1vfa_fit_MID%i_%s_%s', ...
        recon_data(1).header.measurement_uid, ...
        replace(connection.header.acquisitionSystemInformation.systemModel, ' ', '_'), ...
        replace(connection.header.acquisitionSystemInformation.institutionName, ' ', '_')), ...
        'FitResults', 'D', 'B1map');
%     Prep for DICOM
    T1_fin = prep_for_dicom(FitResults.T1*1e3); % [s] -> [ms]
    M0_fin = prep_for_dicom(FitResults.M0);

    Nslc = size(D, 3);

    recon_T1 = recon_data(1);
    recon_T1.data(:,:,:,:) = T1_fin;
    recon_T1.header.image_index = 1;
    recon_T1.header.image_series_index = 2;
    recon_T1.meta('GADGETRON_ImageNumber') = "1";
    recon_T1.meta('GADGETRON_ImageComment') = "T1_M0";
    recon_T1.meta('GADGETRON_SeqDescription') = "t1map";
    
    recon_M0 = recon_data(1);
    recon_M0.data(:,:,:,:) = M0_fin;
    recon_M0.header.image_index = Nslc+1;
    recon_M0.header.image_series_index = 2;
    recon_M0.meta('GADGETRON_ImageNumber') = num2str(recon_M0.header.image_index);

    connection.send(recon_T1)
    connection.send(recon_M0)

    toc;
end
