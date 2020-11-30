#import "FlutterCodeInjectionPlugin.h"
#include <mach-o/dyld.h>

@implementation FlutterCodeInjectionPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter.eyro.co.id/flutter_code_injection"
                                     binaryMessenger:[registrar messenger]];
    FlutterCodeInjectionPlugin* instance = [[FlutterCodeInjectionPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getWhiteListLibraries" isEqualToString:call.method]) {
        result([self getWhiteListLibraries]);
        return;
    }
    
    if ([@"checkWhiteListLibraries" isEqualToString:call.method]) {
        [self checkWhiteListLibraries: call.arguments result:result];
        return;
    }
    
    if ([@"checkDynamicLibrary" isEqualToString:call.method]) {
        char *env = getenv("DYLD_INSERT_LIBRARIES");
        if (env == nil) {
            result(nil);
        } else {
            result([FlutterError errorWithCode:@"DYNAMIC_LIBRARY"
                                       message:@"There is a dynamic library inserted!"
                                       details:[NSString stringWithUTF8String:env]]);
        }
        return;
    }
    
    result(FlutterMethodNotImplemented);
}

- (NSArray*) getWhiteListLibraries {
    // https://developpaper.com/ios-application-code-injection-protection/
    // https://pewpewthespells.com/blog/blocking_code_injection_on_ios_and_os_x.html
    
    NSMutableArray *array = [NSMutableArray array];
    int count = _dyld_image_count();
    
    for (int i = 0; i < count; i++) {
        // Traverse to get the library name!
        const char * imageName = _dyld_get_image_name(i);
        [array addObject:[NSString stringWithUTF8String:imageName]];
    }
    return [NSArray arrayWithArray:array];
}

- (void) checkWhiteListLibraries:(id)arguments result:(FlutterResult)result {
    if (![arguments isKindOfClass:[NSArray class]]) {
        result([FlutterError errorWithCode:@"ARGUMENTS"
                                   message:@"Invalid arguments, array of string required!"
                                   details:nil]);
        return;
    }
    
    NSMutableArray<NSString *> *unListedLibraries = [NSMutableArray array];
    NSArray<NSString *> *array = arguments;
    const char *libraries = [[array componentsJoinedByString:@";"] UTF8String];
    
    int count = _dyld_image_count();
    for (int i = 0; i < count; i++) {
        // Traverse to get the library name!
        const char * imageName = _dyld_get_image_name(i);
        
        if (!strstr(libraries, imageName) && !strstr(imageName, "/var/mobile/Containers/Bundle/Application")) {
            // Workaround to filter the generated UUID of an Application
            BOOL notListed = NO;
            for (NSString *lib in array) {
                if (!strstr(imageName, [lib UTF8String])) {
                    notListed = YES;
                    break;
                }
            }
            
            if (notListed) {
                [unListedLibraries addObject:[NSString stringWithUTF8String:imageName]];
            }
        }
    }
    
    if (unListedLibraries.count > 0) {
        FlutterError *error = [FlutterError errorWithCode:@"UNLISTED_LIBRARY"
                                                  message:@"Some libraries are not in white list!"
                                                  details:unListedLibraries];
        result(error);
        return;
    }
    
    result(@(YES));
}

@end
