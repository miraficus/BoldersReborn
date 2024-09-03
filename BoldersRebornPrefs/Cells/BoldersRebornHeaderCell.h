#import <UIKit/UIKit.h>
#import <rootless.h>
#import <spawn.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSControlTableCell.h>

@interface BoldersRebornHeaderCell : PSControlTableCell
- (UIViewController *)_viewControllerForAncestor;
@end