# /bin/bash

disk=$1

echo 停止docker..
sudo systemctl stop docker.socket
systemctl stop docker

echo 备份数据...
cd /
tar -zcvf data.tar.gz data

#echo 取消docker挂载...
#cat /proc/mounts |grep "data/docker" |awk '{print $2}' |xargs -n1 umount

echo 取消data挂载... 
umount /dev/${disk}

#echo 进行分区的磁盘...
#fdisk $1


echo 格式化...
sudo mkfs.xfs -f  /dev/${disk}

echo 获取新的UUID..
uuid=`lsblk -f | awk -v j=$disk '$1==j {print $3}'`

echo 替换/etc/fstab UUID
sed -i '$s/.*/UUID='$uuid'       \/data\/  xfs     defaults,nofail 0       0/' /etc/fstab


#echo 修改挂载...
#vim /etc/fstab
echo 挂载测试...
mount -a

echo 还原数据...
tar -zxvf data.tar.gz

echo 启动docker...
systemctl start docker
sudo systemctl start docker.socket

