//
//  MBC2.h
//  GameboyEmulator2
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"
#import "Constants.h"

@interface MBC2 : NSObject <Cartridge>
{
   enum RomType romType;
   int selectedRomBank;// = 1;
//   private byte[] ram = new byte[512];
   Byte ram[512];
//   private byte[,] rom;
   Byte ** rom;
   
   uint romBanks;
}

- (id) initWithData:(Byte *)fileData :(enum RomType)_romType :(int)romSize :(int)romBanks;

@end
