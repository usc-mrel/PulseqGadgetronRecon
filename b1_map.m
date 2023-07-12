function b1_map(connection)
    
    tic;
    addpath(genpath('./src'))

    [recon_data, D] = recv_prep_data(connection);
    
    % Parse algo from xml config
    xmlsp = strsplit(connection.config, 'algo=');
    algoname = extractBetween(xmlsp{2}, '"','"');
    algoname = algoname{1};

    %% Estimate and send the map

    if algoname == "afi"

        % TODO: Get with xml config
        FlipAngle = 60;
        N=3;
        TR1 = connection.header.sequenceParameters.TR.*1e-3;
        TR2 = TR1*N;

        FitResults = b1afi_qmr(D, FlipAngle, TR1, TR2);
        
    elseif algoname == "dam"
        % TODO: Get with xml config
        FlipAngle = 30;

        FitResults = b1dam_qmr(D, FlipAngle);
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
