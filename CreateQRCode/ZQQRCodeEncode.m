//
//  ZQQRCodeEncode.m
//  CreateQRCode
//
//  Created by Little Treasure on 7/30/13.
//  Copyright (c) 2013 Little_Treasure. All rights reserved.
//

#import "ZQQRCodeEncode.h"

enum {
	qr_margin = 3
};

@implementation ZQQRCodeEncode

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

// draw the QRCode graph in the context
- (void)drawQRCode:(QRcode *)code context:(CGContextRef)context size:(int)size
{
    __block unsigned char *data = 0;
    int width;
    data = code -> data;
    width = code -> width;
    float zoom = (double)size / (width + 2.0 * qr_margin);
    __block CGRect rectDraw = CGRectMake(0, 0, zoom, zoom);
    CGContextSetFillColor(context, CGColorGetComponents([NSColor blackColor].CGColor));
    for (int i = 0; i < width; ++i) {
        for (int j = 0; j < width; ++j) {
            if (*data & 1) {
                rectDraw.origin = CGPointMake((j + qr_margin) * zoom, (i + qr_margin) * zoom);
                CGContextAddRect(context, rectDraw);
            }
            ++data;
        }
    }
    CGContextFillPath(context);
}

// get the QRCode image from the context

- (void)QRImageWithString:(NSString *)string level:(QRecLevel)aLevel inContext:(CGContextRef)QRCodeImageContext size:(int)size
{
    if (![string length]) {
        _image = nil;
        NSLog(@"Create QRCode failed! reason:no invalid string");
    }
    
    QRcode *theCode = QRcode_encodeString([string UTF8String], 0, aLevel, QR_MODE_8, 1);
    if (!theCode) {
        _image = nil;
        NSLog(@"reason:QRCode create failed!");
    }
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -size);
    CGAffineTransform scaleTransForm = CGAffineTransformMakeScale(1, -1);
    CGContextConcatCTM(QRCodeImageContext, CGAffineTransformConcat(transform, scaleTransForm));
    [self drawQRCode:theCode context:QRCodeImageContext size:size];
                
    CGImageRef QRCGImage = CGBitmapContextCreateImage(QRCodeImageContext);
    _image = [[NSImage alloc] initWithCGImage:QRCGImage size:CGSizeMake(size, size)];
    CGImageRelease(QRCGImage);
    QRcode_free(theCode);
    
}

- (void)dealloc
{
    _image = nil;
}

@end
