//
//  Protocols.h
//  GameboyEmulator2
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef GameboyEmulator2_Protocols_h
#define GameboyEmulator2_Protocols_h

@protocol Cartridge <NSObject>

- (int) ReadByte:(int) address;
- (void) WriteByte:(int) address :(int) value;

//- (void) loadRAM:(NSData *)ramData;
- (void) loadRAM:(NSString *)ramPath;
- (void) saveRAM:(NSString *)savePath;

@end

#endif
