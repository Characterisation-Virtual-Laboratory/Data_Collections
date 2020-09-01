This script is used to optimise uncompression process of Human Connectome Project 1200 data set on High-Performance Computing:

It is tested to unzip 'diffusion data' of 130 HCP subjects and it took only 5 minutes. It's been done without storing unzipped files on a project's scratch folder. It is simple but has a few elements that can help to optimise data user's process:

1) A function is defined for unzipping folder/s and data format conversion for further data processing.
 
2) 'mktemp' is used to write unzipped files into a temporary directory. It means that there is no need to use the space of project's scratch folder for unzipping files. Also, all temporary files get deleted at the end.
 
3) 'gnuparallel' is used to run the function. It is a tool that executes jobs in parallel. It speeds up the unzipping step. NOTE:
gnuparallel can be set up to run on multiple computers which is not recommended on high performance computing. As it is shown in the script I did not use any option when ran this command.
Also, important to note that gnuparallel and slurm must not be used at the same time. You can have this function and run it by gnuparallel before slurm related commands in your script (in case if you use slurm to run your code faster).

Users can adapt this bash script to the files they want to use in data processing, for instance, fMRI data. This script can be combined with their current code they are using. Another option is that they use this file as a separate bash script and call it in the main code prior to any other data processing command. 

Hint: 'tmux' command line can be used to run this script. It helps to not be worried about job failure due to connection loss. It is the crucial benefit of 'tmux' particularly dealing with large data sets such as HCP.

