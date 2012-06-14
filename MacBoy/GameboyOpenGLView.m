//
//  GameboyOpenGLView.m
//  GameboyEmulator2
//
//  Created by Tom Schroeder on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameboyOpenGLView.h"

@implementation GameboyOpenGLView

//- (id)initWithFrame:(NSRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self)
//    {
//       memset(pixels, 0, sizeof(pixels));
//    }
//    
//    return self;
//}

- (void) prepareOpenGL
{
   memset(pixels, 0, sizeof(pixels));
   
   NSRect bounds = [self bounds];
   
   gluOrtho2D (0.0, NSWidth (bounds), NSHeight (bounds), 0.0); // top left 0,0
   
   glClearColor(0, 0, 0, 0);
   glClear(GL_COLOR_BUFFER_BIT);
}

- (void)drawRect:(NSRect)dirtyRect
{
   // Drawing code here.
//   glClear(GL_COLOR_BUFFER_BIT);
   
   glColor3f(0., 0., 0.);
//   glPointSize(2);
   glBegin(GL_POINTS);
   {
      NSSize screenSize = NSMakeSize(160, 144);
      
      for (int y = 0; y < screenSize.height; ++y)
      {
         for (int x = 0; x < screenSize.width; ++x)
         {
            uint pixel = pixels[y * (int)screenSize.width + x];
            if (pixel == 0xFF000000)
            {
               glColor3f(0., 0., 0.);
            }
            else if (pixel == 0xFF555555)
            {
               glColor3f(0.33, 0.33, 0.33);
            }
            else if (pixel == 0xFFAAAAAA)
            {
               glColor3f(0.67, 0.67, 0.67);
            }
            else if (pixel == 0xFFFFFFFF)
            {
               glColor3f(1., 1., 1.);
            }
            else
            {
               glColor3f(1., 1., 1.);
            }
            
            glVertex2i(x, y);
         }
      }
   }
   
   glEnd();
   
   glFlush();
   
}

- (void) setPixels:(uint *)_pixels
{
   memcpy(pixels, _pixels, sizeof(pixels));
}

@end
