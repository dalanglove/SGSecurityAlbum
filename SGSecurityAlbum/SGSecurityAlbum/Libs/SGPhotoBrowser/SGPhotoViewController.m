//
//  SGPhotoViewController.m
//  SGSecurityAlbum
//
//  Created by soulghost on 10/7/2016.
//  Copyright © 2016 soulghost. All rights reserved.
//

#import "SGPhotoViewController.h"
#import "SGPhotoBrowser.h"
#import "SGPhotoView.h"
#import "SGPhotoModel.h"
#import "SGPhotoToolBar.h"
#import "SGUIKit.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface SGPhotoViewController ()

@property (nonatomic, assign) BOOL isBarHidden;
@property (nonatomic, weak) SGPhotoView *photoView;
@property (nonatomic, weak) SGPhotoToolBar *toolBar;

@end

@implementation SGPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    WS();
    [self.photoView setSingleTapHandlerBlock:^{
        [weakSelf toggleBarState];
    }];
}

- (void)setupView {
    SGPhotoView *photoView = [SGPhotoView new];
    self.photoView = photoView;
    self.photoView.controller = self;
    [self.view addSubview:photoView];
    CGFloat x = -PhotoGutt;
    CGFloat y = 0;
    CGFloat w = self.view.bounds.size.width + 2 * PhotoGutt;
    CGFloat h = self.view.bounds.size.height;
    self.photoView.frame = CGRectMake(x, y, w, h);
    CGFloat barW = self.view.bounds.size.width;
    CGFloat barH = 44;
    CGFloat barX = 0;
    CGFloat barY = self.view.bounds.size.height - barH;
    SGPhotoToolBar *tooBar = [[SGPhotoToolBar alloc] initWithFrame:CGRectMake(barX, barY, barW, barH)];
    self.toolBar = tooBar;
    [self.view addSubview:tooBar];
    WS();
    [self.toolBar setButtonActionHandlerBlock:^(UIBarButtonItem *sender) {
        switch (sender.tag) {
            case SGPhotoToolBarTrashTag:
                [weakSelf trashAction];
                break;
            case SGPhotoToolBarExportTag:
                [weakSelf exportAction];
                break;
            default:
                break;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.photoView.browser = self.browser;
    self.photoView.index = self.index;
}

- (void)toggleBarState {
    self.isBarHidden = !self.isBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setNavigationBarHidden:self.isBarHidden animated:YES];
    [UIView animateWithDuration:0.35 animations:^{
        self.toolBar.alpha = self.isBarHidden ? 0 : 1.0f;
    }];
}

- (BOOL)prefersStatusBarHidden {
    return self.isBarHidden;
}

#pragma mark ToolBar Action
- (void)trashAction {
    [[[SGBlockActionSheet alloc] initWithTitle:@"Please Confirm Delete" callback:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [[NSFileManager defaultManager] removeItemAtPath:self.photoView.currentPhoto.photoURL.path error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:self.photoView.currentPhoto.thumbURL.path error:nil];
            [self.navigationController popViewControllerAnimated:YES];
            NSAssert(self.browser.reloadHandler != nil, @"you must implement 'reloadHandler' block to reload files while delete");
            self.browser.reloadHandler();
            [self.browser reloadData];
        }
    } cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitlesArray:nil] showInView:self.view];
}

- (void)exportAction {
    [[[SGBlockActionSheet alloc] initWithTitle:@"Save To Where" callback:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            ALAssetsLibrary *lib = [ALAssetsLibrary new];
            UIImage *image = self.photoView.currentImageView.innerImageView.image;
            [MBProgressHUD showMessage:@"Saving"];
            [lib writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:@"Succeeded"];
            }];
        }
    } cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitlesArray:@[@"Photo Library"]] showInView:self.view];
}

@end
