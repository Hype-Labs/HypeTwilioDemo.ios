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
#import <Hype/Hype.h>

/**
 * @abstract Twilio instance channel.
 * @discussion This class maps Hype instances with idenfiers for vendor
 * and HYPTwilioChannels with identifiers for vendor, so we can
 * associate hype instances with twilio channels.
 */
@interface HYPInstanceChannel : NSObject

/**
 * @abstract Hype instance and identifier for vendor map.
 * @discussion This property maps Hype instances with identifier for vendors.
 */
@property (strong, atomic, readonly) NSMutableDictionary * instanceIdentifierVendor;

/**
 * @abstract Setter.
 * @discussion Sets an HYPInstance object with a given identifier vendor.
 * @param instance HYPInstance object received.
 * @param identifierVendor Identifier for vendor received.
 */
- (void)setInstance:(HYPInstance *)instance
forIdentifierVendor:(NSString *)identifierVendor;

/**
 * @abstract Setter.
 * @discussion Sets an HYPTwilioChannel object with a given identifier vendor.
 * @param channel HYPTwilioChannel object received.
 * @param identifierVendor Identifier for vendor received.
 */
- (void)setChannel:(HYPTwilioChannel *)channel
forIdentifierVendor:(NSString *)identifierVendor;

/**
 * @abstract Getter.
 * @discussion Gets an HYPInstance object with a given identifier vendor.
 * @param identifierVendor Identifier for vendor received.
 */
- (HYPInstance *)instanceWithIdentifierVendor:(NSString *)identifierVendor;

/**
 * @abstract Getter.
 * @discussion Gets an HYPTwilioChannel object with a given identifier vendor.
 * @param identifierVendor Identifier for vendor received.
 */
- (HYPTwilioChannel *)channelWithIdentifierVendor:(NSString *)identifierVendor;

@end
