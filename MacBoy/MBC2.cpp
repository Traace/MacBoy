//
//  MBC2.m
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "MBC2.h"

MBC2::MBC2(byte *fileData, enum RomType type, int size, int banks)
{
   selectedRomBank = 1;
   romBanks = banks;
   romType = type;
   int bankSize = size / romBanks;

   rom = new byte*[romBanks];
   for (int i = 0; i < romBanks; i++)
   {
      rom[i] = new byte[bankSize];
   }

   for (int i = 0, k = 0; i < romBanks; ++i)
   {
      for (int j = 0; j < bankSize; ++j, ++k)
      {
         rom[i][j] = fileData[k];
      }
   }
}

MBC2::~MBC2()
{
   for (int i = 0; i < romBanks; ++i)
   {
      delete rom[i];
   }
   delete rom;
}

int MBC2::readByte(int address)
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
   
//   [NSException raise:@"ReadByte Error" format:@"Invalid cartridge read: %x", address];
   throw -1;
   
   return -1;
}

void MBC2::writeByte(int address, int value)
{
   if (address >= 0xA000 && address <= 0xA1FF)
   {
      ram[address - 0xA000] = (byte)(0x0F & value);
   }
   else if (address >= 0x2000 && address <= 0x3FFF)
   {
      selectedRomBank = 0x0F & value;
   }
}

