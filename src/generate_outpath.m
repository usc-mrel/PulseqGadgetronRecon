function [outpath] = generate_outpath(header, patientID)
%GENERATE_OUTPATH Summary of this function goes here
%   Detailed explanation goes here
   % Find the output dir
    
    if upper(header.acquisitionSystemInformation.institutionName) == "NATIONAL INSTITUTES OF HEALTH" ...
        || header.acquisitionSystemInformation.institutionName == "NHLBI"
        institutionName = "NIH";
    else
        institutionName = header.acquisitionSystemInformation.institutionName;
    end
    
    if upper(header.acquisitionSystemInformation.systemModel) == "MAGNETOM EMERGE-XL"
        systemModel = "FreeMax";
    elseif upper(header.acquisitionSystemInformation.systemModel) == "INVESTIGATIONAL_DEVICE_VE11S_S118"
        systemModel = "Aera";
    else
        systemModel = header.acquisitionSystemInformation.systemModel;
    end
    outpath = sprintf('outputs/%s/%s/%s', institutionName, systemModel, patientID);
end

