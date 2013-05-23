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
      delete [] rom[i];
   }
   delete [] rom;
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

#include <fstream>
#include <string>
#include <stdio.h>

void MBC1::loadRAM(const char *ramPath)
{
   std::ifstream file(ramPath, std::ios::binary);
   if (file.is_open())
   {
      file.seekg(0, file.end);
      std::streamoff length = file.tellg();
      file.seekg(file.beg);
      
      byte *data = new byte[length];
      file.read((char*)data, length);
      
      // Copy file into GB RAM
      memcpy(ram[0], data, 8 * 1024 * sizeof(byte));
      memcpy(ram[1], data + (8 * 1024 * sizeof(byte)), 8 * 1024 * sizeof(byte));
      memcpy(ram[2], data + (2 * 8 * 1024 * sizeof(byte)), 8 * 1024 * sizeof(byte));
      memcpy(ram[3], data + (3 * 8 * 1024 * sizeof(byte)), 8 * 1024 * sizeof(byte));
      
      file.close();
      delete [] data;
   }
   
}

void MBC1::saveRAM(const char *savePath)
{
   long length = 4 * (8 * 1024);
   byte *data = new byte[length];
   
   memcpy(data, ram[0], 8 * 1024 * sizeof(byte));
   memcpy(data + (8 * 1024 * sizeof(byte)), ram[1], 8 * 1024 * sizeof(byte));
   memcpy(data + (2 * 8 * 1024 * sizeof(byte)), ram[2], 8 * 1024 * sizeof(byte));
   memcpy(data + (3 * 8 * 1024 * sizeof(byte)), ram[3], 8 * 1024 * sizeof(byte));
   
   std::ofstream file(savePath, std::ios::binary);
   if (file.is_open())
   {
      file.write((const char *)data, length);
      file.close();
   }
   
   delete [] data;
}
