//
//  BLFontDefinition.h
//  biu
//
//  Created by WuTony on 5/27/15.
//  Copyright (c) 2015 BiuLove. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLFontDefinition : NSObject

+ (UIFont *)ultraLightFont:(CGFloat)fontSize;
+ (UIFont *)ultraLightItalic:(CGFloat)fontSize;
+ (UIFont *)lightFont:(CGFloat)fontSize;
+ (UIFont *)lightItalicFont:(CGFloat)fontSize;
+ (UIFont *)normalFont:(CGFloat)fontSize;
+ (UIFont *)italicFont:(CGFloat)fontSize;
+ (UIFont *)boldFont:(CGFloat)fontSize;

+ (CGSize)normalFontSizeForString:(NSString *)string fontSize:(CGFloat)fontSize;

@end
