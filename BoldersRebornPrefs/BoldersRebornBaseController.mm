#import <UIKit/UIKit.h>
#import <spawn.h>
#import <rootless.h>
#import <Preferences/PSSpecifier.h>
#import "BoldersRebornBaseController.h"
#import "TintColors.h"

@implementation BoldersRebornBaseController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self _initTopMenu];
}

- (void)localizeSpecifiers {
	NSString *genericPath = ROOT_PATH_NS(@"/Library/PreferenceBundles/BoldersRebornPrefs.bundle/Localization/LANG.lproj/Localization.strings");
	NSString *filePath = [genericPath stringByReplacingOccurrencesOfString:@"LANG" withString:NSLocale.currentLocale.languageCode];

	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		filePath = ROOT_PATH_NS(@"/Library/PreferenceBundles/BoldersRebornPrefs.bundle/Localization/en.lproj/Localization.strings");
	}

	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];

	for (PSSpecifier *specifier in _specifiers) {
		NSString *origName = specifier.name;

		NSString *loc = [dict objectForKey:origName];
		NSString *footerTextLoc = [dict objectForKey:[specifier propertyForKey:@"footerText"]];
		NSString *defaultTextLoc = [dict objectForKey:[specifier propertyForKey:@"default"]];

		[specifier setProperty:footerTextLoc forKey:@"footerText"];
		[specifier setProperty:defaultTextLoc forKey:@"default"];
		specifier.name = loc;
	}

	NSString *origTitle = self.title;
	self.title = [dict objectForKey:origTitle];
}

- (void)_initTopMenu {
	__weak typeof(self) weakSelf = self;

	NSString *genericPath = ROOT_PATH_NS(@"/Library/PreferenceBundles/BoldersRebornPrefs.bundle/Localization/LANG.lproj/Localization.strings");
	NSString *filePath = [genericPath stringByReplacingOccurrencesOfString:@"LANG" withString:NSLocale.currentLocale.languageCode];

	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		filePath = ROOT_PATH_NS(@"/Library/PreferenceBundles/BoldersRebornPrefs.bundle/Localization/en.lproj/Localization.strings");
	}

	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];

	UIButton *topMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
	topMenuButton.frame = CGRectMake(0,0,26,26);
	[topMenuButton setImage:[[UIImage systemImageNamed:@"gearshape.fill"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	topMenuButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
	topMenuButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
	topMenuButton.tintColor = kTintColor;

	UIAction *respring = [UIAction actionWithTitle:[dict objectForKey:@"RESPRING"] image:[UIImage systemImageNamed:@"arrow.counterclockwise.circle.fill"] identifier:nil handler:^(UIAction *action) {
		[weakSelf _performRespring];
	}];

	UIAction *resetPrefs = [UIAction actionWithTitle:[dict objectForKey:@"RESET_PREFS"] image:[UIImage systemImageNamed:@"arrow.triangle.2.circlepath.circle.fill"] identifier:nil handler:^(UIAction *action) {
		[weakSelf _performResetPrefs];
	}];

	resetPrefs.attributes = UIMenuElementAttributesDestructive;

	NSArray *items = @[respring, resetPrefs];

	topMenuButton.menu = [UIMenu menuWithTitle:@"" children: items];
	topMenuButton.showsMenuAsPrimaryAction = true;

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:topMenuButton];
}

- (void)_performRespring {
	__weak typeof(self) weakSelf = self;

	UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
	UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
	blurView.frame = self.view.bounds;
	blurView.alpha = 0;
	[self.view addSubview:blurView];

	[UIView animateWithDuration:0.50 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		[blurView setAlpha:1.0];
	} completion:^(BOOL finished) {
		[weakSelf.view endEditing:YES];
		[weakSelf _respring];
	}];
}

- (void)_performResetPrefs {
	__weak typeof(self) weakSelf = self;

	NSString *genericPath = ROOT_PATH_NS(@"/Library/PreferenceBundles/BoldersRebornPrefs.bundle/Localization/LANG.lproj/Localization.strings");
	NSString *filePath = [genericPath stringByReplacingOccurrencesOfString:@"LANG" withString:NSLocale.currentLocale.languageCode];

	if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		filePath = ROOT_PATH_NS(@"/Library/PreferenceBundles/BoldersRebornPrefs.bundle/Localization/en.lproj/Localization.strings");
	}

	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];

	UIAlertController *alert = [UIAlertController alertControllerWithTitle:[dict objectForKey:@"RESET_PREFERENCES_QUESTION"] message:[dict objectForKey:@"RESET_PREFERENCES_DESCRIPTION"] preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[dict objectForKey:@"CANCEL"] style:UIAlertActionStyleDefault handler:nil];
	[alert addAction:cancelAction];

	[alert addAction:[UIAlertAction actionWithTitle:[dict objectForKey:@"RESET_RESET"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"com.nightwind.boldersrebornprefs"];

		NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.nightwind.boldersrebornprefs"];

		[userDefaults setObject:@true forKey:@"tweakEnabled"];
		[userDefaults synchronize];

		UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
		UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
		blurView.frame = weakSelf.view.bounds;
		blurView.alpha = 0;
		[weakSelf.view addSubview:blurView];

		[UIView animateWithDuration:0.50 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			[blurView setAlpha:1.0];
		} completion:^(BOOL finished) {
			[weakSelf.view endEditing:YES];
			[weakSelf _respring];
		}];
	}]];

	[self presentViewController:alert animated:true completion:nil];
}

- (void)_respring {
    pid_t pid;

    const char *args[] = { "killall", "SpringBoard", NULL };
    posix_spawn(&pid, ROOT_PATH("/usr/bin/killall"), NULL, NULL, (char *const *)args, NULL);
}

@end