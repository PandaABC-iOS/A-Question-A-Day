凡是遵守了Strideable协议的类型，理论上都是连续的，在单一维度上的值能够被抵消和测量，支持整型，浮点型和索引值，Strideable协议继承于 Comparable。

假如我们想实现穿越到指定的时间，例如1个小时之后。

```
//伪代码

var date = NSDate()
date = date + 3600   //3600秒 = 1小时
date += 3600
```

我们现在给NSDate类扩展方法，并遵守Strideable协议,advancedBy()和distanceTo()这俩个方法是必须实现，否则会报错，告诉你没按套路来。Strideable协议的关联对象是Stride,遵守SignedNumberType协议。

```
extension NSDate: Strideable{
  public func advancedBy(n: NSTimeInterval) ->Self {
    return dateByAddingTimeInterval(n)
  }

  publicfunc distanceTo(other:NSDate) ->NSTimeInterval {
    return other.timeIntervalSinceDate(self)
  }
}

var time =NSDate()
time = time + 60.00
time += 60
```

这样我们就可实现通过加法(+)运算符任意地增加时间了，或减法(-)运算符减去时间。

我们也可以调用advancedBy()函数实现增减效果

```
time.advancedBy(3600)  //增加1小时
time.advancedBy(-3600)  //减少1小时
```

我们还可以用distanceTo()测量距离或是间隔，比如说:

```
var anHourLaterTime =time +3600
var distance = time.distanceTo(anHourLaterTime)   //anHourLaterTime - time
print(distance)      //距离为3600
```

遵守了Strideable协议的类型,默认会实现func stride(through:by:)和func stride(to:by:)俩个函数

```
  func stride(through end:NSDate, by stride:NSTimeInterval) ->NSDate {
    returndateByAddingTimeInterval(stride)
  }
  
  func stride(to end:NSDate, by stride:NSTimeInterval) ->NSDate {

    returndateByAddingTimeInterval(stride)

  }
```

也可以调用这俩个方法实现增减时间效果

```
time.stride(through:NSDate(), by: 3600)
time.stride(to:NSDate(), by: 3600)
```



