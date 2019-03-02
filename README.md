# docker_ubuntu-unity-novnc

The porter uses Ubuntu's original desktop, installs ecliipse+ chrome, and supports Chinese

http://localhost:6080/vnc.html


```bash
#
sudo docker pull land007/ubuntu-unity-novnc ; sudo docker stop ubuntu-unity-novnc ; sudo docker rm ubuntu-unity-novnc ; docker run -it -p 5901:5901 -p 6080:6080 -p 4040:4040 --privileged --name ubuntu-unity-novnc land007/ubuntu-unity-novnc:latest
#
sudo docker pull land007/ubuntu-unity-novnc ; sudo docker stop ubuntu-unity-novnc ; sudo docker rm ubuntu-unity-novnc ; docker run -it -v ~/docker/eclipse-workspace:/eclipse-workspace -v ~/docker/eclipse:/usr/local/eclipse -p 5901:5901 -p 6080:6080 -p 4040:4040 --privileged --name ubuntu-unity-novnc land007/ubuntu-unity-novnc:latest
#
sudo docker pull land007/ubuntu-unity-novnc ; sudo docker stop ubuntu-unity-novnc ; sudo docker rm ubuntu-unity-novnc ; docker run -it -v ~/docker/chrome_default:/home/ubuntu/.config/google-chrome/Default -v ~/docker/eclipse-workspace:/eclipse-workspace -v ~/docker/eclipse:/usr/local/eclipse -p 5901:5901 -p 6080:6080 -p 4040:4040 -p 2020:20022 --privileged --name ubuntu-unity-novnc land007/ubuntu-unity-novnc:latest
#
sudo docker exec $CONTAINER_ID cat /home/ubuntu/password.txt
```

![image](https://github.com/land007/docker_ubuntu-unity-novnc/raw/master/WechatIMG543.jpeg)