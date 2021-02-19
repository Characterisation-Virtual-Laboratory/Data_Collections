
# Updated 7T fMRI data in hcp1200 data release 2017 to data release 2018
Date of updated data download: 2020-12-08

HCP-1200 data version 2017 with path /scratch/hcp1200 on M3 hadmajor issues with preprocessed 7T fMRI data, as is recognised and reported by the HCP community here.
https://www.humanconnectome.org/study/hcp-young-adult/article/major-issue-preprocessed-7t-fmri-data

Hence, we renames the questionable data in this data collection with prefix "old_" and replaced it with reprocessed 7T fMRI data that was released in version 2018. 
https://www.humanconnectome.org/study/hcp-young-adult/article/reprocessed-7t-fmri-data-released-other-updates

This is a version that has fixed issues as described in the link above. 

2 scripts developed to update data:
1) hcp1200_data_update_20210107_part1.sh :
It has a logic Logic for data movement from a directory with recently downloaded HCP1200; 7T data to a directory with updated version.
Also, it generates a log file with files that couldn't find the equivalent of in version 2017, which means those files are newly added to 2018 version.

2) hcp1200_data_update_20210107_part2.sh:
Ran it after script "hcp1200_data_update_20210107_part1.sh". this to goes through the exception log generated from part1 scriot (exception_log.txt) which includes list of files that are newly added in the updated version (2018) of hcp1200 and move those to the correct subject’s directory.


As part of data update below notes must be considered:
- HCP1200 data version 2017 was loaded on M3 using discs and to update data with issue we downloaded a subset of data using  Aspera Connect (https://downloads.asperasoft.com/connect2/). 
- The structure of data will be different in those 2 approaches. Therefore, moving downloaded data to the right location was carefully considered in the script.
- We were inclusive when downloading 7T data rather than just downloading fMRI data with issues. There was 20TB of 7T preprocessed data that was downloaded.
- A browser was used on one of the M3 Desktop nodes and optimised bandwidth for quicker download.


