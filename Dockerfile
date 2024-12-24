FROM ubuntu:20.04

LABEL maintainer="PhysicsReplicatorAI <acbd@efgh.com>"

ARG NB_USER="coqui_user" \
    NB_UID="1000" \
    NB_GID="100"

USER root

ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm \
    TZ=Europe/Paris

# --------------------------------------------------------------------------------
# Update/Install the basics
# --------------------------------------------------------------------------------
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    	sudo locales apt-utils g++ libsndfile1-dev && \
    apt-get -y clean autoclean && \
    apt-get -y autoremove --purge && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen


# --------------------------------------------------------------------------------
# Configure environment
# --------------------------------------------------------------------------------
ENV SHELL=/bin/bash \
    NB_USER="${NB_USER}" \
    NB_UID=${NB_UID} \
    NB_GID=${NB_GID} \
    LC_ALL=fr_FR.UTF-8 \
    LANG=fr_FR.UTF-8 \
    LANGUAGE=fr_FR.UTF-8 \
    PATH="/home/${NB_USER}/.local/bin:${PATH}" \
    HOME="/home/${NB_USER}"


# --------------------------------------------------------------------------------
# Create coqui_user
# User creation method/pattern obtained from:
# https://github.com/jupyter/docker-stacks/blob/master/base-notebook/Dockerfile
# --------------------------------------------------------------------------------
COPY fix-permissions /usr/local/bin/fix-permissions

RUN chmod a+rx /usr/local/bin/fix-permissions && \
    sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc && \
    echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
    useradd -l -m -s /bin/bash -N -u "${NB_UID}" "${NB_USER}" && \
    chmod g+w /etc/passwd && \
    fix-permissions "${HOME}" && \
    cd "${HOME}" && \
    apt-get install -y --no-install-recommends python3-dev python3-pip && \
    apt-get -y autoclean && \
    apt-get -y autoremove --purge && \
    apt-get -y purge $(dpkg --get-selections | grep deinstall | sed s/deinstall//g) && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# --------------------------------------------------------------------------------
# Install TTS
# --------------------------------------------------------------------------------
USER ${NB_UID}

RUN fix-permissions "${HOME}" && \
    python3 -m pip install --no-cache-dir --upgrade TTS && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 5002

ENTRYPOINT ["tts-server"]
