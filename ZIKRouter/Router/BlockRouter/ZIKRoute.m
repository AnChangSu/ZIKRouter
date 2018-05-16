//
//  ZIKRoute.m
//  ZIKRouter
//
//  Created by zuik on 2018/4/7.
//  Copyright © 2018 zuik. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "ZIKRoute.h"
#import "ZIKRouterInternal.h"
#import "ZIKRouteConfiguration.h"
#import "ZIKRouteRegistryInternal.h"
#import "ZIKRouteConfigurationPrivate.h"

@interface ZIKRoute()
@property (nonatomic, strong) ZIKRoute *retainedSelf;
@property (nonatomic, strong) Class destinationClass;
@property (nonatomic, copy) _Nullable id(^makeDestinationBlock)(ZIKPerformRouteConfiguration *config, ZIKRouter *router);
@property (nonatomic, copy, nullable) ZIKPerformRouteConfiguration *(^makeDefaultConfigurationBlock)(void);
@property (nonatomic, copy, nullable) ZIKRemoveRouteConfiguration *(^makeDefaultRemoveConfigurationBlock)(void);
@property (nonatomic, copy, nullable) void(^prepareDestinationBlock)(id destination, ZIKPerformRouteConfiguration *config, ZIKRouter *router);
@property (nonatomic, copy, nullable) void(^didFinishPrepareDestinationBlock)(id destination, ZIKPerformRouteConfiguration *config, ZIKRouter *router);
@end

@implementation ZIKRoute

- (instancetype)initWithDestination:(Class)destinationClass makeDestination:(id  _Nullable (^)(ZIKPerformRouteConfiguration * _Nonnull, __kindof ZIKRouter<id, ZIKPerformRouteConfiguration *, ZIKRemoveRouteConfiguration *> * _Nonnull))makeDestination {
    if (self = [super init]) {
        self.retainedSelf = self;
        self.makeDestinationBlock = makeDestination;
        self.registerDestination(destinationClass);
    }
    return self;
}

- (instancetype)initWithExclusiveDestination:(Class)destinationClass makeDestination:(id  _Nullable (^)(ZIKPerformRouteConfiguration * _Nonnull, __kindof ZIKRouter<id, ZIKPerformRouteConfiguration *, ZIKRemoveRouteConfiguration *> * _Nonnull))makeDestination {
    if (self = [super init]) {
        self.retainedSelf = self;
        self.makeDestinationBlock = makeDestination;
        self.registerExclusiveDestination(destinationClass);
    }
    return self;
}

- (NSString *)name {
    if (_name == nil) {
        return [NSString stringWithFormat:@"Anonymous route for destination: %@", NSStringFromClass(self.destinationClass)];
    }
    return _name;
}

+ (instancetype)makeRouteWithDestination:(Class)destinationClass makeDestination:(id  _Nullable (^)(ZIKPerformRouteConfiguration * _Nonnull, __kindof ZIKRouter<id, ZIKPerformRouteConfiguration *, ZIKRemoveRouteConfiguration *> * _Nonnull))makeDestination {
    return [[self alloc] initWithDestination:destinationClass makeDestination:makeDestination];
}

+ (instancetype)makeRouteWithExclusiveDestination:(Class)destinationClass makeDestination:(id  _Nullable (^)(ZIKPerformRouteConfiguration * _Nonnull, __kindof ZIKRouter<id, ZIKPerformRouteConfiguration *, ZIKRemoveRouteConfiguration *> * _Nonnull))makeDestination {
    return [[self alloc] initWithExclusiveDestination:destinationClass makeDestination:makeDestination];
}

+ (Class)registryClass {
    return nil;
}

- (ZIKRoute<id, ZIKPerformRouteConfiguration *, ZIKRemoveRouteConfiguration *> *(^)(NSString *))nameAs {
    return ^(NSString *name) {
        self.name = name;
        return self;
    };
};

- (ZIKRoute<id, ZIKPerformRouteConfiguration *, ZIKRemoveRouteConfiguration *> *(^)(Class))registerDestination {
    return ^(Class destinationClass) {
        //register class with route
        [[[self class] registryClass] registerDestination:destinationClass route:self];
        self.destinationClass = destinationClass;
        return self;
    };
};

- (ZIKRoute<id, ZIKPerformRouteConfiguration *, ZIKRemoveRouteConfiguration *> *(^)(Class))registerExclusiveDestination {
    return ^(Class destinationClass) {
        //register class with route
        [[[self class] registryClass] registerExclusiveDestination:destinationClass route:self];
        self.destinationClass = destinationClass;
        return self;
    };
};

- (ZIKRoute<id, ZIKPerformRouteConfiguration *, ZIKRemoveRouteConfiguration *> *(^)(Protocol *))registerDestinationProtocol {
    return ^(Protocol *destinationProtocol) {
        //register destination protocol with route
        [[[self class] registryClass] registerDestinationProtocol:destinationProtocol route:self];
        return self;
    };
};

- (ZIKRoute<id, ZIKPerformRouteConfiguration *, ZIKRemoveRouteConfiguration *> *(^)(NSString *))registerIdentifier {
    return ^(NSString *identifier) {
        [[[self class] registryClass] registerIdentifier: identifier route:self];
        return self;
    };
};

- (ZIKRoute<id, ZIKPerformRouteConfiguration *, ZIKRemoveRouteConfiguration *> *(^)(Protocol *))registerModuleProtocol {
    return ^(Protocol *moduleConfigProtocol) {
        //register module protocol with route
        [[[self class] registryClass] registerModuleProtocol:moduleConfigProtocol route:self];
        return self;
    };
};

- (ZIKRoute<id, ZIKPerformRouteConfiguration *, ZIKRemoveRouteConfiguration *> *(^)(ZIKPerformRouteConfiguration *(^)(void)))makeDefaultConfiguration {
    return ^(ZIKPerformRouteConfiguration *(^block)(void)) {
        self.makeDefaultConfigurationBlock = block;
        return self;
    };
};

- (ZIKRoute<id, ZIKPerformRouteConfiguration *, ZIKRemoveRouteConfiguration *> *(^)(ZIKRemoveRouteConfiguration *(^)(void)))makeDefaultRemoveConfiguration {
    return ^(ZIKRemoveRouteConfiguration *(^block)(void)) {
        self.makeDefaultRemoveConfigurationBlock = block;
        return self;
    };
};

- (ZIKRoute<id, ZIKPerformRouteConfiguration *, ZIKRemoveRouteConfiguration *> *(^)(void(^)(id destination, ZIKPerformRouteConfiguration *config, ZIKRouter *router)))prepareDestination {
    return ^(void(^block)(id destination, ZIKPerformRouteConfiguration *config, ZIKRouter *router)) {
        self.prepareDestinationBlock = block;
        return self;
    };
};

- (ZIKRoute<id, ZIKPerformRouteConfiguration *, ZIKRemoveRouteConfiguration *> *(^)(void(^)(id destination, ZIKPerformRouteConfiguration *config, ZIKRouter *router)))didFinishPrepareDestination {
    return ^(void(^block)(id destination, ZIKPerformRouteConfiguration *config, ZIKRouter *router)) {
        self.didFinishPrepareDestinationBlock = block;
        return self;
    };
};

#pragma mark Inject

// Let route works like class, and inject route to block router

- (Class)routerClass {
    NSAssert(NO, @"Must set router class to forward message");
    return nil;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return [self routerClass];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    return [[self routerClass] respondsToSelector:aSelector];
}

- (instancetype)alloc {
    return self;
}

- (instancetype)allocWithZone:(struct _NSZone *)zone {
    return self;
}

- (id)new {
    return [[self routerClass] new];
}

- (void(^)(ZIKPerformRouteConfiguration *config))_injectedConfigBuilder:(void(^)(ZIKPerformRouteConfiguration *config))builder {
    return ^(ZIKPerformRouteConfiguration *configuration) {
        configuration.route = self;
        ZIKPerformRouteConfiguration *injected = [self defaultRouteConfigurationFromBlock];
        if (injected) {
            configuration.injected = injected;
            configuration = injected;
        }
        if (builder) {
            builder(configuration);
        }
    };
}

- (void(^)(ZIKRemoveRouteConfiguration *config))_injectedRemoveConfigBuilder:(void(^)(ZIKRemoveRouteConfiguration *config))builder {
    return ^(ZIKRemoveRouteConfiguration *configuration) {
        ZIKRemoveRouteConfiguration *injected = [self defaultRemoveRouteConfigurationFromBlock];
        if (injected) {
            configuration.injected = injected;
            configuration = injected;
        }
        if (builder) {
            builder(configuration);
        }
    };
}

- (void (^)(ZIKPerformRouteConfiguration * _Nonnull, void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)),
            void (^ _Nonnull)(void (^ _Nonnull)(ZIKPerformRouteConfiguration * _Nonnull))))
_injectedStrictConfigBuilder:
(void (^)(ZIKPerformRouteConfiguration * _Nonnull,
 void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)),
 void (^ _Nonnull)(void (^ _Nonnull)(ZIKPerformRouteConfiguration * _Nonnull)))
 )builder {
    return ^(ZIKPerformRouteConfiguration * _Nonnull configuration,
             void (^ _Nonnull prepareDestination)(void (^ _Nonnull)(id _Nonnull)),
             void (^ _Nonnull prepareModule)(void (^ _Nonnull)(ZIKPerformRouteConfiguration * _Nonnull))) {
        configuration.route = self;
        ZIKPerformRouteConfiguration *injected = [self defaultRouteConfigurationFromBlock];
        if (injected) {
            configuration.injected = injected;
            configuration = injected;
        }
        if (builder) {
            builder(configuration, prepareDestination, prepareModule);
        }
    };
}

- (void (^)(ZIKRemoveRouteConfiguration * _Nonnull,
            void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull))))
_injectedStrictRemoveConfigBuilder:
(void (^)(ZIKRemoveRouteConfiguration * _Nonnull,
 void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)))
 )builder {
    return ^(ZIKRemoveRouteConfiguration * _Nonnull configuration, void (^ _Nonnull prepareDestination)(void (^ _Nonnull)(id _Nonnull))) {
        ZIKRemoveRouteConfiguration *injected = [self defaultRemoveRouteConfigurationFromBlock];
        if (injected) {
            configuration.injected = injected;
            configuration = injected;
        }
        if (builder) {
            builder(configuration, prepareDestination);
        }
    };
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

- (id)initWithConfiguration:(ZIKPerformRouteConfiguration *)configuration removeConfiguration:(nullable ZIKRemoveRouteConfiguration *)removeConfiguration {
    if (configuration.route == nil) {
        configuration.route = self;
    }
    return [[[self routerClass] alloc] initWithConfiguration:configuration removeConfiguration:removeConfiguration];
}

- (id)initWithConfiguring:(void(^)(ZIKPerformRouteConfiguration *configuration))configBuilder removing:(void(^ _Nullable)(ZIKRemoveRouteConfiguration *configuration))removeConfigBuilder {
    configBuilder = [self _injectedConfigBuilder:configBuilder];
    removeConfigBuilder = [self _injectedRemoveConfigBuilder:removeConfigBuilder];
    return [[[self routerClass] alloc] initWithConfiguring:configBuilder removing:removeConfigBuilder];
}

- (id)initWithStrictConfiguring:(void (^)(ZIKPerformRouteConfiguration * _Nonnull,
                                          void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)),
                                          void (^ _Nonnull)(void (^ _Nonnull)(ZIKPerformRouteConfiguration * _Nonnull))
                                          ))configBuilder
                 strictRemoving:(void (^ _Nullable)(ZIKRemoveRouteConfiguration * _Nonnull,
                                                    void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull))
                                                    ))removeConfigBuilder {
    configBuilder = [self _injectedStrictConfigBuilder:configBuilder];
    removeConfigBuilder = [self _injectedStrictRemoveConfigBuilder:removeConfigBuilder];
    return [[[self routerClass] alloc] initWithStrictConfiguring:configBuilder strictRemoving:removeConfigBuilder];
}

#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

- (id)performRoute {
    return [self performWithConfiguring:^(ZIKPerformRouteConfiguration * _Nonnull configuration) {
        
    } removing:nil];
}

- (id)performWithSuccessHandler:(void(^ _Nullable)(id destination))performerSuccessHandler
                   errorHandler:(void(^ _Nullable)(ZIKRouteAction routeAction, NSError *error))performerErrorHandler {
    return [self performWithConfiguring:^(ZIKPerformRouteConfiguration * _Nonnull config) {
        if (performerSuccessHandler) {
            void(^successHandler)(id) = config.performerSuccessHandler;
            if (successHandler) {
                successHandler = ^(id destination) {
                    successHandler(destination);
                    performerSuccessHandler(destination);
                };
            } else {
                successHandler = performerSuccessHandler;
            }
            config.performerSuccessHandler = successHandler;
        }
        if (performerErrorHandler) {
            void(^errorHandler)(ZIKRouteAction, NSError *) = config.performerErrorHandler;
            if (errorHandler) {
                errorHandler = ^(ZIKRouteAction routeAction, NSError *error) {
                    errorHandler(routeAction, error);
                    performerErrorHandler(routeAction, error);
                };
            } else {
                errorHandler = performerErrorHandler;
            }
            config.performerErrorHandler = errorHandler;
        }
    }];
}

- (id)performWithCompletion:(void(^)(BOOL success, id _Nullable destination, ZIKRouteAction routeAction, NSError *_Nullable error))performerCompletion {
    return [self performWithSuccessHandler:^(id  _Nonnull destination) {
        if (performerCompletion) {
            performerCompletion(YES, destination, ZIKRouteActionPerformRoute, nil);
        }
    } errorHandler:^(ZIKRouteAction  _Nonnull routeAction, NSError * _Nonnull error) {
        if (performerCompletion) {
            performerCompletion(NO, nil, routeAction, error);
        }
    }];
}

- (id)performWithConfiguring:(void(^)(ZIKPerformRouteConfiguration *configuration))configBuilder {
    return [self performWithConfiguring:configBuilder removing:nil];
}

- (id)performWithConfiguring:(void(^)(ZIKPerformRouteConfiguration *configuration))configBuilder removing:(void(^)(ZIKRemoveRouteConfiguration *configuration))removeConfigBuilder {
    configBuilder = [self _injectedConfigBuilder:configBuilder];
    removeConfigBuilder = [self _injectedRemoveConfigBuilder:removeConfigBuilder];
    return [[self routerClass] performWithConfiguring:configBuilder removing:removeConfigBuilder];
}

- (id)performWithStrictConfiguring:(void (^)(ZIKPerformRouteConfiguration * _Nonnull,
                                             void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)),
                                             void (^ _Nonnull)(void (^ _Nonnull)(ZIKPerformRouteConfiguration * _Nonnull))
                                             ))configBuilder {
    return [self performWithStrictConfiguring:configBuilder strictRemoving:nil];
}

- (id)performWithStrictConfiguring:(void (^)(ZIKPerformRouteConfiguration * _Nonnull,
                                             void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)),
                                             void (^ _Nonnull)(void (^ _Nonnull)(ZIKPerformRouteConfiguration * _Nonnull))
                                             ))configBuilder
                    strictRemoving:(void (^)(ZIKRemoveRouteConfiguration * _Nonnull,
                                             void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull))
                                             ))removeConfigBuilder {
    configBuilder = [self _injectedStrictConfigBuilder:configBuilder];
    removeConfigBuilder = [self _injectedStrictRemoveConfigBuilder:removeConfigBuilder];
    return [[self routerClass] performWithStrictConfiguring:configBuilder strictRemoving:removeConfigBuilder];
}

- (id)makeDestinationWithPreparation:(void(^ _Nullable)(id destination))prepare {
    return [self makeDestinationWithConfiguring:^(ZIKPerformRouteConfiguration * _Nonnull config) {
        if (prepare) {
            config.prepareDestination = prepare;
        }
    }];
}

- (id)makeDestinationWithConfiguring:(void(^ _Nullable)(ZIKPerformRouteConfiguration *config))configBuilder {
    configBuilder = [self _injectedConfigBuilder:configBuilder];
    return [[self routerClass] makeDestinationWithConfiguring:configBuilder];
}

- (id)makeDestinationWithStrictConfiguring:(void (^)(ZIKPerformRouteConfiguration * _Nonnull,
                                                     void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)),
                                                     void (^ _Nonnull)(void (^ _Nonnull)(ZIKPerformRouteConfiguration * _Nonnull))
                                                     ))configBuilder {
    configBuilder = [self _injectedStrictConfigBuilder:configBuilder];
    return [[self routerClass] makeDestinationWithStrictConfiguring:configBuilder];
}

- (id)makeDestination {
    return [self makeDestinationWithPreparation:nil];
}

#pragma clang diagnostic pop

- (ZIKPerformRouteConfiguration *)defaultRouteConfiguration {
    ZIKPerformRouteConfiguration *config = [self defaultRouteConfigurationFromBlock];
    if (config) {
        return config;
    }
    config = [[self routerClass] defaultRouteConfiguration];
    config.route = self;
    return config;
}

- (ZIKRemoveRouteConfiguration *)defaultRemoveRouteConfiguration {
    ZIKRemoveRouteConfiguration *config = [self defaultRemoveRouteConfigurationFromBlock];
    if (config) {
        return config;
    }
    return [[self routerClass] defaultRemoveConfiguration];
}

- (nullable ZIKPerformRouteConfiguration *)defaultRouteConfigurationFromBlock {
    if (self.makeDefaultConfigurationBlock) {
        ZIKPerformRouteConfiguration *config = self.makeDefaultConfigurationBlock();
        config.route = self;
        return config;
    }
    return nil;
}

- (nullable ZIKRemoveRouteConfiguration *)defaultRemoveRouteConfigurationFromBlock {
    if (self.makeDefaultRemoveConfigurationBlock) {
        return self.makeDefaultRemoveConfigurationBlock();
    }
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, name: %@",[super description], self.name];
}

@end
