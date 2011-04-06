//
//  WebAPIRequest.h
//  NekoLogic
//
//  Created by Cory on 10/09/17.
//  Copyright 2010 Cory R. Leach. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WebAPIRequestDelegate;

@interface WebAPIRequest : NSObject {

	NSURLConnection* connection;
	NSURL* baseURL;
	NSMutableDictionary* properties;
	NSMutableData* result;
	BOOL active;
	
	id<WebAPIRequestDelegate> delegate;
	
}

@property (readonly) NSURL* baseURL;
@property (readonly) NSData* result;
@property (readonly) BOOL active;
@property (assign) id<WebAPIRequestDelegate> delegate;

- (id) initWithBaseURL:(NSString*)aURLString;

- (void) setValue:(NSString*)value forProperty:(NSString*)property;
- (NSString*) valueForProperty:(NSString*)property;

- (void) send;
- (void) cancel;

@end

@protocol WebAPIRequestDelegate

- (void)request:(WebAPIRequest*)apiRequest didFinishWithResult:(NSData*)aResult;
- (void)request:(WebAPIRequest*)apiRequest didFailWithError:(NSError *)error;

@end

