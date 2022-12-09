#import <dispatch/dispatch.h>
#import <Foundation/Foundation.h>

@class USBMuxChannel;

// Error codes returned with NSError.code for NSError domain USBMuxErrorDomain
typedef enum {
    USBMuxManagerErrorBadDevice = 2,
    USBMuxManagerErrorConnectionRefused = 3,
} USBMuxError;

@interface USBMuxManager : NSObject {
    USBMuxChannel *channel_;
}

/// Shared, implicitly opened manager.
+ (instancetype)shared;

- (instancetype)init NS_UNAVAILABLE;

/// Connect to a TCP *port* on a device, while the actual transport is over USB.
/// Upon success, *error* is nil and *channel* is a duplex I/O channel.
/// You can retrieve the underlying file descriptor using
/// dispatch_io_get_descriptor(channel). The dispatch_io_t channel behaves just
/// like any stream type dispatch_io_t, making it possible to use the same logic
/// for both USB bridged connections and e.g. ethernet-based connections.
///
/// *onStart* is called either when a connection failed, in which case the error
/// argument is non-nil, or when the connection was successfully established (the
/// error argument is nil). Must not be NULL.
///
/// *onEnd* is called when a connection was open and just did close. If the error
/// argument is non-nil, the channel closed because of an error. Pass NULL for no
/// callback.
///
- (void)connectToDevice:(NSNumber*)deviceID
                   port:(int)port
                onStart:(void(^)(NSError *error, dispatch_io_t channel))onStart
                  onEnd:(void(^)(NSError *error))onEnd;

/// Start listening for devices. You only need to invoke this method on custom
/// instances to start receiving notifications. The shared instance returned from
/// +sharedHub is always in listening mode.
///
/// *onStart* is called either when the system failed to start listening, in
/// which case the error argument is non-nil, or when the receiver is listening.
/// Pass NULL for no callback.
///
/// *onEnd* is called when listening stopped. If the error argument is non-nil,
/// listening stopped because of an error. Pass NULL for no callback.
///
- (void)listenOnQueue:(dispatch_queue_t)queue
              onStart:(void(^)(NSError*))onStart
                onEnd:(void(^)(NSError*))onEnd;

- (void)handleBroadcastPacket:(NSDictionary*)packet;

@end
