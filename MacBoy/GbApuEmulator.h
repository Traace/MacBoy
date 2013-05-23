//
//  GbApuEmulator.h
//  GBAudio
//
//  Created by Tom Schroeder on 4/8/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <CoreAudio/CoreAudio.h>
#import <AudioToolbox/AudioToolbox.h>

#include "Gb_Apu.h"
#include "Blip_Buffer.h"

#define NUM_BUFFERS 3

struct GBAPUState
{
   AudioStreamBasicDescription   dataFormat;
   AudioQueueRef                 queue;
   AudioQueueBufferRef           buffers[NUM_BUFFERS];
   UInt32                        bufferByteSize;
   UInt32                        numPacketsToRead;
	SInt64                        packetsToPlay;
   bool                          isRunning;
	Blip_Buffer*                  blipBuffer;
};

enum ShapeType
{
   kCircle,
   kRectangle,
   kOblateSpheroid
};

class GbApuEmulator
{
   Gb_Apu *gbAPU;
	Blip_Buffer *blipBuffer;
	GBAPUState *gbAPUState;
	
	blip_time_t time;
	uint_fast32_t _lastCPUCycle;
	uint8_t _apuStatus;
   
   void initializeAudioPlaybackQueue();
   
   blip_time_t clock();
   
public:
   GbApuEmulator();
   ~GbApuEmulator();
   
   void beginApuPlayback();
   void stopApuPlayback();
   
   // writeByte toAPUFromCPUAddress onCycle
   void writeByte(uint8_t byte, uint16_t address, uint_fast32_t cycle);
   
   double endFrame(uint_fast32_t cycle);
};
