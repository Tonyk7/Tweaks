#import <objc/runtime.h>
#define kIsEnabled @"enabled"

@interface SBDisplayItem : NSObject
@property (nonatomic, copy, readonly) NSString *displayIdentifier;
@end

static BOOL isEnabled;
static NSMutableArray *blacklist;

%hook SBRecentAppLayouts

-(BOOL)_isDisplayItemRestrictedHiddenOrUnsupported:(SBDisplayItem *)arg1 {
	if (isEnabled && [blacklist containsObject:arg1.displayIdentifier])
		return YES;
	return %orig;
}

%end


static void reloadPrefs() {
	
	/* NSUserDefaults were used here as they provided a more reliable and instant
	 * change of settings. The below method for getting selected apps was used
	 * previously, but changes to settings couldnt be read instantly. This would
	 * cause incorrect behaviour within the tweak.
	 */

	static NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.tonyk7.shadowed"];
	if (prefs)
		isEnabled = [prefs objectForKey:kIsEnabled] ? ((NSNumber *)[prefs objectForKey:kIsEnabled]).boolValue : YES;
	
	/*
	 * Due to https://github.com/rpetrich/AppList relying on a prefix followed by apps name to save
	 * the apps selected. They could not be read for NSUserDefaults as done above. This inspired 
	 * https://github.com/kanesbetas/KBAppList to been made, providing a new way to get user  
	 * selected apps, using an NSArray to get the list of apps 
	 */


	NSDictionary *apps = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.tonyk7.shadowed-applist.plist"];
	blacklist = [[NSMutableArray alloc] init];

	[apps enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		BOOL shouldHideApp = [[apps objectForKey:key] boolValue];
		if (shouldHideApp && [key hasPrefix:@"shadowed-"] && ![blacklist containsObject:key])
			[blacklist addObject:[key stringByReplacingOccurrencesOfString:@"shadowed-" withString:@""]];
	}];
}



%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									NULL,
									(CFNotificationCallback)reloadPrefs,
									CFSTR("com.tonyk7.shadowed/prefsChanged"),
									NULL,
									CFNotificationSuspensionBehaviorDeliverImmediately);
	reloadPrefs();
	%init;
}