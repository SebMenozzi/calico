#import "PTAddress.h"

#include <arpa/inet.h>

/// Read member of sockaddr_in without knowing the family
#define PT_SOCKADDR_ACCESS(ss, member4, member6) \
  (((ss)->ss_family == AF_INET) ? ( \
    ((const struct sockaddr_in *)(ss))->member4 \
  ) : ( \
    ((const struct sockaddr_in6 *)(ss))->member6 \
  ))

@implementation PTAddress

- (id)initWithSockaddr:(const struct sockaddr_storage*)addr {
    if (!(self = [super init]))
        return nil;

    assert(addr);
    memcpy((void*)&sockaddr_, (const void*)addr, addr->ss_len);

    return self;
}

- (NSString*)name {
    if (sockaddr_.ss_len) {
        const void *sin_addr = NULL;
        size_t bufferSize = 0;

        if (sockaddr_.ss_family == AF_INET6) {
            bufferSize = INET6_ADDRSTRLEN;
            sin_addr = (const void *)&((const struct sockaddr_in6*)&sockaddr_)->sin6_addr;
        } else {
            bufferSize = INET_ADDRSTRLEN;
            sin_addr = (const void *)&((const struct sockaddr_in*)&sockaddr_)->sin_addr;
        }

        char *buffer = CFAllocatorAllocate(kCFAllocatorDefault, bufferSize + 1, 0);

        if (inet_ntop(sockaddr_.ss_family, sin_addr, buffer, (unsigned int)bufferSize - 1) == NULL) {
            CFAllocatorDeallocate(kCFAllocatorDefault, buffer);
            
            return nil;
        }

        return [[NSString alloc] initWithBytesNoCopy:(void*)buffer length:strlen(buffer) encoding:NSUTF8StringEncoding freeWhenDone:YES];
    }

    return nil;
}

- (NSInteger)port {
    if (sockaddr_.ss_len) {
        return ntohs(PT_SOCKADDR_ACCESS(&sockaddr_, sin_port, sin6_port));
    }

    return 0;
}

- (NSString*)description {
    if (sockaddr_.ss_len) {
        return [NSString stringWithFormat:@"%@:%u", self.name, (unsigned) self.port];
    }

    return @"(?)";
}

@end
