//
//  ZIKRouteConfigurationPrivate.h
//  ZIKRouter
//
//  Created by zuik on 2017/10/26.
//  Copyright © 2017 zuik. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "ZIKRouteConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@class ZIKRoute;
@interface ZIKPerformRouteConfiguration()
@property (nonatomic, strong, nullable) ZIKRoute *route;
@property (nonatomic, strong, nullable) ZIKPerformRouteConfiguration *injected;
@end

@interface ZIKRemoveRouteConfiguration()
@property (nonatomic, strong, nullable) ZIKRemoveRouteConfiguration *injected;
@end

NS_ASSUME_NONNULL_END
