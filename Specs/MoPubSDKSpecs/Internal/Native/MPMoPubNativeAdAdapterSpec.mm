#import "MPMoPubNativeAdAdapter.h"
#import "MPNativeAdConstants.h"

#define kImpressionTrackerURLsKey   @"imptracker"
#define kDefaultActionURLKey        @"clk"
#define kClickTrackerURLKey         @"clktracker"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPMoPubNativeAdAdapterSpec)

describe(@"MPMoPubNativeAdAdapter", ^{
    NSDictionary *validProperties = @{kAdTitleKey : @"WUT",
                                      kAdTextKey : @"WUT DaWG",
                                      kAdIconImageKey : kMPSpecsTestImageURL,
                                      kAdMainImageKey : kMPSpecsTestImageURL,
                                      kAdCTATextKey : @"DO IT",
                                      kImpressionTrackerURLsKey: @[@"http://www.mopub.com/tearinupmyheartwhenimwithyou", @"http://www.mopub.com/pop"],
                                      kClickTrackerURLKey : @"http://www.mopub.com/byebyebye",
                                      kDefaultActionURLKey : @"http://www.mopub.com/iwantyouback"
                                      };

    context(@"when initializing with valid properties", ^{
        __block MPMoPubNativeAdAdapter *adAdapter;

        beforeEach(^{
            adAdapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[validProperties mutableCopy]];
        });

        it(@"should load the properties correctly", ^{
            [adAdapter.defaultActionURL absoluteString] should equal([validProperties objectForKey:kDefaultActionURLKey]);
            [adAdapter.engagementTrackingURL absoluteString] should equal([validProperties objectForKey:kClickTrackerURLKey]);
            adAdapter.impressionTrackers should equal([validProperties objectForKey:kImpressionTrackerURLsKey]);
        });

        it(@"should clean the properties", ^{
            NSDictionary *adProperties = adAdapter.properties;

            [adProperties objectForKey:kImpressionTrackerURLsKey] should be_nil;
            [adProperties objectForKey:kClickTrackerURLKey] should be_nil;
            [adProperties objectForKey:kDefaultActionURLKey] should be_nil;
        });

        context(@"when displaying content for URL", ^{
            it(@"should error out when not given a controller", ^{
                __block BOOL didError = NO;
                [adAdapter displayContentForURL:[NSURL URLWithString:@"www.dimsum.com"] rootViewController:nil completion:^(BOOL success, NSError *error) {
                    didError = (error != nil);
                }];

                didError should be_truthy;
            });

            it(@"should error out when not given a URL", ^{
                __block BOOL didError = NO;
                [adAdapter displayContentForURL:nil rootViewController:[[UIViewController alloc] init] completion:^(BOOL success, NSError *error) {
                    didError = (error != nil);
                }];

                didError should be_truthy;
            });
        });
    });

    context(@"when requesting an ad with invalid info", ^{
        __block MPMoPubNativeAdAdapter *adAdapter;

        it(@"should return nil", ^{
            adAdapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:nil];
            adAdapter should be_nil;
        });
    });

    context(@"when loading the daa icon into an image view", ^{
        __block MPMoPubNativeAdAdapter *adAdapter;
        __block UIImageView *imageView;

        beforeEach(^{
            adAdapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[validProperties mutableCopy]];
            imageView = [[UIImageView alloc] init];
            [adAdapter loadDAAIconIntoImageView:imageView];
        });

        it(@"should attach a tap recognizer to the image view", ^{
            imageView.gestureRecognizers.count should equal(1);
            [imageView.gestureRecognizers[0] isKindOfClass:[UITapGestureRecognizer class]] should be_truthy;
        });

        it(@"should load the daa icon into the image view", ^{
            UIImage *daaImage = [UIImage imageNamed:@"MPDAAIcon"];
            imageView.image should equal(daaImage);
        });
    });
});

SPEC_END
