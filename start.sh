#!/bin/bash

REPOSITORY=$REPO
ACCESS_TOKEN=$TOKEN

if [ -z "${NAME}" ]; then
    RUNNER_NAME=$(hostname)
else
    RUNNER_NAME=${NAME}-$(hostname)
fi

echo "REPO ${REPOSITORY}"
echo "RUNNER_NAME ${RUNNER_NAME}"

if [ -z "${REPOSITORY}" ] || [ -z "${ACCESS_TOKEN}" ]; then
    echo "REPOSITORY or ACCESS_TOKEN is not set"
    exit 1
fi

# POST /orgs/{org}/actions/runners/registration-token
# POST /repos/{org}/{repo}/actions/runners/registration-token
if [[ "${REPOSITORY}" =~ / ]]; then
    ENTITY="repos/${REPOSITORY}"
else
    ENTITY="orgs/${REPOSITORY}"
fi
echo "ENTITY ${ENTITY}"
REG_TOKEN=$(curl -X POST -H "Authorization: token ${ACCESS_TOKEN}" -H "Accept: application/vnd.github+json" https://api.github.com/${ENTITY}/actions/runners/registration-token | jq .token --raw-output)

cd /home/docker/actions-runner

./config.sh --url https://github.com/${REPOSITORY} --token ${REG_TOKEN} --name ${RUNNER_NAME}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
