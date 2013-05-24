//
//  Game.m
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "Game.h"

Game::Game(byte *data, long length)
{
//   NSUInteger length = [data length];
//   Byte * fileData = (Byte *)malloc( length * sizeof(Byte) );
//   [data getBytes:fileData];
   
//   title = (char*)extractGameTitle(data);
   gameBoyColorGame = data[0x0143] == 0x80;
   licenseCode = (((int)data[0x0144]) << 4) | data[0x0145];
   gameBoy = data[0x0146] == 0x00;
   romType = (RomType)data[0x0147];
   
   switch (data[0x0148])
   {
      case 0x00:
         romSize = 32 * 1024;
         romBanks = 2;
         break;
      case 0x01:
         romSize = 64 * 1024;
         romBanks = 4;
         break;
      case 0x02:
         romSize = 128 * 1024;
         romBanks = 8;
         break;
      case 0x03:
         romSize = 256 * 1024;
         romBanks = 16;
         break;
      case 0x04:
         romSize = 512 * 1024;
         romBanks = 32;
         break;
      case 0x05:
         romSize = 1024 * 1024;
         romBanks = 64;
         break;
      case 0x06:
         romSize = 2 * 1024 * 1024;
         romBanks = 128;
         break;
      case 0x52:
         romSize = 1179648;
         romBanks = 72;
         break;
      case 0x53:
         romSize = 1310720;
         romBanks = 80;
         break;
      case 0x54:
         romSize = 1572864;
         romBanks = 96;
         break;
   }
   
   switch (data[0x0149])
   {
      case 0x00:
         ramSize = 0;
         ramBanks = 0;
         break;
      case 0x01:
         ramSize = 2 * 1024;
         ramBanks = 1;
         break;
      case 0x02:
         ramSize = 8 * 1024;
         ramBanks = 1;
         break;
      case 0x03:
         ramSize = 32 * 1024;
         ramBanks = 4;
         break;
      case 0x04:
         ramSize = 128 * 1024;
         ramBanks = 16;
         break;
   }
   
   japanese = data[0x014A] == 0x00;
   oldLicenseCode = data[0x014B];
   maskRomVersion = data[0x014C];
   
   headerChecksum = data[0x014D];
   for(int i = 0x0134; i <= 0x014C; i++)
   {
      actualHeaderChecksum = actualHeaderChecksum - data[i] - 1;
   }
   actualHeaderChecksum &= 0xFF;
   
   checksum = (((int)data[0x014E]) << 8) | data[0x014F];
   for (int i = 0; i < length; i++)
   {
      if (i != 0x014E && i != 0x014F)
      {
         actualChecksum += data[i];
      }
   }
   actualChecksum &= 0xFFFF;
   
   noVerticalBlankInterruptHandler = data[0x0040] == 0xD9;
   noLCDCStatusInterruptHandler = data[0x0048] == 0xD9;
   noTimerOverflowInterruptHandler = data[0x0050] == 0xD9;
   noSerialTransferCompletionInterruptHandler = data[0x0058] == 0xD9;
   noHighToLowOfP10ToP13InterruptHandler = data[0x0060] == 0xD9;
   
   switch (romType)
   {
      case ROM_MBC0:
//            cartridge = [[MBC0 alloc] initWithData:data];
         throw "Not yet implemented!";
         break;
      case ROM_MBC1:
      case ROM_MBC1_RAM:
      case ROM_MBC1_RAM_BATT:
         cartridge = new MBC1(data, length, romType, romSize, romBanks);
         break;
      case ROM_MBC2:
      case ROM_MBC2_BATTERY:
//            cartridge = [[MBC2 alloc] initWithData:fileData :romType :romSize :romBanks];
//            cartridge = new MBC2(fileData, romType, romSize, romBanks);
         throw "Not yet implemented!";
         break;
      default:
//         [NSException raise:@"Game Init Error" format:@"Cannot emulate cartridge type: 0x%x", romType];
         throw "Cannot emulate cartridge type";
   }
}

Game::~Game()
{
   delete [] title;
}

void Game::extractGameTitle(byte *data)
{
   title = new char[0x0142 - 0x0134];
   for (int i = 0x0134; i <= 0x0142; i++)
   {
      title[i - 0x0134] = data[i];
      if (data[i] == 0x00) break;
//      char ch[2] = { (char)fileData[i], 0 };
//      [s appendString:[NSString stringWithUTF8String:ch]];
   }
}

/*
- (NSString *)description
{
   return @"Game Description";
   //   return "title = " + title + "\n"
   //   + "game boy color game = " + gameBoyColorGame + "\n"
   //   + "license code = " + licenseCode + "\n"
   //   + "game boy = " + gameBoy + "\n"
   //   + "rom type = " + romType + "\n"
   //   + "rom size = " + romSize + "\n"
   //   + "rom banks = " + romBanks + "\n"
   //   + "ram size = " + ramSize + "\n"
   //   + "ram banks = " + ramBanks + "\n"
   //   + "japanese = " + japanese + "\n"
   //   + "old license code = " + oldLicenseCode + "\n"
   //   + "mask rom version = " + maskRomVersion + "\n"
   //   + "header checksum = " + headerChecksum + "\n"
   //   + "actual header checksum = " + actualHeaderChecksum + "\n"
   //   + "checksum = " + checksum + "\n"
   //   + "actual checksum = " + actualChecksum + "\n"
   //   + "no vertical blank interrupt handler = " + noVerticalBlankInterruptHandler + "\n"
   //   + "no lcd status interrupt handler = " + noLCDCStatusInterruptHandler + "\n"
   //   + "no timer overflow interrupt handler = " + noTimerOverflowInterruptHandler + "\n"
   //   + "no serial transfer completion interrupt handler = " + noSerialTransferCompletionInterruptHandler + "\n"
   //   + "no high to lower of P10-P13 interrupt handler = " + noHighToLowOfP10ToP13InterruptHandler + "\n";
}
*/
