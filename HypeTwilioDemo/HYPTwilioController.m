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

#import "HYPTwilioController.h"
#import "HYPTwilioChannel.h"
#import "HYPTwilioMessage.h"
#import "HYPTwilioClientWrapper.h"
#import <TwilioChatClient/TwilioChatClient.h>

@interface HYPTwilioController () <TwilioChatClientDelegate>

@property (atomic) TCHChannel * channel;
@property (strong, nonatomic) NSMutableDictionary * clientDictionary;

@end

@implementation HYPTwilioController

- (NSMutableDictionary *)clientDictionary
{
    
    if (_clientDictionary == nil) {
        
        _clientDictionary = [NSMutableDictionary new];
        
    }
    
    return _clientDictionary;
}

- (void)generateTwilioClientWithIdentifierForVendor:(NSString * )identifierForVendor
{
    NSString *tokenEndpoint = @"http://localhost:5000/token?device=%@";
    NSString *urlString = [NSString stringWithFormat:tokenEndpoint, identifierForVendor];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSError *jsonError;
            NSDictionary *tokenResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:kNilOptions
                                                                            error:&jsonError];
            // Handle response from server
            if (!jsonError) {
                
                TwilioChatClient * client = [TwilioChatClient chatClientWithToken:tokenResponse[@"token"] properties:nil delegate:self];
                HYPTwilioClientWrapper * wrapper = [[HYPTwilioClientWrapper alloc] initWithClient:client];
                [self.clientDictionary setObject:identifierForVendor
                                          forKey:wrapper];
                
            } else {
                
                if ([self.delegate respondsToSelector:@selector(twilioController:failConnecting:)]) {
                
                    [self.delegate twilioController:self failConnecting:@"error"];
                    
                }
                NSLog(@"ViewController viewDidLoad: error parsing token from server");
            }
        } else {
            
            if ([self.delegate respondsToSelector:@selector(twilioController:failConnecting:)]) {
                
                [self.delegate twilioController:self failConnecting:@"Error"];
                
            }
            NSLog(@"ViewController viewDidLoad: error fetching token from server");
        }
        
    }];
    [dataTask resume];
}

- (void)chatClient:(TwilioChatClient *)client
synchronizationStatusChanged:(TCHClientSynchronizationStatus)status {
    
    if (status == TCHClientSynchronizationStatusCompleted) {
    
        NSString *defaultChannel = @"general";
        [client.channelsList channelWithSidOrUniqueName:defaultChannel completion:^(TCHResult *result, TCHChannel *channel) {
            
            if (channel) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [channel joinWithCompletion:^(TCHResult *result) {
                        
                        HYPTwilioClientWrapper * wrapper = [[HYPTwilioClientWrapper alloc] initWithClient:client];
                        
                        NSString * identity = client.userInfo.identity;
                        
                        NSString * identifierForVendor = [self.clientDictionary objectForKey:wrapper];
                        
                        // Clean up
                        [self.clientDictionary removeObjectForKey:client];
                        
                        NSLog(@"Joined general channel");
                        
                        HYPTwilioChannel * hypTwilioChannel = [[HYPTwilioChannel alloc] initWithTwilioChannel:channel];
                        
                        if ([self.delegate respondsToSelector:@selector(twilioController:didJoinChannel:withIdentifierForVendor:identity:)]) {
                            [self.delegate twilioController:self
                                             didJoinChannel:hypTwilioChannel
                                    withIdentifierForVendor:identifierForVendor identity:identity];
                        }
                    }];
                });
            } else {
                // Create the general channel (for public use) if it hasn't been created yet
                [client.channelsList createChannelWithOptions:@{
                                                                TCHChannelOptionFriendlyName: @"General Chat Channel",
                                                                TCHChannelOptionType: @(TCHChannelTypePublic)
                                                                }
                                                   completion:^(TCHResult *result, TCHChannel *channel) {
                                                       [channel joinWithCompletion:^(TCHResult *result) {
                                                           [channel setUniqueName:defaultChannel completion:^(TCHResult *result) {
                                                               NSLog(@"channel unique name set");
                                                           }];
                                                       }];
                                                   }];
            }
        }];
    }
}

// Receive messages
- (void)chatClient:(TwilioChatClient *)client
           channel:(TCHChannel *)channel
      messageAdded:(TCHMessage *)message
{
    HYPTwilioMessage * hypMessage = [[HYPTwilioMessage alloc] initWithTwilioMessage:message];
    if ([self.delegate respondsToSelector:@selector(twilioController:didReceiveMessage:)]) {
        
        [self.delegate twilioController:self didReceiveMessage:hypMessage];
        
    }
}

// Send messages
- (void)sendMessageToTwilioToChannel:(HYPTwilioChannel *)channel
                             withText:(NSString *)text
{
    TCHMessage *message = [channel.twilioChannel.messages createMessageWithBody:text];
    [channel.twilioChannel.messages sendMessage:message completion:^(TCHResult *result) {
        if (!result.isSuccessful) {
            NSLog(@"Message not sent.");
            if ([self.delegate respondsToSelector:@selector(twilioController:didSendMessage:)]) {
                [self.delegate twilioController:self didSendMessage:@"Error"];
                
            }
        }else{
            NSLog(@"Message sent.");
            if ([self.delegate respondsToSelector:@selector(twilioController:didSendMessage:)]) {
                [self.delegate twilioController:self didSendMessage:@"Success"];
                
            }
        }
    }];
}

@end
