#define kIsEnabled @"enabled"

@interface SBIconView : UIView
+(CGSize)defaultIconSize; /* iOS 5 - 11.1.2 */
@end

typedef struct SBIconCoordinate {
	long long row;
	long long col;
} SBIconCoordinate;


static double defaultHeight; 
static unsigned long long maxCount;
static BOOL isEnabled;


%hook SBIconController

/* iOS 7 - 11.1.2 */
-(unsigned long long)maxIconCountForDock {
	return isEnabled ? (maxCount = %orig) : %orig;
}

%end

%hook SBDockIconListView

/* iOS 4 - 11.1.2 */
+(unsigned long long)iconRowsForInterfaceOrientation:(long long)arg1 {
	return isEnabled ? 2 : %orig;
}

/* iOS 4 - 11.1.2 */
-(unsigned long long)iconsInRowForSpacingCalculation {	
	return isEnabled ? maxCount/2 : %orig;
}

/* iOS 7 - 11.1.2 */
+(double)defaultHeight {
	defaultHeight = defaultHeight ?: defaultHeight = %orig;
	return isEnabled ? defaultHeight*2 : %orig;
}

/* iOS 7 - 11.1.2 */
-(CGPoint)originForIconAtCoordinate:(struct SBIconCoordinate)arg1 {
	CGPoint orig = %orig;
	if (arg1.row == 2 && isEnabled)
		return CGPointMake(orig.x, orig.y + [%c(SBIconView) defaultIconSize].height);
	return orig;
}

%end

%hook SBDockView

/* iOS 7 - 11.1.2 */
+(double)defaultHeight {
	return isEnabled ? defaultHeight*2 : %orig;
}

%end

static void reloadPrefs() {
	static NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.tonyk7.doubledown"];
	if (prefs)
		isEnabled = [prefs objectForKey:kIsEnabled] ? ((NSNumber *)[prefs objectForKey:kIsEnabled]).boolValue : YES;
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									NULL,
									(CFNotificationCallback)reloadPrefs,
									CFSTR("com.tonyk7.doubledown/prefsChanged"),
									NULL,
									CFNotificationSuspensionBehaviorDeliverImmediately);
	reloadPrefs();
}