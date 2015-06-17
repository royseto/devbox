# Expose an SSH service on top of royseto/devbase

FROM royseto/devbase

# Set locale to US. Override in derivative image if needed.

RUN apt-get update && apt-get install -y language-pack-en
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

# Create a dev user. Mount its home directory /home/dev from a host volume.

WORKDIR /

RUN useradd dev -u 1000 -c "developer account" -d /home/dev -s /bin/zsh -g users -G sudo --no-create-home
RUN mkdir -p /home/dev && /bin/chown dev:users /home/dev
VOLUME ["/home/dev"]

# Run an ssh server.

RUN mkdir /var/run/sshd
ENTRYPOINT ["/usr/sbin/sshd",  "-D"]
EXPOSE 22
