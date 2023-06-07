#!/bin/bash

if [ -z "$1" ]			# 没有参数输入，退出程序
then
	echo "修改目标为空，请确认输入是否正确"
	echo "exit"
	exit 1
fi

path="./"			# 路径，要修改的目标目录
replaced=$1		# 要修改的文件名部分
replacing=$1"s"		# 修改后的部分

# 小写部分
for i in `find $path -name "*$replaced*" | tac`
do
	newpath=`echo $i | sed "s@\(.*\)$replaced@\1$replacing@g"`
	sudo mv "$i" "$newpath"
done

# 更改内容-小写部分
sed -i "s/$replaced/$replacing/g" `grep "$replaced" -rl $path`

# 将变量更改为大写，再进行更改
replaced=`echo $replaced |tr a-z A-Z`
replacing=`echo $replacing | tr a-z A-Z`

for i in `find $path -name "*$replaced*"`
do
        newpath=`echo $i | sed "s@\(.*\)$replaced@\1$replacing@g"`
       	sudo mv "$i" "$newpath"
done

# 更改内容-大写部分
sed -i "s/$replaced/$replacing/g" `grep "$replaced" -rl $path`

echo "修改完成"




