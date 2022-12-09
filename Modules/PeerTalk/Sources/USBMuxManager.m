#import "USBMuxManager.h"

#import "USBMuxChannel.h"

@implementation USBMuxManager

static USBMuxManager *manager;
static dispatch_once_t onceToken;

+ (instancetype) shared {
    dispatch_once(&onceToken, ^{
        manager = [USBMuxManager new];

        [manager listenOnQueue:dispatch_get_main_queue() onStart:^(NSError *error) {
            if (error) {
                NSLog(@"USBMuxManager failed to initialize: %@", error);
            }
        } onEnd:nil];
    });

    return manager;
}

- (id)init {
    if (!(self = [super init]))
        return nil;

    return self;
}

- (void)listenOnQueue:(dispatch_queue_t)queue
              onStart:(void(^)(NSError*))onStart
                onEnd:(void(^)(NSError*))onEnd {

    if (channel_) {
        if (onStart) onStart(nil);
        return;
    }

    channel_ = [USBMuxChannel new];
    NSError *error = nil;

    if ([channel_ openOnQueue:queue error:&error onEnd:onEnd]) {
        [channel_ listenWithBroadcastHandler:^(NSDictionary *packet) {
            [self handleBroadcastPacket:packet];
        } callback:onStart];
    } else if (onStart) {
        onStart(error);
    }
}

- (void)connectToDevice:(NSNumber*)deviceID
                   port:(int)port
                onStart:(void(^)(NSError*, dispatch_io_t))onStart
                  onEnd:(void(^)(NSError*))onEnd {
    USBMuxChannel *channel = [USBMuxChannel new];
    NSError *error = nil;

    if (![channel openOnQueue:dispatch_get_main_queue() error:&error onEnd:onEnd]) {
        onStart(error, nil);
        return;
    }

    port = ((port<<8) & 0xFF00) | (port>>8); // limit

    NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:
                             deviceID, USBMuxPacketKeyDeviceID,
                             [NSNumber numberWithInt:port], @"PortNumber",
                             nil];

    NSDictionary *packet = [USBMuxChannel packetDictionaryWithPacketType:@"Connect"
                                                                 payload:payload];

    [channel sendRequest:packet callback:^(NSError *error_, NSDictionary *responsePacket) {
        onStart(error, (error ? nil : channel.dispatchChannel) );
    }];
}


- (void)handleBroadcastPacket:(NSDictionary*)packet {
    NSLog(@"Packet: %@", packet);

    NSString *messageType = [packet objectForKey:USBMuxPacketKeyMessageType];

    if ([@"Attached" isEqualToString:messageType]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PTUSBDeviceDidAttachNotification object:self userInfo:packet];
    } else if ([@"Detached" isEqualToString:messageType]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PTUSBDeviceDidDetachNotification object:self userInfo:packet];
    } else {
        NSLog(@"Warning: Unhandled broadcast message: %@", packet);
    }
}

@end
