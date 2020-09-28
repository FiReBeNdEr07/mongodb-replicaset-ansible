sudo file -s /dev/xvdb |grep -w "/dev/xvdb: data"
exit_status=`echo $?`
if [[ $exit_status == 0 ]];then
sudo mkfs -t ext4 /dev/xvdb
sudo mkdir -p /data
sudo mount /dev/xvdb /data
else
sudo mkdir -p /data
sudo mount /dev/xvdb /data
fi