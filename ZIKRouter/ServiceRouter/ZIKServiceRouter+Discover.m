//
//  ZIKServiceRouter+Discover.m
//  ZIKRouter
//
//  Created by zuik on 2018/4/8.
//  Copyright © 2018 zuik. All rights reserved.
//

#import "ZIKServiceRouter+Discover.h"
#import "ZIKRouterInternal.h"
#import "ZIKServiceRouteRegistry.h"
#import "ZIKRouteRegistryInternal.h"


ZIKServiceRouterType *_Nullable _ZIKServiceRouterToService(Protocol *serviceProtocol) {
    NSCParameterAssert(serviceProtocol);
    if (!serviceProtocol) {
        [ZIKServiceRouter notifyError_invalidProtocolWithAction:ZIKRouteActionToService errorDescription:@"ZIKServiceRouter.toService() serviceProtocol is nil"];
        NSCAssert1(NO, @"ZIKServiceRouter.toService() serviceProtocol is nil. callStackSymbols: %@",[NSThread callStackSymbols]);
        return nil;
    }
    ZIKRouterType *route = [ZIKServiceRouteRegistry routerToDestination:serviceProtocol];
    if ([route isKindOfClass:[ZIKServiceRouterType class]]) {
        return (ZIKServiceRouterType *)route;
    }
    [ZIKServiceRouter notifyError_invalidProtocolWithAction:ZIKRouteActionToService
                                           errorDescription:@"Didn't find service router for service protocol: %@, this protocol was not registered.",serviceProtocol];
    if (ZIKRouteRegistry.registrationFinished) {
        NSCAssert1(NO, @"Didn't find service router for service protocol: %@, this protocol was not registered.",NSStringFromProtocol(serviceProtocol));
    } else {
        NSCAssert1(NO, @"❌❌❌❌warning: failed to get router for service protocol (%@), because manually registration is not finished yet! If there're modules running before registration is finished, and modules require some routers before you register them, then you should register those required routers earlier.",NSStringFromProtocol(serviceProtocol));
    }
    return nil;
}

ZIKServiceRouterType *_Nullable _ZIKServiceRouterToModule(Protocol *configProtocol) {
    NSCParameterAssert(configProtocol);
    if (!configProtocol) {
        [ZIKServiceRouter notifyError_invalidProtocolWithAction:ZIKRouteActionToServiceModule errorDescription:@"ZIKServiceRouter.toModule() configProtocol is nil"];
        NSCAssert1(NO, @"ZIKServiceRouter.toModule() configProtocol is nil. callStackSymbols: %@",[NSThread callStackSymbols]);
        return nil;
    }
    ZIKRouterType *route = [ZIKServiceRouteRegistry routerToModule:configProtocol];
    if ([route isKindOfClass:[ZIKServiceRouterType class]]) {
        return (ZIKServiceRouterType *)route;
    }
    [ZIKServiceRouter notifyError_invalidProtocolWithAction:ZIKRouteActionToServiceModule
                                           errorDescription:@"Didn't find service router for config protocol: %@, this protocol was not registered.",configProtocol];
    if (ZIKRouteRegistry.registrationFinished) {
        NSCAssert1(NO, @"Didn't find service router for service config protocol: %@, this protocol was not registered.",NSStringFromProtocol(configProtocol));
    } else {
        NSCAssert1(NO, @"❌❌❌❌warning: failed to get router for service config protocol (%@), because manually registration is not finished yet! If there're modules running before registration is finished, and modules require some routers before you register them, then you should register those required routers earlier.",NSStringFromProtocol(configProtocol));
    }
    return nil;
}

@implementation ZIKServiceRouter (Discover)

+ (ZIKDestinationServiceRouterType<id<ZIKServiceRoutable>, ZIKPerformRouteConfiguration *> *(^)(Protocol *))toService {
    return ^(Protocol *serviceProtocol) {
        return (ZIKDestinationServiceRouterType *)_ZIKServiceRouterToService(serviceProtocol);
    };
}

+ (ZIKModuleServiceRouterType<id, id<ZIKServiceModuleRoutable>, ZIKPerformRouteConfiguration *> *(^)(Protocol *))toModule {
    return ^(Protocol *configProtocol) {
        return (ZIKModuleServiceRouterType *)_ZIKServiceRouterToModule(configProtocol);
    };
}

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation ZIKDestinationServiceRouterType
@end

@implementation ZIKModuleServiceRouterType
@end

#pragma clang diagnostic pop
