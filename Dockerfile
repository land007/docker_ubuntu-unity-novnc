FROM land007/ubuntu:20.04

MAINTAINER Yiqiu Jia <yiqiujia@hotmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV USER ubuntu
ENV HOME /home/$USER

# Create new user for vnc login.
RUN adduser $USER --disabled-password

# Install Ubuntu Unity.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ubuntu-desktop \
        unity-lens-applications \
        gnome-panel \
        metacity \
        nautilus \
        gedit \
#        xterm \
        gnome-terminal \
        sudo

# Install dependency components.
RUN apt-get install -y \
        supervisor \
        net-tools \
        curl \
        git \
        pwgen \
#        libtasn1-3-bin \
        libglu1-mesa \
        tigervnc-standalone-server \
        tigervnc-xorg-extension \
        tigervnc-viewer \
        ubuntu-unity-desktop
#    && apt-get autoclean \
#    && apt-get autoremove \
#    && rm -rf /var/lib/apt/lists/*

#RUN find / -name "Xvnc" && tar -zxvf
# Clone noVNC.
RUN git clone https://github.com/novnc/noVNC.git $HOME/noVNC

# Clone websockify for noVNC
RUN git clone https://github.com/kanaka/websockify $HOME/noVNC/utils/websockify

# Download ngrok.
#ADD https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip $HOME/ngrok/ngrok.zip
#RUN unzip -o $HOME/ngrok/ngrok.zip -d $HOME/ngrok && rm $HOME/ngrok/ngrok.zip

# Copy supervisor config
COPY supervisor.conf /etc/supervisor/conf.d/

# Set xsession of Unity
COPY xsession $HOME/.xsession

# Copy startup script
COPY startup.sh $HOME

RUN chmod +x /usr/bin/*
RUN chmod +x /home/ubuntu/startup.sh

# Chrome
#RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
#RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
#RUN sudo apt-get update  && sudo apt-get install -y google-chrome-stable
#RUN mkdir -p /home/ubuntu/.config/google-chrome/Default
#RUN mv /home/ubuntu/.config/google-chrome/Default /home/ubuntu/.config/google-chrome/Default_

#shadowsocks
#RUN add-apt-repository ppa:hzwhuang/ss-qt5 && \
#  apt-get update && \
#  apt-get install -y shadowsocks-qt5

ADD check.sh /
RUN sed -i 's/\r$//' /check.sh
RUN chmod a+x /check.sh

#RUN sed -i "s/^ubunut:x.*/ubuntu:x:0:1001:\/home\/ubuntu:\/bin\/bash/g" /etc/passwd
RUN chmod u+x /etc/sudoers && echo "ubuntu    ALL=(ALL:ALL) ALL" >> /etc/sudoers && chmod u-x /etc/sudoers
#RUN apt install -y fcitx fcitx-googlepinyin fcitx-table-wbpy fcitx-pinyin fcitx-sunpinyin

RUN echo $(date "+%Y-%m-%d_%H:%M:%S") >> /.image_times && \
	echo $(date "+%Y-%m-%d_%H:%M:%S") > /.image_time && \
	echo "land007/ubuntu-unity-novnc" >> /.image_names && \
	echo "land007/ubuntu-unity-novnc" > /.image_name

EXPOSE 6080 5901 4040
#CMD ["/bin/bash", "/home/ubuntu/startup.sh"]
#CMD /check.sh /home/ubuntu/.config/google-chrome/Default ; /etc/init.d/ssh start ; nohup /home/ubuntu/startup.sh > /tmp/startup.out 2>&1 & sleep 2 ; cat /home/ubuntu/password.txt ; bash
#RUN echo "/check.sh /home/ubuntu/.config/google-chrome/Default" >> /start.sh
RUN echo "export LD_PRELOAD=/lib/$(uname -m)-linux-gnu/libgcc_s.so.1" >> /start.sh && \
	echo "nohup /home/ubuntu/startup.sh > /tmp/startup.out 2>&1 &" >> /start.sh && \
	echo "sleep 2" >> /start.sh && \
	echo "cat /home/ubuntu/password.txt || true" >> /start.sh && \
	echo "killall -9 vncconfig" >> /start.sh
#RUN apt-get install --no-install-recommends -y xterm ubuntu-unity-desktop
#RUN apt-get install -y xterm ubuntu-unity-desktop

#ADD chromium-codecs-ffmpeg-extra_97.0.4692.71-0ubuntu0.18.04.1_arm64.deb /tmp
#ADD chromium-browser_97.0.4692.71-0ubuntu0.18.04.1_arm64.deb /tmp
#ADD chromium-browser-l10n_97.0.4692.71-0ubuntu0.18.04.1_all.deb /tmp
#ADD deb /tmp
#RUN dpkg -i /tmp/*.deb && rm -f /tmp/*.deb

#docker build -t land007/ubuntu-unity-novnc:20.04 .
#> docker buildx build --platform linux/amd64,linux/arm64/v8,linux/arm/v7 -t land007/ubuntu-unity-novnc:20.04 --push .
#> docker buildx build --platform linux/amd64,linux/arm64/v8 -t land007/ubuntu-unity-novnc:20.04 --push .
#> docker pull --platform=linux/amd64 land007/ubuntu-unity-novnc:20.04

#sudo docker exec $CONTAINER_ID cat /home/ubuntu/password.txt
#docker rm -f ubuntu-unity-novnc ; docker run -it -p 5901:5901 -p 6080:6080 -p 4040:4040 --privileged --name ubuntu-unity-novnc land007/ubuntu-unity-novnc:20.04

