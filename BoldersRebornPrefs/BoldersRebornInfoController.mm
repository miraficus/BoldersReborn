#import <UIKit/UIKit.h>
#import "BoldersRebornInfoController.h"
#import "TintColors.h"

@implementation BoldersRebornInfoController {
    UIImageView *_imageView;
    UILabel *_description;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	BOOL isOn = ((UISwitch *)(self.caller.control)).isOn;

	self.view.backgroundColor = UIColor.blackColor;

	UIImage *image;

	NSArray *windows = UIApplication.sharedApplication.windows;
	UIWindow *mainWindow = nil;
	for (UIWindow *window in windows) {
		if (window.isKeyWindow) {
			mainWindow = window;
			break;
		}
	}

	UIEdgeInsets safeAreaInsets = mainWindow.safeAreaInsets;

	if (safeAreaInsets.top > 0) {
		if (isOn) {
			image = [UIImage imageNamed:@"notched_no_icon_blur.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
		} else {
			image = [UIImage imageNamed:@"notched_icon_blur.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
		}
	} else {
		if (isOn) {
			image = [UIImage imageNamed:@"legacy_no_icon_blur.jpg" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
		} else {
			image = [UIImage imageNamed:@"legacy_icon_blur.jpg" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
		}
	}

	_imageView = [[UIImageView alloc] initWithImage:image];
	_imageView.layer.masksToBounds = true;
	_imageView.layer.cornerRadius = 10.0f;
	_imageView.translatesAutoresizingMaskIntoConstraints = false;
	_imageView.contentMode = UIViewContentModeScaleAspectFit;
	_imageView.alpha = 0.8;

	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = self.view.bounds;
	gradient.colors = @[(id)UIColor.clearColor.CGColor, (id)UIColor.systemBackgroundColor.CGColor];

	CAShapeLayer *mask = [CAShapeLayer layer];
	mask.frame = self.view.bounds;
	mask.path = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
	mask.fillColor = UIColor.blackColor.CGColor;
	mask.strokeColor = UIColor.clearColor.CGColor;
	mask.lineWidth = 0;

	gradient.mask = mask;

	[self.view addSubview:_imageView];

	[NSLayoutConstraint activateConstraints:@[
		[_imageView.widthAnchor constraintEqualToAnchor: self.view.widthAnchor],
		[_imageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
		[_imageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]
	]];

	[self.view.layer addSublayer:gradient];

	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.translatesAutoresizingMaskIntoConstraints = NO;
	closeButton.backgroundColor = kTintColor;
	closeButton.layer.cornerRadius = 10;
	[closeButton setTitle:self.dismissAndApply forState:UIControlStateNormal];
	[closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:closeButton];

	[NSLayoutConstraint activateConstraints:@[
		[closeButton.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.85],
		[closeButton.heightAnchor constraintEqualToConstant: 50],
		[closeButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-35],
		[closeButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
	]];

	_description = [UILabel new];
	_description.text = isOn ? self.onInfoDescription : self.offInfoDescription;
	_description.textColor = UIColor.whiteColor;
	_description.font = [UIFont systemFontOfSize:20];
	_description.textAlignment = NSTextAlignmentCenter;
	_description.lineBreakMode = NSLineBreakByWordWrapping;
	_description.numberOfLines = 0;
	_description.translatesAutoresizingMaskIntoConstraints = false;
	[self.view addSubview:_description];

	[NSLayoutConstraint activateConstraints:@[
		[_description.bottomAnchor constraintEqualToAnchor:closeButton.topAnchor constant:-30],
		[_description.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.95],
		[_description.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
	]];

	UILabel *infoTitle = [UILabel new];
	infoTitle.text = self.infoTitle;
	infoTitle.textColor = UIColor.whiteColor;
	infoTitle.font = [UIFont boldSystemFontOfSize:27];
	infoTitle.textAlignment = NSTextAlignmentCenter;
	infoTitle.translatesAutoresizingMaskIntoConstraints = false;
	[self.view addSubview:infoTitle];

	[NSLayoutConstraint activateConstraints:@[
		[infoTitle.bottomAnchor constraintEqualToAnchor:_description.topAnchor constant: -10],
		[infoTitle.widthAnchor constraintEqualToAnchor:self.view.widthAnchor],
		[infoTitle.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
	]];

	UISwitch *switchCell = [[UISwitch alloc] initWithFrame: CGRectZero];
	switchCell.transform = CGAffineTransformMakeScale(1.5, 1.5);
	switchCell.translatesAutoresizingMaskIntoConstraints = false;
	switchCell.onTintColor = kTintColor;
	switchCell.on = isOn;
	[switchCell addTarget:self action: @selector(switchTriggered:) forControlEvents: UIControlEventValueChanged];
	[self.view addSubview:switchCell];

	[NSLayoutConstraint activateConstraints:@[
		[switchCell.bottomAnchor constraintEqualToAnchor:infoTitle.topAnchor constant: -30],
		[switchCell.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
	]];
}

- (void)closeButtonTapped {
	[self dismissViewControllerAnimated:true completion:nil];
}

- (void)switchTriggered:(UISwitch *)sender {
    UIImage *newImage = nil;
    NSString *newText = nil;

	NSArray *windows = UIApplication.sharedApplication.windows;
	UIWindow *mainWindow = nil;
	for (UIWindow *window in windows) {
		if (window.isKeyWindow) {
			mainWindow = window;
			break;
		}
	}

	UIEdgeInsets safeAreaInsets = mainWindow.safeAreaInsets;

	if (safeAreaInsets.top > 0) {
		if (sender.isOn) {
			newImage = [UIImage imageNamed:@"notched_no_icon_blur.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
		} else {
			newImage = [UIImage imageNamed:@"notched_icon_blur.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
		}
	} else {
		if (sender.isOn) {
			newImage = [UIImage imageNamed:@"legacy_no_icon_blur.jpg" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
		} else {
			newImage = [UIImage imageNamed:@"legacy_icon_blur.jpg" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
		}
	}

	if (sender.isOn) {
		newText = self.onInfoDescription;
	} else {
		newText = self.offInfoDescription;
	}

    [UIView transitionWithView:_imageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		_imageView.image = newImage;
	} completion:nil];

    CATransition *textTransition = [CATransition animation];
    textTransition.duration = 0.3;
    textTransition.type = kCATransitionFade;
    [_description.layer addAnimation:textTransition forKey:nil];
    _description.text = newText;

	[(UISwitch *)(self.caller.control) setOn:sender.isOn animated:true];
}


@end