//
//  Game.m
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Game.h"

@implementation Game

- (NSString *) extractGameTitle:(Byte *)fileData
{
//   StringBuilder sb = new StringBuilder();
   NSMutableString * s = [NSMutableString string];
   for (int i = 0x0134; i <= 0x0142; i++)
   {
      if (fileData[i] == 0x00) {
         break;
      }
//      sb.Append((char)fileData[i]);
      char ch[2] = { (char)fileData[i], 0 };
      [s appendString:[NSString stringWithUTF8String:ch]];
   }
//   return sb.ToString();
   return s;
}

- (id) initWithData:(NSData *)data
//- (id) initWithData:(Byte *)fileData :(uint)length
{
   if (self = [super init])
   {
//      Byte fileData[[data length]];
//      [data getBytes:fileData];
      
      uint length = [data length];
      Byte * fileData = (Byte *)malloc( length * sizeof(Byte) );
      [data getBytes:fileData];
      
      title = [self extractGameTitle:fileData];
      gameBoyColorGame = fileData[0x0143] == 0x80;
      licenseCode = (((int)fileData[0x0144]) << 4) | fileData[0x0145];
      gameBoy = fileData[0x0146] == 0x00;
      romType = (RomType)fileData[0x0147];
      
      switch (fileData[0x0148])
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
      
      switch (fileData[0x0149])
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
      
      japanese = fileData[0x014A] == 0x00;
      oldLicenseCode = fileData[0x014B];
      maskRomVersion = fileData[0x014C];
      
      headerChecksum = fileData[0x014D];
      for(int i = 0x0134; i <= 0x014C; i++)
      {
         actualHeaderChecksum = actualHeaderChecksum - fileData[i] - 1;
      }
      actualHeaderChecksum &= 0xFF;      
      
      checksum = (((int)fileData[0x014E]) << 8) | fileData[0x014F];
      for (uint i = 0; i < length; i++)
      {
         if (i != 0x014E && i != 0x014F)
         {
            actualChecksum += fileData[i];
         }
      }
      actualChecksum &= 0xFFFF;
      
      noVerticalBlankInterruptHandler = fileData[0x0040] == 0xD9;
      noLCDCStatusInterruptHandler = fileData[0x0048] == 0xD9;
      noTimerOverflowInterruptHandler = fileData[0x0050] == 0xD9;
      noSerialTransferCompletionInterruptHandler = fileData[0x0058] == 0xD9;
      noHighToLowOfP10ToP13InterruptHandler = fileData[0x0060] == 0xD9;
      
      switch (romType)
      {
         case ROM_DEF:
//            cartridge = new ROM(data);
//            cartridge = [[ROM alloc] initWithData:fileData];
            break;
         case ROM_MBC1:
         case ROM_MBC1_RAM:
         case ROM_MBC1_RAM_BATT:
//            cartridge = new MBC1(fileData, romType, romSize, romBanks);
//            cartridge = [[MBC1 alloc] initWithData:data :romType :romSize :romBanks];
            break;
         case ROM_MBC2:
         case ROM_MBC2_BATTERY:
//            cartridge = new MBC2(fileData, romType, romSize, romBanks);
            cartridge = [[MBC2 alloc] initWithData:fileData :romType :romSize :romBanks];
            break;
         default:
//            throw new Exception(string.Format("Cannot emulate cartridge type {0}.", romType)); 
            [NSException raise:@"Game Init Error" format:@"Cannot emulate cartridge type: %d", romType];
      }
      
      free(fileData);
   }

   return self;
}


- (NSString *) description
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

@end
