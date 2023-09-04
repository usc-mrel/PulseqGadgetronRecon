function [recon_data,D] = recv_prep_data(connection)
%RECV_PREP_DATA Summary of this function goes here
%   Detailed explanation goes here

    Neco = double(connection.header.encoding.encodingLimits.set.maximum+1);
    try
        % Once the connection is consumed, calling next will throw an
        % exception. We wrap the loop in a try here to avoid printing an
        % error. 
        
        % Accumulate
        recon_data = [];
        for eco_i=1:Neco
            recon_data = [recon_data connection.next()];

        end
    end

    %% Calculate and apply scaling

    minVal =  Inf;
    maxVal = -Inf;
    for eco_i=1:Neco
        minVal = min(minVal, min(abs(recon_data(eco_i).data), [], 'all'));
        maxVal = max(maxVal, max(abs(recon_data(eco_i).data), [], 'all'));
    end

    mScale = (2^12-1)./(maxVal-minVal);
    % Extract the 4D array for passing to T2 estimation.
    D = zeros([size(recon_data(1).data, [2, 3, 4]), Neco]);
    for eco_i=1:Neco
        D(:,:,:,eco_i) = recon_data(eco_i).data.*mScale;
        recon_data(eco_i).data = round((abs(recon_data(eco_i).data)-minVal).*mScale);
        recon_data(eco_i).header.data_type = gadgetron.types.Image.FLOAT;
        connection.send(recon_data(eco_i))
    end
end

