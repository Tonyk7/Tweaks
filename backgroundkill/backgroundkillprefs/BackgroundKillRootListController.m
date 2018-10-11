#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSwitchTableCell.h>
#include "BackgroundKillRootListController.h"

#define application [UIApplication sharedApplication]

@protocol PreferencesTableCustomView
- (id)initWithSpecifier:(id)arg1;

@optional
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1;
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 inTableView:(id)arg2;
@end

@interface PSTableCell ()
- (id)initWithStyle:(int)style reuseIdentifier:(id)arg2;
@end

@interface PSListController ()
-(void)clearCache;
-(void)reload;
-(void)viewWillAppear:(BOOL)animated;
@end

@interface UIApplication (BackgroundKill)
-(void)openURL:(id)arg1 options:(id)arg2 completionHandler:(id)arg3 ;
@end

@interface BackgroundKillTitleCell : PSTableCell <PreferencesTableCustomView> {
	UILabel *tweakTitle;
	UILabel *tweakSubtitle;
}

@end

@implementation BackgroundKillTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)reuseIdentifier specifier:(id)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {

		int width = self.contentView.bounds.size.width;

		CGRect frame = CGRectMake(0, 20, width, 60);
		CGRect subtitleFrame = CGRectMake(0, 62, width, 60);

		tweakTitle = [[UILabel alloc] initWithFrame:frame];
		[tweakTitle setNumberOfLines:1];
		[tweakTitle setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48]];
		[tweakTitle setText:@"Background Kill"];
		[tweakTitle setBackgroundColor:[UIColor clearColor]];
		[tweakTitle setTextColor:[UIColor colorWithRed:34/255.0f green:47/255.0f blue:62/255.0f alpha:1.0f]];
		[tweakTitle setTextAlignment:NSTextAlignmentCenter];
		tweakTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		tweakTitle.contentMode = UIViewContentModeScaleToFill;

		tweakSubtitle = [[UILabel alloc] initWithFrame:subtitleFrame];
		[tweakSubtitle setNumberOfLines:1];
		[tweakSubtitle setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:18]];
		[tweakSubtitle setText:@"By: Tonyk7"];
		[tweakSubtitle setBackgroundColor:[UIColor clearColor]];
		[tweakSubtitle setTextColor:[UIColor colorWithRed:119/255.0f green:119/255.0f blue:122/255.0f alpha:1.0f]];
		[tweakSubtitle setTextAlignment:NSTextAlignmentCenter];
		tweakSubtitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		tweakSubtitle.contentMode = UIViewContentModeScaleToFill;

		[self addSubview:tweakTitle];
		[self addSubview:tweakSubtitle];
	}

	return self;
}

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
	return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BackgroundKillTitleCell" specifier:specifier];
}

- (void)setFrame:(CGRect)frame {
	frame.origin.x = 0;
	[super setFrame:frame];
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1{
	return 125.0f;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width inTableView:(id)tableView {
	return [self preferredHeightForWidth:width];
}

@end

@interface DarkSwitchCell : PSSwitchTableCell
@end

@implementation DarkSwitchCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)reuseIdentifier specifier:(id)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
	if (self) {
		[((UISwitch *)[self control]) setOnTintColor:[UIColor grayColor]];
	}
	return self;
}

@end

@implementation BackgroundKillRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}
	return _specifiers;
}

-(void)twitterButton {
	if ([application canOpenURL:[NSURL URLWithString:@"twitter://"]])
		[application openURL:[NSURL URLWithString:@"twitter://user?screen_name=tonyk766"] options:@{} completionHandler:nil];
	else	
		[application openURL:[NSURL URLWithString:@"https://twitter.com/tonyk766"] options:@{} completionHandler:nil];

}

-(void)paypalButton {
	[application openURL:[NSURL URLWithString:@"https://paypal.me/tonyk7"] options:@{} completionHandler:nil];
}

-(void)githubButton {
	[application openURL:[NSURL URLWithString:@"https://github.com/Tonyk7/Tweaks/tree/master/backgroundkill"] options:@{} completionHandler:nil];
}




- (void)viewWillAppear:(BOOL)animated {
	[self clearCache];
	[self reload];  
	[super viewWillAppear:animated];
}

@end
