#!/bin/bash

ROOT_PATH=$1

PORT_NUMBER=${2:-9009}
CONDA_ENV_NAME=${3:-gadgetron}

CURRENT_CFG_XML=configs/Pulseq2DCartesianT2Mono.xml

SCRIPT_DIR=$(pwd)

source ~/miniconda3/etc/profile.d/conda.sh
conda activate ${CONDA_ENV_NAME}

batch_recon () {
    echo $1
    #${SCRIPT_DIR}/recon_slim.sh "$1" "${PORT_NUMBER}" "${SCRIPT_DIR}/${CURRENT_CFG_XML}" "${CONDA_ENV_NAME}"
    ntry=5
    while [ $ntry -gt 0 ]; 
    do 
        # Command failed randomly, try again and hope for the best
        ${SCRIPT_DIR}/recon_slim.sh "$1" "${PORT_NUMBER}" "${SCRIPT_DIR}/${CURRENT_CFG_XML}" "${CONDA_ENV_NAME}"
        if [ $? -eq 0 ]; then
            echo "Command succeeded"
            break
            
        else
            echo "Command failed, trying again..."
            ntry=$(($ntry-1))
            sleep 1 # Maybe it needs some sleep.
        fi
        
    done
    

    if [ $ntry -eq 0 ]; then
        echo "Command failed too many times. Exiting..."
        exit -1
    fi

}


export ROOT_PATH
export PORT_NUMBER
export CURRENT_CFG_XML
export CONDA_ENV_NAME
export SCRIPT_DIR
export -f batch_recon

CURRENT_CFG_XML=configs/Pulseq2DCartesianT2Stimfit.xml
find "${ROOT_PATH}" \( -name "*MCSE*.dat" -o -name "*mcse*.dat" \) \
                   -execdir bash -c "batch_recon \"{}\"" \;
                    
CURRENT_CFG_XML=configs/Pulseq2DCartesianT2Mono.xml
find "${ROOT_PATH}" \( -name "*SESE*.dat" -o -name "*sese*.dat" \) \
                    -execdir bash -c "batch_recon \"{}\"" \;

CURRENT_CFG_XML=configs/Pulseq2DCartesianT1IRSE.xml
find "${ROOT_PATH}" \( -name "*IRSE*.dat" -o -name "*irse*.dat" \) \
                    -execdir bash -c "batch_recon \"{}\"" \;

CURRENT_CFG_XML=configs/Pulseq3DCartesianB1AFI.xml
find "${ROOT_PATH}" \( -name "*AFI*.dat" \) \
                   -execdir bash -c "batch_recon \"{}\"" \;

CURRENT_CFG_XML=configs/Pulseq3DCartesianB1DAM.xml
find "${ROOT_PATH}" \( -name "*DAM*.dat" \) \
                   -execdir bash -c "batch_recon \"{}\"" \;

CURRENT_CFG_XML=configs/Pulseq3DCartesianT1VFA.xml
find "${ROOT_PATH}" \( -name "*VFA*.dat" \) \
                   -execdir bash -c "batch_recon \"{}\"" \;
