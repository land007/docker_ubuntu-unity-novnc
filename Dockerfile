FROM land007/ubuntu:latest

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
        libtasn1-3-bin \
        libglu1-mesa \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Copy tigerVNC binaries
ADD tigervnc-1.8.0.x86_64 /

# Clone noVNC.
RUN git clone https://github.com/novnc/noVNC.git $HOME/noVNC

# Clone websockify for noVNC
RUN git clone https://github.com/kanaka/websockify $HOME/noVNC/utils/websockify

# Download ngrok.
ADD https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip $HOME/ngrok/ngrok.zip
RUN unzip -o $HOME/ngrok/ngrok.zip -d $HOME/ngrok && rm $HOME/ngrok/ngrok.zip

# Copy supervisor config
COPY supervisor.conf /etc/supervisor/conf.d/

# Set xsession of Unity
COPY xsession $HOME/.xsession

# Copy startup script
COPY startup.sh $HOME

RUN chmod +x /usr/bin/*
RUN chmod +x /home/ubuntu/startup.sh

# Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
RUN sudo apt-get update  && sudo apt-get install -y google-chrome-stable
RUN mkdir -p /home/ubuntu/.config/google-chrome/Default
RUN mv /home/ubuntu/.config/google-chrome/Default /home/ubuntu/.config/google-chrome/Default_

#shadowsocks
RUN add-apt-repository ppa:hzwhuang/ss-qt5 && \
  apt-get update && \
  apt-get install -y shadowsocks-qt5

ADD check.sh /
RUN sed -i 's/\r$//' /check.sh
RUN chmod a+x /check.sh

#RUN sed -i "s/^ubunut:x.*/ubuntu:x:0:1001:\/home\/ubuntu:\/bin\/bash/g" /etc/passwd
RUN chmod u+x /etc/sudoers && echo "ubuntu    ALL=(ALL:ALL) ALL" >> /etc/sudoers && chmod u-x /etc/sudoers
RUN apt install -y fcitx fcitx-googlepinyin fcitx-table-wbpy fcitx-pinyin fcitx-sunpinyin

RUN echo $(date "+%Y-%m-%d_%H:%M:%S") >> /.image_times
RUN echo $(date "+%Y-%m-%d_%H:%M:%S") > /.image_time
RUN echo "land007/ubuntu-unity-novnc" >> /.image_names
RUN echo "land007/ubuntu-unity-novnc" > /.image_name

EXPOSE 6080 5901 4040
#CMD ["/bin/bash", "/home/ubuntu/startup.sh"]
#CMD /check.sh /home/ubuntu/.config/google-chrome/Default ; /etc/init.d/ssh start ; nohup /home/ubuntu/startup.sh > /tmp/startup.out 2>&1 & sleep 2 ; cat /home/ubuntu/password.txt ; bash
RUN echo "/check.sh /home/ubuntu/.config/google-chrome/Default" >> /start.sh
RUN echo "nohup /home/ubuntu/startup.sh > /tmp/startup.out 2>&1 &" >> /start.sh
RUN echo "sleep 2" >> /start.sh
RUN echo "cat /home/ubuntu/password.txt || true" >> /start.sh


#sudo docker exec $CONTAINER_ID cat /home/ubuntu/password.txt
#docker pull land007/ubuntu-unity-novnc ; docker stop ubuntu-unity-novnc ; docker rm ubuntu-unity-novnc ; docker run -it -p 5901:5901 -p 6080:6080 -p 4040:4040 --privileged --name ubuntu-unity-novnc land007/ubuntu-unity-novnc:latest
#docker pull land007/ubuntu-unity-novnc ; docker stop ubuntu-unity-novnc ; docker rm ubuntu-unity-novnc ; docker run -it -v ~/docker/chrome_default:/home/ubuntu/.config/google-chrome/Default -p 5901:5901 -p 6080:6080 -p 4040:4040 -p 2020:20022 --privileged --name ubuntu-unity-novnc land007/ubuntu-unity-novnc:latest
