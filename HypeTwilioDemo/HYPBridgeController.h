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

#import "HYPBridgeControllerDelegate.h"
#import "HYPHypeControllerDelegate.h"
#import "HYPTwilioControllerDelegate.h"

/**
 * @abstract Bridge controller.
 * @discussion This controller has the purpose of bridging
 * two controllers, the twilio controller and hype controller.
 * The main goal of this bridge controller is to map hype instances
 * into twilio clients and when new twilio messages arrived, this
 * controller maps twilio clients into hype instances.
 */
@interface HYPBridgeController : NSObject <HYPTwilioControllerDelegate, HYPHypeControllerDelegate>

@property (atomic, weak) id<HYPBridgeControllerDelegate> delegate;

/**
 * @abstract Generates a twilio client.
 * @discussion This method generates a twilio client.
 */
- (void)generateTwilioClient;

/**
 * @abstract Sends a message to twilio channel.
 * @discussion This method sends a message to the given twilio channnel.
 * @param text Message to send.
 */
- (void)sendMessageToTwilioWithText:(NSString *)text;

/**
 * @abstract Requests Hype framework to start.
 * @discussion This method requests Hype framework to start.
 */
- (void)requestHypeToStart;

/**
 * @abstract Sends a message to twilio channel.
 * @discussion This method sends a message to the given twilio channnel.
 * @param channel Channel to send.
 * @param text Message to send.
 */
- (void)sendMessageToTwilioToChannel:(HYPTwilioChannel *)channel
                            withText:(NSString *)text;

@end
