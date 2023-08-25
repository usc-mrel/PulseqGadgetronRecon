function t1_irse(connection)
    
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
    
%     % Parse algo from xml config
%     xmlsp = strsplit(connection.config, 'algo=');
%     algoname = extractBetween(xmlsp{2}, '"','"');
%     algoname = algoname{1};
    algoname = 't1irse';
    %% Estimate and send the map

    TI = [50, 100, 200, 400, 800, 1600, 4500]; % [ms]
    FitResults = t1irse_qmr(D, TI, connection.header.sequenceParameters.TR);


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
    T1_fin = prep_for_dicom(FitResults.T1);

    recon_T1 = recon_data(1);
    recon_T1.data(:,:,:,:) = T1_fin;
    recon_T1.header.image_index = 1;
    recon_T1.header.image_series_index = 2;
    recon_T1.meta('GADGETRON_ImageNumber') = "1";
    recon_T1.meta('GADGETRON_ImageComment') = "T1";
    recon_T1.meta('GADGETRON_SeqDescription') = "t1irse";

    connection.send(recon_T1)

    toc;
end

