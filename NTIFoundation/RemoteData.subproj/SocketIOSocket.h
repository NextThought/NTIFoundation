//
//  SocketIOSocket.h
//  NTIFoundation
//
//  Created by Christopher Utz on 9/19/11.
//  Copyright 2011 NextThought. All rights reserved.
//

#import <OmniFoundation/OmniFoundation.h>
#import "SocketIOPacket.h"
#import "SocketIOTransport.h"

extern NSString* const SocketIOResource;
extern NSString* const SocketIOProtocol;

enum {
	SocketIOSocketStatusNew,
	SocketIOSocketStatusConnecting,
	SocketIOSocketStatusConnected,
	SocketIOSocketStatusDisconnecting,
	SocketIOSocketStatusDisconnected
};
typedef NSInteger SocketIOSocketStatus;

@class SocketIOSocket;
@protocol SocketIOSocketDelegate <NSObject>
-(void)socket: (SocketIOSocket*)socket connectionStatusDidChange: (SocketIOSocketStatus)status;
-(void)socket: (SocketIOSocket*)socket didEncounterError: (NSError*)error;
-(void)socket: (SocketIOSocket*)socket didRecieveMessage: (NSString*)message;
-(void)socket:(SocketIOSocket *)socket didRecieveEventNamed: (NSString *)name withArgs: (NSArray*)args;
@end

@interface SocketIOSocket : OFObject<SocketIOTransportDelegate>{
@private
	NSURL* url;
	NSString* username;
	NSString* password;
	NSString* sessionId;
	NSInteger heartbeatTimeout;
	NSArray* serverSupportedTransports;
	NSInteger closeTimeout;
	SocketIOSocketStatus status;
	SocketIOWSTransport* transport;
	id nr_delegate;
}
@property (nonatomic, retain) id nr_delegate;
-(id)initWithURL: (NSURL *)url andName: (NSString*)name andPassword: (NSString*)pwd;
-(void)connect;
//Sends the packet via the selected transport or buffers it for transmission
-(void)sendPacket: (SocketIOPacket*)packet;
-(void)disconnect;

@end
