//
//  Cartridge.h
//  MacBoy
//
//  Created by Tom Schroeder on 5/22/13.
//
//

class Cartridge
{
public:
   virtual int  readByte(int address) = 0;
   virtual void writeByte(int address, int value) = 0;
   
   virtual void loadRAM(const char *ramPath) = 0;
   virtual void saveRAM(const char *savePath) = 0;
};
