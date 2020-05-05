//
//  ViewController.m
//  Test
//
//  Created by 唐绍成 on 2020/5/2.
//  Copyright © 2020 唐绍成. All rights reserved.
//

#import "ViewController.h"
#import "ImageViewController.h"

@interface ViewController ()
<UITableViewDelegate,
UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;

@property(nonatomic,strong)NSArray *files;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.files = [[NSFileManager defaultManager] subpathsAtPath:@"./Downloads/files"];
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithTitle:@"改尺寸" style:UIBarButtonItemStylePlain target:self action:@selector(changeSize:)],
        [[UIBarButtonItem alloc] initWithTitle:@"改色" style:UIBarButtonItemStylePlain target:self action:@selector(changeColor:)]
    ];
}

- (UITableView *)tableView{
    if (!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageWithContentsOfFile:[self path:self.files[indexPath.row]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ImageViewController *vc = [[ImageViewController alloc] init];
    NSString *path = [self path:self.files[indexPath.row]];
    vc.image = [UIImage imageWithContentsOfFile:path];
    vc.path = path;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString*)path:(NSString*)file{
    return [NSString stringWithFormat:@"./Downloads/files/%@", file];
}

- (void)changeSize:(id)sender{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i=0; i<self.files.count; i++)
        {
            NSString *path = [self path:self.files[i]];
            UIImage *img = [UIImage imageWithContentsOfFile:path];
            CGSize size = CGSizeZero;
            if (img.size.width>img.size.height) {
                size.width = 200;
                size.height = img.size.height*200/img.size.width;
            } else {
                size.height = 200;
                size.width = img.size.width*200/img.size.height;
            }
            img = [self sizeImage:img size:size];
            [UIImagePNGRepresentation(img) writeToFile:path atomically:YES];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Done" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                ;
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        });
    });
}

- (UIImage*)sizeImage:(UIImage*)img size:(CGSize)size{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextClip(context);
    [img drawInRect:rect];
    UIImage *sizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return sizedImage;
}

- (void)changeColor:(id)sender{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i=0; i<self.files.count; i++)
        {
            NSString *path = [self path:self.files[i]];
            UIImage *img = [UIImage imageWithContentsOfFile:path];
            img = [self tintColor:img tintColor:[UIColor blackColor] blendMode:kCGBlendModeDestinationIn];
            [UIImagePNGRepresentation(img) writeToFile:path atomically:YES];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Done" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                ;
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        });
    });
}

- (UIImage*)tintColor:(UIImage*)image tintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    [image drawInRect:bounds blendMode:blendMode alpha:1.0f];
    if (blendMode != kCGBlendModeDestinationIn)
    {
        [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}

@end
