//
//  MBC0.h
//  GameboyEmulator2
//
//  Created by Tom Schroeder on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"

@interface MBC0 : NSObject <Cartridge>
{
   Byte * fileData;
   uint fileSize;
}

- (id) initWithData:(NSData *)data;

@end
