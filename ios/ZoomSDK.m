//
//  ZoomSDK.m
//  symboisishealth
//
//  Created by Rishabh Saxena on 27/06/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "ZoomSDK.h"
#import <React/RCTLog.h>


@implementation ZoomSDK

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(addEvent:(NSString *)name location:(NSString *)location)
{
   RCTLogInfo(@"Pretending to create an event %@ at %@", name, location);
}


#pragma mark - Auth Delegate

RCT_EXPORT_METHOD(sdkAuth:(NSString *)clientKey clientSecret:(NSString *)clientSecret domain:(NSString *)domain)
{
   MobileRTCAuthService *authService = [[MobileRTC sharedRTC] getAuthService];
   if (authService)
   {
      authService.delegate = self;
      
      authService.clientKey = clientKey;
      authService.clientSecret = clientSecret;
      [authService sdkAuth];
   }
}

- (void)onLeave:(id)sender
{
   
      
      MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
      if (ms)
      {
         [ms leaveMeetingWithCmd:LeaveMeetingCmd_Leave];
      }
   
}

- (void)onMobileRTCAuthReturn:(MobileRTCAuthError)returnValue
{
   NSLog(@"onMobileRTCAuthReturn %d", returnValue);
   
   if (returnValue != MobileRTCAuthError_Success)
   {
      NSString *message = [NSString stringWithFormat:NSLocalizedString(@"SDK authentication failed, error code: %zd", @""), returnValue];

      NSLog(@"%@", message);
      
      //      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:NSLocalizedString(@"Retry", @""), nil];
//      [alert show];
   } else {
      NSLog(@"Auth success");
   }

}

- (void)onMobileRTCLoginReturn:(NSInteger)returnValue
{
   NSLog(@"onMobileRTCLoginReturn result=%zd", returnValue);
   
   MobileRTCPremeetingService *service = [[MobileRTC sharedRTC] getPreMeetingService];
   if (service)
   {
      service.delegate = self;
   }
}

- (void)onMobileRTCLogoutReturn:(NSInteger)returnValue
{
   NSLog(@"onMobileRTCLogoutReturn result=%zd", returnValue);
}


// MARK:- JOin Meeting

RCT_EXPORT_METHOD(onJoinaMeeting:(NSString *)meetingId password:(NSString *)password userName:(NSString *)userName resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
   MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
   if (!ms)
   {
      return;
   }
   successCallback = resolve;
   [self joinMeeting:meetingId withPassword:password userName:userName];
   
}

- (void)joinMeeting:(NSString*)meetingNo withPassword:(NSString*)pwd userName:(NSString *)userName
{
   if (![meetingNo length])
   return;
   
   MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
   if (ms)
   {
#if 0
      //customize meeting title
      [ms customizeMeetingTitle:@"Sample Meeting Title"];
#endif
      ms.delegate = self;
      
      //For Join a meeting with password
      NSDictionary *paramDict = @{
                                  kMeetingParam_Username:userName,
                                  kMeetingParam_MeetingNumber:meetingNo,
                                  kMeetingParam_MeetingPassword:pwd,
                                  //kMeetingParam_ParticipantID:kParticipantID,
                                  //kMeetingParam_WebinarToken:kWebinarToken,
                                  //kMeetingParam_NoAudio:@(YES),
                                  //kMeetingParam_NoVideo:@(YES),
                                  };
      //            //For Join a meeting
      //            NSDictionary *paramDict = @{
      //                                        kMeetingParam_Username:kSDKUserName,
      //                                        kMeetingParam_MeetingNumber:meetingNo,
      //                                        kMeetingParam_MeetingPassword:pwd,
      //                                        };
      
      MobileRTCMeetError ret = [ms joinMeetingWithDictionary:paramDict];
      
      NSLog(@"onJoinaMeeting ret:%d", ret);
   }
}




#pragma mark - Meeting Service Delegate

- (void)onMeetingReturn:(MobileRTCMeetError)error internalError:(NSInteger)internalError
{
   NSLog(@"onMeetingReturn:%d, internalError:%zd", error, internalError);
}

//- (void)onMeetingError:(NSInteger)error message:(NSString*)message
//{
//    NSLog(@"onMeetingError:%zd, message:%@", error, message);
//}

RCT_EXPORT_METHOD (meetingFinished) {
   
}

- (void)onMeetingStateChange:(MobileRTCMeetingState)state
{
   NSLog(@"onMeetingStateChange:%d", state);
   
   MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
   BOOL inAppShare = [ms isDirectAppShareMeeting] && (state == MobileRTCMeetingState_InMeeting);
   
   if (state != MobileRTCMeetingState_InMeeting)
   {
      NSLog(@"meetingfinished");
      if (successCallback) {
         successCallback(nil);
      }
      [self meetingFinished];
   }

#if 1
   if (state == MobileRTCMeetingState_InMeeting)
   {
      //For customizing the content of Invite by SMS
      NSString *meetingNumber = [[MobileRTCInviteHelper sharedInstance] ongoingMeetingNumber];
      NSString *smsMessage = [NSString stringWithFormat:NSLocalizedString(@"Please join meeting with ID: %@", @""), meetingNumber];
      [[MobileRTCInviteHelper sharedInstance] setInviteSMS:smsMessage];
      
      //For customizing the content of Copy URL
      NSString *joinURL = [[MobileRTCInviteHelper sharedInstance] joinMeetingURL];
      NSString *copyURLMsg = [NSString stringWithFormat:NSLocalizedString(@"Meeting URL: %@", @""), joinURL];
      [[MobileRTCInviteHelper sharedInstance] setInviteCopyURL:copyURLMsg];
   }
#endif
   
#if 0
   //For adding customize view above the meeting view
   if (state == MobileRTCMeetingState_InMeeting)
   {
      MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
      UIView *v = [ms meetingView];
      
      CGFloat offsetY = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 220 : 180;
      UIView *sv = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, v.frame.size.width, 50)];
      sv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
      sv.backgroundColor = [UIColor redColor];
      [v addSubview:sv];
      [sv release];
   }
   
#endif
}

- (void)onMeetingReady
{
   MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
   if ([ms isDirectAppShareMeeting])
   {
      if ([ms isStartingShare] || [ms isViewingShare])
      {
         NSLog(@"There exist an ongoing share");
         [ms showMobileRTCMeeting:^(void){
            [ms stopAppShare];
         }];
         return;
      }
      
      BOOL ret = [ms startAppShare];
      NSLog(@"Start App Share... ret:%zd", ret);
   }
   
   //    [self startClockTimer];
}

#if 0
- (void)onJBHWaitingWithCmd:(JBHCmd)cmd
{
   switch (cmd) {
         case JBHCmd_Show:
      {
         // Display custom UI for waiting screen
      }
         break;
         
         case JBHCmd_Hide:
      default:
      {
         // Dismiss current waiting screen for
      }
         break;
   }
}
#endif


#if 0
- (void)onClickedDialOut:(UIViewController*)parentVC isCallMe:(BOOL)me
{
   MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
   if (!ms)
   return;
   
   if ([ms isDialOutInProgress])
   {
      NSLog(@"There already exists an ongoing call");
      return;
   }
   
   NSString *callName = me ? nil : @"Dialer";
   BOOL ret = [ms dialOut:@"+866004" isCallMe:me withName:callName];
   NSLog(@"Dial out result: %zd", ret);
}

- (void)onDialOutStatusChanged:(DialOutStatus)status
{
   NSLog(@"onDialOutStatusChanged: %zd", status);
}
#endif

#pragma mark - In meeting users' state updated

#if 0
- (void)onInMeetingUserUpdated
{
   MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
   NSArray *users = [ms getInMeetingUserList];
   NSLog(@"In Meeting users:%@", users);
}

- (void)onInMeetingChat:(NSString *)messageID
{
   MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
   NSLog(@"In Meeting Chat:%@ content:%@", messageID, [ms meetingChatByID:messageID]);
}
#endif

#pragma mark - Handle Session Key

#if 0
- (void)onWaitExternalSessionKey:(NSData*)key
{
   NSLog(@"session key: %@", key);
   Byte byte[] = {0x90,0xd7,0x19,0x28,0x7c,0xa5,0x4c,0xfd,0xca,0x89,0x5a,0x31,0x3f,0xf1,0xbc,0x8f,0x9b,0x6c,0x6b,0x4b,0x3e,0xcd,0xfc,0xa8,0xdf,0xda,0x0e,0xe7,0x00,0x4f,0x32,0xc5};
   NSData *keyData = [[NSData alloc] initWithBytes:byte length:32];
   NSLog(@"data: %@", keyData);
   
   MobileRTCE2EMeetingKey *mkChat = [[[MobileRTCE2EMeetingKey alloc] init] autorelease];
   mkChat.type = MobileRTCComponentType_Chat;
   mkChat.meetingKey = keyData;
   mkChat.meetingIv = nil;
   MobileRTCE2EMeetingKey *mkAudio = [[[MobileRTCE2EMeetingKey alloc] init] autorelease];
   mkAudio.type = MobileRTCComponentType_AUDIO;
   mkAudio.meetingKey = keyData;
   mkAudio.meetingIv = nil;
   MobileRTCE2EMeetingKey *mkVideo = [[[MobileRTCE2EMeetingKey alloc] init] autorelease];
   mkVideo.type = MobileRTCComponentType_VIDEO;
   mkVideo.meetingKey = keyData;
   mkVideo.meetingIv = nil;
   MobileRTCE2EMeetingKey *mkShare = [[[MobileRTCE2EMeetingKey alloc] init] autorelease];
   mkShare.type = MobileRTCComponentType_AS;
   mkShare.meetingKey = keyData;
   mkShare.meetingIv = nil;
   MobileRTCE2EMeetingKey *mkFile = [[[MobileRTCE2EMeetingKey alloc] init] autorelease];
   mkFile.type = MobileRTCComponentType_FT;
   mkFile.meetingKey = keyData;
   mkFile.meetingIv = nil;
   
   MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
   BOOL ret = [ms handleE2EMeetingKey:@[mkChat, mkAudio, mkVideo, mkShare, mkFile] withLeaveMeeting:NO];
   NSLog(@"handleE2EMeetingKey ret:%zd", ret);
}
#endif


@end;
