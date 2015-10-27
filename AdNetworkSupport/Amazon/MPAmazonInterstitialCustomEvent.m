//
//  MPAmazonInterstitialCustomEvent.m
//
//
//  Copyright (c) 2014 Idemfactor Solutions Inc. All rights reserved.
//

#import "MPAmazonInterstitialCustomEvent.h"
#import "MPInterstitialAdController.h"
#import "MPLogging.h"
#import "MPAdConfiguration.h"
#import "MPInstanceProvider.h"
#import <CoreLocation/CoreLocation.h>
#import <AmazonAd/AmazonAdOptions.h>
#import <AmazonAd/AmazonAdError.h>
#import <AmazonAd/AmazonAdRegistration.h>

@interface MPInstanceProvider (AmazonInterstitials)

- (AmazonAdInterstitial *)buildAmazonInterstitialAd;

@end

@implementation MPInstanceProvider (AmazonInterstitials)

- (AmazonAdInterstitial *)buildAmazonInterstitialAd
{
    return [AmazonAdInterstitial amazonAdInterstitial];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPAmazonInterstitialCustomEvent ()

@property (nonatomic, strong) AmazonAdInterstitial *interstitial;

@end

@implementation MPAmazonInterstitialCustomEvent

@synthesize interstitial = _interstitial;

#pragma mark - MPInterstitialCustomEvent Subclass Methods
- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting Amazon interstitial");
    
    static BOOL _isRegistered = NO;
    if (!_isRegistered) {
        _isRegistered = YES;
        NSString *appKey = [info objectForKey:@"appId"];
        [[AmazonAdRegistration sharedRegistration] setAppKey:appKey.length==0?AMAZAON_APP_KEY:appKey];

    }
    
    self.interstitial = [[MPInstanceProvider sharedProvider] buildAmazonInterstitialAd];
    self.interstitial.delegate = self;

    // Set the adOptions.
    AmazonAdOptions *options = [AmazonAdOptions options];
    options.usesGeoLocation = ADV_AD_LOCATION > 0;

    [self.interstitial load:options];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.interstitial presentFromViewController:rootViewController];
}

- (void)dealloc
{
    self.interstitial.delegate = nil;
}

#pragma mark - AmazonAdInterstitialDelegate
- (void)interstitialDidLoad:(AmazonAdInterstitial *)interstitial
{
    MPLogInfo(@"Amazon Interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:self];

}

- (void)interstitialDidFailToLoad:(AmazonAdInterstitial *)interstitial withError:(AmazonAdError *)error
{
    MPLogInfo(@"Amazon Interstitial failed to load with error: %@", error.errorDescription);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:@"AmazonIntAd" code:error.errorCode userInfo:nil]];

}

- (void)interstitialWillPresent:(AmazonAdInterstitial *)interstitial
{
    MPLogInfo(@"Amazon Interstitial will present");
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)interstitialDidPresent:(AmazonAdInterstitial *)interstitial
{
    MPLogInfo(@"Interstitial has been presented.");
    [self.delegate interstitialCustomEventDidAppear:self];

}

- (void)interstitialWillDismiss:(AmazonAdInterstitial *)interstitial
{
    MPLogInfo(@"Amazon Interstitial will dismiss");
    [self.delegate interstitialCustomEventWillDisappear:self];

}

- (void)interstitialDidDismiss:(AmazonAdInterstitial *)interstitial
{
    MPLogInfo(@"Amazon Interstitial did dismiss");
    [self.delegate interstitialCustomEventDidDisappear:self];

}

@end
