//
//  ZIKBlockServiceRouter.m
//  ZIKRouter
//
//  Created by zuik on 2018/4/7.
//  Copyright © 2018 zuik. All rights reserved.
//

#import "ZIKBlockServiceRouter.h"
#import "ZIKRouterPrivate.h"
#import "ZIKRoutePrivate.h"
#import "ZIKServiceRoute.h"
#import "ZIKRouterInternal.h"
#import "ZIKRouteConfigurationPrivate.h"

@implementation ZIKBlockServiceRouter

+ (BOOL)isAbstractRouter {
    return YES;
}

- (ZIKServiceRoute *)route {
    ZIKServiceRoute *route = (ZIKServiceRoute *)self.original_configuration.route;
    NSAssert1(route, @"Can't find ZIKServiceRoute for block router (%@). If you add new class method in ZIKRouter or ZIKServiceRouter to create router, you must check your class method in ZIKRoute or ZIKServiceRoute to inject route to router.",self);
    return route;
}

- (nullable id)destinationWithConfiguration:(ZIKPerformRouteConfiguration *)configuration {
    return self.route.makeDestinationBlock(configuration, self);
}

- (void)prepareDestination:(id)destination configuration:(ZIKPerformRouteConfiguration *)configuration {
    void(^prepareDestinationBlock)(id destination, ZIKPerformRouteConfiguration *config, ZIKRouter *router) = self.route.prepareDestinationBlock;
    if (prepareDestinationBlock) {
        prepareDestinationBlock(destination, configuration, self);
    }
}

- (void)didFinishPrepareDestination:(id)destination configuration:(ZIKPerformRouteConfiguration *)configuration {
    void(^didFinishPrepareDestinationBlock)(id destination, ZIKPerformRouteConfiguration *config, ZIKRouter *router) = self.route.didFinishPrepareDestinationBlock;
    if (didFinishPrepareDestinationBlock) {
        didFinishPrepareDestinationBlock(destination, configuration, self);
    }
}

- (ZIKRemoveRouteConfiguration *)original_removeConfiguration {
    if (_removeConfiguration == nil) {
        ZIKRoute *route = self.original_configuration.route;
        if (route && route.makeDefaultRemoveConfigurationBlock) {
            _removeConfiguration = route.makeDefaultRemoveConfigurationBlock();
        } else {
            _removeConfiguration = [[self class] defaultRemoveConfiguration];
        }
    }
    return _removeConfiguration;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, route: (%@)",[super description], self.route];
}

@end
