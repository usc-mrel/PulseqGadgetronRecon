# Siemens to ISMRMRD data conversion

The quantitative parameter estimation code requires two extra header information, `tSequenceVariant` (Hash of the Pulseq sequence) and `tSequenceString` (short string that identifies sequence type) for ensuring the proper file naming of the results. These are added to the parameter map files for VD&VE line and NX line under the `ParameterMaps/` directory. 

In the case of the online reconstruction, these maps need to be copied to the scanner, and pointed out at the XML file at Ice Fire xml config.
In the case of the offline reconstruction, raw data needs to be converted to the MRD format. `dat2mrdv2.sh` script can do that job.

# Reconstruction configs

Gadgetron config files are stored under `configs/` directory. Some configs have parameters to send to `MATLAB` function that effects the mapping algorithm, under the `<external><configuration \>` tag.

In the case of offline reconstruction, `recon.sh` script takes the config file as an input.

In the case of online reconstruciton, Ice Fire xml config points out to the desired config file. The xml files need to be copied to Gadgetron installation's config directory, potentially under the conda environment in which the Gadgetron server is called.

# Offline reconstruction
For offline reconstruction, use `recon.sh`.

MRD data directory hierarchy:

```
|-MRD_ROOT\
    |-h5\
        |-measXXX.h5
            .....
    |-noise\
        |-noise_measXXX.h5
            ......
    |-measXXXX.dat [optional]  
```

Input format is `./recon.sh /path/to/MRD_ROOT/measXXX[.dat] configs/PulseqXDCartesianXXX.xml`.
