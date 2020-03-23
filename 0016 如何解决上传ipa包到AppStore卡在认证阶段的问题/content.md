# 如何解决上传ipa包到AppStore提示卡在正在验证而无法上传的问题

## 现象

苹果 ipa通过Transporter提交App Store，提示：“正在验证APP-正在通过App Store进行认证...

## 原因

Transporter安装上第一次打开后，会在硬盘目录：/用户/你的电脑登录账号名/资源库/Caches/com.apple.amp.itmstransporter/目录下下载一些缓存文件，这些缓存文件没有下载完，或者下载失败没下载完时，使用Transporter去提交应用这个页面就会卡住或者这个页面很慢。

## 解决方案

1. 下载资源：[链接](http://hpo-prod.oss-cn-hangzhou.aliyuncs.com/client_resource/%E5%AE%A2%E6%88%B7%E7%AB%AF%E8%B5%84%E6%BA%90%E9%9B%86%E5%90%88/itmstransporter.zip)
2. 将压缩包解压，修改目录下/obr/2.0.0/目录下的repository.xml文件中的所有“retygu”修改为你自己电脑的登录账号名（是英文名），把解压后的“com.apple.amp.itmstransporter”目录放到“/用户/你的电脑登录账号名/资源库/Caches/”目录下，覆盖你原有的“com.apple.amp.itmstransporter”目录。
3. 替换成功后重启Transporter，重新上传 ipa

