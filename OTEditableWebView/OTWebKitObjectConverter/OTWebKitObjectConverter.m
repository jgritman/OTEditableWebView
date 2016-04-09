//
//  OTWebKitObjectConverter.m
//  OTEditableWebViewDemo
//
//  Created by openthread on 4/9/16.
//  Copyright © 2016 openthread. All rights reserved.
//

#import "OTWebKitObjectConverter.h"

@implementation OTWebKitObjectConverter

+ (double)safeDoubleValueFromObject:(id)object
{
    if ([object respondsToSelector:@selector(doubleValue)])
    {
        return [object doubleValue];
    }
    return 0;
}

+ (id)objectFromJSONString:(NSString *)JSONString
{
    NSError *error = nil;
    id ret = nil;
    @try
    {
        NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
        ret = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingAllowFragments error:&error];
    }
    @catch (NSException *exception)
    {
        return nil;
    }
    
    if (error)
    {
        return nil;
    }
    return ret;
}

+ (NSString *)JSONStringFromObject:(id)object
{
    NSError *error = nil;
    NSData *data = nil;
    @try
    {
        data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    }
    @catch (NSException *exception)
    {
        return nil;
    }
    
    if (error)
    {
        return nil;
    }
    
    NSString *resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return resultString;
}

+ (NSString *)stringFromWebKitReturnedObject:(id)webKitReturnedObject
{
//  webKitReturnedObject can be NSNumber, NSString, NSDate, NSArray, NSDictionary, and NSNull.
    if ([webKitReturnedObject isKindOfClass:[NSNull class]])
    {
        return @"";
    }
    else if ([webKitReturnedObject isKindOfClass:[NSDate class]] ||
             [webKitReturnedObject isKindOfClass:[NSNumber class]])
    {
        return [webKitReturnedObject description];
    }
    else if ([webKitReturnedObject isKindOfClass:[NSString class]])
    {
        return webKitReturnedObject;
    }
    else if ([webKitReturnedObject isKindOfClass:[NSArray class]] ||
             [webKitReturnedObject isKindOfClass:[NSDictionary class]])
    {
        NSString *string = [self JSONStringFromObject:webKitReturnedObject];
        return string;
    }
    return @"";
}

@end
