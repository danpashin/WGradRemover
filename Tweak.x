
@interface NSUserDefaults (UFS_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end


static BOOL enabled = YES;
static NSString *notificationString = @"com.daniilpashin.wgradremover.prefs.changed";



%hook SBFWallpaperView

 // For iOS 8.2 and lower
- (bool) _shouldShowTopGradient {
    if (enabled) return NO;
    return %orig;
}

- (bool) _shouldShowBottomGradient {
    if (enabled) return NO;
    return %orig;
}



 // For iOS 8.3 and higher
- (float) contrast {
    if (enabled) return 0;
    return %orig;
}
%end



static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSNumber *n = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:@"com.daniilpashin.wgradremover"];
    enabled = (n)? [n boolValue]:YES;
}

%ctor {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    notificationCallback(NULL, NULL, NULL, NULL, NULL);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)notificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
    [pool release];
}