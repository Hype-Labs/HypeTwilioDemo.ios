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

#import <Foundation/Foundation.h>
#import "HYPHypeControllerDelegate.h"
#import "HYPTwilioChannel.h"
#import "HYPTwilioMessage.h"
#import <Hype/Hype.h>

/**
 * @abstract Hype controller.
 * @discussion This controller has the purpose to control the hype
 * framework. The main responsabilities of this controller are: 
 * start hype framework, join an offline peer to a twilio channel,
 * send messages to a closer instance and foward messages from twilio
 * to a closer instance.
 */
@interface HYPHypeController : NSObject

@property (atomic, weak) id<HYPHypeControllerDelegate> delegate;


/**
 * @abstract Requests Hype framework to start.
 * @discussion This method requests Hype framework to start.
 */
- (void)requestHypeToStart;

/**
 * @abstract Notification issued when identifier for vendor joins a channel.
 * @discussion This notification indicates that the given identifier for vendor
 * joined a channel with the given identity.
 * @param channel Channel that has been joined.
 * @param identifierForVendor Identifier for vendor of the device joined.
 * @param identity Identity of the device that joined the channel.
 */
- (void)identifierForVendor:(NSString *)identifierForVendor
             didjoinChannel:(HYPTwilioChannel *)channel
               withIdentity:(NSString *)identity;

/**
 * @abstract Sends a message to instance.
 * @discussion This method sends a message to a given instance.
 * @param instance Instance that will receive the message.
 * @param text Message to send.
 * @param identifierForVendor Peer identifier for vendor.
 */
- (void)sendMessageToCloserInstance:(HYPInstance *)instance
                           withText:(NSString *)text
             identifierForVendor:(NSString *)identifierForVendor;

/**
 * @abstract Forwards messages to saved instances.
 * @discussion This method fowards a messages to saved instances.
 * @param message Message that will be foward
 * @param instances Saved instances.
 */
- (void)resendTwilioMessage:(NSMutableDictionary *)message
                toInstances:(NSDictionary *)instances;

/**
 * @abstract Notifys class that it fails trying to connect to twilio.
 * @discussion This method notifys class when it fails trying to connect to twilio.
 * @param response Error response
 */
- (void)failConnecting:(NSString *)response;

@end
