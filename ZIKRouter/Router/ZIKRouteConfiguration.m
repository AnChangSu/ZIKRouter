//
//  ZIKRouteConfiguration.m
//  ZIKRouter
//
//  Created by zuik on 2017/10/13.
//  Copyright © 2017 zuik. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "ZIKRouteConfiguration.h"
#import "ZIKRouteConfigurationPrivate.h"
#import <objc/runtime.h>
#import "ZIKRouterRuntime.h"

@interface ZIKRouteConfiguration ()

@end

@implementation ZIKRouteConfiguration

- (instancetype)init {
    if (self = [super init]) {
        NSAssert1(ZIKRouter_classSelfImplementingMethod([self class], @selector(copyWithZone:), false), @"configuration (%@) must override -copyWithZone:, because it will be deep copied when router is initialized. You can use -setPropertiesFromConfiguration: to quickly set properties to copy object in Objective-C.",[self class]);
        
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    ZIKRouteConfiguration *config = [[self class] new];
    config.errorHandler = self.errorHandler;
    config.performerErrorHandler = self.performerErrorHandler;
    config.stateNotifier = self.stateNotifier;
    return config;
}

- (BOOL)setPropertiesFromConfiguration:(ZIKRouteConfiguration *)configuration {
    if ([configuration isKindOfClass:[self class]] == NO) {
        NSAssert2(NO, @"Invalid configuration (%@) to copy property values to %@",[configuration class], [self class]);
        return NO;
    }
    NSMutableArray<NSString *> *keys = [NSMutableArray array];
    Class configClass = [self class];
    while (configClass && configClass != [ZIKRouteConfiguration class]) {
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList(configClass, &count);
        for (int i = 0; i < count; i++) {
            objc_property_t property = properties[i];
            if (property) {
                const char *readonly = property_copyAttributeValue(property, "R");
                if (readonly) {
                    continue;
                }
                const char *propertyName = property_getName(property);
                if (propertyName == NULL) {
                    continue;
                }
                NSString *name = [NSString stringWithUTF8String:propertyName];
                if (name == nil) {
                    continue;
                }
                [keys addObject:name];
            }
        }
        configClass = class_getSuperclass(configClass);
    }
    
    [self setValuesForKeysWithDictionary:[configuration dictionaryWithValuesForKeys:keys]];
    return YES;
}

@end

@interface ZIKPerformRouteConfiguration()
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *userInfo;
@end

@implementation ZIKPerformRouteConfiguration

- (void)setRouteCompletion:(void (^)(id _Nonnull))routeCompletion {
    self.successHandler = routeCompletion;
}

- (void (^)(id _Nonnull))routeCompletion {
    return self.successHandler;
}

- (NSMutableDictionary<NSString *, id> *)userInfo {
    if (_userInfo == nil) {
        _userInfo = [NSMutableDictionary dictionary];
    }
    return _userInfo;
}

- (void)addUserInfoForKey:(NSString *)key object:(id)object {
    if (key == nil) {
        return;
    }
    if (_userInfo == nil) {
        _userInfo = [NSMutableDictionary dictionary];
    }
    _userInfo[key] = object;
}

- (void)addUserInfo:(NSDictionary<NSString *, id> *)userInfo {
    if (userInfo == nil) {
        return;
    }
    if (_userInfo == nil) {
        _userInfo = [NSMutableDictionary dictionary];
    }
    [_userInfo addEntriesFromDictionary:userInfo];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    ZIKPerformRouteConfiguration *config = [super copyWithZone:zone];
    config.prepareDestination = self.prepareDestination;
    config.successHandler = self.successHandler;
    config.completionHandler = self.completionHandler;
    config.performerSuccessHandler = self.performerSuccessHandler;
    config.route = self.route;
    if (_userInfo) {
        config.userInfo = _userInfo;
    }
    return config;
}

@end

@implementation ZIKRemoveRouteConfiguration

- (id)copyWithZone:(nullable NSZone *)zone {
    ZIKRemoveRouteConfiguration *config = [super copyWithZone:zone];
    config.prepareDestination = self.prepareDestination;
    config.successHandler = self.successHandler;
    config.completionHandler = self.completionHandler;
    config.performerSuccessHandler = self.performerSuccessHandler;
    return config;
}

@end

@implementation ZIKPerformRouteStrictConfiguration

- (instancetype)initWithConfiguration:(ZIKPerformRouteConfiguration *)configuration {
    if (self= [super init]) {
        _configuration = configuration;
    }
    return self;
}

- (void(^)(id))prepareDestination {
    return _configuration.prepareDestination;
}

- (void)setPrepareDestination:(void (^)(id _Nonnull))prepareDestination {
    _configuration.prepareDestination = prepareDestination;
}

- (void(^)(id))successHandler {
    return _configuration.successHandler;
}

- (void)setSuccessHandler:(void (^)(id _Nonnull))successHandler {
    _configuration.successHandler = successHandler;
}

- (void(^)(id))performerSuccessHandler {
    return _configuration.performerSuccessHandler;
}

- (void)setPerformerSuccessHandler:(void (^)(id _Nonnull))performerSuccessHandler {
    _configuration.performerSuccessHandler = performerSuccessHandler;
}

- (void(^)(BOOL success, id _Nullable, ZIKRouteAction, NSError *_Nullable))completionHandler {
    return _configuration.completionHandler;
}

- (void)setCompletionHandler:(void (^)(BOOL, id _Nullable, ZIKRouteAction _Nonnull, NSError * _Nullable))completionHandler {
    _configuration.completionHandler = completionHandler;
}

@end

@implementation ZIKRemoveRouteStrictConfiguration

- (instancetype)initWithConfiguration:(ZIKRemoveRouteConfiguration *)configuration {
    if (self= [super init]) {
        _configuration = configuration;
    }
    return self;
}

- (void(^)(id))prepareDestination {
    return _configuration.prepareDestination;
}

- (void)setPrepareDestination:(void (^)(id _Nonnull))prepareDestination {
    _configuration.prepareDestination = prepareDestination;
}
@end
