//
//  OKChatService.m
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
