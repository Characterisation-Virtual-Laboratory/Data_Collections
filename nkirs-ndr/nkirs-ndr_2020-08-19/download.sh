#!/bin/bash

#SBATCH --job-name=nkirs-ndr
#SBATCH --account=fs87
#SBATCH --time=5-
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=8192
#SBATCH --cpus-per-task=2

[ ! -d /fs03/nkirs-ndr/latest ] && mkdir /fs03/nkirs-ndr/latest

aws --no-sign-request s3 cp s3://fcp-indi/data/Projects/RocklandSample/RawDataBIDSLatest \
	/fs03/nkirs-ndr/latest --recursive
