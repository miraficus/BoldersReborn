#import <Preferences/PSSliderTableCell.h>
#import <Preferences/PSSpecifier.h>

@interface UIView (Private)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface PSSliderTableCell (Undocumented)
- (NSNumber *)controlValue;
@end

@interface BoldersRebornSliderCell : PSSliderTableCell
@end