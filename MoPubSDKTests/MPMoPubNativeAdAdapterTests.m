//
//  MPMoPubNativeAdAdapterTests.m
//  MoPubSDKTests
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPMoPubNativeAdAdapter+Testing.h"
#import "MPAdImpressionTimer+Testing.h"
#import "MPNativeAdConstants.h"
#import "MPNativeAdConfigValues.h"

@interface MPMoPubNativeAdAdapterTests : XCTestCase

@end

@implementation MPMoPubNativeAdAdapterTests

#pragma mark: Impression timer gets set correctly

- (void)testImpressionRulesTimerSetFromHeaderPropertiesPixels {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:30
                                                                                  impressionMinVisiblePercent:-1
                                                                                  impressionMinVisibleSeconds:5.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertEqual(adapter.impressionTimer.pixelsRequiredForViewVisibility, configValues.impressionMinVisiblePixels);
    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    XCTAssertFalse(configValues.isImpressionMinVisiblePercentValid);
    XCTAssertTrue(configValues.isImpressionMinVisiblePixelsValid);
    XCTAssertTrue(configValues.isImpressionMinVisibleSecondsValid);
}

- (void)testImpressionRulesPixelsTakePriorityOverPercentage {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:30
                                                                                  impressionMinVisiblePercent:30
                                                                                  impressionMinVisibleSeconds:5.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertEqual(adapter.impressionTimer.pixelsRequiredForViewVisibility, configValues.impressionMinVisiblePixels);
    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    XCTAssertNotEqual(adapter.impressionTimer.percentageRequiredForViewVisibility, configValues.impressionMinVisiblePercent);
    XCTAssertTrue(configValues.isImpressionMinVisiblePercentValid);
    XCTAssertTrue(configValues.isImpressionMinVisiblePixelsValid);
    XCTAssertTrue(configValues.isImpressionMinVisibleSecondsValid);
}

- (void)testImpressionRulesTimerSetFromHeaderPropertiesPercentage {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0 // invalid pixels to fall through
                                                                                  impressionMinVisiblePercent:30
                                                                                  impressionMinVisibleSeconds:5.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    CGFloat percentage = (configValues.impressionMinVisiblePercent / 100.0);
    XCTAssertEqual(adapter.impressionTimer.percentageRequiredForViewVisibility, percentage);
    XCTAssertTrue(configValues.isImpressionMinVisiblePercentValid);
    XCTAssertFalse(configValues.isImpressionMinVisiblePixelsValid);
    XCTAssertTrue(configValues.isImpressionMinVisibleSecondsValid);
}

- (void)testImpressionRulesDefaultsAreUsedWhenHeaderPropertiesAreInvalid {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0
                                                                                  impressionMinVisiblePercent:-1
                                                                                  impressionMinVisibleSeconds:-1.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertNotEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    XCTAssertNotEqual(adapter.impressionTimer.percentageRequiredForViewVisibility, (configValues.impressionMinVisiblePercent / 100.0));
    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, 1.0);
    XCTAssertEqual(adapter.impressionTimer.percentageRequiredForViewVisibility, 0.5);
    XCTAssertFalse(configValues.isImpressionMinVisiblePercentValid);
    XCTAssertFalse(configValues.isImpressionMinVisiblePixelsValid);
    XCTAssertFalse(configValues.isImpressionMinVisibleSecondsValid);
}

- (void)testImpressionRulesPropertiesDictionaryDoesNotContainConfigAfterInit {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0
                                                                                  impressionMinVisiblePercent:-1
                                                                                  impressionMinVisibleSeconds:-1.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];
    XCTAssertNil(adapter.properties[kNativeAdConfigKey]);
}

- (void)testImpressionRulesOnlyValidPixels {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:20
                                                                                  impressionMinVisiblePercent:-1
                                                                                  impressionMinVisibleSeconds:-1.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertEqual(adapter.impressionTimer.pixelsRequiredForViewVisibility, configValues.impressionMinVisiblePixels);
    XCTAssertNotEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, 1.0); // check for default
    XCTAssertFalse(configValues.isImpressionMinVisiblePercentValid);
    XCTAssertTrue(configValues.isImpressionMinVisiblePixelsValid);
    XCTAssertFalse(configValues.isImpressionMinVisibleSecondsValid);
}

- (void)testImpressionRulesOnlyValidPercentage {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0
                                                                                  impressionMinVisiblePercent:10
                                                                                  impressionMinVisibleSeconds:-1.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertNotEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    CGFloat percentage = (configValues.impressionMinVisiblePercent / 100.0);
    XCTAssertEqual(adapter.impressionTimer.percentageRequiredForViewVisibility, percentage);
    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, 1.0);
    CGFloat expected = 0.1;
    XCTAssertEqual(adapter.impressionTimer.percentageRequiredForViewVisibility, expected);
    XCTAssertTrue(configValues.isImpressionMinVisiblePercentValid);
    XCTAssertFalse(configValues.isImpressionMinVisiblePixelsValid);
    XCTAssertFalse(configValues.isImpressionMinVisibleSecondsValid);
}

- (void)testImpressionRulesOnlyValidTimeInterval {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePixels:-1.0
                                                                                  impressionMinVisiblePercent:-1
                                                                                  impressionMinVisibleSeconds:30.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    XCTAssertNotEqual(adapter.impressionTimer.percentageRequiredForViewVisibility, (configValues.impressionMinVisiblePercent / 100.0));
    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, 30.0);
    XCTAssertEqual(adapter.impressionTimer.percentageRequiredForViewVisibility, 0.5);
    XCTAssertFalse(configValues.isImpressionMinVisiblePercentValid);
    XCTAssertFalse(configValues.isImpressionMinVisiblePixelsValid);
    XCTAssertTrue(configValues.isImpressionMinVisibleSecondsValid);
}

@end
