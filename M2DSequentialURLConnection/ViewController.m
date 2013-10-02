//
//  ViewController.m
//  M2DSequentialURLConnection
//
//  Created by Akira Matsuda on 2013/08/04.
//  Copyright (c) 2013年 Akira Matsuda. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	M2DSequentialURLConnection *sharedQueue = [M2DSequentialURLConnection sharedQueue];
	sharedQueue.delegate = self;
	
	NSArray *array = @[@"http://www.apple.com", @"http://www.google.com", @"https://github.com"];
	for (NSString *url in array) {
		M2DURLConnectionOperation *operation = [[M2DURLConnectionOperation alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] completeBlock:^(M2DURLConnection *connection, NSData *data, NSError *error) {
			if (error) {
				NSLog(@"%@", error.localizedDescription);
			}
			NSLog(@"finished:%@", url);
		}];
		[sharedQueue addOperation:operation autoStart:YES];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark M2DSequentialURLConnectionDelegate

- (void)sequentiaoURLConnectionDidDequeue:(NSDictionary *)operationInfo
{
	M2DURLConnectionOperation *operation = operationInfo[M2DSequentialURLConnectionOperation];
	NSLog(@"%@(auto start:%d)", operation.connection.identifier, [operationInfo[M2DSequentialURLConnectionAutoStart] boolValue]);
}

@end
