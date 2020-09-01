#!/bin/bash

module load gnuparallel/20190122
module load mrtrix/0.3.16

TARGETDIR="path_to_desired_directory_on_project_scratch"

export HCP=/scratch/hcp1200/

export TARGETDIR

mkdir -p $TARGETDIR

function extractFile()
{
   TD=$(mktemp -d) || exit 1
   trap 'rm -rf ${TD}' RETURN

   ID=$(basename $1)
   IDP=${TD}/${ID}
   echo $ID
   trap 'rm -rf ${IDP}' RETURN

   ZIP1=${1}/preproc/${ID}_3T_Structural_preproc.zip
   ZIP2=${1}/preproc/${ID}_3T_Structural_preproc_extended.zip
   ZIP3=${1}/preproc/${ID}_3T_Diffusion_preproc.zip
   unzip $ZIP1 -d ${TD}
   unzip $ZIP2 -d ${TD}
   unzip $ZIP3 -d ${TD}

   RB= ${IDP}/T1w/ribbon.nii.gz

   mrconvert ${IDP}/T1w/ribbon.nii.gz ${TARGETDIR}/${ID}_ribbon_expanded.nii -stride -1,2,3
   rm -rf ${TD}
}

export -f extractFile

parallel extractFile {} ::: ${HCP}/[1-9]*



