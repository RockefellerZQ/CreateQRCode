//
//  ZQQRCodeViewController.h
//  CreateQRCode
//
//  Created by Little Treasure on 7/30/13.
//  Copyright (c) 2013 Little_Treasure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZQQRCodeEncode.h"

@interface ZQQRCodeViewController : NSViewController

@property (weak) IBOutlet NSImageView *imageView;
@property (assign) QRecLevel level;
@property (strong, nonatomic) NSString *EncodeString;
@property (strong) ZQQRCodeEncode *QRCodeEncode;

// the sigleten method
+ (ZQQRCodeViewController *) shareQRCodeController;

// show the QRCode image in this view's imageView
- (void)showQRCodeView;

// create the RQCode through the string
- (NSImage *)createQRCodeImageWithString:(NSString *)string;
@end
