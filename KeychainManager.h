//
//  KeychainManager.h
//  Common
//
//  Created by Emilien Stremsdoerfer on 01/04/2014.
//  Copyright (c) 2014 Emilien Stremsdoerfer. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEYCHAIN_ID @"com.justalab.keychainapp"


@interface KeychainManager : NSObject


/**
* Class method that returns a singleton instance of KeychainManager
*/
+ (KeychainManager *)sharedInstance;


/**
 * Method that allows to save a string couple into the keychain
 *
 * @param value value to save
 * @param identifier key that matches the value
 * @param (optional) access group if you want to share this value accross different apps
 */
- (void)saveValue:(NSString*)value identifier:(NSString*)identifer accessGroup:(NSString*)accessGroup;


/**
 * Method that allows to retrieve a value with a given key from the keychain
 *
 * @param identifier key that matches the value
 * @param (optional) access group if this value is shared accross different apps
 */
- (NSString*)valueWithIdentifer:(NSString*)identifier accessGroup:(NSString*)accessGroup;


/**
 * Method that clears the keychain from any previous value entered from your app
 */
- (void)resetAllItems;

@end
