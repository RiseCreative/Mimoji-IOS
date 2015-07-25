//
//  UIImage+Crop.h
//

#import <UIKit/UIKit.h>

@interface UIImage(Extended)

- (UIImage *)crop:(CGRect)rect;
- (UIImage *)fixOrientation;
- (UIImage*)resizedImageToSize:(CGSize)dstSize;
- (UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale;

@end

