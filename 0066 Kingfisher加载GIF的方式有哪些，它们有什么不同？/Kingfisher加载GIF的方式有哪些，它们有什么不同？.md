## 使用UIImageView

```swift
let imageView = UIImageView()
imageView.kf.setImage(with: URL(string: "gif_url")!)
```

### 内部实现

1. 在结构体 KingfisherParsedOptionsInfo 中

   ```swift
   public var processor: ImageProcessor = DefaultImageProcessor.default
   ```

2. 默认情况下，加载完成时会调用DefaultImageProcessor的processor的这个方法

   ```swift
   public func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
       switch item {
       case .image(let image):
           return image.kf.scaled(to: options.scaleFactor)
       case .data(let data):
           return KingfisherWrapper.image(data: data, options: options.imageCreatingOptions)
       }
   }
   ```

3. 根据图片类型

   ```swift
   public static func image(data: Data, options: ImageCreatingOptions) -> KFCrossPlatformImage? {
       var image: KFCrossPlatformImage?
       switch data.kf.imageFormat {
       case .JPEG:
           image = KFCrossPlatformImage(data: data, scale: options.scale)
       case .PNG:
           image = KFCrossPlatformImage(data: data, scale: options.scale)
       case .GIF:
           image = KingfisherWrapper.animatedImage(data: data, options: options)
       case .unknown:
           image = KFCrossPlatformImage(data: data, scale: options.scale)
       }
       return image
   }
   ```

4. 调用gif 实现

   ```swift
   public static func animatedImage(data: Data, options: ImageCreatingOptions) -> KFCrossPlatformImage? {
       let info: [String: Any] = [
           kCGImageSourceShouldCache as String: true,
           kCGImageSourceTypeIdentifierHint as String: kUTTypeGIF
       ]
   		
     	// 1. 将data转成CGImageSource
       guard let imageSource = CGImageSourceCreateWithData(data as CFData, info as CFDictionary) else {
           return nil
       }
   
       var image: KFCrossPlatformImage?
       if options.preloadAll || options.onlyFirstFrame {
           // Use `images` image if you want to preload all animated data
           guard let animatedImage = GIFAnimatedImage(from: imageSource, for: info, options: options) else {
               return nil
           }
           if options.onlyFirstFrame {
               image = animatedImage.images.first
           } else {
               let duration = options.duration <= 0.0 ? animatedImage.duration : options.duration
             	// 获取GIF图的每一帧，并获取每一帧的时间然后加起来，通过以下方法生成一个动图的image实例
               image = .animatedImage(with: animatedImage.images, duration: duration)
           }
           image?.kf.animatedImageData = data
       } else {
           image = KFCrossPlatformImage(data: data, scale: options.scale)
           var kf = image?.kf
           kf?.imageSource = imageSource
           kf?.animatedImageData = data
       }
   
       return image
   }
   
   init?(from imageSource: CGImageSource, for info: [String: Any], options: ImageCreatingOptions) {
       let frameCount = CGImageSourceGetCount(imageSource)
       var images = [KFCrossPlatformImage]()
       var gifDuration = 0.0
   
       for i in 0 ..< frameCount {
           guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, info as CFDictionary) else {
               return nil
           }
   
           if frameCount == 1 {
               gifDuration = .infinity
           } else {
               // Get current animated GIF frame duration
               gifDuration += GIFAnimatedImage.getFrameDuration(from: imageSource, at: i)
           }
           images.append(KingfisherWrapper.image(cgImage: imageRef, scale: options.scale, refImage: nil))
           if options.onlyFirstFrame { break }
       }
       self.images = images
       self.duration = gifDuration
   }
   ```

## 使用AnimatedImageView

```swift
let imageView = AnimatedImageView()
imageView.kf.setImage(with: URL(string: "gif_url")!)
```

### 内部实现

1. 重写 shouldPreloadAllAnimation，使options.preloadAll 为false，从而走else逻辑

   ```swift
   override func shouldPreloadAllAnimation() -> Bool {
       return false
   }
   ```

2. 重写image的didSet方法，这里开启了一个CADisplayLink 和 Animator

   ```swift
   override open var image: KFCrossPlatformImage? {
     didSet {
         if image != oldValue {
             reset()
         }
         setNeedsDisplay()
       	// 调用layer.delegate的 display(_ layer: CALayer)方法，而UIView的layer.delegate是自身，会调用AniamtedImageView重写的display方法
         layer.setNeedsDisplay()
     }
   }
   
   override open func display(_ layer: CALayer) {
       if let currentFrame = animator?.currentFrameImage {
           layer.contents = currentFrame.cgImage
       } else {
           layer.contents = image?.cgImage
       }
   }
   ```

## 两者差别

AnimatedImageView支持以下5点特性，UIImageView都不支持

1. repeatCount
2. autoPlayAnimatedImage
3. framePreloadCount
4. backgroundDecode
5. runLoopMode

AnimatedImageView由于不用同时解码所有帧的图形数据，会更省内存，但由于多了一些计算会比较浪费CPU。

