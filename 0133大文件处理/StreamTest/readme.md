# NSStream 处理大文件

如果一次性读入大文件，会占用文件大小的内存。但是创建输入流，可以减少内存峰值。

创建文件出入流，添加到 runloop 中，添加到 runloop 是为了模拟 while 循环，每一次循环读输入流。
```objc
- (void)setUpStreamForFile:(NSString *)path {
    // iStream is NSInputStream instance variable
    _iStream = [[NSInputStream alloc] initWithFileAtPath:path];
    [_iStream setDelegate:self];
    [_iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
        forMode:NSDefaultRunLoopMode];
    [_iStream open];
}
```

delegate 回调处理数据。每次处理 1024 字节，减少内存峰值。
```objc
#pragma mark - NSStreamDelegate -
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    if (_iStream == stream) {
        NSLog(@"NSInputStream: %s, eventCode:%ld", __func__, eventCode);
        
        switch(eventCode) {
            case NSStreamEventHasBytesAvailable:{
                if(!_data) {
                    _data = [NSMutableData data];
                }
                uint8_t buf[1024];
                NSInteger len = 0;
                len = [(NSInputStream *)stream read:buf maxLength:1024];
                NSLog(@"NSInputStream: bytes available:%ld", len);
                if(len) {
                    [_data appendBytes:(const void *)buf length:len];
                    // bytesRead is an instance variable of type NSNumber.
                    _bytesRead = @([_bytesRead intValue]+len);
                } else {
                    NSLog(@"NSInputStream: no buffer!");
                }
                break;
            }
            case NSStreamEventEndEncountered: {
                [stream close];
                [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                  forMode:NSDefaultRunLoopMode];
                stream = nil; // stream is ivar, so reinit it
                [self readInputStreamFinished];
                break;
            }
            default:{
                break;
            }
        }
    }
}

```