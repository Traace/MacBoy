//
//  Cartridge.h
//  MacBoy
//
//  Created by Tom Schroeder on 5/22/13.
//
//

#ifndef MacBoy_Cartridge_h
#define MacBoy_Cartridge_h

//@protocol Cartridge <NSObject>
//
//- (int) ReadByte:(int) address;
//- (void) WriteByte:(int) address :(int) value;
//
////- (void) loadRAM:(NSData *)ramData;
//- (void) loadRAM:(NSString *)ramPath;
//- (void) saveRAM:(NSString *)savePath;
//
//@end

class Cartridge
{
public:
   virtual int  readByte(int address) = 0;
   virtual void writeByte(int address, int value) = 0;
   
// virtual void loadRAM(NSData *ramData) = 0;
   virtual void loadRAM(const char *ramPath) = 0;
   virtual void saveRAM(const char *savePath) = 0;
};

#endif
