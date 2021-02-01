# Download Brain Genomics Superstruct Project (GSP) data set on M3
# Download date: 2020-09-10
# Original link: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/25833

ls -l home/fsad0002/Downloads/* 
-rw-r--r-- 1 fsad0002 monashuniversity      289445 Sep 10 19:55 GSP_DataUse_Terms_140422.pdf
-rw-r--r-- 1 fsad0002 monashuniversity      651720 Sep 10 14:10 GSP_list_140630.csv
-rw-r--r-- 1 fsad0002 monashuniversity 10736506880 Sep 10 20:09 GSP_part10_140630.tar
-rw-r--r-- 1 fsad0002 monashuniversity 10891991040 Sep 10 14:26 GSP_part1_140630.tar
-rw-r--r-- 1 fsad0002 monashuniversity 10972774400 Sep 10 14:47 GSP_part2_140630.tar
-rw-r--r-- 1 fsad0002 monashuniversity 10798878720 Sep 10 15:01 GSP_part3_140630.tar
-rw-r--r-- 1 fsad0002 monashuniversity 10438246400 Sep 10 19:20 GSP_part4_140630.tar
-rw-r--r-- 1 fsad0002 monashuniversity 10689955840 Sep 10 19:21 GSP_part5_140630.tar
-rw-r--r-- 1 fsad0002 monashuniversity 11055155200 Sep 10 19:35 GSP_part6_140630.tar
-rw-r--r-- 1 fsad0002 monashuniversity 10844508160 Sep 10 19:35 GSP_part7_140630.tar
-rw-r--r-- 1 fsad0002 monashuniversity 10677258240 Sep 10 19:44 GSP_part8_140630.tar
-rw-r--r-- 1 fsad0002 monashuniversity 10900736000 Sep 10 19:59 GSP_part9_140630.tar
-rw-r--r-- 1 fsad0002 monashuniversity     2435962 Sep 10 19:46 GSP_README_140630.pdf
-rw-r--r-- 1 fsad0002 monashuniversity       41902 Sep 10 19:46 GSP_retest_140630.csv
-rw-r--r-- 1 fsad0002 monashuniversity  8960821248 Sep 10 19:58 GSP_retest_140630.tar

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

