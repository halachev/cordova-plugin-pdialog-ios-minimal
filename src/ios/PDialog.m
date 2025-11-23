#import "PDialog.h"

@interface PDialog ()
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIView *backgroundView;
@end

@implementation PDialog

- (void)init:(CDVInvokedUrlCommand*)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.spinner != nil) {
            [self.spinner stopAnimating];
            [self.backgroundView removeFromSuperview];
            self.spinner = nil;
        }

        UIView *rootView = self.viewController.view;

        self.backgroundView = [[UIView alloc] initWithFrame:rootView.bounds];
        self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];

        self.spinner = [[UIActivityIndicatorView alloc]
                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        self.spinner.center = rootView.center;

        [self.backgroundView addSubview:self.spinner];
        [rootView addSubview:self.backgroundView];

        [self.spinner startAnimating];

        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    });
}

- (void)dismiss:(CDVInvokedUrlCommand*)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.spinner != nil) {
            [self.spinner stopAnimating];
            [self.backgroundView removeFromSuperview];
            self.spinner = nil;
        }

        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    });
}

@end
