//
//  CPU.h
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"
#import "Constants.h"
#import "GBAPUEmulator.h"
#import "CPUTables.h"

extern const uint WHITE;
extern const uint LIGHT_GRAY;
extern const uint DARK_GRAY;
extern const uint BLACK;

@interface CPU : NSObject
{
   IBOutlet GBAPUEmulator * apu;
   
@public
   
   id<Cartridge> cartridge;
   
   bool running;
   bool halted;
   bool stopped;
   
   bool interruptsEnabled;
   bool leftKeyPressed;
   bool rightKeyPressed;
   bool upKeyPressed;
   bool downKeyPressed;
   bool aButtonPressed;
   bool bButtonPressed;
   bool startButtonPressed;
   bool selectButtonPressed;
   bool keyP14, keyP15;
   
   bool keyPressedInterruptRequested;
   bool serialIOTransferCompleteInterruptRequested;
   bool timerOverflowInterruptRequested;
   bool lcdcInterruptRequested;
   bool vBlankInterruptRequested;
   
   bool keyPressedInterruptEnabled;
   bool serialIOTransferCompleteInterruptEnabled;
   bool timerOverflowInterruptEnabled;
   bool lcdcInterruptEnabled;
   bool vBlankInterruptEnabled;
   bool lcdControlOperationEnabled;
   
   bool windowTileMapDisplaySelect;
   bool windowDisplayed;
   bool backgroundAndWindowTileDataSelect;
   bool backgroundTileMapDisplaySelect;
   bool largeSprites;
   bool spritesDisplayed;
   bool backgroundDisplayed;
   
   int scrollX, scrollY;
   int windowX, windowY;
   int lyCompare, ly;

   uint backgroundPalette[4];
   uint objectPalette0[4];
   uint objectPalette1[4];
   
   bool lcdcLycLyCoincidenceInterruptEnabled;
   bool lcdcOamInterruptEnabled;
   bool lcdcVBlankInterruptEnabled;
   bool lcdcHBlankInterruptEnabled;
   enum LcdcModeType lcdcMode;
   
   bool timerRunning;
   int timerCounter;
   int timerModulo;
   enum TimerFrequencyType timerFrequency;
   int ticks;
   
   uint backgroundBuffer[256][256];
   uint spriteTile[256][8][8][2];
   uint windowBuffer[144][168];
   
   Byte oam[256];
   
   uint cycle;
   
@private
   
   int A, B, C, D, E, H, L, PC, SP;
   bool FZ, FC, FH, FN;
   bool stopCounting;
   
   Byte highRam[256];
   Byte videoRam[8 * 1024];
   Byte workRam[8 * 1024];
   
   bool backgroundTileInvalidated[32][32];
   bool invalidateAllBackgroundTilesRequest;
   bool spriteTileInvalidated[256];
   bool invalidateAllSpriteTilesRequest;
}

@property (retain, readwrite) id<Cartridge> cartridge;

- (void) Step;
- (int) ReadByte:(int)address;
- (void) PowerUp;
- (int) ReadWord:(int)address;
- (void) WriteByte:(int)address :(int)value;
- (void) KeyChanged:(enum Keys)keyCode :(bool)pressed;

- (void) UpdateSpriteTiles;
- (void) UpdateWindow;
- (void) UpdateBackground;

@end
