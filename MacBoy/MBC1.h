//
//  MBC1.h
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "Cartridge.h"
#import "Constants.h"

using byte = unsigned char;

class MBC1 : public Cartridge
{
   enum RomType romType;
   bool ramBankingMode;
   int selectedRomBank = 1;
   int selectedRamBank;
   
   byte ram[4][8 * 1024];
   byte **rom;
   
   unsigned int romBanks;
   
public:
   MBC1(byte *data, long length, enum RomType type, int size, int banks);
   ~MBC1();
   
   // Cartridge
   int  readByte(int address);
   void writeByte(int address, int value);
   void loadRAM(const char *ramPath);
   void saveRAM(const char *savePath);
};
