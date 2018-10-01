#define kIsEnabled @"enabled"

@interface SBDisplayItem : NSObject
+(id)displayItemWithType:(NSString*)arg1 displayIdentifier:(id)arg2 ;
@end

@interface SBMainSwitcherViewController : UIViewController
+(id)sharedInstanceIfExists;
-(void)_quitAppsRepresentedByAppLayout:(id)arg1 forReason:(long long)arg2;
@end

@interface SBRecentAppLayouts : NSObject
+(id)sharedInstance;
-(id)_legacyAppLayoutForItem:(id)arg1 layoutRole:(long long)arg2;
@end

@interface FBProcessState : NSObject
-(int)visibility;
@end

@interface SBApplication : NSObject
-(NSString *)bundleIdentifier;
@end

@interface SBAppLayout : NSObject
@end

static NSMutableArray *appsToKill;
static BOOL isEnabled;

%hook SBApplication
/* iOS 11 - 11.1.2 */
-(void)_updateProcess:(id)arg1 withState:(FBProcessState *)state {
	%orig;
	if ([state visibility] == 1 && isEnabled && [appsToKill containsObject:[self bundleIdentifier]]) {
		// Kill app that we just existed if that app should be killed
		SBMainSwitcherViewController *sbmsvc = [%c(SBMainSwitcherViewController) sharedInstanceIfExists];
		SBDisplayItem *item = [objc_getClass("SBDisplayItem") displayItemWithType:@"App" displayIdentifier:[self bundleIdentifier]];
		// get SBAppLayout from SBDisplayItem
		SBAppLayout *appLayout = [[objc_getClass("SBRecentAppLayouts") sharedInstance] _legacyAppLayoutForItem:item layoutRole:1];
		if (appLayout)
			[sbmsvc _quitAppsRepresentedByAppLayout:appLayout forReason:1];
	}
}

%end

// Preferences
static void reloadPrefs() {
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tonyk7.backgroundkill.plist"];
	if (prefs)
		isEnabled = [prefs objectForKey:kIsEnabled] ? ((NSNumber *)[prefs objectForKey:kIsEnabled]).boolValue : YES;

	// Add all apps that we should kill on exit to a global NSMutableArray
	NSDictionary *apps = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tonyk7.backgroundkill-applist.plist"];
	appsToKill = [[NSMutableArray alloc] init];
	for (NSString *key in apps) {
		BOOL shouldKillApp = [[apps objectForKey:key] boolValue];
		if (shouldKillApp && ![appsToKill containsObject:key]) {
			[appsToKill addObject:key];
		}
	}
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									NULL,
									(CFNotificationCallback)reloadPrefs,
									CFSTR("com.tonyk7.backgroundkill/prefsChanged"),
									NULL,
									CFNotificationSuspensionBehaviorDeliverImmediately);
	reloadPrefs();

	%init;
}