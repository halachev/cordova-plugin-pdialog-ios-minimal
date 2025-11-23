#import <Cordova/CDVPlugin.h>

@interface PDialog : CDVPlugin
- (void)init:(CDVInvokedUrlCommand*)command;
- (void)dismiss:(CDVInvokedUrlCommand*)command;
@end
