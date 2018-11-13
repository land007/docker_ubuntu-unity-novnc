FROM land007/ubuntu:16.04

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

# Install Java.
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV CLASSPATH .:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV PATH $PATH:$JAVA_HOME/bin
RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-8-oracle' >> /etc/profile && echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >> /etc/profile && echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
# Eclipse
RUN cd /tmp && wget http://mirror.rise.ph/eclipse//technology/epp/downloads/release/photon/R/eclipse-jee-photon-R-linux-gtk-x86_64.tar.gz && tar -zxvf eclipse-jee-photon-R-linux-gtk-x86_64.tar.gz -C /usr/local/ && rm -f eclipse-jee-photon-R-linux-gtk-x86_64.tar.gz
ADD eclipse.desktop /usr/share/applications/eclipse.desktop
#shadowsocks
RUN add-apt-repository ppa:hzwhuang/ss-qt5 && \
  apt-get update && \
  apt-get install -y shadowsocks-qt5

# eclipse
RUN mv /usr/local/eclipse /usr/local/eclipse_
VOLUME ["/usr/local/eclipse"]
 
# Define working directory.
#RUN mkdir /eclipse-workspace
ADD eclipse-workspace /eclipse-workspace
WORKDIR /eclipse-workspace
RUN ln -s /eclipse-workspace ~/
RUN ln -s /eclipse-workspace /home/land007
RUN mv /eclipse-workspace /eclipse-workspace_
VOLUME ["/eclipse-workspace"]
ADD check.sh /
RUN sed -i 's/\r$//' /check.sh
RUN chmod a+x /check.sh
RUN sed -i 's/\r$//' /eclipse-workspace_/start.sh
RUN chmod a+x /eclipse-workspace_/start.sh
ADD checkOne.sh /
RUN sed -i 's/\r$//' /checkOne.sh
RUN chmod a+x /checkOne.sh

#RUN sed -i "s/^ubunut:x.*/ubuntu:x:0:1001:\/home\/ubuntu:\/bin\/bash/g" /etc/passwd
RUN chmod u+x /etc/sudoers && echo "ubuntu    ALL=(ALL:ALL) ALL" >> /etc/sudoers && chmod u-x /etc/sudoers
RUN apt install -y fcitx fcitx-googlepinyin fcitx-table-wbpy fcitx-pinyin fcitx-sunpinyin

ADD codemeter_6.70.3152.500_amd64.deb /tmp
RUN apt-get update && apt-get install -y libfontconfig1 libfreetype6 libice6 libsm6
RUN dpkg -i /tmp/codemeter_6.70.3152.500_amd64.deb && rm -f /tmp/codemeter_6.70.3152.500_amd64.deb
RUN service codemeter start && service codemeter status && cmu -l
RUN echo '[ServerSearchList\Server1]' >> /etc/wibu/CodeMeter/Server.ini
RUN cat /etc/wibu/CodeMeter/Server.ini
#RUN echo 'Address=192.168.86.8' >> /etc/wibu/CodeMeter/Server.ini
#RUN service codemeter start && service codemeter status && cmu -k
ENV CodeMeter_Server 192.168.86.8

ENV LEVEL Release
#ENV LEVEL Test
#ENV LEVEL Beta
#ENV LEVEL Alpha
ENV GitRepository 192.168.0.1/gitlab/golang-grpc.git
ENV GitUser land007
ENV GitPass 123456

RUN mkdir -p /home/ubuntu/.m2/repository
VOLUME ["/home/ubuntu/.m2/repository"]
RUN mkdir -p /home/ubuntu/.config/google-chrome/Default
VOLUME ["/home/ubuntu/.config/google-chrome/Default"]

#CMD ["/bin/bash", "/home/ubuntu/startup.sh"]
#CMD /check.sh /eclipse-workspace ; /check.sh /usr/local/eclipse ; /check.sh /home/ubuntu/.config/google-chrome/Default ; /etc/init.d/ssh start ; nohup /home/ubuntu/startup.sh > /tmp/startup.out 2>&1 & sleep 2 ; cat /home/ubuntu/password.txt ; bash
CMD /checkOne.sh /eclipse-workspace ; /check.sh /usr/local/eclipse ; /check.sh /home/ubuntu/.config/google-chrome/Default ; /etc/init.d/ssh start ; nohup /home/ubuntu/startup.sh > /tmp/startup.out 2>&1 & sleep 2 ; cat /home/ubuntu/password.txt ; service codemeter start ; sleep 2 ; /eclipse-workspace/start.sh

EXPOSE 6080 5901 4040 8080

#sudo docker exec $CONTAINER_ID cat /home/ubuntu/password.txt
#docker pull land007/ubuntu-unity-novnc ; docker stop ubuntu-unity-novnc ; docker rm ubuntu-unity-novnc ; docker run -it -p 5901:5901 -p 6080:6080 -p 4040:4040 --privileged --name ubuntu-unity-novnc land007/ubuntu-unity-novnc:latest
#docker pull land007/ubuntu-unity-novnc ; docker stop ubuntu-unity-novnc ; docker rm ubuntu-unity-novnc ; docker run -it -v ~/docker/eclipse-workspace:/eclipse-workspace -v ~/docker/eclipse:/usr/local/eclipse -p 5901:5901 -p 6080:6080 -p 4040:8080 --privileged --name ubuntu-unity-novnc land007/ubuntu-unity-novnc:latest
#docker pull land007/ubuntu-unity-novnc ; docker stop ubuntu-unity-novnc ; docker rm ubuntu-unity-novnc ; docker run -it -v ~/docker/chrome_default:/home/ubuntu/.config/google-chrome/Default -v ~/docker/eclipse-workspace:/eclipse-workspace -v ~/docker/eclipse:/usr/local/eclipse -p 5901:5901 -p 6080:6080 -p 4040:8080 -p 2020:20022 --privileged --name ubuntu-unity-novnc land007/ubuntu-unity-novnc:latest

#docker pull land007/ubuntu-unity-novnc:codemeter ; docker stop ubuntu-unity-novnc_codemeter ; docker rm ubuntu-unity-novnc_codemeter ; docker run -it -v ~/docker/chrome_default:/home/ubuntu/.config/google-chrome/Default -v ~/docker/eclipse-workspace_debug:/eclipse-workspace -v ~/docker/eclipse:/usr/local/eclipse -v ~/docker/m2_repository:/home/ubuntu/.m2/repository -p 5911:5901 -p 6080:6080 -p 4040:8080 -p 2020:20022 -e "LEVEL=Test" -e "GitUser=jiayiqiu" -e "GitPass=jiayq007" -e "GitRepository=10.2.0.10:8090/gitlab/jd/store-face-detect-client.git" --privileged --name ubuntu-unity-novnc_codemeter land007/ubuntu-unity-novnc:codemeter
#docker cp ubuntu-unity-novnc_codemeter:/home/ubuntu/.m2/repository ~/docker/m2_repository