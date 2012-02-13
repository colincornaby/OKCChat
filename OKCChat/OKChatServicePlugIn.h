//
//  OKChatServicePlugIn.h
//  OKCChat
//
//  Created by Colin Cornaby on 6/12/11.

/* Copyright 2011 Colin Cornaby. All rights reserved.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * 
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

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
