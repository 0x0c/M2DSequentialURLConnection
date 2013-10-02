//
//  M2DSequentialURLConnection.h
//  DecoChat
//
//  Created by Akira Matsuda on 2013/06/21.
//  Copyright (c) 2013年 Primeagain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M2DURLConnectionOperation.h"

#define M2DSequentialURLConnectionOperation @"operation"
#define M2DSequentialURLConnectionAutoStart @"autoStart"

@protocol M2DSequentialURLConnectionDelegate <NSObject>

- (void)sequentiaoURLConnectionDidDequeue:(NSDictionary *)operationInfo;

@end

@interface M2DSequentialURLConnection : NSObject<M2DURLConnectionOperationDelegate>
{
	NSString *currentConnectionIdentifier_;
	NSMutableArray *queue_;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, readonly) NSMutableArray *queue;

+ (M2DSequentialURLConnection *)sharedQueue;
- (void)addOperation:(M2DURLConnectionOperation *)operation autoStart:(BOOL)autoStart;
- (void)dequeue;

@end
