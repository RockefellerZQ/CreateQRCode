//
//  ZQRandomString.m
//  CreateQRCode
//
//  Created by Little Treasure on 8/8/13.
//  Copyright (c) 2013 Little_Treasure. All rights reserved.
//

#import "ZQRandomString.h"

@implementation ZQRandomString
{
    NSArray *colors;
    NSArray *letterArray;
    NSArray *fontSizes;
    NSDateFormatter *formatter;
}

- (id)init
{
    self = [super init];
    if (self) {
        colors = @[[NSColor blackColor], [NSColor darkGrayColor], [NSColor lightGrayColor], [NSColor whiteColor], [NSColor grayColor], [NSColor redColor], [NSColor greenColor], [NSColor blueColor], [NSColor cyanColor], [NSColor yellowColor], [NSColor magentaColor], [NSColor orangeColor], [NSColor purpleColor], [NSColor brownColor], [NSColor clearColor]];
        
        NSString *string = @"0,1,2,3,4,5,6,7,8,9,Z,X,C,V,B,N,M,A,S,D,F,G,H,J,K,L,Q,W,E,R,T,Y,U,I,O,P,z,x,c,v,b,n,m,a,s,d,f,g,h,j,k,l,q,w,e,r,t,y,u,i,p";
        
        letterArray = [string componentsSeparatedByString:@","];
        fontSizes = @[@13, @14, @15, @16, @12, @11];
    }
    return self;
}

- (NSAttributedString *)attributedStringWithLength:(int)length
{
    NSMutableAttributedString *result = [NSMutableAttributedString new];
    for (int i = 0; i<length; i++) {
        NSString *aChar = [letterArray objectAtIndex:[self numberWithRandom:(int)[letterArray count]]];
        NSColor *randomColor = [colors objectAtIndex:[self numberWithRandom:(int)[colors count]]];
        float randomFontSize = [[fontSizes objectAtIndex:[self numberWithRandom:(int)[fontSizes count]]] floatValue];
        
        NSAttributedString *tempString = [[NSAttributedString alloc] initWithString:aChar attributes:@{NSForegroundColorAttributeName:randomColor, NSFontAttributeName:[NSFont systemFontOfSize:randomFontSize]}];
        [result appendAttributedString:tempString];
        tempString = nil;
        aChar = nil;
        randomColor = nil;
    }
    NSAttributedString *attrString = [result copy];
    result = nil;
    return attrString;
}

- (int)numberWithRandom:(int)range
{
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYYMMddHHmmssSSSS"];
    }
    long date = [[formatter stringFromDate:[NSDate date]] longLongValue];
    
    srand((unsigned)date);
    int i = random() % range;
//    NSLog(@"%i", i);
    [NSThread sleepForTimeInterval:1/100];
    return i;
}

- (void)dealloc
{
    colors = nil;
    letterArray = nil;
    fontSizes = nil;
    formatter = nil;
}

@end
