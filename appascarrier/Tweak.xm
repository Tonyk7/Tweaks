@interface SBApplication : NSObject
-(NSString *)displayName;
@end

@interface SBTelephonyManager : NSObject
+(id)sharedTelephonyManager;
-(void)_reallySetOperatorName:(id)arg1; /* iOS 8 - 11.1.2 */
-(id)operatorName;
@end

@interface SBStatusBarStateAggregator : NSObject
+(instancetype)sharedInstance;
-(void)_updateServiceItem;
@end

@interface FBProcessState : NSObject
-(int)visibility;
@end

static NSString *ogCarrier;
static SBTelephonyManager *sbtm;

static void setCarrierText(NSString *text) {
	sbtm = [objc_getClass("SBTelephonyManager") sharedTelephonyManager];
	static dispatch_once_t once;
	dispatch_once(&once, ^ {
		// Save original carrier so we can revert later
		ogCarrier = [sbtm operatorName];
	});
	[sbtm _reallySetOperatorName:text];
}

%hook SBApplication

%group iOS11

/* iOS 11 - 11.1.2 */
-(void)_updateProcess:(id)arg1 withState:(FBProcessState *)state {
	// Left App check
	if ([state visibility] == 1) {
		// Revert changes here
		if (sbtm != nil) {
			[sbtm _reallySetOperatorName:ogCarrier];
		}
	} else {
		// Entering app
		setCarrierText([self displayName]);
	}
	%orig;
}
%end

%group iOS10Lower

/* iOS 7 - 10.2 */
-(void)willActivate {
	%orig;
	setCarrierText([self displayName]);
}

/* iOS 7 - 10.2 */
-(void)didDeactivateForEventsOnly:(BOOL)arg1 {
	if (sbtm != nil) {
		[sbtm _reallySetOperatorName:ogCarrier];
	}
	%orig;
}

%end

%end

%ctor {
	if (kCFCoreFoundationVersionNumber > 1400) {
		%init(iOS11);
	} else {
		%init(iOS10Lower);
	}
	%init;
}