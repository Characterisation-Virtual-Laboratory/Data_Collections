#!/bin/bash
#SBATCH --job-name=cxr14data
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=kiowa.scott-hurley@monash.edu.au
#SBATCH --mem=100G
#SBATCH --time=02:00:00
#SBATCH --output=slurm%j.out
#SBATCH --error=slurm%j.err

# This file downloads the images, metadata, and other pdfs related to the NIH Chest Xray Dataset.
# All data can be found here: https://nihcc.app.box.com/v/ChestXray-NIHCC/folder/36938765345
####################################################################################################

cd /fs03/nih-cxr-14/nih-cxr-14_20201029

# Activate the Python virtual environment
source download_venv/bin/activate

# Change directories into images to download the images
cd /fs03/nih-cxr-14/nih-cxr-14_20201029/images

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

# Move the checksums
mv cxr14_md5sum_verification_output.md5 /fs03/nih-cxr-14/nih-cxr-14_2020102pCPcZnNYasawouOdO1TfjMxOK3zfkqAdHfWudUm02KsJNBdw1efH27WpSmC0wR-UB1OBPUXP7A_XuLIM_YfnKX5cJmDRIC2FHhan2VTtl4FgmveLFYyjjDeH-ZYdbUgdiE0HUpUHoK80KHfkFuVqDXFtm7LaMyBV9o90ddFodAfwf2OCIksPlSOXtrPqhEbl5a2NQgf45SJNhhzSrq1nyAUFFXv2q245u0lkLGey-Oi-Jd6BQgDYx_5RhPc8JLYfyPiA4_J-hQ2wgINtZqREPMS6lMYWfIQOL4NYPG4BjsgKegVkT3hXU78jnmC_72eZ81DBznCBrrq0G67JfS0YEIVJJ9CUEtDlJ1dhO4-KlFsjZdkkFn4KkN1pl9-_NOhBT0XJ1D2o4OoRozQb73TmvGbEFcGUiVeR5gWWB9mwjkx4nGJi88S0RPPH7WeR934F1HMoeBERCc9x4CngwSOevMWvxyOL-EicxAoyQNEJkG_czFfpSwjMb9gGrAVDPoeSb4MSRGQef5dsOhmfvEJM5o12QcgzCPAGCBZvd_n1nRANbwW0vS754kQ8CXBuYWbeNMoYyKNBuMf-HSBOSsPWt3x1z8cwohbHBhlw6cLCYT7dZiqD9xaCGKU2oELUIVZ2TrRVRrrq6a17aXcwmazgnNddojbHIr9pwBIFs27HaL-eDY4NemQx7drWByrhbhEUKfLA5R9_sE_feD3B7Ji0nLt10ugu0vkKQWiWLx6dwLZVSgzQ_VMDVLop4tAoL9_NC8h4u4Yinuxg5IoslEsCWo3POndgmyN_7sPkCvFwtV4D4euks2VgaDLopint17QVJYFXLFFVcfDytA_DQGEFiaKmmb4320wyprxSZ6cr1vmi2AK0zIl0JLqIzWTOwqUhR1sI_csnrkxY9RS_-66g1ssFno9r_tgtG1VUB3122umPS8xoJxB6mZ1PPOGdYOugopX9rsx1Kz9W7MRsJhbkzhN_zsdGHFworhs42My95MGmkP_LR3sLCENABmRFBZH918iZ5OUt10Pp6MIoprlp_vvToksvkCKMY2GbMD6UesktaijmhZw5gDbxr76FNibwuIsLP9zSSF6WGJBMLgaa-L3rhGVt1oYZVJARRYdXyOml4m5NATDje_GzVscLFwUk_-Kq7iBzxQbtEnxBaQqZeltyhaEplm9G3q07Kg2tk0wI-RyEnazGebtkL0zkt2jf1Hwbg../download'
