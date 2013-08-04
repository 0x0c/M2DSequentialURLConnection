//
//  M2DURLConnection.h
//  NewsPacker
//
//  Created by Akira Matsuda on 2013/04/07.
//  Copyright (c) 2013年 Akira Matsuda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M2DURLConnection : NSURLConnection
{
	NSString *identifier_;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately identifier:(NSString *)identifier;

@property (nonatomic, readonly) NSString *identifier;

@end

@class M2DURLConnectionOperation;

@protocol M2DURLConnectionOperationDelegate <NSObject>

- (void)connectionOperationDidComplete:(M2DURLConnectionOperation *)operation connection:(M2DURLConnection *)connection;

@end

@interface M2DURLConnectionOperation : NSObject <NSURLConnectionDataDelegate>
{
	void (^completeBlock_)(NSURLConnection *connection, NSData *data, NSError *error);
	
	NSMutableData *data_;
	NSURLRequest *request_;
	M2DURLConnection *connection_;
}

@property M2DURLConnection *connection;
@property id delegate;

+ (void)globalStop:(NSString *)identifier;
- (id)initWithRequest:(NSURLRequest *)request;
- (id)initWithRequest:(NSURLRequest *)request completeBlock:(void (^)(M2DURLConnection *connection, NSData *data, NSError *error))completeBlock;
- (NSString *)sendRequest;
- (NSString *)sendRequestWithCompleteBlock:(void (^)(M2DURLConnection *connection, NSData *data, NSError *error))completeBlock;
- (NSString *)sendRequest:(NSURLRequest *)request completeBlock:(void (^)(M2DURLConnection *connection, NSData *data, NSError *error))completeBlock;
- (NSString *)sendAsyncronousRequest:(NSURLRequest *)request completeBlock:(void (^)(M2DURLConnection *connection, NSData *data, NSError *error))completeBlock;

@end
