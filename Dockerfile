# Expose an SSH service on top of royseto/devbase

FROM royseto/devbase

# Create a dev user. Mount its home directory /home/dev from a host volume.

WORKDIR /

RUN useradd dev -u 1000 -c "developer account" -d /home/dev -s /bin/zsh -g users -G sudo --no-create-home
RUN mkdir -p /home/dev && /bin/chown dev:users /home/dev
VOLUME ["/home/dev"]

# Run an ssh server.

RUN mkdir /var/run/sshd
ENTRYPOINT ["/usr/sbin/sshd",  "-D"]
EXPOSE 22
