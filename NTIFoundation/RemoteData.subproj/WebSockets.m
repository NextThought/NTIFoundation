
//
//  WebSockets.m
//  NTIFoundation
//
//  Created by Christopher Utz on 9/19/11.
//  Copyright 2011 NextThought. All rights reserved.
//

#import "WebSockets.h"
#import <CommonCrypto/CommonDigest.h>
#import "OmniFoundation/NSDictionary-OFExtensions.h"
#import "OmniFoundation/NSMutableDictionary-OFExtensions.h"

@implementation WebSocketData
@synthesize data, text;

-(id)initWithData:(NSData *)d isText:(BOOL)t
{
	self = [super init];
	self->data = [d retain];
	self->text = t;
	return self;
}

-(void)dealloc
{
	NTI_RELEASE(self->data);
}

@end

@implementation WebSocket7
@synthesize status, nr_delegate;

static NSString* b64EncodeString(NSString* string)
{
	return [[string dataUsingEncoding: NSUTF8StringEncoding] base64String];
}

static NSError* errorWithCodeAndMessage(NSInteger code, NSString* message)
{
	NSDictionary* userData = [NSDictionary dictionaryWithObject: message forKey: NSLocalizedDescriptionKey];
	
	return [NSError errorWithDomain: @"WebSocketError" code: code userInfo: userData];
}

-(void)updateStatus: (WebSocketStatus)s
{
	if(self->status == s){
		return;
	}
	self->status = s;
	if([self->nr_delegate respondsToSelector:@selector(websocket:connectionStatusDidChange:)]){
		[self->nr_delegate websocket: self connectionStatusDidChange: s];
	}
	
	if(self->status == WebSocketStatusConnected && self->shouldForcePumpOutputStream){
		if( [self->nr_delegate respondsToSelector: @selector(websocketIsReadyForData:)] ){
			[self->nr_delegate websocketIsReadyForData: self];
		}
	}
	
}

-(id)initWithURL: (NSURL *)u
{
	self = [super init];
	self->url = [u retain];
	self->shouldForcePumpOutputStream = NO;
	[self updateStatus: WebSocketStatusNew];

	//Generate key.
	//A "Sec-WebSocket-Key" header field with a base64-encoded (see
	//Section 4 of [RFC4648]) value that, when decoded, is 16 bytes in
	//length.
	
	NSMutableData* bytesToEncode = [NSMutableData data];
	
	for(NSInteger i = 0; i < 16; i++){
		uint8_t byte = arc4random() % 256;
		[bytesToEncode appendBytes: &byte length: 1];
	}
	NSString* k = [NSString stringWithData: bytesToEncode encoding: NSASCIIStringEncoding] ;
	self->key = [b64EncodeString(k) retain];
	
	return self;
}


-(void)shutdownStreams
{
	[self->socketOutputStream close];
	[self->socketInputStream close];
	[self->socketInputStream removeFromRunLoop: [NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self->socketOutputStream removeFromRunLoop: [NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	NTI_RELEASE(self->socketInputStream);
	NTI_RELEASE(self->socketOutputStream);
	[self updateStatus: WebSocketStatusDisconnected];
}


-(void)shutdownAsResultOfError: (NSError*)error
{
	NSLog(@"Shutting down as a result of an error! %@", error ? [error localizedDescription] : @"");
	[self updateStatus: WebSocketStatusDisconnecting];
	
	if( [self->nr_delegate respondsToSelector: @selector(websocket:didEncounterError:)] ){
		[self->nr_delegate websocket: self didEncounterError: error];
	}
	
	[self shutdownStreams];
}

-(void)readAndEnqueue: (BOOL)asString
{
	//Called after having read the first byte.
	
	//Next byte is our flag and opcode
	uint8_t mask_and_len = 0x00;
	[self->socketInputStream read: &mask_and_len maxLength: 1];
	
	int client_len = mask_and_len & 0x7F;
	
	uint8_t b1;
	uint8_t b2;
	if( client_len == 126 ){
		[self->socketInputStream read: &b1 maxLength: 1];
		[self->socketInputStream read: &b2 maxLength: 1];
		client_len = (b1 << 8) | b2;
	}
	else if(client_len == 127){
		[self shutdownAsResultOfError: errorWithCodeAndMessage(301, @"64 bit length frame not allowed")];
	}
	
	//The server doesn't have to send a masking key
	BOOL masked = (mask_and_len & 0x80);
	
	uint8_t mask[4];
	for(NSInteger i = 0; i<4; i++){
		if(masked){
			[self->socketInputStream read: &mask[i] maxLength: 1];
		}
		else{
			mask[i]=0x00;
		}
	}
	
	//We must go byte by byte so we can apply the mask if necessary
	NSMutableData* data = [NSMutableData data];
	for(NSInteger i=0; i<client_len; i++){
		uint8_t byte;
		[self->socketInputStream read: &byte maxLength: 1];
		byte = byte ^ mask[i%4];
		[data appendBytes: &byte length: 1];
	}
	
	WebSocketData* wsdata = [[[WebSocketData alloc] initWithData: data
														isText: asString] autorelease];
	[self enqueueRecievedData: wsdata];
	if( [self->nr_delegate respondsToSelector: @selector(websocketDidRecieveData:)] ){
		[self->nr_delegate websocketDidRecieveData: self];
	}
}

-(void)dequeueAndSend
{
	WebSocketData* wsdata = [self dequeueDataForSending];
	
	if( !wsdata ){
		self->shouldForcePumpOutputStream = YES;
		return;
	}
	
		
	uint8_t flag_and_opcode = 0x80;
	if( [wsdata text] ){
		//We will go as string
		flag_and_opcode = flag_and_opcode+1;
	}
	
	NSData* data = wsdata.data;
#ifdef DEBUG_SOCKETIO
	NSLog(@"About to send data %@", wsdata);
#endif
	
	BOOL isLong=NO;
	uint8_t first = 0x00;
	uint8_t second = 0x00;
	uint8_t third = 0x00;
		
	if( [data length] < 126 ){
		first = [data length];
	}
	else if([data length] < 0xFFFF){
		first = 126;
		second = ([data length] & 0xFF00) >> 8;
		third = [data length] & 0xFF;
		isLong = YES;
	}
	else{
		[self shutdownAsResultOfError: errorWithCodeAndMessage(301, @"64 bit length frame not allowed")];
	}
#ifdef DEBUG_SOCKETIO
	NSLog(@"About to send data length = %ld", [data length]);
#endif
	//Client is always masked
	first = first | 0x80;
	
	[self->socketOutputStream write: &flag_and_opcode maxLength: 1];
	[self->socketOutputStream write: &first maxLength: 1];
	if(isLong){
		[self->socketOutputStream write: &second maxLength: 1];
		[self->socketOutputStream write: &third maxLength: 1];
	}
	
	//Generate a random 4 bytes to use as our mask
	uint8_t mask[4];
	for(NSInteger i = 0; i < 4; i++){
		mask[i] = arc4random() % 128;
	}
	
	[self->socketOutputStream write: (const uint8_t*)mask maxLength: 4];

	//We must go byte by byte so we can apply the mask
	for(NSUInteger i=0; i<[data length]; i++){
		uint8_t byte;
		[data getBytes: &byte range: NSMakeRange(i, 1)];
		byte = byte ^ mask[i%4];
		[self->socketOutputStream write: &byte maxLength: 1];
	}
	
	self->shouldForcePumpOutputStream = NO;
}

-(void)enqueueDataForSending:(id)data
{
	[super enqueueDataForSending: data];
	if(self->shouldForcePumpOutputStream){
		[self dequeueAndSend];
	}
}

static NSArray* piecesFromString(NSString* data, NSString* regexString){
	NSError* error = nil;
	NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: regexString 
																		   options: 0 
																			 error: &error];
	
	if (error) {
		NSLog(@"%@", [error description]);
		return nil;
	}
	
	NSArray* results = [regex matchesInString: data options:0 range:NSMakeRange(0, [data length])];
	NSMutableArray* parts = [NSMutableArray arrayWithCapacity: 5];
	for (NSTextCheckingResult* result in results) {
		
		for(NSUInteger i = 1 ; i<=regex.numberOfCaptureGroups; i++ ){
			NSRange range = [result rangeAtIndex: i];
			if(range.location == NSNotFound){
				[parts addObject: nil];
			}else{
				[parts addObject: [data substringWithRange: range]];
			}
		}
		
		//Only take the first match
		break;
	}
	return parts;
	
}

static NSData* hashUsingSHA1(NSData* data)
{
    unsigned char hashBytes[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([data bytes], [data length], hashBytes);
	
    return [NSData dataWithBytes:hashBytes length:CC_SHA1_DIGEST_LENGTH];
}

-(BOOL)isSuccessfulHandshakeResponse: (NSString*)response
{
	NSArray* parts = piecesFromString( response, @"Sec-WebSocket-Accept:\\s+(.+?)\\s");
	//We expect one part the accept key
	if( [parts count] < 1  || ![parts firstObject]){
		return NO;
	}
	
	//return YES;
	NSString* acceptKey = [parts firstObject];
//	NSLog(@"Accept key %@", acceptKey);
	//The accept key should be our key concated with the secret.  Sha-1 hashed and then base64 encoded
	NSString* concatWithSecret = [NSString stringWithFormat: @"%@%@", self->key, @"258EAFA5-E914-47DA-95CA-C5AB0DC85B11", nil];
//	NSLog(@"concat is %@", concatWithSecret);
	NSData* hash=hashUsingSHA1([concatWithSecret dataUsingEncoding: NSUTF8StringEncoding]);
//	NSLog(@"hash %@", hash);
	NSString* encoded = [hash base64String];
//	NSLog(@"encoded %@", encoded);
	
	return [encoded isEqualToString: acceptKey];
}

-(void)processHandshakeResponse
{
	//Read 4 bytes and make sure we are http
	uint8_t buf[4];
	[self->socketInputStream read: buf maxLength: 4];
	
	NSData* firstFourData = [NSData dataWithBytes: buf length: 4];
	NSString* firstFourBytesString = [NSString stringWithData: firstFourData encoding: NSUTF8StringEncoding];
	if(![firstFourBytesString isEqualToString: @"HTTP"]){
		[self shutdownAsResultOfError: errorWithCodeAndMessage(302, @"64 bit length frame not allowed")];
	}
	
	NSMutableData* data = [NSMutableData dataWithBytes: buf length: 4];
	
	//We have an http response. must read byte by byte until we encounter 0d0a0d0a (\r\n)
	uint8_t state = 0;  //1 is \r, 2 is \r\n, 3=\r\n\r, 4=\r\n\r\n
	
	//We are an http response so we can guarentee it will eventually come?
	NSInteger maxSize = 1024;
	NSInteger i = 0;
	uint8_t currentByte = 0x00;
	while(i<maxSize){
		
		[self->socketInputStream read: &currentByte maxLength: 1];
		[data appendBytes: &currentByte length: 1];
		
		if( currentByte == 0x0d && (state == 0 || state == 2)){
			state = state + 1;
		}else if( currentByte == 0x0a && (state == 1 || state == 3)){
			state = state + 1;
		}else{
			state = 0;
		}
		if(state == 4){
			break;
		}
	}
	
	NSString* response = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
#ifdef DEBUG_SOCKETIO
	NSLog(@"Handling handshake response %@", response);
#endif
	//FIXME actually check the accept field
	if ([self isSuccessfulHandshakeResponse: response]) {
		//FIXM we completely ignore the accept key here
		[self updateStatus: WebSocketStatusConnected];
	} else {
		[self shutdownAsResultOfError: errorWithCodeAndMessage(300, 
															   [NSString stringWithFormat: 
																@"Unexpected response for handshake. %@", response])];
	}

}

-(void)handleInputStreamEvent: (NSStreamEvent)eventCode
{
	//Stream wants us to read something
	if( eventCode == NSStreamEventHasBytesAvailable)
	{
		switch (self->status) {
			case WebSocketStatusConnecting:
				[self processHandshakeResponse];
				break;
			case WebSocketStatusConnected:{ //Todo handle opcodes here
				
				//Second nibble of first byte is opcode.
				uint8_t firstByte = 0x00;
				[self->socketInputStream read: &firstByte maxLength: 1];
				
				if( firstByte & 0x81 ){ //This is text
					[self readAndEnqueue: YES];
				}
				else if( firstByte & 0x82 ){ //This is binary
					[self readAndEnqueue: NO];
				}
				else if( firstByte & 0x88){ //This is a close
					//Server initiated the disconnect
					//Shut'em down
					[self updateStatus: WebSocketStatusDisconnecting];
					[self->socketOutputStream write: &firstByte maxLength: 1];
					[self shutdownStreams];
					
				}
				else{ //1000 0001
					[self shutdownAsResultOfError: errorWithCodeAndMessage(305, 
																		   [NSString stringWithFormat: @"Unknown opcode recieved. First byte of frame=%d", firstByte])];
				}
				break;
			}
			case WebSocketStatusDisconnecting:{
				//Second nibble of first byte is opcode.
				uint8_t firstByte = 0x00;
				[self->socketInputStream read: &firstByte maxLength: 1];
				//We sent a disconnect we are expecting an acknowledgement of that
				if( firstByte & 0x88){ //This is a close
					[self shutdownStreams];
				}
			}
			default:
#ifdef DEBUG_SOCKETIO
				NSLog(@"Unhandled stream event %ld for stream %@ status is %ld", 
					  eventCode, self->socketInputStream, self->status);
#endif
				break;
		}
	}
	else if( eventCode == NSStreamEventEndEncountered ){
		if(self->status != WebSocketStatusDisconnected){
			NSLog(@"End of input stream encoutered");
			[self shutdownStreams];
		}
	}
}

-(void)initiateHandshake
{
	NSString* getRequest = [NSString stringWithFormat:@"GET %@ HTTP/1.1\r\n"
							"Upgrade: WebSocket\r\n"
							"Connection: Upgrade\r\n"
							"Host: %@\r\n"
							"sec-websocket-origin: %@\r\n"
							"Sec-WebSocket-Key: %@\r\n"
							"Sec-WebSocket-Version: 7\r\n\r\n",
							self->url.path ? self->url.path : @"/",self->url.host,
							[NSString stringWithFormat: @"http://%@",self->url.host], self->key] ;
#ifdef DEBUG_SOCKETIO
	NSLog(@"Initiating handshake with %@", getRequest);
#endif
	NSData* data = [getRequest dataUsingEncoding: NSUTF8StringEncoding];
	[self->socketOutputStream write: [data bytes] maxLength: [data length]];
	[self updateStatus: WebSocketStatusConnecting];
	self->shouldForcePumpOutputStream = NO;
}

-(void)handleOutputStreamEvent: (NSStreamEvent)eventCode
{
	//The stream wants us to write something
	if(eventCode == NSStreamEventHasSpaceAvailable)
	{
		switch (self->status){
			case WebSocketStatusNew:
				[self initiateHandshake];
				break;
			case WebSocketStatusConnecting:
				self->shouldForcePumpOutputStream = YES;
				break;
			case WebSocketStatusConnected:{
				[self dequeueAndSend];
				
				//if we just wrote data we have room for more, otherwise we were empty and we 
				//have room for more.
				if( [self->nr_delegate respondsToSelector: @selector(websocketIsReadyForData:)] ){
					[self->nr_delegate websocketIsReadyForData: self];
				}
				
				break;
			}
			default:
#ifdef DEBUG_SOCKETIO
				NSLog(@"Unhandled stream event %ld for stream %@", eventCode, self->socketOutputStream);
#endif
				break;
		}
	}
	else if( eventCode == NSStreamEventEndEncountered ){
		if(self->status != WebSocketStatusDisconnected){
#ifdef DEBUG_SOCKETIO
			NSLog(@"End of output stream encoutered");
#endif
			[self shutdownStreams];
		}
	}
}

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
	if( eventCode == NSStreamEventErrorOccurred){
		NSError *theError = [aStream streamError];
		NSLog(@"%@ Error: %@ code=%ld domain=%@", aStream, [theError localizedDescription], theError.code, theError.domain);
		[self shutdownAsResultOfError: theError];
	}

	if (aStream == self->socketInputStream){
		[self handleInputStreamEvent: eventCode];
		return;
	}
	
	if(aStream == self->socketOutputStream){
		[self handleOutputStreamEvent: eventCode];
		return;
	}
	
}

-(void)connect
{
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)[self->url host], [[self->url port] intValue], &readStream, &writeStream);
	
	self->socketInputStream = (NSInputStream *)readStream;
	self->socketOutputStream = (NSOutputStream *)writeStream;
	[self->socketInputStream setDelegate:self];
	[self->socketOutputStream setDelegate:self];
	[self->socketInputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self->socketOutputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self->socketInputStream open];
	[self->socketOutputStream open];
}

-(void)disconnect
{
	if(self->status == WebSocketStatusDisconnecting || self->status == WebSocketStatusDisconnected)
	{
		return;
	}
#ifdef DEBUG_SOCKETIO
	NSLog(@"Client initiated disconnect");
#endif
	//FIXME Send disconnect handshake.
	[self updateStatus: WebSocketStatusDisconnecting];
	uint8_t closeByte = 0x88;
	[self->socketOutputStream write: &closeByte maxLength: 1];
}

-(void)kill
{
	[self updateStatus: WebSocketStatusDisconnecting];
	[self shutdownStreams];
	[self updateStatus: WebSocketStatusDisconnected];
}


-(void)dealloc
{
	[self shutdownStreams];
	NTI_RELEASE(self->key);
	NTI_RELEASE(self->url);
}

@end