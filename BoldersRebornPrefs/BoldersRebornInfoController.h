#import <Foundation/Foundation.h>
#import <Preferences/PSSwitchTableCell.h>
#import <UIKit/UIViewController.h>
#import <UIKit/UIImage.h>

@interface BoldersRebornInfoController : UIViewController
@property (nonatomic, weak) NSString *infoTitle;
@property (nonatomic, strong) NSString *offInfoDescription;
@property (nonatomic, strong) NSString *onInfoDescription;
@property (nonatomic, weak) NSString *dismissAndApply;
@property (nonatomic, weak) UIImage *infoImage;
@property (nonatomic, weak) PSSwitchTableCell *caller;
@end