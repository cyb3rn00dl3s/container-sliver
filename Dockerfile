FROM debian:bullseye

LABEL maintainer="@cyb3rn00dl3s <https://github.com/cyb3rn00dl3s>"

ENV DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

# Create sliver user & group
RUN useradd --uid 10000 -m -s /usr/sbin/nologin -U sliver

# Update & install required packages
RUN apt update && apt install --no-install-recommends -y curl ca-certificates gnupg2 build-essential mingw-w64 binutils-mingw-w64 g++-mingw-w64 && rm -rf /var/lib/apt/lists/* && apt clean && apt autoremove

# Metasploit (optional) dependency -- this will make the container CHONKY
RUN mkdir /opt/install
WORKDIR /opt/install/
RUN curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && chmod 755 msfinstall && ./msfinstall && cd ../ && rm -rf install

# Install sliver
USER sliver
WORKDIR /home/sliver
RUN echo 'Zm9yIFVSTCBpbiAkKGN1cmwgLXMgImh0dHBzOi8vYXBpLmdpdGh1Yi5jb20vcmVwb3MvQmlzaG9wRm94L3NsaXZlci9yZWxlYXNlcy9sYXRlc3QiIHwgYXdrIC1GICciJyAnL2Jyb3dzZXJfZG93bmxvYWRfdXJsL3twcmludCAkNH0nKTsgZG8gaWYgW1sgIiRVUkwiID09ICoic2xpdmVyLXNlcnZlcl9saW51eCIqIF1dOyB0aGVuIGVjaG8gIkRvd25sb2FkaW5nICRVUkwiO2N1cmwgLS1zaWxlbnQgLUwgJFVSTCAtLW91dHB1dCAkKGJhc2VuYW1lICRVUkwpO2ZpO2lmIFtbICIkVVJMIiA9PSAqInNsaXZlci1jbGllbnRfbGludXgiKiBdXTsgdGhlbiBlY2hvICJEb3dubG9hZGluZyAkVVJMIjtjdXJsIC0tc2lsZW50IC1MICRVUkwgLS1vdXRwdXQgJChiYXNlbmFtZSAkVVJMKTtmaTtkb25l'|base64 -d|bash

# Container & user setup
USER root
RUN chmod +x sliver-client_linux sliver-server_linux;mv sliver-server_linux /usr/local/bin/server;mv sliver-client_linux /usr/local/bin/client;ln -s /usr/local/bin/client /usr/local/bin/sliver
RUN mkdir /configs /phishlets /payloads /misc

USER sliver
RUN /usr/local/bin/server unpack
RUN mkdir -p /home/sliver/.sliver-client/configs
RUN /usr/local/bin/server operator --name sliver --lhost localhost --save /home/sliver/.sliver-client/configs

# Some nice docker settings :)
EXPOSE 80 443 31337
STOPSIGNAL SIGQUIT
ENTRYPOINT [ "/usr/local/bin/server" ]