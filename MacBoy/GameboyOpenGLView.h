//
//  GameboyOpenGLView.h
//  GameboyEmulator2
//
//  Created by Tom Schroeder on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGl/gl.h>
#import <OpenGl/glu.h>

@interface GameboyOpenGLView : NSOpenGLView
{
   uint pixels[160 * 144];
}

- (void) setPixels:(uint *)_pixels;

@end
