## 如何用 UIImageView 显示超大分辨率的图

官方实例中，用于展示的图片*large_leaves_70mp.jpg*，分辨率达到了惊人的7033 × 10110。要展示这么一张图片，我相信大家都能立即意识到，通过通常方法(imageView.image=image)是无法正常显示的。Apple的文档和实例给我了我们一个很好的思路。

针对这个问题，我们的Android工程师的解决方案是将图片按照屏幕分辨率进行等比裁剪。及针对7033 * 10110分辨率的图片为了在1280 * 720分辨率的手机上展示成功，至少会把原图裁剪为703 * 1011。这样可以大幅减少显示图片的内存消耗，基本解决了APP显示大图的问题。但是这样总会有不足，假设有款手机分辨率是1080P，但只有512MB ROM(这个例子比较极端)，那么上面那种按照屏幕分辨率的裁剪方式就会有问题，图片依然没法正确显示。Apple Sample中的做法是利用QuartzCore来进行绘制，并且将图片分割成多个Tile进行绘制。

官方实例中，首先获取了原始图片的高度和宽度

```objective-c
/* 获取原始照片的宽度和高度 */
sourceResolution.width = CGImageGetWidth(sourceImage.CGImage);
sourceResolution.height = CGImageGetHeight(sourceImage.CGImage);
```

计算图片的总像素

```objective-c
sourceTotalPixels = sourceResolution.width * sourceResolution.height;
```

计算未压缩的图片占用多大内存

```
sourceTotalMB = sourceTotalPixels / pixelsPerMB;
```

计算缩放比例

```
imageScale = destTotalPixels / sourceTotalPixels;
```

计算缩放后的宽度和高度，公式为 **缩放后高度=原高度 \* 缩放比例**

```
destResolution.width = (int)(sourceResolution.width * imageScale);
destResolution.height = (int)(sourceResolution.height * imageScale);
```

接下来我们进行绘图工作,首先获取当前设备的色彩空间(色彩范围)。

```
CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//计算缩放后的图片每一行的字节数。
int bytesPerRow = bytesPerPixel * destResolution.width;
```

为需要显示的图片分配足够的像素空间。

```
void *destBitmapData = malloc(bytesPerRow * destResolution.height);
```

[CGBitmapContextCreate函数参数详解](http://blog.csdn.net/wangyuchun_799/article/details/7804809)

```
//创建输出图像的上下文
destContext = CGBitmapContextCreate(
destBitmapData/输出图片需要的像素地址/
, destResolution.width/输出图片的宽度/
, destResolution.height/输出图片的高度/
, 8/内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8/
, bytesPerRow/输出图片每行字节数/
, colorSpace/当前设备色彩范围/
, kCGImageAlphaPremultipliedLast
);
```

对需要展示的位图进行移动和缩放，是我们能够在屏幕上看清图片全貌。

```
//移动图片
CGContextTranslateCTM(destContext, 0.0f, destResolution.height);
//缩放图片
CGContextScaleCTM(destContext, 1.0f, –1.0f);
```

虽然我们对超大图片进行了缩放，但是依然较大，特别是在绘制的时候，非常耗性能。所以Sample中的方法是将该图的绘制分成多个Tile来进行，在该Sample中这张图片被分成了14个Tile。sourceTile表示从原图上截取的Tile尺寸，destTile表示最终绘制到界面上的Tile尺寸。

```
//源Tile的宽度和原图一直
sourceTile.size.width = sourceResolution.width;
/ * 源Tile的高度等于 Tile的总像素/Tile的宽度(因为我们从前面了解到，图片的总像素=高度 * 宽度) Tile用于从原图中截取图片，经过转换变为目标Tile * /
sourceTile.size.height = (int)(tileTotalPixels / sourceTile.size.width);
NSLog(@“source tile size: %f x %f”, sourceTile.size.width,
sourceTile.size.height);
sourceTile.origin.x = 0.0f;
//目标Tile的高度和宽度
destTile.size.width = destResolution.width;
destTile.size.height = sourceTile.size.height * imageScale;
destTile.origin.x = 0.0f;
NSLog(@“dest tile size: %f x %f”, destTile.size.width, destTile.size.height);
// the source seem overlap is proportionate to the destination seem overlap.
// this is the amount of pixels to overlap each tile as we assemble the ouput
// image.
sourceSeemOverlap = (int)((destSeemOverlap / destResolution.height) *
sourceResolution.height);
NSLog(@“dest seem overlap: %f, source seem overlap: %f”, destSeemOverlap,
sourceSeemOverlap);
CGImageRef sourceTileImageRef;
//获取迭代次数，用于表示需要几次读取绘制能将图片展示完毕。
int iterations = (int)(sourceResolution.height / sourceTile.size.height);
//剩余高度
int remainder = (int)sourceResolution.height % (int)sourceTile.size.height;
if (remainder)
iterations++;
// add seem overlaps to the tiles, but save the original tile height for y
// coordinate calculations.
float sourceTileHeightMinusOverlap = sourceTile.size.height;
sourceTile.size.height += sourceSeemOverlap;
destTile.size.height += destSeemOverlap;
NSLog(@“beginning downsize. iterations: %d, tile height: %f, remainder ”
@“height: %d”,
iterations, sourceTile.size.height, remainder);
//开始读取绘制图片
for (int y = 0; y < iterations; ++y) {
// create an autorelease pool to catch calls to -autorelease made within the
// downsize loop.
NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
NSLog(@“iteration %d of %d”, y + 1, iterations);
//计算员Tile坐标
sourceTile.origin.y = y * sourceTileHeightMinusOverlap + sourceSeemOverlap;
//目标Tile坐标
destTile.origin.y =
(destResolution.height) -
((y + 1) * sourceTileHeightMinusOverlap * imageScale + destSeemOverlap);
// create a reference to the source image with its context clipped to the
// argument rect.
/ * 获取源图片的一部分，生成sourceTileImageRef，不要忘记一开始我们就将原图保存在了sourceImage.CGImage * /
sourceTileImageRef =
CGImageCreateWithImageInRect(sourceImage.CGImage, sourceTile);

/ * 判断是否是最后一次迭代，并有剩余高度的图片，不能组成一个Tile * /
if (y == iterations - 1 && remainder) {
float dify = destTile.size.height;
destTile.size.height = CGImageGetHeight(sourceTileImageRef) * imageScale;
dify -= destTile.size.height;
destTile.origin.y += dify;
}
//将获取到的源Tile按照目标Tile的尺寸绘制到界面上
CGContextDrawImage(destContext, destTile, sourceTileImageRef);
/* release the source tile portion pixel data. note,
releasing the sourceTileImageRef doesn’t actually release the tile portion
pixel
data that we just drew, but the call afterward does. /
CGImageRelease(sourceTileImageRef);
/ while CGImageCreateWithImageInRect lazily loads just the image data
defined by the argument rect,
that data is finally decoded from disk to mem when CGContextDrawImage is
called. sourceTileImageRef
maintains internally a reference to the original image, and that original
image both, houses and
caches that portion of decoded mem. Thus the following call to release the
source image. */
[sourceImage release];
// free all objects that were sent -autorelease within the scope of this
// loop.
[pool2 drain];
// we reallocate the source image after the pool is drained since UIImage
// -imageNamed
// returns us an autoreleased object.
//判断绘制是否结束，如果没有则继续读取原图，进行后续绘制工作。
if (y < iterations - 1) {
sourceImage = [[UIImage alloc]
initWithContentsOfFile:[[NSBundle mainBundle]
pathForResource:kImageFilename
ofType:nil]];
[self performSelectorOnMainThread:@selector(updateScrollView:)
withObject:nil
waitUntilDone:YES];
}
}
NSLog(@“downsize complete.”);
//将绘制完毕的图片在ScrollView进行展示
[self performSelectorOnMainThread:@selector(initializeScrollView:)
withObject:nil
waitUntilDone:YES];
// free the context since its job is done. destImageRef retains the pixel data
// now.
CGContextRelease(destContext);
[pool drain];
```

##        如何支持缩放？

```
#import <UIKit/UIKit.h>

@class TiledImageView;

@interface ImageScrollView : UIScrollView <UIScrollViewDelegate> {
	// The TiledImageView that is currently front most
	TiledImageView* frontTiledView;
	// The old TiledImageView that we draw on top of when the zooming stops
	TiledImageView* backTiledView;	
	// A low res version of the image that is displayed until the TiledImageView
	// renders its content.
	UIImageView *backgroundImageView;
    float minimumScale;
	// current image zoom scale
	CGFloat imageScale;
    UIImage* image;
}
@property (retain) UIImage* image;
@property (retain) TiledImageView* backTiledView;	

-(id)initWithFrame:(CGRect)frame image:(UIImage*)image;

@end

```

```
#import "ImageScrollView.h"
#import "TiledImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ImageScrollView;

@synthesize image, backTiledView;

- (void)dealloc {
    [frontTiledView release];
    self.backTiledView = nil;
	[backgroundImageView release];
    [image release];
    //--
    [super dealloc];
}
-(id)initWithFrame:(CGRect)frame image:(UIImage*)img {
    if((self = [super initWithFrame:frame])) {		
		// Set up the UIScrollView
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
		self.maximumZoomScale = 5.0f;
		self.minimumZoomScale = 0.25f;
		self.backgroundColor = [UIColor colorWithRed:0.4f green:0.2f blue:0.2f alpha:1.0f];
		// determine the size of the image
        self.image = img;
        CGRect imageRect = CGRectMake(0.0f,0.0f,CGImageGetWidth(image.CGImage),CGImageGetHeight(image.CGImage));
        imageScale = self.frame.size.width/imageRect.size.width;
        minimumScale = imageScale * 0.75f;
        NSLog(@"imageScale: %f",imageScale);
        imageRect.size = CGSizeMake(imageRect.size.width*imageScale, imageRect.size.height*imageScale);
        // Create a low res image representation of the image to display before the TiledImageView
        // renders its content.
        UIGraphicsBeginImageContext(imageRect.size);		
        CGContextRef context = UIGraphicsGetCurrentContext();		
        CGContextSaveGState(context);
        CGContextDrawImage(context, imageRect, image.CGImage);
        CGContextRestoreGState(context);		
        UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();		
        UIGraphicsEndImageContext();		
        backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        backgroundImageView.frame = imageRect;
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:backgroundImageView];
        [self sendSubviewToBack:backgroundImageView];
        // Create the TiledImageView based on the size of the image and scale it to fit the view.
        frontTiledView = [[TiledImageView alloc] initWithFrame:imageRect image:image scale:imageScale];
        [self addSubview:frontTiledView];
        [frontTiledView release];
    }
    return self;
}

#pragma mark -
#pragma mark Override layoutSubviews to center content

// We use layoutSubviews to center the image in the view
- (void)layoutSubviews {
    [super layoutSubviews];
    // center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = frontTiledView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    frontTiledView.frame = frameToCenter;
	backgroundImageView.frame = frameToCenter;
	// to handle the interaction between CATiledLayer and high resolution screens, we need to manually set the
	// tiling view's contentScaleFactor to 1.0. (If we omitted this, it would be 2.0 on high resolution screens,
	// which would cause the CATiledLayer to ask us for tiles of the wrong scales.)
	frontTiledView.contentScaleFactor = 1.0;
}
#pragma mark -
#pragma mark UIScrollView delegate methods
// A UIScrollView delegate callback, called when the user starts zooming. 
// We return our current TiledImageView.
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return frontTiledView;
}
// A UIScrollView delegate callback, called when the user stops zooming.  When the user stops zooming
// we create a new TiledImageView based on the new zoom level and draw it on top of the old TiledImageView.
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
	// set the new scale factor for the TiledImageView
	imageScale *=scale;
    if( imageScale < minimumScale ) imageScale = minimumScale;
    CGRect imageRect = CGRectMake(0.0f,0.0f,CGImageGetWidth(image.CGImage) * imageScale,CGImageGetHeight(image.CGImage) * imageScale);
    // Create a new TiledImageView based on new frame and scaling.
	frontTiledView = [[TiledImageView alloc] initWithFrame:imageRect image:image scale:imageScale];	
	[self addSubview:frontTiledView];
    [frontTiledView release];
}

// A UIScrollView delegate callback, called when the user begins zooming.  When the user begins zooming
// we remove the old TiledImageView and set the current TiledImageView to be the old view so we can create a
// a new TiledImageView when the zooming ends.
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
	// Remove back tiled view.
	[backTiledView removeFromSuperview];
	// Set the current TiledImageView to be the old view.
	self.backTiledView = frontTiledView;
}

@end

```

