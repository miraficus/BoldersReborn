/*
 *
 * Copyright (c) 2024 Nightwind. All rights reserved.
 *
 * A portion of this code is derived from Atria, which is
 * licensed under the GPLv3 license. The original code can be found at
 * https://github.com/ren7995/Atria
 *
 */

#import "Tweak.h"
#import "Localization.h"

static id lastIconSuccess = nil;

// This hook hides the background square of the original folder layout
%hook SBFolderBackgroundView

- (void)didMoveToWindow {
	%orig;
	self.hidden = true;
}

%end


// This hook determines whether the blurred homescreen icons are visible whilst inside of a folder
%hook SBFolderController

- (BOOL)_homescreenAndDockShouldFade {
	return homescreenIconBlur_portrait ? true : false;
}

%end


%hook SBFloatyFolderView

// Getting rid of the original corner radius for the background
- (double)cornerRadius {
	return 0;
}

// This determines the spacing and positioning of everything
- (CGRect)_frameForScalingView {
	CGRect frame = %orig;

	return CGRectMake(frame.origin.x - 36 + horizontalIconInset_portrait + horizontalOffset_portrait,
					  frame.origin.y + topIconInset_portrait,
					  UIScreen.mainScreen.bounds.size.width - 18 - (horizontalIconInset_portrait * 2),
					  frame.size.height + verticalIconSpacing_portrait);
}

- (NSInteger)iconVisibilityHandling {
	return 0;
}

- (void)updateVisibleColumnRangeWithTotalLists:(NSUInteger)arg1 iconVisibilityHandling:(NSInteger)arg2 {
	%orig(arg1, 0);
}

// Makes the folder close even if you're tapping on the background that would've originally been there
- (BOOL)_tapToCloseGestureRecognizer:(UIGestureRecognizer *)gesture shouldReceiveTouch:(UITouch *)touch {
	const CGPoint point = [touch locationInView:gesture.view];
    UIView *const viewTouched = [gesture.view hitTest:point withEvent:nil];

	if ([viewTouched isKindOfClass:[self class]] || [viewTouched isKindOfClass:%c(SBIconListView)]) {
		return true;
	}

	return %orig;
}

%end


%hook SBFloatyFolderController

// Update icon count when a new icon is dropped into a folder
- (void)_updateFolderRequiredTrailingEmptyListCount {
	%orig;
	[self.folderView._titleTextField _br_updateIconCount];
}

%end


// Hides the page dots in an opened folder
%hook SBIconListPageControl

- (void)setHidden:(BOOL)hidden {
	if ([self.superview.superview isKindOfClass:%c(SBFloatyFolderView)]) {
		%orig(true);
	} else %orig;
}

%end


// Increases the maximum icon count from 9 (3x3) to whatever the rows * columns is
%hook SBIconListFlowLayout

- (unsigned long long)maximumIconCount {
	if (self.layoutConfiguration.isOldFolder) {
		return rows * columns;
	} else return %orig;
}

%end

%hook SBFolderTitleTextField
%property (nonatomic, strong) UILabel *_br_appCountLabel;
%property (nonatomic, strong) NSLayoutConstraint *_br_newConstraint;
%property (nonatomic, strong) NSNumberFormatter *_br_numberFormatter;

// Changes the font of the title of the folder
- (void)setFont:(UIFont *)font {
	%orig([UIFont systemFontOfSize:(50 * titleScale_portrait) weight:UIFontWeightSemibold]);
}

// Adds the app count label to the folder
- (void)didMoveToWindow {
	%orig;

	if (!self._br_numberFormatter) {
		self._br_numberFormatter = [NSNumberFormatter new];
		self._br_numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
	}

	self.textColor = [self.textColor colorWithAlphaComponent:titleTransparency_portrait];

	self._br_appCountLabel = [UILabel new];
	self._br_appCountLabel.translatesAutoresizingMaskIntoConstraints = false;
	self._br_appCountLabel.font = [UIFont systemFontOfSize:(25 * subtitleScale_portrait) weight:UIFontWeightSemibold];
	self._br_appCountLabel.textColor = [UIColor whiteColor];
	self._br_appCountLabel.alpha = subtitleTransparency_portrait;
	[self addSubview:self._br_appCountLabel];

	[self._br_appCountLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20].active = true;
	[self._br_appCountLabel.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = true;
	[self._br_appCountLabel.bottomAnchor constraintEqualToAnchor:self.topAnchor constant:15 + subtitleOffset_portrait - topIconInset_portrait].active = true;
}

// Places all the views in their correct positions
- (void)layoutSubviews {
	%orig;

	if (![self showingEditUI]) {
		const BOOL deviceLanguageIsRTL = [NSLocale characterDirectionForLanguage:NSLocale.preferredLanguages.firstObject] == NSLocaleLanguageDirectionRightToLeft;

		const CGRect origTextFrame = self._textCanvasView.frame;
		self._textCanvasView.frame = CGRectMake(deviceLanguageIsRTL ? -55 : 20, origTextFrame.origin.y + titleOffset_portrait - topIconInset_portrait, UIScreen.mainScreen.bounds.size.width, origTextFrame.size.height);

		const CGRect origBGFrame = self._backgroundView.frame;
		self._backgroundView.frame = CGRectMake(origBGFrame.origin.x, origBGFrame.origin.y + titleOffset_portrait - topIconInset_portrait, origBGFrame.size.width, origBGFrame.size.height);

		const CGRect origClearButtonFrame = self._clearButton.frame;
		self._clearButton.frame = CGRectMake(origClearButtonFrame.origin.x, origClearButtonFrame.origin.y + titleOffset_portrait - topIconInset_portrait, origClearButtonFrame.size.width, origClearButtonFrame.size.height);
	}
}

- (void)setShowsEditUI:(BOOL)showsEditUI animated:(BOOL)animated {
	%orig;

	self._br_newConstraint.active = false;

	if (showsEditUI) {
		self._br_newConstraint = [self._br_appCountLabel.bottomAnchor constraintEqualToAnchor:self.topAnchor constant:subtitleOffset_portrait - topIconInset_portrait];
	} else {
		self._br_newConstraint = [self._br_appCountLabel.bottomAnchor constraintEqualToAnchor:self.topAnchor constant:15 + subtitleOffset_portrait - topIconInset_portrait];
	}

	[UIView animateWithDuration:0.3 animations:^{
		self._br_appCountLabel.alpha = showsEditUI ? 0.0f : subtitleTransparency_portrait;
		self._br_newConstraint.active = true;
		[self layoutIfNeeded];
	}];
}

// Sets the text alignment of the title to left on LTR languages and right on RTL languages
- (void)setTextAlignment:(NSTextAlignment)alignment {
	%orig(NSTextAlignmentNatural);
}

%new
- (void)_br_updateIconCount {
	// $c => ((SBFloatyFolderView *)(self.delegate)).folder.iconCount
	// $t => ((SBFloatyFolderView *)(self.delegate)).folder.displayName

	SBFloatyFolderView *const delegate = (SBFloatyFolderView *)[self delegate];

	NSString *iconCount = [self._br_numberFormatter stringFromNumber:@(delegate.folder.iconCount)];
	NSString *displayName = delegate.folder.displayName;
	NSString *text = [[countText stringByReplacingOccurrencesOfString:@"$c" withString:iconCount] stringByReplacingOccurrencesOfString:@"$t" withString:displayName];
	self._br_appCountLabel.text = text;
}

%end



%hook SBIconListView

// Needed to check whether the list view is in a folder
- (void)setIconsNeedLayout {
	%orig;

	if ([self.superview isKindOfClass:%c(SBFloatyFolderScrollView)]) {
		self.layout.layoutConfiguration.isOldFolder = true;
		self.layout.layoutConfiguration.check = false;
	}
}

// Needed to check whether the list view is in a folder, because it seems as if the view updates itself every time you scroll to a different page
- (void)layoutSubviews {
	%orig;

	if ([self.superview isKindOfClass:%c(SBFloatyFolderScrollView)]) {
		self.layout.layoutConfiguration.isOldFolder = true;
		self.layout.layoutConfiguration.check = false;
	}
}

// Applies the proper icon scale to the icons in the folder
- (void)layoutIconsIfNeeded {
	%orig;

	if ([self.superview isKindOfClass:%c(SBFloatyFolderScrollView)]) {
		for (SBIconView *icon in self.subviews) {
			if ([icon respondsToSelector:@selector(setIconContentScale:)]) {
				icon.iconContentScale = iconScale_portrait;
			}
		}
	}
}

// Initially sets the value of whether the icon list is in a folder, then handled by other methods
- (SBIconListGridLayout *)layout {
	SBIconListGridLayout *origLayout = %orig;

	if ([self.superview isKindOfClass:%c(SBFloatyFolderScrollView)]) {
		origLayout.layoutConfiguration.isOldFolder = true;
		origLayout.layoutConfiguration.check = false;
		self.model.location = self.iconLocation;
	}

	return origLayout;
}

%end


// https://github.com/Falc0nDev/HomePlusPro/blob/bf404a4af0fa0584612d1490ede0c8f556d2eb6c/Hooks/ios13/MainLayout.xm
%hook SBIconListModel

%property (nonatomic, strong) NSString *location;

// Again needed to set the value of the maximum amount of icons to rows * columns
- (NSUInteger)maxNumberOfIcons {
	if ([self.location isEqualToString:@"SBIconLocationFolder"]) {
		return rows * columns;
	}
	return %orig;
}

// Fixes the icon placement inside of a folder and in general
- (NSUInteger)firstFreeSlotIndex {
    if (self.numberOfIcons >= self.maxNumberOfIcons) {
        return 0x7FFFFFFFFFFFFFFFLL;
	}
    return self.numberOfIcons;
}

// Fixes issues regarding the method using an ivar before
- (BOOL)isFullIncludingPlaceholders {
    return self.icons.count >= self.maxNumberOfIcons;
}

// FROM ATRIA:
// Changes the grid size of the folder in order to account for rows * columns
- (SBHIconGridSize)gridSize {
	SBHIconGridSize size = %orig;

	if ([self.location isEqualToString:@"SBIconLocationFolder"]) {
		size.height = rows;
		size.width = columns;
	}

	return size;
}

%end


%hook SBIconListGridLayoutConfiguration

%property (nonatomic, assign) BOOL isOldFolder;
%property (nonatomic, assign) BOOL check;

// This checks whether the layout configuration is in a folder or not, self explanatory
%new
- (BOOL)checkIfFolder {
	if (self.check) self.isOldFolder = false;
	return self.isOldFolder;
}

// This patches the amount of rows in a folder in portrait mode
- (NSUInteger)numberOfPortraitRows {
	[self checkIfFolder];

	if (self.isOldFolder && !self.check) {
		return rows;
	}

	return %orig;
}

// This patches the amount of columns in a folder in portrait mode
- (NSUInteger)numberOfPortraitColumns {
	[self checkIfFolder];

	if (self.isOldFolder && !self.check) {
		return columns;
	}

	return %orig;
}

// Patches the 'check' and 'isOldFolder' properties to be false on the initialization of the class
- (instancetype)init {
    self = %orig;

    if (self) {
        self.check = false;
        self.isOldFolder = false;
    }

    return self;
}

%end


%hook SBIconGridImage

// Makes sure the 'check' is passed so that the folder icon is properly patched up
- (SBIconListGridLayout *)listLayout {
	SBIconListGridLayout *orig = %orig;

	orig.layoutConfiguration.check = true;

	return orig;
}

// Makes the folder icon always 3x3 or 3x4 no matter what, matching the original Bolders's looks
- (void)setListLayout:(SBIconListGridLayout *)listLayout {
	SBIconListGridLayout *orig = listLayout;
	orig.layoutConfiguration.check = true;

	if (orig.layoutConfiguration.numberOfPortraitColumns == 2) {
		orig.layoutConfiguration.numberOfPortraitRows = 2;
	} else {
		if (rows >= 4) {
			orig.layoutConfiguration.numberOfPortraitRows = 4;
		}

		if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad && rows == 3) {
			orig.layoutConfiguration.numberOfPortraitRows = 3;
		}
	}

	%orig(orig);
}

// Patches a crash that happened prior to this hook's existence
+ (id)gridImageForLayout:(id)arg1 previousGridImage:(id)arg2 previousGridCellIndexToUpdate:(unsigned long long)arg3 pool:(id)arg4 cellImageDrawBlock:(id)arg5 {
	@try {
		return %orig;
		lastIconSuccess = %orig;
	} @catch (NSException *exception) {
		NSLog(@"[Nightwind] -> EXCEPTION -> %@", exception);
		return lastIconSuccess;
	}
}

%end


%hook SBFolderIconImageCache

// Makes sure the 'check' is passed so that the folder icon is properly patched up, also
// Makes the folder icon always 3x3 or 3x4 no matter what, matching the original Bolders's looks
- (SBIconListGridLayout *)listLayout {
	SBIconListGridLayout *orig = %orig;

	orig.layoutConfiguration.check = true;

	if (orig.layoutConfiguration.numberOfPortraitColumns == 2) {
		orig.layoutConfiguration.numberOfPortraitRows = 2;
	} else {
		if (rows >= 4) {
			orig.layoutConfiguration.numberOfPortraitRows = 4;
		}

		if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad && rows == 3) {
			orig.layoutConfiguration.numberOfPortraitRows = 3;
		}
	}

	return orig;
}

// Makes the folder icon always 3x3 or 3x4 no matter what, matching the original Bolders's looks
- (void)setListLayout:(SBIconListGridLayout *)listLayout {
	SBIconListGridLayout *orig = listLayout;
	orig.layoutConfiguration.check = true;

	if (orig.layoutConfiguration.numberOfPortraitColumns == 2) {
		orig.layoutConfiguration.numberOfPortraitRows = 2;
	} else {
		if (rows >= 4) {
			orig.layoutConfiguration.numberOfPortraitRows = 4;
		}

		if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad && rows == 3) {
			orig.layoutConfiguration.numberOfPortraitRows = 3;
		}
	}

	%orig(orig);
}

%end


%hook _SBIconGridWrapperView

// Prepares for the adjustment of the folder grid area in a folder preview icon in order to accomodate for the 3x4 layout
- (void)layoutSubviews {
    %orig;

	if (UIDevice.currentDevice.systemVersion.floatValue < 15.0) {
		self.layer.masksToBounds = true;
		CAShapeLayer *maskLayer = [CAShapeLayer layer];
		maskLayer.frame = self.bounds;
		UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-self.frame.origin.x, 0, self.bounds.size.width + (self.frame.origin.x * 2), self.bounds.size.height - 10.8) byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(14, 14)];
		maskLayer.path = maskPath.CGPath;
		self.layer.mask = maskLayer;
	}

	SBIconGridImage *image = (SBIconGridImage *)self.image;

	if ([image respondsToSelector:@selector(iconImageAtIndex:)]) {
		if (image.numberOfColumns > 2 && [image iconImageAtIndex:1]) {
			if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
				if (!(image.numberOfRows == 4 && image.numberOfColumns == 4)) {
					[self adjustTransform];
				}
			} else {
				if (!(image.numberOfRows == 3 && image.numberOfColumns == 3)) {
					[self adjustTransform];
				}
			}
		}
	}
}


// Prepares for the adjustment of the folder grid area in a folder preview icon in order to accomodate for the 3x4 layout
- (void)reposition {
	%orig;

	SBIconGridImage *image = (SBIconGridImage *)self.image;

	if (image.numberOfColumns > 2 && [image iconImageAtIndex:1]) {
		if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
			if (!(image.numberOfRows == 4 && image.numberOfColumns == 4)) {
				[self adjustTransform];
			}
		} else {
			if (!(image.numberOfRows == 3 && image.numberOfColumns == 3)) {
				[self adjustTransform];
			}
		}
	}
}

// Adjusts the folder grid area in a folder preview icon in order to accomodate for the 3x4 layout
%new
- (void)adjustTransform {
	SBIconGridImage *image = (SBIconGridImage *)self.image;

	if ([image iconImageAtIndex:1]) {
		NSArray *paddingArray = @[@0, @8, @8.5, @8.5, @8.5, @8.5, @8.5, @8.5];
		NSUInteger padding = (NSUInteger)[paddingArray[rows - 3] integerValue];

		CGAffineTransform originalIconView = (self.transform);
		self.transform = CGAffineTransformMake(
			originalIconView.a,
			originalIconView.b,
			originalIconView.c,
			originalIconView.d,
			originalIconView.tx,
			padding
		);
	}
}

%end


// Allows for the icons to be scaled, i.e. 0.5x, 2x, etc.
%hook SBIconView

- (BOOL)isIconContentScalingEnabled {
	return [self.location isEqualToString:@"SBIconLocationFolder"] ? true : %orig;
}

- (void)setIconContentScalingEnabled:(BOOL)enabled {
	if ([self.location isEqualToString:@"SBIconLocationFolder"]) {
		if (enabled) {
			%orig(true);
		}
	} else %orig;
}

%end


// Hiding the folder background
%hook SBFolderIconImageView

- (void)layoutSubviews {
	%orig;

	if (!folderBackground_portrait && ![[self _viewControllerForAncestor] isKindOfClass:%c(SBHLibraryCategoryIconViewController)]) {
		for (UIView *subview in self.subviews) {
			if (![subview subviews] || [subview isKindOfClass:%c(MTMaterialView)]) {
				[subview setAlpha:0];
			}
		}
	}
}

%end

// FIX FROM ATRIA
%hook SBHDefaultIconListLayoutProvider

- (SBIconListFlowExtendedLayout *)layoutForIconLocation:(NSString *)location {
	SBIconListFlowExtendedLayout *orig = %orig;

	if ([location isEqualToString:@"SBIconLocationFolder"]) {
		orig.layoutConfiguration.check = false;
		orig.layoutConfiguration.isOldFolder = true;
	}

	return orig;
}

%end

%ctor {
	__block NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.nightwind.boldersrebornprefs"];

	BOOL (^boolForKey)(NSString *, BOOL) = ^(NSString *key, BOOL def) {
		return ([prefs objectForKey:key]) ? [prefs boolForKey:key] : def;
	};
	NSInteger (^intForKey)(NSString *, NSInteger) = ^(NSString *key, NSInteger def) {
		return ([prefs objectForKey:key]) ? [prefs integerForKey:key] : def;
	};
	NSUInteger (^uintForKey)(NSString *, NSUInteger) = ^(NSString *key, NSUInteger def) {
		return ([prefs objectForKey:key]) ? [prefs integerForKey:key] : def;
	};
	double (^doubleForKey)(NSString *, double) = ^(NSString *key, double def) {
		return ([prefs objectForKey:key]) ? [prefs doubleForKey:key] : def;
	};
	NSString *(^stringForKey)(NSString *, NSString *) = ^(NSString *key, NSString *def) {
		return ([prefs objectForKey:key]) ? [prefs objectForKey:key] : def;
	};

	NSDictionary *dict = localizationDictionary();

	/*
	|====================|
	| Global Preferences |
	|====================|
	*/

	tweakEnabled = boolForKey(@"tweakEnabled", true);

	countText = stringForKey(@"countText", [dict objectForKey:@"DEFAULT_APPS"]);

	rows = uintForKey(@"rows", 3);
	columns = uintForKey(@"columns", 3);

	/*
	|======================|
	| Portrait Preferences |
	|======================|
	*/

	titleOffset_portrait = intForKey(@"titleOffset_portrait", 0);
	subtitleOffset_portrait = intForKey(@"subtitleOffset_portrait", 0);
	horizontalIconInset_portrait = intForKey(@"horizontalIconInset_portrait", 0);
	topIconInset_portrait = intForKey(@"topIconInset_portrait", 0);
	horizontalOffset_portrait = intForKey(@"horizontalOffset_portrait", 0);

	titleScale_portrait = doubleForKey(@"titleScale_portrait", 1);
	subtitleScale_portrait = doubleForKey(@"subtitleScale_portrait", 1);
	titleTransparency_portrait = doubleForKey(@"titleTransparency_portrait", 1);
	subtitleTransparency_portrait = doubleForKey(@"subtitleTransparency_portrait", 0.5);
	verticalIconSpacing_portrait = uintForKey(@"verticalIconSpacing_portrait", 50);
	iconScale_portrait = doubleForKey(@"iconScale_portrait", 1);

	homescreenIconBlur_portrait = boolForKey(@"homescreenIconBlur_portrait", true);

	folderBackground_portrait = boolForKey(@"folderBackground_portrait", true);

	if (tweakEnabled) {
		%init;
	}
}

/*
|==================================================================|
| Landscape Preferences                                            |
| ---------------------------------------------------------------- |
| The original Bolders had landscape as well.                      |
| However, since landscape is pretty much broken on iOS 14 and 15, |
| Landscape support is not planned at the moment.                  |
|==================================================================|
*/

// titleOffset_landscape = intForKey(@"titleOffset_landscape", 0);
// subtitleOffset_landscape = intForKey(@"subtitleOffset_landscape", 0);
// horizontalIconInset_landscape = intForKey(@"horizontalIconInset_landscape", 0);
// topIconInset_landscape = intForKey(@"topIconInset_landscape", 0);
// horizontalOffset_landscape = intForKey(@"horizontalOffset_landscape", 0);

// titleScale_landscape = doubleForKey(@"titleScale_landscape", 1);
// subtitleScale_landscape = doubleForKey(@"subtitleScale_landscape", 1);
// titleTransparency_landscape = doubleForKey(@"titleTransparency_landscape", 1);
// subtitleTransparency_landscape = doubleForKey(@"subtitleTransparency_landscape", 0.5);
// verticalIconSpacing_landscape = uintForKey(@"verticalIconSpacing_landscape", 50);
// iconScale_landscape = doubleForKey(@"iconScale_landscape", 1);

// homescreenIconBlur_landscape = boolForKey(@"homescreenIconBlur_landscape", true);

/*
|===========================|
| To make background darker |
|===========================|

@interface SBFolderControllerBackgroundView : UIView
@end

@interface MTMaterialLayer : CALayer
@end

@interface MTMaterialView : UIView
@property NSInteger recipe;
@end

%hook SBFolderControllerBackgroundView

- (void)layoutSubviews {
	%orig;

	// http://iphonedev.wiki/index.php/MTMaterialView
	((MTMaterialView *)self.subviews[0]).recipe = 1;
}

%end

*/