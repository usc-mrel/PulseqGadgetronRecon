#!/bin/bash

# full_name=/mnt/LIN_DATA/MRI_DATA/2023-05-31-PulSeq_HV-FreeMax/raw/meas_MID00023_FID05617_pulseq_MCSE.h5

full_name=$1

portn=${2:-9009}
configfile=${3:-./configs/PulseqCartesian.xml}
condaenvname=${4:-gadgetron}

# Split the full path into filename and directory path
meas_name=$(basename "${full_name}")
# Get rid of the extension for convenience
meas_name=$(echo "${meas_name}" | cut -f 1 -d '.')
meas_folder=$(dirname "${full_name}")

echo $meas_folder
echo $meas_name

mkdir -p $meas_folder

# Upload dependency measurements to the storage server
conda run -n $condaenvname gadgetron_ismrmrd_client --verbose -p $portn -f "$meas_folder/noise/noise_${meas_name}.h5" -c default_measurement_dependencies_ismrmrd_storage.xml
# matlab -nodisplay -batch "gadgetron.external.listen(18000, @gadgetron.quantitative.t1_vfa);" &

# Run the recon
conda run -n $condaenvname gadgetron_ismrmrd_client -p $portn -f $meas_folder/h5/$meas_name.h5 -o "$meas_folder/recon_$meas_name.h5" -C $configfile
