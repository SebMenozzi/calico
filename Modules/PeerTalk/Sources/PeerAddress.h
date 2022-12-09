#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>
#import <netinet/in.h>
#import <sys/socket.h>

// Represents a peer's address
@interface PeerAddress : NSObject {
    struct sockaddr_storage sockaddr_;
}

// For network addresses, this is the IP address in textual format
@property (readonly) NSString *name;
// For network addresses, this is the port number. Otherwise 0 (zero).
@property (readonly) NSInteger port;

- (id)initWithSockaddr:(const struct sockaddr_storage*)addr;

@end
