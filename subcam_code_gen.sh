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

count=1

for i in `find $path -iname "*$replacing*"`	# 录入已被更名的文件
do
	array[count]=$i
	let count++ 
done

for i in `grep $replacing -i -rl $path`		# 录入内容被修改的文件
do
	array[count]=$i
	let count++
done

array=`echo ${array[@]} | sort -u`  	#这个不行，输出空白了


echo "修改完成"




