//
//  Logme.h
//
//  Free for use
//

#import <Foundation/Foundation.h>

#define LogmeDebug(s,...) [Logme logForLevel:LogLevelDebug file:__FILE__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define LogmeInfo(s,...) [Logme logForLevel:LogLevelInfo file:__FILE__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define LogmeWarn(s,...) [Logme logForLevel:LogLevelWarning file:__FILE__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define LogmeError(s,...) [Logme logForLevel:LogLevelError file:__FILE__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]

typedef NS_ENUM(NSUInteger, LogLevel) {
    LogLevelDebug = 40,
    LogLevelInfo = 30,
    LogLevelWarning = 20,
    LogLevelError = 10,
};

NS_ASSUME_NONNULL_BEGIN

@interface Logme : NSObject

+(void)setLevel:(LogLevel)newLevel;
+ (void) logForLevel:(LogLevel)level file: (char *) sourceFile lineNumber: (int) lineNumber format: (NSString *) format, ...;

@end

NS_ASSUME_NONNULL_END
