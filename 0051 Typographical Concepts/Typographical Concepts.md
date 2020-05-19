![截屏2020-05-18上午10.36.02](https://tva1.sinaimg.cn/large/007S8ZIlly1gewehs015jj30kk0ad758.jpg)

## Characters and Glyphs

`character`

> A character is the smallest unit of written language that carries meaning.
>
> 例如一个单词，一个汉字，一个数学字符。

`glyph`

> Although characters must be represented in a display area by a reconizable shape, they are not identical to that shap.
>
> Any one of these various forms of a character is called a glyph.
>
> 一个字符必须由一个可识别的外形来表示，但外形不是唯一的。不同的形状称为字形。

字符和字形不是一对一的关系。例如：é 由 字形 e 和 字形 ´组成；而一些连字符可以表达多个字符。

`layout manager`：存储glyph code。

## Text Layout

> Text Layout is the process of arranging glyphs on a display device.

![截屏2020-05-18上午11.26.01](https://tva1.sinaimg.cn/large/007S8ZIlly1gewfxr3rtcj30f10c4q3p.jpg)

`layout manager`沿着baseline布局字形。

`metrics`

> Glyph designers provide a set of measurements with a font, which describe the spacing around each glyph in the font.

`kerning`

> shringking or stretching the space between two glyphs.
>
> ![截屏2020-05-18上午11.44.59](https://tva1.sinaimg.cn/large/007S8ZIlly1gewghhwlr9j30go057t99.jpg)

```
lineHeight = ascent + descent + leading
```

### 参考链接 

[Text Programming Guide for iOS](https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/Introduction/Introduction.html#//apple_ref/doc/uid/TP40009542)

