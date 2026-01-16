FROM jenkins/jenkins:lts

USER root

RUN apt-get update && apt-get install -y \
    docker.io \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip \
    && unzip terraform_1.6.0_linux_amd64.zip -d /usr/local/bin/ \
    && rm terraform_1.6.0_linux_amd64.zip

RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v0.48.0

USER jenkins

RUN jenkins-plugin-cli --plugins \
    git \
    workflow-aggregator \
    docker-workflow \
    terraform \
    ws-cleanup
