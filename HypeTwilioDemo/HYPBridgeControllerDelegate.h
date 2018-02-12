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
#import "HYPTwilioChannel.h"
#import "HYPTwilioMessage.h"

/**
 * @abstract Bridge controller delegate.
 * @discussion This controller delegate has the purpose of dealing
 * with twilio controller notifications. This delegate notifys upper classes
 * when some client joined a channel, a message was sent to twilio with
 * success, a new message arrived, if a client fails connecting to twilio
 * and Hype framework loses an instance.
 */
@class HYPBridgeController;

@protocol HYPBridgeControllerDelegate <NSObject>

/**
 * @abstract Notification issued when identifier for vendor joins a channel.
 * @discussion This notification indicates that the given identifier for vendor
 * joined a channel with the given identity.
 * @param bridgeController The controller issuing the notification.
 * @param channel Channel that has been joined.
 * @param identity Identity of the device that joined the channel.
 */
- (void)bridgeController:(HYPBridgeController *)bridgeController
          didJoinChannel:(HYPTwilioChannel *)channel
            withIdentity:(NSString *)identity;

/**
 * @abstract Notification issued when a client sends a message.
 * @discussion This notification indicates that the message was
 * sent with success.
 * @param bridgeController The controller issuing the notification.
 * @param response Feedback given by twilio.
 */
- (void)bridgeController:(HYPBridgeController *)bridgeController
          didSendMessage:(NSString *)response;

/**
 * @abstract Notification issued when twilio channel has a new message.
 * @discussion This notification indicates that the channel has a new message.
 * @param bridgeController The controller issuing the notification.
 * @param message Message received.
 */
- (void)bridgeController:(HYPBridgeController *)bridgeController
       didReceiveMessage:(NSMutableDictionary *)message;

/**
 * @abstract Notification issued when identifier for vendor joins a channel.
 * @discussion This notification indicates that the given identifier for vendor
 * joined a channel.
 * @param bridgeController The controller issuing the notification.
 * @param response Contains the identity of the client that has been joined.
 */
- (void)bridgeController:(HYPBridgeController *)bridgeController
          didJoinTwilio:(NSMutableDictionary *)response;

/**
 * @abstract Notification issued when fails connecting to twilio channel.
 * @discussion This notification indicates that client could not join twilio channel.
 * @param bridgeController The controller issuing the notification.
 * @param response Indicates a message describing the why it failed.
 */
- (void)bridgeController:(HYPBridgeController *)bridgeController
          failConnecting:(NSString *)response;

/**
 * @abstract Notification issued when loses an instance.
 * @discussion This notification indicates that lost a instance of hype framework.
 * @param bridgeController The controller issuing the notification.
 * @param response Indicates a message describing the why it failed.
 */
- (void)bridgeController:(HYPBridgeController *)bridgeController
          didLoseInstance:(NSString *)response;
@end
