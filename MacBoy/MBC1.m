//
//  MBC1.m
//  GameboyEmulator2
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBC1.h"

@implementation MBC1

- (id) initWithData:(NSData *)data :(enum RomType)_romType :(int)romSize :(int)_romBanks
//- (id) initWithData:(Byte *)fileData :(enum RomType)_romType :(int)romSize :(int)romBanks
{
   if (self = [super init])
   {
      uint length = [data length];
      Byte * fileData = (Byte *)malloc( length * sizeof(Byte) );
      [data getBytes:fileData];
      
      selectedRomBank = 1;

      romBanks = _romBanks;
      
      romType = _romType;
      int bankSize = romSize / romBanks;
    
      rom = (Byte **)malloc( romBanks * sizeof(Byte *) );
      for (int i = 0; i < romBanks; i++)
      {
         rom[i] = (Byte *)malloc(bankSize * sizeof(Byte));
      }
      
      for (int i = 0, k = 0; i < romBanks; i++)
      {
         for (int j = 0; j < bankSize; j++, k++)
         {
            rom[i][j] = fileData[k];
         }
      }
      
      free(fileData);
   }
   return self;
}

- (void) dealloc
{
   for (int i = 0; i < romBanks; i++)
   {
      free(rom[i]);
   }
   free(rom);
}


- (int) ReadByte:(int)address
{
   if (address <= 0x3FFF)
   {
      return rom[0][address];
   }
   else if (address >= 0x4000 && address <= 0x7FFF)
   {
      return rom[selectedRomBank][address - 0x4000];
   }
   else if (address >= 0xA000 && address <= 0xBFFF)
   {
      return ram[selectedRamBank][address - 0xA000];
   }
   [NSException raise:@"ReadByte Error" format:@"Invalid cartridge read: %x", address];
//      throw new Exception(string.Format("Invalid cartridge read: {0:X}", address));
   return -1;
}

- (void) WriteByte:(int)address :(int)value
{
   if (address >= 0xA000 && address <= 0xBFFF)
   {
      ram[selectedRamBank][address - 0xA000] = (Byte)(0xFF & value);
   }
   else if (address >= 0x6000 && address <= 0x7FFF)
   {
      ramBankingMode = (value & 0x01) == 0x01;         
   }
   else if (address >= 0x2000 && address <= 0x3FFF)
   {
      int selectedRomBankLow = 0x1F & value;
      if (selectedRomBankLow == 0x00)
      {
         selectedRomBankLow++;
      }
      selectedRomBank = (selectedRomBank & 0x60) | selectedRomBankLow;
   }
   else if (address >= 0x4000 && address <= 0x5FFF)
   {
      if (ramBankingMode)
      {
         selectedRamBank = 0x03 & value;
      }
      else
      {
         selectedRomBank = (selectedRomBank & 0x1F) | ((0x03 & value) << 5);
      }
   } 
}

//- (void) loadRAM:(NSData *)ramData
- (void) loadRAM:(NSString *)ramPath
{
   NSData * data = [NSData dataWithContentsOfFile:[ramPath stringByAppendingString:@".sav"]];
   uint length = [data length];
   if (length == 0)
      return;
   Byte * fileData = (Byte *)malloc( length * sizeof(Byte) );
   [data getBytes:fileData];

   memcpy(ram[0], fileData, 8 * 1024 * sizeof(Byte));
   memcpy(ram[1], fileData + (8 * 1024 * sizeof(Byte)), 8 * 1024 * sizeof(Byte));
   memcpy(ram[2], fileData + (2 * 8 * 1024 * sizeof(Byte)), 8 * 1024 * sizeof(Byte));
   memcpy(ram[3], fileData + (3 * 8 * 1024 * sizeof(Byte)), 8 * 1024 * sizeof(Byte));

   free(fileData);
}

- (void) saveRAM:(NSString *)savePath
{
   NSData * bank0 = [NSData dataWithBytes:ram[0] length:(8 * 1024)];
   NSData * bank1 = [NSData dataWithBytes:ram[1] length:(8 * 1024)];
   NSData * bank2 = [NSData dataWithBytes:ram[2] length:(8 * 1024)];
   NSData * bank3 = [NSData dataWithBytes:ram[3] length:(8 * 1024)];

   NSMutableData * saveData = [NSMutableData dataWithData:bank0];
   [saveData appendData:bank1];
   [saveData appendData:bank2];
   [saveData appendData:bank3];

   [saveData writeToFile:savePath atomically:true];
}

@end
