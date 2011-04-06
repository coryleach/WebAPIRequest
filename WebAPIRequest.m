//
//  WebAPIRequest.m
//  NekoLogic
//
//  Created by Cory on 10/09/17.
//  Copyright 2010 Cory R. Leach. All rights reserved.
//

#import "WebAPIRequest.h"

@implementation WebAPIRequest

@synthesize baseURL;
@synthesize active;
@synthesize delegate;

- (id) initWithBaseURL:(NSString*)aURLString {

	if ( (self = [super init]) ) {
		
		baseURL = [[NSURL alloc] initWithString:aURLString];
		properties = [[NSMutableDictionary alloc] init];
		
		result = [[NSMutableData alloc] initWithCapacity:1024];
	
		connection = nil;
		
		active = NO;
		
		delegate = nil;
		
	}
	
	return self;
	
}

- (void) dealloc {
		
	[baseURL release];
	baseURL = nil;
	
	[properties release];
	properties = nil;
	
	[connection release];
	connection = nil;
	
	[result release];
	result = nil;
	
	[super dealloc];
	
}

- (void) setValue:(NSString*)value forProperty:(NSString*)property {
	
	@synchronized(properties) {
	
		if ( value == nil ) {
			[properties removeObjectForKey:property];
			return;
		}
	
		[properties setObject:value forKey:property];
	
	}
	
}

- (NSString*) valueForProperty:(NSString*)property {

	NSString* string = nil;
	@synchronized(properties) {

		string = [properties objectForKey:property];
	
	}
	
	return string;
	
}

- (NSData*) result {
	return result;
}

- (void) send {
	
	//Build proper URL request
	NSString* urlString = [baseURL absoluteString];
	
	NSString* propertyString = @"";
	
	@synchronized(properties) {
	
		for ( NSString* key in properties ) {
			
			NSString* value = [properties objectForKey:key];
			value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			
			if ( propertyString.length <= 0 ) {
				propertyString = [propertyString stringByAppendingFormat:@"?%@=%@",key,value];
			} else {
				propertyString = [propertyString stringByAppendingFormat:@"&%@=%@",key,value];
			}
			
		}
		
	}
		
	NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",urlString,propertyString]];
		
	NSURLRequest* request = [NSURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
	
	if ( connection != nil ) {
		[connection release];
		connection = nil;
	}
	
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	[result setLength:0];
	active = YES;
	
	[connection start];
	
}

- (void) cancel {
	
	[connection cancel];
	active = NO;
	
}

#pragma mark NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data {
		
	//Append Recieved Data to result
	[result appendData:data];
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
	
	active = NO;
	//NSLog(@"Finished Result Size: %d",result.length);

	[delegate request:self didFinishWithResult:result];
		
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
	
	active = NO;

	//Notify Delegate of Failure
	[delegate request:self didFailWithError:error];
	
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)aConnection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	return nil;
}

@end
