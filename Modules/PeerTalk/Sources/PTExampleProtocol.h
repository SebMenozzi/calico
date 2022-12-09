#import <Foundation/Foundation.h>
#include <stdint.h>

static const NSTimeInterval PTAppReconnectDelay = 1.0;
static const NSTimeInterval PTPingDelay = 1.0;
static const int PTExampleProtocolIPv4PortNumber = 2345;

typedef enum : uint32_t {
    PTExampleFrameTypeUnknown = 100,
    PTExampleFrameTypeDeviceInfo = 101,
    PTExampleFrameTypeTextMessage = 102,
    PTExampleFrameTypePing = 103,
    PTExampleFrameTypePong = 104,
} PTExampleFrameType;

typedef struct _PTExampleTextFrame {
    uint32_t length;
    uint8_t utf8text[0];
} PTExampleTextFrame;

static NSData *PTExampleTextCreateMessagePayload(NSString *message) {
    const char *utf8text = [message cStringUsingEncoding:NSUTF8StringEncoding];

    size_t length = strlen(utf8text);
    PTExampleTextFrame *textFrame = CFAllocatorAllocate(nil, sizeof(PTExampleTextFrame) + length, 0);
    memcpy(textFrame->utf8text, utf8text, length); // Copy bytes to utf8text array

    textFrame->length = htonl(length); // Convert integer to network byte order
  
    // Wrap the textFrame in a dispatch data object
    return (NSData *) dispatch_data_create((const void*)textFrame, sizeof(PTExampleTextFrame)+length, nil, ^{
        CFAllocatorDeallocate(nil, textFrame);
    });
}

static NSString *PTExampleTextRetrieveMessageFromPayload(NSData* payload) {
    PTExampleTextFrame *textFrame = (PTExampleTextFrame*)payload.bytes;
    textFrame->length = ntohl(textFrame->length);

    NSString *message = [[NSString alloc] initWithBytes:textFrame->utf8text length:textFrame->length encoding:NSUTF8StringEncoding];

    return message;
}
