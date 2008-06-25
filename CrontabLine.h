
@protocol CrontabLine

- (id)initWithString: (NSString *)line;
+ (BOOL)isContainedInString: (NSString *)line;

- (NSData *)data;

@end