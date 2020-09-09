//
//  ViewController.m
//  StreamTest
//
//  Created by songzhou on 2020/9/2.
//  Copyright © 2020 songzhou. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSStreamDelegate>

@property (nonatomic) NSInputStream *iStream;
@property (nonatomic) NSMutableData *data;
@property (nonatomic) NSNumber *bytesRead;

@property (nonatomic) NSOutputStream *oStream;
@property (nonatomic) unsigned int byteIndex;
@property (nonatomic) unsigned int bytesWritten;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *file = [[NSBundle mainBundle] pathForResource:@"stu" ofType:@"json"];
    [self setUpStreamForFile:file];
}

- (void)setUpStreamForFile:(NSString *)path {
    // iStream is NSInputStream instance variable
    _iStream = [[NSInputStream alloc] initWithFileAtPath:path];
    [_iStream setDelegate:self];
    [_iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
        forMode:NSDefaultRunLoopMode];
    [_iStream open];
}

- (void)createOutputStream {
    NSLog(@"Creating and opening NSOutputStream...");
    // oStream is an instance variable
    _oStream = [[NSOutputStream alloc] initToMemory];
    [_oStream setDelegate:self];
    [_oStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
        forMode:NSDefaultRunLoopMode];
    [_oStream open];
}

- (void)readInputStreamFinished {
//    [self createOutputStream];
    [self createNewFile];
}

- (void)processData:(NSData *)data {
    
}
 
- (void)handleError:(NSError *)error {
    NSLog(@"%s-%@", __func__, error);
}

/// polling
- (void)createNewFile {
    _oStream = [[NSOutputStream alloc] initToMemory];
    [_oStream open];
    uint8_t *readBytes = (uint8_t *)[_data mutableBytes];
    int len = MIN(1024, (int)_data.length);
    uint8_t buf[len];

    while (1) {
        if (len == 0) break;
        if ([_oStream hasSpaceAvailable]) {
            (void)strncpy((char *)buf, (const char *)readBytes, len);
            readBytes += len;
            if ([_oStream write:(const uint8_t *)buf maxLength:len] == -1) {
                [self handleError:[_oStream streamError]];
                break;
            }
            
            _bytesWritten += len;
            len = (((int)[_data length] - _bytesWritten >= 1024) ? 1024 :
                   (int)[_data length] - _bytesWritten);
        }
    }
    NSData *newData = [_oStream propertyForKey:
                       NSStreamDataWrittenToMemoryStreamKey];
    if (!newData) {
        NSLog(@"No data written to memory!");
    } else {
        [self processData:newData];
    }
    [_oStream close];
    _oStream = nil;
}

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
    } else if (_oStream == stream) {
        NSLog(@"NSOutStream: %s, eventCode:%ld", __func__, eventCode);
        switch(eventCode) {
            case NSStreamEventHasSpaceAvailable: {
                uint8_t *readBytes = (uint8_t *)[_data mutableBytes];
                readBytes += _byteIndex; // instance variable to move pointer
                int data_len = (int)[_data length];
                unsigned int len = ((data_len - _byteIndex >= 1024) ?
                                    1024 : (data_len-_byteIndex));
                uint8_t buf[len];
                (void)memcpy(buf, readBytes, len);
                len = (unsigned int)[(NSOutputStream *)stream write:(const uint8_t *)buf maxLength:len];
                _byteIndex += len;
                break;
            }
            case NSStreamEventEndEncountered: {
                NSData *newData = [_oStream propertyForKey:
                                   NSStreamDataWrittenToMemoryStreamKey];
                if (!newData) {
                    NSLog(@"NSOutStream: No data written to memory!");
                } else {
                    [self processData:newData];
                }
                [stream close];
                [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                                  forMode:NSDefaultRunLoopMode];
                _oStream = nil; // oStream is instance variable
                break;
            }
            default: break;
        }
    }
}
@end
