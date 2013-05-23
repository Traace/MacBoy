//
//  AppDelegate.m
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
   apu = new GbApuEmulator;
   cpu.apu = apu;
   
   // Size window in ratio with GB screen size
   [_window setAspectRatio:NSMakeSize(10, 9)];
   
   for (int i = 0; i < 160 * 144; i++)
      pixels[i] = 0x00000000; // Black
   
   [self renderFrame];
   
   [NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
   apu->stopApuPlayback();
}

static double timeCorrection = 0;

- (void)run
{
   for (;;)
   {   
      if (cpu != nil && cpu->running)
      {
         [self updateModel];
         [self renderFrame];
         timeCorrection = apu->endFrame(70000);
         [NSThread sleepForTimeInterval:0.016667 + timeCorrection];
         cpu->cycle = 0;
      }
   }
}

- (void)updateModel
{
//   printf("updateModel\n");
   for (int y = 0, pixelIndex = 0; y < 144; y++)
   {
      cpu->ly = y;
      cpu->lcdcMode = SearchingOamRam;
      if (cpu->lcdcInterruptEnabled 
          && (cpu->lcdcOamInterruptEnabled 
              || (cpu->lcdcLycLyCoincidenceInterruptEnabled && cpu->lyCompare == y)))
      {
         cpu->lcdcInterruptRequested = true;
      }

      [self executeProcessor:800];
      cpu->lcdcMode = TransferingData;
      [self executeProcessor:1720];
      
      [cpu UpdateWindow];
      [cpu UpdateBackground];
      [cpu UpdateSpriteTiles];
      
      int windowX = cpu->windowX - 7;
      int windowY = cpu->windowY;
         
      for (int x = 0; x < 160; x++, pixelIndex++)
      {
         uint intensity = 0;
         
         if (cpu->backgroundDisplayed)
         {
            intensity = cpu->backgroundBuffer[0xFF & (cpu->scrollY + y)][0xFF & (cpu->scrollX + x)];
         }
         
         if (cpu->windowDisplayed && y >= windowY && y < windowY + 144 && x >= windowX && x < windowX + 160
             && windowX >= -7 && windowX <= 159 && windowY >= 0 && windowY <= 143)
         {
            intensity = cpu->windowBuffer[y - windowY][x - windowX];
         }
         
         pixels[pixelIndex] = intensity;
      }
         
      if (cpu->spritesDisplayed)
      {
         if (cpu->largeSprites)
         {
            for (int address = 0; address < 160; address += 4)
            {
               int spriteY = cpu->oam[address];
               int spriteX = cpu->oam[address + 1];
               if (spriteY == 0 || spriteX == 0 || spriteY >= 160 || spriteX >= 168)
               {
                  continue;
               }
               spriteY -= 16;
               if (spriteY > y || spriteY + 15 < y)
               {
                  continue;
               }
               spriteX -= 8;
               
               int spriteTileIndex0 = 0xFE & cpu->oam[address + 2];
               int spriteTileIndex1 = spriteTileIndex0 | 0x01;
               int spriteFlags = cpu->oam[address + 3];
               bool spritePriority = (0x80 & spriteFlags) == 0x80;
               bool spriteYFlipped = (0x40 & spriteFlags) == 0x40;
               bool spriteXFlipped = (0x20 & spriteFlags) == 0x20;
               int spritePalette = (0x10 & spriteFlags) == 0x10 ? 1 : 0;
               
               if (spriteYFlipped)
               {
                  int temp = spriteTileIndex0;
                  spriteTileIndex0 = spriteTileIndex1;
                  spriteTileIndex1 = temp;
               }
               
               int spriteRow = y - spriteY;
               if (spriteRow >= 0 && spriteRow < 8)
               {
                  int screenAddress = (y << 7) + (y << 5) + spriteX;
                  for (int x = 0; x < 8; x++, screenAddress++)
                  {
                     int screenX = spriteX + x;
                     if (screenX >= 0 && screenX < 160)
                     {
                        uint color = cpu->spriteTile[spriteTileIndex0]
                                                    [spriteYFlipped ? 7 - spriteRow : spriteRow]
                                                    [spriteXFlipped ? 7 - x : x]
                                                    [spritePalette];
                        if (color > 0)
                        {
                           if (spritePriority)
                           {
                              if (pixels[screenAddress] == 0xFFFFFFFF)
                              {
                                 pixels[screenAddress] = color;
                              }
                           }
                           else
                           {
                              pixels[screenAddress] = color;
                           }
                        }
                     }
                  }
                  continue;
               }
               
               spriteY += 8;
               
               spriteRow = y - spriteY;
               if (spriteRow >= 0 && spriteRow < 8)
               {
                  int screenAddress = (y << 7) + (y << 5) + spriteX;
                  for (int x = 0; x < 8; x++, screenAddress++)
                  {
                     int screenX = spriteX + x;
                     if (screenX >= 0 && screenX < 160)
                     {
                        uint color = cpu->spriteTile[spriteTileIndex1]
                                                    [spriteYFlipped ? 7 - spriteRow : spriteRow]
                                                    [spriteXFlipped ? 7 - x : x]
                                                    [spritePalette];
                        if (color > 0)
                        {
                           if (spritePriority)
                           {
                              if (pixels[screenAddress] == 0xFFFFFFFF)
                              {
                                 pixels[screenAddress] = color;
                              }
                           }
                           else
                           {
                              pixels[screenAddress] = color;
                           }
                        }
                     }
                  }
               }
            }
         }
         else
         {
            for (int address = 0; address < 160; address += 4)
            {
               int spriteY = cpu->oam[address];
               int spriteX = cpu->oam[address + 1];
               if (spriteY == 0 || spriteX == 0 || spriteY >= 160 || spriteX >= 168)
               {
                  continue;
               }
               spriteY -= 16;
               if (spriteY > y || spriteY + 7 < y)
               {
                  continue;
               }
               spriteX -= 8;
               
               int spriteTileIndex = cpu->oam[address + 2];
               int spriteFlags = cpu->oam[address + 3];
               bool spritePriority = (0x80 & spriteFlags) == 0x80;
               bool spriteYFlipped = (0x40 & spriteFlags) == 0x40;
               bool spriteXFlipped = (0x20 & spriteFlags) == 0x20;
               int spritePalette = (0x10 & spriteFlags) == 0x10 ? 1 : 0;
               
               int spriteRow = y - spriteY;
               int screenAddress = (y << 7) + (y << 5) + spriteX;
               for (int x = 0; x < 8; x++, screenAddress++)
               {
                  int screenX = spriteX + x;
                  if (screenX >= 0 && screenX < 160)
                  {
                     uint color = cpu->spriteTile[spriteTileIndex]
                                                 [spriteYFlipped ? 7 - spriteRow : spriteRow] 
                                                 [spriteXFlipped ? 7 - x : x]
                                                 [spritePalette];
                     if (color > 0)
                     {
                        if (spritePriority)
                        {
                           if (pixels[screenAddress] == 0xFFFFFFFF)
                           {
                              pixels[screenAddress] = color;
                           }
                        }
                        else
                        {
                           pixels[screenAddress] = color;
                        }
                     }
                  }
               }
            }
         }
      }
         
      cpu->lcdcMode = HBlank;
      if (cpu->lcdcInterruptEnabled && cpu->lcdcHBlankInterruptEnabled)
      {
         cpu->lcdcInterruptRequested = true;
      }

      [self executeProcessor:2040];
      [self addTicksPerScanLine];
   }
   
   cpu->lcdcMode = VBlank;
   if (cpu->vBlankInterruptEnabled)
   {
      cpu->vBlankInterruptRequested = true;
   }
   if (cpu->lcdcInterruptEnabled && cpu->lcdcVBlankInterruptEnabled)
   {
      cpu->lcdcInterruptRequested = true;
   }
   for (int y = 144; y <= 153; y++)
   {
      cpu->ly = y;
      if (cpu->lcdcInterruptEnabled && cpu->lcdcLycLyCoincidenceInterruptEnabled
          && cpu->lyCompare == y)
      {
         cpu->lcdcInterruptRequested = true;
      }
      [self executeProcessor:4560];
      [self addTicksPerScanLine];
   }
}

- (void)addTicksPerScanLine
{
   switch (cpu->timerFrequency)
   {
      case hz4096:
         scanLineTicks += 0.44329004329004329004329004329004;
         break;
      case hz16384:
         scanLineTicks += 1.7731601731601731601731601731602;
         break;
      case hz65536:
         scanLineTicks += 7.0926406926406926406926406926407;
         break;
      case hz262144:
         scanLineTicks += 28.370562770562770562770562770563;
         break;
   }
   
   while (scanLineTicks >= 1.0)
   {
      scanLineTicks -= 1.0;
      if (cpu->timerCounter == 0xFF)
      {
         cpu->timerCounter = cpu->timerModulo;
         if (cpu->lcdcInterruptEnabled && cpu->timerOverflowInterruptEnabled)
         {
            cpu->timerOverflowInterruptRequested = true;
         }          
      }
      else
      {
         cpu->timerCounter++;
      }
   }
}

- (void)executeProcessor:(int)maxTicks
{   
   do
   {
      [cpu Step];
      if (cpu->halted)
      {
         cpu->ticks = ((maxTicks - cpu->ticks) & 0x03);
         return;
      }
   } while (cpu->ticks < maxTicks);
   
   cpu->ticks -= maxTicks;
}

- (void)renderFrame
{
   [openGLView setPixels:pixels];
   [openGLView setNeedsDisplay:true];
}

#pragma mark -
#pragma mark File I/O

- (IBAction)openFile:(id)sender
{
   NSOpenPanel *openPanel = [NSOpenPanel openPanel];
   if ([openPanel runModal] == NSOKButton)
   {
      NSArray *urls = [openPanel URLs];
      NSURL *romFile = [urls objectAtIndex:0];
      
      NSString *romPath = [[[romFile filePathURL] absoluteString] stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""];
      
      // Replace escape characters from URL
      romPath = [romPath stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
      romPath = [romPath stringByReplacingOccurrencesOfString:@"%5B" withString:@"["];
      romPath = [romPath stringByReplacingOccurrencesOfString:@"%5D" withString:@"]"];
      
      [self loadFile:romPath];
   }
}

- (IBAction)saveFile:(id)sender
{
   cpu.cartridge->saveRAM([[romFilePath stringByAppendingString:@".sav"] UTF8String]);
}

- (void)loadFile:(NSString *)romPath
{
   romFilePath = [NSString stringWithString:romPath];
   
   NSFileHandle * file = [NSFileHandle fileHandleForReadingAtPath: romPath];
   
   if (file == nil) printf("ERROR: Failed to open file\n");
   
   romData = [file readDataToEndOfFile];
   
   game = [[Game alloc] initWithData:romData];
   
   [cpu setCartridge:game->cartridge];
   
   cpu.cartridge->loadRAM([romPath UTF8String]);
   
   [cpu PowerUp];
   apu->beginApuPlayback();
}

#pragma mark -

@end
