
# Download Nathan Kline Institute Rockland Sample (NKI-RS): Neuroimaging Release on M3
Download date: 2020-08-19


Brief description:
The Rockland Sample is currently comprised of data from four studies, please see here for information about those studies. NKI-RS Neuroimaging Release contains imaging data, physiological data acquired during scan acquisition (cardiac and respiratory), and limited phenotyping (age, sex, and handedness). No psychiatric, cognitive, or behavioral information is included. here you can find more information about scans that are included for subjects in the Cross-Sectional Lifespan Connectomics Study, Longitudinal Developmental Connectomics Study, and Mapping Interindividual Variation In The Aging Connectome studies. The latest data release of raw data organized in the BIDS format. This folder includes data from all the releases. Since BIDS makes provisions for phenotypic and data collected during scanning (physiological,event-related), this data is also included in this folder in addition to the MRI series NifTIs. DICOMs are not included.

Data version:
RawDataBidsLatest

Date of data release:
December 2019

Date of data download on M3:
2020-08-19

Data access process:
As advised here, Neuroimaging Release is immediately available to users and does not require a data usage agreement. To access this data on M3, please visit this link to register your data access request.

Location on M3:

/scratch/nkirs-ndr/RawDataBidsLatest_20200819

Link to the source:
Enhanced Nathan Kline Institute - Rockland Sample (http://fcon_1000.projects.nitrc.org/indi/enhanced/index.html)
Link to data documentation can be found here: http://fcon_1000.projects.nitrc.org/indi/enhanced/documentation.html


# Below steps followed to download nkirs-ndr data collection

1) Get AWS installed

# download the AWS installer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

2) unzip it. It creates a folder which calls "aws"
unzip awscliv2.zip

3) AWS CLI installed on $HOME via:

./aws/install -i ~/aws-cli -b ~/bin

4) prepare a download.sh job script
see download.sh here
/fs03/nkirs-ndr/scripts/download.sh

to submit:

sbatch download.sh

5) to check if the job has been started
squeue -u $USER


6) look for the slurm-JOBID.out file e.g., slurm-15281433.out

tail -f slurm-15281433.out   # to follow the aws s3 command and what it is doing
