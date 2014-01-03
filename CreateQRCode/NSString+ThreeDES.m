//
//  NSString+Three.m
//  CreateQRCode
//
//  Created by Little Treasure on 8/1/13.
//  Copyright (c) 2013 Little_Treasure. All rights reserved.
//

#import "NSString+ThreeDES.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "GTMBase64.h"

#define kVinitVec @"0123456789"
#define kSecrectKeyLength 40

@implementation NSString (ThreeDES)

+ (NSString *)encryptString:(NSString *)string withKey:(NSString *)key
{
//    const char *cstr = [key cStringUsingEncoding:NSUTF8StringEncoding];
//    NSData *keyData = [NSData dataWithBytes:cstr length:key.length];
//    
//    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
//    
//    CC_SHA1(keyData.bytes, (uint)keyData.length, digest);
//    
//    uint8_t keyByte[kSecrectKeyLength];
//    for (int i=0; i<16; i++) {
//        keyByte[i] = digest[i];
//    }
//    for (int i=0; i<8; i++) {
//        keyByte[16+i] = digest[i];
//    }
    
    NSString *sha1Key = [key sha1];
    key = nil;
    
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    size_t plainTextBufferSize = [data length];
    const void *vplainText = (const void *)[data bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
//    const void *vkey = (const void *) keyByte;
    const void *vkey = (const void *) [sha1Key UTF8String];
    sha1Key = nil;
    const void *vinitVec = (const void *) [kVinitVec UTF8String];
    
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySize3DES,
                       vinitVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    free((void *)bufferPtr);
    NSString *result = [GTMBase64 stringByEncodingData:myData];
    
    return result;
}

+ (NSString *)decryptString:(NSString *)eString withKey:(NSString *)key
{
//    const char *cstr = [key cStringUsingEncoding:NSUTF8StringEncoding];
//    NSData *data = [NSData dataWithBytes:cstr length:key.length];
//    
//    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
//    
//    CC_SHA1(data.bytes, (uint)data.length, digest);
//    
//    uint8_t keyByte[kSecrectKeyLength];
//    for (int i=0; i<16; i++) {
//        keyByte[i] = digest[i];
//    }
//    for (int i=0; i<8; i++) {
//        keyByte[16+i] = digest[i];
//    }
    
    NSString *sha1Key = [key sha1];
    key = nil;
    
    NSData *encryptData = [GTMBase64 decodeData:[eString dataUsingEncoding:NSUTF8StringEncoding]];
    size_t plainTextBufferSize = [encryptData length];
    const void *vplainText = [encryptData bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
//    const void *vkey = (const void *) keyByte;
    const void *vkey = (const void *) [sha1Key UTF8String];
    sha1Key = nil;
    const void *vinitVec = (const void *) [kVinitVec UTF8String];
    
    ccStatus = CCCrypt(kCCDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySize3DES,
                       vinitVec,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    NSString *result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr
                                                                     length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding];
    free((void *)bufferPtr);
    return result;
}

- (NSString *)sha1
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, (uint)data.length, digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

@end
