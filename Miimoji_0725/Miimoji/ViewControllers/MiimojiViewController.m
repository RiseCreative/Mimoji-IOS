//
//  MiimojiViewController.m
//  Miimoji
//
//  Created by Master of IT on 6/29/15.
//  Copyright (c) 2015 Queen. All rights reserved.
//

#import "AppDelegate.h"
#import "MiimojiViewController.h"
#import "HIPImageCropperView.h"
#import "SaveMiimojiViewController.h"
#import "CLImageToolBase.h"
#import "CLImageEditor.h"
#import "CLToolbarMenuItem.h"
#import "CLContrastTool.h"
#import "CLEffectTool.h"
#import "CLStickerTool.h"
#import "CLTextTool.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Extended.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@interface MiimojiViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, CLImageToolProtocol> {
    int opType;
    BOOL bVisitSaveMiimoji;

    UIImage* _originalImage; // Cropped image from gallery

    BOOL bFrontCamera;
    BOOL haveImage;
    BOOL bNotInitializedCamera; // YES : you have to initialize camera  NO : already initialized
    BOOL photoFromCam;
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    AVCaptureStillImageOutput *stillImageOutput;
}

@property (weak, nonatomic) IBOutlet UIButton *btnSwitchCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnGallery;
@property (weak, nonatomic) IBOutlet UIButton *btnPhotoCapture;
@property (weak, nonatomic) IBOutlet UIButton *btnContrast;
@property (weak, nonatomic) IBOutlet UIButton *btnColor;
@property (weak, nonatomic) IBOutlet UIButton *btnAccessory;
@property (weak, nonatomic) IBOutlet UIButton *btnCaption;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnApply;
@property (weak, nonatomic) IBOutlet UILabel *lblGlossary;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewForCropper;
@property (weak, nonatomic) IBOutlet UIButton *btnNavCreate;
@property (weak, nonatomic) IBOutlet UIView *filterView;
@property (weak, nonatomic) IBOutlet UIView *captureButtonView;
@property (weak, nonatomic) IBOutlet UIView *buttonView;

@property (nonatomic, strong) CLImageToolBase *currentTool;
@property (nonatomic, strong) HIPImageCropperView *cropperView;
@property (nonatomic, readwrite, strong) UIView *overlayView;

@property (weak, nonatomic) IBOutlet UIView *cameraPreview;
@property (weak, nonatomic) IBOutlet UIImageView *captureImage;
@property (weak, nonatomic) IBOutlet UIImageView *maskImageView;
@property (weak, nonatomic) IBOutlet UIView *cameraDoneButtBar;
@property (weak, nonatomic) IBOutlet UIView *cameraFlashButtonBar;
@property (weak, nonatomic) IBOutlet UIButton *flashToggleButton;
@property (weak, nonatomic) IBOutlet UIButton *gridToggleButton;

@end

@implementation MiimojiViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    bVisitSaveMiimoji = NO;
    
    [APPDELEGATE setSelectedPhoto:nil];

    [self setOpType:-1]; // Capture & Select Image Mode

    // Relative to Camera
    _cameraPreview.hidden = NO;
    _captureImage.hidden = YES;
    
    bFrontCamera = YES;
    bNotInitializedCamera = YES;
    photoFromCam = YES;

    self.btnNavCreate.enabled = NO;
    self.lblGlossary.text = self.glossary;
    
    // Set mask for CameraView
    [self setMaskForCameraView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Make navigation bar transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;

    //V !!
    if (bVisitSaveMiimoji == YES) {
        _originalImage = [[APPDELEGATE selectedPhoto] copy];
        [self refreshImageView];

        opType = 0;
        [self setButtonsVisible:opType];
    }

    // Relative to Camera
    self.cameraDoneButtBar.hidden = YES;
    self.btnSwitchCamera.selected = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (bNotInitializedCamera){
        bNotInitializedCamera = NO;
        
        // Initialize camera
        [self initializeCamera];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    if (_currentTool) {
        [_currentTool cleanup];
    }
}

-(void) dealloc
{
    if (session)
        session=nil;
    
    if (captureVideoPreviewLayer)
        captureVideoPreviewLayer=nil;
    
    if (stillImageOutput)
        stillImageOutput=nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - CAMERA INITIALIZATION =============

//AVCaptureSession to show live video feed in view
- (void) initializeCamera {
    if (session)
        session = nil;
    
    session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    if (captureVideoPreviewLayer)
        captureVideoPreviewLayer = nil;
    
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    captureVideoPreviewLayer.frame = self.cameraPreview.bounds;
    [_cameraPreview.layer addSublayer:captureVideoPreviewLayer];
    
    UIView *view = [self cameraPreview];
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera = nil;
    AVCaptureDevice *backCamera = nil;
    
    // Checks if device available
    if (devices.count == 0) {
        NSLog(@"No Camera Available");
        [self disableCameraDeviceControls];
        return;
    }
    
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    if (!bFrontCamera) {
        
        if ([backCamera hasFlash]){
            [backCamera lockForConfiguration:nil];
            if (self.flashToggleButton.selected)
                [backCamera setFlashMode:AVCaptureFlashModeOn];
            else
                [backCamera setFlashMode:AVCaptureFlashModeOff];
            [backCamera unlockForConfiguration];
            
            self.flashToggleButton.enabled = YES;
        }
        else {
            if ([backCamera isFlashModeSupported:AVCaptureFlashModeOff]) {
                [backCamera lockForConfiguration:nil];
                [backCamera setFlashMode:AVCaptureFlashModeOff];
                [backCamera unlockForConfiguration];
            }
            self.flashToggleButton.enabled = NO;
        }
        
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        [session addInput:input];
    }
    
    if (bFrontCamera) {
        self.flashToggleButton.enabled = NO;
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        [session addInput:input];
    }
    
    if (stillImageOutput)
        stillImageOutput = nil;
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    
    [session startRunning];
}

// Method to capture Image from AVCaptureSession
- (void) capImageFromSession {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    NSLog(@"about to request a capture from: %@", stillImageOutput);
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if (imageSampleBuffer != NULL) {
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            [self processImage:[UIImage imageWithData:imageData]];
        }
    }];
}

- (UIImage*)imageWithImage:(UIImage *)sourceImage scaledToWidth:(float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


//process captured image, crop, resize and rotate
- (void) processImage:(UIImage *)image {
    haveImage = YES;
    photoFromCam = YES;
    
    if (bFrontCamera) {
        UIImage* fixedImage = [image fixOrientation];
        _captureImage.image = [UIImage imageWithCGImage:fixedImage.CGImage
                                                  scale:fixedImage.scale
                                            orientation:UIImageOrientationUpMirrored];
    } else {
        _captureImage.image = image;
    }
    
    [self setCapturedImage];
}

- (void)setCapturedImage{
    // Stop capturing image
    [session stopRunning];
    
    // Hide Top/Bottom controller after taking photo for editing
    [self hideControllers];
}

#pragma mark - Device Availability Controls
- (void)disableCameraDeviceControls{
    self.btnSwitchCamera.enabled = NO;
    self.btnPhotoCapture.enabled = NO;
    self.flashToggleButton.enabled = NO;
}

- (IBAction)toggleFlash:(UIButton *)sender {
    if (!bFrontCamera) {
        if (sender.selected) { // Set flash off
            [sender setSelected:NO];
            
            NSArray *devices = [AVCaptureDevice devices];
            for (AVCaptureDevice *device in devices) {
                
                NSLog(@"Device name: %@", [device localizedName]);
                
                if ([device hasMediaType:AVMediaTypeVideo]) {
                    
                    if ([device position] == AVCaptureDevicePositionBack) {
                        NSLog(@"Device position : back");
                        if ([device hasFlash]){
                            
                            [device lockForConfiguration:nil];
                            [device setFlashMode:AVCaptureFlashModeOff];
                            [device unlockForConfiguration];
                            
                            break;
                        }
                    }
                }
            }
            
        } else {           // Set flash on
            [sender setSelected:YES];
            
            NSArray *devices = [AVCaptureDevice devices];
            for (AVCaptureDevice *device in devices) {
                
                NSLog(@"Device name: %@", [device localizedName]);
                
                if ([device hasMediaType:AVMediaTypeVideo]) {
                    
                    if ([device position] == AVCaptureDevicePositionBack) {
                        NSLog(@"Device position : back");
                        if ([device hasFlash]){
                            
                            [device lockForConfiguration:nil];
                            [device setFlashMode:AVCaptureFlashModeOn];
                            [device unlockForConfiguration];
                            
                            break;
                        }
                    }
                }
            }
        }
    }
}

- (IBAction)gridToogle:(UIButton *)sender{
    if (sender.selected) {
        sender.selected = NO;
        [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
            self.maskImageView.alpha = 0.0f;
        } completion:nil];
    }
    else{
        sender.selected = YES;
        [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
            self.maskImageView.alpha = 1.0f;
        } completion:nil];
    }
}

-(IBAction) cancelCamera:(id)sender {
    [self processWhenHideCamera];
}

- (IBAction)retakePhoto:(id)sender{
    _btnPhotoCapture.enabled = YES;
    self.btnSwitchCamera.enabled = YES;
    _captureImage.image = nil;
    _cameraPreview.hidden = NO;
    
    // Shows Camera Controls
    [self showControllers];
    
    haveImage = NO;
    [self performSelector:@selector(initializeCamera) withObject:nil afterDelay:0.001];
}

- (IBAction)donePhotoCapture:(id)sender {
    [APPDELEGATE setSelectedPhoto:self.captureImage.image];
    [self processWhenHideCamera];

    if (bVisitSaveMiimoji == NO) {
        [self addCropperView];
    }
}

- (void)addCropperView {
    [self.cropperView removeFromSuperview];
    self.cropperView = nil;
    
    CGFloat h = [APPDELEGATE mainScreenSize].height / 2 - 50;
    CGFloat w = h * 0.75;
    CGSize cropSize = CGSizeMake(w, h);
    self.cropperView = [[HIPImageCropperView alloc]
                        initWithFrame:self.scrollViewForCropper.bounds
                        cropAreaSize:cropSize]; // cropRect position : center of scrollViewForCropper
    [self.cropperView setImage:[APPDELEGATE selectedPhoto]];
    [self.scrollViewForCropper addSubview:self.cropperView];
}

#pragma mark - Show/Hide Topbar controls
- (void)hideControllers{
    [UIView animateWithDuration:0.2 animations:^{
        _cameraPreview.hidden = YES;
        _cameraFlashButtonBar.hidden = YES;
        _cameraDoneButtBar.hidden = NO;
        
    } completion:nil];
}

- (void)showControllers{
    [UIView animateWithDuration:0.2 animations:^{
        self.cameraFlashButtonBar.hidden = NO;
        self.cameraDoneButtBar.hidden = YES;
    } completion:nil];
}

#pragma mark - UI Method
- (void)setOpType:(int)val {
    if (opType == val) return;
    
    opType = val;
    [self setButtonsVisible:opType];
}

- (void)setAllButtonsHidden {
    self.captureButtonView.hidden = YES;
    self.toolView.hidden = YES;
    self.menuView.hidden = YES;
    self.buttonView.hidden = YES;
}

- (void)setBkColorForFilterViewButtons:(int)type {
    UIColor* color = [UIColor colorWithRed:227.0/255 green:14.0/255 blue:2.0/255 alpha:1];
    UIColor* selColor = [UIColor colorWithRed:1.0 green:100.0/255 blue:1.0/255 alpha:1];
    self.btnContrast.backgroundColor = color;
    self.btnColor.backgroundColor = color;
    self.btnAccessory.backgroundColor = color;
    self.btnCaption.backgroundColor = color;
    
    switch (type) {
        case 0:
            self.btnContrast.backgroundColor = selColor;
            break;
        case 1:
            self.btnColor.backgroundColor = selColor;
            break;
        case 2:
            self.btnAccessory.backgroundColor = selColor;
            break;
        case 3:
            self.btnCaption.backgroundColor = selColor;
            break;
        default:
            break;
    }
}

- (void)setButtonsVisible:(int)type {
    [self setAllButtonsHidden];
    [self setBkColorForFilterViewButtons:type];
    
    [APPDELEGATE setBNeedToApply:NO];
    [self enableButtonsForNeedToApply];
    
    BOOL bHideCamera = (type != -1);
    self.captureButtonView.hidden = bHideCamera;
    self.toolView.hidden = !bHideCamera;
    self.buttonView.hidden = !bHideCamera;
    
    switch (type) {
        case 0: // Contrast
            self.currentTool = [[CLContrastTool alloc] initWithImageEditor:self withToolInfo:nil];
            break;
        case 1: // Color
            self.currentTool = [[CLEffectTool alloc] initWithImageEditor:self withToolInfo:nil];
            break;
        case 2: // Accessory
            self.currentTool = [[CLStickerTool alloc] initWithImageEditor:self withToolInfo:nil];
            break;
        case 3: // Caption
            self.currentTool = [[CLTextTool alloc] initWithImageEditor:self withToolInfo:nil];
            break;
        default:
            break;
    }
}

- (void)addOverlayView {
    [self.overlayView removeFromSuperview];
    self.overlayView = nil;
    
    self.overlayView = [[UIView alloc] initWithFrame:self.scrollViewForCropper.bounds];
    [self.overlayView setUserInteractionEnabled:NO];
    [self.overlayView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    [self.overlayView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                           UIViewAutoresizingFlexibleHeight)];
    [self.scrollViewForCropper addSubview:self.overlayView];
    
    // Set Mask layer
    for (UIView *subview in [self.overlayView subviews]) {
        [subview removeFromSuperview];
    }
    
    CAShapeLayer *maskWithHole = [CAShapeLayer layer];
    
    CGSize maskSize = self.overlayView.frame.size;
    CGRect biggerRect = self.overlayView.bounds;
    CGRect smallerRect = CGRectMake((biggerRect.size.width - maskSize.width) / 2.0,
                                    (biggerRect.size.height - maskSize.height) / 2.0,
                                    maskSize.width, maskSize.height);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    
    CGFloat h = [APPDELEGATE mainScreenSize].height / 2 - 50;
    CGFloat w = h * 0.75;
    CGSize sz = CGSizeMake(w, h); // smallerRect.size;
    CGPoint pt = CGPointMake(smallerRect.origin.x + smallerRect.size.width / 2 - sz.width / 2,
                             smallerRect.origin.y + smallerRect.size.height / 2 - sz.height / 2);// smallerRect.origin;
    
    NSArray *points = [NSArray arrayWithObjects:
                       [NSValue valueWithCGPoint:CGPointMake(pt.x + sz.width / 2, pt.y)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x, pt.y)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x, pt.y + sz.height / 2)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x, pt.y + sz.height)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x + sz.width / 2, pt.y + sz.height)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x + sz.width, pt.y + sz.height)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x + sz.width, pt.y + sz.height / 2)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x + sz.width, pt.y)],
                       nil];
    
    [maskPath moveToPoint:[points[0] CGPointValue]];
    [maskPath addQuadCurveToPoint:[points[2] CGPointValue] controlPoint:[points[1] CGPointValue]];
    [maskPath addQuadCurveToPoint:[points[4] CGPointValue] controlPoint:[points[3] CGPointValue]];
    [maskPath addQuadCurveToPoint:[points[6] CGPointValue] controlPoint:[points[5] CGPointValue]];
    [maskPath addQuadCurveToPoint:[points[0] CGPointValue] controlPoint:[points[7] CGPointValue]];
    
    [maskWithHole setFrame:self.overlayView.bounds];
    [maskWithHole setFillRule:kCAFillRuleEvenOdd];
    [maskWithHole setPath:[maskPath CGPath]];
    
    [self.overlayView.layer setMask:maskWithHole];
}

- (void)setMaskForCameraView {

    UIView* maskView = nil;
    
    CGSize mainScreenSize = [APPDELEGATE mainScreenSize];
    maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                        mainScreenSize.width,
                                                        mainScreenSize.height / 2)];
    [maskView setUserInteractionEnabled:NO];
    [maskView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    [maskView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                           UIViewAutoresizingFlexibleHeight)];
    [self.maskImageView addSubview:maskView];
    
    CAShapeLayer *maskWithHole = [CAShapeLayer layer];
    
    CGRect biggerRect = maskView.bounds;
    CGRect smallerRect = biggerRect;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    
    [maskPath moveToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMaxY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMaxX(biggerRect), CGRectGetMinY(biggerRect))];
    [maskPath addLineToPoint:CGPointMake(CGRectGetMinX(biggerRect), CGRectGetMinY(biggerRect))];
    
    CGFloat h = [APPDELEGATE mainScreenSize].height / 2 - 50;
    CGFloat w = h * 0.75;
    CGSize sz = CGSizeMake(w, h);
    CGPoint pt = CGPointMake((smallerRect.size.width - sz.width) / 2,
                             (smallerRect.size.height - sz.height) / 2);
    
    NSArray *points = [NSArray arrayWithObjects:
                       [NSValue valueWithCGPoint:CGPointMake(pt.x + sz.width / 2, pt.y)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x, pt.y)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x, pt.y + sz.height / 2)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x, pt.y + sz.height)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x + sz.width / 2, pt.y + sz.height)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x + sz.width, pt.y + sz.height)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x + sz.width, pt.y + sz.height / 2)],
                       [NSValue valueWithCGPoint:CGPointMake(pt.x + sz.width, pt.y)],
                       nil];
    
    [maskPath moveToPoint:[points[0] CGPointValue]];
    [maskPath addQuadCurveToPoint:[points[2] CGPointValue] controlPoint:[points[1] CGPointValue]];
    [maskPath addQuadCurveToPoint:[points[4] CGPointValue] controlPoint:[points[3] CGPointValue]];
    [maskPath addQuadCurveToPoint:[points[6] CGPointValue] controlPoint:[points[5] CGPointValue]];
    [maskPath addQuadCurveToPoint:[points[0] CGPointValue] controlPoint:[points[7] CGPointValue]];
    
    [maskWithHole setFrame:maskView.bounds];
    [maskWithHole setFillRule:kCAFillRuleEvenOdd];
    [maskWithHole setPath:[maskPath CGPath]];
    
    [maskView.layer setMask:maskWithHole];
}

- (void)enableButtonsForNeedToApply {

    if ([APPDELEGATE bNeedToApply]) {
        self.btnCancel.enabled = YES;
        self.btnApply.enabled = YES;
    } else {
        self.btnCancel.enabled = NO;
        self.btnApply.enabled = NO;
    }
}

#pragma mark - Button Click Methods
- (IBAction)onBtnSwitchCamera:(UIButton*)sender {

    if (self.cameraPreview.hidden == YES)
        return;

    // Stop current recording process
    [session stopRunning];
    
    if (bFrontCamera) // Switch to Back camera
        bFrontCamera = NO;
    else // Switch to Front camera
        bFrontCamera = YES;

    [self performSelector:@selector(initializeCamera) withObject:nil afterDelay:0.001];
}

- (IBAction)onBtnGallery:(id)sender {
    [self displayImagePickerWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)onBtnPhotoCapture:(id)sender {
    
    if (self.cameraPreview.hidden == NO) {
        _btnPhotoCapture.enabled = NO;
        self.btnSwitchCamera.enabled = NO;
        
        if (!haveImage) {
            _captureImage.image = nil; //remove old image from view
            _captureImage.hidden = NO; //show the captured image view
//            _cameraPreview.hidden = YES; //hide the live video feed
            
            [self capImageFromSession];
            
        } else {
            _captureImage.hidden = YES;
            _cameraPreview.hidden = NO;
            haveImage = NO;
        }
    } else {
        [self retakePhoto:sender];
        self.btnNavCreate.enabled = NO;
    }
}

- (IBAction)onBtnCancel:(id)sender {
    [self refreshImageView];
    self.currentTool = nil;
    int curOpType = opType;
    opType = 99;
    [self setOpType:curOpType];
}

- (IBAction)onBtnApply:(id)sender {
    // Apply filtering
    self.view.userInteractionEnabled = NO;
    
    [self.currentTool executeWithCompletionBlock:^(UIImage *image, NSError *error, NSDictionary *userInfo) {
        if(error){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else if(image){
            _originalImage = [image deepCopy];
            [self refreshImageView];

            [APPDELEGATE setBNeedToApply:NO];
            [self enableButtonsForNeedToApply];
        }
        self.view.userInteractionEnabled = YES;
    }];

}

- (IBAction)onBtnContrast:(id)sender {
    if (opType == -1) return;
    [self refreshImageView];
    [self setOpType:0];
}

- (IBAction)onBtnColor:(id)sender {
    if (opType == -1) return;
    [self refreshImageView];
    [self setOpType:1];
}

- (IBAction)onBtnAccessory:(id)sender {
    if (opType == -1) return;
    [self refreshImageView];
    [self setOpType:2];
}

- (IBAction)onBtnCaption:(id)sender {
    if (opType == -1) return;
    [self refreshImageView];
    [self setOpType:3];
}

- (IBAction)onNavBtnCreate:(UIButton*)sender {
    if (sender.tag == 0) {
        _originalImage = [[self.cropperView processedImage] deepCopy];
        
        // Set Fixed ImageView
        if(_imageView == nil){
            _imageView = [UIImageView new];
            self.cropperView.hidden = YES;
            
            [_scrollViewForCropper addSubview:_imageView];
            [self refreshImageView];
            
            // Set Overlay
//            [self addOverlayView];
        }
        
        [self.btnNavCreate setTitle:@"Create" forState:UIControlStateNormal];
        self.btnNavCreate.tag = 1;
        [self setOpType:0];
    }
    else {
        if ([APPDELEGATE bNeedToApply]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Do you cancel the last changes?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Yes"
                                                  otherButtonTitles:@"No", nil];
            alertView.tag = 1;
            [alertView show];
        } else {
            [self saveCurrentMiimoji];
        }
    }
}

- (void)saveCurrentMiimoji {
    [APPDELEGATE setSelectedPhoto:_originalImage];
    
    // In case of back from SaveMiimojiViewController
    bVisitSaveMiimoji = YES;
    
    //V !! Present viewcontroller by push
    SaveMiimojiViewController* viewController = nil;
    viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"saveMiimojiController"];
    viewController.miimojiName = self.glossary;
    [[self navigationController] pushViewController:viewController animated:YES];
}

#pragma mark - ImageView Methods
- (void)setCurrentTool:(CLImageToolBase *)currentTool
{
    if(currentTool != _currentTool){
        [_currentTool cleanup];
        _currentTool = currentTool;
        [_currentTool setup];
    }
}

- (void)fixZoomScaleWithAnimated:(BOOL)animated {
    
}

- (void)refreshImageView
{
    _imageView.image = _originalImage;
    [self resetImageViewFrame];
    [self resetZoomScaleWithAnimated:NO];
}

- (void)resetImageViewFrame  {
    CGSize size = (_imageView.image) ? _imageView.image.size : _imageView.frame.size;
    if(size.width>0 && size.height>0){
        CGFloat ratio = MIN(_scrollViewForCropper.frame.size.width / size.width, _scrollViewForCropper.frame.size.height / size.height);
        CGFloat W = ratio * size.width * _scrollViewForCropper.zoomScale;
        CGFloat H = ratio * size.height * _scrollViewForCropper.zoomScale;
        
        _imageView.frame = CGRectMake((_scrollViewForCropper.width-W)/2, 0, W, H);
        [_scrollViewForCropper setContentSize:CGSizeMake(0, 0)];
    }
}

- (void)resetZoomScaleWithAnimated:(BOOL)animated
{
    CGFloat Rw = _scrollViewForCropper.frame.size.width / _imageView.frame.size.width;
    CGFloat Rh = _scrollViewForCropper.frame.size.height / _imageView.frame.size.height;
    
    CGFloat scale = 1;
    Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollViewForCropper.frame.size.width));
    Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollViewForCropper.frame.size.height));
    
    _scrollViewForCropper.contentSize = _imageView.frame.size;
    _scrollViewForCropper.minimumZoomScale = 1;
    _scrollViewForCropper.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
    
    [_scrollViewForCropper setZoomScale:_scrollViewForCropper.minimumZoomScale animated:animated];
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //V !! Camera Image
    /* You can change the cropperView image by only choose photo from gallery.
       But if you get photo from camera, you have to run this statement.
       [self.cropperView setImage:[APPDELEGATE selectedPhoto]];
     */
    
    [APPDELEGATE setSelectedPhoto:info[UIImagePickerControllerOriginalImage]];
    
    // Load saved item
    [picker dismissViewControllerAnimated:YES completion:^(void){
        [self processWhenHideCamera];

        if (bVisitSaveMiimoji == NO) {
            [self addCropperView];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - YCameraViewController Delegate

- (void)processWhenHideCamera {
    self.cameraPreview.hidden = YES;
    self.captureImage.hidden = YES;
    
    self.cameraFlashButtonBar.hidden = YES;
    self.cameraDoneButtBar.hidden = YES;
    
    self.btnSwitchCamera.enabled = NO;
    self.btnPhotoCapture.enabled = YES;
    
    self.btnNavCreate.enabled = YES;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1:
            if (buttonIndex == alertView.cancelButtonIndex) {
                [self saveCurrentMiimoji];
            } else if (buttonIndex == 1) {
                
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - Util Methods
-(void) displayImagePickerWithSource:(UIImagePickerControllerSourceType)srcType
{
    if([UIImagePickerController isSourceTypeAvailable:srcType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        [picker setSourceType:srcType];
        [picker setDelegate:self];
        picker.allowsEditing = NO;
        
        // allowing editing is nice, but only returns a small 320px image
        //        [picker setAllowsImageEditing:YES];
        [self presentViewController:picker animated:YES completion:nil];
    }
}

// Make UIImage from UIColor
- (UIImage *)imageFromColor:(UIColor *)color {
   CGRect rect = CGRectMake(0, 0, 30, 30);
   UIGraphicsBeginImageContext(rect.size);
   CGContextRef context = UIGraphicsGetCurrentContext();
   CGContextSetFillColorWithColor(context, [color CGColor]);
   CGContextFillRect(context, rect);
   UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
   return image;
}

- (void)makeButtonRound:(UIButton*)button WithCornerRadius:(CGFloat)cornderRadius BorderWidth:(CGFloat)borderWidth AndBorderColor:(UIColor*)borderColor {
    button.layer.cornerRadius = cornderRadius;
    button.layer.borderWidth = borderWidth;
    button.layer.borderColor = borderColor.CGColor;
    // (note - may prefer to use the tintColor of the control)
}

@end
