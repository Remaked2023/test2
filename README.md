# test2

包括考核2.1和考核2.2两题

#### 2.1 对应subcam_code_gen.sh

```shell
#!/bin/bash

if [ -z "$1" ]            # 没有参数输入，退出程序
then
    echo "修改目标为空，请确认输入是否正确"
    echo "exit"
    exit 1
fi

path="./"            # 路径，要修改的目标目录
replaced=$1        # 要修改的文件名部分
replacing=$1"s"        # 修改后的部分

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

#### 2.2 对应show_lcm_infor.sh

```shell
#!/bin/bash

if [ -z "$1" ]            # 检测是否带参，防止误操作
then
    sleep 1s
    device=`read -p "warning: 无带参执行 请输入要查找的器件"`
else
    device=$1    # 保存要查找配置的器件型号
fi

devPath=/home/disk3/linhongyi/shell_test_project_code/device/agenew    # 工程配置查找路径
verPath=/home/disk3/linhongyi/shell_test_project_code            # 版本文件夹查找路径

for i in `find $devPath -name "*$device*" -type d`     # 获得对应的器件全称，并搜寻版本号和对应的配置信息
do
    deviceName=$(basename $i)
    newPath="$i/ProjectConfig.mk"
    version=`grep "LINUX_KERNEL_VERSION" $newPath | cut -d ' ' -f3`    # 保存版本信息
    for j in `find "$verPath/$version" -name "*$deviceName*defconfig" ! -name "*debug*" -type f`
    do
            LCM_NAME=`grep "CONFIG_CUSTOM_KERNEL_LCM" $j | cut -d '"' -f2`    # 获取所有LCM_NAME
        for LCM in ${LCM_NAME}
        do
                echo "LCM_NAME is: $(echo $LCM)"        # LCM_NAME
            echo "IC is: $(echo $LCM | cut -d '_' -f1)"        # IC型号
            echo "Module : $(echo $LCM | cut -d '_' -f2)"        # Module模组厂商
            echo "lane is: $(echo $LCM | cut -d '_' -f3)"        # lane传输通道
            echo "resolution is: $(echo $LCM | cut -d '_' -f4)"    # resolution分辨率
        done
    done
done
```
