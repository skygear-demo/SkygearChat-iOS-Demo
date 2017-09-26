#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SKYChatRecord.h"
#import "SKYConversation.h"
#import "SKYMessage.h"
#import "SKYUserChannel.h"
#import "SKYChatExtension.h"
#import "SKYChatExtension_Private.h"
#import "SKYChatReceipt.h"
#import "SKYChatRecordChange.h"
#import "SKYChatRecordChange_Private.h"
#import "SKYChatTypingIndicator.h"
#import "SKYChatTypingIndicator_Private.h"
#import "SKYContainer+Chat.h"
#import "SKYKitChat.h"

FOUNDATION_EXPORT double SKYKitChatVersionNumber;
FOUNDATION_EXPORT const unsigned char SKYKitChatVersionString[];

