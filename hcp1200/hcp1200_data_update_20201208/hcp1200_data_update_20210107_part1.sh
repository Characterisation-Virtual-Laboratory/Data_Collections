#!/bin/bash
# 2021-01-07

# Update HCP1200 data from release 2017 to release 2018; which has resolved 7T fMRI data issue

# Logic for data movement from a directory with recently downloaded HCP1200; 7T data to current /scratch/hcp1200/ directory:

# make a symbolic link to the original directory (current version):

UPDATEDIR=/fs03/hcp1200_20201208
OLDDIR=/scratch/hcp1200
# a variable for a path to where Lance downloaded data
DLDIR=/fs03/hcp1200_updated_data
PREFIX="/old_"
TXTFILEPATH=/home/fsad0002/hcp1200_data_update

#mkdir $UPDATEDIR
#lndir $OLDDIR $UPDATEDIR
#ls -l $UPDATEDIR

# ${file:0:6} gives the subjects ID which is a directory name in hcp1200 dataset.
#cd /home/fsad0002
cd $DLDIR ;
for d in * ; do echo ${d} >> $TXTFILEPATH/hcp1200_update_file_list_MAIN.txt; done

cd $TXTFILEPATH ;
cat $TXTFILEPATH/hcp1200_update_file_list_MAIN.txt | while read i; \
do find $UPDATEDIR/${i:0:6}/* -name ${i} > $TXTFILEPATH/file_path.txt ;
	echo "____________________________"; 
	echo ${i:0:6} ; 
	if [ -s $TXTFILEPATH/file_path.txt ] ; then echo "${i} exists in the 2017 data release;"; 
	TMP=$(find $UPDATEDIR/${i:0:6}/* -name ${i})
	mv ${TMP} ${TMP%/*}${PREFIX}${TMP##*/}  
	cp  $DLDIR/${i} "${TMP%/*}"/
	else echo “${i} doesn’t exist in the 2017 data release” >> $TXTFILEPATH/exception_log.txt; fi ;
done

# Number of Files downloaded to update 7T data:
# cd $TXTFILEPATH
# wc -l hcp1200_update_file_list_MAIN.txt
# 7334 hcp1200_update_file_list_MAIN.txt

# Number of files that are new in release 2018 and were not available in 2017 data release:
# wc -l exception_log.txt
# 1104 exception_log.txt


# NOTE:
# Bash script "hcp1200_data_update_20210107_part2.sh" must be run after this to go through  exception_log.txt file which includes list of files that are newly added in the updated version (2018) of hcp1200 and must be moved to the correct subject’s directory 



