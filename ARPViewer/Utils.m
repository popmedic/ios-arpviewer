//
//  Utils.m
//  ARPViewer
//
//  Created by Kevin Scardina on 3/30/18.
//  Copyright © 2018 popmedic. All rights reserved.
//

#import "Utils.h"

#import "if_types.h"
#import "route.h"
#import "if_ether.h"

#import <arpa/inet.h>
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <ifaddrs.h>
#import <net/if_dl.h>
#import <net/if.h>
#import <netinet/in.h>

#define ROUNDUP(a) ((a) > 0 ? (1 + (((a) - 1) | (sizeof(long) - 1))) : sizeof(long))

@implementation IP

@end

@implementation Utils

+ (NSArray*)allIPs {
    NSMutableArray* res = [[NSMutableArray alloc] init];
    size_t needed;
    char *buf, *next;
    
    struct rt_msghdr *rtm;
    struct sockaddr * sa;
    struct sockaddr_inarp *sin;
    struct sockaddr_dl *sdl;
    
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET, NET_RT_FLAGS, RTF_LLINFO};
    
    if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), NULL, &needed, NULL, 0) < 0)
    {
        NSLog(@"error in route-sysctl-estimate");
        return nil;
    }
    
    if ((buf = (char*)malloc(needed)) == NULL)
    {
        NSLog(@"error in malloc");
        return nil;
    }
    
    if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), buf, &needed, NULL, 0) < 0)
    {
        NSLog(@"error in retrieval of routing table");
        return nil;
    }
    
    for (next = buf; next < buf + needed; next += rtm->rtm_msglen)
    {
        rtm = (struct rt_msghdr *)next;
        sin = (struct sockaddr_inarp *)(rtm + 1);
        sdl = (struct sockaddr_dl *)(sin + 1);
        sa = (struct sockaddr *)(rtm + 1);
        
        u_char *cp = (u_char*)LLADDR(sdl);
        IP* ip = [[IP alloc] init];
        ip.addr = [NSString stringWithUTF8String:inet_ntoa(sin->sin_addr)];
        ip.mac = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                       cp[0], cp[1], cp[2], cp[3], cp[4], cp[5]];
        [res addObject:ip];
        
    }
    
    free(buf);
    
    return res;
}

+ (NSString*)getDefaultGateway
{
    NSString* res = nil;
    
    size_t needed;
    char *buf, *next;
    
    struct rt_msghdr *rtm;
    struct sockaddr * sa;
    struct sockaddr * sa_tab[RTAX_MAX];
    int i = 0;
    
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET, NET_RT_FLAGS, RTF_GATEWAY};
    
    if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), NULL, &needed, NULL, 0) < 0)
    {
        NSLog(@"error in route-sysctl-estimate");
        return nil;
    }
    
    if ((buf = (char*)malloc(needed)) == NULL)
    {
        NSLog(@"error in malloc");
        return nil;
    }
    
    if (sysctl(mib, sizeof(mib) / sizeof(mib[0]), buf, &needed, NULL, 0) < 0)
    {
        NSLog(@"retrieval of routing table");
        return nil;
    }
    
    for (next = buf; next < buf + needed; next += rtm->rtm_msglen)
    {
        rtm = (struct rt_msghdr *)next;
        sa = (struct sockaddr *)(rtm + 1);
        for(i = 0; i < RTAX_MAX; i++)
        {
            if(rtm->rtm_addrs & (1 << i))
            {
                sa_tab[i] = sa;
                sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
            }
            else
            {
                sa_tab[i] = NULL;
            }
        }
        
        if(((rtm->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
           && sa_tab[RTAX_DST]->sa_family == AF_INET
           && sa_tab[RTAX_GATEWAY]->sa_family == AF_INET)
        {
            if(((struct sockaddr_in *)sa_tab[RTAX_DST])->sin_addr.s_addr == 0)
            {
                char ifName[128];
                if_indextoname(rtm->rtm_index,ifName);
                if(strcmp("en0",ifName) == 0)
                {
                    struct in_addr temp;
                    temp.s_addr = ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr;
                    res = [NSString stringWithUTF8String:inet_ntoa(temp)];
                }
            }
        }
    }
    
    free(buf);
    
    return res;
}

+ (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    if (success == 0) {
        
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"] ||
                   [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"]) {
                    
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

@end
