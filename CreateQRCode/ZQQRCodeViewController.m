//
//  ZQQRCodeViewController.m
//  CreateQRCode
//
//  Created by Little Treasure on 7/30/13.
//  Copyright (c) 2013 Little_Treasure. All rights reserved.
//

#import "ZQQRCodeViewController.h"
#import "ZQRandomString.h"

#define DRAWSIZE 320

@interface ZQQRCodeViewController () {
    
    __weak NSTextField *_sizeLabel;
    __weak NSPopUpButton *_upButton;
    __weak NSTextField *_showPixesLabel;
    CGContextRef theContext;
    CGColorSpaceRef theColorSpace;
    ZQRandomString *randomString;
}

@property (weak) IBOutlet NSPopUpButton *upButton;
@property (weak) IBOutlet NSTextField *showPixesLabel;
@property (weak) IBOutlet NSTextField *sizeLabel;
@property (weak) IBOutlet NSTextField *showEnString;
@end

static ZQQRCodeViewController *QRCodeController;

@implementation ZQQRCodeViewController

+ (ZQQRCodeViewController *) shareQRCodeController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        QRCodeController = [[ZQQRCodeViewController alloc] initWithNibName:@"ZQQRCodeViewController" bundle:[NSBundle mainBundle]];
    });
    return QRCodeController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        [_upButton selectItemAtIndex:0];
        _level = 0;
        theColorSpace = CGColorSpaceCreateDeviceRGB();
        randomString = [[ZQRandomString alloc] init];
    }
    return self;
}

- (void)awakeFromNib
{
    if (!_QRCodeEncode) {
        _QRCodeEncode = [[ZQQRCodeEncode alloc] init];
    }
    theContext = [self createImageContextWithColorSpace:theColorSpace size:_showPixesLabel.intValue];
}

- (void)setEncodeString:(NSString *)EncodeString
{
    _EncodeString = EncodeString;
    if (_EncodeString != @"") {
        [_showEnString setAttributedStringValue:[randomString attributedStringWithLength:150]];
    } else {
        [_showEnString setStringValue:@""];
    }
    
}

// change the QRCode level
- (IBAction)selectLevel:(NSPopUpButton *)sender {
    _level = (QRecLevel)sender.indexOfSelectedItem;
    [self showQRCodeView];
}

// change the QRCode size
- (IBAction)selectSize:(NSSlider *)sender {
    [_showPixesLabel setIntegerValue:[sender integerValue]];
    [_sizeLabel setStringValue:[NSString stringWithFormat:@"%@ x %@", _showPixesLabel.stringValue, _showPixesLabel.stringValue]];
    theContext = [self createImageContextWithColorSpace:theColorSpace size:_showPixesLabel.intValue];
    [self showQRCodeView];
}

- (void)showQRCodeView
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSImage *image = [self createQRCodeImageWithString:_EncodeString];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageView setImage:image];
        });
    });
}

- (NSImage *)createQRCodeImageWithString:(NSString *)string
{
    if (!_QRCodeEncode) {
        _QRCodeEncode = [[ZQQRCodeEncode alloc] init];
    }
    if (string) {
        CGContextSaveGState(theContext);
        [_QRCodeEncode QRImageWithString:string level:_level inContext:theContext size:_showPixesLabel.intValue];
        CGContextClearRect(theContext, CGRectMake(0, 0, _showPixesLabel.intValue, _showPixesLabel.intValue));
        CGContextRestoreGState(theContext);
        return _QRCodeEncode.image;
    } else {
        return nil;
    }
}

// when the size changed will redraw the QRcode in the context
- (CGContextRef)createImageContextWithColorSpace:(CGColorSpaceRef)colorSpace size:(int)size
{
    CGContextRelease(theContext);
    return CGBitmapContextCreate(nil, size, size, 8, 4*size, colorSpace, kCGImageAlphaPremultipliedLast);
}

- (void)dealloc
{
    _EncodeString = nil;
    _QRCodeEncode = nil;
    randomString = nil;
}

@end
