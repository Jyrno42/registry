#!/usr/bin/env bash

# Ensure $EIS_CA_DIR variable is set
[ -z ${EIS_CA_DIR} ] && { echo "Unset required environment variable EIS_CA_DIR"; exit 1; }

# Ensure CA directory exists
mkdir -p ${EIS_CA_DIR}

# If EIS_CERT_ARCHIVE env variable is set, load CA data from that
if [ ${EIS_CERT_ARCHIVE} ]; then
    echo "USING EIS_CERT_ARCHIVE";

    # IF DRONE_PROJECT_PATH is set, we are running inside drone and the EIS_CERT_ARCHIVE MUST be relative to drone source dir
    if [ ${DRONE_PROJECT_PATH} ]; then
        if [ ! -d "/drone/src/$DRONE_PROJECT_PATH" ]; then
            if [ ! -d "/drone/src/" ]; then
                # If no drone dirs found exit with an error
                echo "Did not find source code (tried: [/drone/src/$DRONE_PROJECT_PATH, /drone/src/])" >&2;
                exit 1;
            else
                EIS_CERT_ARCHIVE="/drone/src/$EIS_CERT_ARCHIVE"
            fi
        else
            EIS_CERT_ARCHIVE="/drone/src/$DRONE_PROJECT_PATH/$EIS_CERT_ARCHIVE"
        fi
    fi

    if [ ! -f ${EIS_CERT_ARCHIVE} ]; then
        echo "File $EIS_CERT_ARCHIVE does not exist";
        exit 1;
    fi

    tar -C ${EIS_CA_DIR} -zxvf ${EIS_CERT_ARCHIVE} ;
    code=$?

    if [ ${code} != 0 ]; then
        echo "Invalid tar archive $EIS_CERT_ARCHIVE (tar exit code $code)";
        exit 2;
    fi

    exit 0;
fi

# Ensure CA inner directories exist
mkdir -p ${EIS_CA_DIR}/certs ${EIS_CA_DIR}/crl ${EIS_CA_DIR}/newcerts ${EIS_CA_DIR}/private ${EIS_CA_DIR}/csrs

# Allow openssl config path to be specified via $OPENSSL_CONFIG
OPENSSL_CONFIG=${OPENSSL_CONFIG:='/etc/ssl/openssl.cnf'}
echo "Using openssl config from: $OPENSSL_CONFIG"

# Create CA database files
chmod 700 ${EIS_CA_DIR}/private
touch ${EIS_CA_DIR}/index.txt
echo 1000 > ${EIS_CA_DIR}/serial
echo 1000 > ${EIS_CA_DIR}/crlnumber

# Generate the root registry key
openssl genrsa -aes256 -passout pass:test -out ${EIS_CA_DIR}/private/ca.key.pem 4096 -config ${OPENSSL_CONFIG} || {
    echo "generating root registry key failed";
    exit 3;
}

# Create root registry certificate
openssl req \
    -config ${OPENSSL_CONFIG} \
    -new \
    -x509 \
    -days 3653 \
    -key ${EIS_CA_DIR}/private/ca.key.pem \
    -sha256 \
    -extensions v3_ca \
    -out ${EIS_CA_DIR}/certs/ca.crt.pem \
    -passin pass:test \
    -subj "/C=EE/ST=/L=/O=/CN=ca.eis.local" || {
    echo "generating root registry certificate failed";
    exit 4;
}

# Create webclient key
openssl genrsa -out ${EIS_CA_DIR}/private/webclient.key.pem 4096 -config ${OPENSSL_CONFIG} || {
    echo "generating webclient key failed";
    exit 5;
}

# Create webclient CSR
openssl req \
    -config ${OPENSSL_CONFIG} \
    -sha256 \
    -new \
    -days 3653 \
    -key ${EIS_CA_DIR}/private/webclient.key.pem \
    -out ${EIS_CA_DIR}/csrs/webclient.csr.pem \
    -subj "/C=EE/ST=/L=/O=/CN=eis.local" || {
    echo "generating webclient CSR failed";
    exit 6;
}


# Sign CSR and create certificate
openssl ca \
    -config ${OPENSSL_CONFIG} \
    -keyfile ${EIS_CA_DIR}/private/ca.key.pem \
    -passin pass:test \
    -cert ${EIS_CA_DIR}/certs/ca.crt.pem \
    -extensions usr_cert \
    -notext \
    -md sha256 \
    -in ${EIS_CA_DIR}/csrs/webclient.csr.pem \
    -days 3653 \
    -batch \
    -out ${EIS_CA_DIR}/certs/webclient.crt.pem || {
    echo "creating webclient certificate failed";
    exit 7;
}

# Create certificate revocation list
openssl ca \
    -config ${OPENSSL_CONFIG} \
    -keyfile ${EIS_CA_DIR}/private/ca.key.pem \
    -passin pass:test \
    -cert ${EIS_CA_DIR}/certs/ca.crt.pem \
    -batch \
    -gencrl \
    -out ${EIS_CA_DIR}/crl/crl.pem || {
    echo "creating certificate revocation list failed";
    exit 8;
}
ln -s ./crl.pem crl/`openssl crl -hash -noout -in ${EIS_CA_DIR}/crl/crl.pem`.r0
ln -s ./crl.pem crl/`openssl crl -hash -noout -in ${EIS_CA_DIR}/crl/crl.pem`.r1
