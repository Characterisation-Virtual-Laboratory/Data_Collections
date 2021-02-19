#!/bin/bash
# 2021-01-07

# Check the "exception_log.txt" file content which is the output of script "hcp1200_data_update_20200107_part1.sh". This file contains the list of data that are newly added to hcp1200, 2018 data release. 
# Following is a script to move those data to the correct subjects' sub-directory: 
# (NOTE: files end with fix.zip must go to the sub-directory of "fix/" and those files end with fixextended.zip must go the subject's subdirectory of "fixextended/")

# *7T*RET_*fix.zip and *7T*RET_*fixextended.zip data are additional data in release 2018:
#   *7T_RET_1.6mm_fix.zip
#   *7T_RET_2mm_fix.zip
#   *7T_RET_fixextended.zip

# Some other newly added data for some of the subjects are:
# *7T_MOVIE_fixextended.zip
# *7T_REST_fixextended.zip

UPDATEDIR=/fs03/hcp1200_20201208
OLDDIR=/scratch/hcp1200
# a variable for a path to where Lance downloaded data
DLDIR=/fs03/hcp1200_updated_data
TXTFILEPATH=/home/fsad0002/hcp1200_data_update


# Check the exception_log.txt for the list of files that are newly added hcp1200, 2018 data release. Following is a script to move those files to the correct subject’s directory: 
# (NOTE: files end with fix.zip must go to the sub-directory of "fix/" and those files end with fixextended.zip must go the subject's subdirectory of "fixextended/")

cat $TXTFILEPATH/exception_log.txt | while read j; 
do  echo "____________________________";
    echo ${j:1:6} ; 
    TMP=$(echo ${j:1} | cut -d' ' -f1) ;
    echo $TMP;
    if [[ $TMP =~ "fix.zip" ]]; then  echo "*fix.zip*" 
        cp $DLDIR/${TMP}  $UPDATEDIR/${j:1:6}/fix/;
    elif [[ $TMP =~ "fixextended.zip" ]]; then  echo "*fixextended.zip*" 
        cp $DLDIR/${TMP}  $UPDATEDIR/${j:1:6}/fixextended/;
    else echo “${TMP} doesn’t fit into fix or fixextended directories” >> $TXTFILEPATH/exception_log_newlyadded.txt ; 
    fi ;
done
