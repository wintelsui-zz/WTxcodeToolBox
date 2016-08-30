# Xcode Source Editor Extensions Demo

WTxcodeToolBox

Xcode Source Editor Extensions for Xcode 8
第一次需要打开terminal，然后执行命令sudo /usr/libexec/xpccachectl 一次,
可能是Extension 需要 建议重启电脑.

OS X - Application Extensions - Xcode Source Editor 

编写好你的代码之后，运行extension scheme，当弹出"Choose an app to run"菜单时，选择Xcode 8，打开任意源文件，你的插件就会在"Editor"菜单出现。如果未出现,可能是因为你没有选择开发证书(免费 or 收费)都可

###########################################################################################
插件是可以在Xcode的Preferences的Key Bindings中设置快捷键的 
###########################################################################################
最近使用xcode8 尝试开发一些新的SDK时,很郁闷,有 注释bug 和 不能用VVDocumenter所以花几个小时搞一个超级点单的山寨,
所以简单的自己先写一个插件自己用着,也许会在日后优化,更新功能😄,不过也不一定,
也在研究的同学可以看看这个简单的Demo
不喜勿喷,学习中......
###########################################################################################

1:CommentStatement 插件
包含功能:
(1):CommentStatement 注释掉代码(即xcode原有的Comment Statement功能,因为xcode 8有bug 所以...)等效于 "command + /"
(2):DocumentAdd      添加注释 (超级简单的山寨VVDocumenter)
