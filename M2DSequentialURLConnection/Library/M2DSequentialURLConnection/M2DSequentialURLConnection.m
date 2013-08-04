//
//  M2DSequentialURLConnection.m
//  DecoChat
//
//  Created by Akira Matsuda on 2013/06/21.
//  Copyright (c) 2013年 Primeagain. All rights reserved.
//

#import "M2DSequentialURLConnection.h"

@implementation M2DSequentialURLConnection

@synthesize queue = queue_;

M2DSequentialURLConnection *sharedQueue;

+ (M2DSequentialURLConnection *)sharedQueue
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedQueue = [[M2DSequentialURLConnection alloc] init];
	});
	
	return sharedQueue;
}

- (id)init
{
	self = [super init];
	if (self) {
		queue_ = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)addOperation:(M2DURLConnectionOperation *)operation autoStart:(BOOL)autoStart
{
	operation.delegate = self;
	[queue_ addObject:@{
	 M2DSequentialURLConnectionOperation : operation,
	 M2DSequentialURLConnectionAutoStart : [NSNumber numberWithBool:autoStart]
	 }];
	if (autoStart && [queue_ count] == 1) {
		[self dequeue];
	}
}

- (void)dequeue
{
	if (queue_.count) {
		NSDictionary *dict = queue_[0];
		M2DURLConnectionOperation *operation = dict[M2DSequentialURLConnectionOperation];
		currentConnectionIdentifier_ = [operation sendRequest];
		
		if ([self.delegate respondsToSelector:@selector(sequentiaoURLConnectionDidDequeued:)]) {
			[self.delegate sequentiaoURLConnectionDidDequeued:dict];
		}
	}
}

#pragma - M2DURLConnectionOperationDelegate

- (void)connectionOperationDidComplete:(M2DURLConnectionOperation *)operation connection:(M2DURLConnection *)connection
{
	if (queue_.count) {
		[queue_ removeObjectAtIndex:0];
	}
	NSDictionary *dict = queue_.lastObject;
	if ([dict[M2DSequentialURLConnectionAutoStart] boolValue]) {
		[self dequeue];
	}
}

@end
