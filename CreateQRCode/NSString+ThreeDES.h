//
//  NSString+Three.h
//  CreateQRCode
//
//  Created by Little Treasure on 8/1/13.
//  Copyright (c) 2013 Little_Treasure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ThreeDES)

// encrypt or decrypt the string you want
+ (NSString *)encryptString:(NSString *)string withKey:(NSString *)key;
+ (NSString *)decryptString:(NSString *)eString withKey:(NSString *)key;
/*
 you can use this method to generate the key, EX:[@"78887766786576" sha1];
 then get the sha1 string to encrypt the "78887766786576"
 */
@end
