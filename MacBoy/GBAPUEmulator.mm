//
//  GBAPUEmulator.m
//  GBAudio
//
//  Created by Tom Schroeder on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GBAPUEmulator.h"

static void HandleOutputBuffer(void *aqData,
                               AudioQueueRef inAQ,
                               AudioQueueBufferRef inBuffer)
{
//   NSLog(@"%s", __FUNCTION__);
   
	UInt32 bytesRead = 0;
	UInt32 samplesRead;
	UInt32 availableSamples;
   GBAPUState *pAqData = (GBAPUState *)aqData;
	
	if (!pAqData->isRunning)
   {	
		bytesRead = pAqData->bufferByteSize;
		bzero(inBuffer->mAudioData,pAqData->bufferByteSize);
//		NSLog(@"APU is not running. Filling buffer with zeros.");	
	}
	else
   {
		
		availableSamples = pAqData->blipBuffer->samples_avail();
		if (availableSamples < pAqData->numPacketsToRead)
      {
			NSLog(@"Insufficient audio samples for buffering. Inserting silence.");
         NSLog(@"Available Samples: %u", availableSamples);
         NSLog(@"NumPacketsToRead: %u", pAqData->numPacketsToRead);

			bytesRead = pAqData->bufferByteSize;
			bzero(inBuffer->mAudioData, pAqData->bufferByteSize);
		}
		else
      {
			samplesRead = pAqData->blipBuffer->read_samples((blip_sample_t*)inBuffer->mAudioData,pAqData->numPacketsToRead);
			bytesRead = samplesRead * 2; // As each sample is 16-bits
		}
	}
   
	inBuffer->mAudioDataByteSize = bytesRead;
	AudioQueueEnqueueBuffer(pAqData->queue, inBuffer, 0, NULL);
}

@implementation GBAPUEmulator

- (void)initializeAudioPlaybackQueue
{
	Float32 gain = 1.0;
	int error;
	
	// Create new output
	error = AudioQueueNewOutput(&(gbAPUState->dataFormat),
                               HandleOutputBuffer,
                               gbAPUState,
                               CFRunLoopGetCurrent(),
                               kCFRunLoopCommonModes,
                               0,
                               &(gbAPUState->queue));
	
	NSLog(@"AudioQueueNewOutput: %d", error);
	
	// Set buffer size
   gbAPUState->numPacketsToRead = 735 * 4; // 44.1kHz at 60 fps = 735 (times 4 to reduce overhead)
	gbAPUState->bufferByteSize = gbAPUState->numPacketsToRead * 2; // Packets times 16-bits per sample
	
	// Allocate those bufferes
	for (int i = 0; i < NUM_BUFFERS; ++i)
   {
		AudioQueueAllocateBuffer(gbAPUState->queue, 
                               gbAPUState->bufferByteSize,
                               &(gbAPUState->buffers[i]));
		
		NSLog(@"AudioQueueAllocateBuffer: %d", error);
	}
	
	AudioQueueSetParameter(gbAPUState->queue,
                          kAudioQueueParam_Volume,
                          gain);
}

- (id)init
{
	if (self = [super init])
   {
		time = 0;
		
		gbAPU = new Gb_Apu();
		blipBuffer = new Blip_Buffer();

      blipBuffer->clock_rate(4194304); // 4194304 for Gameboy

      blargg_err_t error = blipBuffer->set_sample_rate(44100, 600); // 600ms to accomodate up to eight times four frames of audio
		if (error) NSLog(@"Error allocating blipBuffer.");
		
		gbAPU->output(blipBuffer); // TODO: use Stereo_Buffer 

		gbAPUState = (GBAPUState *)malloc(sizeof(GBAPUState));
		gbAPUState->dataFormat.mSampleRate = 44100.0;
		gbAPUState->dataFormat.mFormatID = kAudioFormatLinearPCM;
		
      // Sort out endianness
		if (NSHostByteOrder() == NS_BigEndian)
			gbAPUState->dataFormat.mFormatFlags = kLinearPCMFormatFlagIsBigEndian | kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
		else
         gbAPUState->dataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
		
		gbAPUState->dataFormat.mBytesPerPacket = 2;
		gbAPUState->dataFormat.mFramesPerPacket = 1;
		gbAPUState->dataFormat.mBytesPerFrame = 2;
		gbAPUState->dataFormat.mChannelsPerFrame = 1;
		gbAPUState->dataFormat.mBitsPerChannel = 16;
		gbAPUState->isRunning = false;
		
		gbAPUState->blipBuffer = blipBuffer;
		
		[self initializeAudioPlaybackQueue];
	}
	
	return self;
}

- (void)dealloc
{
	AudioQueueDispose(gbAPUState->queue, true);
	
	// TODO: Free APU Resources
	
   //	[super dealloc];
}

- (void)beginAPUPlayback
{
	// Reset the APU and Buffer
//	gbAPU->reset(false,0);
   gbAPU->reset();
	blipBuffer->clear(true);
	
	// Prime the playback buffer
	for (int i = 0; i < NUM_BUFFERS; ++i)
   {	
		HandleOutputBuffer(gbAPUState, gbAPUState->queue, gbAPUState->buffers[i]);
	}
	
	AudioQueuePrime(gbAPUState->queue, 0, NULL);
   
   gbAPUState->isRunning = true;
	AudioQueueStart(gbAPUState->queue, NULL);
}

- (void)stopAPUPlayback
{
	gbAPUState->isRunning = false;
	AudioQueueStop(gbAPUState->queue, true);
}

// faked CPU timing
//blip_time_t clock() { return time += 4; }
- (blip_time_t) clock
{
   return time += 4;
}

// Write to register (0x4000-0x4017, except 0x4014 and 0x4016)
- (void)writeByte:(uint8_t)byte toAPUFromCPUAddress:(uint16_t)address onCycle:(uint_fast32_t)cycle
{
   
//   NSLog(@"%s : cycle = %u", __FUNCTION__, cycle);
   
//	gbAPU->write_register(cycle, address, byte);
   gbAPU->write_register([self clock], address, byte);
}

// End a 1/60 sound frame
- (double)endFrameOnCycle:(uint_fast32_t)cycle
{
//   NSLog(@"%s : cycle = %u", __FUNCTION__, cycle);
	
	gbAPU->end_frame(cycle);
	blipBuffer->end_frame(cycle);

   uint availableSamples;
   float timingCorrection = 0.;
   
	availableSamples = gbAPUState->blipBuffer->samples_avail();
	if (availableSamples < (gbAPUState->numPacketsToRead * 2))
   {
		timingCorrection = -0.005;
	}
	else if (availableSamples > (gbAPUState->numPacketsToRead * 4))
   {
		timingCorrection = 0.005;
			
		// Try to catch run-away buffer overflow
		if (availableSamples > (gbAPUState->numPacketsToRead * 6))
      {
			NSLog(@"Reducing samples in audio buffer to prevent overflow.");
			blipBuffer->remove_samples(gbAPUState->numPacketsToRead);
		}
	}
	return timingCorrection;
//   return 0;
}



@end
