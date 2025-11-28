#import "PDialog.h"
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

@interface PDialog () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UIView *spinnerContainer;
@property (nonatomic, strong) CAShapeLayer *circularSpinner;

// Нови свойства за галерия
@property (nonatomic, strong) CDVInvokedUrlCommand *galleryCommand;
@end

@implementation PDialog

#pragma mark - Spinner (оригинален код)

- (void)init:(CDVInvokedUrlCommand*)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *rootView = self.viewController.view;

        // Премахваме стария spinner
        if (self.spinnerContainer != nil) {
            [self.spinnerContainer removeFromSuperview];
            self.spinnerContainer = nil;
            self.circularSpinner = nil;
        }

        // Контейнер за spinner (кръгъл, тъмен и леко прозрачен)
        CGFloat containerSize = 80.0;
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerSize, containerSize)];
        container.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6]; // тъмен и прозрачен фон
        container.layer.cornerRadius = containerSize / 2.0;
        container.clipsToBounds = YES;
        container.center = rootView.center;

        [rootView addSubview:container];
        self.spinnerContainer = container;

        // Circular spinner (бял)
        CGFloat spinnerSize = 40.0;
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

        // Позициониране на spinner в центъра на контейнера
        circleLayer.frame = CGRectMake((containerSize - spinnerSize)/2.0,
                                       (containerSize - spinnerSize)/2.0,
                                       spinnerSize, spinnerSize);

        // Rotation animation
        CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotation.byValue = @(2 * M_PI);
        rotation.duration = 1.0;
        rotation.repeatCount = INFINITY;
        [circleLayer addAnimation:rotation forKey:@"rotationAnimation"];

        [container.layer addSublayer:circleLayer];
        self.circularSpinner = circleLayer;

        // Callback към JS
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    });
}

- (void)dismiss:(CDVInvokedUrlCommand*)command {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.spinnerContainer != nil) {
            [self.spinnerContainer removeFromSuperview];
            self.spinnerContainer = nil;
            self.circularSpinner = nil;
        }

        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    });
}

#pragma mark - Gallery (нови методи)

- (void)openGallery:(CDVInvokedUrlCommand*)command {
    self.galleryCommand = command;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        picker.allowsEditing = NO;
        
        // Премахваме спинъра точно след като галерията се появи
        [self.viewController presentViewController:picker animated:YES completion:^{
            if (self.spinnerContainer != nil) {
                [self.spinnerContainer removeFromSuperview];
                self.spinnerContainer = nil;
                self.circularSpinner = nil;
            }
        }];
    });
}


// Delegate метод след избор на снимка
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    __weak PDialog *weakSelf = self; // слаб референс за избягване на retain cycle
    [picker dismissViewControllerAnimated:YES completion:^{
        PDialog *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        // Показваме спинъра отново
        [strongSelf init:nil]; // използваме вече съществуващия метод за спинър
        
        NSURL *imageURL = [info valueForKey:UIImagePickerControllerImageURL];
        
        if (!imageURL) {
            // fallback за iOS < 11
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp_photo.jpg"];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            [imageData writeToFile:path atomically:YES];
            imageURL = [NSURL fileURLWithPath:path];
        }
        
        // Връщаме резултата към JS
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:imageURL.path];
        [strongSelf.commandDelegate sendPluginResult:result callbackId:strongSelf.galleryCommand.callbackId];
        strongSelf.galleryCommand = nil;
    }];
}


// Delegate метод при отказ
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"User canceled"];
    [self.commandDelegate sendPluginResult:result callbackId:self.galleryCommand.callbackId];
    self.galleryCommand = nil;
}

@end

