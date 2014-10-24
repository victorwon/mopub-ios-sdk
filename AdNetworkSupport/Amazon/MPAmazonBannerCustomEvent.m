//
//  MPAmazonBannerCustomEvent.m
//
//
//  Copyright (c) 2014 Idemfactor Solutions. All rights reserved.
//

#import "MPAmazonBannerCustomEvent.h"
#import "MPLogging.h"
#import "MPInstanceProvider.h"
#import <AmazonAd/AmazonAdOptions.h>
#import <AmazonAd/AmazonAdError.h>
#import <AmazonAd/AmazonAdRegistration.h>

@interface MPInstanceProvider (AmazonBanners)

- (AmazonAdView *)buildAmazonBannerViewWithFrame:(CGRect)frame;

@end

@implementation MPInstanceProvider (AmazonBanners)

- (AmazonAdView *)buildAmazonBannerViewWithFrame:(CGRect)frame
{
    return [AmazonAdView amazonAdViewWithAdSize:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)? AmazonAdSize_728x90: AmazonAdSize_320x50];
}


@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPAmazonBannerCustomEvent ()

@property (nonatomic, strong) AmazonAdView *adBannerView;

@end


@implementation MPAmazonBannerCustomEvent
- (id)init
{
    self = [super init];

    return self;
}

- (void)dealloc
{
    self.adBannerView.delegate = nil;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting Amazon banner");

    static BOOL _isRegistered = NO;
    if (!_isRegistered) {
        _isRegistered = YES;
        NSString *appKey = [info objectForKey:@"appId"];
        [[AmazonAdRegistration sharedRegistration] setAppKey:appKey.length==0?AMAZAON_APP_KEY:appKey];
        
    }
    
    self.adBannerView = [[MPInstanceProvider sharedProvider] buildAmazonBannerViewWithFrame:CGRectZero];
    self.adBannerView.delegate = self;

    self.adBannerView.frame = [self frameForCustomEventInfo:info];

    AmazonAdOptions *options = [AmazonAdOptions options];
    options.usesGeoLocation = ADV_AD_LOCATION > 0;

    [self.adBannerView loadAd:options];

}

- (CGRect)frameForCustomEventInfo:(NSDictionary *)info
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)? CGRectMake(0, 0, 728, 90): CGRectMake(0, 0, 320, 50);
}

#pragma mark AmazonAdViewDelegate
// @required
- (UIViewController *)viewControllerForPresentingModalView {
    return [self.delegate viewControllerForPresentingModalView];
}

// @optional
- (void)adViewWillExpand:(AmazonAdView *)view {
    MPLogInfo(@"Amazon Banner will present modal");
    [self.delegate bannerCustomEventWillBeginAction:self];
}

// @optional
- (void)adViewDidCollapse:(AmazonAdView *)view {
    MPLogInfo(@"Amazon Banner did dismiss modal");
    [self.delegate bannerCustomEventDidFinishAction:self];

}

// @optional
- (void)adViewDidLoad:(AmazonAdView *)view {
    MPLogInfo(@"Amazon Banner did load");
    [self.delegate bannerCustomEvent:self didLoadAd:self.adBannerView];
}

// @optional
- (void)adViewDidFailToLoad:(AmazonAdView *)view withError:(AmazonAdError *)error {
    MPLogInfo(@"Amazon Banner failed to load with error: %@", error);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:@"AmazonBannerAd" code:error.errorCode userInfo:nil]];
}

@end
