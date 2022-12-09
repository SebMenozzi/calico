#import <dispatch/dispatch.h>
#import <Foundation/Foundation.h>

#import "USBMux.h"

typedef uint32_t USBMuxPacketType;
enum {
    USBMuxPacketTypeResult = 1,
    USBMuxPacketTypeConnect = 2,
    USBMuxPacketTypeListen = 3,
    USBMuxPacketTypeDeviceAdd = 4,
    USBMuxPacketTypeDeviceRemove = 5,
    // Unknown = 6,
    // Unknown = 7,
    USBMuxPacketTypePlistPayload = 8,
};

typedef uint32_t USBMuxPacketProtocol;
enum {
    USBMuxPacketProtocolBinary = 0,
    USBMuxPacketProtocolPlist = 1,
};

typedef struct usbmux_packet {
    uint32_t size;
    USBMuxPacketProtocol protocol;
    USBMuxPacketType type;
    uint32_t tag;
    char data[0];
} __attribute__((__packed__)) usbmux_packet_t;

#pragma mark -

/// Represents a channel of communication between the host process and a remote
/// (device) system. In practice, a USBMuxChannel is connected to a usbmuxd
/// endpoint which is configured to either listen for device changes (the
/// USBMuxManager's channel is usually configured as a device notification listener) or
/// configured as a TCP bridge (e.g. channels returned from USBMuxManager's
/// connectToDevice:port:callback:). You should not create channels yourself, but
/// let USBMuxManager provide you with already configured channels.
@interface USBMuxChannel : NSObject {
    dispatch_io_t channel_;
    dispatch_queue_t queue_;
    uint32_t nextPacketTag_;
    NSMutableDictionary *responseQueue_;
    BOOL autoReadPackets_;
    BOOL isReadingPackets_;
}

// The underlying dispatch I/O channel. This is handy if you want to handle your
// own I/O logic without USBMuxChannel. Remember to dispatch_retain() the channel
// if you plan on using it as it might be released from the USBMuxChannel at any
// point in time.
@property (readonly) dispatch_io_t dispatchChannel;

// The underlying file descriptor.
@property (readonly) dispatch_fd_t fileDescriptor;

// Send data
- (void)sendDispatchData:(dispatch_data_t)data callback:(void(^)(NSError*))callback;
- (void)sendData:(NSData*)data callback:(void(^)(NSError*))callback;

// Read data
- (void)readFromOffset:(off_t)offset length:(size_t)length callback:(void(^)(NSError *error, dispatch_data_t data))callback;

// Close the channel, preventing further reads and writes, but letting currently
// queued reads and writes finish.
- (void)cancel;

// Close the channel, preventing further reads and writes, immediately
// terminating any ongoing reads and writes.
- (void)stop;

@end

#pragma mark -

@interface USBMuxChannel (Private)

+ (NSDictionary*)packetDictionaryWithPacketType:(NSString*)messageType
                                        payload:(NSDictionary*)payload;
- (BOOL)openOnQueue:(dispatch_queue_t)queue error:(NSError**)error
              onEnd:(void(^)(NSError *error))onEnd;
- (void)listenWithBroadcastHandler:(void(^)(NSDictionary *packet))broadcastHandler
                          callback:(void(^)(NSError*))callback;
- (uint32_t)nextPacketTag;
- (void)sendPacketOfType:(USBMuxPacketType)type
            overProtocol:(USBMuxPacketProtocol)protocol
                     tag:(uint32_t)tag payload:(NSData*)payload
                callback:(void(^)(NSError*))callback;
- (void)sendPacket:(NSDictionary*)packet
               tag:(uint32_t)tag
          callback:(void(^)(NSError *error))callback;
- (void)sendRequest:(NSDictionary*)packet
           callback:(void(^)(NSError *error, NSDictionary *responsePacket))callback;
- (void)scheduleReadPacketWithCallback:(void(^)(NSError *error, NSDictionary *packet, uint32_t packetTag))callback;
- (void)scheduleReadPacketWithBroadcastHandler:(void(^)(NSDictionary *packet))broadcastHandler;
- (void)setNeedsReadingPacket;

@end
