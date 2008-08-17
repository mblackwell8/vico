#import "ViTheme.h"

@implementation ViTheme

- (NSColor *)hashRGBToColor:(NSString *)hashRGB
{
	//NSLog(@"%s saving foreground color %@", _cmd, foreground);
	int r, g, b;
	if(sscanf([hashRGB UTF8String], "#%02X%02X%02X", &r, &g, &b) != 3)
		return nil;
	return [NSColor colorWithDeviceRed:(float)r/256.0 green:(float)g/256.0 blue:(float)b/256.0 alpha:1.0];
}

- (id)initWithBundle:(NSString *)aBundleName
{
	self = [super init];
	if(self == nil)
		return nil;

	NSString *path = [[NSBundle mainBundle] pathForResource:aBundleName ofType:@"tmTheme"];
	theme = [NSDictionary dictionaryWithContentsOfFile:path];

	themeAttributes = [[NSMutableDictionary alloc] init];
	NSArray *settings = [theme objectForKey:@"settings"];
	NSDictionary *setting;
	for(setting in settings)
	{
		NSString *scope = [setting objectForKey:@"scope"];
		NSArray *scope_selectors = [scope componentsSeparatedByString:@", "];
		NSString *foreground = [[setting objectForKey:@"settings"] objectForKey:@"foreground"];
		if(foreground == nil)
			continue;
		NSMutableDictionary *attrs = [[NSMutableDictionary alloc] init];	
		[attrs setObject:[self hashRGBToColor:foreground] forKey:NSForegroundColorAttributeName];

		NSString *background = [[setting objectForKey:@"settings"] objectForKey:@"background"];
		if(background)
		{
			[attrs setObject:[self hashRGBToColor:background] forKey:NSBackgroundColorAttributeName];
		}

		for(scope in scope_selectors)
		{
			[themeAttributes setObject:attrs forKey:scope];
			NSLog(@"%s  %@ = %@", _cmd, scope, attrs);
		}
	}

	return self;
}

- (NSDictionary *)attributeForScopeSelector:(NSString *)aScopeSelector
{
	NSString *scope;
	for(scope in [themeAttributes allKeys])
	{
		if([aScopeSelector hasPrefix:scope])
		{
			return [themeAttributes objectForKey:scope];
		}
	}

	NSLog(@"scope [%@] has no attributes", aScopeSelector);
	return nil;
}

@end
