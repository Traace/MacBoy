//
//  MBC2.m
//  GameboyEmulator2
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MBC2.h"

@implementation MBC2

- (id) initWithData:(Byte *)fileData :(enum RomType)_romType :(int)romSize :(int)_romBanks
{
   if (self = [super init])
   {
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
   else if (address >= 0xA000 && address <= 0xA1FF)
   {
      return ram[address - 0xA000];
   }
   //   throw new Exception(string.Format("Invalid cartridge address: {0}", address));
   [NSException raise:@"ReadByte Error" format:@"Invalid cartridge read: %x", address];
   return -1;
}

- (void) WriteByte:(int)address :(int)value
{
   if (address >= 0xA000 && address <= 0xA1FF)
   {
      ram[address - 0xA000] = (Byte)(0x0F & value);
   }
   else if (address >= 0x2000 && address <= 0x3FFF)
   {
      selectedRomBank = 0x0F & value;
   } 
}

@end
