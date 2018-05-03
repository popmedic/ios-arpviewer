//
//  Utils.h
//  ARPViewer
//
//  Created by Kevin Scardina on 3/30/18.
//  Copyright © 2018 popmedic. All rights reserved.
//

#ifndef Utils_h
#define Utils_h
#import <Foundation/Foundation.h>

@interface IP:NSObject

@property NSString* addr;
@property NSString* mac;

@end

@interface Utils : NSObject

+ (NSArray*)allIPs;
+ (NSString*)getDefaultGateway;
+ (NSString *)getIPAddress;

@end
#endif /* Utils_h */
