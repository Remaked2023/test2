#!/bin/bash

if [ -z "$1" ]			# 检测是否带参，防止误操作
then
	sleep 1s
	device=`read -p "warning: 无带参执行 请输入要查找的器件"`
else
	device=$1	# 保存要查找配置的器件型号
fi

devPath=/home/disk3/linhongyi/shell_test_project_code/device/agenew	# 工程配置查找路径
verPath=/home/disk3/linhongyi/shell_test_project_code			# 版本文件夹查找路径

for i in `find $devPath -name "*$device*" -type d` 	# 获得对应的器件全称，并搜寻版本号和对应的配置信息
do
	deviceName=$(basename $i)
	newPath="$i/ProjectConfig.mk"
	version=`grep "LINUX_KERNEL_VERSION" $newPath | cut -d ' ' -f3`	# 保存版本信息
	for j in `find "$verPath/$version" -name "*$deviceName*defconfig" ! -name "*debug*" -type f`
	do
        	LCM_NAME=`grep "CONFIG_CUSTOM_KERNEL_LCM" $j | cut -d '"' -f2`	# 获取所有LCM_NAME
		for LCM in ${LCM_NAME}
		do
        		echo "LCM_NAME is: $(echo $LCM)"		# LCM_NAME
			echo "IC is: $(echo $LCM | cut -d '_' -f1)"		# IC型号
			echo "Module : $(echo $LCM | cut -d '_' -f2)"		# Module模组厂商
			echo "lane is: $(echo $LCM | cut -d '_' -f3)"		# lane传输通道
			echo "resolution is: $(echo $LCM | cut -d '_' -f4)"	# resolution分辨率
		done
	done
done
