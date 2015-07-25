/*=====================
 -- Pixl --
 
 Created for CodeCanyon
 by FV iMAGINATION
 =====================*/

#import <iAd/iAd.h>
#import <AudioToolbox/AudioToolbox.h>
//#import "GADBannerView.h"


#import "CLImageEditor.h"

@interface _CLImageEditorViewController : CLImageEditor <
UIScrollViewDelegate,
UIBarPositioningDelegate
>
{
    IBOutlet __weak UINavigationBar *_navigationBar;
    IBOutlet __weak UIScrollView *_scrollView;
}

//Ad banners properties
@property (strong, nonatomic) ADBannerView *iAdBannerView;


@property (nonatomic, strong) UIImageView  *imageView;
@property (nonatomic, weak) IBOutlet UIScrollView *menuView;

- (IBAction)pushedCloseBtn:(id)sender;
- (IBAction)pushedFinishBtn:(id)sender;


- (id)initWithImage:(UIImage*)image;


- (void)fixZoomScaleWithAnimated:(BOOL)animated;
- (void)resetZoomScaleWithAnimated:(BOOL)animated;

@end
