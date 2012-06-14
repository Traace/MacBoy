//
//  GameboyOpenGLView.m
//  MacBoy
//
//  Created by Tom Schroeder on 3/22/12.
//  Copyright (c) 2012. All rights reserved.
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
   
   
   
//   NSRect frame = [self frame];
////   frame.size.width *= 2;
////   frame.size.height *= 2;
////   frame.origin.x = 0;
////   frame.origin.y = 0;
////   [self setFrame:frame];
////   
////   NSRect bounds = [self bounds];
////   bounds.size.width *= 2;
////   bounds.size.height *= 2;
////   bounds.origin.x = frame.size.width;
////   bounds.origin.y = frame.size.height;
////   [self setBounds:bounds];
//
////   
////   [self setNeedsDisplay:true];
//   
//   // Update the viewport
//   glViewport (0, 0, NSWidth (frame), NSHeight (frame));
//   
//   // Update the projection
//   glMatrixMode (GL_PROJECTION);
//   glLoadIdentity ();
//   //   gluOrtho2D (0.0, NSWidth (bounds), 0.0, NSHeight (bounds)); // bottom left 0,0
//   gluOrtho2D (0.0, NSWidth (frame), NSHeight (frame), 0.0); // top left 0,0
//   
//   glMatrixMode (GL_MODELVIEW);
//   
////   glViewport(0, 0, bounds.size.width, bounds.size.height);
////   gluOrtho2D (0.0, NSWidth (bounds) * 2, NSHeight (bounds) * 2, 0.0); // top left 0,0
//   
//   glClearColor(0, 0, 0, 0);
//   glClear(GL_COLOR_BUFFER_BIT);
}

//- (void) reshape
//{
////   NSRect bounds = [self bounds];
//
////   [self setFrame:[self bounds]];
////   [self setBounds:[self frame]];
//   
//   NSRect frame = [self frame];
//   
//   glViewport (0, 0, NSWidth (frame), NSHeight (frame));
//   
//   // Update the projection
//   glMatrixMode (GL_PROJECTION);
//   glLoadIdentity ();
//
//   gluOrtho2D (0.0, NSWidth (frame), NSHeight (frame), 0.0); // top left 0,0
//   
//   glMatrixMode (GL_MODELVIEW);
//}

- (void)drawRect:(NSRect)dirtyRect
{
   NSRect frame = [self frame];
   glViewport (0, 0, NSWidth (frame), NSHeight (frame));
   
   glMatrixMode(GL_PROJECTION);
   glLoadIdentity();
   gluOrtho2D(0., 160., 144., 0.);
   
   glClearColor(0, 0, 0, 0);

   // Drawing code here.
   glClear(GL_COLOR_BUFFER_BIT);
   
   glColor3f(0., 0., 0.);
   glPointSize(frame.size.width / 80);
//   glPointSize(4);
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
            
//            glVertex2i(x, y);            
            glVertex2i(x + 1, y);
//            glVertex2i(x * 2, y * 2);     glVertex2i(x * 2 + 1, y * 2);
//            glVertex2i(x * 2, y * 2 + 1); glVertex2i(x * 2 + 1, y * 2 + 1);
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
