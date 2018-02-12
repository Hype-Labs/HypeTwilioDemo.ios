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

#import "HYPInstanceChannel.h"


@interface HYPInstanceChannel ()

@property (strong, atomic, readonly) NSMutableDictionary * channelIdentifierVendor;

@end

@implementation HYPInstanceChannel
@synthesize instanceIdentifierVendor = _instanceIdentifierVendor;
@synthesize channelIdentifierVendor = _channelIdentifierVendor;

- (NSMutableDictionary *)channelIdentifierVendor
{
    @synchronized(self) {
        
        if (_channelIdentifierVendor == nil) {
            _channelIdentifierVendor = [NSMutableDictionary new];
        }
        
        return _channelIdentifierVendor;
    }
}

- (NSMutableDictionary *)instanceIdentifierVendor
{
    @synchronized(self) {
        
        if (_instanceIdentifierVendor == nil) {
            _instanceIdentifierVendor = [NSMutableDictionary new];
        }
        
        return _instanceIdentifierVendor;
    }
}

- (void)setInstance:(HYPInstance *)instance
forIdentifierVendor:(NSString *)identifierVendor
{
    [self.instanceIdentifierVendor setValue:instance forKey:identifierVendor];
}

- (void)setChannel:(HYPTwilioChannel *)channel
forIdentifierVendor:(NSString *)identifierVendor
{
    [self.channelIdentifierVendor setValue:channel forKey:identifierVendor];
}

- (HYPInstance *)instanceWithIdentifierVendor:(NSString *)identifierVendor
{
    HYPInstance * instance = [self.instanceIdentifierVendor objectForKey:identifierVendor];
    
    return instance;

}

- (HYPTwilioChannel *) channelWithIdentifierVendor:(NSString *)identifierVendor
{
    HYPTwilioChannel * channel = [self.channelIdentifierVendor objectForKey:identifierVendor];
    
    return channel;
}

@end
