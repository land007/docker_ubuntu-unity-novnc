FROM land007/ubuntu:22.04

MAINTAINER Yiqiu Jia <yiqiujia@hotmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV USER ubuntu
ENV HOME /home/$USER

# 创建一个新用户用于 VNC 登录
#RUN id $USER || adduser $USER --disabled-password
RUN adduser $USER --disabled-password

# 安装 Ubuntu Unity 和依赖组件
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
        sudo \
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
        tigervnc-tools \
        ubuntu-unity-desktop \
        dbus-x11 \
        fcitx \
        fcitx-googlepinyin \
        fcitx-table-wbpy \
        fcitx-pinyin \
        fcitx-sunpinyin && \
	apt-get clean
#    && apt-get autoclean \
#    && apt-get autoremove \
#    && rm -rf /var/lib/apt/lists/*

#RUN find / -name "Xvnc" && tar -zxvf
# 克隆 noVNC 和 websockify
RUN git config --global http.proxy http://proxy.qhkly.com:10172 && \
    git clone https://github.com/novnc/noVNC.git $HOME/noVNC

# Clone websockify for noVNC
RUN git clone https://github.com/kanaka/websockify $HOME/noVNC/utils/websockify
RUN git config --global --unset http.proxy
# Download ngrok.
#ADD https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip $HOME/ngrok/ngrok.zip
#RUN unzip -o $HOME/ngrok/ngrok.zip -d $HOME/ngrok && rm $HOME/ngrok/ngrok.zip

# 复制 supervisor 配置文件
COPY supervisor.conf /etc/supervisor/conf.d/

# 设置 xsession 为 Unity
COPY xsession $HOME/.xsession

# 复制启动脚本
COPY startup.sh $HOME

# 修改权限
RUN chmod +x /usr/bin/* && \
    chmod +x /home/ubuntu/startup.sh

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
RUN sed -i 's/\r$//' /check.sh && \
    chmod a+x /check.sh

#RUN sed -i "s/^ubunut:x.*/ubuntu:x:0:1001:\/home\/ubuntu:\/bin\/bash/g" /etc/passwd
RUN chmod u+x /etc/sudoers && echo "ubuntu    ALL=(ALL:ALL) ALL" >> /etc/sudoers && chmod u-x /etc/sudoers
#RUN apt install -y fcitx fcitx-googlepinyin fcitx-table-wbpy fcitx-pinyin fcitx-sunpinyin
RUN apt-get install -y fcitx fcitx-googlepinyin fcitx-table-wbpy fcitx-pinyin fcitx-sunpinyin

# 设置镜像元数据
RUN echo $(date "+%Y-%m-%d_%H:%M:%S") >> /.image_times && \
	echo $(date "+%Y-%m-%d_%H:%M:%S") > /.image_time && \
	echo "land007/ubuntu-unity-novnc" >> /.image_names && \
	echo "land007/ubuntu-unity-novnc" > /.image_name

# 暴露端口
EXPOSE 6080 5901 4040
#CMD ["/bin/bash", "/home/ubuntu/startup.sh"]
#CMD /check.sh /home/ubuntu/.config/google-chrome/Default ; /etc/init.d/ssh start ; nohup /home/ubuntu/startup.sh > /tmp/startup.out 2>&1 & sleep 2 ; cat /home/ubuntu/password.txt ; bash
#RUN echo "/check.sh /home/ubuntu/.config/google-chrome/Default" >> /start.sh
# 添加启动项
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

#docker build -t land007/ubuntu-unity-novnc:22.04 .
#> docker buildx build --platform linux/amd64,linux/arm64/v8,linux/arm/v7 -t land007/ubuntu-unity-novnc:22.04 --push .
#> docker buildx build --platform linux/amd64,linux/arm64/v8,linux/arm/v7 -t wrt.qhkly.com:5000/ubuntu-unity-novnc:22.04 --push .
#> docker buildx build --platform linux/amd64,linux/arm64/v8 -t land007/ubuntu-unity-novnc:20.04 --push .
#> docker pull --platform=linux/amd64 land007/ubuntu-unity-novnc:20.04

#sudo docker exec $CONTAINER_ID cat /home/ubuntu/password.txt
#docker rm -f ubuntu-unity-novnc ; docker run -it -p 5901:5901 -p 6080:6080 -p 4040:4040 --privileged --name ubuntu-unity-novnc land007/ubuntu-unity-novnc:20.04
