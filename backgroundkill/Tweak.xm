#define kIsEnabled @"enabled"

@interface SBDisplayItem : NSObject
@property (nonatomic, copy, readonly) NSString *displayIdentifier;
@end

@interface SBMainSwitcherViewController : UIViewController
+(id)sharedInstanceIfExists;
-(void)_quitAppsRepresentedByAppLayout:(id)arg1 forReason:(long long)arg2;
-(NSArray *)appLayouts;
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
@property (nonatomic, copy) NSDictionary *rolesToLayoutItemsMap;
@end

@interface UIApplication ()
-(SBApplication *)_accessibilityFrontMostApplication;
@end

static NSMutableArray *appsToKill;
static BOOL isEnabled;

%hook SBApplication
/* iOS 11 - 11.1.2 */
-(void)_updateProcess:(id)arg1 withState:(FBProcessState *)state {
	%orig;
	if ([state visibility] == 1 && isEnabled && [appsToKill containsObject:[self bundleIdentifier]] && ![appsToKill containsObject:[[[UIApplication sharedApplication] _accessibilityFrontMostApplication] bundleIdentifier]]) {
		// Kill app that we just existed if that app should be killed
		SBMainSwitcherViewController *sbmsvc = [%c(SBMainSwitcherViewController) sharedInstanceIfExists];
		for (SBAppLayout *appLayout in [sbmsvc appLayouts]) {
			if ([appsToKill containsObject:((SBDisplayItem *)[appLayout.rolesToLayoutItemsMap allValues][0]).displayIdentifier])
				[sbmsvc _quitAppsRepresentedByAppLayout:appLayout forReason:1];
		}
	}
}

%end


// Preferences
static void reloadPrefs() {
	static NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.tonyk7.backgroundkill"];
	if (prefs)
		isEnabled = [prefs objectForKey:kIsEnabled] ? ((NSNumber *)[prefs objectForKey:kIsEnabled]).boolValue : YES;

	// Add all apps that we should kill on exit to a global NSMutableArray
	NSDictionary *apps = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tonyk7.backgroundkill-applist.plist"];
	appsToKill = [[NSMutableArray alloc] init];

	[apps enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		BOOL shouldKillApp = [[apps objectForKey:key] boolValue];
		if (shouldKillApp && [key hasPrefix:@"backgroundkill-"] && ![appsToKill containsObject:key])
			[appsToKill addObject:[key stringByReplacingOccurrencesOfString:@"backgroundkill-" withString:@""]];
	}];
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