//
//  MBC0.m
//  MacBoy
//
//  Created by Tom Schroeder on 3/23/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "MBC0.h"

@implementation MBC0

- (id) initWithData:(NSData *)data
{
   if (self = [super init])
   {
      fileSize = [data length];
      fileData = (Byte *)malloc( fileSize * sizeof(Byte) );
      [data getBytes:fileData];
   }
   return self;
}

- (void) dealloc
{
   free(fileData);
}

- (int) ReadByte:(int)address
{
   return fileData[ 0x7FFF & address ];
}

- (void) WriteByte:(int)address :(int)value
{
   
}

@end
