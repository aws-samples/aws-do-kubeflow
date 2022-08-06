#!/bin/bash

if [ -f ../../../../../.env ]; then
        pushd ../../../../../
        source .env
        popd
fi

cd ${KF_DIR}
kfctl delete -V -f ${CONFIG_FILE}

