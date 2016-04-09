//
//  OTWebKitObjectConverter.h
//  OTEditableWebViewDemo
//
//  Created by openthread on 4/9/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTWebKitObjectConverter : NSObject

+ (double)safeDoubleValueFromObject:(id)object;

+ (id)objectFromJSONString:(NSString *)JSONString;

@end
