//
//  TestRouteRegistry.m
//  ZIKRouterTests
//
//  Created by zuik on 2018/4/18.
//  Copyright © 2018 zuik. All rights reserved.
//

#import "TestRouteRegistry.h"
#import "TestConfig.h"
#import "AServiceRouter.h"
#import "AServiceInput.h"
#import "AService.h"
#import "AServiceModuleRouter.h"
#import "AServiceModuleInput.h"

#import "AViewRouter.h"
#import "AViewInput.h"
#import "AViewController.h"
#import "AViewModuleInput.h"
#import "AViewModuleRouter.h"

#import "BSubviewRouter.h"
#import "BSubviewInput.h"
#import "BSubview.h"
#import "BSubviewModuleInput.h"
#import "BSubviewModuleRouter.h"
@import ZIKRouter.Internal;

@implementation TestRouteRegistry

#if !AUTO_REGISTER_ROUTERS

+ (void)load {
    ZIKRouteRegistry.autoRegister = NO;
    
    //Service router
    [AServiceRouter registerRoutableDestination];
    {
        ZIKDestinationServiceRoute(id<AServiceInput>) *route;
        route = [ZIKDestinationServiceRoute(id<AServiceInput>)
                 makeRouteWithDestination:[AService class]
                 makeDestination:^id<AServiceInput> _Nullable(ZIKPerformRouteConfig * _Nonnull config, ZIKRouter * _Nonnull router) {
                     if (TestConfig.routeShouldFail) {
                         return nil;
                     }
                     return [[AService alloc] init];
                 }];
        route.name = @"Route for AService<AServiceInput>";
        route
#if TEST_BLOCK_ROUTE
        .registerDestinationProtocol(ZIKRoutableProtocol(AServiceInput))
#endif
        .prepareDestination(^(id<AServiceInput> destination, ZIKPerformRouteConfig *config, ZIKServiceRouter *router) {
            
        })
        .didFinishPrepareDestination(^(id<AServiceInput> destination, ZIKPerformRouteConfig *config, ZIKServiceRouter *router) {
            
        });
    }
    
    //Service module router
    [AServiceModuleRouter registerRoutableDestination];
    {
        ZIKModuleServiceRoute(AServiceModuleInput) *route;
        route = [ZIKModuleServiceRoute(AServiceModuleInput)
                 makeRouteWithDestination:[AService class]
                 makeDestination:^id _Nullable(ZIKPerformRouteConfig<AServiceModuleInput> * _Nonnull config, ZIKRouter * _Nonnull router) {
                     if (TestConfig.routeShouldFail) {
                         return nil;
                     }
                     AService *destination = [[AService alloc] init];
                     destination.title = config.title;
                     return destination;
                 }];
        route.name = @"Route for AServiceModuleInput module (AService)";
        route
#if TEST_BLOCK_ROUTE
        .registerModuleProtocol(ZIKRoutableProtocol(AServiceModuleInput))
#endif
        .makeDefaultConfiguration(^ZIKPerformRouteConfig<AServiceModuleInput> * _Nonnull{
            return [[AServiceModuleConfiguration alloc] init];
        })
        .prepareDestination(^(id<AServiceInput> destination, ZIKPerformRouteConfig *config, ZIKServiceRouter *router) {
            
        })
        .didFinishPrepareDestination(^(id<AServiceInput> destination, ZIKPerformRouteConfig *config, ZIKServiceRouter *router) {
            
        });
    }
    
    //View router
    [AViewRouter registerRoutableDestination];
    {
        ZIKDestinationViewRoute(id<AViewInput>) *route;
        route = [ZIKDestinationViewRoute(id<AViewInput>)
                 makeRouteWithDestination:[AViewController class]
                 makeDestination:^id<AViewInput> _Nullable(ZIKViewRouteConfig * _Nonnull config, ZIKRouter * _Nonnull router) {
                     if (TestConfig.routeShouldFail) {
                         return nil;
                     }
                     return [[AViewController alloc] init];
                 }];
        route.name = @"Route for AViewController<AViewInput>";
        route
#if TEST_BLOCK_ROUTE
        .registerDestinationProtocol(ZIKRoutableProtocol(AViewInput))
#endif
        .prepareDestination(^(id<AViewInput> destination, ZIKViewRouteConfig *config, ZIKViewRouter *router) {
            
        })
        .didFinishPrepareDestination(^(id<AViewInput> destination, ZIKViewRouteConfig *config, ZIKViewRouter *router) {
            
        });
    }
    
    //View module router
    [AViewModuleRouter registerRoutableDestination];
    {
        ZIKModuleViewRoute(AViewModuleInput) *route;
        route = [ZIKModuleViewRoute(AViewModuleInput)
                 makeRouteWithDestination:[AViewController class]
                 makeDestination:^id _Nullable(ZIKViewRouteConfig<AViewModuleInput> * _Nonnull config, ZIKRouter * _Nonnull router) {
                     if (TestConfig.routeShouldFail) {
                         return nil;
                     }
                     AViewController *destination = [[AViewController alloc] init];
                     destination.title = config.title;
                     return destination;
                 }];
        route.name = @"Route for AViewModuleInput module (AViewController)";
        route
#if TEST_BLOCK_ROUTE
        .registerModuleProtocol(ZIKRoutableProtocol(AViewModuleInput))
#endif
        .makeDefaultConfiguration(^ZIKViewRouteConfig<AViewModuleInput> * _Nonnull{
            return [[AViewModuleConfiguration alloc] init];
        })
        .prepareDestination(^(id destination, ZIKViewRouteConfig *config, ZIKViewRouter *router) {
            
        })
        .didFinishPrepareDestination(^(id destination, ZIKViewRouteConfig *config, ZIKViewRouter *router) {
            
        });
    }
    
    //Subview router
    [BSubviewRouter registerRoutableDestination];
    {
        ZIKDestinationViewRoute(id<BSubviewInput>) *route;
        route = [ZIKDestinationViewRoute(id<BSubviewInput>)
                 makeRouteWithDestination:[BSubview class]
                 makeDestination:^id<BSubviewInput> _Nullable(ZIKViewRouteConfig * _Nonnull config, ZIKRouter * _Nonnull router) {
                     if (TestConfig.routeShouldFail) {
                         return nil;
                     }
                     return [[BSubview alloc] init];
                 }];
        route.name = @"Route for BSubview<BSubviewInput>";
        route
#if TEST_BLOCK_ROUTE
        .registerDestinationProtocol(ZIKRoutableProtocol(BSubviewInput))
#endif
        .prepareDestination(^(id<BSubviewInput> destination, ZIKViewRouteConfig *config, ZIKViewRouter *router) {
            
        })
        .didFinishPrepareDestination(^(id<BSubviewInput> destination, ZIKViewRouteConfig *config, ZIKViewRouter *router) {
            
        });
    }
    
    //Subview module router
    [BSubviewModuleRouter registerRoutableDestination];
    {
        ZIKModuleViewRoute(BSubviewModuleInput) *route;
        route = [ZIKModuleViewRoute(BSubviewModuleInput)
                 makeRouteWithDestination:[BSubview class]
                 makeDestination:^id _Nullable(ZIKViewRouteConfig<BSubviewModuleInput> * _Nonnull config, ZIKRouter * _Nonnull router) {
                     if (TestConfig.routeShouldFail) {
                         return nil;
                     }
                     BSubview *destination = [[BSubview alloc] init];
                     destination.title = config.title;
                     return destination;
                 }];
        route.name = @"Route for BSubviewModuleInput module (BSubview)";
        route
#if TEST_BLOCK_ROUTE
        .registerModuleProtocol(ZIKRoutableProtocol(BSubviewModuleInput))
#endif
        .makeDefaultConfiguration(^ZIKViewRouteConfig<BSubviewModuleInput> * _Nonnull{
            return [[BSubviewModuleConfiguration alloc] init];
        })
        .prepareDestination(^(id destination, ZIKViewRouteConfig *config, ZIKViewRouter *router) {
            
        })
        .didFinishPrepareDestination(^(id destination, ZIKViewRouteConfig *config, ZIKViewRouter *router) {
            
        });
    }
    
    [ZIKRouteRegistry notifyRegistrationFinished];
}

#endif

@end
