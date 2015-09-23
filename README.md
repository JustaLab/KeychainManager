# KeychainManager

KeychainManager is a simple yet effective Keychain wrapper that allows you to save a string and get it back with its given key.


----------

To save a string:

```objc
[[KeychainManager sharedInstance] saveValue:@"test123" identifier:@"myKey" accessGroup:nil];
```

To get it back:

```objc
[[KeychainManager sharedInstance] valueWithIdentifer:@"myKey" accessGroup:nil];
```
