//
//  MBC1.h
//  GameboyEmulator2
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"
#import "Constants.h"

@interface MBC1 : NSObject <Cartridge>
{
   enum RomType romType;
   bool ramBankingMode;
   int selectedRomBank;// = 1;
   int selectedRamBank;
//   byte[,] ram = new byte[4, 8 * 1024];
//   byte[,] rom;
   Byte ram[4][8 * 1024];
   Byte ** rom; // [romBanks][bankSize]
   
   uint romBanks;
   
}

//- (id) initWithData:(Byte *)fileData :(enum RomType)_romType :(int)romSize :(int)romBanks;
- (id) initWithData:(NSData *)data :(enum RomType)_romType :(int)romSize :(int)romBanks;

@end
