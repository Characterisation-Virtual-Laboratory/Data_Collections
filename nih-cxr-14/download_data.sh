#!/bin/bash
#SBATCH --job-name=cxr14data
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=kiowa.scott-hurley@monash.edu.au
#SBATCH --mem=100G
#SBATCH --time=02:00:00
#SBATCH --output=slurm%j.out
#SBATCH --error=slurm%j.err

# This file downloads the images, metadata, and other pdfs related to the NIH Chest Xray Dataset.
# THIS IS THE VERSION USED TO DOWNLOAD AND UNZIP NIH CXR 14, INTO /mnt/reference
# All data can be found here: https://nihcc.app.box.com/v/ChestXray-NIHCC/folder/36938765345
####################################################################################################

cd /mnt/reference/nih-cxr-14/nih-cxr-14_20210219

# Activate the Python virtual environment
source download_venv/bin/activate

# Change directories into images to download the images
cd /mnt/reference/nih-cxr-14/nih-cxr-14_20210219/images

# Load data using the Python script provided by NIHCXR14
python download_images.py

# Perform md5 checksums and save output
md5sum images_01.tar.gz >> cxr14_md5sum_verification_output.md5
md5sum images_02.tar.gz >> cxr14_md5sum_verification_output.md5
md5sum images_03.tar.gz >> cxr14_md5sum_verification_output.md5
md5sum images_04.tar.gz >> cxr14_md5sum_verification_output.md5
md5sum images_05.tar.gz >> cxr14_md5sum_verification_output.md5
md5sum images_06.tar.gz >> cxr14_md5sum_verification_output.md5
md5sum images_07.tar.gz >> cxr14_md5sum_verification_output.md5
md5sum images_08.tar.gz >> cxr14_md5sum_verification_output.md5
md5sum images_09.tar.gz >> cxr14_md5sum_verification_output.md5
md5sum images_10.tar.gz >> cxr14_md5sum_verification_output.md5
md5sum images_11.tar.gz >> cxr14_md5sum_verification_output.md5
md5sum images_12.tar.gz >> cxr14_md5sum_verification_output.md5

# Make directories to unzip to
mkdir images_01
mkdir images_02
mkdir images_03
mkdir images_04
mkdir images_05
mkdir images_06
mkdir images_07
mkdir images_08
mkdir images_09
mkdir images_10
mkdir images_11
mkdir images_12

# Unzip each file
tar xzf images_01.tar.gz -C /mnt/reference/nih-cxr-14/nih-cxr-14_20210219/images/images_01
tar xzf images_02.tar.gz -C /mnt/reference/nih-cxr-14/nih-cxr-14_20210219/images/images_02
tar xzf images_03.tar.gz -C /mnt/reference/nih-cxr-14/nih-cxr-14_20210219/images/images_03
tar xzf images_04.tar.gz -C /mnt/reference/nih-cxr-14/nih-cxr-14_20210219/images/images_04
tar xzf images_05.tar.gz -C /mnt/reference/nih-cxr-14/nih-cxr-14_20210219/images/images_05
tar xzf images_06.tar.gz -C /mnt/reference/nih-cxr-14/nih-cxr-14_20210219/images/images_06
tar xzf images_07.tar.gz -C /mnt/reference/nih-cxr-14/nih-cxr-14_20210219/images/images_07
tar xzf images_08.tar.gz -C /mnt/reference/nih-cxr-14/nih-cxr-14_20210219/images/images_08
tar xzf images_09.tar.gz -C /mnt/reference/nih-cxr-14/nih-cxr-14_20210219/images/images_09
tar xzf images_10.tar.gz -C /mnt/reference/nih-cxr-14/nih-cxr-14_20210219/images/images_10
tar xzf images_11.tar.gz -C /mnt/reference/nih-cxr-14/nih-cxr-14_20210219/images/images_11
tar xzf images_12.tar.gz -C /mnt/reference/nih-cxr-14/nih-cxr-14_20210219/images/images_12

# Delete the zip files
rm -f images_01.tar.gz
rm -f images_02.tar.gz
rm -f images_03.tar.gz
rm -f images_04.tar.gz
rm -f images_05.tar.gz
rm -f images_06.tar.gz
rm -f images_07.tar.gz
rm -f images_08.tar.gz
rm -f images_09.tar.gz
rm -f images_10.tar.gz
rm -f images_11.tar.gz
rm -f images_12.tar.gz
