#!/bin/bash

rcrsv_cvt=false
CLEAN_MODE=false


while getopts ":hrc" option; do
  case $option in
    h) echo "usage: $0 [-h] [-r] [-c] path_to_convert ..."; exit ;;
    r) rcrsv_cvt=true ;;
    c) CLEAN_MODE=true; echo "Cleaning mode..." ;;
    ?) echo "error: option -$OPTARG is not implemented"; exit ;;
  esac
done

# remove the options from the positional parameters
shift $(( OPTIND - 1 ))

full_name=$1
XSL_FILE=${2:-IsmrmrdParameterMap_Siemens_mod.xsl}

SCRIPT_DIR=$(pwd)

convert2mrd() {
    
    # Adapted from R Ramasawmy convertRR_NX.sh 2019
    NUMFILES=$(siemens_to_ismrmrd -f $1/$2.dat -z 9 | grep only | grep -o '[0-9]*')

    if [ $NUMFILES -gt "1" ]
    then
	# If .dat has noise dependency
	# Only process first noise measurement, and label it "noise_XXX.h5"
    siemens_to_ismrmrd -f "$1/$2.dat" -z 1 -o "$1/noise/noise_$2.h5" -m ${SCRIPT_DIR}/IsmrmrdParameterMap_Siemens_mod.xml -x ${SCRIPT_DIR}/${XSL_FILE} --skipSyncData
    fi

    siemens_to_ismrmrd -f "$1/$2.dat" -z $NUMFILES -o "$1/h5/$2.h5" -m ${SCRIPT_DIR}/IsmrmrdParameterMap_Siemens_mod.xml -x ${SCRIPT_DIR}/${XSL_FILE} --skipSyncData
}

remove_mrd() {
    rm -v "$1/noise/noise_$2.h5" "$1/h5/$2.h5"
}

batch_remove () {
    local dat_file=$(basename "${1}")
    local dat_file=$(echo "$dat_file" | cut -f 1 -d '.')

    remove_mrd './' ${dat_file}
}


batch_convert () {
    local dat_file=$(basename "${1}")
    local dat_file=$(echo "$dat_file" | cut -f 1 -d '.')

    mkdir -p "h5" "noise"

    echo Current file: 
    echo ${dat_file}
    echo ${SCRIPT_DIR}

    convert2mrd '.' ${dat_file}
}

# Create output directories if does not exist

if [ -f "${full_name}" ]; then # If given path is to a file, just convert that file

    if ${rcrsv_cvt}; then
        echo "-r is given with a file name, ignoring recursive option."
    fi

    # Parse filename without extension and folder name
    DAT_FILE=$(basename "${full_name}")
    DAT_FILE=$(echo "$DAT_FILE" | cut -f 1 -d '.')
    DATA_PATH=$(dirname "${full_name}")

    if ${CLEAN_MODE}; then
        remove_mrd ${DATA_PATH} ${DAT_FILE}
    else
        mkdir "${DATA_PATH}/h5" "${DATA_PATH}/noise"

        convert2mrd ${DATA_PATH} ${DAT_FILE}
    fi

else # Otherwise convert all .dat files inside the folder
    ROOT_PATH=${full_name}

    if ${rcrsv_cvt}; then

        if ${CLEAN_MODE}; then
            echo "Recursively removing..."

            export -f remove_mrd
            export -f batch_remove
            find "${ROOT_PATH}" -name \*.dat -execdir bash -c "batch_remove \"{}\"" \;

        else
            echo "Recursively converting..."

            export XSL_FILE
            export SCRIPT_DIR
            export -f convert2mrd
            export -f batch_convert
            find "${ROOT_PATH}" -name \*.dat -execdir bash -c "batch_convert \"{}\"" \;

        fi
    else
        DATA_PATH=${ROOT_PATH}

        if ${CLEAN_MODE}; then
            
            for i in ${DATA_PATH}/*.dat; do
                [ -f "$i" ] || break
                    DAT_FILE=$(basename "${i}")
                    DAT_FILE=$(echo "$DAT_FILE" | cut -f 1 -d '.')
                    
                    remove_mrd ${DATA_PATH} ${DAT_FILE}
            done
            
        else

            mkdir -p "${DATA_PATH}/h5" "${DATA_PATH}/noise"

            for i in ${DATA_PATH}/*.dat; do
                [ -f "$i" ] || break
                    DAT_FILE=$(basename "${i}")
                    DAT_FILE=$(echo "$DAT_FILE" | cut -f 1 -d '.')
                    
                    convert2mrd ${DATA_PATH} ${DAT_FILE} 
            done
        fi
    fi

fi

echo "Done."
