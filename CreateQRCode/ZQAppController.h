//
//  ZQAppController.h
//  CreateQRCode
//
//  Created by Little Treasure on 7/30/13.
//  Copyright (c) 2013 Little_Treasure. All rights reserved.
//

/* ******************************** Little Treasure ********************************** */

// the main use of this application is generate the encryption number
// before encrypted the code like this "LT 600 001 001 001 xxxxxxxx";
/*
 the LT is the prefix indentifier of this code that on behalf of our company.
 The 600 is the product where make it.
 The first 001 is the manufacturer.
 The second 001 is the category of the company's products.
 The third 001 is the product‘s specification
 
 The last 8 numbers is the id that indentifier the product, so you can generate the last 8 numbers,
 you should select the rule way to generate the code. you can input rule number to start.
 
 */

/* ******************************** Little Treasure ********************************** */

// the Security Number generate way
typedef enum {
    randomly,
    rules
} GenerateWay;

typedef enum {
    printer,
    file
} OutputQRCodeWay;

// the QRcode image format
typedef enum {
    PngImage,
    JpegImage
} ImageFormat;

#import <Foundation/Foundation.h>
#import "NSString+ThreeDES.h"

@interface ZQAppController : NSObject

// this view is the ZQQRCodeViewController's view
@property (weak) IBOutlet NSView *codeView;

@end
