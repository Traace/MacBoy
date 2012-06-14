//
//  ROMLoader.m
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ROMLoader.h"

@implementation ROMLoader

//- (Game *) Load:(NSString *)filename
- (Game *) Load:(NSURL *)fileURL;
{
   // TODO
//   return nil;
   
//   NSFileHandle * file = [NSFileHandle fileHandleForReadingAtPath: filename];
//   NSError * error = [[NSError alloc] init];
//   NSFileHandle * file = [NSFileHandle fileHandleForReadingFromURL:fileURL error:&error];
//   
//   if (error)
//      [NSApp presentError:error];
   
   NSString * romPath = @"/Users/tomschroeder/Stuff/Roms/Gameboy/SuperMarioLand2.gb";
   NSFileHandle * file = [NSFileHandle fileHandleForReadingAtPath: romPath];
   
   if (file == nil)
      NSLog(@"ERROR: Failed to open file");
   
   data = [file readDataToEndOfFile];
   
   Game * game = [[Game alloc] initWithData:data];
   
   return game;

//   uint romSize = [data length];
//   Byte * rom = (Byte *)malloc( romSize * sizeof(Byte) );
   
//   [data getBytes:rom];
   
//   NSData *data = [NSData dataWithContentsOfFile:filePath];
//   NSUInteger len = [data length];
//   
//   Byte *byteData = (Byte*)malloc(len);
//   memcpy(byteData, [data bytes], len);
   
//   Game * game = [[Game alloc] initWithData:rom :romSize];
//   return game;
   
//   rom = malloc( [data length] * sizeof(Byte) );
//   romSize = (unsigned int)[data length];
//   
//   [data getBytes:rom];
}

@end
