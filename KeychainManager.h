//
//  KeychainManager.h
//  Common
//
//  Created by Emilien Stremsdoerfer on 01/04/2014.
//  Copyright (c) 2014 Emilien Stremsdoerfer. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEYCHAIN_ID @"com.sunday.app"


@interface KeychainManager : NSObject{
    NSString *bundleSeedId;
}

+ (KeychainManager *)sharedInstance;

- (void)saveValue:(NSString*)value identifier:(NSString*)identifer accessGroup:(NSString*)accessGroup;
- (NSString*)valueWithIdentifer:(NSString*)identifier accessGroup:(NSString*)accessGroup;
- (void)resetAllItems;

@end
