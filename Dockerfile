FROM ubuntu:24.04
SHELL ["/bin/bash", "-c"]

ARG RUNNER_VERSION="2.327.1"

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETPLATFORM

RUN apt update -y && apt upgrade -y && \
    apt --no-install-recommends install -y ca-certificates && \
    useradd -m docker

RUN apt install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev libicu-dev python3 python3-venv python3-dev python3-pip && \
    apt clean -y

RUN cd /home/docker && mkdir actions-runner && cd actions-runner && \
    if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
    curl -o actions-runner-linux.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-arm64-${RUNNER_VERSION}.tar.gz; \
    elif [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
    curl -o actions-runner-linux.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz; \
    fi && \
    tar xzf ./actions-runner-linux.tar.gz

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

ENTRYPOINT ["./start.sh"]
