#import "USBMuxChannel.h"

#import <netinet/in.h>
#import <sys/socket.h>
#import <sys/ioctl.h>
#import <sys/un.h>
#import <err.h>

#import "PTPrivate.h"

@implementation USBMuxChannel

static NSString *const USBMuxErrorDomain = @"USBMuxError";
static const uint32_t kUSBMuxPacketMaxPayloadSize = UINT32_MAX - (uint32_t)sizeof(usbmux_packet_t);

static uint32_t usbmux_packet_payload_size(usbmux_packet_t *upacket) {
    return upacket->size - sizeof(usbmux_packet_t);
}

static void *usbmux_packet_payload(usbmux_packet_t *upacket) {
    return (void*)upacket->data;
}

static void usbmux_packet_set_payload(usbmux_packet_t *upacket,
                                      const void *payload,
                                      uint32_t payloadLength)
{
    memcpy(usbmux_packet_payload(upacket), payload, payloadLength);
}


static usbmux_packet_t *usbmux_packet_alloc(uint32_t payloadSize) {
    assert(payloadSize <= kUSBMuxPacketMaxPayloadSize);

    uint32_t upacketSize = sizeof(usbmux_packet_t) + payloadSize;
    usbmux_packet_t *upacket = CFAllocatorAllocate(kCFAllocatorDefault, upacketSize, 0);
    memset(upacket, 0, sizeof(usbmux_packet_t));
    upacket->size = upacketSize;

    return upacket;
}


static usbmux_packet_t *usbmux_packet_create(USBMuxPacketProtocol protocol,
                                             USBMuxPacketType type,
                                             uint32_t tag,
                                             const void *payload,
                                             uint32_t payloadSize)
{
    usbmux_packet_t *packet = usbmux_packet_alloc(payloadSize);
    if (!packet) {
        return NULL;
    }

    packet->protocol = protocol;
    packet->type = type;
    packet->tag = tag;

    if (payload && payloadSize) {
        usbmux_packet_set_payload(packet, payload, (uint32_t)payloadSize);
    }

    return packet;
}

static void usbmux_packet_free(usbmux_packet_t *upacket) {
    CFAllocatorDeallocate(kCFAllocatorDefault, upacket);
}

static NSString *bundleName = nil;
static NSString *bundleVersion = nil;
static NSString *bundleIdentifier = nil;

+ (NSDictionary*)packetDictionaryWithPacketType:(NSString*)messageType
                                        payload:(NSDictionary*)payload {
    NSDictionary *packet = nil;

    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary *infoDict = [NSBundle mainBundle].infoDictionary;

        if (infoDict) {
            bundleName = [infoDict objectForKey:@"CFBundleName"];
            bundleVersion = [[infoDict objectForKey:@"CFBundleVersion"] description];
            bundleIdentifier = [[infoDict objectForKey:@"CFBundleIdentifier"] description];
        }
    });

    if (bundleName && bundleVersion && bundleIdentifier) {
        packet = [NSDictionary dictionaryWithObjectsAndKeys:
            messageType, USBMuxPacketKeyMessageType,
            bundleName, @"ProgName",
            bundleVersion, @"ClientVersionString",
            bundleIdentifier, @"BundleID",
            [NSNumber numberWithInt:3], @"kLibUSBMuxVersion",
            nil
        ];
    } else {
        packet = [NSDictionary dictionaryWithObjectsAndKeys:messageType, USBMuxPacketKeyMessageType, nil];
    }

    if (payload) {
        NSMutableDictionary *mpacket = [NSMutableDictionary dictionaryWithDictionary:payload];
        [mpacket addEntriesFromDictionary:packet];
        packet = mpacket;
    }

    return packet;
}

- (id)init {
    if (!(self = [super init]))
        return nil;

    return self;
}


- (void)dealloc {
    if (channel_) {
        channel_ = nil;
    }
}


- (BOOL)valid {
    return !!channel_;
}


- (dispatch_io_t)dispatchChannel {
    return channel_;
}

- (dispatch_fd_t)fileDescriptor {
    return dispatch_io_get_descriptor(channel_);
}


- (BOOL)openOnQueue:(dispatch_queue_t)queue error:(NSError**)error onEnd:(void(^)(NSError*))onEnd {
    assert(queue != nil);
    assert(channel_ == nil);

    queue_ = queue;

    /// Create socket
    dispatch_fd_t fd = socket(AF_UNIX, SOCK_STREAM, 0);

    if (fd == -1) {
        if (error)
            *error = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];

        return NO;
    }

    /// Prevent SIGPIPE
    int on = 1;
    setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &on, sizeof(on));

    /// Connect socket
    struct sockaddr_un addr;
    addr.sun_family = AF_UNIX;

    strcpy(addr.sun_path, "/private/var/run/usbmuxd");

    if (connect(fd, (struct sockaddr*)&addr, sizeof(addr)) == -1) {
        if (error)
            *error = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];

        close(fd);

        return NO;
    }

    channel_ = dispatch_io_create(DISPATCH_IO_STREAM, fd, queue_, ^(int error) {
        close(fd);

        if (onEnd) {
            onEnd(error == 0 ? nil : [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:error userInfo:nil]);
        }
    });

    return YES;
}

- (void)listenWithBroadcastHandler:(void(^)(NSDictionary *packet))broadcastHandler callback:(void(^)(NSError*))callback {
    autoReadPackets_ = YES;
    [self scheduleReadPacketWithBroadcastHandler:broadcastHandler];

    NSDictionary *packet = [USBMuxChannel packetDictionaryWithPacketType:@"Listen" payload:nil];

    [self sendRequest:packet callback:^(NSError *error, NSDictionary *responsePacket) {
        if (!callback)
            return;

        callback(error);
    }];
}

- (uint32_t)nextPacketTag {
    return ++nextPacketTag_;
}

- (void)sendRequest:(NSDictionary*)packet callback:(void(^)(NSError*, NSDictionary*))callback {
    uint32_t tag = [self nextPacketTag];

    [self sendPacket:packet tag:tag callback:^(NSError *error) {
        if (error) {
            callback(error, nil);
            return;
        }

        // TODO: timeout un-triggered callbacks in responseQueue_
        if (!self->responseQueue_) self->responseQueue_ = [NSMutableDictionary new];
            [self->responseQueue_ setObject:callback forKey:[NSNumber numberWithUnsignedInt:tag]];
    }];

    // We are awaiting a response
    [self setNeedsReadingPacket];
}


- (void)setNeedsReadingPacket {
    if (!isReadingPackets_) {
        [self scheduleReadPacketWithBroadcastHandler:nil];
    }
}

- (void)scheduleReadPacketWithBroadcastHandler:(void(^)(NSDictionary *packet))broadcastHandler {
    assert(isReadingPackets_ == NO);

    [self scheduleReadPacketWithCallback:^(NSError *error, NSDictionary *packet, uint32_t packetTag) {
        // Interpret the package we just received
        if (packetTag == 0) {
            // Broadcast message
            if (broadcastHandler)
                broadcastHandler(packet);
        } else if (self->responseQueue_) {
            // Reply
            NSNumber *key = [NSNumber numberWithUnsignedInt:packetTag];

            void(^requestCallback)(NSError*,NSDictionary*) = [self->responseQueue_ objectForKey:key];
            if (requestCallback) {
                [self->responseQueue_ removeObjectForKey:key];
                requestCallback(error, packet);
            } else {
                NSLog(@"Warning: Ignoring reply packet for which there is no registered callback. Packet => %@", packet);
            }
        }

        // Schedule reading another incoming package
        if (self->autoReadPackets_) {
            [self scheduleReadPacketWithBroadcastHandler:broadcastHandler];
        }
  }];
}

- (void)scheduleReadPacketWithCallback:(void(^)(NSError*, NSDictionary*, uint32_t))callback {
    static usbmux_packet_t ref_upacket;
    isReadingPackets_ = YES;

    // Read the first `sizeof(ref_upacket.size)` bytes off the channel_
    dispatch_io_read(channel_, 0, sizeof(ref_upacket.size), queue_, ^(bool done, dispatch_data_t data, int error) {
        if (!done)
            return;

        if (error) {
            self->isReadingPackets_ = NO;
            callback([[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:error userInfo:nil], nil, 0);
            return;
        }

        // Read size of incoming usbmux_packet_t
        uint32_t upacket_len = 0;
        char *buffer = NULL;
        size_t buffer_size = 0;
        PT_PRECISE_LIFETIME_UNUSED dispatch_data_t map_data = dispatch_data_create_map(data, (const void **)&buffer, &buffer_size); // objc_precise_lifetime guarantees 'map_data' isn't released before memcpy has a chance to do its thing
        memcpy((void *)&(upacket_len), (const void *)buffer, buffer_size);

        /*
         * This change addresses the crash that's been plaguing PT for quite some time now. The infamous issue supposedly closed here: https://github.com/rsms/peertalk/issues/34
         * I was able to reproduce this fairly regularly after allowing an iPhone not running PeerTalk to connect to a macOS client listening for devices and then disconnecting it repeatedly.
         * The main issue was the assertion that run-time value of buffer_size necessarily equals the compile-time constant UINT32_MAX (which was, explicitly stated, sizeof(ref_upacket.size)).
         * When buffer_size was zero, this assertion failed and crashed the application, yet there was no real *problem* with buffer_size being zero. It makes more sense to recover gracefully in this case.
         */
        if (buffer_size == 0 && done) {
            // If buffer_size is zero, no data was sent in the `data` param of this dispatch_io block; if done is true, maybe we just return?
            if (callback)
                callback(nil, nil, 0);

            return;
        }

        // Allocate a new usbmux_packet_t for the expected size
        uint32_t payloadLength = upacket_len - (uint32_t)sizeof(usbmux_packet_t);
        usbmux_packet_t *upacket = usbmux_packet_alloc(payloadLength);

        // Read rest of the incoming usbmux_packet_t
        off_t offset = sizeof(ref_upacket.size);
        dispatch_io_read(self->channel_, offset, upacket->size - offset, self->queue_, ^(bool done, dispatch_data_t data, int error) {
            if (!done) {
                return;
            }

            self->isReadingPackets_ = NO;

            if (error) {
                callback([[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:error userInfo:nil], nil, 0);
                usbmux_packet_free(upacket);
                return;
            }

            if (upacket_len > kUSBMuxPacketMaxPayloadSize) {
                callback([[NSError alloc] initWithDomain:USBMuxErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey:@"Received a packet that is too large"}], nil, 0);
                usbmux_packet_free(upacket);
                return;
            }

            // Copy read bytes onto our usbmux_packet_t
            char *buffer = NULL;
            size_t buffer_size = 0;
            PT_PRECISE_LIFETIME_UNUSED dispatch_data_t map_data = dispatch_data_create_map(data, (const void **)&buffer, &buffer_size);
            assert(buffer_size == upacket->size - offset);
            memcpy(((void *)(upacket))+offset, (const void *)buffer, buffer_size);

            // We only support plist protocol
            if (upacket->protocol != USBMuxPacketProtocolPlist) {
                callback([[NSError alloc] initWithDomain:USBMuxErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:@"Unexpected package protocol" forKey:NSLocalizedDescriptionKey]], nil, upacket->tag);
                usbmux_packet_free(upacket);
                return;
            }

            // Only one type of packet in the plist protocol
            if (upacket->type != USBMuxPacketTypePlistPayload) {
                callback([[NSError alloc] initWithDomain:USBMuxErrorDomain code:0 userInfo:[NSDictionary dictionaryWithObject:@"Unexpected package type" forKey:NSLocalizedDescriptionKey]], nil, upacket->tag);
                usbmux_packet_free(upacket);
                return;
            }

            // Try to decode any payload as plist
            NSError *err = nil;
            NSDictionary *dict = nil;
            if (usbmux_packet_payload_size(upacket)) {
                dict = [NSPropertyListSerialization propertyListWithData:[NSData dataWithBytesNoCopy:usbmux_packet_payload(upacket) length:usbmux_packet_payload_size(upacket) freeWhenDone:NO] options:NSPropertyListImmutable format:NULL error:&err];
            }

            // Invoke callback
            callback(err, dict, upacket->tag);
            usbmux_packet_free(upacket);
        });
    });
}

- (void)sendDispatchData:(dispatch_data_t)data callback:(void(^)(NSError*))callback {
    off_t offset = 0;

    dispatch_io_write(channel_, offset, data, queue_, ^(bool done, dispatch_data_t data, int _errno) {
        //NSLog(@"dispatch_io_write: done=%d data=%p error=%d", done, data, error);
        if (!done)
            return;

        if (callback) {
            NSError *err = nil;

            if (_errno)
                err = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:_errno userInfo:nil];

            callback(err);
        }
    });
}

- (void)sendPacketOfType:(USBMuxPacketType)type
            overProtocol:(USBMuxPacketProtocol)protocol
                     tag:(uint32_t)tag
                 payload:(NSData*)payload
                callback:(void(^)(NSError*))callback
{
    assert(payload.length <= kUSBMuxPacketMaxPayloadSize);

    usbmux_packet_t *packet = usbmux_packet_create(
        protocol,
        type,
        tag,
        payload ? payload.bytes : nil,
        (uint32_t)(payload ? payload.length : 0)
    );

    dispatch_data_t data = dispatch_data_create((const void*)packet, packet->size, queue_, ^{
        // Free packet when data is freed
        usbmux_packet_free(packet);
    });

    [self sendDispatchData:data callback:callback];
}

- (void)sendPacket:(NSDictionary*)packet tag:(uint32_t)tag callback:(void(^)(NSError*))callback {
    NSError *error = nil;
    // NSPropertyListBinaryFormat_v1_0
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:packet format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];

    if (!plistData) {
        callback(error);
    } else {
        [self sendPacketOfType:USBMuxPacketTypePlistPayload overProtocol:USBMuxPacketProtocolPlist tag:tag payload:plistData callback:callback];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-getter-return-value"

- (void)sendData:(NSData*)data callback:(void(^)(NSError*))callback {
    dispatch_data_t ddata = dispatch_data_create((const void*)data.bytes, data.length, queue_, ^{
        // trick to have the block capture and retain the data
        [data length];
    });

    [self sendDispatchData:ddata callback:callback];
}

#pragma clang diagnostic pop

- (void)readFromOffset:(off_t)offset length:(size_t)length callback:(void(^)(NSError *error, dispatch_data_t data))callback {
    dispatch_io_read(channel_, offset, length, queue_, ^(bool done, dispatch_data_t data, int _errno) {
        if (!done)
            return;

        NSError *error = nil;
        if (_errno != 0) {
            error = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain code:_errno userInfo:nil];
        }

        callback(error, data);
    });
}

- (void)cancel {
    if (channel_) {
        dispatch_io_close(channel_, 0);
    }
}


- (void)stop {
    if (channel_) {
        dispatch_io_close(channel_, DISPATCH_IO_STOP);
    }
}

@end
