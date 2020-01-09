#!/bin/bash -e
BASEDIR="$(dirname "$0")"
ACCESS_KEY_ID=0cb039eb6290492a9f24e6ffec71c7d7
SECRET_ACCESS_KEY=1b2cda43f1a59b521bf521bd1ee7f84c80d1dd7ec9df44de
BUCKET_NAME=paiv-trial
PUBLIC_ENDPOINT=s3.us-south.cloud-object-storage.appdomain.cloud
# shellcheck disable=SC1090
# source ${BASEDIR}/env.sh

# Install s3fs- allowing us to present a COS bucket as a File System in User Space (FUSE). 
sudo apt install s3fs

# Store your COS credentials to authenticate later.
echo ${ACCESS_KEY_ID}:${SECRET_ACCESS_KEY} > ${BASEDIR}/.passwd-s3fs
chmod 600 .passwd-s3fs

# Need to get a copy over existing data from PAIV to the COS bucket.
# Create a temporary mount, copy the data across, and then unmount.
s3fs ${BUCKET_NAME} ./temp/ -o url=http://${PUBLIC_ENDPOINT} -o passwd_file=${BASEDIR}/.passwd-s3fs
cp ./test-data/ ./temp/
umount ./temp/
#fusermount -uz ./temp/
rm -r ./temp/

# Now that we have a backup of existing files, we can overwrite and mount at the point where
# PAIV will save logs and user data.
s3fs ${BUCKET_NAME} ./test2/ -o url=http://${PUBLIC_ENDPOINT} -o passwd_file=${BASEDIR}/.passwd-s3fs

# Cleanup
rm ${BASEDIR}/.passwd-s3fs
sudo apt remove s3fs
