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

#import <Hype/Hype.h>

/**
 * @abstract Hype controller delegate.
 * @discussion This controller delegate has the purpose of dealing
 * with hype controller notifications. This delegate notifys upper classes
 * when it neeeds to request a twilio client, needs to join a offline peer
 * to a twilio channel, needs to foward a message from a offline peer to twilio,
 * when founds or loses a new peer.
 */
@class HYPHypeController;

@protocol HYPHypeControllerDelegate <NSObject>

/**
 * @abstract Notification issued when a twilio client request occur.
 * @discussion This notification indicates that a offline peer 
 * wants do connect to twilio. So
 * @param hypeController The controller issuing the notification.
 * @param identifierForVendor Indicates the identifier vendor of the offline client.
 */
- (void)hypeController:(HYPHypeController *)hypeController
   requestTwilioClient:(NSString *)identifierForVendor;

/**
 * @abstract Notification issued when identifier for vendor joins a channel.
 * @discussion This notification indicates that the given identifier for vendor
 * joined a channel with the given identity.
 * @param hypeController The controller issuing the notification.
 * @param response Channel that has been joined.
 */
- (void)hypeController:(HYPHypeController *)hypeController
         didJoinTwilio:(NSMutableDictionary *)response;
/**
 * @abstract Notification issued to send messages to twilio.
 * @discussion This notification occurs when a client fowards a message
 * to twilio from a offline client.
 * @param hypeController The controller issuing the notification.
 * @param instance Indicates the instance of the offline client.
 * @param identifierVendor Indicates the identifier vendor of the offline client.
 */
- (void) hypeController:(HYPHypeController *)hypeController
         didSendMessage:(NSString *)instance
   fromIdentifierVendor:(NSString *)identifierVendor;

/**
 * @abstract Notification issued to indicate that hype found an instance.
 * @discussion This notification occurs when the hype framework found an instance.
 * @param hypeController The controller issuing the notification.
 * @param instance Indicates the instance of the offline client.
 * @param identifierForVendor Indicates the identifier vendor of the offline client.
 */
- (void)hypeController:(HYPHypeController *)hypeController
       didFoundInstance:(HYPInstance *)instance
withIdentifierForVendor:(NSString *) identifierForVendor;

/**
 * @abstract Notification issued when loses a instance.
 * @discussion This notification indicates that client could not join twilio channel.
 * @param hypeController The controller issuing the notification.
 * @param instance Indicates a message describing the why it failed.
 */
- (void)hypeController:(HYPHypeController * )hypeController
        didLoseInstance:(HYPInstance *)instance;

/**
 * @abstract Notification issued hype framework receives message.
 * @discussion This notification indicates that hype framework received a message.
 * @param hypeController The controller issuing the notification.
 * @param message Message received.
 */
- (void)hypeController:(HYPHypeController *)hypeController
      didReceiveMessage:(NSMutableDictionary *)message;

@end
