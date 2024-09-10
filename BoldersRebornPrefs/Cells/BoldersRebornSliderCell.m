// Copyright (c) 2024 Nightwind. All rights reserved.

#import "BoldersRebornSliderCell.h"
#import "../../Localization.h"
#import <rootless.h>

@interface UITextField (NumericInput)
- (void)addNumericAccessory:(BOOL)addPlusMinus;
- (void)plusMinusPressed;
@end

@implementation BoldersRebornSliderCell {
    NSNumberFormatter *_numberFormatter;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];

    if (self) {
        _numberFormatter = [NSNumberFormatter new];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatter.roundingMode = NSNumberFormatterRoundUp;
        _numberFormatter.maximumFractionDigits = 2;
    }

    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    [self.control setValue:[NSMutableArray array] forKey:@"_gestureRecognizers"];

	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
	tapGestureRecognizer.numberOfTapsRequired = 2;
	[self addGestureRecognizer:tapGestureRecognizer];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    UILabel *const label = (UILabel *)self.control.subviews[0].subviews[0];

    if ([label isKindOfClass:[UILabel class]]) {
        label.translatesAutoresizingMaskIntoConstraints = false;
        [label.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = true;
        [label.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor constant:-10].active = true;
    }
}

- (void)tapped {
	NSDictionary *dict = localizationDictionary();

    UISlider *slider = (UISlider *)[self control];
    NSString *minVal = [_numberFormatter stringFromNumber:@([slider minimumValue])];
    NSString *maxVal = [_numberFormatter stringFromNumber:@([slider maximumValue])];

    NSString *message = [NSString stringWithFormat:@"%@: %@ • %@: %@", [dict objectForKey:@"MIN_VALUE"], minVal, [dict objectForKey:@"MAX_VALUE"], maxVal];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[dict objectForKey:@"SET_SLIDER_VALUE"] message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [_numberFormatter stringFromNumber:@([self.controlValue floatValue])];
        textField.placeholder = [_numberFormatter stringFromNumber:@([self.controlValue floatValue])];
        textField.keyboardType = UIKeyboardTypeDecimalPad;

        [textField addNumericAccessory: true];
    }];

    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        float textFieldValue = [[[alertController textFields][0] text] floatValue];
        UISlider *slider = (UISlider *)[self control];

        [slider setValue:textFieldValue animated: true];
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.nightwind.boldersrebornprefs"];

        [userDefaults setObject:@(textFieldValue) forKey:self.specifier.identifier];
        [userDefaults synchronize];

        if (textFieldValue < slider.minimumValue || textFieldValue > slider.maximumValue) {
            action.enabled = false;
        } else {
            action.enabled = true;
        }
    }];

    [alertController addAction:confirmAction];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[dict objectForKey:@"CANCEL"] style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];

    [self._viewControllerForAncestor presentViewController:alertController animated:YES completion:nil];
}

@end

@implementation UITextField (NumericAccessory)

- (void)addNumericAccessory:(BOOL)addPlusMinus {
    UIToolbar *numberToolbar = [[UIToolbar alloc] init];
    numberToolbar.barStyle = UIBarStyleDefault;

    NSMutableArray *accessories = [[NSMutableArray alloc] init];

    if (addPlusMinus) {
        [accessories addObject:[[UIBarButtonItem alloc] initWithTitle:@"+/-"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(plusMinusPressed)]];
        [accessories addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil]]; // add padding after
    }

    [numberToolbar setItems:accessories];
    [numberToolbar sizeToFit];

    [self setInputAccessoryView:numberToolbar];
}

- (void)plusMinusPressed {
    NSString *currentText = [self text];
    if (currentText) {
        if ([currentText hasPrefix:@"-"]) {
            NSString *substring = [currentText substringFromIndex:1];
            [self setText:substring];
        } else {
            NSString *newText = [NSString stringWithFormat:@"-%@", currentText];
            [self setText:newText];
        }
    }
}

@end