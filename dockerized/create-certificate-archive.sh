#!/usr/bin/env bash

# Setup some variables
WORKING_DIR=`pwd`
TARGET_DIR=`mktemp -d`

# Use TARGET_FILE env variable if it is provided, else fall back to eis-certificate-file.tar.gz
TARGET_FILE=${TARGET_FILE:-'eis-certificate-file.tar.gz'}

# Ensure env variables are configured
[ -z ${TARGET_DIR} ] && { echo "Unset required environment variable TARGET_DIR"; exit 1; }
[ -z ${TARGET_FILE} ] && { echo "Unset required environment variable TARGET_FILE"; exit 1; }

# Run configure-certificates which creates the CA configuration
EIS_CA_DIR=${TARGET_DIR} OPENSSL_CONFIG=./dockerized/openssl.cnf ./dockerized/configure-certificates.sh

# Compress target dir using tar
cd ${TARGET_DIR} && tar -cvzf out.tar *
cd ${WORKING_DIR}

# move the file to target path
mv ${TARGET_DIR}/out.tar ${TARGET_FILE}

# Remove temporary dir
rm -r ${TARGET_DIR}
