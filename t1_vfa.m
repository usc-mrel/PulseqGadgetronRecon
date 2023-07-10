function t1_vfa(connection)
    
    tic;
    addpath(genpath('./src'))

    [recon_data, D] = recv_prep_data(connection);

    % Parse b1map from xml config
    xmlsp = strsplit(connection.config, 'b1map=');
    b1map_param = extractBetween(xmlsp{2}, '"','"');
    b1map_param = b1map_param{1};
    
    % Find the output dir
    
    if connection.header.acquisitionSystemInformation.institutionName == "NATIONAL INSTITUTES OF HEALTH" ...
        || connection.header.acquisitionSystemInformation.institutionName == "NHLBI"
        institutionName = "NIH";
    else
        institutionName = connection.header.acquisitionSystemInformation.institutionName;
    end
    outpath = sprintf('outputs/%s/%s', institutionName, connection.header.acquisitionSystemInformation.systemModel);
    %% Estimate and send the map
    
    % TODO: Get with xml config
    FlipAngle = [1.0, 1.7627, 3.1072, 5.4772, 9.6549, 17.019, 30.0];
    TR =  connection.header.sequenceParameters.TR;

    % Find and load B1 map
    if b1map_param == "none"
        B1map = ones(size(D));
    elseif b1map_param == "auto_afi" || b1map_param == "auto_dam"
        % ASSUMPTIONS: 
        % - B1 map acquired before, or right 3 after the VFA.
        % - B1 map successfully reconstructed.
        % - B1 map is acquired at the same institution, same device
        % - B1 map is the closest MID B1 map acquisition.
        
        b1algo = strsplit(b1map_param, '_');
        b1algo = b1algo{2};
        
        mlist = dir([outpath '/*.mat']);
        
        b1mlist = [];

        for f_i=1:length(mlist)
            if contains(mlist(f_i).name, b1algo)
                b1mlist = [b1mlist; mlist(f_i).name];
            end
        end
        
        if size(b1mlist, 1) > 0
            curMID = recon_data(1).header.measurement_uid;
            
            mids = zeros(1, size(b1mlist, 1));
            for mid_i=1:size(b1mlist, 1)
                midc = extractBetween(b1mlist(mid_i,:), 'MID', '.');
                mids(mid_i) = str2double(midc{1});
            end
            
            mids(mids >= curMID+3) = 0;
            
            [maxmid, I] = max(mids);
            
            if maxmid < curMID-5
               warning('Closest MID is too far away, continuing anyways...') 
            end
            
            b1filename = b1mlist(I,:);
            
            fprintf('Found B1 map: %s\n', b1filename)
            
            b1mat = load(sprintf('%s/%s', outpath, b1filename));
            B1map = imresize3(b1mat.FitResults.B1map_filtered, 2, 'method', 'linear');
            
            
        else
            warning('No B1 map was found. Using all 1s.')
            B1map = ones(size(D));
        end


    
    else
        b1mat = load(b1map_param);
        B1map = imresize3(b1mat.FitResults.B1map_filtered, 2, 'method', 'linear');  
    end
    
    FitResults = t1vfa_qmr(D, FlipAngle, TR*1e-3, B1map);

    mkdir(outpath);
    seqname = connection.header.userParameters.userParameterString(1).value(1:end-3);
    save(sprintf('%s/%s_%s_MID%i', ...
        outpath, ...
        seqname, ...
        'vfa', ...
        recon_data(1).header.measurement_uid), ...
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
