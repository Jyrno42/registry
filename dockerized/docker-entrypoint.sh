#!/usr/bin/env bash

log_err() { echo "$@" 1>&2; }

# Replace seed file if needed
if [ ${EIS_SEED_FILE} ]; then
    echo "USING EIS_SEED_FILE";

    # IF DRONE_PROJECT_PATH is set, we are running inside drone and the EIS_SEED_FILE MUST be relative to drone source dir
    if [ ${DRONE_PROJECT_PATH} ]; then
        if [ ! -d "/drone/src/$DRONE_PROJECT_PATH" ]; then
            if [ ! -d "/drone/src/" ]; then
                # If no drone dirs found exit with an error
                log_err "Did not find source code (tried: [/drone/src/$DRONE_PROJECT_PATH, /drone/src/])" >&2;
                exit 1;
            else
                EIS_SEED_FILE="/drone/src/$EIS_SEED_FILE"
            fi
        else
            EIS_SEED_FILE="/drone/src/$DRONE_PROJECT_PATH/$EIS_SEED_FILE"
        fi
    fi

    echo "replacing seeds file with $EIS_SEED_FILE";
    cp $EIS_SEED_FILE db/seeds.rb
fi

# Setup database
rake db:all:create || { log_err "db:all:create failed (code=$?)"; exit 1; }
rake db:all:schema:load || { log_err "db:all:schema:load failed (code=$?)"; exit 2; }
rake db:migrate || { log_err "db:all:migrate failed (code=$?)"; exit 3; }
rake db:seed || { log_err "db:seed failed (code=$?)"; exit 4; }

# Configure certificates
/configure-certificates.sh || { log_err "configure-certificates.sh failed (code=$?)"; exit 5; }
chown -R www-data:www-data ${EIS_CA_DIR} || { log_err "chown ca dir failed (code=$?)"; exit 6; }

# Precompile assets
rake assets:precompile || { log_err "assets:precompile failed (code=$?)"; exit 7; }

# Ensure tmp folder ownership is correct
chown -R www-data:www-data /home/registry/registry/tmp || { log_err "chown tmp dir failed (code=$?)"; exit 8; }
chmod -R g+r /home/registry/registry/tmp || { log_err "chmod tmp dir failed (code=$?)"; exit 9; }

# Server the app using apache
httpd-foreground || { log_err "httpd-foreground failed (code=$?)"; exit 10; }

