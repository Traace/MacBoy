//
//  ROM.m
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ROM.h"

@implementation ROM

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

- (int) ReadByte:(int)address
{
   return fileData[ 0x7FFF & address ];
}

- (void) WriteByte:(int)address :(int)value
{
   
}

@end
