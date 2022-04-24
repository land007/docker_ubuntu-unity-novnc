# docker_ubuntu-unity-novnc

Docker uses the Ubuntu20.04 Unity desktop, and the startup command to set the password is as follows.


```bash
sudo docker run -it -p 5901:5901 -p 6080:6080 -p 4040:4040 -e PASSWORD=123456 --privileged --name ubuntu-unity-novnc land007/ubuntu-unity-novnc:20.04
```

Visit http://127.0.0.1:6080/vnc.html in your browser,

After booting, you can remotely display the following address. The password is 123456. This 123456 is the VNC connection 123456 and the ubuntu password.

You can also use a random password as follows.

```bash
#Start
sudo docker rm -f ubuntu-unity-novnc; sudo docker run -it -p 5901:5901 -p 6080:6080 -p 4040:4040 --privileged --name ubuntu-unity-novnc land007/ubuntu-unity-novnc:20.04
#View password
sudo docker exec ubuntu-unity-novnc cat /home/ubuntu/password.txt
```

![image](https://github.com/land007/docker_ubuntu-unity-novnc/raw/master/1101650796708_.pic.jpg)