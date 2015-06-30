//
//  Partner.h
//  biu
//
//  Created by WuTony on 6/7/15.
//  Copyright (c) 2015 BiuLove. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Partner : NSObject

@property (strong, nonatomic) NSNumber *partnerId;
@property (strong, nonatomic) NSNumber *userId;
@property (assign, nonatomic) NSArray *sexualities;
@property (strong, nonatomic) NSArray *preferZodiacs;
@property (strong, nonatomic) NSNumber *minAge;
@property (strong, nonatomic) NSNumber *maxAge;
@property (strong, nonatomic) NSArray *preferStyles;

- (id)initWithFromUserDefault;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (void)save;

+ (NSString *)getStyleNameFromZodiac:(BLStyleType)style;

@end
