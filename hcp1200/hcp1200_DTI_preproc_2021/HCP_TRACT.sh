#!/bin/env bash

#SBATCH --job-name=TRACT_PIPE
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH -t 2-0:0:0
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=6G
#SBATCH --account=kg98

## This script will run tractography on HCP data

## If running as an array job, the following code can be used to read subject IDs from a text file.
#declare -i ID=$SLURM_ARRAY_TASK_ID
#echo $SLURM_ARRAY_TASK_ID
#SUBJECT_LIST=$1
#SUBJECTID=$(sed -n "${ID}p" ${SUBJECT_LIST})
#WORKDIR="$2/${SUBJECTID}"

# SUBJECTID is the ID of the subject you want to run tractography/connectome generation on
SUBJECTID=$1
# WORKDIR is where you want to put the data generated by this script
WORKDIR=$2
# WHERESMYSCRIPT is where this script is located
WHERESMYSCRIPT=$3
# PARENTDIR is where the data this script will need is located
PARENTDIR=$4

# Check in SUBJECTID is empty. If empty exit the script because this can cause massive issues if the script reads an empty string for this value
 if [ "${SUBJECTID}" = "" ]; then
	exit
 fi

### Adjust code below this line to control the parameters of the script

## Run steps

# RUN_PREPARATION copies data into the working directory
RUN_PREPARATION=0
# RUN_STAGE_ONE generates masks
RUN_STAGE_ONE=0
# RUN_STAGE_TWO generates the response funciton for CSD
RUN_STAGE_TWO=0
# RUN_STAGE_THREE generates tensors and runs CSD 
RUN_STAGE_THREE=0
# RUN_STAGE_FOUR runs tractography
RUN_STAGE_FOUR=0
# RUN_STAGE_FIVE runs SIFT
RUN_STAGE_FIVE=0
# RUN_STAGE_SIX copies parcellations into the work directory (if desired)
RUN_STAGE_SIX=0
# RUN_STAGE_SEVEN generates connectomes
RUN_STAGE_SEVEN=0
# RUN_STAGE_EIGHT generates density corrected connectomes
RUN_STAGE_EIGHT=0
# RUN_STAGE_NINE finds the coordinates of each node in each parcellation
RUN_STAGE_NINE=0
# RUN_STAGE_TEN finds the T1w/T2w ratio of each ROI (provided you have a T2w scan)
RUN_STAGE_TEN=0

# Name of input diffusion data
DIFFUSION_IN_NAME="data.nii.gz"
# Location and name of input diffusion data
DIFFUSION_DATA_PATH="${PARENTDIR}/${SUBJECTID}/T1w/Diffusion/data.nii.gz"

# Set DIFFUSION_DATA_NAME to what you wish to call the diffusion data as it is handled by this script
DIFFUSION_DATA_NAME="dwi.mif"

# Set the name and location of a T1 image 
T1_PATH="${PARENTDIR}/${SUBJECTID}/T1w/T1w_acpc_dc_restore_1.25.nii.gz"
# Set the name of the T1 image as handled by the script (note this image isn't actually used for anything, just helps to have it in the same directory to make any visualisation easy
T1_NAME="T1.nii.gz"

# Set the name and location of the T1 image for use with ACT
ACT_T1_NAME="T1w_acpc_dc_restore_brain.nii.gz"

# Set the name and location of the bvecs and bvals
BVALS_NAME="bvals"
BVALS_PATH="${PARENTDIR}/${SUBJECTID}/T1w/Diffusion/bvals"
BVECS_NAME="bvecs"
BVECS_PATH="${PARENTDIR}/${SUBJECTID}/T1w/Diffusion/bvecs"

# Set the name and location of the ACT image. Only applicable if not generating the image in this script
ACT_NAME="ACT.nii"
ACT_PATH="${PARENTDIR}/${SUBJECTID}/ACT/ACT.nii"

# Set the name and location of the image containing the T1w/T2w ratio
T1wDivT2w_NAME="T1wDividedByT2w.nii"
T1wDivT2w_PATH="${PARENTDIR}/${SUBJECTID}/T1w/T1wDividedByT2w.nii.gz"

# Set the name and location to your custom mask (if being used)
CUSTOM_MASK_PATH="${PARENTDIR}/${SUBJECTID}/T1w/Diffusion/nodif_brain_mask.nii.gz"
CUSTOM_MASK_NAME="nodif_brain_mask.nii.gz"

# Set the name and location of the MRtrix gradients file
#GRAD_NAME="dwscheme_corrected.txt"
#GRAD_PATH="${PARENTDIR}/1008.2.57.${SUBJECTID}/diffusion/dwscheme_orig.txt"

# Set to 1 if all parecalltion images are in the same folder. Set to 0 if parcellations are in different folders (each folder must be named after the parcellation)
USE_CUSTOM_PARC_LIST=1

# Set the location of the directory containing all the parcellation images (only if USE_CUSTOM_PARC_LIST=1)
PARCDIR="${PARENTDIR}/${SUBJECTID}/T1w/parc"

#PARC_LIST="HCPMMP1ANDfslatlas20_acpc HCPMMP1_acpc aparc+first_acpc aparc+aseg_acpc random200_acpc random500_acpc random500ANDfslatlas20_acpc random200ANDfslatlas20_acpc aparc_acpc"
PARC_LIST="Schaefer200_17net_acpc Schaefer400_17net_acpc Schaefer900_17net_acpc"

# NPASS: Set the number of passes to use when creating the single fibre
# mask (default is 1).
NPASS=6;

# SFTHRESHOLD: Set the FA threshold for the mask of high anisotropy voxels.
SFTHRESHOLD=0.6;

# DOWNSAMPLE: Chose to downsample the CSD image. Use when SIFTing a large number (50 million or over) of streamlines
# in order to save on running time and memory (RAM) usage. Set to 1 to downsample
DOWNSAMPLE=0; # 

# LMAXRESPONSE: Set the maximum harmonic order (lmax) for estimating the
# response function coefficient. This number should be chosen such that
# the number of distinct DW directions used in the acquisition is greater
# than the number of parameters that need to be estimated
# (see http://www.brain.org.au/software/mrtrix/tractography/preprocess.html#response).
# LMAXRESPONSE=8;
# LMAXCSD: Set the maximum harmonic order (lmax) for performing CSD or
# super-resolved CSD. A 60 direction data set will be analysed using
# straight CSD if csdeconv is performed with lmax=8 or lower, and
# super-resolved CSD if csdeconv is performed with lmax=10 or higher.
LMAXCSD=8;

# Set to one if using multishelled data and you want to run multishell CSD
MULTISHELL=1

# Set the number of streamlines to generate
NUM=10000000;

# SIFT_NUMBER: Set the number of tracks desired to SIFT down to if using SIFT1.
SIFT_NUMBER=500000;

# Set which diffusion-weighted gradient shells to extract. Must be in the format x,y,z i.e. 0,2000,3000
SHELL_EXTRACT="0,3000"

#Set to 1 to run iFOD2 (tractography)
iFOD2=1

#Set to 1 to run FACT (tractography)
FACT=1

# Set the type of brain mask. 1 is a mask generated by MRtrix3, 2 is a mask generated by bet and 3 is a custom mask already created
MASK_TYPE=3

# Set to 1 if you want to copy over the parcellations at the start of the pipeline
COPY_PARC=0

#GRAD_TYPE=1 for .nii dwi file with FSL bvec/bvals file, = 2 for .nii file with MRtrix3 dwscheme file and = 3 for .mif file
GRAD_TYPE=1

# Set HCP=1 if the data is HCP
HCP=1

# Set ACT=1 if you want to apply Anatomically Constrained Tractography, otherwise set to 0
ACT=1

# Set ACT_gen=1 if you want to generate the Anatomically Constrained Tractography image, otherwise set to 0. Highly recommend generating the ACT image outside of this script, has I have found that the generation of this image can be prone to failing
ACT_gen=0

# Set SIFT1=1 if you want to run SIFT1
SIFT1=0
# Set SIFT2=1 if you want to run SIFT2
SIFT2=1
# Set NOSIFT=1 if you want to run tractography without SIFT
NOSIFT=1

# Set the radius in mm that will affect streamline assignment (streamlines will be assigned to the closest ROI within that radius)
RADIAL_SEARCH=5

# Set to one to delete the tractography image after connectome generation
DELETE_TRACTOGRAPHY_IMAGE=0

# Set to 1 to delete everything but the connectomes
KEEP_ONLY_CONNECTOMES=0

#Set to 1 to check if everything was correctly generated
CHECK_COMPLETED=1


### Everything below this line contains the actual code to perform tractography and connectome generation: Enter at your own risk ###


## Load modules
module load mrtrix/0.3.15-gcc4
module load fsl/5.0.9
module load python/2.7.12-gcc4
module load matlab/r2016a

# FSL DIRECTORY
FSLDIR="/usr/local/fsl/5.0.9"

# MRTRIX DIRECTORY
MRTRIXDIR="/usr/local/mrtrix/0.3.15-gcc4"

# MRTRIX SCRIPTS DIRECTORY
MRTRIX_SCRIPTS_DIR="/usr/local/mrtrix/0.3.15-gcc4/scripts"

# MATLAB DIRECTORY
MATLABDIR="/usr/local/matlab/r2016a"

## Set environment variables
echo -e "\nSETTING ENVIRONMENT VARIABLES\n"

  expected_connectomes=$(echo $PARC_LIST | wc -w );

 if [ "${iFOD2}" = 1 ]; then
	if [ "${FACT}" = 1 ]; then
	expected_connectomes=$((expected_connectomes * 2));
	ALGOR_LIST="iFOD2 FACT";
	elif [ "${FACT}" = 0 ]; then
	ALGOR_LIST="iFOD2";
	fi
 elif [ "${iFOD2}" = 0 ]; then
	if [ "${FACT}" = 1 ]; then
	ALGOR_LIST="FACT";
	elif [ "${FACT}" = 0 ]; then
	echo -e "\nHAVE NOT SPECIFIED ANY TRACTOGRAPHY ALGORITHMS TO RUN/PRODUCE CONNECTOMES FOR. EXITING\n"; exit;
	fi
 fi

	SIFT_TYPES="";
 if [ "${SIFT2}" = 1 ]; then
	SIFT_TYPES="${SIFT_TYPES} SIFT2"
 fi
 if [ "${SIFT1}" = 1 ]; then
	SIFT_TYPES="${SIFT_TYPES} SIFT1"
 fi
 if [ "${NOSIFT}" = 1 ]; then
	SIFT_TYPES="${SIFT_TYPES} NOSIFT"
 fi


NUM_SIFT_TYPES=$(echo $SIFT_TYPES | wc -w );

expected_connectomes=$((expected_connectomes * $NUM_SIFT_TYPES));
echo -e "\nExpecting $expected_connectomes connectomes to be generated\n"

	if [ "${MASK_TYPE}" = 1 ]; then

			BRAIN_MASK=b0_mask.nii

	elif [ "${MASK_TYPE}" = 2 ]; then

			BRAIN_MASK=b0_bet_mask.nii.gz

	elif [ "${MASK_TYPE}" = 3 ]; then

		if [ -f "${CUSTOM_MASK_PATH}" ]; then

		echo -e "\n***CUSTOM MASK***\n"

			BRAIN_MASK=${CUSTOM_MASK_NAME}

		elif [ ! -f "${CUSTOM_MASK}" ]; then

			echo -e "No such file: ${CUSTOM_MASK_PATH}\n"
		fi
	fi

    ## Begin processing
    echo -e "\nPROCESSING SUBJECT ${SUBJECTID}\n"
    date

    Connectome_Out="${WORKDIR}/connectomes"

    ## PREPARATION
    ## Begin processing
    echo -e "\nPROCESSING SUBJECT ${SUBJECTID}\n"
    date

    ## PREPARATION
if [ "${RUN_PREPARATION}" = 1 ]; then

    echo -e "\n***PREPARATION***\n"
    # Purpose: Get a copy of this subject's HCP data.
    	if [ -d "${WORKDIR}" ]; then

        	echo -e "${WORKDIR} already exists. Removing."
        	rm -Rf ${WORKDIR}


        	mkdir ${WORKDIR}

    	elif [ ! -d "${WORKDIR}" ]; then

        	echo -e "No such directory: ${WORKDIR}\n"
        	mkdir ${WORKDIR}
	fi

	cd ${WORKDIR}

        cp -Rfv ${DIFFUSION_DATA_PATH} ${WORKDIR}/${DIFFUSION_IN_NAME}

	if [ "${GRAD_TYPE}" = 1 ]; then

		cp -Rfv ${BVALS_PATH} ${WORKDIR}/${BVALS_NAME}
		cp -Rfv ${BVECS_PATH} ${WORKDIR}/${BVECS_NAME}

	elif [ "${GRAD_TYPE}" = 2 ]; then

		cp -Rfv ${GRAD_PATH} ${WORKDIR}/${GRAD_NAME}

	fi

        cp -Rfv ${T1_PATH} ${WORKDIR}/${T1_NAME}

	if [ "${RUN_STAGE_TEN}" = 1 ]; then

	mrconvert -force ${T1wDivT2w_PATH} ${WORKDIR}/${T1wDivT2w_NAME}

	fi

	if [ "${ACT_gen}" = 0 ]; then

		cp -Rfv ${ACT_PATH} ${WORKDIR}/${ACT_NAME}

	else

	echo -e "ACT to be generated\n"

	fi

	if [ "${MASK_TYPE}" = 3 ]; then

		cp -Rfv ${CUSTOM_MASK_PATH} ${WORKDIR}/${CUSTOM_MASK_NAME}

	elif [ "${MASK_TYPE}" != 3 ]; then

		echo -e "Brain mask to be generated\n"

	fi

        cd ${WORKDIR}

        echo -e "\converting files...\n"


  elif [ "${RUN_PREPARATION}" != 1 ]; then

  echo -e "\n***SKIP PREPARATION***\n"
  date
  echo -e "\n***SKIP PREPARATION***\n"

  fi
 
    ## STAGE ONE
    # Purpose: Obtain DW-MRI files and images, generate masks
    if [ "${RUN_STAGE_ONE}" = 1 ]; then

    echo -e "\n***BEGIN STAGE ONE***\n"
    date
    echo -e "\n***BEGIN STAGE ONE***\n"


	if [ "${GRAD_TYPE}" = 1 ]; then

		if [ "${MULTISHELL}" = 1 ]; then


		# The "-datatype float32 -stride 0,0,0,1" is supposed to help make the data more accessible  when performing operations

			${MRTRIXDIR}/bin/mrconvert ${WORKDIR}/${DIFFUSION_IN_NAME} ${WORKDIR}/${DIFFUSION_DATA_NAME} -fslgrad ${WORKDIR}/${BVECS_NAME} ${WORKDIR}/${BVALS_NAME} -datatype float32 -stride 0,0,0,1

		elif [ "${MULTISHELL}" = 0 ]; then

			${MRTRIXDIR}/bin/dwiextract ${WORKDIR}/${DIFFUSION_IN_NAME} ${WORKDIR}/dwi_extracted.mif -fslgrad ${WORKDIR}/${BVECS_NAME} ${WORKDIR}/${BVALS_NAME} -shell ${SHELL_EXTRACT}
			${MRTRIXDIR}/bin/mrconvert ${WORKDIR}/dwi_extracted.mif ${WORKDIR}/${DIFFUSION_DATA_NAME} -datatype float32 -stride 0,0,0,1
		fi
		

		${MRTRIXDIR}/bin/dwiextract ${WORKDIR}/${DIFFUSION_DATA_NAME} -bzero -shell ${SHELL_EXTRACT} ${WORKDIR}/b0.nii

	elif [ "${GRAD_TYPE}" = 2 ]; then

		if [ "${MULTISHELL}" = 1 ]; then

			${MRTRIXDIR}/bin/dwiextract ${WORKDIR}/${DIFFUSION_IN_NAME} ${WORKDIR}/dwi_extracted.mif -grad ${WORKDIR}/${GRAD_NAME}

		elif [ "${MULTISHELL}" = 0 ]; then

			${MRTRIXDIR}/bin/dwiextract ${WORKDIR}/${DIFFUSION_IN_NAME} ${WORKDIR}/dwi_extracted.mif -grad ${WORKDIR}/${GRAD_NAME} -shell ${SHELL_EXTRACT}
		fi

		${MRTRIXDIR}/bin/mrconvert ${WORKDIR}/dwi_extracted.mif ${WORKDIR}/${DIFFUSION_DATA_NAME} -datatype float32 -stride 0,0,0,1

	# dwiextract then creates a b0 image
	${MRTRIXDIR}/bin/dwiextract ${WORKDIR}/${DIFFUSION_DATA_NAME} -bzero -shell ${SHELL_EXTRACT} ${WORKDIR}/b0.nii

	elif [ "${GRAD_TYPE}" = 3 ]; then

		${MRTRIXDIR}/bin/mrconvert ${WORKDIR}/${DIFFUSION_IN_NAME} ${WORKDIR}/${DIFFUSION_DATA_NAME} -datatype float32 -stride 0,0,0,1
		rm -rfv ${WORKDIR}/${DIFFUSION_IN_NAME}

	fi

	if [ "${MASK_TYPE}" = 1 ]; then

    		# convert diffusion-weighted images to mask
    		if [ -f "${WORKDIR}/${DIFFUSION_DATA_NAME}" ]; then

    			echo -e "\n***MRTRIX: GEN B0 MASK***\n"

        		${MRTRIXDIR}/bin/dwi2mask ${WORKDIR}/${DIFFUSION_DATA_NAME} ${WORKDIR}/b0_mask.nii
			BRAIN_MASK=b0_mask.nii

    		elif [ ! -f "${WORKDIR}/${DIFFUSION_DATA_NAME}" ]; then

        		echo -e "No such file: ${WORKDIR}/${DIFFUSION_DATA_NAME}\n"
        		echo -e "Cannot generate: ${WORKDIR}/b0_bet_mask.nii.gz\n";

    		fi

	elif [ "${MASK_TYPE}" = 2 ]; then

	echo -e "\n***BET: GEN B0 MASK***\n"

		bet ${WORKDIR}/b0.nii ${WORKDIR}/b0_bet.nii -m -f 0.2
		BRAIN_MASK=b0_bet_mask.nii.gz

	elif [ "${MASK_TYPE}" = 3 ]; then

		if [ -f "${CUSTOM_MASK_PATH}" ]; then

		echo -e "\n***CUSTOM MASK***\n"
			BRAIN_MASK=${CUSTOM_MASK_NAME}

		elif [ ! -f "${CUSTOM_MASK}" ]; then
			echo -e "No such file: ${CUSTOM_MASK_PATH}\n"
		fi
	fi


	${MRTRIXDIR}/bin/mrconvert ${WORKDIR}/${T1_NAME} ${WORKDIR}/T1.nii
    if [ "${ACT_gen}" = 1 ]; then
        echo -e "\n***MRTRIX: ACT***\n"
        # creates an ACT (Anatomically Constrained Tractography) image for using as a mask in tractography and SIFT.

		cd ${WORKDIR}

		rm -rfv ${WORKDIR}/ACT.nii

		cp -Rfv ${CUSTOM_MASK_PATH} ${WORKDIR}/${CUSTOM_MASK_NAME}

		export FSLSUB_LOCAL_RUN=YES

		${MRTRIX_SCRIPTS_DIR}/5ttgen -tempdir ${WORKDIR} fsl ${WORKDIR}/${ACT_T1_NAME} ${WORKDIR}/ACT.nii -premasked -nocrop

		mrconvert -force -coord 3 2 -axes 0,1,2 ${WORKDIR}/ACT.nii ${WORKDIR}/WM.nii
		mrconvert -force -coord 3 1 -axes 0,1,2 ${WORKDIR}/ACT.nii ${WORKDIR}/sub_GM.nii
		mrconvert -force -coord 3 0 -axes 0,1,2 ${WORKDIR}/ACT.nii ${WORKDIR}/cort_GM.nii

		mrcalc ${WORKDIR}/WM.nii ${WORKDIR}/sub_GM.nii -add ${WORKDIR}/cort_GM.nii -add 0 -gt ${WORKDIR}/GM_WM_mask.nii

    elif [ "${ACT_gen}" = 0 ]; then

    echo -e "\n***NOT GENERATING ACT IMAGE***\n"

    fi



    echo -e "\n***END STAGE ONE***\n"
    date
    echo -e "\n***END STAGE ONE***\n"

elif [ "${RUN_STAGE_ONE}" != 1 ]; then

    echo -e "\n***SKIP STAGE ONE***\n"
    date
    echo -e "\n***SKIP STAGE ONE***\n"

fi

    ## STAGE TWO
    # Purpose: Generates the response function

    if [ "${RUN_STAGE_TWO}" = 1 ]; then

    echo -e "\n***BEGIN STAGE TWO***\n"
    date
    echo -e "\n***BEGIN STAGE TWO***\n"

    echo -e "\n***REMOVING OUTPUTS***\n"

    # estimate the response function coefficient for use in spherical deconvolution
    # as part of updating to MRtrix3 the single fiber mask step has been removed, now the dwi2response incorporates this functionality
    # If the response function has been generated seperately (i.e. when doing testing) and you want to apply this script set SKIP to 1, otherwise set to 0

	SKIP=0;
	if [ "${SKIP}" = 1 ]; then
	   echo -e "\n***RESPONSE FUNCTION COEFFICIENT DONE SEPERATELY***\n"
	elif  [ "${SKIP}" = 0 ]; then

	rm -fv ${WORKDIR}/response*
	rm -fv ${WORKDIR}/sf*

	    if [ "${MULTISHELL}" = 1 ]; then
		echo -e "\n***MRTRIX: ESTIMATE MULTISHELL RESPONSE FUNCTION COEFFICIENT***\n"

		${MRTRIX_SCRIPTS_DIR}/dwi2response -tempdir ${WORKDIR} msmt_5tt ${WORKDIR}/${DIFFUSION_DATA_NAME} ${WORKDIR}/ACT.nii ${WORKDIR}/RF_WM.txt ${WORKDIR}/RF_GM.txt ${WORKDIR}/RF_CSF.txt -voxels ${WORKDIR}/RF_voxels.mif

	    elif [ "${MULTISHELL}" = 0 ]; then 

		 echo -e "\n***MRTRIX: ESTIMATE RESPONSE FUNCTION COEFFICIENT***\n"

		if [ -f "${WORKDIR}/${DIFFUSION_DATA_NAME}" ]; then

				${MRTRIX_SCRIPTS_DIR}/dwi2response -tempdir ${WORKDIR} tax ${WORKDIR}/${DIFFUSION_DATA_NAME} ${WORKDIR}/response.txt -voxels ${WORKDIR}/RF_voxels.mif
				#${MRTRIX_SCRIPTS_DIR}/dwi2response -tempdir ${WORKDIR} tax ${WORKDIR}/${DIFFUSION_DATA_NAME} ${WORKDIR}/response_masked.txt -mask ${BRAIN_MASK} -voxels ${WORKDIR}/RF_voxels_masked.mif

			    echo -e "To display the response function, use the disp_profile command:\n${MRTRIXDIR}/bin/disp_profile -response ${WORKDIR}/response.txt\n"

		elif [ ! -f "${WORKDIR}/${DIFFUSION_DATA_NAME}" ]; then

			echo -e "No such file: ${WORKDIR}/${DIFFUSION_DATA_NAME}\n"
			echo -e "Cannot generate: ${WORKDIR}/response.txt\n";
	    	fi
	    fi
	fi
	date


    echo -e "\n***END STAGE TWO***\n"
    date
    echo -e "\n***END STAGE TWO***\n"

    elif [ "${RUN_STAGE_TWO}" != 1 ]; then

    echo -e "\n***SKIP STAGE TWO***\n"
    date
    echo -e "\n***SKIP STAGE TWO***\n"

    fi

    if [ "${RUN_STAGE_THREE}" = 1 ]; then

    echo -e "\n***BEGIN STAGE THREE***\n"
    date
    echo -e "\n***BEGIN STAGE THREE***\n"

	${MRTRIXDIR}/bin/dwi2tensor -mask ${WORKDIR}/${BRAIN_MASK} ${WORKDIR}/${DIFFUSION_DATA_NAME} ${WORKDIR}/DT.mif
	${MRTRIXDIR}/bin/tensor2metric -mask ${WORKDIR}/${BRAIN_MASK} -vector ${WORKDIR}/directions.mif ${WORKDIR}/DT.mif
	${MRTRIXDIR}/bin/tensor2metric -mask ${WORKDIR}/${BRAIN_MASK} -fa ${WORKDIR}/FA.mif ${WORKDIR}/DT.mif
	${MRTRIXDIR}/bin/tensor2metric -mask ${WORKDIR}/${BRAIN_MASK} -adc ${WORKDIR}/MD.mif ${WORKDIR}/DT.mif
	${MRTRIXDIR}/bin/tensor2metric -mask ${WORKDIR}/${BRAIN_MASK} -ad ${WORKDIR}/AD.mif ${WORKDIR}/DT.mif
	${MRTRIXDIR}/bin/tensor2metric -mask ${WORKDIR}/${BRAIN_MASK} -rd ${WORKDIR}/RD.mif ${WORKDIR}/DT.mif

    echo -e "\n***MRTRIX: NON-NEGATIVITY CSD***\n"

	    echo -e "\n${MULTISHELL}\n"

    # perform non-negativity constrained spherical deconvolution (makes FODs)
	if [ "${MULTISHELL}" = 1 ]; then

	 echo -e "\n***MRTRIX: USING MULTISHELL***\n"

		 if [ -f "${WORKDIR}/${DIFFUSION_DATA_NAME}" ]; then

			    if [ -f "${WORKDIR}/${BRAIN_MASK}" ]; then

				${MRTRIXDIR}/bin/dwi2fod msmt_csd ${WORKDIR}/${DIFFUSION_DATA_NAME} ${WORKDIR}/RF_WM.txt ${WORKDIR}/FOD.mif ${WORKDIR}/RF_GM.txt ${WORKDIR}/GM.mif ${WORKDIR}/RF_CSF.txt ${WORKDIR}/csf.mif -mask ${WORKDIR}/${BRAIN_MASK}
				echo -e "\nNote. The csdeconv command is capable of running in multi-threaded mode.\nTo use this feature, set the NumberOfThreads parameter in the MRtrix configuration file.\nSee http://www.brain.org.au/software/mrtrix/appendix/config.html\n"

			    elif [ ! -f "${WORKDIR}/${BRAIN_MASK}" ]; then

				echo -e "No such file: ${WORKDIR}/${BRAIN_MASK}\n"
				echo -e "Cannot generate: ${WORKDIR}/FOD.mif\n";

			    fi
		  elif [ ! -f "${WORKDIR}/${DIFFUSION_DATA_NAME}" ]; then

			echo -e "No such file: ${WORKDIR}/${DIFFUSION_DATA_NAME}\n"
			echo -e "Cannot generate: ${WORKDIR}/FOD.mif\n";

		  fi
	elif [ "${MULTISHELL}" = 0 ]; then

		    	echo -e "\n***MRTRIX: NOT USING MULTISHELL***\n"

		    if [ -f "${WORKDIR}/${DIFFUSION_DATA_NAME}" ]; then

			if [ -f "${WORKDIR}/response.txt" ]; then

			    if [ -f "${WORKDIR}/${BRAIN_MASK}" ]; then

				${MRTRIXDIR}/bin/dwi2fod csd ${WORKDIR}/${DIFFUSION_DATA_NAME} ${WORKDIR}/response.txt ${WORKDIR}/FOD.mif -mask ${WORKDIR}/${BRAIN_MASK}
				echo -e "\nNote. The csdeconv command is capable of running in multi-threaded mode.\nTo use this feature, set the NumberOfThreads parameter in the MRtrix configuration file.\nSee http://www.brain.org.au/software/mrtrix/appendix/config.html\n"

			    elif [ ! -f "${WORKDIR}/${BRAIN_MASK}" ]; then

				echo -e "No such file: ${WORKDIR}/${BRAIN_MASK}\n"
				echo -e "Cannot generate: ${WORKDIR}/FOD.mif\n";

			    fi

			elif [ ! -f "${WORKDIR}/response.txt" ]; then

			    echo -e "No such file: ${WORKDIR}/response.txt\n"
			    echo -e "Cannot generate: ${WORKDIR}/FOD.mif\n";

			fi

		    elif [ ! -f "${WORKDIR}/${DIFFUSION_DATA_NAME}" ]; then

			echo -e "No such file: ${WORKDIR}/${DIFFUSION_DATA_NAME}\n"
			echo -e "Cannot generate: ${WORKDIR}/FOD.mif\n";

		    fi
		
	fi

   date

    echo -e "\n***END STAGE THREE***\n"
    date
    echo -e "\n***END STAGE THREE***\n"

    elif [ "${RUN_STAGE_THREE}" != 1 ]; then

	    echo -e "\n***SKIP STAGE THREE***\n"
	    date
	    echo -e "\n***SKIP STAGE THREE***\n"

    fi

    if [ "${RUN_STAGE_FOUR}" = 1 ]; then

	    echo -e "\n***BEGIN STAGE FOUR***\n"
	    date
	    echo -e "\n***BEGIN STAGE FOUR***\n"

	    echo -e "\n***REMOVING OUTPUTS***\n"

	if [ "${iFOD2}" = 1 ] ; then

		rm -rv ${WORKDIR}/streamlines_iFOD2.tck  
	    	echo -e "\n***MRTRIX: iFOD2***\n"
	    # perform streamlines tracking using iFOD2. See MRtrix documentation for details of augmentations but in short uses seed dynamic for seeding, backtrack means bad streamlines are redone and crop at gmwmi crops the steamline endpoints more precisely as they cross the gm-wm interface. Backtrack and crop_at_gmwmi are designed for use with ACT

	    if [ -f "${WORKDIR}/FOD.mif" ]; then

		    if [ -f "${WORKDIR}/${BRAIN_MASK}" ]; then

		        if [ "${ACT}" = 0 ]; then

		# This script was mostly designed around using ACT, if not using ACT a more appropriate brain mask will be needed here

		${MRTRIXDIR}/bin/tckgen -seed_dynamic ${WORKDIR}/FOD.mif -mask ${WORKDIR}/${BRAIN_MASK}.nii -maxlength 250 -number ${NUM} -algorithm iFOD2 ${WORKDIR}/FOD.mif ${WORKDIR}/streamlines_iFOD2.tck  
		   
		        elif [ "${ACT}" = 1 ]; then

		${MRTRIXDIR}/bin/tckgen -crop_at_gmwmi -backtrack -seed_dynamic ${WORKDIR}/FOD.mif -act ${WORKDIR}/ACT.nii -maxlength 250 -number ${NUM} -algorithm iFOD2 ${WORKDIR}/FOD.mif ${WORKDIR}/streamlines_iFOD2.tck 
		#${MRTRIXDIR}/bin/tckgen -crop_at_gmwmi -backtrack -seed_grid_per_voxel ${WORKDIR}/WM.nii 2 -act ${WORKDIR}/ACT.nii -maxlength 250 -number ${NUM} -algorithm iFOD2 ${WORKDIR}/FOD.mif ${WORKDIR}/streamlines_iFOD2.tck 

		        fi 
           
		    elif [ ! -f "${WORKDIR}/${BRAIN_MASK}" ]; then

		        echo -e "No such file: ${WORKDIR}/${BRAIN_MASK}\n"
		        echo -e "Cannot generate: ${WORKDIR}/streamlines.tck\n";

		    fi
	    elif [ ! -f "${WORKDIR}/FOD.mif" ]; then

		echo -e "No such file: ${WORKDIR}/FOD.mif\n"
		echo -e "Cannot generate: ${WORKDIR}/streamlines.tck\n";

	    fi

	elif [ "${iFOD2}" = 0 ] ; then

	    echo -e "\n***NOT RUNNING iFOD2***\n"
	fi

date

if [ "${FACT}" = 1 ]; then

rm -rv ${WORKDIR}/streamlines_FACT.tck 

        echo -e "\n***MRTRIX: FIBRE ASSIGNMENT BY CONTINUOUS TRACKING***\n"

    # perform streamlines tracking using FACT. See MRtrix documentation for details of augmentations. Will terminate when FA is below .2 or the curvature is greater than 45 degrees

	if [ -f "${WORKDIR}/FOD.mif" ]; then

            if [ -f "${WORKDIR}/${BRAIN_MASK}" ]; then

                if [ "${ACT}" = 0 ]; then

			${MRTRIXDIR}/bin/tckgen -seed_dynamic ${WORKDIR}/FOD.mif -angle 45 -mask ${WORKDIR}/${BRAIN_MASK}.nii -maxlength 250 -number ${NUM} -algorithm FACT -downsample 5 ${WORKDIR}/directions.mif ${WORKDIR}/streamlines_FACT.tck   
          
                elif [ "${ACT}" = 1 ]; then

			${MRTRIXDIR}/bin/tckgen -crop_at_gmwmi -seed_dynamic ${WORKDIR}/FOD.mif -angle 45 -act ${WORKDIR}/ACT.nii -mask ${WORKDIR}/${BRAIN_MASK} -maxlength 250 -number ${NUM} -algorithm FACT -downsample 5 ${WORKDIR}/directions.mif ${WORKDIR}/streamlines_FACT.tck 

#${MRTRIXDIR}/bin/tckgen -crop_at_gmwmi -seed_grid_per_voxel ${WORKDIR}/WM.nii 2 -angle 45 -act ${WORKDIR}/ACT.nii -mask ${WORKDIR}/${BRAIN_MASK} -maxlength 250 -number ${NUM} -algorithm FACT -downsample 5 ${WORKDIR}/directions.mif ${WORKDIR}/streamlines_FACT.tck 

                fi 
           
            elif [ ! -f "${WORKDIR}/${BRAIN_MASK}" ]; then

                echo -e "No such file: ${WORKDIR}/${BRAIN_MASK}\n"
                echo -e "Cannot generate: ${WORKDIR}/streamlines_FACT.tck\n";

            fi

    	elif [ ! -f "${WORKDIR}/FOD.mif" ]; then

        echo -e "No such file: ${WORKDIR}/FOD.mif\n"
        echo -e "Cannot generate: ${WORKDIR}/streamlines_FACT.tck\n";

    	fi

elif [ "${FACT}" = 0 ]; then

    echo -e "\n***NOT RUNNING FACT***\n"

fi

    echo -e "\n***END STAGE FOUR***\n"
    date
    echo -e "\n***END STAGE FOUR***\n"

    elif [ "${RUN_STAGE_FOUR}" != 1 ]; then

    echo -e "\n***SKIP STAGE FOUR***\n"
    date
    echo -e "\n***SKIP STAGE FOUR***\n"

    fi

    ## STAGE FIVE
    # Purpose: To apply SIFT to the streamlines

    if [ "${RUN_STAGE_FIVE}" = 1 ]; then

    echo -e "\n***BEGIN STAGE FIVE***\n"
    date
    echo -e "\n***BEGIN STAGE FIVE***\n"

	# This downsamples the image by half in order to save on memory (if the option is selected).

if [ "${DOWNSAMPLE}" = 1 ]; then
	echo -e "DOWNSAMPLING CSD IMAGE\n"
	${MRTRIXDIR}/bin/mrresize ${WORKDIR}/FOD.mif ${WORKDIR}/FOD_down.mif -scale 0.5 -interp sinc

	CSD_DATA="FOD_down.mif"

elif [ "${DOWNSAMPLE}" != 1 ]; then
	echo -e "NOT DOWNSAMPLING CSD IMAGE\n";

	CSD_DATA="FOD.mif"

fi


if [ "${ACT}" = 1 ]; then

	ACT_ARG="-act ${WORKDIR}/ACT.nii"

else

	ACT_ARG=""

fi

for ALGOR_TYPE in ${ALGOR_LIST}; do

    if [ "${SIFT1}" = 1 ]; then

    	${MRTRIXDIR}/bin/tcksift -force -csv ${WORKDIR}/SIFT_data_${ALGOR_TYPE}.csv ${ACT_ARG} -term_number ${SIFT_NUMBER} ${WORKDIR}/streamlines_${ALGOR_TYPE}.tck ${WORKDIR}/${CSD_DATA} ${WORKDIR}/SIFT_streamlines_${ALGOR_TYPE}.tck;

    fi

    if [ "${SIFT2}" = 1 ]; then

    	${MRTRIXDIR}/bin/tcksift2 -force -csv ${WORKDIR}/SIFT_data_${ALGOR_TYPE}.csv ${ACT_ARG} ${WORKDIR}/streamlines_${ALGOR_TYPE}.tck ${WORKDIR}/${CSD_DATA} ${WORKDIR}/SIFT2_weights_${ALGOR_TYPE}.txt; 

    fi

	done

done

    echo -e "\n***END STAGE FIVE***\n"
    date
    echo -e "\n***END STAGE FIVE***\n"

    elif [ "${RUN_STAGE_FIVE}" != 1 ]; then

    echo -e "\n***SKIP STAGE FIVE***\n"
    date
    echo -e "\n***SKIP STAGE FIVE***\n"

    fi


	if [ "${RUN_STAGE_SIX}" = 1 ]; then

	if [ "${USE_CUSTOM_PARC_LIST}" = 1 ]; then

	for PARC_TYPE in ${PARC_LIST}; do
		if [ "${COPY_PARC}" = 1 ]; then
			cp -Rfv ${PARCDIR}/${PARC_TYPE}.nii ${WORKDIR}/${PARC_TYPE}.nii
			PARCLOCATION=${WORKDIR}
		elif [ "${COPY_PARC}" = 0 ]; then
			PARCLOCATION=${PARCDIR}
		fi 
	done

	elif [ "${USE_CUSTOM_PARC_LIST}" = 0 ]; then	

	for PARC_TYPE in ${PARC_LIST}; do
		cp -Rfv ${PARENTDIR}/${SUBJECTID}/${PARC_TYPE}/${PARC_TYPE}.nii ${WORKDIR}/${PARC_TYPE}.nii
	done

	

	fi

    elif [ "${RUN_STAGE_SIX}" != 1 ]; then

    echo -e "\n***SKIP STAGE SIX***\n"
    date
    echo -e "\n***SKIP STAGE SIX***\n"

    fi
    ## STAGE SEVEN
    # Purpose: Generates connectomes

    if [ "${RUN_STAGE_SEVEN}" = 1 ]; then

    echo -e "\n***BEGIN STAGE SEVEN***\n"
    date
    echo -e "\n***BEGIN STAGE SEVEN***\n"

    echo -e "\n***REMOVING OUTPUTS***\n"

    
	date

   if [ -d "${WORKDIR}/connectomes" ]; then

   	echo -e "connectomes directory exists..\n"

   elif [ ! -d "${WORKDIR}/connectomes" ]; then

   	mkdir ${WORKDIR}/connectomes

   fi

    cd ${WORKDIR} 

cd ${Connectome_Out}

for ALGOR_TYPE in ${ALGOR_LIST}; do

	for SIFT_TYPE in ${SIFT_TYPES}; do

		if [ "${SIFT_TYPE}" =  "SIFT2" ]

			TCK_WEIGHTS="-tck_weights_in ${WORKDIR}/SIFT2_weights_${ALGOR_TYPE}.txt"
			TRACOGRAM="streamlines_${ALGOR_TYPE}.tck"

		elif [ "${SIFT_TYPE}" =  "NOSIFT" ]

			TCK_WEIGHTS=""
			TRACOGRAM="streamlines_${ALGOR_TYPE}.tck"

		elif [ "${SIFT_TYPE}" =  "SIFT1" ]

			TCK_WEIGHTS=""
			TRACOGRAM="SIFT_streamlines_${ALGOR_TYPE}.tck"
		fi

			for PARC_TYPE in ${PARC_LIST}; do
				# Loops over the different parcellation types	

				PARC_NAME="${PARC_TYPE}"

				if [ "${COPY_PARC}" = 1 ]; then
					PARCLOCATION=${WORKDIR}
				elif [ "${COPY_PARC}" = 0 ]; then
					PARCLOCATION=${PARCDIR}
				fi 

				CONN_PARC="${PARCLOCATION}/${PARC_TYPE}.nii"

				date
				echo -e "\nMaking ${ALGOR_TYPE} ${PARC_NAME} connectome\n"
		   		${MRTRIXDIR}/bin/tck2connectome -force -zero_diagonal -assignment_radial_search ${RADIAL_SEARCH} ${TCK_WEIGHTS} ${WORKDIR}/${TRACOGRAM} ${CONN_PARC} ${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}.csv

				date

				echo -e "\nMaking ${ALGOR_TYPE} ${PARC_NAME} connectome for lengths\n"
				${MRTRIXDIR}/bin/tck2connectome -force -zero_diagonal -scale_length -stat_edge mean -assignment_radial_search ${RADIAL_SEARCH} ${TCK_WEIGHTS} ${WORKDIR}/${TRACOGRAM} ${CONN_PARC} ${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_length.csv

				date

				echo "${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}.csv ${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}.mat"

				${MATLABDIR}/bin/matlab -nodisplay -nosplash -r "WheresMyScript='${WHERESMYSCRIPT}/Functions'; addpath(genpath(WheresMyScript)); csv_to_mat('${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}.csv','${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}.mat'); exit"

				${MATLABDIR}/bin/matlab -nodisplay -nosplash -r "WheresMyScript='${WHERESMYSCRIPT}/Functions'; addpath(genpath(WheresMyScript)); csv_to_mat('${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_length.csv','${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_length.mat'); exit"

				for METRIC in FA MD RD AD; do

					echo -e "\nMaking ${ALGOR_TYPE} ${PARC_NAME} ${METRIC} connectome\n"

					${MRTRIXDIR}/bin/tcksample -force ${WORKDIR}/streamlines_${ALGOR_TYPE}.tck ${WORKDIR}/${METRIC}.mif ${WORKDIR}/${METRIC}_mean.csv -stat_tck mean

					${MRTRIXDIR}/bin/tck2connectome -force -zero_diagonal -scale_file ${WORKDIR}/${METRIC}_mean.csv -stat_edge mean -assignment_radial_search ${RADIAL_SEARCH} ${TCK_WEIGHTS} ${WORKDIR}/${TRACOGRAM} ${CONN_PARC} ${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_${METRIC}.csv


					echo -e "\n***Converting from CSV to MAT***\n"

					${MATLABDIR}/bin/matlab -nodisplay -nosplash -r "WheresMyScript='${WHERESMYSCRIPT}/Functions'; addpath(genpath(WheresMyScript)); csv_to_mat('${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_${METRIC}.csv','${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_${METRIC}.mat'); exit"

				done

			date

			done

		done

	done

done

    echo -e "\n***END STAGE SEVEN***\n"
    date
    echo -e "\n***END STAGE SEVEN***\n"

    elif [ "${RUN_STAGE_SEVEN}" != 1 ]; then

    echo -e "\n***SKIP STAGE SEVEN***\n"
    date
    echo -e "\n***SKIP STAGE SEVEN***\n"

    fi

    ## STAGE EIGHT
    # Purpose: Converts connectomes to density values (streamline count of two connecting nodes divided by the summed volume of the two nodes)

    if [ "${RUN_STAGE_EIGHT}" = 1 ]; then

    echo -e "\n***RUNNING STAGE EIGHT***\n"
    date
    echo -e "\n***RUNNING STAGE EIGHT***\n"

	cd ${Connectome_Out}

	for ALGOR_TYPE in ${ALGOR_LIST};do

		for PARC_TYPE in ${PARC_LIST}; do

			for SIFT_TYPE in ${SIFT_TYPES}; do

				VarName="adj"
				echo -e "\n***DEFINING VARIABLES***\n"
					PARC_NAME="${PARC_TYPE}"
					CONN_PARC="${PARCLOCATION}/${PARC_TYPE}.nii"
					CountMatInName="${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}.mat"
					VolMatOutName="${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_volume.mat"
					DensityMatOutName="${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_density.mat"
					ParcInPath="${CONN_PARC}"
				echo -e "${CountMatInName} ${VarName} ${ParcInPath} ${VolMatOutName} ${DensityMatOutName}"

				echo -e "\n***BUILDING VOLUME AND DENSITY MATRICES***\n"
				${MATLABDIR}/bin/matlab -nodisplay -nosplash -r "WheresMyScript='${WHERESMYSCRIPT}/Functions'; addpath(genpath(WheresMyScript)); BuildVolumeAndDensityMats(${SUBJECTID},'${Connectome_Out}','${CountMatInName}','${VarName}','${ParcInPath}','${VolMatOutName}','${DensityMatOutName}',${HCP}); exit"

			done
		done
	done

    elif [ "${RUN_STAGE_EIGHT}" != 1 ]; then

    echo -e "\n***SKIP STAGE EIGHT***\n"
    date
    echo -e "\n***SKIP STAGE EIGHT***\n"

    fi

    ## STAGE NINE
    # Purpose: Find the coordinates of each node
	
    if [ "${RUN_STAGE_NINE}" = 1 ]; then
	cd ${Connectome_Out}
    echo -e "\n***RUNNING STAGE NINE***\n"
    date
    echo -e "\n***RUNNING STAGE NINE***\n"
		for PARC_TYPE in ${PARC_LIST}; do
		echo -e "\n***DEFINING VARIABLES***\n"
				PARC_NAME="${PARC_TYPE}"
				CONN_PARC="${PARCLOCATION}/${PARC_TYPE}.nii"
				ParcInPath="${CONN_PARC}"
		VOXDIM=($(mrinfo -vox ${ParcInPath}))
		echo -e "\n***FINDING ${PARC_NAME} NODE COORDINATES**\n"
		#${MATLABDIR}/bin/matlab -nodisplay -nosplash -r "WheresMyScript='${WHERESMYSCRIPT}/Functions'; addpath(genpath(WheresMyScript)); getCOG('${ParcInPath}',${VOXDIM},0,'COG_${PARC_TYPE}_${SUBJECTID}.txt',${HCP}); exit"
		${MATLABDIR}/bin/matlab -nodisplay -nosplash -r "WheresMyScript='${WHERESMYSCRIPT}/Functions'; addpath(genpath(WheresMyScript)); getCOG('${ParcInPath}',${VOXDIM},1,'${WORKDIR}/COG_${PARC_NAME}_${SUBJECTID}.txt',${HCP}); exit"
		done

    elif [ "${RUN_STAGE_NINE}" != 1 ]; then

    echo -e "\n***SKIP STAGE NINE***\n"
    date
    echo -e "\n***SKIP STAGE NINE***\n"

    fi

    ## STAGE TEN
    # Purpose: Find the average T1w/T2w value for each ROI in each parcellation
	
    if [ "${RUN_STAGE_TEN}" = 1 ]; then
	cd ${Connectome_Out}
    echo -e "\n***RUNNING STAGE TEN***\n"
    date
    echo -e "\n***RUNNING STAGE TEN***\n"

		mrconvert ${PARENTDIR}/${SUBJECTID}/T1w/T1w_acpc_dc_restore.nii.gz ${WORKDIR}/T1w_acpc_dc_restore.nii -stride -1,2,3
		mrconvert ${PARENTDIR}/${SUBJECTID}/T1w/T2w_acpc_dc_restore.nii.gz ${WORKDIR}/T2w_acpc_dc_restore.nii -stride -1,2,3
		for PARC_TYPE in ${PARC_LIST}; do
		echo -e "\n***DEFINING VARIABLES***\n"
				PARC_NAME="${PARC_TYPE}"
				CONN_PARC="${PARCLOCATION}/${PARC_TYPE}.nii"
		
		echo -e "\n***FINDING ${PARC_NAME} T1w/T2w average values**\n"
		ParcInPath="${CONN_PARC}"

		${MATLABDIR}/bin/matlab -nodisplay -nosplash -r "WheresMyScript='${WHERESMYSCRIPT}/Functions'; addpath(genpath(WheresMyScript)); T1T2_roi_average('${ParcInPath}','${WORKDIR}/T1w_acpc_dc_restore.nii','${WORKDIR}/T2w_acpc_dc_restore.nii','${WORKDIR}/${PARC_NAME}_T1wANDT2w_roi_average'); exit"
		done

    elif [ "${RUN_STAGE_TEN}" != 1 ]; then

    echo -e "\n***SKIP STAGE TEN***\n"
    date
    echo -e "\n***SKIP STAGE TEN***\n"

    fi

SUCCESSFUL=0

	if [ "${RUN_STAGE_EIGHT}" = 1 ]; then
		if [ ${CHECK_COMPLETED} = 1 ]; then
			echo -e "\n***CHECKING ALL DESIRED CONNECTOMES ARE GENERATED***\n"
		fi
	elif [ "${RUN_STAGE_EIGHT}" != 1 ]; then
		if [ "${RUN_STAGE_SEVEN}" = 1 ]; then
			if [ ${CHECK_COMPLETED} = 1 ]; then
				echo -e "\n***CHECKING ALL DESIRED CONNECTOMES ARE GENERATED***\n"
			fi
		elif [ "${RUN_STAGE_SEVEN}" != 1 ]; then
			echo -e "\n***NO CONNECTOME GENERATION STEP RUN. CHECKING IF TRACTOGRAMS ARE COMPLETED***\n"
			CHECK_COMPLETED=0
			missing=0
				for ALGOR_TYPE in ${ALGOR_LIST}; do
					if  [ -f "${WORKDIR}/streamlines_${ALGOR_TYPE}.tck" ]; then
						echo -e "streamlines_${ALGOR_TYPE}.tck found!\n"
					elif [ ! -f "${WORKDIR}/streamlines_${ALGOR_TYPE}.tck" ]; then
						echo -e "streamlines_${ALGOR_TYPE}.tck is missing!\n"
						missing=$((var+1))
					fi
				done
			if [ ${missing} = 0 ]; then
				echo -e "\n***SUCCESSFULLY COMPLETED***\n"
			SUCCESSFUL=1
			elif [ ${missing} -ne 0 ]; then
				echo -e "\n***NOT SUCCESSFULLY COMPLETED***\n"
			fi
		fi
	fi

if [ ${CHECK_COMPLETED} = 1 ]; then
	var=0
	for ALGOR_TYPE in ${ALGOR_LIST}; do
		for PARC_NAME in ${PARC_LIST}; do
			for SIFT_TYPE in ${SIFT_TYPES}; do
				if [ "${RUN_STAGE_EIGHT}" = 1 ]; then
					if [ -f "${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_density.mat" ]; then
					#echo $var
					# This increases var by 1
				 	var=$((var+1))
					#echo $var
					elif [ ! -f "${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_density.mat" ]; then
					echo -e "${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_density.mat is missing!\n"	
					fi
				elif [ "${RUN_STAGE_EIGHT}" != 1 ]; then

					if [ "${RUN_STAGE_SEVEN}" = 1 ]; then

						if [ -f "${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}.mat" ]; then
						#echo $var
						# This increases var by 1
					 	var=$((var+1))
						#echo $var
						elif [ ! -f "${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}.mat" ]; then

						echo -e "${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}.mat is missing!\n"
	
						fi
					fi
				fi
			done		 
		done
	done

	echo -e "$var connectomes made; $expected_connectomes connectomes expected\n"

		if [ "$var" -eq "$expected_connectomes" ]; then	

	    echo -e "\n"
	    date

	    echo -e "\n***SUCCESSFULLY COMPLETED***\n"

		SUCCESSFUL=1

		if [ ${KEEP_ONLY_CONNECTOMES} = 1 ]; then

		cd ${WORKDIR}

		elif [ ${KEEP_ONLY_CONNECTOMES} = 0 ]; then
			if [ "${DELETE_TRACTOGRAPHY_IMAGE}" = 1 ]; then
			echo -e "DELETING TRACTOGRAPHY IMAGES TO SAVE SPACE\n"
			rm -fv ${WORKDIR}/streamlines_FACT.tck
			rm -fv ${WORKDIR}/streamlines_iFOD2.tck
			fi
		fi
	    date
		elif  [ "$var" -ne "$expected_connectomes" ]; then
	    echo -e "\n"
	    date
	    echo -e "\n***NEEDS REDOING/CHECKING***\n"
	    date
		fi
	fi
else
	date
	echo -e "\n***NOT CHECKING IF CONNECTOMES WERE GENERATED***\n"
	date

fi

echo -e "\n***DONE***\n"
