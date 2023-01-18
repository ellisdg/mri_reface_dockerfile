# Use Ubuntu 22.04 LTS
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND="noninteractive" \
    LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    apt-utils \
                    autoconf \
                    build-essential \
                    bzip2 \
                    ca-certificates \
                    curl \
                    git \
                    libtool \
                    lsb-release \
                    netbase \
                    pkg-config \
                    xorg \
                    unzip \
                    wget \
                    cmake \
                    make \
                    xvfb && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Installing ANTs 2.3.3 (NeuroDocker build)
# Note: the URL says 2.3.4 but it is actually 2.3.3
ENV ANTSPATH="/opt/ants" \
    PATH="/opt/ants:$PATH"
WORKDIR $ANTSPATH
RUN curl -sSL "https://dl.dropbox.com/s/gwf51ykkk5bifyj/ants-Linux-centos6_x86_64-v2.3.4.tar.gz" \
    | tar -xzC $ANTSPATH --strip-components 1


# Installing niftyreg
WORKDIR "/opt"
RUN git clone https://github.com/KCL-BMEIS/niftyreg.git
RUN mkdir niftyreg-build
RUN cd ./niftyreg-build && cmake ../niftyreg && make

# setup niftyreg
RUN rm -rf ./niftyreg && mv ./niftyreg-build /opt/niftyreg
ENV PATH="/opt/niftyreg/reg-io:/opt/niftyreg/reg-apps:$PATH"


# Install matlab-runtime
# Modified from https://github.com/dafnifacility/matlab-runtime-docker
# Install pre-requisites
RUN mkdir -p /matlab-runtime /opt/matlab-runtime/v94/archives /code/model

# Download and install Matlab runtime
RUN wget https://ssd.mathworks.com/supportfiles/downloads/R2018a/deployment_files/R2018a/installers/glnxa64/MCR_R2018a_glnxa64_installer.zip && \
    unzip MCR_R2018a_glnxa64_installer.zip && \
    rm -rf MCR_R2018a_glnxa64_installer.zip && \
    ./install -destinationFolder /opt/matlab-runtime -agreeToLicense yes -mode silent -outputFile /log.txt $$ \
    rm -rf /matlab-runtime
ENV MCRROOT=/opt/matlab-runtime/v94

# Point to the newly installed Matlab runtime binaries
ENV LD_LIBRARY_PATH $MCRROOT:$MCRROOT/runtime/glnxa64:$MCRROOT/bin/glnxa64:$MCRROOT/sys/os/glnxa64:$MCRROOT/sys/opengl/lib/glnxa64:$MCRROOT/extern/bin/glnxa64

# Add mri_reface
COPY * /opt/mri_reface/
ENV PATH="/opt/mri_reface:$PATH"

WORKDIR "/home"


