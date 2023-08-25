function t2_map(connection)
    
    tic;
    addpath(genpath('./src'))

    [recon_data, D] = recv_prep_data(connection);
    %% Ugly Free.Max fix. Can't do FoV shift, so we shift post processing.
    if upper(connection.header.acquisitionSystemInformation.systemModel) == "MAGNETOM EMERGE-XL"
        xshift_mm = 40; % [mm]
        nx = connection.header.encoding.reconSpace.matrixSize.x;
        dx = connection.header.encoding.reconSpace.fieldOfView_mm.x./nx;
        shift_px = xshift_mm./dx;

        Dk = gadgetron.lib.fft.cifft(D, 2).*exp(-2i*pi*shift_px*((-nx/2):(nx/2-1))./nx); 
        D = abs(gadgetron.lib.fft.cfft(Dk, 2));
    end
    
    % Parse algo from xml config
    xmlsp = strsplit(connection.config, 'algo=');
    algoname = extractBetween(xmlsp{2}, '"','"');
    algoname = algoname{1};
    %% Estimate and send the map

    if algoname == "t2mono"
        FitResults = t2mono_qmr(D, connection.header.sequenceParameters.TE);
    elseif algoname == "t2stimfit"
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
    else
        warning('Wrong algo name. Exiting...');
        return;
    end

    outpath = generate_outpath(connection.header, recon_data(1).meta('patientID'));
    mkdir(outpath);
    seqname = connection.header.userParameters.userParameterString(1).value(1:end-3);
    save(sprintf('%s/%s_%s_MID%i', ...
        outpath, ...
        seqname, ...
        algoname, ...
        recon_data(1).header.measurement_uid), ...
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

