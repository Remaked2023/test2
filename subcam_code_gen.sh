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




