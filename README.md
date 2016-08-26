powerline-bash
=======

A new powerline-shell which written with bash script and run more faster.

觉得powerline-shell使用python写的，有的时候有些慢，所以希望写一个bash脚本的同样功能的玩意。

# 目标
* Bash 下运行，支持设置环境变量来决定是否开启。
* 快速高效（历史命令智能判断）

# 字体

使用前先去[Powerline Fonts](https://github.com/powerline/fonts)去下载字体安装好。
然后需要设置Terminal使用Powerline Font。

# 使用

如果你的powerline.sh放在HOME目录下，
那么将下面代码加入到```.profile```或者```.bashrc```或者```.bash_profile```中。

如果不是，那么把下面的```powerline.sh```的目录改为你存放的目录即可。

```
function _update_ps1() {
	PS1="$(~/powerline.sh $? 2> /dev/null)"
}

if [ "$TERM" != "linux" ]; then
	PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi
```

## 简化
如果你仅仅想显示git，那么可以使用简化的```powerline-git.sh```文件，这个只处理git，而且并不需要安装额外字体。

