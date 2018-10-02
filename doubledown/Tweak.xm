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

%group tweak
%hook SBIconController

/* iOS 7 - 11.1.2 */
-(NSUInteger)maxIconCountForDock {
	return (maxCount = %orig);
}

%end

%hook SBDockIconListView

/* iOS 4 - 11.1.2 */
+(NSUInteger)iconRowsForInterfaceOrientation:(long long)arg1 {
	return 2;
}

/* iOS 4 - 11.1.2 */
-(NSUInteger)iconsInRowForSpacingCalculation {	
	return maxCount/2;
}

/* iOS 7 - 11.1.2 */
+(double)defaultHeight {
	defaultHeight = defaultHeight ?: defaultHeight = %orig;
	return defaultHeight*2;
}

/* iOS 7 - 11.1.2 */
-(CGPoint)originForIconAtCoordinate:(struct SBIconCoordinate)arg1 {
	CGPoint orig = %orig;
	if (arg1.row == 2)
		return CGPointMake(orig.x, orig.y + [%c(SBIconView) defaultIconSize].height);
	return orig;
}

%end

%hook SBDockView

/* iOS 7 - 11.1.2 */
+(double)defaultHeight {
	return defaultHeight*2;
}

%end
%end

static void reloadPrefs() {
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tonyk7.doubledown.plist"];
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
	if (isEnabled)
		%init(tweak);
}
