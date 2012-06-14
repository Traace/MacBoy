//
//  Protocols.h
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef MacBoy_Protocols_h
#define MacBoy_Protocols_h

@protocol Cartridge <NSObject>

- (int) ReadByte:(int) address;
- (void) WriteByte:(int) address :(int) value;

@end

#endif
