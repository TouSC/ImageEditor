//
//  ImageViewController.m
//  Test
//
//  Created by 唐绍成 on 2020/5/2.
//  Copyright © 2020 唐绍成. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@property(nonatomic,strong)UIImageView *imageView;

@property(nonatomic,strong)UISlider *slider;

@property(nonatomic,strong)UISwitch *switcher;

@property(nonatomic,strong)UIColor *color;

@end

@implementation ImageViewController
{
    BOOL isExclude;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isExclude = YES;
    // Do any additional setup after loading the view.
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.switcher];
    self.switcher.frame = CGRectMake(10, self.view.bounds.size.height-50, 100, 40);
    [self.view addSubview:self.slider];
    self.slider.frame = CGRectMake(10, self.view.bounds.size.height-100, 300, 40);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.imageView.image = self.image;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(clickDone:)];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIImageView *)imageView{
    if (!_imageView){
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapColorPicker:)]];
        _imageView.userInteractionEnabled = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (void)tapColorPicker:(UITapGestureRecognizer*)sender{
    UIColor *color = [self colorAtPixel:[sender locationInView:sender.view] size:self.imageView.bounds.size withImage:self.imageView.image];
    self.color = color;
    self.imageView.image = [self changeColorTransparent:self.image color:self.color isExcluded:isExclude sensitive: self.slider.value];
}

- (UIColor *)colorAtPixel:(CGPoint)point size:(CGSize)size withImage:(UIImage*)image{
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = image.CGImage;
    NSUInteger width = size.width;
    NSUInteger height = size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast |     kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (UIImage*)changeColorTransparent:(UIImage*)img color:(UIColor*)color isExcluded:(BOOL)isExcluded sensitive:(CGFloat)sensitive{
    //convert to uncompressed jpg to remove any alpha channels
    //this is a necessary first step when processing images that already have transparency
    UIImage *image = [UIImage imageWithData:UIImageJPEGRepresentation(img, 1.0)];
    CGImageRef rawImageRef=image.CGImage;
    //RGB color range to mask (make transparent)  R-Low, R-High, G-Low, G-High, B-Low, B-High
    
    NSArray<NSString*> *rgbs = [self rgbStrings:color];
    if (rgbs.count<3) return img;
    CGFloat range = 235*(sensitive-1);
    const double colorMasking[6] = {
        MAX(0, rgbs[0].integerValue-20+range),
        MIN(255, rgbs[0].integerValue+20-range),
        MAX(0, rgbs[1].integerValue-20+range),
        MIN(255, rgbs[1].integerValue+20-range),
        MAX(0, rgbs[2].integerValue-20+range),
        MIN(255, rgbs[2].integerValue+20-range)
    };
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    CGImageRef maskedImageRef = CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    
    //iPhone translation
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();
    
    if (!isExcluded)
    {
        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        [result drawInRect:CGRectMake(0, 0, image.size.width, image.size.height) blendMode:kCGBlendModeDestinationOut alpha:1];
        result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return result;
}

- (NSArray<NSString *> *)rgbStrings:(UIColor*)color{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    return @[
        [NSString stringWithFormat:@"%.0f", r*255],
        [NSString stringWithFormat:@"%.0f", g*255],
        [NSString stringWithFormat:@"%.0f", b*255],
    ];
}

- (void)clickDone:(id)sender{
    BOOL success = [UIImagePNGRepresentation(self.imageView.image) writeToFile:self.path atomically:YES];
    if (success) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)switcher:(UISwitch*)sender{
    isExclude = sender.isOn;
}

- (UISwitch *)switcher{
    if (!_switcher) {
        _switcher = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        [_switcher addTarget:self action:@selector(switcher:) forControlEvents:UIControlEventValueChanged];
        _switcher.on = YES;
    }
    return _switcher;
}

- (UISlider *)slider{
    if (!_slider){
        _slider = [[UISlider alloc] init];
        _slider.value = 0.8;
    }
    return _slider;
}

@end
