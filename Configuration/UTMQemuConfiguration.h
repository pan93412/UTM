//
// Copyright © 2019 osy. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import "UTMConfigurable.h"

NS_ASSUME_NONNULL_BEGIN

@interface UTMQemuConfiguration : NSObject<NSCopying, UTMConfigurable>

@property (nonatomic, weak, readonly) NSDictionary *dictRepresentation;
@property (nonatomic, nullable, copy) NSNumber *version;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, nullable, copy) NSURL *existingPath;
@property (nonatomic, nullable, copy) NSURL *selectedCustomIconPath;


@property (nonatomic, readonly) NSURL *terminalInputOutputURL;
@property (nonatomic, readonly) NSURL *spiceSocketURL;

- (void)migrateConfigurationIfNecessary;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary name:(NSString *)name path:(NSURL *)path NS_DESIGNATED_INITIALIZER;

- (void)resetDefaults;
- (BOOL)reloadConfigurationWithDictionary:(NSDictionary *)dictionary name:(NSString *)name path:(NSURL *)path;

@end

NS_ASSUME_NONNULL_END
