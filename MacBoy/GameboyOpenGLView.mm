//
//  GameboyOpenGLView.m
//  MacBoy
//
//  Created by Tom Schroeder on 3/22/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "GameboyOpenGLView.h"

@implementation GameboyOpenGLView

- (id)initWithFrame:(NSRect)frame
{
    return [super initWithFrame:frame];
}

- (void) prepareOpenGL
{
   memset(pixels, 0, sizeof(pixels));
}

- (void)drawRect:(NSRect)dirtyRect
{
   NSRect frame = [self frame];
   glViewport (0, 0, NSWidth (frame), NSHeight (frame)); // Resize rendering with view

   uint width = 160;
   uint height = 144;
   
   glMatrixMode(GL_PROJECTION);
   glLoadIdentity();
   gluOrtho2D(0., width, height, 0.);
   
   // 8-bit per component values (32 bits per pixel) for rgba colors
   GLuint internalFormat = GL_RGBA8;
   GLuint format = GL_RGBA;
   GLuint type = GL_UNSIGNED_BYTE;
   
   // Pass pixels buffer to OpenGL
   glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, width, height, 0, format, type, pixels);
   
   // by default, OpenGL uses mipmaps. We must disable that for this texture to be "complete"
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
   
   // Draw a quad with the texture
   glEnable(GL_TEXTURE_2D);
   glBegin(GL_QUADS);
   glTexCoord2f(0, 0); glVertex2f(0, 0);
   glTexCoord2f(1, 0); glVertex2f(width, 0);
   glTexCoord2f(1, 1); glVertex2f(width,height);
   glTexCoord2f(0, 1); glVertex2f(0, height);
   glEnd();
   glDisable(GL_TEXTURE_2D);
   
   glFlush();
}

- (void) setPixels:(uint *)_pixels
{
   memcpy(pixels, _pixels, sizeof(pixels));
}

@end
