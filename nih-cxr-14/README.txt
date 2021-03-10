# Dataset Download Documentation
# Create directory for data
mkdir /mnt/reference/nih-cxr-14/nih-cxr_$DATE

#Create Python virtual environment
/usr/local/python/3.8.7-static/bin/python3 -m venv download_venv

# Create directory for the images
mkdir /mnt/reference/nih-cxr-14/nih-cxr-14_20210219/images
cd images

# Add Python script to download files as found here: 
# https://nihcc.app.box.com/v/ChestXray-NIHCC/file/3$
# name it download_images.py

# Run the sbatch script to download the images and do checksums including unzipping
cd /mnt/reference/nih-cxr-14/nih-cxr-14_20210219
sbatch download_data.sh

# The other files in the box DO NOT have static links.
# You can wget / curl them but the links change over time so they can't be put in a script.
# Either wget them via command line or download on Strudel desktop.
# Download Data_Entry_2017_v2020.csv
# Download LOG_CHESTXRAY.pdf
# Download ARXIV_V5_CHESTXRAY.pdf
# Download BBox_List_2017.csv
# Download FAQ_CHESTXRAY.pdf
# Download README_CHESTXRAY.pdf
# Download test_list.txt
# Download train_val_list.txt
