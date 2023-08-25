FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV LC_ALL=en_US.UTF-8


RUN set -ux; \
  sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//http:\/\/mirrors.aliyun.com\/ubuntu\//g' /etc/apt/sources.list \
  && apt-get update \
  && apt-get install -y \
  --no-install-recommends \
  openssl \
  net-tools \
  git \
  zsh \
  locales \
  sudo \
  dumb-init \
  vim \
  curl \
  wget \
  bash-completion \
  python3 \
  python3-pip \
  python3-setuptools \
  build-essential \
  python3-dev \
  libssl-dev \
  libffi-dev \
  libxml2 \
  libxml2-dev \
  libxslt1-dev \
  zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

RUN chsh -s /bin/bash
ENV SHELL=/bin/bash


# fixuid
ADD fixuid-0.5.1-linux-amd64.tar.gz /usr/local/bin/
RUN set -ux; \
  chown root:root /usr/local/bin/fixuid && \
  chmod 4755 /usr/local/bin/fixuid && \
  mkdir -p /etc/fixuid && \
  printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml


# code_server
COPY code-server_4.13.0_amd64.deb /tmp/
RUN set -ux; \
  cd /tmp/ && \
  sudo dpkg -i code-server_4.13.0_amd64.deb && \
  rm -rf code-server_4.13.0_amd64.deb



# add user
RUN set -ux; \
  adduser --disabled-password --gecos '' coder && \
  adduser coder sudo && \
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
  echo "root:P@ssw0rd" | chpasswd && \
  echo "coder:oschina" | chpasswd && \
  locale-gen en_US.UTF-8


# add workspace
RUN chmod g+rw /home && \
  mkdir -p /home/coder/workspace && \
  mkdir -p /home/coder/.local && \
  chown -R coder:coder /home/coder && \
  chown -R coder:coder /home/coder/.local && \
  chown -R coder:coder /home/coder/workspace;


ENV PASSWORD=${PASSWORD:-P@ssw0rd}


# kubectl and helm
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.21.1/bin/linux/amd64/kubectl" && \
  chmod 755 ./kubectl && \
  mv ./kubectl /usr/bin/ && \
  HELM_VERSION=v3.8.0 && \
  curl -sSL "https://mirrors.huaweicloud.com/helm/${HELM_VERSION}/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar -xzf - && \
  mv ./linux-amd64/helm  /usr/bin/


USER coder


# fzf
COPY --chown=1000:1000 fzf /home/coder/.fzf
RUN set -ux;\
  /home/coder/.fzf/install


COPY ./extensions /home/coder/.local/extensions

RUN set -ux; \
  code-server --install-extension /home/coder/.local/extensions/bmalehorn.shell-syntax-1.0.5.vsix && \
  code-server --install-extension /home/coder/.local/extensions/codezombiech.gitignore-0.9.0.vsix && \
  code-server --install-extension /home/coder/.local/extensions/dave-hagedorn.jenkins-runner-1.3.0.vsix && \
  code-server --install-extension /home/coder/.local/extensions/dbaeumer.vscode-eslint-2.4.0.vsix && \
  code-server --install-extension /home/coder/.local/extensions/foxundermoon.shell-format-7.2.5.vsix && \
  code-server --install-extension /home/coder/.local/extensions/ipedrazas.kubernetes-snippets-0.1.9.vsix && \
  code-server --install-extension /home/coder/.local/extensions/janjoerke.jenkins-pipeline-linter-connector-1.2.0.vsix && \
  code-server --install-extension /home/coder/.local/extensions/jannek-aalto.shell-function-outline-1.2.2.vsix && \
  code-server --install-extension /home/coder/.local/extensions/lunuan.kubernetes-templates-1.3.1.vsix && \
  code-server --install-extension /home/coder/.local/extensions/ms-azuretools.vscode-docker-1.24.0.vsix && \
  code-server --install-extension /home/coder/.local/extensions/ms-kubernetes-tools.vscode-kubernetes-tools-1.3.11.vsix && \
  code-server --install-extension /home/coder/.local/extensions/piotrpalarz.vscode-gitignore-generator-1.0.3.vsix && \
  code-server --install-extension /home/coder/.local/extensions/PKief.material-icon-theme-4.25.0.vsix && \
  code-server --install-extension /home/coder/.local/extensions/tetradresearch.vscode-h2o-0.2.9.vsix && \
  code-server --install-extension /home/coder/.local/extensions/Tim-Koehler.helm-intellisense-0.14.3.vsix && \
  code-server --install-extension /home/coder/.local/extensions/tkrkt.linenote-1.2.1.vsix && \
  code-server --install-extension /home/coder/.local/extensions/yzhang.markdown-all-in-one-3.5.0.vsix

RUN sudo rm -rf /home/coder/.local/extensions/


RUN set -eux; \
  python3 -m pip install -U pip setuptools && \
  python3 -m pip install requests autopep8 -i  https://mirrors.aliyun.com/pypi/simple



COPY entrypoint.sh /home/coder/.local/entrypoint.sh
COPY settings.json /home/coder/.local/share/code-server/User/settings.json


RUN set -eux; \
  sudo chmod +x /home/coder/.local/entrypoint.sh && \
  sudo chown coder /home/coder/.local/share/code-server/User/settings.json && \
  sudo sed -i 's/.*NOPASSWD:*/#&/g' /etc/sudoers



WORKDIR /home/coder/workspace

EXPOSE 8080

ENTRYPOINT ["/bin/sh", "/home/coder/.local/entrypoint.sh"]

