//
//  AnalyticsController.m
//  
//
//  Created by Dubois, Theodore Alexander on 11/18/15.
//
//

#import "AnalyticsController.h"
#import "uuid.h"

@implementation AnalyticsController

- (void)awakeFromNib {
    NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    NSString *uuid = [self uuid];
    if (!uuid) {
#ifdef DEBUG
        NSLog(@"no hardware id somehow failed");
#endif
        return; // it's not mission critical
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://vindo-analytics.herokuapp.com/ping?uuid=%@&version=%@", uuid, version];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (NSString *)uuid {
    kern_return_t   kernResult = KERN_SUCCESS;
    io_iterator_t   intfIterator;
    UInt8           MACAddress[kIOEthernetAddressSize];
    
    kernResult = FindEthernetInterfaces(&intfIterator);
    
    if (KERN_SUCCESS != kernResult) {
        return nil;
    }
    else {
        kernResult = GetMACAddress(intfIterator, MACAddress, sizeof(MACAddress));
        
        if (KERN_SUCCESS != kernResult) {
            return nil;
        }
    }
    
    (void) IOObjectRelease(intfIterator);   // Release the iterator.
    
    return [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", MACAddress[0], MACAddress[1], MACAddress[2], MACAddress[3], MACAddress[4], MACAddress[5]];
}

@end
