//
//  MBC1.m
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "MBC1.h"

MBC1::MBC1(byte *data, long length, enum RomType type, int size, int banks)
{
   romBanks = banks;

   romType = type;
   int bankSize = size / romBanks;

   rom = new byte*[romBanks];
   for (int i = 0; i < romBanks; i++)
   {
      rom[i] = new byte[bankSize];
   }

   for (int i = 0, k = 0; i < romBanks; i++)
   {
      for (int j = 0; j < bankSize; j++, k++)
      {
         rom[i][j] = data[k];
      }
   }
}

MBC1::~MBC1()
{
   for (int i = 0; i < romBanks; i++)
   {
      delete rom[i];
   }
   delete rom;
}


int MBC1::readByte(int address)
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
   
//   [NSException raise:@"ReadByte Error" format:@"Invalid cartridge read: %x", address];
   throw -1;
   
   return -1;
}

void MBC1::writeByte(int address, int value)
{
   if (address >= 0xA000 && address <= 0xBFFF)
   {
      ram[selectedRamBank][address - 0xA000] = (byte)(0xFF & value);
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

void MBC1::loadRAM(const char *ramPath)
{
//   NSData * data = [NSData dataWithContentsOfFile:[ramPath stringByAppendingString:@".sav"]];
//   NSUInteger length = [data length];
//   if (length == 0)
//      return;
//   Byte * fileData = (Byte *)malloc( length * sizeof(Byte) );
//   [data getBytes:fileData];
//   
//   memcpy(ram[0], fileData, 8 * 1024 * sizeof(Byte));
//   memcpy(ram[1], fileData + (8 * 1024 * sizeof(Byte)), 8 * 1024 * sizeof(Byte));
//   memcpy(ram[2], fileData + (2 * 8 * 1024 * sizeof(Byte)), 8 * 1024 * sizeof(Byte));
//   memcpy(ram[3], fileData + (3 * 8 * 1024 * sizeof(Byte)), 8 * 1024 * sizeof(Byte));
//   
//   free(fileData);
}

void MBC1::saveRAM(const char *savePath)
{
//   NSData * bank0 = [NSData dataWithBytes:ram[0] length:(8 * 1024)];
//   NSData * bank1 = [NSData dataWithBytes:ram[1] length:(8 * 1024)];
//   NSData * bank2 = [NSData dataWithBytes:ram[2] length:(8 * 1024)];
//   NSData * bank3 = [NSData dataWithBytes:ram[3] length:(8 * 1024)];
//   
//   NSMutableData * saveData = [NSMutableData dataWithData:bank0];
//   [saveData appendData:bank1];
//   [saveData appendData:bank2];
//   [saveData appendData:bank3];
//   
//   [saveData writeToFile:savePath atomically:true];
}
