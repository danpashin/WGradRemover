//
//  WGradRemover.x
//  WGradRemover
//
//  Created by Daniil Pashin on 22.08.2015
//  Copyright (c) 2015 Daniil Pashin. All rights reserved.
//

@interface SpringBoard : UIApplication
- (void)_relaunchSpringBoardNow;
@end


BOOL enabled = YES;
BOOL enableOverlay = NO;
float backGroundColorValue = 0.75;
float foreGroundColorValue = 0.25;



%hook SBFWallpaperView

//  For iOS 8.2 and lower
- (bool) _shouldShowTopGradient
{
    if (enabled) return NO;
    return %orig;
}

- (bool) _shouldShowBottomGradient
{
    if (enabled) return NO;
    return %orig;
}

//  For iOS 8.3, 8.4, 8.4.1
- (float) contrast
{
    if (enabled) return 0;
    return %orig;
}
%end



//  For iOS 9.0
%hook SBFColorBoxes
- (float) contrast
{
    if (enabled) return 0;
    return %orig;
}
%end


//  Chage status bar colors (black & white)
%hook UIStatusBarNewUIStyleAttributes
- (void) initWithRequest:(id)request backgroundColor:(UIColor *)backColor foregroundColor:(UIColor *)foreColor
{
    if (enabled && enableOverlay) {
        backColor = [UIColor colorWithWhite:backGroundColorValue alpha:0.5];
        foreColor = [UIColor colorWithWhite:foreGroundColorValue alpha:1];
    }

    %orig;
}
%end





static void makeRespring(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    [(SpringBoard *)[UIApplication sharedApplication] _relaunchSpringBoardNow];
}


static void reloadPrefs(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.daniilpashin.wgradremover.plist"];

    enabled = prefs[@"enabled"]?[prefs[@"enabled"] boolValue]:enabled;
    enableOverlay = prefs[@"enableOverlay"]?[prefs[@"enableOverlay"] boolValue]:enableOverlay;
    backGroundColorValue = prefs[@"backGroundColorValue"]?[prefs[@"backGroundColorValue"] floatValue]:backGroundColorValue;
    foreGroundColorValue = prefs[@"foreGroundColorValue"]?[prefs[@"foreGroundColorValue"] floatValue]:foreGroundColorValue;
}


%ctor
{
    reloadPrefs(nil, nil, nil, nil, nil);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), nil, reloadPrefs, CFSTR("com.daniilpashin.wgradremover.prefs.changed"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), nil, makeRespring, CFSTR("com.daniilpashin.wgradremover.respring"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);
}
