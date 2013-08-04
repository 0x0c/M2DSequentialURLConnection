//
//  M2DURLConnection.m
//  NewsPacker
//
//  Created by Akira Matsuda on 2013/04/07.
//  Copyright (c) 2013年 Akira Matsuda. All rights reserved.
//

#import "M2DURLConnectionOperation.h"

static dispatch_queue_t globalConnectionQueue;

@implementation M2DURLConnection

@synthesize identifier = identifier_;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately identifier:(NSString *)identifier
{
	self = [super initWithRequest:request delegate:delegate startImmediately:startImmediately];
	if (self) {
		identifier_ = [identifier copy];
	}
	
	return self;
}

- (void)cancel
{
	[super cancel];
}

@end

@implementation M2DURLConnectionOperation

@synthesize connection = connection_;

+ (void)globalStop:(NSString *)identifier
{
	NSNotification *n = [NSNotification notificationWithName:identifier object:self userInfo:nil];
	[[NSNotificationCenter defaultCenter] postNotification:n];
}

+ (dispatch_queue_t)globalConnectionQueue
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		globalConnectionQueue = dispatch_queue_create("M2DURLConnectionOperationGlobalConnectionQueue", NULL);
	});
	
	return globalConnectionQueue;
}

- (id)initWithRequest:(NSURLRequest *)request
{
	self = [super init];
	if (self) {
		request_ = [request copy];
	}
	
	return self;
}

- (id)initWithRequest:(NSURLRequest *)request completeBlock:(void (^)(M2DURLConnection *connection, NSData *data, NSError *error))completeBlock
{
	self = [self initWithRequest:request];
	if (self) {
		completeBlock_ = [completeBlock copy];
	}
	
	return self;
}

- (NSString *)sendRequest
{
	NSString *identifier = [[NSProcessInfo processInfo] globallyUniqueString];

	connection_ = [[M2DURLConnection alloc] initWithRequest:request_ delegate:self startImmediately:NO identifier:identifier];
	[[NSNotificationCenter defaultCenter] addObserver:connection_ selector:@selector(cancel) name:identifier object:nil];
	[connection_ start];
	
	return identifier;
}

- (NSString *)sendRequestWithCompleteBlock:(void (^)(M2DURLConnection *connection, NSData *data, NSError *error))completeBlock
{
	NSString *identifier = [[NSProcessInfo processInfo] globallyUniqueString];
	
	completeBlock_ = [completeBlock copy];
	connection_ = [[M2DURLConnection alloc] initWithRequest:request_ delegate:self startImmediately:NO identifier:identifier];
	[[NSNotificationCenter defaultCenter] addObserver:connection_ selector:@selector(cancel) name:identifier object:nil];
	[connection_ start];
	
	return identifier;
}

- (NSString *)sendRequest:(NSURLRequest *)request completeBlock:(void (^)(M2DURLConnection *connection, NSData *data, NSError *error))completeBlock
{
	NSString *identifier = [[NSProcessInfo processInfo] globallyUniqueString];
	
	completeBlock_ = [completeBlock copy];
	connection_ = [[M2DURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO identifier:identifier];
	[[NSNotificationCenter defaultCenter] addObserver:connection_ selector:@selector(cancel) name:identifier object:nil];
	[connection_ start];
	
	return identifier;
}

- (NSString *)sendAsyncronousRequest:(NSURLRequest *)request completeBlock:(void (^)(M2DURLConnection *connection, NSData *data, NSError *error))completeBlock
{
	NSString *identifier = [[NSProcessInfo processInfo] globallyUniqueString];
	
	completeBlock_ = [completeBlock copy];
	connection_ = [[M2DURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO identifier:identifier];
	[[NSNotificationCenter defaultCenter] addObserver:connection_ selector:@selector(cancel) name:identifier object:nil];
	dispatch_async(dispatch_get_main_queue(), ^{
		[connection_ start];
	});
		
	return identifier;
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[data_ appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	data_ = [[NSMutableData alloc] init];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	completeBlock_(connection, data_, nil);
	if ([self.delegate respondsToSelector:@selector(connectionOperationDidComplete:connection:)]) {
		[self.delegate connectionOperationDidComplete:self connection:(M2DURLConnection *)connection];
	}
	[self finish:(M2DURLConnection *)connection];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	completeBlock_(connection, nil, error);
	[self finish:(M2DURLConnection *)connection];
}

- (void)finish:(M2DURLConnection *)connection
{
	[[NSNotificationCenter defaultCenter] removeObserver:connection name:connection.identifier object:nil];
}

@end