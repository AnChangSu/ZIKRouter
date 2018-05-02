//
//  ZIKViewRoute.m
//  ZIKRouter
//
//  Created by zuik on 2018/4/7.
//  Copyright © 2018 zuik. All rights reserved.
//

#import "ZIKViewRoute.h"
#import "ZIKRoutePrivate.h"
#import "ZIKViewRouteRegistry.h"
#import "ZIKViewRouterInternal.h"
#import "ZIKViewRouterPrivate.h"
#import "ZIKRouteConfigurationPrivate.h"
#import "ZIKBlockViewRouter.h"
#import "ZIKBlockCustomViewRouter.h"
#import "ZIKBlockSubviewRouter.h"
#import "ZIKBlockCustomSubviewRouter.h"
#import "ZIKBlockCustomOnlyViewRouter.h"
#import "ZIKBlockAnyViewRouter.h"
#import "ZIKBlockAllViewRouter.h"

@interface ZIKViewRoute()
@property (nonatomic, copy, nullable) BOOL(^destinationFromExternalPreparedBlock)(id destination, ZIKViewRouter *router);
@property (nonatomic, copy, nullable) ZIKBlockViewRouteTypeMask(^makeSupportedRouteTypesBlock)(void);
@property (nonatomic, copy, nullable) BOOL(^canPerformCustomRouteBlock)(ZIKViewRouter *router);
@property (nonatomic, copy, nullable) BOOL(^canRemoveCustomRouteBlock)(ZIKViewRouter *router);
@property (nonatomic, copy, nullable) void(^performCustomRouteBlock)(id destination, _Nullable id source, ZIKViewRouteConfiguration *config, ZIKViewRouter *router);
@property (nonatomic, copy, nullable) void(^removeCustomRouteBlock)(id destination, _Nullable id source, ZIKViewRemoveConfiguration *removeConfig, ZIKViewRouteConfiguration *config, ZIKViewRouter *router);
@end

@implementation ZIKViewRoute
@dynamic registerDestination;
@dynamic registerDestinationProtocol;
@dynamic registerModuleProtocol;
@dynamic makeDefaultConfiguration;
@dynamic makeDefaultRemoveConfiguration;
@dynamic prepareDestination;
@dynamic didFinishPrepareDestination;

- (ZIKViewRoute<id, ZIKViewRouteConfiguration *> *(^)(BOOL(^)(id destination, ZIKViewRouter *router)))destinationFromExternalPrepared {
    return ^(BOOL(^block)(id destination, ZIKViewRouter *router)) {
        self.destinationFromExternalPreparedBlock = block;
        return self;
    };
}

- (ZIKViewRoute<id, ZIKViewRouteConfiguration *> *(^)(ZIKBlockViewRouteTypeMask(^)(void)))makeSupportedRouteTypes {
    return ^(ZIKBlockViewRouteTypeMask(^block)(void)) {
        self.makeSupportedRouteTypesBlock = block;
        return self;
    };
}

- (ZIKViewRoute<id, ZIKViewRouteConfiguration *> *(^)(BOOL(^)(ZIKViewRouter *router)))canPerformCustomRoute {
    return ^(BOOL(^block)(ZIKViewRouter *router)) {
        self.canPerformCustomRouteBlock = block;
        return self;
    };
}

- (ZIKViewRoute<id, ZIKViewRouteConfiguration *> *(^)(BOOL(^)(ZIKViewRouter *router)))canRemoveCustomRoute {
    return ^(BOOL(^block)(ZIKViewRouter *router)) {
        self.canRemoveCustomRouteBlock = block;
        return self;
    };
}

- (ZIKViewRoute<id, ZIKViewRouteConfiguration *> *(^)(void(^)(id destination, _Nullable id source, ZIKViewRouteConfiguration *config, ZIKViewRouter *router)))performCustomRoute {
    return ^(void(^block)(id destination, _Nullable id source, ZIKViewRouteConfiguration *config, ZIKViewRouter *router)) {
        self.performCustomRouteBlock = block;
        return self;
    };
}

- (ZIKViewRoute<id, ZIKViewRouteConfiguration *> *(^)(void(^)(id destination, _Nullable id source, ZIKViewRemoveConfiguration *removeConfig, ZIKViewRouteConfiguration *config, ZIKViewRouter *router)))removeCustomRoute {
    return ^(void(^block)(id destination, _Nullable id source, ZIKViewRemoveConfiguration *removeConfig, ZIKViewRouteConfiguration *config, ZIKViewRouter *router)) {
        self.removeCustomRouteBlock = block;
        return self;
    };
}

- (Class)routerClass {
    if (self.makeSupportedRouteTypesBlock) {
        return [self routerClassForSupportedRouteTypes:self.makeSupportedRouteTypesBlock()];
    }
    return [ZIKBlockViewRouter class];
}

+ (Class)registryClass {
    return [ZIKViewRouteRegistry class];
}

#pragma mark Inject

- (void(^)(ZIKViewRouteConfiguration *config))_injectedConfigBuilder:(void(^)(ZIKViewRouteConfiguration *config))builder {
    return ^(ZIKViewRouteConfiguration *configuration) {
        configuration.route = self;
        ZIKViewRouteConfiguration *injected = [self defaultRouteConfigurationFromBlock];
        if (injected) {
            configuration.injected = injected;
            configuration = injected;
        }
        if (builder) {
            builder(configuration);
        }
    };
}

- (void(^)(ZIKViewRemoveConfiguration *config))_injectedRemoveConfigBuilder:(void(^)(ZIKViewRemoveConfiguration *config))builder {
    return ^(ZIKViewRemoveConfiguration *configuration) {
        ZIKViewRemoveConfiguration *injected = [self defaultRemoveRouteConfigurationFromBlock];
        if (injected) {
            configuration.injected = injected;
            configuration = injected;
        }
        if (builder) {
            builder(configuration);
        }
    };
}

- (void (^)(ZIKViewRouteConfiguration * _Nonnull, void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)),
            void (^ _Nonnull)(void (^ _Nonnull)(ZIKViewRouteConfiguration * _Nonnull))))
_injectedStrictConfigBuilder:
(void (^)(ZIKViewRouteConfiguration * _Nonnull,
          void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)),
          void (^ _Nonnull)(void (^ _Nonnull)(ZIKViewRouteConfiguration * _Nonnull)))
 )builder {
    return ^(ZIKViewRouteConfiguration * _Nonnull configuration,
             void (^ _Nonnull prepareDestination)(void (^ _Nonnull)(id _Nonnull)),
             void (^ _Nonnull prepareModule)(void (^ _Nonnull)(ZIKViewRouteConfiguration * _Nonnull))) {
        configuration.route = self;
        ZIKViewRouteConfiguration *injected = [self defaultRouteConfigurationFromBlock];
        if (injected) {
            configuration.injected = injected;
            configuration = injected;
        }
        if (builder) {
            builder(configuration, prepareDestination, prepareModule);
        }
    };
}

- (void (^)(ZIKViewRemoveConfiguration * _Nonnull,
            void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull))))
_injectedStrictRemoveConfigBuilder:
(void (^)(ZIKViewRemoveConfiguration * _Nonnull,
          void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)))
 )builder {
    return ^(ZIKViewRemoveConfiguration * _Nonnull configuration, void (^ _Nonnull prepareDestination)(void (^ _Nonnull)(id _Nonnull))) {
        ZIKViewRemoveConfiguration *injected = [self defaultRemoveRouteConfigurationFromBlock];
        if (injected) {
            configuration.injected = injected;
            configuration = injected;
        }
        if (builder) {
            builder(configuration, prepareDestination);
        }
    };
}

- (id)performPath:(ZIKViewRoutePath *)path configuring:(void(NS_NOESCAPE ^)(ZIKViewRouteConfiguration *config))configBuilder {
    return [self performPath:path configuring:configBuilder removing:nil];
}

- (id)performPath:(ZIKViewRoutePath *)path {
    return [self performPath:path configuring:^(ZIKViewRouteConfiguration * _Nonnull config) {
        
    } removing:nil];
}

- (id)performPath:(ZIKViewRoutePath *)path
   successHandler:(void(^ _Nullable)(id destination))performerSuccessHandler
     errorHandler:(void(^ _Nullable)(ZIKRouteAction routeAction, NSError *error))performerErrorHandler {
    return [self performPath:path configuring:^(ZIKViewRouteConfiguration * _Nonnull config) {
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

- (id)performPath:(ZIKViewRoutePath *)path completion:(ZIKPerformRouteCompletion)performerCompletion {
    return [self performPath:path successHandler:^(id destination) {
        if (performerCompletion) {
            performerCompletion(YES, destination, ZIKRouteActionPerformRoute, nil);
        }
    } errorHandler:^(ZIKRouteAction routeAction, NSError *error) {
        if (performerCompletion) {
            performerCompletion(NO, nil, routeAction, error);
        }
    }];
}

- (id)performPath:(ZIKViewRoutePath *)path
      configuring:(void(NS_NOESCAPE ^)(ZIKViewRouteConfiguration *config))configBuilder
         removing:(void(NS_NOESCAPE ^ _Nullable)(ZIKViewRemoveConfiguration *config))removeConfigBuilder {
    configBuilder = [self _injectedConfigBuilder:configBuilder];
    removeConfigBuilder = [self _injectedRemoveConfigBuilder:removeConfigBuilder];
    return [[self routerClass] performPath:path configuring:configBuilder removing:removeConfigBuilder];
}

- (id)performPath:(ZIKViewRoutePath *)path
strictConfiguring:(void (^)(ZIKViewRouteConfiguration * _Nonnull,
                            void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)),
                            void (^ _Nonnull)(void (^ _Nonnull)(ZIKViewRouteConfiguration * _Nonnull))
                            ))configBuilder {
    return [self performPath:path strictConfiguring:configBuilder strictRemoving:nil];
}

- (id)performPath:(ZIKViewRoutePath *)path
strictConfiguring:(void (^)(ZIKViewRouteConfiguration * _Nonnull,
                            void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)),
                            void (^ _Nonnull)(void (^ _Nonnull)(ZIKViewRouteConfiguration * _Nonnull))
                            ))configBuilder
   strictRemoving:(void (^)(ZIKViewRemoveConfiguration * _Nonnull,
                            void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull))
                            ))removeConfigBuilder {
    configBuilder = [self _injectedStrictConfigBuilder:configBuilder];
    removeConfigBuilder = [self _injectedStrictRemoveConfigBuilder:removeConfigBuilder];
    return [[self routerClass] performPath:path strictConfiguring:configBuilder strictRemoving:removeConfigBuilder];
}

- (id)performOnDestination:(id)destination
                      path:(ZIKViewRoutePath *)path
               configuring:(void(NS_NOESCAPE ^)(ZIKViewRouteConfiguration *config))configBuilder {
    return [self performOnDestination:destination path:path configuring:configBuilder removing:nil];
}

- (id)performOnDestination:(id)destination
                      path:(ZIKViewRoutePath *)path
               configuring:(void(NS_NOESCAPE ^)(ZIKViewRouteConfiguration *config))configBuilder
                  removing:(void(NS_NOESCAPE ^ _Nullable)(ZIKViewRemoveConfiguration *config))removeConfigBuilder {
    configBuilder = [self _injectedConfigBuilder:configBuilder];
    removeConfigBuilder = [self _injectedRemoveConfigBuilder:removeConfigBuilder];
    return [[self routerClass] performOnDestination:destination path:path configuring:configBuilder removing:removeConfigBuilder];
}

- (id)performOnDestination:(id)destination
                      path:(ZIKViewRoutePath *)path {
    return [self performOnDestination:destination path:path configuring:^(__kindof ZIKViewRouteConfiguration * _Nonnull config) {
        
    } removing:nil];
}

- (id)performOnDestination:(id)destination
                      path:(ZIKViewRoutePath *)path
         strictConfiguring:(void (^)(ZIKViewRouteConfiguration * _Nonnull,
                                     void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)),
                                     void (^ _Nonnull)(void (^ _Nonnull)(ZIKViewRouteConfiguration * _Nonnull))
                                     ))configBuilder {
    return [self performOnDestination:destination path:path strictConfiguring:configBuilder strictRemoving:nil];
}

- (id)performOnDestination:(id)destination
                      path:(ZIKViewRoutePath *)path
         strictConfiguring:(void (^)(ZIKViewRouteConfiguration * _Nonnull,
                                     void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)),
                                     void (^ _Nonnull)(void (^ _Nonnull)(ZIKViewRouteConfiguration * _Nonnull))
                                     ))configBuilder
            strictRemoving:(void (^)(ZIKViewRemoveConfiguration * _Nonnull,
                                     void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull))
                                     ))removeConfigBuilder {
    configBuilder = [self _injectedStrictConfigBuilder:configBuilder];
    removeConfigBuilder = [self _injectedStrictRemoveConfigBuilder:removeConfigBuilder];
    return [[self routerClass] performOnDestination:destination path:path strictConfiguring:configBuilder strictRemoving:removeConfigBuilder];
}

- (id)prepareDestination:(id)destination
             configuring:(void(NS_NOESCAPE ^)(ZIKViewRouteConfiguration *config))configBuilder {
    return [self prepareDestination:destination configuring:configBuilder removing:nil];
}

- (id)prepareDestination:(id)destination
             configuring:(void(NS_NOESCAPE ^)(ZIKViewRouteConfiguration *config))configBuilder
                removing:(void(NS_NOESCAPE ^ _Nullable)(ZIKViewRemoveConfiguration *config))removeConfigBuilder {
    configBuilder = [self _injectedConfigBuilder:configBuilder];
    removeConfigBuilder = [self _injectedRemoveConfigBuilder:removeConfigBuilder];
    return [[self routerClass] prepareDestination:destination configuring:configBuilder removing:removeConfigBuilder];
}

- (id)prepareDestination:(id)destination strictConfiguring:(void (^)(ZIKViewRouteConfiguration * _Nonnull, void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)), void (^ _Nonnull)(void (^ _Nonnull)(ZIKViewRouteConfiguration * _Nonnull))))configBuilder {
    return [self prepareDestination:destination strictConfiguring:configBuilder strictRemoving:nil];
}

- (id)prepareDestination:(id)destination
       strictConfiguring:(void (^)(ZIKViewRouteConfiguration * _Nonnull,
                                   void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)),
                                   void (^ _Nonnull)(void (^ _Nonnull)(ZIKViewRouteConfiguration * _Nonnull))
                                   ))configBuilder
                             strictRemoving:(void (^ _Nullable)(ZIKViewRemoveConfiguration * _Nonnull,
                                                                void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull))
                                                                ))removeConfigBuilder {
    configBuilder = [self _injectedStrictConfigBuilder:configBuilder];
    removeConfigBuilder = [self _injectedStrictRemoveConfigBuilder:removeConfigBuilder];
    return [[self routerClass] prepareDestination:destination strictConfiguring:configBuilder strictRemoving:removeConfigBuilder];
}

- (id)routerFromSegueIdentifier:(NSString *)identifier sender:(nullable id)sender destination:(UIViewController *)destination source:(UIViewController *)source {
    ZIKBlockViewRouter *router = [[self routerClass] routerFromSegueIdentifier:identifier sender:sender destination:destination source:source];
    router.original_configuration.route = self;
    return router;
}
- (id)routerFromView:(UIView *)destination source:(UIView *)source {
    ZIKBlockViewRouter *router = [[self routerClass] routerFromView:destination source:source];
    router.original_configuration.route = self;
    return router;
}

- (nullable ZIKViewRouteConfiguration *)defaultRouteConfigurationFromBlock {
    if (self.makeDefaultConfigurationBlock) {
        ZIKViewRouteConfiguration *config = self.makeDefaultConfigurationBlock();
        config.route = self;
        return config;
    }
    return nil;
}

- (nullable ZIKViewRemoveConfiguration *)defaultRemoveRouteConfigurationFromBlock {
    if (self.makeDefaultRemoveConfigurationBlock) {
        return self.makeDefaultRemoveConfigurationBlock();
    }
    return nil;
}

- (ZIKViewRouteTypeMask)supportedRouteTypes {
    if (self.makeSupportedRouteTypesBlock) {
        return (ZIKViewRouteTypeMask)self.makeSupportedRouteTypesBlock();
    }
    return [[self routerClass] supportedRouteTypes];
}

- (BOOL)supportRouteType:(ZIKViewRouteType)type {
    ZIKViewRouteTypeMask supportedRouteTypes = [self supportedRouteTypes];
    ZIKViewRouteTypeMask mask = 1 << type;
    if ((supportedRouteTypes & mask) == mask) {
        return YES;
    }
    return NO;
}

- (Class)routerClassForSupportedRouteTypes:(ZIKBlockViewRouteTypeMask)supportedTypes {
    switch ((NSInteger)supportedTypes) {
        case ZIKBlockViewRouteTypeMaskUIViewControllerDefault:
            return [ZIKBlockViewRouter class];
            break;
        case ZIKBlockViewRouteTypeMaskUIViewControllerDefault | ZIKBlockViewRouteTypeMaskCustom:
            return [ZIKBlockCustomViewRouter class];
            break;
        case ZIKBlockViewRouteTypeMaskUIViewDefault:
            return [ZIKBlockSubviewRouter class];
            break;
        case ZIKBlockViewRouteTypeMaskUIViewDefault | ZIKBlockViewRouteTypeMaskCustom:
            return [ZIKBlockCustomSubviewRouter class];
            break;
        case ZIKBlockViewRouteTypeMaskCustom:
            return [ZIKBlockCustomOnlyViewRouter class];
            break;
        case ZIKViewRouteTypeMaskUIViewControllerDefault | ZIKViewRouteTypeMaskUIViewDefault:
            return [ZIKBlockAnyViewRouter class];
            break;
        case ZIKBlockViewRouteTypeMaskUIViewControllerDefault | ZIKBlockViewRouteTypeMaskUIViewDefault | ZIKBlockViewRouteTypeMaskCustom:
            return [ZIKBlockAllViewRouter class];
            break;
    }
    return [ZIKBlockViewRouter class];
}

#pragma mark Deprecated

- (id)performFromSource:(nullable id<ZIKViewRouteSource>)source configuring:(void(NS_NOESCAPE ^)(ZIKViewRouteConfiguration *config))configBuilder {
    return [self performFromSource:source configuring:configBuilder removing:nil];
}

- (id)performFromSource:(nullable id)source routeType:(ZIKViewRouteType)routeType {
    ZIKViewRoutePath *path = [[ZIKViewRoutePath alloc] initWithRouteType:routeType source:source];
    return [self performPath:path];
}

- (id)performFromSource:(nullable id<ZIKViewRouteSource>)source
              routeType:(ZIKViewRouteType)routeType
         successHandler:(void(^ _Nullable)(id destination))performerSuccessHandler
           errorHandler:(void(^ _Nullable)(ZIKRouteAction routeAction, NSError *error))performerErrorHandler {
    ZIKViewRoutePath *path = [[ZIKViewRoutePath alloc] initWithRouteType:routeType source:source];
    return [self performPath:path successHandler:performerSuccessHandler errorHandler:performerErrorHandler];
}

- (id)performFromSource:(nullable id<ZIKViewRouteSource>)source routeType:(ZIKViewRouteType)routeType completion:(ZIKPerformRouteCompletion)performerCompletion {
    ZIKViewRoutePath *path = [[ZIKViewRoutePath alloc] initWithRouteType:routeType source:source];
    return [self performPath:path completion:performerCompletion];
}

- (id)performFromSource:(nullable id<ZIKViewRouteSource>)source
            configuring:(void(NS_NOESCAPE ^)(ZIKViewRouteConfiguration *config))configBuilder
               removing:(void(NS_NOESCAPE ^ _Nullable)(ZIKViewRemoveConfiguration *config))removeConfigBuilder {
    configBuilder = [self _injectedConfigBuilder:configBuilder];
    removeConfigBuilder = [self _injectedRemoveConfigBuilder:removeConfigBuilder];
    return [[self routerClass] performFromSource:source configuring:configBuilder removing:removeConfigBuilder];
}

- (id)performFromSource:(id<ZIKViewRouteSource>)source
      strictConfiguring:(void (^)(ZIKViewRouteConfiguration * _Nonnull,
                                  void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)),
                                  void (^ _Nonnull)(void (^ _Nonnull)(ZIKViewRouteConfiguration * _Nonnull))
                                  ))configBuilder {
    return [self performFromSource:source strictConfiguring:configBuilder strictRemoving:nil];
}

- (id)performFromSource:(id<ZIKViewRouteSource>)source
      strictConfiguring:(void (^)(ZIKViewRouteConfiguration * _Nonnull,
                                  void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)),
                                  void (^ _Nonnull)(void (^ _Nonnull)(ZIKViewRouteConfiguration * _Nonnull))
                                  ))configBuilder
         strictRemoving:(void (^)(ZIKViewRemoveConfiguration * _Nonnull,
                                  void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull))
                                  ))removeConfigBuilder {
    configBuilder = [self _injectedStrictConfigBuilder:configBuilder];
    removeConfigBuilder = [self _injectedStrictRemoveConfigBuilder:removeConfigBuilder];
    return [[self routerClass] performFromSource:source strictConfiguring:configBuilder strictRemoving:removeConfigBuilder];
}

- (id)performOnDestination:(id)destination
                fromSource:(nullable id<ZIKViewRouteSource>)source
               configuring:(void(NS_NOESCAPE ^)(ZIKViewRouteConfiguration *config))configBuilder {
    return [self performOnDestination:destination fromSource:source configuring:configBuilder removing:nil];
}

- (id)performOnDestination:(id)destination
                fromSource:(nullable id<ZIKViewRouteSource>)source
               configuring:(void(NS_NOESCAPE ^)(ZIKViewRouteConfiguration *config))configBuilder
                  removing:(void(NS_NOESCAPE ^ _Nullable)(ZIKViewRemoveConfiguration *config))removeConfigBuilder {
    configBuilder = [self _injectedConfigBuilder:configBuilder];
    removeConfigBuilder = [self _injectedRemoveConfigBuilder:removeConfigBuilder];
    return [[self routerClass] performOnDestination:destination fromSource:source configuring:configBuilder removing:removeConfigBuilder];
}

- (id)performOnDestination:(id)destination
                fromSource:(nullable id<ZIKViewRouteSource>)source
                 routeType:(ZIKViewRouteType)routeType {
    ZIKViewRoutePath *path = [[ZIKViewRoutePath alloc] initWithRouteType:routeType source:source];
    return [self performOnDestination:destination path:path];
}

- (id)performOnDestination:(id)destination
                fromSource:(id<ZIKViewRouteSource>)source
         strictConfiguring:(void (^)(ZIKViewRouteConfiguration * _Nonnull,
                                     void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)),
                                     void (^ _Nonnull)(void (^ _Nonnull)(ZIKViewRouteConfiguration * _Nonnull))
                                     ))configBuilder {
    return [self performOnDestination:destination fromSource:source strictConfiguring:configBuilder strictRemoving:nil];
}

- (id)performOnDestination:(id)destination
                fromSource:(id<ZIKViewRouteSource>)source
         strictConfiguring:(void (^)(ZIKViewRouteConfiguration * _Nonnull,
                                     void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull)),
                                     void (^ _Nonnull)(void (^ _Nonnull)(ZIKViewRouteConfiguration * _Nonnull))
                                     ))configBuilder
            strictRemoving:(void (^)(ZIKViewRemoveConfiguration * _Nonnull,
                                     void (^ _Nonnull)(void (^ _Nonnull)(id _Nonnull))
                                     ))removeConfigBuilder {
    configBuilder = [self _injectedStrictConfigBuilder:configBuilder];
    removeConfigBuilder = [self _injectedStrictRemoveConfigBuilder:removeConfigBuilder];
    return [[self routerClass] performOnDestination:destination fromSource:source strictConfiguring:configBuilder strictRemoving:removeConfigBuilder];
}

@end
