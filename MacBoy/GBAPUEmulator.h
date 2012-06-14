//
//  GBAPUEmulator.h
//  GBAudio
//
//  Created by Tom Schroeder on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Cocoa/Cocoa.h>
#import <CoreAudio/CoreAudio.h>
#import <AudioToolbox/AudioToolbox.h>
//#include "nes_apu/Nes_Apu.h"
//#include "nes_apu/Blip_Buffer.h"

#include "Gb_Apu.h"
#include "Blip_Buffer.h"

#define NUM_BUFFERS 3

typedef struct
{
   AudioStreamBasicDescription   dataFormat;
   AudioQueueRef                 queue;
   AudioQueueBufferRef           buffers[NUM_BUFFERS];
   UInt32                        bufferByteSize;
   UInt32                        numPacketsToRead;
	SInt64                        packetsToPlay;
   BOOL                          isRunning;
	Blip_Buffer*                  blipBuffer;
} GBAPUState;

static void HandleOutputBuffer(void *aqData,
                               AudioQueueRef inAQ,
                               AudioQueueBufferRef inBuffer);

typedef enum {
   kCircle,
   kRectangle,
   kOblateSpheroid
} ShapeType;

@interface GBAPUEmulator : NSObject
{
   Gb_Apu *gbAPU;
	Blip_Buffer *blipBuffer;
	GBAPUState *gbAPUState;
	
	blip_time_t time;
	uint_fast32_t _lastCPUCycle;
	uint8_t _apuStatus;
}

- (void)beginAPUPlayback;
- (void)stopAPUPlayback;

// Set function for APU to call when it needs to read memory (DMC samples)
//-(void)setDMCReadObject:(NES6502Interpreter *)cpu;

// Set output sample rate
//- (BOOL)setOutputSampleRate:(long)rate;

// Write to register (0x4000-0x4017, except 0x4014 and 0x4016)
- (void)writeByte:(uint8_t)byte toAPUFromCPUAddress:(uint16_t)address onCycle:(uint_fast32_t)cycle;

// Read from status register at 0x4015
//- (uint8_t)readAPUStatusOnCycle:(uint_fast32_t)cycle;

// End a 1/60 sound frame
- (double)endFrameOnCycle:(uint_fast32_t)cycle;

// Number of samples in buffer
//- (long)numberOfBufferedSamples;

//- (void)clearBuffer;

//- (void)pause;
//- (void)resume;

// Save/load snapshot of emulation state
//- (void)saveSnapshot;
//- (void)loadSnapshot;

//- (int)pendingDMCReadsOnCycle:(uint_fast32_t)cycle;
//- (void)runAPUUntilCPUCycle:(uint_fast32_t)cycle;

@end
