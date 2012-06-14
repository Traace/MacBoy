//
//  ROMLoader.h
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"

@interface ROMLoader : NSObject
{
   NSData * data;
}

//- (Game *) Load:(NSString *)filename;
- (Game *) Load:(NSURL *)fileURL;

@end
