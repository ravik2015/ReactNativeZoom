//
//  ZoomSDK.h
//  symboisishealth
//
//  Created by Rishabh Saxena on 27/06/18.
// CalendarManager.h
#import <React/RCTBridgeModule.h>
#import <MobileRTC/MobileRTC.h>

@interface ZoomSDK : NSObject <RCTBridgeModule, MobileRTCAuthDelegate, MobileRTCPremeetingDelegate, MobileRTCMeetingServiceDelegate>
{
   RCTPromiseResolveBlock successCallback;
}
@end
