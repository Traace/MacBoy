//
//  ROM.h
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"
#import "Constants.h"

@interface ROM : NSObject <Cartridge>
{
   Byte * fileData;
   uint fileSize;
}

- (id) initWithData:(NSData *)data;

@end
