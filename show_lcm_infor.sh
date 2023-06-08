#!/bin/bash
device=$1       # 保存要查找配置的器件型号

while [ -z "$device" ]			# 检测是否带参，防止误操作
do
	read -p "warning: 无带参执行 请输入要查找的器件:" device
done



for devPath in `find . -name "*$device*" -type d` 	# 获得对应的器件全称，并搜寻版本号和对应的配置信息
do
	deviceName=$(basename $devPath)	# 切割绝对路径获取器件名称
	configPath=`find $devPath -name "ProjectConfig.mk" -type f`	# 搜索Config文件
	if [ -z "$configPath" ]	# 找不到ProjectConfig.mk，执行下一个循环
	then
		continue
	fi
	#echo "$configPath"

	version=`grep "LINUX_KERNEL_VERSION" $configPath | cut -d ' ' -f3`	# 保存版本信息
	if [ -z "$version" ]
	then
		continue
	fi
	version=`find . -name "$version" -type d`		# 获取对应版本文件夹路径
	#echo $version

	for LCM_Config in `find "$version" -name "*$deviceName*defconfig" ! -name "*debug*" -type f`
	do
        	LCM_NAME=`grep "CONFIG_CUSTOM_KERNEL_LCM" $LCM_Config | cut -d '"' -f2`	# 获取所有LCM_NAME
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


