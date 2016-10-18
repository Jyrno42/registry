#!/usr/bin/env bash

# Ensure $EIS_CA_DIR variable is set
[ -z ${EIS_CA_DIR} ] && { echo "Unset required environment variable EIS_CA_DIR"; exit 1; }

# Ensure CA directory exists
mkdir -p ${EIS_CA_DIR}

# Ensure CA inner directories exist
mkdir -p ${EIS_CA_DIR}/certs ${EIS_CA_DIR}/crl ${EIS_CA_DIR}/newcerts ${EIS_CA_DIR}/private ${EIS_CA_DIR}/csrs

# ID card login
temp_dir=`mktemp -d`
wget https://sk.ee/upload/files/EE_Certification_Centre_Root_CA.pem.crt -O ${temp_dir}/crt_0.crt
wget https://sk.ee/upload/files/ESTEID-SK_2007.pem.crt -O ${temp_dir}/crt_1.crt
wget https://sk.ee/upload/files/ESTEID-SK_2011.pem.crt -O ${temp_dir}/crt_2.crt
wget https://sk.ee/upload/files/ESTEID-SK_2015.pem.crt -O ${temp_dir}/crt_3.crt
wget https://sk.ee/upload/files/Juur-SK.pem.crt -O ${temp_dir}/crt_4.crt

cat ${temp_dir}/crt_0.crt \
    ${temp_dir}/crt_1.crt \
    ${temp_dir}/crt_2.crt \
    ${temp_dir}/crt_3.crt \
    ${temp_dir}/crt_4.crt >> ${EIS_CA_DIR}/certs/esteid.cert.pem

rm -rf ${temp_dir}

# also create revocation lists
get_revocation_file() {
    url=$1
    filename=$2

    # Download the crl file
    wget ${url} -O ${EIS_CA_DIR}/crl/${filename}.crl || {
        echo "Failed to download crl from ${url} to ${EIS_CA_DIR}/crl/${filename}.crl";
        exit 1;
    }

    # Convert it to PEM format
    openssl crl -in ${EIS_CA_DIR}/crl/${filename}.crl -out ${EIS_CA_DIR}/crl/${filename}.crl -inform DER || {
        echo "Failed to convert crl ${EIS_CA_DIR}/crl/${filename}.crl to PEM";
        exit 2;
    }

    # Create r0 hash from the certificate
    ln -s ./${filename}.crl ${EIS_CA_DIR}/crl/`openssl crl -hash -noout -in ${EIS_CA_DIR}/crl/${filename}.crl`.r0 || {
        echo "Failed to create r0 hash from crl ${EIS_CA_DIR}/crl/${filename}.crl";
        exit 3;
    }
}

get_revocation_file https://sk.ee/crls/esteid/esteid2007.crl esteid2007 || {
    exit 9;
}
get_revocation_file https://sk.ee/crls/juur/crl.crl crl || {
    exit 9;
}
get_revocation_file https://sk.ee/crls/eeccrca/eeccrca.crl eeccrca || {
    exit 9;
}
get_revocation_file https://sk.ee/repository/crls/esteid2011.crl esteid2011 || {
    exit 9;
}
get_revocation_file https://sk.ee/crls/esteid/esteid2015.crl esteid2015 || {
    exit 9;
}
