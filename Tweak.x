
@interface NSUserDefaults (UFS_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

@interface SpringBoard : UIApplication
- (void)_relaunchSpringBoardNow;
@end


//  Set default values
static NSString *notificationString = @"com.daniilpashin.wgradremover.prefs.changed";
static NSString *respringString = @"com.daniilpashin.wgradremover.respring";

static bool enabled = YES;
static bool chaneSB = NO;
static float BGValue = 0.75;
static float FGValue = 0.25;



%hook SBFWallpaperView

//  For iOS 8.2 and lower
- (bool) _shouldShowTopGradient {
    if (enabled) return NO;
    return %orig;
}

- (bool) _shouldShowBottomGradient {
    if (enabled) return NO;
    return %orig;
}



//  For iOS 8.3, 8.4, 8.4.1
- (float) contrast {
    if (enabled) return 0;
    return %orig;
}
%end



//  For iOS 9.0
//  Thanks sinfool for this method
%hook SBFColorBoxes

- (float) contrast {
    if (enabled) return 0;
    return %orig;
}
%end


//  Chage status bar colors (black & white)
%hook UIStatusBarNewUIStyleAttributes
- (void) initWithRequest:(id)request backgroundColor:(id)background foregroundColor:(id)foreground {

    if (enabled && chaneSB) {
        background = [UIColor colorWithRed:BGValue green:BGValue blue:BGValue alpha:0.5];
        foreground = [UIColor colorWithRed:FGValue green:FGValue blue:FGValue alpha:1];
    } else { %orig; }

    %orig;
}
%end





static void respring(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [(SpringBoard *)[UIApplication sharedApplication] _relaunchSpringBoardNow];
}


static void getValues(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {

//  Get values
    NSNumber *eV = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:@"com.daniilpashin.wgradremover"];
    NSNumber *cSB = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"chaneSB" inDomain:@"com.daniilpashin.wgradremover"];
    NSNumber *FG = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"BGValue" inDomain:@"com.daniilpashin.wgradremover"];
    NSNumber *BG = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"FGValue" inDomain:@"com.daniilpashin.wgradremover"];

    enabled = (eV)? [eV boolValue]:YES;
    chaneSB = (cSB)? [cSB boolValue]:NO;
    BGValue = (FG)? [FG floatValue]:0.75;
    FGValue = (BG)? [BG floatValue]:0.25;
}

%ctor {
//    Register tweak for receiving notifications
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    getValues(NULL, NULL, NULL, NULL, NULL);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, getValues, (CFStringRef)notificationString, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)respring, (CFStringRef)respringString, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    [pool release];
}