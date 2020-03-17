# 修改字体

FZLanTYJW_Cu.TTF：

	- 全名：方正兰亭圆简体_粗
	- name：FZLANTY_CUJW--GB1-0
	- family：FZLanTingYuanS-B-GB

FZLanTYJW.TTF: 

	- 全名: 方正兰亭圆简体
	- name：FZLANTY_JW--GB1-0
	- family：FZLanTingYuanS-R-GB
	
## 添加到项目中
把字体文件拖到项目中，勾选 target。

在 info.plist 中加入

```xml
<key>UIAppFonts</key>
<array>
	<string>FZLanTYJW_Cu.TTF</string>
	<string>FZLanTYJW.TTF</string>
</array>
```
	
## xib
可以从自定义字体列表中的 family 中选择 FZLanTingYuanS-B-GB 或 FZLanTingYuanS-R-GB

我们可以分析下，选中自定义字体后，xib 文件发生了什么改动。

手动 xib 替换字体为 FZLanTingYuanS-B-GB

修改之前
```xml
<rect key="frame" x="101" y="61" width="112" height="20"/>
<fontDescription key="fontDescription" name="PingFangSC-Regular" family="PingFang SC" pointSize="14"/>
                    
<rect key="frame" x="97.5" y="30" width="119" height="24"/>
<fontDescription key="fontDescription" name="PingFangSC-Semibold" family="PingFang SC" pointSize="17"/>
```

修改之后
```xml
 <customFonts key="customFonts">
        <array key="FZLanTYJW.TTF">
            <string>FZLANTY_JW--GB1-0</string>
        </array>
        <array key="FZLanTYJW_Cu.TTF">
            <string>FZLANTY_CUJW--GB1-0</string>
        </array>
</customFonts>

<rect key="frame" x="101" y="57" width="112" height="16.5"/>
<fontDescription key="fontDescription" name="FZLANTY_JW--GB1-0" family="FZLanTingYuanS-R-GB" pointSize="14"/>

                    
<rect key="frame" x="97.5" y="30" width="119" height="20"/>
<fontDescription key="fontDescription" name="FZLANTY_CUJW--GB1-0" family="FZLanTingYuanS-B-GB" pointSize="17"/>
```

实践发现，`customFonts` 不需要指定也能正确设定字体，如果是 autolayout 设定布局，那么 `rect` 标签的修改也可以忽略，那么，我们只需要关注
`fontDescription` 标签。

```xml
<!-- 常规 -->
<fontDescription key="fontDescription" name="FZLANTY_JW--GB1-0" family="FZLanTingYuanS-R-GB" pointSize="14"/>
<!-- 粗体 -->
<fontDescription key="fontDescription" name="FZLANTY_CUJW--GB1-0" family="FZLanTingYuanS-B-GB" pointSize="17"/>
```

如果想自动替换全部 xib 的字体，思路就是扫描所有的 xib 文件，不管是什么字体，如果自重小于等于 `regular`，就替换成 `name="FZLANTY_JW--GB1-0" family="FZLanTingYuanS-R-GB"`，
大于 `regular`，就替换成 `name="FZLANTY_CUJW--GB1-0" family="FZLanTingYuanS-B-GB"`

我这边写了示例代码，对 ACC iPhone 扫描，修改了 100 多个 xib 的字体。目前支持对 UILabel 上指定的苹方字体，修改到对应字重的方正兰亭圆简体。

## 代码替换

`UIFont(name: "FZLANTY_JW--GB1-0", size: size)`