//
//  AppDelegate.h
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "CPU.h"
#import "Game.h"
#import "GameboyOpenGLView.h"
#import "GbApuEmulator.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
   IBOutlet CPU *cpu;
   double scanLineTicks;
   Game *game;
   
   NSData *romData;
   
   IBOutlet NSImageView *imageView;
   NSBitmapImageRep *bitmapImageRep;
   NSSize screenSize;
   
   IBOutlet GameboyOpenGLView *openGLView;

   uint pixels[160 * 144];
   
   NSString * romFilePath;
   
   GbApuEmulator *apu;
}

@property (assign) IBOutlet NSWindow *window;

@end
