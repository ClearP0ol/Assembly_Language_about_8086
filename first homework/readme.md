# First Homework: HelloWorld

## 环境配置
手动装载（mount命令）：
在`C:\Users\用户名\AppData\Local\DOSBox`中以记事本形式打开dosbox-0.74.conf，下拉到最后在`autoexec`部分的尾部写入
```
mount d d:\assembly
D:
path D:\Masm5
cd code
```
由于dosbox内的D盘是虚拟盘，所以需要将我们assmbly文件夹所在的位置挂载到它的虚拟D盘中，同时Masm5作为我们的汇编器，也要添加到环境变量路径中

## Debug内存写入

### 1.写入数据
![](picture/picture_1.png)
### 2. 写入代码
![](picture/picture_2.png)
### 3. 查看寄存器默认值、修改默认cs,ds和ip
![](picture/picture_3.png)
![](picture/picture_4.png)
### 4. 运行代码+输出
![](picture/picture_5.png)