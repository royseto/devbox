# Expose an SSH service on top of royseto/devbase

FROM royseto/devbase

# Set default locale to US. Requires en_US.UTF-8 locale to be available in base image.

RUN echo 'LANG="en_US.UTF-8"' > /etc/default/locale

# Create a dev user. Mount its home directory /home/dev from a host volume.

WORKDIR /

RUN useradd dev -u 1000 -c "developer account" -d /home/dev -s /bin/zsh -g users -G sudo --no-create-home
RUN mkdir -p /home/dev && /bin/chown dev:users /home/dev
VOLUME ["/home/dev"]

# Run an ssh server.

RUN mkdir /var/run/sshd
ENTRYPOINT ["/usr/sbin/sshd",  "-D"]
EXPOSE 22
