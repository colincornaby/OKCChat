//
//  OKChatService.m
//  OKCChat
//
//  Created by Colin Cornaby on 6/12/11.
//  Copyright 2011 Consonance Software. All rights reserved.
//

#import "OKChatService.h"

@implementation OKChatService

@synthesize username = m_username, password = m_password, delegate = m_delegate;

- (id)initWithDelegate:(id <OKChatServiceDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        buffers = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)post:(NSString *)post toService:(NSString *)service
{
    m_error = nil;
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.okcupid.com/%@", service]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod: @"POST"];
    [request addValue:@"1" forHTTPHeaderField:@"X-OkCupid-Api-Version"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[post dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [buffers setObject:[NSMutableData data] forKey:[NSValue valueWithNonretainedObject:connection]];
    [connection start];
}



- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSURLCredential *credential = [NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceForSession];
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [[buffers objectForKey:[NSValue valueWithNonretainedObject:connection]] appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
        
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSData *data = [[[buffers objectForKey:[NSValue valueWithNonretainedObject:connection]] retain] autorelease];
    [buffers removeObjectForKey:[NSValue valueWithNonretainedObject:connection]];
    [self.delegate okcChatServiceDidReceiveData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    m_error = [error retain];
}

@end
