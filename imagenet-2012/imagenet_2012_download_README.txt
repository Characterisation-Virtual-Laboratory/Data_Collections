
# This file contains both instructions and commands to download and unzip imagenet 2012 as of 2021-03-02
# Ensure you've created a directory in the read only file system, /mnt/reference 
# Ask someone on the HPC team with the relevant power to do this

$ mkdir imagenet/imagenet-2012_download date

# Ensure you're on the dtn-t node to download this
# This is because /mnt/reference is a read only system
# This fact means an interactive session, or sbatch script won't work
# due to writing permissions.
# You should execute these commands in a tmux session, as a few of them may take a few days. 

# Ensure you're in the right directory
$ cd /mnt/reference/imagenet/imagenet-2012_20200302 

# Download the the data with wget, including:
# To access this data you need to make an account on the imagenet website and navigate to
# download images > 2012
# http://image-net.org/download

# The Development Kits:
# Development Kit (Task 1 & 2)
$ wget http://www.image-net.org/challenges/LSVRC/2012/dd31405981ef5f776aa17412e1f0c112/ILSVRC2012_devkit_t12.tar.gz
# Development Kit (Task 3)
$ wget http://www.image-net.org/challenges/LSVRC/2012/dd31405981ef5f776aa17412e1f0c112/ILSVRC2012_devkit_t3.tar.gz

# The Images:
# Training Images (Task 1 & 2)
$ wget http://www.image-net.org/challenges/LSVRC/2012/dd31405981ef5f776aa17412e1f0c112/ILSVRC2012_img_train.tar
# Training Images (Task 3)
$ wget http://www.image-net.org/challenges/LSVRC/2012/dd31405981ef5f776aa17412e1f0c112/ILSVRC2012_img_train_t3.tar
# Validation Images (All Tasks)
$ wget http://www.image-net.org/challenges/LSVRC/2012/dd31405981ef5f776aa17412e1f0c112/ILSVRC2012_img_val.tar
# Test Images (All Tasks)
$ wget http://www.image-net.org/challenges/LSVRC/2012/dd31405981ef5f776aa17412e1f0c112/ILSVRC2012_img_test_v10102019.tar

# The Bounding Boxes
# Training Bounding Box Annotations (Task 1 & 2)
$ wget http://www.image-net.org/challenges/LSVRC/2012/dd31405981ef5f776aa17412e1f0c112/ILSVRC2012_bbox_train_v2.tar.gz
# Training Bounding Box Annotations (Task 3)
$ wget http://www.image-net.org/challenges/LSVRC/2012/dd31405981ef5f776aa17412e1f0c112/ILSVRC2012_bbox_train_dogs.tar.gz
# Validation Bounding Box Annotations (All Tasks)
$ wget http://www.image-net.org/challenges/LSVRC/2012/dd31405981ef5f776aa17412e1f0c112/ILSVRC2012_bbox_val_v3.tgz
# Test Bounding Box Annotations (Task 3) 
$ wget http://www.image-net.org/challenges/LSVRC/2012/dd31405981ef5f776aa17412e1f0c112/ILSVRC2012_bbox_test_dogs.zip

# Do an md5sum check on each file and compare with the download webpage
$ touch imagenet-2012_20210302_md5sum.md5
$ md5sum ILSVRC2012_bbox_test_dogs.zip ILSVRC2012_bbox_train_v2.tar.gz ILSVRC2012_devkit_t12.tar.gz ILSVRC2012_img_test_v10102019.tar ILSVRC2012_img_train.tar ILSVRC2012_bbox_train_dogs.tar.gz ILSVRC2012_bbox_val_v3.tgz ILSVRC2012_devkit_t3.tar.gz ILSVRC2012_img_train_t3.tar ILSVRC2012_img_val.tar >> imagenet-2012_20210302_md5sum.md5

# Make directories to unzip these into
$ mkdir {development_kit_task_1and2,development_kit_task_3,training_images_task_1and2,training_images_task_3,validation_images_all_tasks,test_images_all_tasks,bounding_box_annotations_task_1and2,bounding_box_annotations_task_3,validation_bounding_box_annotations_all_tasks,test_bounding_box_annotations_task_3}

# Unzip each file into it's associated directory
$ tar -xvf ILSVRC2012_devkit_t12.tar.gz -C development_kit_task_1and2
$ tar -xvf ILSVRC2012_devkit_t3.tar.gz -C development_kit_task_3
$ tar -xvf ILSVRC2012_img_train.tar -C training_images_task_1and2
$ tar -xvf ILSVRC2012_img_train_t3.tar -C training_images_task_3
$ tar -xvf ILSVRC2012_img_val.tar -C validation_images_all_tasks
$ tar -xvf ILSVRC2012_img_test_v10102019.tar -C test_images_all_tasks
$ tar -xvf ILSVRC2012_bbox_train_v2.tar.gz -C bounding_box_annotations_task_1and2
$ tar -xvf ILSVRC2012_bbox_train_dogs.tar.gz -C bounding_box_annotations_task_3
$ tar -xvf ILSVRC2012_bbox_val_v3.tgz -C validation_bounding_box_annotations_all_tasks
$ unzip ILSVRC2012_bbox_test_dogs.zip -d test_bounding_box_annotations_task_3

# move the zip files and md5sum checks
$ cd /mnt/reference/imagenet/imagenet-2012_20200302 
$ mkdir zipped_files
$ mv *.tar* zipped_files
$ mv *.zip zipped_files

# training_images_task_1and2 and training_images_task_3 both end up full of .tar files. 
# this script will untar them into directories of the name of the tar file.
# then delete the tar files

cd /mnt/reference/imagenet/imagenet-2012_20200302/training_images_task_1and2

find . -type f -name "*.tar" -execdir sh -c '
   dirn="${1%.tar}"         # desired directory name
   mkdir -- "$dirn"            # creating a directory
   cd -- "$dirn" &&
   tar -xf ../"$1"           # extracting to it
' find-sh {} \;

rm -rf *.tar

# ...same for task 3

cd /mnt/reference/imagenet/imagenet-2012_20200302/training_images_task_3

find . -type f -name "*.tar" -execdir sh -c '
   dirn="${1%.tar}"         # desired directory name
   mkdir -- "$dirn"            # creating a directory
   cd -- "$dirn" &&
   tar -xf ../"$1"           # extracting to it
' find-sh {} \;

rm -rf *.tar

# Add the terms and conditions file
