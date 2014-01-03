//
//  ZQQRCodeEncode.h
//  CreateQRCode
//
//  Created by Little Treasure on 7/30/13.
//  Copyright (c) 2013 Little_Treasure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZQQRCodeEncode : NSObject <NSTextViewDelegate>

@property (strong) NSImage *image;

// this method is create QRCode image, the QRCode saved in the avariable 'image'

- (void)QRImageWithString:(NSString *)string level:(QRecLevel)aLevel inContext:(CGContextRef)QRCodeImageContext size:(int)size;

@end
