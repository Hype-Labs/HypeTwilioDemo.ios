//
// MIT License
//
// Copyright (C) 2015 Twilio Inc.
// Copyright (C) 2018 HypeLabs Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "HYPHypeController.h"
#import <UIKit/UIKit.h>
#import "HYPInstanceChannel.h"

@interface HYPHypeController () <HYPStateObserver, HYPNetworkObserver, HYPMessageObserver>

@property (atomic, readonly) HYPInstanceChannel * instanceChannel;
@property (atomic) NSString * announcement;
@property (nonatomic, assign) BOOL netAccess;

@end

@implementation HYPHypeController
@synthesize instanceChannel = _instanceChannel;

- (HYPInstanceChannel *)instanceChannel
{

    @synchronized(self) {

        if (_instanceChannel == nil) {
            _instanceChannel = [[HYPInstanceChannel alloc] init];

        }
        return _instanceChannel;
    }
}

#pragma mark - Hype framework
- (void)requestHypeToStart
{
    // Adding itself as an Hype state observer makes sure that the application gets
    // notifications for lifecycle events being triggered by the Hype framework. These
    // events include starting and stopping, as well as some error handling.
    [HYP addStateObserver:self];

    // Adding itself as an Hype network observer makes sure that the application gets
    // notifications regarding the devices that enter and leave the network. When a new device
    // is found all the network observers receive an onHypeInstanceFound notification,
    // and when they leave an onHypeInstanceLost is triggered instead. The network observers
    // also receive an onHypeInstanceResolved notification when a new device is resolved.
    // A device can only communicate with another device after resolving it. The resolution
    // of an instance consists on the exchange of digital certificates for security purposes.
    [HYP addNetworkObserver:self];

    // Adding itself as an Hype message observer makes sure that the application gets
    // I/O notifications that indicate when messages are received, sent, delivered, or fail
    // to be sent. These notifications also allow to track the sending and delivery percentages
    // of a message. Notice that a message being sent does not imply that it has been delivered,
    // only that it has been queued for output. This is especially important when using mesh
    // networking, as the destination device might not be connect in a direct link.
    [HYP addMessageObserver:self];

    // Requesting Hype to start is equivalent to requesting the device to publish
    // itself on the network and start browsing for other devices in proximity. If
    // everything goes well, the -hypeDidStart: delegate method gets called, indicating
    // that the device is actively participating on the network. The 00000000 app identifier is
    // reserved for test apps, so it's not recommended that apps are shipped with it.
    // For generating an app identifier go to https://hypelabs.io, login, access the dashboard
    // under the Apps section and click "Create New App". The resulting app should
    // display a identifier number. Copy and paste that here.

    [HYP setAppIdentifier:@"{{app_identifier}}"];
    [HYP start];
}

- (void)hypeDidStart
{
    // At this point, the device is actively participating on the network. Other devices
    // (instances) can be found at any time and the domestic (this) device can be found
    // by others. When that happens, the two devices should be ready to communicate.
    NSLog(@"Hype started!");
}

- (void)hypeDidStopWithError:(HYPError *)error
{
    // The framework has stopped working for some reason. If it was asked to do so (by
    // calling -stop) the error parameter is nil. If, on the other hand, it was forced
    // by some external means, the error parameter indicates the cause. Common causes
    // include the user turning the Bluetooth and/or Wi-Fi adapters off. When the later
    // happens, you shouldn't attempt to start the Hype services again. Instead, the
    // framework triggers a -hypeDidBecomeReady: delegate method if recovery from the
    // failure becomes possible.
    NSLog(@"Hype stopped [%@]", [error description]);
}

- (void)hypeDidFailStartingWithError:(HYPError *)error
{
    // Hype couldn't start its services. Usually this means that all adapters (Wi-Fi
    // and Bluetooth) are not on, and as such the device is incapable of participating
    // on the network. The error parameter indicates the cause for the failure. Attempting
    // to restart the services is futile at this point. Instead, the implementation should
    // wait for the framework to trigger a -hypeDidBecomeReady: notification, indicating
    // that recovery is possible, and start the services then.
    NSLog(@"Hype failed starting [%@]", [error description]);
}

- (void)hypeDidBecomeReady
{
    // This Hype delegate event indicates that the framework believes that it's capable
    // of recovering from a previous start failure. This event is only triggered once.
    // It's not guaranteed that starting the services will result in success, but it's
    // known to be highly likely. If the services are not needed at this point it's
    // possible to delay the execution for later, but it's not guaranteed that the
    // recovery conditions will still hold by then.
    [self requestHypeToStart];
}

- (void)hypeDidChangeState
{
    // State change updates are triggered before their corresponding, specific, observer
    // call. For instance, when Hype starts, it transits to the State.Running state,
    // triggering a call to this method, and only then is onStart(Hype) called. The framework
    // has 4 possible states:  Idle, Starting, Running and Stopping. Every such event has a
    // corresponding observer method, so state change notifications are mostly for convenience.
    // This method is often not used.
    NSLog(@"Hype changed state: %d", (int)[HYP state]);
}

- (void)hypeDidFindInstance:(HYPInstance *)instance
{
    dispatch_async(dispatch_get_main_queue(), ^{

        NSLog(@"Found instance: %@", [instance stringIdentifier]);

        if([instance isResolved]){
            [self sendResponseToResolvedInstance:instance];
            [self notifiyHypeControllerOnInstanceResolved:instance];
        }
        else{
            [HYP resolveInstance:instance];
        }
    });
}

- (void)hypeDidLoseInstance:(HYPInstance *)instance
                      error:(HYPError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{

        // An instance being lost means that communicating with it is no longer possible.
        // This usually happens by the link being broken. This can happen if the connection
        // times out or the device goes out of range. Another possibility is the user turning
        // the adapters off, in which case not only are all instances lost but the framework
        // also stops with an error.
        NSLog(@"Lost instance: %@ [%@]", [instance stringIdentifier], [error description]);
        [self notifiyHypeControllerOnInstanceLost:instance];
    });
}

- (void)hypeDidResolveInstance:(HYPInstance *)instance
{
    NSLog(@"Instance resolved: %@", instance.stringIdentifier);
    [self sendResponseToResolvedInstance:instance];
    [self notifiyHypeControllerOnInstanceResolved:instance];
}

- (void)hypeDidFailResolvingInstance:(HYPInstance *)instance
                               error:(HYPError *)error
{
    NSLog(@"Failed to resolve instance: %@ [%@]", instance.stringIdentifier, error.description);
}

- (void)sendMessageToCloserInstance:(HYPInstance *)instance
                           withText:(NSString *)text
             identifierForVendor:(NSString *)identifierForVendor
{
    NSMutableDictionary * sendMessage = [[NSMutableDictionary alloc] init];
    [sendMessage setValue:text forKey:@"message"];
    [sendMessage setValue:@"send" forKey:@"type"];
    [sendMessage setValue:identifierForVendor forKey:@"identifierForVendor"];

    NSData * data = [NSJSONSerialization dataWithJSONObject:sendMessage
                                                    options:0
                                                      error:nil];

    [HYP sendData:data
                  toInstance:instance
               trackProgress:NO];
}

- (void)sendMessage:(NSMutableDictionary* )twilioMessage
         toInstance:(HYPInstance *)instance
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    dict = twilioMessage;
    if([dict objectForKey:@"type"] == nil)
    {
        [dict setValue:@"receive" forKey:@"type"];
    }
    NSData * data = [NSJSONSerialization dataWithJSONObject:dict
                                                    options:0
                                                      error:nil];

    [HYP sendData:data
                  toInstance:instance
               trackProgress:NO];
}

- (void)processSendsWithResponse:(NSMutableDictionary *)response
{
    if ([self.delegate respondsToSelector:@selector(hypeController:didSendMessage:fromIdentifierVendor:)]) {

        [self.delegate hypeController:self didSendMessage:[response objectForKey:@"message"] fromIdentifierVendor:[response objectForKey:@"identifierForVendor"]];

    }
}

- (void)resendTwilioMessage:(NSMutableDictionary *)message
                toInstances:(NSDictionary *)instances
{

    for (NSString* key in instances) {

        HYPInstance *instance = [instances objectForKey:key];
        [self sendMessage:message toInstance:instance];

    }
}

- (void) processReceivesWithResponse:(NSMutableDictionary *)response
{
    if ([self.delegate respondsToSelector:@selector(hypeController:didReceiveMessage:)]) {

        [self.delegate hypeController:self didReceiveMessage:response];

    }
}

- (void)hypeDidReceiveMessage:(HYPMessage *)message
                 fromInstance:(HYPInstance *)fromInstance
{
    __strong HYPInstance * tmp_instance = [[HYPInstance alloc] init];
    tmp_instance = fromInstance;

    dispatch_async(dispatch_get_main_queue(), ^{

        NSLog(@"Got a message from: %@", [fromInstance stringIdentifier]);

        NSMutableDictionary *response = [NSJSONSerialization JSONObjectWithData:message.data
                                                                        options:0
                                                                          error:nil];

        if ([[response objectForKey:@"type"] isEqualToString:@"announcement"] && [[response objectForKey:@"twilio"] isEqualToString:@"NO"]){

            [self proccessAnnouncementResponsesWithDictionary:response instance:tmp_instance];

        }else if ([[response objectForKey:@"type"] isEqualToString:@"announcement"] && [[response objectForKey:@"twilio"] isEqualToString:@"YES"]){

            //
        }else if ([[response objectForKey:@"type"] isEqualToString:@"client"]){

            [self processClientWithResponse:response];

        }else if ([[response objectForKey:@"type"] isEqualToString:@"send"]){

            [self processSendsWithResponse:response];

        }else if ([[response objectForKey:@"type"] isEqualToString:@"receive"]){

            [self processReceivesWithResponse:response];
        }
    });
}

- (void)hypeDidFailSendingMessage:(HYPMessageInfo *)messageInfo
                       toInstance:(HYPInstance *)toInstance
                            error:(HYPError *)error
{
    // Sending messages can fail for a lot of reasons, such as the adapters
    // (Bluetooth and Wi-Fi) being turned off by the user while the process
    // of sending the data is still ongoing. The error parameter describes
    // the cause for the failure.
    NSLog(@"Failed to send message: %lu [%@]", (unsigned long)messageInfo.identifier, [error description]);
}

- (void)hypeDidSendMessage:(HYPMessageInfo *)messageInfo
                toInstance:(HYPInstance *)toInstance
                  progress:(float)progress
                  complete:(BOOL)complete
{
    // A message being "sent" indicates that it has been written to the output
    // streams. However, the content could still be buffered for output, so it
    // has not necessarily left the device. This is useful to indicate when a
    // message is being processed, but it does not indicate delivery by the
    // destination device.
    NSLog(@"Message being sent: %f", progress);
}

- (void)hypeDidDeliverMessage:(HYPMessageInfo *)messageInfo
                   toInstance:(HYPInstance *)toInstance
                     progress:(float)progress
                     complete:(BOOL)complete
{
    // A message being delivered indicates that the destination device has
    // acknowledge reception. If the "done" argument is true, then the message
    // has been fully delivered and the content is available on the destination
    // device. This method is useful for implementing progress bars.
    NSLog(@"Message being delivered: %f", progress);
}

- (NSString *)hypeDidRequestAccessTokenWithUserIdentifier:(NSUInteger)userIdentifier
{
    // This notification is triggered when the SDK requests an access token to ask the server
    // for a certificate. This method is called when no certificate exists or an existing one
    // is about to expire, and only when the SDK is requested to start.
    return @"";
}

#pragma mark - Notify bridge

- (void)identifierForVendor:(NSString *)identifierForVendor
             didjoinChannel:(HYPTwilioChannel *)channel
               withIdentity:(NSString *)identity
{
    HYPInstance * instance = [self.instanceChannel instanceWithIdentifierVendor:identifierForVendor];
    [self.instanceChannel setChannel:channel forIdentifierVendor:identifierForVendor];
    NSMutableDictionary * channelDict = [[NSMutableDictionary alloc]init];
    [channelDict setValue:@"client"forKey:@"type"];
    [channelDict setValue:identity forKey:@"identity"];

    NSData * data = [NSJSONSerialization dataWithJSONObject:channelDict
                                                    options:0
                                                      error:nil];

    [HYP sendData:data
                  toInstance:instance
               trackProgress:NO];
}

#pragma mark - Hype framework Manager

- (void)proccessAnnouncementResponsesWithDictionary:(NSMutableDictionary *)response
                                        instance:(HYPInstance *)instance
{
    if ([self.delegate respondsToSelector:@selector(hypeController:requestTwilioClient:)]) {

        [self.instanceChannel setInstance:instance forIdentifierVendor:[response objectForKey:@"vendorIdentifier"]];

        [self.delegate hypeController:self requestTwilioClient:[response objectForKey:@"vendorIdentifier"]];

    }
}

- (void)processClientWithResponse:(NSMutableDictionary * )response
{
    self.announcement = @"MIM";

    if ([self.delegate respondsToSelector:@selector(hypeController:didJoinTwilio:)]) {

        [self.delegate hypeController:self didJoinTwilio:response];

    }
}

- (void)failConnecting:(NSString *)response
{
    self.netAccess = false;
}

-(void)sendResponseToResolvedInstance:(HYPInstance *)instance
{
    NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
    // Hype instances that are participating on the network are identified by a full
    // UUID, composed by the vendor's identifier followed by a unique identifier generated
    // for each instance.
    NSString *identifierForVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [response setValue:@"announcement" forKey:@"type"];

    if(self.netAccess){
        [response setValue:@"YES" forKey:@"twilio"];
    }else{
        [response setValue:@"NO" forKey:@"twilio"];
    }

    [response setValue:identifierForVendor forKey:@"vendorIdentifier"];

    NSData * data = [NSJSONSerialization dataWithJSONObject:response
                                                    options:0 error:nil];

    [HYP sendData:data toInstance:instance trackProgress:NO];
}

-(void)notifiyHypeControllerOnInstanceResolved:(HYPInstance *)instance
{
    NSString *identifierForVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if ([self.delegate respondsToSelector:@selector(hypeController:didFoundInstance:withIdentifierForVendor:)]) {
        [self.delegate hypeController:self didFoundInstance:instance withIdentifierForVendor:identifierForVendor];
    }
}

-(void)notifiyHypeControllerOnInstanceLost:(HYPInstance *)instance
{
    if ([self.delegate respondsToSelector:@selector(hypeController:didLoseInstance:)]) {

        [self.delegate hypeController:self didLoseInstance:instance ];

    }
}


@end
