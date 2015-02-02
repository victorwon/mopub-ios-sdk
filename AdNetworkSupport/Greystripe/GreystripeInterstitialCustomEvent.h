//
//  GreystripeInterstitialCustomEvent.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPInterstitialCustomEvent.h"
#endif

/*
 * Certified with version 4.3 of the Greystripe SDK.
 */

@interface GreystripeInterstitialCustomEvent : MPInterstitialCustomEvent

/**
 * Registers a Greystripe GUID to be used when making ad requests.
 *
 * When making ad requests, the Greystripe SDK requires you to provide your GUID. When
 * integrating Greystripe using a MoPub custom event, this ID is typically configured on the MoPub
 * website in your Greystripe network settings. However, if you wish, you may use this method to
 * manually provide the custom event with your GUID.
 */
+ (void)setGUID:(NSString *)GUID;

@end
