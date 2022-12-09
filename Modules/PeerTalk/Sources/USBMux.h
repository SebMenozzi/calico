#import <Foundation/Foundation.h>

typedef NSString * USBMuxPacketKey NS_TYPED_ENUM;
static const USBMuxPacketKey USBMuxPacketKeyDeviceID = @"DeviceID";
static const USBMuxPacketKey USBMuxPacketKeyMessageType = @"MessageType";
static const USBMuxPacketKey USBMuxPacketKeyProperties = @"Properties";

static const NSNotificationName PTUSBDeviceDidAttachNotification = @"PTUSBDeviceDidAttachNotification";
static const NSNotificationName PTUSBDeviceDidDetachNotification = @"PTUSBDeviceDidDetachNotification";
