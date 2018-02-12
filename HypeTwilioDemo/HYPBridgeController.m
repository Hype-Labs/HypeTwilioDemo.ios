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

#import "HYPBridgeController.h"
#import "HYPHypeController.h"
#import "HYPTwilioController.h"
#import "HYPInstanceChannel.h"
#import <UIKit/UIKit.h>

@interface HYPBridgeController ()

@property (atomic, readonly) HYPTwilioController * twilioController;
@property (atomic, readonly) HYPHypeController * hypeController;
@property (atomic) NSString * identifierForVendor;
//@property (atomic) NSString * announcement;
@property (atomic, readonly) HYPInstanceChannel * instanceChannel;
@property (atomic, readonly) HYPTwilioMessage * twilioMessage;
@property (strong, atomic, readonly) NSMutableSet * sidContainer;

@end

@implementation HYPBridgeController
@synthesize twilioController = _twilioController;
@synthesize hypeController = _hypeController;
@synthesize instanceChannel = _instanceChannel;
@synthesize twilioMessage = _twilioMessage;
@synthesize sidContainer = _sidContainer;

- (NSMutableSet *)sidContainer
{
    @synchronized(self) {
        
        if (_sidContainer == nil) {
            _sidContainer = [NSMutableSet new];
        }
        
        return _sidContainer;
    }
}

- (HYPTwilioController *)twilioController
{
    @synchronized(self) {
        
        if (_twilioController == nil) {
            _twilioController = [[HYPTwilioController alloc] init];
            _twilioController.delegate = self;
        }
        
        return _twilioController;
    }
}

- (HYPHypeController *)hypeController
{
    @synchronized(self) {
        
        if (_hypeController == nil) {
            _hypeController = [[HYPHypeController alloc] init];
            _hypeController.delegate = self;
        }
        
        return _hypeController;
    }
}

- (HYPInstanceChannel *)instanceChannel
{
    @synchronized(self) {
        
        if (_instanceChannel == nil) {
            _instanceChannel = [[HYPInstanceChannel alloc] init];
            
        }
        return _instanceChannel;
    }
}

- (HYPTwilioMessage *)twilioMessage
{
    @synchronized(self) {
        
        if (_twilioMessage == nil) {
            _twilioMessage = [[HYPTwilioMessage alloc] init];
            
        }
        return _twilioMessage;
    }
}

- (void)setTwilioController:(HYPTwilioController *)twilioController
{
    @synchronized (self) {
        _twilioController = twilioController;
    }
}

- (void)generateTwilioClient
{
    NSString *identifierForVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    self.identifierForVendor = identifierForVendor;
    
    [self generateTwilioClientWithIdentifierForVendor:self.identifierForVendor];
    
}

- (void) generateTwilioClientWithIdentifierForVendor:(NSString * )identifierForVendor
{
    [self.twilioController generateTwilioClientWithIdentifierForVendor:identifierForVendor];
}

- (void) requestHypeToStart
{
    [self.hypeController requestHypeToStart];
}


#pragma mark - Twilio Controller Delegates

// Notification
- (void)twilioController:(HYPTwilioController *)twilioController
          didJoinChannel:(HYPTwilioChannel *)channel
 withIdentifierForVendor:(NSString *)identifierForVendor
             identity:(NSString *)identity

{
    if([self.identifierForVendor isEqualToString:identifierForVendor]){
        
        if ([self.delegate respondsToSelector:@selector(bridgeController:didJoinChannel:withIdentity:)]) {
            [self.delegate bridgeController:self
                             didJoinChannel:channel withIdentity:identity];
        }
        [self.instanceChannel setChannel:channel forIdentifierVendor:identifierForVendor];
        
    }else{
        
        [self.hypeController identifierForVendor:identifierForVendor didjoinChannel:channel withIdentity:identity];
        [self.instanceChannel setChannel:channel forIdentifierVendor:identifierForVendor];
    }
}

- (NSMutableDictionary *)getRandomObjectFromDictionary:(NSMutableDictionary *)dictionary
{
    [dictionary removeObjectForKey:self.identifierForVendor];
    NSArray *keys = dictionary.allKeys;
    NSMutableDictionary * tempDict = [[NSMutableDictionary alloc]init];
    [tempDict setValue:dictionary[keys[arc4random_uniform((int)keys.count)]] forKey:keys[arc4random_uniform((int)keys.count)]];
    
    return tempDict ;
}

- (void)sendMessageToTwilioWithText:(NSString *)text
{
    HYPTwilioChannel * channel = [self.instanceChannel channelWithIdentifierVendor:self.identifierForVendor];
    
    if(channel != nil){
    
        [self sendMessageToTwilioToChannel:channel withText:text];
        
    }else{
        
        NSMutableDictionary * instancesDict = self.instanceChannel.instanceIdentifierVendor;
        NSString * identifierForVendor = [[instancesDict allKeys] objectAtIndex:0]; // Assumes 'message' is not empty
        HYPInstance * instance = [instancesDict objectForKey:identifierForVendor];
        [self.hypeController sendMessageToCloserInstance:instance withText: text identifierForVendor:identifierForVendor];
        
    }
}

- (void)sendMessageToTwilioToChannel:(HYPTwilioChannel *)channel
                             withText:(NSString *)text
{
    [self.twilioController sendMessageToTwilioToChannel:channel withText:text];
}

// Notification
- (void)twilioController:(HYPTwilioController *)twilioController
           didSendMessage:(NSString *)response
{
    if ([self.delegate respondsToSelector:@selector(bridgeController:didSendMessage:)]) {
        [self.delegate bridgeController:self
                         didSendMessage:response];
    }
}

- (void)manageMenssageReceptionsWithReceivedMessage:(NSMutableDictionary *)receivedMessage
{

    NSString * twilioSid = [receivedMessage objectForKey:@"sid"];
    BOOL flag = [self.sidContainer containsObject:twilioSid];
 
    if(flag){
        
        NSMutableDictionary * instances = self.instanceChannel.instanceIdentifierVendor;
        [self.hypeController resendTwilioMessage:receivedMessage
                                     toInstances:instances];
        
    }else{
        
        [self.sidContainer addObject:twilioSid];
        if ([self.delegate respondsToSelector:@selector(bridgeController:didReceiveMessage:)]) {
            [self.delegate bridgeController:self
                          didReceiveMessage:receivedMessage];
        }
    }
}

// ReceiveMessageNotification
- (void)twilioController:(HYPTwilioController *)twilioController
        didReceiveMessage:(HYPTwilioMessage *)message
{
    NSMutableDictionary * receivedMessage = [[NSMutableDictionary alloc] init];
    [receivedMessage setValue:message.twilioMessage.sid forKey:@"sid"];
    [receivedMessage setValue:message.twilioMessage.author forKey:@"author"];
    [receivedMessage setValue:message.twilioMessage.body forKey:@"body"];
    [self manageMenssageReceptionsWithReceivedMessage:receivedMessage];
}

- (void)twilioController:(HYPTwilioController *)twilioController
           failConnecting:(NSString *)response
{
    if ([self.delegate respondsToSelector:@selector(bridgeController:failConnecting:)]) {
        [self.delegate bridgeController:self
                      failConnecting:@"twilio error"];
    }
    [self.hypeController failConnecting: response];
}

#pragma mark - Hype Controller Delegates

- (void)hypeController:(HYPHypeController *)hypeController
    requestTwilioClient:(NSString *)identifierForVendor
{
    [self generateTwilioClientWithIdentifierForVendor:identifierForVendor];
}

-(void)hypeController:(HYPHypeController *)hypeController
         didJoinTwilio:(NSMutableDictionary *)response
{
    if ([self.delegate respondsToSelector:@selector(bridgeController:didJoinTwilio:)]) {
        [self.delegate bridgeController:self
                         didJoinTwilio:response];
    }
}

- (void)hypeController:(HYPHypeController *)hypeController
         didSendMessage:(NSString *)message
   fromIdentifierVendor:(NSString *)identifierVendor
{
    HYPTwilioChannel * twilioChannel = [self.instanceChannel channelWithIdentifierVendor:identifierVendor];
    [self sendMessageToTwilioToChannel:twilioChannel withText:message];
}

- (void)hypeController:(HYPHypeController *)hypeController
       didFoundInstance:(HYPInstance *)instance
withIdentifierForVendor:(NSString *)identifierForVendor
{
    [self.instanceChannel setInstance:instance forIdentifierVendor:identifierForVendor];
}

- (void)hypeController:(HYPHypeController *)hypeController
      didReceiveMessage:(NSMutableDictionary *)message
{
    [self manageMenssageReceptionsWithReceivedMessage:message];
}

- (void)hypeController:(HYPHypeController *)hypeController
        didLoseInstance:(HYPInstance *)instance
{
    NSMutableDictionary * dict = self.instanceChannel.instanceIdentifierVendor;
    NSArray *keys = [dict allKeys];
    
    for (int i = 0 ; i < [keys count]; i++)
    {
        if ([dict[keys[i]] isEqual:instance])
        {   
            [dict removeObjectForKey:keys[i]];
        }
    }
    
    HYPTwilioChannel * channel = [self.instanceChannel channelWithIdentifierVendor:self.identifierForVendor];
    
    if([[dict allKeys] count] == 0 && channel == nil ){
        if ([self.delegate respondsToSelector:@selector(bridgeController:didLoseInstance:)]) {
            [self.delegate bridgeController:self
                            didLoseInstance:@"off"];
        }
    }
}

@end
