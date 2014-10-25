//
//  FacebookBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "FacebookBannerCustomEvent.h"

#import "MPInstanceProvider.h"
#import "MPLogging.h"

@interface MPInstanceProvider (FacebookBanners)

- (FBAdView *)buildFBAdViewWithPlacementID:(NSString *)placementID
                        rootViewController:(UIViewController *)controller
                                  delegate:(id<FBAdViewDelegate>)delegate
                                      size:(CGSize)size;
@end

@implementation MPInstanceProvider (FacebookBanners)

- (FBAdView *)buildFBAdViewWithPlacementID:(NSString *)placementID
                        rootViewController:(UIViewController *)controller
                                  delegate:(id<FBAdViewDelegate>)delegate
                                      size:(CGSize)size
{
    FBAdSize fbSize = size.height==90?kFBAdSizeHeight90Banner : size.width==320?kFBAdSize320x50: kFBAdSizeHeight50Banner;
    FBAdView *adView = [[FBAdView alloc] initWithPlacementID:placementID
                                                       adSize:fbSize
                                           rootViewController:controller];
    adView.delegate = delegate;
    return adView;
}

@end

@interface FacebookBannerCustomEvent ()

@property (nonatomic, strong) FBAdView *fbAdView;

@end

@implementation FacebookBannerCustomEvent

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    if (size.height!=50 && size.height!=90) {
        MPLogError(@"Invalid size for Facebook banner ad");
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    if (![info objectForKey:@"placement_id"]) {
        MPLogError(@"Placement ID is required for Facebook banner ad");
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    MPLogInfo(@"Requesting Facebook banner ad");
    self.fbAdView =
        [[MPInstanceProvider sharedProvider] buildFBAdViewWithPlacementID:[info objectForKey:@"placement_id"]
                                                       rootViewController:[self.delegate viewControllerForPresentingModalView]
                                                                 delegate:self
                                                                     size:size];

    if (!self.fbAdView) {
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    [self.fbAdView loadAd];
}

- (void)dealloc
{
    _fbAdView.delegate = nil;
}

#pragma mark FBAdViewDelegate methods

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error;
{
    MPLogInfo(@"Facebook banner failed to load with error: %@", error.description);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)adViewDidLoad:(FBAdView *)adView;
{
    MPLogInfo(@"Facebook banner ad did load");
    [self.delegate trackImpression];
    [self.delegate bannerCustomEvent:self didLoadAd:adView];
}

- (void)adViewDidClick:(FBAdView *)adView
{
    MPLogInfo(@"Facebook banner ad was clicked");
    [self.delegate trackClick];
}

@end
