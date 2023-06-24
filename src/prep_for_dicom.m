function imo = prep_for_dicom(im)
    imo = im;
    imo(isnan(imo)) = 0;
    imo(imo < 0) = 0;
    imo(imo > 4095) = 4095;
    imo = single(round(imo));
end
