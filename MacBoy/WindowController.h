//
//  WindowController.h
//  MacBoy
//
//  Created by Tom Schroeder on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CPU.h"
#import "Constants.h"

@interface WindowController : NSWindowController
{
   IBOutlet CPU * cpu;
}

@end
