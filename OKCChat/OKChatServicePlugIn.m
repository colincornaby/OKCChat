//
//  OKChatServicePlugIn.m
//  OKCChat
//
//  Created by Colin Cornaby on 6/12/11.
//  Copyright 2011 Consonance Software. All rights reserved.
//

#import "OKChatServicePlugIn.h"

@implementation OKChatServicePlugIn

@synthesize accountSettings = m_accountSettings;
@synthesize groupListProperties = m_groupListProperties;

- (id) initWithServiceApplication:(id<IMServiceApplication>)serviceApplication
{
    self = [super init];
    if (self) {
        m_serviceApplication = (id<IMServiceApplication, IMServiceApplicationGroupListSupport, IMServiceApplicationInstantMessagingSupport>) [serviceApplication retain];
        m_service = [[OKChatService alloc] initWithDelegate:self];
    }
    return self;
}


- (oneway void) updateAccountSettings:(NSDictionary *)accountSettings
{
    NSLog(@"%@", [accountSettings description]);
    self.accountSettings = [accountSettings copy];
}


- (oneway void) login
{
    NSString *postString = [NSString stringWithFormat:@"username=%@&password=%@", [m_accountSettings valueForKey:IMAccountSettingLoginHandle], [m_accountSettings valueForKey:IMAccountSettingPassword], nil];
    
    [m_service post:postString toService:@"login"];
}

-(void)getMessages
{
    NSString *postString = [NSString stringWithFormat:@"rand=0.%u&server_seqid=%u&server_gmt=%u&load_thumbnails=1&do_event_poll=1&buddylist=1&show_offline=1&num_unread=1&im_status=1&do_post_read=1", rand(), seqid, gmt, nil];
    [m_service post:postString toService:@"instantevents"];
    gettingMessages=NO;
}

- (oneway void) logout
{
    
    [m_service post:@"" toService:@"logout"];
}

-(void)dealloc
{
    [m_serviceApplication release];
    [super dealloc];
}

NSString *CreateEscapedString(NSString *inString);

NSString *CreateEscapedString(NSString *inString)
{
    static CFStringRef sUnescape = NULL;
    static CFStringRef sForceEscape = CFSTR("&=:/+%");
    return CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)inString, sUnescape, sForceEscape, kCFStringEncodingUTF8);
}

- (oneway void) requestGroupList
{
}

- (oneway void) userDidStartTypingToHandle:(NSString *)handle
{
    
}


- (oneway void) userDidStopTypingToHandle:(NSString *)handle
{
    
}


- (oneway void) sendMessage:(IMServicePlugInMessage *)message toHandle:(NSString *)handle
{
    NSString * body = [CreateEscapedString([message.content string]) autorelease];
    NSString *postString = [NSString stringWithFormat:@"send=1&attempt=1&rid=%d&recipient=%@&topic=false&body=%@", rand(), handle, body, nil];
    [m_service post:postString toService:@"instantevents"];
    [m_serviceApplication plugInDidSendMessage:message toHandle:handle error:nil];
}

-(void)okcChatServiceDidReceiveData:(NSData *)data
{
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"%@", [response description]);
    if([response objectForKey:@"events"]&&gmt)
    {
        for(NSDictionary *event in [response objectForKey:@"events"])
        {
            if([[event objectForKey:@"type"] isEqualToString:@"im"]&&[event objectForKey:@"from"])
            {
                IMServicePlugInMessage *message = [IMServicePlugInMessage servicePlugInMessageWithContent:
                                                   [[[NSAttributedString alloc] initWithString:[event objectForKey:@"contents"]] autorelease]];
                [m_serviceApplication plugInDidReceiveMessage:message fromHandle:[event objectForKey:@"from"]];
                seqid = [[response objectForKey:@"server_seqid"] intValue];
            }
        }
        [self performSelector:@selector(getMessages) withObject:nil afterDelay:0.5];
    }else if([response objectForKey:@"userid"])
    {
        m_rid = [response objectForKey:@"userid"];
        [m_serviceApplication plugInDidLogIn];
        
        NSString * postString = [NSString stringWithFormat:@"rand=0.%u&load_thumbnails=0&do_event_poll=0&buddylist=0&show_offline=0&num_unread=0", rand(), nil];
        [m_service post:postString toService:@"instantevents"];
    }
    
    
    if([[response objectForKey:@"server_gmt"] intValue]!=0)
    {
        if(!gmt&&!gettingMessages)
        {
            gettingMessages=YES;
            [self performSelector:@selector(getMessages) withObject:nil afterDelay:0.1];
        }
        gmt = [[response objectForKey:@"server_gmt"] intValue];
    }
    if([response objectForKey:@"people"])
    {
        NSArray *people = [response objectForKey:@"people"];
        NSMutableArray *buddyNames = [NSMutableArray array];
        NSMutableDictionary *newGroupListProperties = [NSMutableDictionary dictionary];
        for(NSDictionary *person in people)
        {
            [buddyNames addObject:[person objectForKey:@"screenname"]];
            [newGroupListProperties setObject:person forKey:[person objectForKey:@"screenname"]];
        }
        
        NSDictionary *groupDictionary = [NSDictionary dictionaryWithObjects:
            [NSArray arrayWithObjects:IMGroupListDefaultGroup, [NSNumber numberWithInt:IMGroupListCanReorderGroup], buddyNames, nil] forKeys:[NSArray arrayWithObjects:IMGroupListNameKey, IMGroupListPermissionsKey, IMGroupListHandlesKey, nil]];
        [m_serviceApplication plugInDidUpdateGroupList:[NSArray arrayWithObject:groupDictionary] error:nil];
        
        for(NSDictionary *person in people)
        {
            NSMutableDictionary *updatedKeys = [NSMutableDictionary dictionary];
            NSString *userName = [person objectForKey:@"screenname"];
            if([self valueHasChangedForUser:userName valueKey:@"is_online" newValue:[person objectForKey:@"is_online"]])
            {
                IMHandleAvailability available = IMHandleAvailabilityOffline;
                if([[person objectForKey:@"is_online"] boolValue])
                    available = IMHandleAvailabilityAvailable;
                [updatedKeys setObject:[NSNumber numberWithLong:available] forKey:IMHandlePropertyAvailability];
            }
            if([self valueHasChangedForUser:userName valueKey:@"thumbnail" newValue:[person objectForKey:@"thumbnail"]])
            {
                [updatedKeys setObject:[person objectForKey:@"thumbnail"] forKey:IMHandlePropertyPictureIdentifier];
            }
            [m_serviceApplication plugInDidUpdateProperties:updatedKeys ofHandle:[person objectForKey:@"screenname"]];
        }
    }
}

-(BOOL)valueHasChangedForUser:(NSString *)username valueKey:(NSString *)key newValue:(id)newValue
{
    if(!self.groupListProperties)
        return YES;
    NSDictionary *user = [self.groupListProperties objectForKey:username];
    if(!user)
        return YES;
    if([[user objectForKey:key] isEqual:newValue])
        return YES;
    return NO;
}

- (oneway void) requestPictureForHandle:(NSString *)handle withIdentifier:(NSString *)identifier
{
    
    [m_serviceApplication plugInDidUpdateProperties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     [NSData dataWithContentsOfURL:[NSURL URLWithString:identifier]], IMHandlePropertyPictureData,
                                                     identifier ,IMHandlePropertyPictureIdentifier,
                                                     nil] ofHandle:handle];
}

@end
