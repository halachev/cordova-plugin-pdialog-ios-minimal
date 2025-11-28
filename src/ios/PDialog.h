#import <Cordova/CDVPlugin.h>
#import <UIKit/UIKit.h>

@interface PDialog : CDVPlugin <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

// Оригинални методи
- (void)init:(CDVInvokedUrlCommand*)command;
- (void)dismiss:(CDVInvokedUrlCommand*)command;

// Нов метод за отваряне на галерия
- (void)openGallery:(CDVInvokedUrlCommand*)command;

@end
