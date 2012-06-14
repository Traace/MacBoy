//
//  WindowController.m
//  GameboyEmulator2
//
//  Created by Tom Schroeder on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WindowController.h"

//@interface WindowController ()
//
//@end

@implementation WindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self)
    {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) keyDown:(NSEvent *)theEvent
{
//   [cpu KeyChanged:Start :true];
//   [cpu KeyChanged:KeyA :true];
   if (cpu != nil)
   {
      switch( [theEvent keyCode] )
      {
         case 2: // d
         {
            [cpu KeyChanged:KeyB :true];
            break;
         }
         case 3: // f
         {
            [cpu KeyChanged:KeyA :true];
            break;
         }
         case 36: // enter
         {
            [cpu KeyChanged:Start :true];
            break;
         }
         case 42: // "\"
         {
            [cpu KeyChanged:Select :true];
            break;
         }
         case 126: //arrowUp
         {
            [cpu KeyChanged:ArrowUp :true];
            break;
         }
         case 125: //arrowDown
         {
            [cpu KeyChanged:ArrowDown :true];
            break;
         }
         case 124: //arrowRight
         {
            [cpu KeyChanged:ArrowRight :true];
            break;
         }
         case 123: //arrowLeft
         {
            [cpu KeyChanged:ArrowLeft :true];
            break;
         }
         default:
//            NSLog(@"Key %@", theEvent);
//            NSLog(@"Key %@", [theEvent keyCode]);
            break;
      }
   }
}

- (void) keyUp:(NSEvent *)theEvent
{
   if (cpu != nil)
   {
      switch( [theEvent keyCode] )
      {
         case 2: // d
         {
            [cpu KeyChanged:KeyB :false];
            break;
         }
         case 3: // f
         {
            [cpu KeyChanged:KeyA :false];
            break;
         }
         case 36: // enter
         {
            [cpu KeyChanged:Start :false];
            break;
         }
         case 42: // "\"
         {
            [cpu KeyChanged:Select :false];
            break;
         }
         case 126: //arrowUp
         {
            [cpu KeyChanged:ArrowUp :false];
            break;
         }
         case 125: //arrowDown
         {
            [cpu KeyChanged:ArrowDown :false];
            break;
         }
         case 124: //arrowRight
         {
            [cpu KeyChanged:ArrowRight :false];
            break;
         }
         case 123: //arrowLeft
         {
            [cpu KeyChanged:ArrowLeft :false];
            break;
         }
         default:
//            NSLog(@"Key %@", theEvent);
            break;
      }
   }
   
}

@end
