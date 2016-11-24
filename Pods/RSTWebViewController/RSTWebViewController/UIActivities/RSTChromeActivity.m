//
//  RSTSafariActivity.m
//
//  Created by Riley Testut on 1/11/14.
//  Copyright (c) 2013 Riley Testut. All rights reserved.
//

#import "RSTChromeActivity.h"

NSString *const RSTActivityTypeChrome = @"RSTActivityTypeChrome";

@interface RSTChromeActivity ()

@property (copy, nonatomic) NSURL *url;

@end

@implementation RSTChromeActivity

#pragma mark - UIActivity subclass

- (NSString *)activityType
{
    return RSTActivityTypeChrome;
}

- (NSString *)activityTitle
{
    return NSLocalizedString(@"Chrome", @"");
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"chrome_activity"];
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    id activityItem = [self firstValidActivityItemForActivityItems:activityItems];
    
    return (activityItem != nil);
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    id activityItem = [self firstValidActivityItemForActivityItems:activityItems];
    
    if ([activityItem isKindOfClass:[NSString class]])
    {
        self.url = [NSURL URLWithString:(NSString *)activityItem];
    }
    else
    {
        self.url = activityItem;
    }
}

- (void)performActivity
{
    NSURLComponents *components = [NSURLComponents componentsWithURL:self.url resolvingAgainstBaseURL:NO];
    
    if ([components.scheme.lowercaseString isEqualToString:@"https"])
    {
        components.scheme = @"googlechromes";
    }
    else
    {
        components.scheme = @"googlechrome";
    }
    
    BOOL finished = [[UIApplication sharedApplication] openURL:components.URL];
    
    [self activityDidFinish:finished];
}

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryAction;
}

#pragma mark - Helper Methods

- (id)firstValidActivityItemForActivityItems:(NSArray *)activityItems
{
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"googlechrome://"]])
    {
        return nil;
    }
    
    for (id activityItem in activityItems)
    {
        if ([activityItem isKindOfClass:[NSString class]])
        {
            return activityItem;
        }
        else if ([activityItem isKindOfClass:[NSURL class]])
        {
            return activityItem;
        }
    }
    
    return nil;
}

@end

