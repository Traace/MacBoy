//
//  WindowController.h
//  MacBoy
//
//  Created by Tom Schroeder on 3/22/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "CPU.h"
#import "Constants.h"

@interface WindowController : NSWindowController
{
   IBOutlet CPU * cpu;
}

@end
