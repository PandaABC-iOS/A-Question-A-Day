# 图片

在 iOS 载入图片是一件比较耗费内存的事情。

显示一张图片，可以分成三个阶段：
- 载入，载入压缩的图片到内存，对应到 data buffer
- 解码，解码到 image buffer
- 渲染

# Buffer
- 连续的内存区域

## Data Buffers

- 在内存中存储图片的内容
- 元数据表示图片的尺寸
- 图片本身编码成 JPEG，PNG 等形式
- 字节不会直接表示成对应像素

## Image Buffer

- 图片的内存表示
- 每个元素对应到一个像素的颜色
- buffer 的尺寸与图片尺寸成等比关系

## Frame buffer
frame buffer 是对应到屏幕的一块显示区域。

# 解码
data buffer 要先解码到 image buffer，内存占用与图片的尺寸成正比，而不是需要显示的尺寸或者图片大小。

再 copy 到 frame buffer。

# 降采样

因为图片占用的内存比较大，比如 750*3248 的图片大小，假设每个像素占用4个字节（SRGB 色彩空间中，RGBA各占一个字节）
750*3248*4/1024/1024 = 9.30M

可以裁剪图片到适合尺寸来显著减少内存使用

## 从 Bundle 读取

```swift
// 内存涨幅：13.5M -> 23.3M = 9.8
let path = Bundle.main.path(forResource: "CourseList_bg@2x", ofType: "png")!
let image = UIImage(contentsOfFile: path)
```

## 从 Asset 读取
```swift
/// 13.5M -> 34.9 M = 21.4M
/// UIImage 会缓存一份解码后的数据，所以内存占用是两倍于 bundle 读取

let imageAsset = UIImage(named: "CourseList_bg")!
imageView.image = imageAsset
```

## 降采样

创建一个更小的解码后的 image buffer，尺寸是需要展示的尺寸而不是整个图片的尺寸。

```swift
let url = Bundle.main.url(forResource: "CourseList_bg@2x", withExtension: "png")!
let downsampledImage = downsample(imageAt: url, to: CGSize(width: view.bounds.width, height: view.bounds.height), scale: 2)
// 13.5M -> 14M = 0.5M

private func downsample(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
	/// kCGImageSourceShouldCache: false，先不解码
	let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
	let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!
	
	let maxDimentionInPixels = max(pointSize.width, pointSize.height) * scale
	
	let downsampledOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
							  kCGImageSourceShouldCacheImmediately: true,
							  kCGImageSourceCreateThumbnailWithTransform: true,
							  kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels] as CFDictionary
	
	let downsampledImage =  CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions)!
	
	return UIImage(cgImage: downsampledImage)
}
```

# 参考
- [Image and Graphics Best Practices](https://developer.apple.com/videos/play/wwdc2018/219/)
- [Downsampling images for better memory consumption and UICollectionView performance](https://medium.com/@zippicoder/downsampling-images-for-better-memory-consumption-and-uicollectionview-performance-35e0b4526425)
- [Optimizing Images](https://www.swiftjectivec.com/optimizing-images/)