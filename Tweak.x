%hook SBFWallpaperView
- (bool) _shouldShowTopGradient { return NO; } // For iOS 8.2 and lower

- (bool) _shouldShowBottomGradient { return NO; } // For iOS 8.2 and lower

- (float) contrast { return 0; } // For iOS 8.3 and higher
%end