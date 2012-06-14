//
//  Protocols.h
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012. All rights reserved.
//

#ifndef MacBoy_Protocols_h
#define MacBoy_Protocols_h

@protocol Cartridge <NSObject>

- (int) ReadByte:(int) address;
- (void) WriteByte:(int) address :(int) value;

//- (void) loadRAM:(NSData *)ramData;
- (void) loadRAM:(NSString *)ramPath;
- (void) saveRAM:(NSString *)savePath;

@end

#endif
