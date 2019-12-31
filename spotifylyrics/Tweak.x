#import <CommonCrypto/CommonDigest.h>
#include <objc/runtime.h>

#define kLyricViewTag 420420
#define tmpLyricDir [NSTemporaryDirectory() stringByAppendingString:@"/SpotifyLyrics/"]

@interface SPTPlayerTrack : NSObject
@property(readonly, nonatomic) NSString *trackTitle;
@property(readonly, nonatomic) NSString *artistTitle;
@property(readonly, nonatomic) NSString *albumTitle;
@end

@interface SPTNowPlayingModel : NSObject
@property(readonly, nonatomic) SPTPlayerTrack *displayedMetadata;
@end

@interface SPTNowPlayingContentLayerViewModel : NSObject
@property(readonly, nonatomic) SPTNowPlayingModel *nowPlayingModel;
@end

@interface SPTNowPlayingCoverArtImageView : UIImageView
@end

@interface SPTNowPlayingContentLayerViewController : UIViewController
@property(readonly, nonatomic) SPTNowPlayingContentLayerViewModel *viewModel;
@property(retain, nonatomic) SPTNowPlayingCoverArtImageView *imageView;
@end

@interface SPTNowPlayingCoverArtCell : UICollectionViewCell
@property(retain, nonatomic) SPTNowPlayingCoverArtImageView *imageView;
@end

@interface SpotifyLyrics : NSObject
+(instancetype)sharedInstance;
-(void)toggleLyricView:(SPTNowPlayingCoverArtImageView *)coverView forSongTitle:(NSString *)title byArtist:(NSString *)artist inAlbum:(NSString *)album;
@property(retain, nonatomic) UITextView *lyricsTextView;
@end

@interface NSString (sha1)
-(NSString *)sha1;
@end

@implementation NSString (sha1)
// https://stackoverflow.com/a/7571583
-(NSString *)sha1 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}
@end

@implementation SpotifyLyrics

+(instancetype)sharedInstance {
	static SpotifyLyrics *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[SpotifyLyrics alloc] init];
	});
	return sharedInstance;
}

-(void)updateLyricsTextViewWithText:(NSString *)text {
	dispatch_async(dispatch_get_main_queue(), ^(){
		self.lyricsTextView.text = text;
	});
}

-(void)updateLyricsWithTrackTitle:(NSString *)title artist:(NSString *)artist album:(NSString *)album {
	if (!title || !artist || !album) {
		[self updateLyricsTextViewWithText:@"failed"];
		return;
	}
	NSString *formattedName = [NSString stringWithFormat:@"%@-%@", artist, title];
	NSString *tmpLyricFilePath = [tmpLyricDir stringByAppendingString:[formattedName sha1]];
	if (!access(tmpLyricFilePath.UTF8String, F_OK)) {
		NSString *lyrics = [NSString stringWithContentsOfFile:tmpLyricFilePath encoding:NSUTF8StringEncoding error:nil];
		[self updateLyricsTextViewWithText:lyrics ?: @"failed"];
	} else {
		NSString *url = [[NSString stringWithFormat:@"https://apic.musixmatch.com/ws/1.1/macro.subtitles.get?app_id=mac-ios-v2.0&usertoken=1806241a800384d1588f4bde531da16e19ac746268a4999ebae016&q_track=%@&q_artist=%@&q_album=%@&format=json&page_size=1", title, artist, album] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		[request setURL:[NSURL URLWithString:url]];
		[request setHTTPMethod:@"GET"];
		[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
			NSString *lyrics = results[@"message"][@"body"][@"macro_calls"][@"track.lyrics.get"][@"message"][@"body"][@"lyrics"][@"lyrics_body"];
			[self updateLyricsTextViewWithText:lyrics ?: @"failed"];
			[lyrics writeToFile:tmpLyricFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
		}] resume];
	}
}

-(void)toggleLyricView:(SPTNowPlayingCoverArtImageView *)coverView forSongTitle:(NSString *)title byArtist:(NSString *)artist inAlbum:(NSString *)album {
	self.lyricsTextView = [coverView.superview viewWithTag:kLyricViewTag];
	if (!self.lyricsTextView) {
		self.lyricsTextView = [[UITextView alloc] initWithFrame:coverView.frame];
		UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeLyricView)];
		singleFingerTap.numberOfTapsRequired = 1; 
		[self.lyricsTextView addGestureRecognizer:singleFingerTap];
		self.lyricsTextView.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.5];
		self.lyricsTextView.textColor = [UIColor whiteColor];
		self.lyricsTextView.editable = NO;
		self.lyricsTextView.font = [UIFont fontWithName:@".SFUIText-Regular" size:14];
		self.lyricsTextView.textAlignment = NSTextAlignmentCenter;
		self.lyricsTextView.text = @"Loading...";
		[self.lyricsTextView setScrollEnabled:YES];
		[self.lyricsTextView setUserInteractionEnabled:YES];
		self.lyricsTextView.tag = kLyricViewTag;
		[coverView.superview addSubview:self.lyricsTextView];
	}
	[self updateLyricsWithTrackTitle:title artist:artist album:album];
}

-(void)removeLyricView {
	UIView *oldView;
	if ((oldView = [[self.lyricsTextView superview] viewWithTag:kLyricViewTag]))
		[oldView removeFromSuperview];
}

@end

/*
why not just hook SPTNowPlayingCoverArtCell and add UITapGestureRecognizer in initWithFrame: and then just get now playing info using MRMediaRemoteGetNowPlayingInfo?
because if you do it that way then open the now playing view for first time since launching app and try fetching lyrics without having pressing play the whole time, MRMediaRemoteGetNowPlayingInfo will return null
*/
%hook SPTNowPlayingContentLayerViewController
%property(retain, nonatomic) SPTNowPlayingCoverArtImageView *imageView;

- (void)collectionView:(id)arg1 willDisplayCell:(id)arg2 forItemAtIndexPath:(id)arg3 {
	%orig;
	if ([arg2 isKindOfClass:objc_getClass("SPTNowPlayingCoverArtCell")]) {
		UITapGestureRecognizer *coverArtTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverArtTapped)];
		coverArtTapRecognizer.numberOfTapsRequired = 1;
		[arg2 addGestureRecognizer:coverArtTapRecognizer];
		self.imageView = ((SPTNowPlayingCoverArtCell *)arg2).imageView;
	}
}

- (void)collectionView:(id)arg1 didEndDisplayingCell:(id)arg2 forItemAtIndexPath:(id)arg3 {
	%orig;
	if ([arg2 isKindOfClass:objc_getClass("SPTNowPlayingCoverArtCell")])
		[[objc_getClass("SpotifyLyrics") sharedInstance] removeLyricView];
}

%new
-(void)coverArtTapped {
	SPTPlayerTrack *track = self.viewModel.nowPlayingModel.displayedMetadata;
	[[objc_getClass("SpotifyLyrics") sharedInstance] toggleLyricView:self.imageView forSongTitle:track.trackTitle byArtist:track.artistTitle inAlbum:track.albumTitle];
}

%end

%ctor {
	if (![[NSFileManager defaultManager] fileExistsAtPath:tmpLyricDir])
		[[NSFileManager defaultManager] createDirectoryAtPath:tmpLyricDir withIntermediateDirectories:NO attributes:nil error:nil];
}