// Copyright 2018-present 650 Industries. All rights reserved.

#import <EXNotifications/EXServerRegistrationModule.h>

static NSString * const kEXDeviceInstallationUUIDKey = @"EXDeviceInstallationUUIDKey";
static NSString * const kEXDeviceInstallationUUIDLegacyKey = @"EXDeviceInstallUUIDKey";

static NSString * const kEXRegistrationInfoKey = @"EXNotificationRegistrationInfoKey";

@implementation EXServerRegistrationModule

UM_EXPORT_MODULE(NotificationsServerRegistrationModule)

UM_EXPORT_METHOD_AS(getInstallationIdAsync,
                    getInstallationIdAsyncWithResolver:(UMPromiseResolveBlock)resolve
                                              rejecter:(UMPromiseRejectBlock)reject)
{
  resolve([self getInstallationId]);
}

- (NSString *)getInstallationId
{
  NSString *installationId = [self fetchInstallationId];
  if (installationId) {
    return installationId;
  }
  
  installationId = [[NSUUID UUID] UUIDString];
  [self setInstallationId:installationId error:NULL];
  return installationId;
}

- (nullable NSString *)fetchInstallationId
{
  NSString *installationId;
  CFTypeRef keychainResult = NULL;
  
  if (SecItemCopyMatching((__bridge CFDictionaryRef)[self installationIdGetQuery], &keychainResult) == noErr) {
    NSData *result = (__bridge_transfer NSData *)keychainResult;
    NSString *value = [[NSString alloc] initWithData:result
                                            encoding:NSUTF8StringEncoding];
    // `initWithUUIDString` returns nil if string is not a valid UUID
    if ([[NSUUID alloc] initWithUUIDString:value]) {
      installationId = value;
    }
  }
  
  if (installationId) {
    return installationId;
  }
  
  NSString *legacyUUID = [[NSUserDefaults standardUserDefaults] stringForKey:kEXDeviceInstallationUUIDLegacyKey];
  if (legacyUUID) {
    installationId = legacyUUID;

    NSError *error = nil;
    if ([self setInstallationId:installationId error:&error]) {
      // We only remove the value from old storage once it's set and saved in the new storage.
      [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEXDeviceInstallationUUIDLegacyKey];
    } else {
      NSLog(@"Could not migrate device installation UUID from legacy storage: %@", error.description);
    }
  }
  
  return installationId;
}

- (BOOL)setInstallationId:(NSString *)installationId error:(NSError **)error
{
  // Delete existing UUID so we don't need to handle "duplicate item" error
  SecItemDelete((__bridge CFDictionaryRef)[self installationIdSearchQuery]);
  
  OSStatus status = SecItemAdd((__bridge CFDictionaryRef)[self installationIdSetQuery:installationId], NULL);
  if (status != errSecSuccess && error) {
    *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
  }
  return status == errSecSuccess;
}

# pragma mark - Keychain dictionaries

- (NSDictionary *)installationIdSearchQueryMerging:(NSDictionary *)dictionaryToMerge
{
  NSData *encodedKey = [kEXDeviceInstallationUUIDKey dataUsingEncoding:NSUTF8StringEncoding];
  NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:@{
    (__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
    (__bridge id)kSecAttrService:[NSBundle mainBundle].bundleIdentifier,
    (__bridge id)kSecAttrGeneric:encodedKey,
    (__bridge id)kSecAttrAccount:encodedKey
  }];
  [query addEntriesFromDictionary:dictionaryToMerge];
  return query;
}

- (NSDictionary *)installationIdSearchQuery
{
  return [self installationIdSearchQueryMerging:@{}];
}

- (NSDictionary *)installationIdGetQuery
{
  return [self installationIdSearchQueryMerging:@{
    (__bridge id)kSecMatchLimit:(__bridge id)kSecMatchLimitOne,
    (__bridge id)kSecReturnData:(__bridge id)kCFBooleanTrue
  }];
}

- (NSDictionary *)installationIdSetQuery:(NSString *)deviceInstallationUUID
{
  return [self installationIdSearchQueryMerging:@{
    (__bridge id)kSecValueData:[deviceInstallationUUID dataUsingEncoding:NSUTF8StringEncoding],
    (__bridge id)kSecAttrAccessible:(__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
  }];
}

UM_EXPORT_METHOD_AS(getRegistrationInfoAsync,
                    getRegistrationInfoAsyncWithResolver:(UMPromiseResolveBlock)resolve
                                                rejecter:(UMPromiseRejectBlock)reject)
{
  resolve([[NSUserDefaults standardUserDefaults] stringForKey:kEXRegistrationInfoKey]);
}

UM_EXPORT_METHOD_AS(setRegistrationInfoAsync,
                    setRegistrationInfoAsync:(NSString *)registrationInfo
                                    resolver:(UMPromiseResolveBlock)resolve
                                    rejecter:(UMPromiseRejectBlock)reject)
{
  [[NSUserDefaults standardUserDefaults] setObject:registrationInfo forKey:kEXRegistrationInfoKey];
  resolve(nil);
}

@end
