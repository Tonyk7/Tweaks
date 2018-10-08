#include <spawn.h>

@interface SBDisplayItem : NSObject
-(NSString *)displayIdentifier;
@end

@interface FBProcessState : NSObject
-(int)visibility;
@end

@interface SBMainSwitcherViewController : UIViewController
+(id)sharedInstanceIfExists;
-(NSArray*)appLayouts;
-(void)_quitAppsRepresentedByAppLayout:(id)arg1 forReason:(long long)arg2;
@end

@interface SBAppLayout : NSObject
@property (nonatomic, copy) NSDictionary *rolesToLayoutItemsMap;
@end

%hook SBApplication
/* iOS 11 - 11.1.2 */
-(void)_updateProcess:(id)arg1 withState:(FBProcessState *)state {
	%orig;
	if ([state visibility] == 1) {
		// Kill snapchat app
		SBMainSwitcherViewController* sbmsvc = [%c(SBMainSwitcherViewController) sharedInstanceIfExists];
		for (SBAppLayout *appLayout in [sbmsvc appLayouts]) {
			SBDisplayItem *displayItem = [appLayout.rolesToLayoutItemsMap allValues][0];
			if ([[displayItem displayIdentifier] isEqualToString:@"com.toyopagroup.picaboo"]) {
				[sbmsvc _quitAppsRepresentedByAppLayout:appLayout forReason:1];
			}
		}
		// Kill daemon "applecamerad"
		pid_t pid;
		int status;
		const char *argv[] = {"killall", "applecamerad", NULL};
		posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)argv, NULL);
		waitpid(pid, &status, WEXITED);
	}
}

%end