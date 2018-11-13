#!/bin/bash
DIR=$1
if [ "$(ls -A ${DIR})" ]; then
echo "${DIR} is not Empty"
else
echo "${DIR} is Empty"
echo "cp -R ${DIR}_/* ${DIR}"
echo "Address=${CodeMeter_Server}" >> /etc/wibu/CodeMeter/Server.ini
if [ ${LEVEL} == "Release" ]; then
echo "cp -R ${DIR}_/* ${DIR}"
cp -R ${DIR}_/* ${DIR}
else
echo "git clone ${GitRepository}"
git clone http://${GitUser}:${GitPass}@${GitRepository} /eclipse-workspace
cp /eclipse-workspace_/start.sh /eclipse-workspace
fi
sudo chmod -R 777 /eclipse-workspace/
fi
