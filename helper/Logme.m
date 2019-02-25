//
//  Logme.m
//
//  Free for use
//

#import "Logme.h"

#import <Foundation/Foundation.h>
#import <stdio.h>

#ifndef NDEBUG
extern void _NSSetLogCStringFunction(void (*)(const char *string, unsigned length, BOOL withSyslogBanner));
static void PrintNSLogMessage(const char *string, unsigned length, BOOL withSyslogBanner){ puts(string); }
static void HackNSLog(void) __attribute__((constructor));
static void HackNSLog(void){ _NSSetLogCStringFunction(PrintNSLogMessage); }
#endif

static LogLevel __level = LogLevelError; // default
static BOOL __LogMeIsActive = NO;

@implementation Logme
+(void)setLevel:(LogLevel)newLevel {
    __level = newLevel;
}
+ (void) setLogActive: (BOOL) value { __LogMeIsActive = value; }

+ (void) initialize { char * env = getenv("LogMeIsActive");
    if (strcmp(env == NULL ? "" : env, "NO") != 0) {
        __LogMeIsActive = YES;
    }
}

+ (void) logForLevel:(LogLevel)level file: (char *) sourceFile lineNumber: (int) lineNumber format: (NSString *) format, ...; {
    if (level > __level) return;

    va_list ap;    NSString *print, *file;
    if (__LogMeIsActive == NO) return;   va_start(ap, format);
    file  = [[NSString alloc] initWithBytes: sourceFile                  length:strlen(sourceFile) encoding: NSUTF8StringEncoding];
    print = [[NSString alloc] initWithFormat:format arguments: ap];
    va_end(ap); // NSLog handles synchronization issues
    NSLog(@"%s: %d %@", [[file lastPathComponent] UTF8String], lineNumber, print); return;
}

@end
