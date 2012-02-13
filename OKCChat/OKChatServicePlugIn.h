//
//  OKChatServicePlugIn.h
//  OKCChat
//
//  Created by Colin Cornaby on 6/12/11.
//  Copyright 2011 Consonance Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IMServicePlugIn/IMServicePlugIn.h>
#import "OKChatService.h"

@interface OKChatServicePlugIn : NSObject <IMServicePlugIn, IMServicePlugInGroupListSupport, IMServicePlugInInstantMessagingSupport, OKChatServiceDelegate>
{
    id<
        IMServiceApplication,
        IMServiceApplicationGroupListSupport,
        IMServiceApplicationInstantMessagingSupport
    > m_serviceApplication;
    NSDictionary *m_accountSettings;
    NSURLConnection *m_connection;
    OKChatService *m_service;
    NSString *m_rid;
    int seqid;
    int gmt;
    NSTimer *m_newMessageTimer;
    BOOL gettingMessages;
    NSDictionary *m_groupListProperties;
};
@property (copy) NSDictionary *accountSettings;
@property (copy, atomic) NSDictionary *groupListProperties;

-(BOOL)valueHasChangedForUser:(NSString *)username valueKey:(NSString *)key newValue:(id)newValue;

@end
