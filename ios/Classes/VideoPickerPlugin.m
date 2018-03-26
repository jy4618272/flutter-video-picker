#import "VideoPickerPlugin.h"
#import <MobileCoreServices/MobileCoreServices.h>

@import UIKit;

@interface VideoPickerPlugin ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

static const int SOURCE_ASK_USER = 0;
static const int SOURCE_CAMERA = 1;
static const int SOURCE_GALLERY = 2;

@implementation VideoPickerPlugin {
    FlutterResult _result;
    NSDictionary *_arguments;
    UIImagePickerController *_videoPicker;
    UIViewController *_viewController;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"video_picker"
            binaryMessenger:[registrar messenger]];
  UIViewController *viewController =
    [UIApplication sharedApplication].delegate.window.rootViewController;
  VideoPickerPlugin* instance = [[VideoPickerPlugin alloc] initWithViewController:viewController];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
        _videoPicker = [[UIImagePickerController alloc] init];
    }
    return self;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // This is the NSURL of the video object
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    NSLog(@"VideoURL = %@", videoURL);
    NSString *myString = videoURL.absoluteString;
    _result(myString);
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if (_result) {
        _result([FlutterError errorWithCode:@"multiple_request"
                                    message:@"Cancelled by a second request"
                                    details:nil]);
        _result = nil;
    }
    
  if ([@"pickVideo" isEqualToString:call.method]) {
      
      _videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
      _videoPicker.delegate = self;
      
      _result = result;
      _arguments = call.arguments;
      
      int imageSource = [[_arguments objectForKey:@"source"] intValue];
      
      switch (imageSource) {
          case SOURCE_ASK_USER:
              //result(@"SOURCE_ASK_USER");
              [self showImageSourceSelector];
              break;
          case SOURCE_CAMERA:
              //result(@"SOURCE_CAMERA");
              [self showCamera];
              break;
          case SOURCE_GALLERY:
              //result(@"SOURCE_GALLERY");
              [self showPhotoLibrary];
              break;
          default:
              result([FlutterError errorWithCode:@"invalid_source"
                                         message:@"Invalid image source."
                                         details:nil]);
              break;
      }
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)showImageSourceSelector {
    UIAlertControllerStyle style = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
    ? UIAlertControllerStyleAlert
    : UIAlertControllerStyleActionSheet;
    
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:style];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Take Video"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [self showCamera];
                                                   }];
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Choose Video"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        [self showPhotoLibrary];
                                                    }];
    UIAlertAction *cancel =
    [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:camera];
    [alert addAction:library];
    [alert addAction:cancel];
    [_viewController presentViewController:alert animated:YES completion:nil];
}

- (void)showCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _videoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //_videoPicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        //_videoPicker.allowsEditing = false;
        //_videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
        //_videoPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        [_viewController presentViewController:_videoPicker animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Camera not available."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)showPhotoLibrary {
    _videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
    _videoPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    //_videoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [_viewController presentViewController:_videoPicker animated:YES completion:nil];
}
@end
