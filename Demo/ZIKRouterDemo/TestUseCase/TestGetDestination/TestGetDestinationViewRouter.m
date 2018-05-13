//
//  TestGetDestinationViewRouter.m
//  ZIKRouterDemo
//
//  Created by zuik on 2017/7/5.
//  Copyright © 2017 zuik. All rights reserved.
//

#import "TestGetDestinationViewRouter.h"
#import "TestGetDestinationViewController.h"

@interface TestGetDestinationViewController (TestGetDestinationViewRouter) <ZIKRoutableView>
@end
@implementation TestGetDestinationViewController (TestGetDestinationViewRouter)
@end

@implementation TestGetDestinationViewRouter

+ (void)registerRoutableDestination {
    [self registerView:[TestGetDestinationViewController class]];
    [self registerIdentifier:@"com.zuik.viewController.testGetDestination"];
}

- (id<ZIKRoutableView>)destinationWithConfiguration:(ZIKViewRouteConfiguration *)configuration {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TestGetDestinationViewController *destination = [sb instantiateViewControllerWithIdentifier:@"testGetDestination"];
    NSString *title = @"Test GetDestination";
    if ([configuration.userInfo objectForKey:@"url"]) {
        title = [title stringByAppendingString:@"-fromURL"];
    }
    destination.title = title;
    return destination;
}

@end
