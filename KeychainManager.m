//
//  KeychainManager.m
//  Common
//
//  Created by Emilien Stremsdoerfer on 01/04/2014.
//  Copyright (c) 2014 Emilien Stremsdoerfer. All rights reserved.
//

#import "KeychainManager.h"

@interface KeychainManager ()

@property(nonatomic) NSString *bundleSeedId;

@end


@implementation KeychainManager

+ (KeychainManager *)sharedInstance{
    static KeychainManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[KeychainManager alloc] init];
    });
    return sharedInstance;
}

-(id)init{
    self = [super init];
    if (self) {
        _bundleSeedId = [KeychainManager getBundleSeedId];
    }
    return self;
}

+ (NSString *)getBundleSeedId {
    
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys: (__bridge id)kSecClassGenericPassword, kSecClass,
                           @"bundleSeedID", kSecAttrAccount,@"", kSecAttrService,(id)kCFBooleanTrue, kSecReturnAttributes,(__bridge id)kSecAttrAccessibleAlways,(__bridge id)kSecAttrAccessible, nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound)
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status != errSecSuccess)
        return nil;
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge id)kSecAttrAccessGroup];
    NSArray *components = [accessGroup componentsSeparatedByString:@"."];
    NSString *bundleSeedID = [[components objectEnumerator] nextObject];
    CFRelease(result);
    return bundleSeedID;
}

- (NSMutableDictionary *)keychainDictionary:(NSString *)identifier accessGroup:(NSString *)accessGroup{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    [dictionary setObject:KEYCHAIN_ID forKey:(__bridge id)kSecAttrService];
    
#if TARGET_IPHONE_SIMULATOR
    //iPhone Simulator does not support keychain groups
#else
    if (accessGroup !=nil && ![accessGroup isEqualToString:@""]) {
        [dictionary setObject:[NSString stringWithFormat:@"%@.%@",self.bundleSeedId,accessGroup] forKey:(__bridge id)kSecAttrAccessGroup];
    }
#endif
    
    return dictionary;
}

- (void)createKeychainItem:(NSDictionary *)item withValue:(NSString*)value{
    NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithDictionary:item];
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    [newItem setObject:data forKey:(__bridge id)kSecValueData];
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)newItem, NULL);
    if (status != noErr) {
        NSLog(@"Error creating keychain item: %@",[self resultCode:status]);
    }
    
    NSAssert(status == noErr, @"Could not create keychain item, error");
}

- (NSData *)getKeychainItem:(NSDictionary*)item{
    NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionaryWithDictionary:item];
    
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [searchDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    CFTypeRef cfResult = nil;
    SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary,&cfResult);
    
    return (cfResult)  ? (__bridge NSData *)cfResult : nil;
}

- (void)updateKeychainItem:(NSDictionary*)item withValue:(NSString *)value{
    NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    [updateDictionary setObject:data forKey:(__bridge id)kSecValueData];
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)item, (__bridge CFDictionaryRef)updateDictionary);
    if (status != noErr) {
        NSLog(@"Error updating keychain: %@",[self resultCode:status]);
    }
    NSAssert(status == noErr, @"Could not update keychain item, error %@",[self resultCode:status]);
    
}

- (void)saveValue:(NSString*)value identifier:(NSString*)identifer accessGroup:(NSString*)accessGroup{
    NSMutableDictionary *keychainItem = [self keychainDictionary:identifer accessGroup:accessGroup];
    if ([self getKeychainItem:keychainItem]==nil) {
        [self createKeychainItem:keychainItem withValue:value];
    }else{
        [self updateKeychainItem:keychainItem withValue:value];
    }
}

- (NSString*)valueWithIdentifer:(NSString*)identifier accessGroup:(NSString*)accessGroup{
    NSData *data = [self getKeychainItem:[self keychainDictionary:identifier accessGroup:accessGroup]];
    return (data!=nil) ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}


- (void)resetAllItems {
    [self deleteAllKeysForSecClass:kSecClassGenericPassword];
    [self deleteAllKeysForSecClass:kSecClassInternetPassword];
    [self deleteAllKeysForSecClass:kSecClassCertificate];
    [self deleteAllKeysForSecClass:kSecClassKey];
    [self deleteAllKeysForSecClass:kSecClassIdentity];
}

- (void)deleteAllKeysForSecClass:(CFTypeRef)secClass {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:(__bridge id)secClass forKey:(__bridge id)kSecClass];
    OSStatus result = SecItemDelete((__bridge CFDictionaryRef) dict);
    NSAssert(result == noErr || result == errSecItemNotFound, @"Error deleting keychain data (%@)", @(result));
}


#pragma mark results code

- (NSString *)resultCode:(OSStatus) status {
    
	switch (status) {
		case 0:
			return @"No error";
		case -4:
			return @"Function or operation not implemented";
		case -50:
			return @"One or more parameters passed to the function were not valid";
		case -108:
			return @"Failed to allocate memory";
		case -25291:
			return @"No trust results are available";
        case -25243:
            return @"Keychain access denied";
		case -25299:
			return @"The item already exists";
		case -25300:
			return @"The item cannot be found";
		case -25308:
			return @"Interaction with the Security Server is not allowed";
		case -26275:
			return @"Unable to decode the provided data";
		default:
			return [NSString stringWithFormat:@"Unknown error: %@",@(status)];
	}
}

@end
