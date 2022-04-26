/usr/lib/gnome-session/gnome-session-binary --session=ubuntu &
/usr/lib/$(uname -m)-linux-gnu/unity/unity-panel-service &
/usr/lib/unity-settings-daemon/unity-settings-daemon &


for indicator in /usr/lib/$(uname -m)-linux-gnu/indicator-*; do
  basename=`basename ${indicator}`
  dirname=`dirname ${indicator}`
  service=${dirname}/${basename}/${basename}-service
  ${service} &
done

unity --reset -v
