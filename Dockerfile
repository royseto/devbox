# Build a dev tools image with Python, R, NodeJS, PhantomJS, and
# various editors and utilities.
#
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

RUN apt-get update && apt-get install -y -q curl
RUN curl -sL https://deb.nodesource.com/setup | bash -

# Install Ubuntu packages.

RUN apt-get update && apt-get install -y -q \
    openssh-client openssh-server \
    zip unzip bzip2 wget curl git git-man \
    python2.7 python-pip python-virtualenv build-essential python2.7-dev \
    python-software-properties \
    vim emacs-snapshot tmux zsh keychain \
    postgresql-client libpq-dev python-dev \
    r-base r-base-dev nodejs imagemagick optipng

# Install RVM, Ruby, and gist.

RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby
RUN bash -c "(. /usr/local/rvm/scripts/rvm && gem install gist)"

# Install npm packages.

RUN npm install -g brunch@1.7.14 karma@0.12.0 karma-cli@0.0.4 bower@1.3.1

# Install csvkit.

RUN pip install csvkit

# Install R packages.

ADD install_packages.R /tmp/build/
WORKDIR /tmp/build
RUN R CMD BATCH --no-save --no-restore install_packages.R

# Install PhantomJS.

ADD install_phantomjs.sh /tmp/build/
RUN /tmp/build/install_phantomjs.sh

# Install GNU Parallel.

RUN (wget -O - pi.dk/3 || curl pi.dk/3/ || fetch -o - http://pi.dk/3) | bash
RUN bash -c "(echo 'will cite' | parallel --bibtex)"

# Install Redis.

ADD install_redis.sh /tmp/build/
RUN /tmp/build/install_redis.sh

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
