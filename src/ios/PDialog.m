#import "PDialog.h"

@interface PDialog ()
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) CAShapeLayer *circularSpinner;
@end

@implementation PDialog

- (void)init:(CDVInvokedUrlCommand*)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Премахваме стария spinner
        if (self.circularSpinner != nil) {
            [self.circularSpinner removeFromSuperlayer];
            [self.blurView removeFromSuperview];
            [self.backgroundView removeFromSuperview];
            self.circularSpinner = nil;
        }

        UIView *rootView = self.viewController.view;

        // Background view
        self.backgroundView = [[UIView alloc] initWithFrame:rootView.bounds];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        // Винаги тъмен blur
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.blurView.frame = self.backgroundView.bounds;
        self.blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        // Много прозрачен overlay
        self.blurView.backgroundColor = [[UIColor colorWithWhite:0.0 alpha:0.05] colorWithAlphaComponent:0.05];

        [self.backgroundView addSubview:self.blurView];
        [rootView addSubview:self.backgroundView];

        // Circular spinner (винаги бял)
        CGFloat spinnerSize = 50.0;
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        circleLayer.strokeColor = [UIColor whiteColor].CGColor;
        circleLayer.fillColor = UIColor.clearColor.CGColor;
        circleLayer.lineWidth = 4.0;
        circleLayer.lineCap = kCALineCapRound;

        CGFloat radius = spinnerSize / 2.0;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius)
                                                            radius:radius - 2
                                                        startAngle:0
                                                          endAngle:M_PI * 1.5
                                                         clockwise:YES];
        circleLayer.path = path.CGPath;

        // Positioning
        circleLayer.frame = CGRectMake((rootView.bounds.size.width - spinnerSize)/2.0,
                                       (rootView.bounds.size.height - spinnerSize)/2.0,
                                       spinnerSize, spinnerSize);

        // Rotation animation
        CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotation.byValue = @(2 * M_PI);
        rotation.duration = 1.0;
        rotation.repeatCount = INFINITY;
        [circleLayer addAnimation:rotation forKey:@"rotationAnimation"];

        [self.backgroundView.layer addSublayer:circleLayer];
        self.circularSpinner = circleLayer;

        // Callback към JS
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    });
}

- (void)dismiss:(CDVInvokedUrlCommand*)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.circularSpinner != nil) {
            [self.circularSpinner removeFromSuperlayer];
            [self.blurView removeFromSuperview];
            [self.backgroundView removeFromSuperview];
            self.circularSpinner = nil;
        }

        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    });
}

@end

