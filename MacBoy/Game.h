//
//  Game.h
//  GameboyEmulator2
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"
#import "Constants.h"
#import "MBC0.h"
#import "MBC1.h"
#import "MBC2.h"

@interface Game : NSObject
{
@public
   NSString * title;
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
   id<Cartridge> cartridge;
}

- (id) initWithData:(NSData *)fileData;
- (NSString *) description;

@end
