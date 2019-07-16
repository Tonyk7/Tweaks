@interface UIStatusBarBatteryPercentItemView : UIView
@end


%hook UIStatusBarBatteryPercentItemView

-(id)contentsImage {
	NSString *percentString = [self valueForKey:@"_percentString"];
	if (percentString)
		MSHookIvar<NSString *>(self, "_percentString") = [percentString stringByReplacingOccurrencesOfString:@"%" withString:@""];
	return %orig;
}

%end