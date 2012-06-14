//
//  AppDelegate.h
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CPU.h"
#import "Game.h"
#import "ROMLoader.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>
{
   //   static const int FRAMES_PER_SECOND = 60;
   //   int MAX_FRAMES_SKIPPED = 10;
   //   int WIDTH = 2 * 160;
   //   int HEIGHT = 2 * 144;
   //   public long FREQUENCY = Stopwatch.Frequency;
   //   public long TICKS_PER_FRAME = Stopwatch.Frequency / FRAMES_PER_SECOND;
   //   private Bitmap bitmap;
   //   public Graphics graphics;
   //   public Stopwatch stopwatch = new Stopwatch();
   //   public long nextFrameStart;
   //   private X80 x80;
   IBOutlet CPU * cpu;
   //   private Rectangle rect;
   //   private double scanLineTicks;
   double scanLineTicks;
   //   private uint[] pixels = new uint[160 * 144];
   uint pixels[160 * 144];
   //   private Game game;
   Game * game;
   
   NSData * romData;
   //   ROMLoader * romLoader;
   
   IBOutlet NSImageView * imageView;
   NSBitmapImageRep * bitmapImageRep;
   NSSize screenSize;
}

@property (assign) IBOutlet NSWindow *window;

@end
