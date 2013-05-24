//
//  Game.h
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "Constants.h"

#import "Cartridge.h"
#import "MBC0.h"
#import "MBC1.h"
#import "MBC2.h"

class Game
{
   char *title;
   bool gameBoyColorGame;
   int licenseCode;
   bool gameBoy;
   enum RomType romType;
   int romSize;
   int romBanks;
   int ramSize;
   int ramBanks;
   bool japanese;
   int oldLicenseCode;
   int maskRomVersion;
   int checksum;
   int actualChecksum;
   int headerChecksum;
   int actualHeaderChecksum;
   bool noVerticalBlankInterruptHandler;
   bool noLCDCStatusInterruptHandler;
   bool noTimerOverflowInterruptHandler;
   bool noSerialTransferCompletionInterruptHandler;
   bool noHighToLowOfP10ToP13InterruptHandler;
   
   void extractGameTitle(byte *data);
   
public:
   Cartridge *cartridge; // TODO: should this be public?
   
   Game(byte *data, long length);
   ~Game();
};
