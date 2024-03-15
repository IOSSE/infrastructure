FROM ubuntu:23.04

RUN sed -i "s+//archive.ubuntu.com+//de.archive.ubuntu.com+" /etc/apt/sources.list

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-mate-desktop locales sudo language-pack-de language-pack-de-base

RUN DEBIAN_FRONTEND=noninteractive apt install -y openssh-server
RUN DEBIAN_FRONTEND=noninteractive apt install -y xrdp && \
    adduser xrdp ssl-cert && \
		locale-gen de_DE.UTF-8 && \
		update-locale LANG=de_DE.UTF-8

ARG USER=ubuntu
ARG DEFAULT_PASS=SiZohb9p

RUN echo "$USER:$(openssl passwd -1 $DEFAULT_PASS)" | chpasswd -e  
RUN	usermod -aG sudo $USER && \
    chsh -s /bin/bash $USER && \
		usermod -d /home/$USER $USER 
				
RUN echo "#!/bin/sh\n\
export XDG_SESSION_DESKTOP=mate\n\
export XDG_SESSION_TYPE=x11\n\
export XDG_CURRENT_DESKTOP=MATE\n\
export XDG_CONFIG_DIRS=/etc/xdg/xdg-mate:/etc/xdg\n\
exec dbus-run-session -- mate-session" > /xstartup && chmod +x /xstartup

RUN cp -f /xstartup /etc/xrdp/startwm.sh 

# Configuartions and additional Software

# Disable warnings 
RUN echo "enabled=0" > /etc/default/apport

USER $USER
RUN mkdir /home/$USER/Apps && \
		mkdir /home/$USER/Desktop

##Firefox
USER $USER
ARG firefox_version=123.0.1
RUN cd /home/$USER/Apps && \
		wget https://download-installer.cdn.mozilla.net/pub/firefox/releases/$firefox_version/linux-x86_64/de/firefox-$firefox_version.tar.bz2 && \	
		tar -xf firefox-$firefox_version.tar.bz2 && \
		rm firefox-$firefox_version.tar.bz2 

RUN echo "[Desktop Entry]\n\
Name=Firefox\n\
Comment=Web Browser\n\
Exec=/home/$USER/Apps/firefox/firefox\n\
Icon=/home/$USER/Apps/firefox/browser/chrome/icons/default/default64.png\n\
Terminal=false\n\
Type=Application\n\
Categories=Network;WebBrowser;" > /home/$USER/Desktop/firefox.desktop

USER root

RUN echo "#!/bin/sh\n\
if [ -n \"\$1\" ]; then\n\
  echo \"$USER:\$(openssl passwd -1 \$1)\" | chpasswd -e\n\
  echo \"#!/bin/sh\necho 'done.'\nexit 0\" > /change_password_firsttime.sh\n\
fi\n" > /change_password_firsttime.sh
RUN chmod a+x /change_password_firsttime.sh



EXPOSE 3389
EXPOSE 22


CMD ["bash","-c","service dbus start; service xrdp start; service ssh start; /change_password_firsttime.sh $PASS; /usr/lib/systemd/systemd-logind;"]
