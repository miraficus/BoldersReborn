#import <Foundation/Foundation.h>
#import <rootless.h>

NSDictionary *localizationDictionary(void) {
	static NSDictionary *bundleDictionary = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		NSString *const genericPath = ROOT_PATH_NS(@"/Library/PreferenceBundles/BoldersRebornPrefs.bundle/Localization/LANG.lproj/Localization.strings");
		NSString *filePath = [genericPath stringByReplacingOccurrencesOfString:@"LANG" withString:NSLocale.currentLocale.languageCode];

		if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
			filePath = ROOT_PATH_NS(@"/Library/PreferenceBundles/BoldersRebornPrefs.bundle/Localization/en.lproj/Localization.strings");
		}

		bundleDictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
	});

	return bundleDictionary;
}