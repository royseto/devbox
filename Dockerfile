# Build a dev box for data science work at the command line.
# This exposes an SSH service.

FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive

# Set locale to US. Override in derivative image if needed.

RUN apt-get update && apt-get install -y language-pack-en
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales

# Add package repositories.

RUN apt-get install -y -q software-properties-common
RUN add-apt-repository ppa:ubuntu-elisp/ppa
RUN add-apt-repository ppa:pi-rho/dev
RUN add-apt-repository ppa:git-core/ppa
RUN add-apt-repository 'deb http://cran.rstudio.com/bin/linux/ubuntu trusty/'
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

# Install Ubuntu packages.

RUN apt-get update && apt-get install -y -q \
    openssh-client openssh-server \
    zip unzip bzip2 wget curl git \
    python2.7 python-pip python-virtualenv build-essential python2.7-dev \
    python-software-properties \
    vim emacs-snapshot tmux zsh keychain \
    postgresql-client \
    r-base r-base-dev

# Install csvkit.

RUN pip install csvkit

# Install R packages.

ADD install_packages.R /tmp/build/
WORKDIR /tmp/build
RUN R CMD BATCH --no-save --no-restore install_packages.R

# Enable passwordless sudo for users in the sudo group.

RUN sed -ie '/sudo/ s/ALL$/NOPASSWD: ALL/' /etc/sudoers

# Create a dev user. Mount its home directory /home/dev from a host volume.

RUN useradd dev -u 1000 -c "developer account" -d /home/dev -s /bin/zsh -g users -G sudo --no-create-home
RUN mkdir -p /home/dev
RUN /bin/chown dev:users /home/dev
VOLUME ["/home/dev"]

# Run an ssh server.

WORKDIR /
RUN mkdir /var/run/sshd
ENTRYPOINT /usr/sbin/sshd -D
EXPOSE 22
