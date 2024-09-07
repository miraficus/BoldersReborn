// Copyright (c) 2023 Nightwind. All rights reserved.

#import <rootless.h>
#import <spawn.h>
#import "BoldersRebornHeaderCell.h"
#import "../TintColors.h"

@implementation BoldersRebornHeaderCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];

    if (self) {

        UILabel *tweakTitle = [UILabel new];
        tweakTitle.text = [specifier propertyForKey:@"tweakTitle"];
        tweakTitle.font = [UIFont boldSystemFontOfSize:40];
        tweakTitle.textAlignment = NSTextAlignmentCenter;
        tweakTitle.translatesAutoresizingMaskIntoConstraints = false;
        [self.contentView addSubview:tweakTitle];

        [NSLayoutConstraint activateConstraints:@[
            [tweakTitle.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor],
            [tweakTitle.bottomAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [tweakTitle.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        ]];

        UIImage *image = [UIImage imageNamed:@"pref_icon.png" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];

        UIImageView *tweakIconImageView = [[UIImageView alloc] initWithImage:image];
        tweakIconImageView.layer.masksToBounds = true;
        tweakIconImageView.layer.cornerRadius = 10.0f;
        tweakIconImageView.translatesAutoresizingMaskIntoConstraints = false;
        [self.contentView addSubview: tweakIconImageView];

        [NSLayoutConstraint activateConstraints:@[
            [tweakIconImageView.widthAnchor constraintEqualToConstant: 50],
            [tweakIconImageView.heightAnchor constraintEqualToConstant: 50],
            [tweakIconImageView.bottomAnchor constraintEqualToAnchor:tweakTitle.topAnchor constant: -10],
            [tweakIconImageView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        ]];

        UILabel *versionSubtitle = [UILabel new];
        versionSubtitle.text = PACKAGE_VERSION;
        versionSubtitle.textColor = UIColor.secondaryLabelColor;
        versionSubtitle.font = [UIFont boldSystemFontOfSize:25];
        versionSubtitle.textAlignment = NSTextAlignmentCenter;
        versionSubtitle.translatesAutoresizingMaskIntoConstraints = false;
        [self.contentView addSubview:versionSubtitle];

        [NSLayoutConstraint activateConstraints:@[
            [versionSubtitle.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor],
            [versionSubtitle.topAnchor constraintEqualToAnchor:self.contentView.centerYAnchor constant: 2],
            [versionSubtitle.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        ]];

        int on = [[[[NSUserDefaults alloc] initWithSuiteName:@"com.nightwind.boldersrebornprefs"] objectForKey:@"tweakEnabled"] intValue];

        UISwitch *switchCell = [[UISwitch alloc] initWithFrame: CGRectZero];
        switchCell.transform = CGAffineTransformMakeScale(1.3, 1.3);
        switchCell.translatesAutoresizingMaskIntoConstraints = false;
        switchCell.onTintColor = kTintColor;
        switchCell.on = on == 1 ? true : false;
        [switchCell addTarget: self action: @selector(switchTriggered) forControlEvents: UIControlEventValueChanged];
        [self.contentView addSubview: switchCell];

        [NSLayoutConstraint activateConstraints:@[
            [switchCell.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant: -10],
            [switchCell.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
        ]];

        [self setControl:switchCell];

    }

    return self;
}

- (void)switchTriggered {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.nightwind.boldersrebornprefs"];

    [userDefaults setObject:@(((UISwitch *)(self.control)).on) forKey:@"tweakEnabled"];
    [userDefaults synchronize];

    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    blurView.frame = self._viewControllerForAncestor.view.bounds;
    blurView.alpha = 0;
    [self._viewControllerForAncestor.view addSubview:blurView];

    [UIView animateWithDuration:0.50 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [blurView setAlpha:1.0];
    } completion:^(BOOL finished) {
        pid_t pid;

        const char *args[] = { "killall", "SpringBoard", NULL};
        posix_spawn(&pid, ROOT_PATH("/usr/bin/killall"), NULL, NULL, (char *const *)args, NULL);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    for (UIView *view in self.subviews) {
        if (view != self.contentView){
            [view removeFromSuperview];
        }
    }
}

@end