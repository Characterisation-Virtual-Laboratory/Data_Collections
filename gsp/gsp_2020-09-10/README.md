# Download Brain Genomics Superstruct Project (GSP) data set on M3
Download date: 2020-09-10

Brief description:
Large scale imaging data sets are necessary to address complex questions regarding the relationship between brain and behavior. The Brain Genomics Superstruct Project Open Access Data Release exposes a carefully vetted collection of neuroimaging, behavior, cognitive, and personality data for over 1,500 human participants. Each neuroimaging data set includes one high-resolution Magnetic Resonance Imaging (MRI) acquisition and one or more resting-state functional MRI acquisitions. Each functional acquisition is accompanied by a fully-automated quality assessment and pre-computed brain morphometrics are also provided. The imaging data are stored in 10 separate tar files, each containing 157 subjects. There is a single description .csv file that contains the demographic and phenotype data for all 1570 unique subjects. All 10 tar files have been downloaded to obtain the full n=1570 dataset. Also, tar files are uncompressed to help users with data processing.

Data version:
10.5

Date of data release:
2020-03-09

Date of data download on M3:
2020-09-10

Data access process:
 - Be sure to read though and accept the GSP terms and conditions
 - Please follow the instructions here to create a Dataverse account and go to the GSP Dataverse page (data version = 10.5), click on request access next to each restricted file. and get approval from the source to access this data set. It may take a few days for the access to be granted by source.
 - Please forward the access approval email to help@massive.org.au.
 - If you have completed the above steps you can request access this data on M3 with this link: Brain Genomics Superstruct Project (GSP).
 - We will review your approval email and grant access.

Location on M3:
/scratch/gsp/gsp-20200910

Link to the source:
GSP at Harvard University, Neuroinformatics Research Group (https://www.neuroinfo.org/gsp)
GSP data in the Dataverse Harvard. Metadata can be downloaded from the same link.(https://dataverse.harvard.edu/dataverse/GSP)


Original link: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/25833

# list of downloaded files from above link:
GSP_DataUse_Terms_140422.pdf
GSP_list_140630.csv
GSP_part10_140630.tar
GSP_part1_140630.tar
GSP_part2_140630.tar
GSP_part3_140630.tar
GSP_part4_140630.tar
GSP_part5_140630.tar
GSP_part6_140630.tar
GSP_part7_140630.tar
GSP_part8_140630.tar
GSP_part9_140630.tar
GSP_README_140630.pdf
GSP_retest_140630.csv
GSP_retest_140630.tar

# Make a directory to move original downloaded files to /fs03 relevant folder:
mkdir /fs03/gsp/gsp-20200910/original

# Copy downloaded files from original Harvard dataverse to allocated folder for GSP data set
cp /home/fsad0002/Downloads/* /fs03/gsp/gsp-20200910/original

# Verify the integrity of downloaded files:
cd /fs03/gsp/gsp-20200910/original
md5sum GSP_* >> gsp-20200910_md5sum_original.md5
md5sum -c gsp-20200910_md5sum_original.md5 >> gsp-20200910_md5sum_verification_output.md5

# Create a directory for each tar file in path /fs03/gsp/gsp-20200910/ . It will be used as a destination for an uncompressed tar files.
for i in GSP_*.tar ; do mkdir ../${i%????} ; done

#uncompress files:
cd /fs03/gsp/gsp-20200910/original
for i in *.tar ; do tar -C ../${i%????} -xvf ${i} ; done

# copy metadata information and terms and condition to a folder to move to be available /scratch
cp original/*.pdf original/*.csv original/*.md5 .

