#!/bin/bash
#SBATCH --job-name=isicdata
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=kiowa.scott-hurley@monash.edu.au
#SBATCH --nodes=1
#SBATCH --tasks-per-node=2
#SBATCH --mem=10G
#SBATCH --time=01:00:00
#SBATCH --output=slurm%j.out
#SBATCH --error=slurm%j.err

# Change date of folder as needed
mkdir /mnt/reference/isic-2019/isic-2019-20201002/data
cd /mnt/reference/isic-2019/isic-2019-20201002/data

# Use wget to download files from the ISIC website

# Get ISIC_2019_Training_Input.zip
wget --header="Host: s3.amazonaws.com" --header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36" --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" --header="Accept-Language: en-GB,en-US;q=0.9,en;q=0.8" --header="Referer: https://challenge2019.isic-archive.com/" "https://s3.amazonaws.com/isic-challenge-2019/ISIC_2019_Training_Input.zip" -c -O 'ISIC_2019_Training_Input.zip'

# Get ISIC_2019_Training_Metadata.csv
wget --header="Host: s3.amazonaws.com" --header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36" --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" --header="Accept-Language: en-GB,en-US;q=0.9,en;q=0.8" --header="Referer: https://challenge2019.isic-archive.com/" "https://s3.amazonaws.com/isic-challenge-2019/ISIC_2019_Training_Metadata.csv" -c -O 'ISIC_2019_Training_Metadata.csv'

# Get ISIC_2019_Training_GroundTruth.csv
wget --header="Host: s3.amazonaws.com" --header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36" --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" --header="Accept-Language: en-GB,en-US;q=0.9,en;q=0.8" --header="Referer: https://challenge2019.isic-archive.com/" "https://s3.amazonaws.com/isic-challenge-2019/ISIC_2019_Training_GroundTruth.csv" -c -O 'ISIC_2019_Training_GroundTruth.csv'

# Get ISIC_2019_Test_Input.zip
wget --header="Host: s3.amazonaws.com" --header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36" --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" --header="Accept-Language: en-GB,en-US;q=0.9,en;q=0.8" --header="Referer: https://challenge2019.isic-archive.com/" "https://s3.amazonaws.com/isic-challenge-2019/ISIC_2019_Test_Input.zip" -c -O 'ISIC_2019_Test_Input.zip'

# Get ISIC_2019_Test_Metadata.csv
wget --header="Host: s3.amazonaws.com" --header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36" --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" --header="Accept-Language: en-GB,en-US;q=0.9,en;q=0.8" --header="Referer: https://challenge2019.isic-archive.com/" "https://s3.amazonaws.com/isic-challenge-2019/ISIC_2019_Test_Metadata.csv" -c -O 'ISIC_2019_Test_Metadata.csv'

#perform md5sum checks on the files we just saved, and store the output
md5sum ISIC_2019_Training_Input.zip ISIC_2019_Training_Metadata.csv ISIC_2019_Training_GroundTruth.csv ISIC_2019_Test_Input.zip ISIC_2019_Test_Metadata.csv > /fs03/isic-2019/isic-2019-20201002/ISIC2019_md5sum_verification_output.md5

# Unzip files
tar xzf ISIC_2019_Training_Input.zip
tar xzf ISIC_2019_Test_Input.zip

# Remove ZIP files
rm -f ISIC_2019_Training_Input.zip
rm -f ISIC_2019_Test_Input.zip

