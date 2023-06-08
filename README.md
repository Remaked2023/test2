# test2

包括考核2.1和考核2.2两题

#### 2.1 subcam_code_gen.sh

```shell
#!/bin/bash

replaced=$1             # 要修改的文本

while [ -z "$replaced" ]			# 没有参数输入，退出程序
do
	read -p "修改目标为空，请输入要修改的文本:" replaced
done
echo "输入为：$replaced,1s后执行"
sleep 1s
echo "开始修改"

replacing=$replaced"s"		# 在要改的文本后加s

# 小写部分
for filePath in `find . -name "*$replaced*" | tac`		
do
	newPath=`echo $filePath | sed "s@\(.*\)$replaced@\1$replacing@g"`
	sudo mv "$filePath" "$newPath"
done

# 更改内容-小写部分
sed -i "s/$replaced/$replacing/g" `grep "$replaced" -rl .`

# 将变量更改为大写，再进行更改
replaced=`echo $replaced |tr a-z A-Z`
replacing=`echo $replacing | tr a-z A-Z`

for filePath in `find . -name "*$replaced*"`
do
        newPath=`echo $filePath | sed "s@\(.*\)$replaced@\1$replacing@g"`
       	sudo mv "$filePath" "$newPath"
done

# 更改内容-大写部分
sed -i "s/$replaced/$replacing/g" `grep "$replaced" -rl .`

echo "修改完成"
```

##### 2.1.1 思路

1. 在脚本运行时，如果**忘记带参数**，会导致脚本修改所有文件名，并将路径下所有目录和子目录下所有文件内容清空，**误操作成本过高**（~~再加上自己误操作了3次~~），所以加上了误操作提醒并在误操作时退出脚本。判断依据是输入参数$1长度是否为0，即[ -z \$1 ]，条件成立时执行退出命令exit 1。

2. 思路上将整体分为两部分：大写匹配更改部分和小写匹配更改部分，然后在两个部分内分别进行文件名和文件内容的匹配更改，也就是总计4步的更替

3. `find $path -name "*$replaced*" | tac`  在路径下查找文件名包含"$replaced"的文件，然后对它们进行倒序排列，即从深层路径到浅层路径排列的方式

4. `echo $i | sed "s@\(.*\)$replaced@\1$replacing@g"` 对find找到的文件名进行替换，`sed "s@\(.*\)$replaced@\1$replacing@g"` s@...@...@...代表替换，@是分隔符，`\(.*\)` 和`\1` 匹配，意思相同，代表以'.'(一个任意字符)开始，忽略后续字符匹配，然后接上`$replaced` 和`$replacing` ，g代表全局替换。`echo $i` 即是最终输出也是输入sed的数据

5. grep -rl，-r表示对目录和子目录下所有文件进行匹配搜索，-l表示只输出文件名；
   
   ```shell
   sed -i "s/replaced/replacing/g" `grep "$replaced" -rl $path`
   ```

       将grep匹配得到的文件名集合作为输入，进行内容替换

##### 2.1.2 难点

1. 匹配更改本身需要花费更多时间，需要选中尽量少的目标范围，同时避免更改其他文本

2. 改动时对文件本身造成修改，需要花费时间恢复

3. sed、find、grep三者只有sed具有替换功能，但是sed没有足够丰富的查找和匹配能力，需要联合三者进行

4. 字符串修改需要符合linux命令行和shell编程要求

#### 2.2 show_lcm_infor.sh

```shell
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

```

##### 2.2.1 思路

1. 目标是用输入参数模糊匹配目录下文件夹全称`devPath`（即`basename+$deviceName器件名`），然后进入对应目录寻找配置信息文件`ProjectConfig.mk`，检索匹配出版本信息变量`LINUX_KERNEL_VERSION`，然后再进入对应的版本目录文件，搜寻对应器件包含`LCM`名称的变量`CONFIG_CUSTOM_KERNEL_LCM`，最后分割输出`LCM_NAME`、`IC`、`Module`、`lane`、`resolution`

2. 同样是先做输入检查，确保`$replaced`长度不为0，循环判断，判空就提示要求重新输入

3. 在对应路径`devPath`模糊查找器件文件夹，循环列出能匹配上的文件夹名称，<u>因为模糊搜索可能使得有不止一个结果</u>，而后续<u>确定版本号、获取对应版本配置信息等操作都是建立在只找到单一目标上的</u>，所以需要将列出的所有目标一个一个进行处理输出，于是后续语句放在for循环中
   
   ```shell
   for devPath in `find . -name "*$device*" -type d`
   ```

4. 变量i此时获取的是绝对路径，利用linux系统自带的路径处理方法
   
   ```shell
   deviceName=$(basename $devPath)
   ```
   
   获取寻找到每个文件夹的命名，也就是模糊搜索匹配到的器件全称

5. 在目录中查找文件名为`"ProjectConfig.mk"`的普通文件，找到的绝对路径做值定义变量为`configPath` 
   
   ```shell
   configPath=`find $devPath -name "ProjectConfig.mk" -type f`
   ```

6. 获取版本号匹配搜索关键变量名称获得整行，然后在此基础上以`"`作为分隔符分隔字符串取第二区域，存储在`version`变量，然后再通过`version`变量的值查找得到对应的版本文件路径，更新在`version`变量中

7. 在版本对应文件夹下用文件名称匹配的方式匹配同时包含`$deviceName`和`$deconfig`且不包含`$debug`字样的文件，并要求必须是普通文件的格式，以搜索结果为列表进行for循环

8. shell中，字符串str中用空格隔开各段信息则可表示数组，但是没法引用，`${str}`用此方法可列表循环

##### 2.2.2 难点

1. 模糊匹配搜索得到的结果可能有多项，搜索时可能会导致变量结构变为数组，后续查找发生不匹配问题        --for循环内执行，将搜索结果分开处理

2. 搜索得到的结果是绝对路径，后续匹配需要更加精准的器件名确保搜索结果唯一，就需要对路径进行处理，得到文件名（器件名）    --`$(basename $devPath)` 路径处理
