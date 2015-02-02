# Build a dev box for data science work at the command line.

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
RUN add-apt-repository 'deb http://cran.rstudio.com/bin/linux/ubuntu trusty/'
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9

# Install Ubuntu packages.

RUN apt-get update && apt-get install -y -q \
    openssh-client \
    zip unzip bzip2 wget curl git \
    python2.7 python-pip python-virtualenv build-essential python2.7-dev \
    python-software-properties \
    vim emacs-snapshot tmux zsh keychain \
    postgresql-client \
    r-base r-base-dev

# Install R packages.

ADD install_packages.R /tmp/build/
WORKDIR /tmp/build
RUN R CMD BATCH --no-save --no-restore install_packages.R

WORKDIR /root
