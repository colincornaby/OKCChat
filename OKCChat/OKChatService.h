//
//  OKChatService.h
//  OKCChat
//
//  Created by Colin Cornaby on 6/12/11.
//  Copyright 2011 Consonance Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IMServicePlugIn/IMServicePlugIn.h>

@interface OKChatService : NSObject
{
    NSString *m_username;
    NSString *m_password;
    NSError     *m_error;
    id          m_delegate;
    NSMutableDictionary *buffers;
}

@property (assign) id       delegate;
@property (copy) NSString * username;
@property (copy) NSString * password;

- (void)post:(NSString *)post toService:(NSString *)service;
- (id)initWithDelegate:(id)delegate;

@end
