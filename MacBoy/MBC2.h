//
//  MBC2.h
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "Cartridge.h"
#import "Constants.h"

using byte = unsigned char;

class MBC2 : public Cartridge
{
   enum RomType romType;
   int selectedRomBank;

   byte ram[512];
   byte **rom;
   
   unsigned int romBanks;
   
public:
   MBC2(byte *fileData, enum RomType type, int size, int banks);
   ~MBC2();
   
   // Cartridge
   int  readByte(int address);
   void writeByte(int address, int value);
};
