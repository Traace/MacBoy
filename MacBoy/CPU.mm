//
//  CPU.m
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "CPU.h"

static const uint WHITE = 0xFFFFFFFF;
static const uint LIGHT_GRAY = 0xFFAAAAAA;
static const uint DARK_GRAY = 0xFF555555;
static const uint BLACK = 0xFF000000;

@implementation CPU

@synthesize cartridge, apu;

- (id) init
{
   if (self = [super init])
   {
      running = false;
      
      interruptsEnabled = true;
      
      backgroundPalette[0] = WHITE;
      backgroundPalette[1] = LIGHT_GRAY;
      backgroundPalette[2] = DARK_GRAY;
      backgroundPalette[3] = BLACK;
      
      objectPalette0[0] = WHITE;
      objectPalette0[1] = LIGHT_GRAY;
      objectPalette0[2] = DARK_GRAY;
      objectPalette0[3] = BLACK;
      
      objectPalette1[0] = WHITE;
      objectPalette1[1] = LIGHT_GRAY;
      objectPalette1[2] = DARK_GRAY;
      objectPalette1[3] = BLACK;
      
      cycle = 0;
   }
   
   return self;
}

- (void) Step
{
   //[self CheckForBadState];
   
   if (interruptsEnabled)
   {
      if (vBlankInterruptEnabled && vBlankInterruptRequested)
      {
         vBlankInterruptRequested = false;
         [self Interrupt:0x0040];
      }
      else if (lcdcInterruptEnabled && lcdcInterruptRequested)
      {
         lcdcInterruptRequested = false;
         [self Interrupt:0x0048];
      }
      else if (timerOverflowInterruptEnabled && timerOverflowInterruptRequested)
      {
         timerOverflowInterruptRequested = false;
         [self Interrupt:0x0050];
      }
      else if (serialIOTransferCompleteInterruptEnabled && serialIOTransferCompleteInterruptRequested)
      {
         serialIOTransferCompleteInterruptRequested = false;
         [self Interrupt:0x0058];
      }
      else if (keyPressedInterruptEnabled && keyPressedInterruptRequested)
      {
         keyPressedInterruptRequested = false;
         [self Interrupt:0x0060];
      }
   }
   
   PC &= 0xFFFF;
   
   int opCode = 0x00;
   if (!halted)
   {
      opCode = [self ReadByte:PC];
      if (stopCounting)
      {
         stopCounting = false;
      }
      else
      {
         PC++;
      }
   }
   
   switch (opCode)
   {
      case 0x00: // NOP
      case 0xD3:
      case 0xDB:
      case 0xDD:
      case 0xE3:
      case 0xE4:
      case 0xEB:
      case 0xEC:
      case 0xF4:
      case 0xFC:
      case 0xFD:
         [self noOperation];
         break;
      case 0x01: // LD BC,NN
         [self LoadImmediate:B :C];
         break;
      case 0x02: // LD (BC),A
         [self WriteByte:B :C :A];
         break;
      case 0x03: // INC BC
         [self Increment:B :C];
         break;
      case 0x04: // INC B
         [self Increment:B];
         break;
      case 0x05: // DEC B 
         [self Decrement:B];
         break;
      case 0x06: // LD B,N
         [self LoadImmediate:B];
         break;
      case 0x07: // RLCA
         [self RotateALeft];
         break;
      case 0x08: // LD (word),SP
         [self WriteWordToImmediateAddress:SP];
         break;
      case 0x09: // ADD HL,BC
         [self Add:H :L :B :C];
         break;
      case 0x0A: // LD A,(BC)
         [self ReadByte:A :B :C];
         break;
      case 0x0B: // DEC BC
         [self Decrement:B :C];
         break;
      case 0x0C: // INC C
         [self Increment:C];
         break;
      case 0x0D: // DEC C
         [self Decrement:C];
         break;
      case 0x0E: // LD C,N
         [self LoadImmediate:C];
         break;
      case 0x0F: // RRCA
         [self RotateARight];
         break;
      case 0x10: // STOP
         stopped = true;
         ticks += 4;
         break;
      case 0x11: // LD DE,NN
          [self LoadImmediate:D :E];
         break;
      case 0x12: // LD (DE),A
          [self WriteByte:D :E :A];
         break;
      case 0x13: // INC DE
         [self Increment:D :E];
         break;
      case 0x14: // INC D
         [self Increment:D];
         break;
      case 0x15: // DEC D
         [self Decrement:D];
         break;
      case 0x16: // LD D,N
         [self LoadImmediate:D];
         break;
      case 0x17: // RLA
         [self RotateALeftThroughCarry];
         break;
      case 0x18: // JR N
         [self JumpRelative];
         break;
      case 0x19: // ADD HL,DE
         [self Add:H :L :D :E];
         break;
      case 0x1A: // LD A,(DE)
         [self ReadByte:A :D :E];
         break;
      case 0x1B: // DEC DE
         [self Decrement:D :E];
         break;
      case 0x1C: // INC E
         [self Increment:E];
         break;
      case 0x1D: // DEC E
         [self Decrement:E];
         break;
      case 0x1E: // LD E,N
         [self LoadImmediate:E];
         break;
      case 0x1F: // RRA
         [self RotateARightThroughCarry];
         break;
      case 0x20: // JR NZ,N
         [self JumpRelativeIfNotZero];
         break;
      case 0x21: // LD HL,NN
         [self LoadImmediate:H :L];
         break;
      case 0x22: // LD (HLI),A
          [self WriteByte:H :L :A];
         [self Increment:H :L];
         break;
      case 0x23: // INC HL
         [self Increment:H :L];
         break;
      case 0x24: // INC H
         [self Increment:H];
         break;
      case 0x25: // DEC H
         [self Decrement:H];
         break;
      case 0x26: // LD H,N
         [self LoadImmediate:H];
         break;
      case 0x27: // DAA
          [self DecimallyAdjustA];
         break;
      case 0x28: // JR Z,N
         [self JumpRelativeIfZero];
         break;
      case 0x29: // ADD HL,HL
         [self Add:H :L :H :L];
         break;
      case 0x2A: // LD A,(HLI)
         [self ReadByte:A :H :L];
         [self Increment:H :L];
         break;
      case 0x2B: // DEC HL
         [self Decrement:H :L];
         break;
      case 0x2C: // INC L
         [self Increment:L];
         break;
      case 0x2D: // DEC L
         [self Decrement:L];
         break;
      case 0x2E: // LD L,N
         [self LoadImmediate:L];
         break;
      case 0x2F: // CPL
          [self ComplementA];
         break;
      case 0x30: // JR NC,N
         [self JumpRelativeIfNotCarry];
         break;
      case 0x31: // LD SP,NN
         [self LoadImmediateWord:SP];
         break;
      case 0x32: // LD (HLD),A
          [self WriteByte:H :L :A];
         [self Decrement:H :L];
         break;
      case 0x33: // INC SP
         [self IncrementWord:SP];
         break;
      case 0x34: // INC (HL)
          [self IncrementMemory:H :L];
         break;
      case 0x35: // DEC (HL)
          [self DecrementMemory:H :L];
         break;
      case 0x36: // LD (HL),N
          [self LoadImmediateIntoMemory:H :L];
         break;
      case 0x37: // SCF
         [self SetCarryFlag];
         break;
      case 0x38: // JR C,N
         [self JumpRelativeIfCarry];
         break;
      case 0x39: // ADD HL,SP
         [self AddSPToHL];
         break;
      case 0x3A: // LD A,(HLD)
         [self ReadByte:A :H :L];
         [self Decrement:H :L];
         break;
      case 0x3B: // DEC SP
         [self DecrementWord:SP];
         break;
      case 0x3C: // INC A
         [self Increment:A];
         break;
      case 0x3D: // DEC A
         [self Decrement:A];
         break;
      case 0x3E: // LD A,N
         [self LoadImmediate:A];
         break;
      case 0x3F: // CCF
         [self ComplementCarryFlag];
         break;
      case 0x40: // LD B,B
         [self Load:B :B];
         break;
      case 0x41: // LD B,C
         [self Load:B :C];
         break;
      case 0x42: // LD B,D
         [self Load:B :D];
         break;
      case 0x43: // LD B,E
         [self Load:B :E];
         break;
      case 0x44: // LD B,H
         [self Load:B :H];
         break;
      case 0x45: // LD B,L
         [self Load:B :L];
         break;
      case 0x46: // LD B,(HL)
         [self ReadByte:B :H :L];
         break;
      case 0x47: // LD B,A
         [self Load:B :A];
         break;
      case 0x48: // LD C,B
         [self Load:C :B];
         break;
      case 0x49: // LD C,C
         [self Load:C :C];
         break;
      case 0x4A: // LD C,D
         [self Load:C :D];
         break;
      case 0x4B: // LD C,E
         [self Load:C :E];
         break;
      case 0x4C: // LD C,H
         [self Load:C :H];
         break;
      case 0x4D: // LD C,L
         [self Load:C :L];
         break;
      case 0x4E: // LD C,(HL)
         [self ReadByte:C :H :L];
         break;
      case 0x4F: // LD C,A
         [self Load:C :A];
         break;
      case 0x50: // LD D,B
         [self Load:D :B];
         break;
      case 0x51: // LD D,C
         [self Load:D :C];
         break;
      case 0x52: // LD D,D
         [self Load:D :D];
         break;
      case 0x53: // LD D,E
         [self Load:D :E];
         break;
      case 0x54: // LD D,H
         [self Load:D :H];
         break;
      case 0x55: // LD D,L
         [self Load:D :L];
         break;
      case 0x56: // LD D,(HL)
         [self ReadByte:D :H :L];
         break;
      case 0x57: // LD D,A
         [self Load:D :A];
         break;
      case 0x58: // LD E,B
         [self Load:E :B];
         break;
      case 0x59: // LD E,C
         [self Load:E :C];
         break;
      case 0x5A: // LD E,D
         [self Load:E :D];
         break;
      case 0x5B: // LD E,E
         [self Load:E :E];
         break;
      case 0x5C: // LD E,H
         [self Load:E :H];
         break;
      case 0x5D: // LD E,L
         [self Load:E :L];
         break;
      case 0x5E: // LD E,(HL)
         [self ReadByte:E :H :L];
         break;
      case 0x5F: // LD E,A
         [self Load:E :A];
         break;
      case 0x60: // LD H,B
         [self Load:H :B];
         break;
      case 0x61: // LD H,C
         [self Load:H :C];
         break;
      case 0x62: // LD H,D
         [self Load:H :D];
         break;
      case 0x63: // LD H,E
         [self Load:H :E];
         break;
      case 0x64: // LD H,H
         [self Load:H :H];
         break;
      case 0x65: // LD H,L
         [self Load:H :L];
         break;
      case 0x66: // LD H,(HL)
         [self ReadByte:H :H :L];
         break;
      case 0x67: // LD H,A
         [self Load:H :A];
         break;
      case 0x68: // LD L,B
         [self Load:L :B];
         break;
      case 0x69: // LD L,C
         [self Load:L :C];
         break;
      case 0x6A: // LD L,D
         [self Load:L :D];
         break;
      case 0x6B: // LD L,E
         [self Load:L :E];
         break;
      case 0x6C: // LD L,H
         [self Load:L :H];
         break;
      case 0x6D: // LD L,L
         [self Load:L :L];
         break;
      case 0x6E: // LD L,(HL)
         [self ReadByte:L :H :L];
         break;
      case 0x6F: // LD L,A
         [self Load:L :A];
         break;
      case 0x70: // LD (HL),B
         [self WriteByte:H :L :B];
         break;
      case 0x71: // LD (HL),C
         [self WriteByte:H :L :C];
         break;
      case 0x72: // LD (HL),D
         [self WriteByte:H :L :D];
         break;
      case 0x73: // LD (HL),E
         [self WriteByte:H :L :E];
         break;
      case 0x74: // LD (HL),H
         [self WriteByte:H :L :H];
         break;
      case 0x75: // LD (HL),L
         [self WriteByte:H :L :L];
         break;
      case 0x76: // HALT
         [self Halt];
         break;
      case 0x77: // LD (HL),A
         [self WriteByte:H :L :A];
         break;
      case 0x78: // LD A,B
         [self Load:A :B];
         break;
      case 0x79: // LD A,C
         [self Load:A :C];
         break;
      case 0x7A: // LD A,D
         [self Load:A :D];
         break;
      case 0x7B: // LD A,E
         [self Load:A :E];
         break;
      case 0x7C: // LD A,H
         [self Load:A :H];
         break;
      case 0x7D: // LD A,L
         [self Load:A :L];
         break;
      case 0x7E: // LD A,(HL)
         [self ReadByte:A :H :L];
         break;
      case 0x7F: // LD A,A
         [self Load:A :A];
         break;
      case 0x80: // ADD A,B
         [self Add:B];
         break;
      case 0x81: // ADD A,C
         [self Add:C];
         break;
      case 0x82: // ADD A,D
         [self Add:D];
         break;
      case 0x83: // ADD A,E
         [self Add:E];
         break;
      case 0x84: // ADD A,H
         [self Add:H];
         break;
      case 0x85: // ADD A,L
         [self Add:L];
         break;
      case 0x86: // ADD A,(HL)
         [self Add:H :L];
         break;
      case 0x87: // ADD A,A
         [self Add:A];
         break;
      case 0x88: // ADC A,B
         [self AddWithCarry:B];
         break;
      case 0x89: // ADC A,C
         [self AddWithCarry:C];
         break;
      case 0x8A: // ADC A,D
         [self AddWithCarry:D];
         break;
      case 0x8B: // ADC A,E
         [self AddWithCarry:E];
         break;
      case 0x8C: // ADC A,H
         [self AddWithCarry:H];
         break;
      case 0x8D: // ADC A,L
         [self AddWithCarry:L];
         break;
      case 0x8E: // ADC A,(HL)
         [self AddWithCarry:H :L];
         break;
      case 0x8F: // ADC A,A
         [self AddWithCarry:A];
         break;
      case 0x90: // SUB B
         [self Sub:B];
         break;
      case 0x91: // SUB C
         [self Sub:C];
         break;
      case 0x92: // SUB D
         [self Sub:D];
         break;
      case 0x93: // SUB E
         [self Sub:E];
         break;
      case 0x94: // SUB H
         [self Sub:H];
         break;
      case 0x95: // SUB L
         [self Sub:L];
         break;
      case 0x96: // SUB (HL)
         [self Sub:H :L];
         break;
      case 0x97: // SUB A
         [self Sub:A];
         break;
      case 0x98: // SBC B
         [self SubWithBorrow:B];
         break;
      case 0x99: // SBC C
         [self SubWithBorrow:C];
         break;
      case 0x9A: // SBC D
         [self SubWithBorrow:D];
         break;
      case 0x9B: // SBC E
         [self SubWithBorrow:E];
         break;
      case 0x9C: // SBC H
         [self SubWithBorrow:H];
         break;
      case 0x9D: // SBC L
         [self SubWithBorrow:L];
         break;
      case 0x9E: // SBC (HL)
         [self SubWithBorrow:H :L];
         break;
      case 0x9F: // SBC A
         [self SubWithBorrow:A];
         break;
      case 0xA0: // AND B
         [self And:B];
         break;
      case 0xA1: // AND C
         [self And:C];
         break;
      case 0xA2: // AND D
         [self And:D];
         break;
      case 0xA3: // AND E
         [self And:E];
         break;
      case 0xA4: // AND H
         [self And:H];
         break;
      case 0xA5: // AND L
         [self And:L];
         break;
      case 0xA6: // AND (HL)
         [self And:H :L];
         break;
      case 0xA7: // AND A
         [self And:A];
         break;
      case 0xA8: // XOR B
         [self Xor:B];
         break;
      case 0xA9: // XOR C
         [self Xor:C];
         break;
      case 0xAA: // XOR D
         [self Xor:D];
         break;
      case 0xAB: // XOR E
         [self Xor:E];
         break;
      case 0xAC: // XOR H
         [self Xor:H];
         break;
      case 0xAD: // XOR L
         [self Xor:L];
         break;
      case 0xAE: // XOR (HL)
         [self Xor:H :L];
         break;
      case 0xAF: // XOR A
         [self Xor:A];
         break;
      case 0xB0: // OR B
         [self Or:B];
         break;
      case 0xB1: // OR C
         [self Or:C];
         break;
      case 0xB2: // OR D
         [self Or:D];
         break;
      case 0xB3: // OR E
         [self Or:E];
         break;
      case 0xB4: // OR H
         [self Or:H];
         break;
      case 0xB5: // OR L
         [self Or:L];
         break;
      case 0xB6: // OR (HL)
         [self Or:H :L];
         break;
      case 0xB7: // OR A
         [self Or:A];
         break;
      case 0xB8: // CP B
         [self Compare:B];
         break;
      case 0xB9: // CP C
         [self Compare:C];
         break;
      case 0xBA: // CP D
         [self Compare:D];
         break;
      case 0xBB: // CP E
         [self Compare:E];
         break;
      case 0xBC: // CP H
         [self Compare:H];
         break;
      case 0xBD: // CP L
         [self Compare:L];
         break;
      case 0xBE: // CP (HL)
         [self Compare:H :L];
         break;
      case 0xBF: // CP A
         [self Compare:A];
         break;
      case 0xC0: // RET NZ
         [self ReturnIfNotZero];
         break;
      case 0xC1: // POP BC
         [self Pop:B :C];
         break;
      case 0xC2: // JP NZ,N
         [self JumpIfNotZero];
         break;
      case 0xC3: // JP N
         [self Jump];
         break;
      case 0xC4: // CALL NZ,NN
         [self CallIfNotZero];
         break;
      case 0xC5: // PUSH BC
          [self Push:B :C];
         break;
      case 0xC6: // ADD A,N
         [self AddImmediate];
         break;
      case 0xC7: // RST 00H
          [self Restart:0];
         break;
      case 0xC8: // RET Z
         [self ReturnIfZero];
         break;
      case 0xC9: // RET
         [self Return];
         break;
      case 0xCA: // JP Z,N
         [self JumpIfZero];
         break;
      case 0xCB:
         switch ([self ReadByte:PC++])
         {
            case 0x00: // RLC B
               [self RotateLeft:B];
               break;
            case 0x01: // RLC C
               [self RotateLeft:C];
               break;
            case 0x02: // RLC D
               [self RotateLeft:D];
               break;
            case 0x03: // RLC E
               [self RotateLeft:E];
               break;
            case 0x04: // RLC H
               [self RotateLeft:H];
               break;
            case 0x05: // RLC L
               [self RotateLeft:L];
               break;
            case 0x06: // RLC (HL)
               [self RotateLeft:H :L];
               break;
            case 0x07: // RLC A
               [self RotateLeft:A];
               break;
            case 0x08: // RRC B
               [self RotateRight:B];
               break;
            case 0x09: // RRC C
               [self RotateRight:C];
               break;
            case 0x0A: // RRC D
               [self RotateRight:D];
               break;
            case 0x0B: // RRC E
               [self RotateRight:E];
               break;
            case 0x0C: // RRC H
               [self RotateRight:H];
               break;
            case 0x0D: // RRC L
               [self RotateRight:L];
               break;
            case 0x0E: // RRC (HL)
               [self RotateRight:H :L];
               break;
            case 0x0F: // RRC A
               [self RotateRight:A];
               break;
            case 0x10: // RL  B
               [self RotateLeftThroughCarry:B];
               break;
            case 0x11: // RL  C
               [self RotateLeftThroughCarry:C];
               break;
            case 0x12: // RL  D
               [self RotateLeftThroughCarry:D];
               break;
            case 0x13: // RL  E
               [self RotateLeftThroughCarry:E];
               break;
            case 0x14: // RL  H
               [self RotateLeftThroughCarry:H];
               break;
            case 0x15: // RL  L
               [self RotateLeftThroughCarry:L];
               break;
            case 0x16: // RL  (HL)
               [self RotateLeftThroughCarry:H :L];
               break;
            case 0x17: // RL  A
               [self RotateLeftThroughCarry:A];
               break;
            case 0x18: // RR  B
               [self RotateRightThroughCarry:B];
               break;
            case 0x19: // RR  C
               [self RotateRightThroughCarry:C];
               break;
            case 0x1A: // RR  D
               [self RotateRightThroughCarry:D];
               break;
            case 0x1B: // RR  E
               [self RotateRightThroughCarry:E];
               break;
            case 0x1C: // RR  H
               [self RotateRightThroughCarry:H];
               break;
            case 0x1D: // RR  L
               [self RotateRightThroughCarry:L];
               break;
            case 0x1E: // RR  (HL)
               [self RotateRightThroughCarry:H :L];
               break;
            case 0x1F: // RR  A
               [self RotateRightThroughCarry:A];
               break;
            case 0x20: // SLA B
               [self ShiftLeft:B];
               break;
            case 0x21: // SLA C
               [self ShiftLeft:C];
               break;
            case 0x22: // SLA D
               [self ShiftLeft:D];
               break;
            case 0x23: // SLA E
               [self ShiftLeft:E];
               break;
            case 0x24: // SLA H
               [self ShiftLeft:H];
               break;
            case 0x25: // SLA L
               [self ShiftLeft:L];
               break;
            case 0x26: // SLA (HL)
               [self ShiftLeft:H :L];
               break;
            case 0x27: // SLA A
               [self ShiftLeft:A];
               break;
            case 0x28: // SRA B
               [self SignedShiftRight:B];
               break;
            case 0x29: // SRA C
               [self SignedShiftRight:C];
               break;
            case 0x2A: // SRA D
               [self SignedShiftRight:D];
               break;
            case 0x2B: // SRA E
               [self SignedShiftRight:E];
               break;
            case 0x2C: // SRA H
               [self SignedShiftRight:H];
               break;
            case 0x2D: // SRA L
               [self SignedShiftRight:L];
               break;
            case 0x2E: // SRA (HL)
               [self SignedShiftRight:H :L];
               break;
            case 0x2F: // SRA A
               [self SignedShiftRight:A];
               break;
            case 0x30: // SWAP B
               [self Swap:B];
               break;
            case 0x31: // SWAP C
               [self Swap:C];
               break;
            case 0x32: // SWAP D
               [self Swap:D];
               break;
            case 0x33: // SWAP E
               [self Swap:E];
               break;
            case 0x34: // SWAP H
               [self Swap:H];
               break;
            case 0x35: // SWAP L
               [self Swap:L];
               break;
            case 0x36: // SWAP (HL)
               [self Swap:H :L];
               break;
            case 0x37: // SWAP A
               [self Swap:A];
               break;
            case 0x38: // SRL B
               [self UnsignedShiftRight:B];
               break;
            case 0x39: // SRL C
               [self UnsignedShiftRight:C];
               break;
            case 0x3A: // SRL D
               [self UnsignedShiftRight:D];
               break;
            case 0x3B: // SRL E
               [self UnsignedShiftRight:E];
               break;
            case 0x3C: // SRL H
               [self UnsignedShiftRight:H];
               break;
            case 0x3D: // SRL L
               [self UnsignedShiftRight:L];
               break;
            case 0x3E: // SRL (HL)
               [self UnsignedShiftRight:H :L];
               break;
            case 0x3F: // SRL A
               [self UnsignedShiftRight:A];
               break;
            case 0x40: // BIT 0,B
               [self TestBit:0 : B];
               break;
            case 0x41: // BIT 0,C
               [self TestBit:0 : C];
               break;
            case 0x42: // BIT 0,D
               [self TestBit:0 : D];
               break;
            case 0x43: // BIT 0,E
               [self TestBit:0 : E];
               break;
            case 0x44: // BIT 0,H
               [self TestBit:0 : H];
               break;
            case 0x45: // BIT 0,L
               [self TestBit:0 : L];
               break;
            case 0x46: // BIT 0,(HL)
               [self TestBit:0 :H :L];
               break;
            case 0x47: // BIT 0,A
               [self TestBit:0 : A];
               break;
            case 0x48: // BIT 1,B
               [self TestBit:1 : B];
               break;
            case 0x49: // BIT 1,C
               [self TestBit:1 : C];
               break;
            case 0x4A: // BIT 1,D
               [self TestBit:1 : D];
               break;
            case 0x4B: // BIT 1,E
               [self TestBit:1 : E];
               break;
            case 0x4C: // BIT 1,H
               [self TestBit:1 : H];
               break;
            case 0x4D: // BIT 1,L
               [self TestBit:1 : L];
               break;
            case 0x4E: // BIT 1,(HL)
               [self TestBit:1 :H :L];
               break;
            case 0x4F: // BIT 1,A
               [self TestBit:1 : A];
               break;
            case 0x50: // BIT 2,B
               [self TestBit:2 : B];
               break;
            case 0x51: // BIT 2,C
               [self TestBit:2 : C];
               break;
            case 0x52: // BIT 2,D
               [self TestBit:2 : D];
               break;
            case 0x53: // BIT 2,E
               [self TestBit:2 : E];
               break;
            case 0x54: // BIT 2,H
               [self TestBit:2 : H];
               break;
            case 0x55: // BIT 2,L
               [self TestBit:2 : L];
               break;
            case 0x56: // BIT 2,(HL)
               [self TestBit:2 :H :L];
               break;
            case 0x57: // BIT 2,A
               [self TestBit:2 : A];
               break;
            case 0x58: // BIT 3,B
               [self TestBit:3 : B];
               break;
            case 0x59: // BIT 3,C
               [self TestBit:3 : C];
               break;
            case 0x5A: // BIT 3,D
               [self TestBit:3 : D];
               break;
            case 0x5B: // BIT 3,E
               [self TestBit:3 : E];
               break;
            case 0x5C: // BIT 3,H
               [self TestBit:3 : H];
               break;
            case 0x5D: // BIT 3,L
               [self TestBit:3 : L];
               break;
            case 0x5E: // BIT 3,(HL)
               [self TestBit:3 :H :L];
               break;
            case 0x5F: // BIT 3,A
               [self TestBit:3 : A];
               break;
            case 0x60: // BIT 4,B
               [self TestBit:4 : B];
               break;
            case 0x61: // BIT 4,C
               [self TestBit:4 : C];
               break;
            case 0x62: // BIT 4,D
               [self TestBit:4 : D];
               break;
            case 0x63: // BIT 4,E
               [self TestBit:4 : E];
               break;
            case 0x64: // BIT 4,H
               [self TestBit:4 : H];
               break;
            case 0x65: // BIT 4,L
               [self TestBit:4 : L];
               break;
            case 0x66: // BIT 4,(HL)
               [self TestBit:4 :H :L];
               break;
            case 0x67: // BIT 4,A
               [self TestBit:4 : A];
               break;
            case 0x68: // BIT 5,B
               [self TestBit:5 : B];
               break;
            case 0x69: // BIT 5,C
               [self TestBit:5 : C];
               break;
            case 0x6A: // BIT 5,D
               [self TestBit:5 : D];
               break;
            case 0x6B: // BIT 5,E
               [self TestBit:5 : E];
               break;
            case 0x6C: // BIT 5,H
               [self TestBit:5 : H];
               break;
            case 0x6D: // BIT 5,L
               [self TestBit:5 : L];
               break;
            case 0x6E: // BIT 5,(HL)
               [self TestBit:5 :H :L];
               break;
            case 0x6F: // BIT 5,A
               [self TestBit:5 : A];
               break;
            case 0x70: // BIT 6,B
               [self TestBit:6 : B];
               break;
            case 0x71: // BIT 6,C
               [self TestBit:6 : C];
               break;
            case 0x72: // BIT 6,D
               [self TestBit:6 : D];
               break;
            case 0x73: // BIT 6,E
               [self TestBit:6 : E];
               break;
            case 0x74: // BIT 6,H
               [self TestBit:6 : H];
               break;
            case 0x75: // BIT 6,L
               [self TestBit:6 : L];
               break;
            case 0x76: // BIT 6,(HL)
               [self TestBit:6 :H :L];
               break;
            case 0x77: // BIT 6,A
               [self TestBit:6 : A];
               break;
            case 0x78: // BIT 7,B
               [self TestBit:7 : B];
               break;
            case 0x79: // BIT 7,C
               [self TestBit:7 : C];
               break;
            case 0x7A: // BIT 7,D
               [self TestBit:7 : D];
               break;
            case 0x7B: // BIT 7,E
               [self TestBit:7 : E];
               break;
            case 0x7C: // BIT 7,H
               [self TestBit:7 : H];
               break;
            case 0x7D: // BIT 7,L
               [self TestBit:7 : L];
               break;
            case 0x7E: // BIT 7,(HL)
               [self TestBit:7 :H :L];
               break;
            case 0x7F: // BIT 7,A
               [self TestBit:7 : A];
               break;
            case 0x80: // RES 0,B
               [self ResetBit:0 :B];
               break;
            case 0x81: // RES 0,C
               [self ResetBit:0 :C];
               break;
            case 0x82: // RES 0,D
               [self ResetBit:0 :D];
               break;
            case 0x83: // RES 0,E
               [self ResetBit:0 :E];
               break;
            case 0x84: // RES 0,H
               [self ResetBit:0 :H];
               break;
            case 0x85: // RES 0,L
               [self ResetBit:0 :L];
               break;
            case 0x86: // RES 0,(HL)
               [self ResetBit:0 :H :L];
               break;
            case 0x87: // RES 0,A
               [self ResetBit:0 :A];
               break;
            case 0x88: // RES 1,B
               [self ResetBit:1 :B];
               break;
            case 0x89: // RES 1,C
               [self ResetBit:1 :C];
               break;
            case 0x8A: // RES 1,D
               [self ResetBit:1 :D];
               break;
            case 0x8B: // RES 1,E
               [self ResetBit:1 :E];
               break;
            case 0x8C: // RES 1,H
               [self ResetBit:1 :H];
               break;
            case 0x8D: // RES 1,L
               [self ResetBit:1 :L];
               break;
            case 0x8E: // RES 1,(HL)
               [self ResetBit:1 :H :L];
               break;
            case 0x8F: // RES 1,A
               [self ResetBit:1 :A];
               break;
            case 0x90: // RES 2,B
               [self ResetBit:2 :B];
               break;
            case 0x91: // RES 2,C
               [self ResetBit:2 :C];
               break;
            case 0x92: // RES 2,D
               [self ResetBit:2 :D];
               break;
            case 0x93: // RES 2,E
               [self ResetBit:2 :E];
               break;
            case 0x94: // RES 2,H
               [self ResetBit:2 :H];
               break;
            case 0x95: // RES 2,L
               [self ResetBit:2 :L];
               break;
            case 0x96: // RES 2,(HL)
               [self ResetBit:2 :H :L];
               break;
            case 0x97: // RES 2,A
               [self ResetBit:2 :A];
               break;
            case 0x98: // RES 3,B
               [self ResetBit:3 :B];
               break;
            case 0x99: // RES 3,C
               [self ResetBit:3 :C];
               break;
            case 0x9A: // RES 3,D
               [self ResetBit:3 :D];
               break;
            case 0x9B: // RES 3,E
               [self ResetBit:3 :E];
               break;
            case 0x9C: // RES 3,H
               [self ResetBit:3 :H];
               break;
            case 0x9D: // RES 3,L
               [self ResetBit:3 :L];
               break;
            case 0x9E: // RES 3,(HL)
               [self ResetBit:3 :H :L];
               break;
            case 0x9F: // RES 3,A
               [self ResetBit:3 :A];
               break;
            case 0xA0: // RES 4,B
               [self ResetBit:4 :B];
               break;
            case 0xA1: // RES 4,C
               [self ResetBit:4 :C];
               break;
            case 0xA2: // RES 4,D
               [self ResetBit:4 :D];
               break;
            case 0xA3: // RES 4,E
               [self ResetBit:4 :E];
               break;
            case 0xA4: // RES 4,H
               [self ResetBit:4 :H];
               break;
            case 0xA5: // RES 4,L
               [self ResetBit:4 :L];
               break;
            case 0xA6: // RES 4,(HL)
               [self ResetBit:4 :H :L];
               break;
            case 0xA7: // RES 4,A
               [self ResetBit:4 :A];
               break;
            case 0xA8: // RES 5,B
               [self ResetBit:5 :B];
               break;
            case 0xA9: // RES 5,C
               [self ResetBit:5 :C];
               break;
            case 0xAA: // RES 5,D
               [self ResetBit:5 :D];
               break;
            case 0xAB: // RES 5,E
               [self ResetBit:5 :E];
               break;
            case 0xAC: // RES 5,H
               [self ResetBit:5 :H];
               break;
            case 0xAD: // RES 5,L
               [self ResetBit:5 :L];
               break;
            case 0xAE: // RES 5,(HL)
               [self ResetBit:5 :H :L];
               break;
            case 0xAF: // RES 5,A
               [self ResetBit:5 :A];
               break;
            case 0xB0: // RES 6,B
               [self ResetBit:6 :B];
               break;
            case 0xB1: // RES 6,C
               [self ResetBit:6 :C];
               break;
            case 0xB2: // RES 6,D
               [self ResetBit:6 :D];
               break;
            case 0xB3: // RES 6,E
               [self ResetBit:6 :E];
               break;
            case 0xB4: // RES 6,H
               [self ResetBit:6 :H];
               break;
            case 0xB5: // RES 6,L
               [self ResetBit:6 :L];
               break;
            case 0xB6: // RES 6,(HL)
               [self ResetBit:6 :H :L];
               break;
            case 0xB7: // RES 6,A
               [self ResetBit:6 :A];
               break;
            case 0xB8: // RES 7,B
               [self ResetBit:7 :B];
               break;
            case 0xB9: // RES 7,C
               [self ResetBit:7 :C];
               break;
            case 0xBA: // RES 7,D
               [self ResetBit:7 :D];
               break;
            case 0xBB: // RES 7,E
               [self ResetBit:7 :E];
               break;
            case 0xBC: // RES 7,H
               [self ResetBit:7 :H];
               break;
            case 0xBD: // RES 7,L
               [self ResetBit:7 :L];
               break;
            case 0xBE: // RES 7,(HL)
               [self ResetBit:7 :H :L];
               break;
            case 0xBF: // RES 7,A
               [self ResetBit:7 :A];
               break;
            case 0xC0: // SET 0,B
               [self SetBit:0 :B];
               break;
            case 0xC1: // SET 0,C
               [self SetBit:0 :C];
               break;
            case 0xC2: // SET 0,D
               [self SetBit:0 :D];
               break;
            case 0xC3: // SET 0,E
               [self SetBit:0 :E];
               break;
            case 0xC4: // SET 0,H
               [self SetBit:0 :H];
               break;
            case 0xC5: // SET 0,L
               [self SetBit:0 :L];
               break;
            case 0xC6: // SET 0,(HL)
               [self SetBit:0 :H :L];
               break;
            case 0xC7: // SET 0,A
               [self SetBit:0 :A];
               break;
            case 0xC8: // SET 1,B
               [self SetBit:1 :B];
               break;
            case 0xC9: // SET 1,C
               [self SetBit:1 :C];
               break;
            case 0xCA: // SET 1,D
               [self SetBit:1 :D];
               break;
            case 0xCB: // SET 1,E
               [self SetBit:1 :E];
               break;
            case 0xCC: // SET 1,H
               [self SetBit:1 :H];
               break;
            case 0xCD: // SET 1,L
               [self SetBit:1 :L];
               break;
            case 0xCE: // SET 1,(HL)
               [self SetBit:1 :H :L];
               break;
            case 0xCF: // SET 1,A
               [self SetBit:1 :A];
               break;
            case 0xD0: // SET 2,B
               [self SetBit:2 :B];
               break;
            case 0xD1: // SET 2,C
               [self SetBit:2 :C];
               break;
            case 0xD2: // SET 2,D
               [self SetBit:2 :D];
               break;
            case 0xD3: // SET 2,E
               [self SetBit:2 :E];
               break;
            case 0xD4: // SET 2,H
               [self SetBit:2 :H];
               break;
            case 0xD5: // SET 2,L
               [self SetBit:2 :L];
               break;
            case 0xD6: // SET 2,(HL)
               [self SetBit:2 :H :L];
               break;
            case 0xD7: // SET 2,A
               [self SetBit:2 :A];
               break;
            case 0xD8: // SET 3,B
               [self SetBit:3 :B];
               break;
            case 0xD9: // SET 3,C
               [self SetBit:3 :C];
               break;
            case 0xDA: // SET 3,D
               [self SetBit:3 :D];
               break;
            case 0xDB: // SET 3,E
               [self SetBit:3 :E];
               break;
            case 0xDC: // SET 3,H
               [self SetBit:3 :H];
               break;
            case 0xDD: // SET 3,L
               [self SetBit:3 :L];
               break;
            case 0xDE: // SET 3,(HL)
               [self SetBit:3 :H :L];
               break;
            case 0xDF: // SET 3,A
               [self SetBit:3 :A];
               break;
            case 0xE0: // SET 4,B
               [self SetBit:4 :B];
               break;
            case 0xE1: // SET 4,C
               [self SetBit:4 :C];
               break;
            case 0xE2: // SET 4,D
               [self SetBit:4 :D];
               break;
            case 0xE3: // SET 4,E
               [self SetBit:4 :E];
               break;
            case 0xE4: // SET 4,H
               [self SetBit:4 :H];
               break;
            case 0xE5: // SET 4,L
               [self SetBit:4 :L];
               break;
            case 0xE6: // SET 4,(HL)
               [self SetBit:4 :H :L];
               break;
            case 0xE7: // SET 4,A
               [self SetBit:4 :A];
               break;
            case 0xE8: // SET 5,B
               [self SetBit:5 :B];
               break;
            case 0xE9: // SET 5,C
               [self SetBit:5 :C];
               break;
            case 0xEA: // SET 5,D
               [self SetBit:5 :D];
               break;
            case 0xEB: // SET 5,E
               [self SetBit:5 :E];
               break;
            case 0xEC: // SET 5,H
               [self SetBit:5 :H];
               break;
            case 0xED: // SET 5,L
               [self SetBit:5 :L];
               break;
            case 0xEE: // SET 5,(HL)
               [self SetBit:5 :H :L];
               break;
            case 0xEF: // SET 5,A
               [self SetBit:5 :A];
               break;
            case 0xF0: // SET 6,B
               [self SetBit:6 :B];
               break;
            case 0xF1: // SET 6,C
               [self SetBit:6 :C];
               break;
            case 0xF2: // SET 6,D
               [self SetBit:6 :D];
               break;
            case 0xF3: // SET 6,E
               [self SetBit:6 :E];
               break;
            case 0xF4: // SET 6,H
               [self SetBit:6 :H];
               break;
            case 0xF5: // SET 6,L
               [self SetBit:6 :L];
               break;
            case 0xF6: // SET 6,(HL)
               [self SetBit:6 :H :L];
               break;
            case 0xF7: // SET 6,A
               [self SetBit:6 :A];
               break;
            case 0xF8: // SET 7,B
               [self SetBit:7 :B];
               break;
            case 0xF9: // SET 7,C
               [self SetBit:7 :C];
               break;
            case 0xFA: // SET 7,D
               [self SetBit:7 :D];
               break;
            case 0xFB: // SET 7,E
               [self SetBit:7 :E];
               break;
            case 0xFC: // SET 7,H
               [self SetBit:7 :H];
               break;
            case 0xFD: // SET 7,L
               [self SetBit:7 :L];
               break;
            case 0xFE: // SET 7,(HL)
               [self SetBit:7 :H :L];
               break;
            case 0xFF: // SET 7,A
               [self SetBit:7 :A];
               break;
         }
         break;
      case 0xCC: // CALL Z,NN
         [self CallIfZero];
         break;
      case 0xCD: // CALL NN
         [self Call];
         break;
      case 0xCE: // ADC A,N
         [self AddImmediateWithCarry];
         break;
      case 0xCF: // RST 8H
         [self Restart:0x08];
         break;
      case 0xD0: // RET NC
         [self ReturnIfNotCarry];
         break;
      case 0xD1: // POP DE
         [self Pop:D :E];
         break;
      case 0xD2: // JP NC,N
         [self JumpIfNotCarry];
         break;
      case 0xD4: // CALL NC,NN
         [self CallIfNotCarry];
         break;
      case 0xD5: // PUSH DE
         [self Push:D :E];
         break;
      case 0xD6: // SUB N
         [self SubImmediate];
         break;
      case 0xD7: // RST 10H
         [self Restart:0x10];
         break;
      case 0xD8: // RET C
         [self ReturnIfCarry];
         break;
      case 0xD9: // RETI
         [self ReturnFromInterrupt];
         break;
      case 0xDA: // JP C,N
         [self JumpIfCarry];
         break;
      case 0xDC: // CALL C,NN
         [self CallIfCarry];
         break;
      case 0xDE: // SBC A,N
         [self SubImmediateWithBorrow];
         break;
      case 0xDF: // RST 18H
         [self Restart:0x18];
         break;
      case 0xE0: // LD (FF00+byte),A
         [self SaveAWithOffset];
         break;
      case 0xE1: // POP HL
         [self Pop:H :L];
         break;
      case 0xE2: // LD (FF00+C),A
         [self SaveAToC];
         break;
      case 0xE5: // PUSH HL
         [self Push:H :L];
         break;
      case 0xE6: // AND N
         [self AndImmediate];
         break;
      case 0xE7: // RST 20H
         [self Restart:0x20];
         break;
      case 0xE8: // ADD SP,offset
         [self OffsetStackPointer];
         break;
      case 0xE9: // JP (HL)
         [self Jump:H :L];
         break;
      case 0xEA: // LD (word),A
         [self SaveA];
         break;
      case 0xEE: // XOR N
         [self XorImmediate];
         break;
      case 0xEF: // RST 28H
         [self Restart:0x0028];
         break;
      case 0xF0: // LD A :(FF00 + n)
         [self LoadAFromImmediate];
         break;
      case 0xF1: // POP AF
         [self PopAF];
         break;
      case 0xF2: // LD A :(FF00 + C)
         [self LoadAFromC];
         break;
      case 0xF3: // DI
         interruptsEnabled = false;
         break;
      case 0xF5: // PUSH AF
         [self PushAF];
         break;
      case 0xF6: // OR N
         [self OrImmediate];
         break;
      case 0xF7: // RST 30
         [self Restart:0x0030];
         break;
      case 0xF8: // LD HL :SP + dd
         [self LoadHLWithSPPlusImmediate];
         break;
      case 0xF9: // LD SP,HL
         [self LoadSPWithHL];
         break;
      case 0xFA: // LD A :(nn)
         [self LoadFromImmediateAddress:A];
         break;
      case 0xFB: // EI
         interruptsEnabled = true;
         break;
      case 0xFE: // CP N
         [self CompareImmediate];
         break;
      case 0xFF: // RST 38H
         [self Restart:0x0038];
         break;
      default:
         [NSException raise:@"CPU Error: Step" format:@"Unknown instruction: 0x%x at PC=0x%x", opCode, PC];
   }
   
   // Calculate Cycle
   cycle += Cycles[opCode];
}

- (void) Load:(int &)a :(int)b
{
   a = b;
   ticks += 4;
}

- (void) LoadSPWithHL
{
   SP = (H << 8) | L;
   ticks += 6;
}

- (void) LoadAFromImmediate
{
   A = [self ReadByte:0xFF00 | [self ReadByte:PC++]];
   ticks += 19;
}

- (void) LoadAFromC
{
   A = [self ReadByte:0xFF00 | C];
   ticks += 19;
}

- (void) LoadHLWithSPPlusImmediate
{
   int offset = [self ReadByte:PC++];
   if (offset > 0x7F)
   {
      offset -= 256;
   }
   offset += SP;
   H = 0xFF & (offset >> 8);
   L = 0xFF & offset;
   ticks += 20;
}

- (void) ReturnFromInterrupt
{
   interruptsEnabled = true;
   halted = false;
   [self Return];
   ticks += 4;
}

- (void) NegateA
{
   FC = A == 0;
   FH = (A & 0x0F) != 0;
   A = 0xFF & -A;
   FZ = A == 0;       
   FN = true;
   ticks += 8;
}

- (void) noOperation
{
   ticks += 4;
}

- (void) OffsetStackPointer
{
   int value = [self ReadByte:PC++];
   if (value > 0x7F)
   {
      value -= 256;
   }
   SP += value;
   ticks += 20;
}

- (void) SaveAToC
{
   [self WriteByte:(0xFF00 | C) :A];
   ticks += 19;
}

- (void) SaveA
{
   [self WriteByte:[self ReadWord:PC] :A];
   PC += 2;
   ticks += 13;
}

- (void) SaveAWithOffset
{
   [self WriteByte:0xFF00 | [self ReadByte:PC++] :A];
   ticks += 19;
}

- (void) Swap:(int)ah :(int)al
{
   int address = (ah << 8) | al;
   int value = [self ReadByte:address];
   [self Swap:value];
   [self WriteByte:address :value];
   ticks += 7;
}

- (void) Swap:(int &)r
{
   r = 0xFF & ((r << 4) | (r >> 4));
   ticks += 8;
}

- (void) SetBit:(int)bit :(int)ah :(int)al
{
   int address = (ah << 8) | al;
   int value = [self ReadByte:address];
   [self SetBit:bit :value];
   [self WriteByte:address :value];
   ticks += 7;
}

- (void) SetBit:(int)bit :(int &)a
{
   a |= (1 << bit);
   ticks += 8;
}

- (void) ResetBit:(int)bit :(int)ah :(int)al
{
   int address = (ah << 8) | al;
   int value = [self ReadByte:address];
   [self ResetBit:bit :value];
   [self WriteByte:address :value];
   ticks += 7;
}

- (void) ResetBit:(int)bit :(int &)a
{
   switch (bit)
   {
      case 0: // 1111 1110
         a &= 0xFE;
         break;
      case 1: // 1111 1101
         a &= 0xFD;
         break;
      case 2: // 1111 1011
         a &= 0xFB;
         break;
      case 3: // 1111 0111
         a &= 0xF7;
         break;
      case 4: // 1110 1111
         a &= 0xEF;
         break;
      case 5: // 1101 1111
         a &= 0xDF;
         break;
      case 6: // 1011 1111
         a &= 0xBF;
         break;
      case 7: // 0111 1111
         a &= 0x7F;
         break;
   }
   ticks += 8;
}

- (void) Halt
{
   if (interruptsEnabled)
   {
      halted = true;
   }
   else
   {
      stopCounting = true;
   }
   ticks += 4;
}

- (void) TestBit:(int)bit :(int)ah :(int)al
{
   int address = (ah << 8) | al;
   int value = [self ReadByte:address];
   [self TestBit:bit :value];
   [self WriteByte:address :value];
   ticks += 4;
}

- (void) TestBit:(int)bit :(int)a
{
   FZ = (a & (1 << bit)) == 0;
   FN = false;
   FH = true;
   ticks += 8;
}

- (void) CallIfCarry
{
   if (FC)
   {
      [self Call];
   }
   else
   {
      PC += 2;
      ticks++;
   }
}

- (void) CallIfNotCarry
{
   if (FC)
   {
      PC += 2;
      ticks++;
   }
   else
   {
      [self Call];
   }
}

- (void) CallIfZero
{
   if (FZ)
   {
      [self Call];
   }
   else
   {        
      PC += 2;
      ticks++;
   }
}

- (void) CallIfNotZero
{
   if (FZ)
   {
      PC += 2;
      ticks++;
   }
   else
   {
      [self Call];
   }
}

- (void) Interrupt:(int)address
{
   interruptsEnabled = false;
   halted = false;
   [self Push:PC];
   PC = address;      
}

- (void) Restart:(int)address
{
   [self Push:PC];
   PC = address;
}

- (void) Call
{
   [self Push:0xFFFF & (PC + 2)];
   PC = [self ReadWord:PC];
   ticks += 17;
}

- (void) JumpIfCarry
{
   if (FC)
   {
      [self Jump];
   }
   else
   {
      PC += 2;
      ticks++;
   }
}

- (void) JumpIfNotCarry
{
   if (FC)
   {
      PC += 2;
      ticks++;
   }
   else
   {
      [self Jump];
   }
}

- (void) JumpIfZero
{
   if (FZ)
   {
      [self Jump];
   }
   else
   {        
      PC += 2;
      ticks++;
   }
}

- (void) JumpIfNotZero
{
   if (FZ)
   {
      PC += 2;
      ticks++;
   }
   else
   {
      [self Jump];
   }
}

- (void) Jump:(int)ah :(int)al
{
   PC = (ah << 8) | al;
   ticks += 4;
}

- (void) Jump
{
   PC = [self ReadWord:PC];
   ticks += 10;
}

- (void) ReturnIfCarry
{
   if (FC)
   {
      [self Return];
      ticks++;
   }
   else
   {
      ticks += 5;
   }
}

- (void) ReturnIfNotCarry
{
   if (FC)
   {
      ticks += 5;
   }
   else
   {        
      [self Return];
      ticks++;
   }
}

- (void) ReturnIfZero
{
   if (FZ)
{
      [self Return];
      ticks++;
   }
   else
   {
      ticks += 5;
   }
}

- (void) ReturnIfNotZero
{
   if (FZ)
{
      ticks += 5;
   }
   else
   {
      [self Return];
      ticks++;
   }
}

- (void) Return
{
   [self Pop:PC];
}

- (void) Pop:(int &)a
{
   a = [self ReadWord:SP];
   SP += 2;
   ticks += 10;
}

- (void) PopAF
{
   int F = 0;
   [self Pop:A :F];
   FZ = (F & 0x80) == 0x80;
   FC = (F & 0x40) == 0x40;
   FH = (F & 0x20) == 0x20;
   FN = (F & 0x10) == 0x10;
}

- (void) PushAF
{
   int F = 0;
   if (FZ)
   {
      F |= 0x80;
   }
   if (FC)
   {
      F |= 0x40;
   }
   if (FH)
   {
      F |= 0x20;
   }
   if (FN)
   {
      F |= 0x10;
   }
   [self Push:A :F];
}

- (void) Pop:(int &)rh :(int &)rl
{      
   rl = [self ReadByte:SP++];
   rh = [self ReadByte:SP++];
   ticks += 10;
}

- (void) Push:(int)rh :(int)rl
{
   [self WriteByte:--SP :rh];
   [self WriteByte:--SP :rl];
   ticks += 11;
}

- (void) Push:(int)value
{
   SP -= 2;
   [self WriteWord:SP :value];
   ticks += 11;
}

- (void) Or:(int)addressHigh :(int)addressLow
{
   [self Or:[self ReadByte:(addressHigh << 8) | addressLow] ];
   ticks += 3;
}

- (void) Or:(int)b
{
   A = 0xFF & (A | b);
   FH = false;
   FN = false;
   FC = false;
   FZ = A == 0;
   ticks += 4;
}

- (void) OrImmediate
{
   [self Or:[self ReadByte:PC++] ];
   ticks += 3;
}

- (void) XorImmediate
{
   [self Xor:[self ReadByte:PC++]];
}

- (void) Xor:(int)addressHigh :(int)addressLow
{
   [self Xor:[self ReadByte:(addressHigh << 8) | addressLow]];
}

- (void) Xor:(int)b
{
   A = 0xFF & (A ^ b);
   FH = false;
   FN = false;
   FC = false;
   FZ = A == 0;
}

- (void) And:(int)addressHigh :(int)addressLow
{
   [self And:[self ReadByte:(addressHigh << 8) | addressLow]];
   ticks += 3;
}

- (void) AndImmediate
{
   [self And:[self ReadByte:PC++]];
   ticks += 3;
}

- (void) And:(int)b
{
   A = 0xFF & (A & b);
   FH = true;
   FN = false;
   FC = false;
   FZ = A == 0;
   ticks += 4;
}

- (void) SetCarryFlag
{
   FH = false;
   FC = true;
   FN = false;
   ticks += 4;
}

- (void) ComplementCarryFlag
{
   FH = FC;
   FC = !FC;
   FN = false;
   ticks += 4;
}

- (void) LoadImmediateIntoMemory:(int)ah :(int)al
{
   [self WriteByte:(ah << 8) | al :[self ReadByte:PC++]];
   ticks += 10;
}

- (void) ComplementA
{
   A ^= 0xFF;
   FN = true;
   FH = true;
   ticks += 4;
}

- (void) DecimallyAdjustA
{
   int highNibble = A >> 4;
   int lowNibble = A & 0x0F;
   bool _FC = true;
   if (FN)
   {
      if (FC)
      {
         if (FH)
         {
            A += 0x9A;
         }
         else
         {
            A += 0xA0;
         }
      }
      else
      {
         _FC = false;
         if (FH)
         {
            A += 0xFA;
         }
         else
         {
            A += 0x00;
         }
      }
   }
   else if (FC)
   {
      if (FH || lowNibble > 9)
      {
         A += 0x66;
      }
      else
      {
         A += 0x60;
      }
   }
   else if (FH)
   {
      if (highNibble > 9)
      {
         A += 0x66;
      }
      else
      {
         A += 0x06;
         _FC = false;
      }
   }
   else if (lowNibble > 9)
   {
      if (highNibble < 9)
      {
         _FC = false;
         A += 0x06;
      }
      else
      {
         A += 0x66;
      }
   }
   else if (highNibble > 9)
   {
      A += 0x60;
   }
   else
   {
      _FC = false;
   }
   
   A &= 0xFF;
   FC = _FC;
   FZ = A == 0;
   ticks += 4;
}

- (void) JumpRelativeIfNotCarry
{
   if (FC)
   {
      PC++;
      ticks += 7;
   }
   else
   {
      [self JumpRelative];
   }
}

- (void) JumpRelativeIfCarry
{
   if (FC)
   {
      [self JumpRelative];
   }
   else
   {
      PC++;
      ticks += 7;
   }
}

- (void) JumpRelativeIfNotZero
{
   if (FZ)
   {
      PC++;
      ticks += 7;
   }
   else
   {
      [self JumpRelative];
   }
}

- (void) JumpRelativeIfZero
{
   if (FZ)
   {
      [self JumpRelative];
   }
   else
   {
      PC++;
      ticks += 7;
   }
}

- (void) JumpRelative
{
   int relativeAddress = [self ReadByte:PC++];
   if (relativeAddress > 0x7F)
   {
      relativeAddress -= 256;
   }
   PC += relativeAddress;
   ticks += 12;
}

- (void) Add:(int)addressHigh :(int)addressLow
{
   [self Add:[self ReadByte:(addressHigh << 8) | addressLow]];
   ticks += 3;
}

- (void) AddImmediateWithCarry
{
   [self AddWithCarry:[self ReadByte:PC++]];
   ticks += 3;
}

- (void) AddWithCarry:(int)addressHigh :(int)addressLow
{
   [self AddWithCarry:[self ReadByte:(addressHigh << 8) | addressLow]];
   ticks += 3;
}

- (void) AddWithCarry:(int)b
{
   int carry = FC ? 1 : 0;
   FH = carry + (A & 0x0F) + (b & 0x0F) > 0x0F;
   A += b + carry;
   FC = A > 255;
   A &= 0xFF;
   FN = false;
   FZ = A == 0;
   ticks += 4;
}

- (void) SubWithBorrow:(int)ah :(int)al
{
   [self SubWithBorrow:[self ReadByte:(ah << 8) | al]];
   ticks += 3;
}

- (void) SubImmediateWithBorrow
{
   [self SubWithBorrow:[self ReadByte:PC++]];
   ticks += 3;
}

- (void) SubWithBorrow:(int)b
{
   if (FC)
{
      [self Sub:b + 1];
   }
   else
   {
      [self Sub:b];
   }
}

- (void) Sub:(int)ah :(int)al
{
   [self Sub:[self ReadByte:(ah << 8) | al]];
   ticks += 3;
}

- (void) Compare:(int)ah :(int)al
{
   [self Compare:[self ReadByte:(ah << 8) | al]];
   ticks += 3;
}

- (void) CompareImmediate
{
   [self Compare:[self ReadByte:PC++]];
   ticks += 3;
}

- (void) Compare:(int)b
{
   FH = (A & 0x0F) < (b & 0x0F);
   FC = b > A;
   FN = true;
   FZ = A == b;
   ticks += 4;
}

- (void) SubImmediate
{
   [self Sub:[self ReadByte:PC++]];
   ticks += 3;
}

- (void) Sub:(int)b
{
   FH = (A & 0x0F) < (b & 0x0F);
   FC = b > A;
   A -= b;
   A &= 0xFF;
   FN = true;
   FZ = A == 0;
   ticks += 4;
}

- (void) AddImmediate
{
   [self Add:[self ReadByte:PC++]];
   ticks += 3;
}

- (void) Add:(int)b
{
   FH = (A & 0x0F) + (b & 0x0F) > 0x0F;
   A += b;
   FC = A > 255;
   A &= 0xFF;
   FN = false;
   FZ = A == 0;
   ticks += 4;
}

- (void) AddSPToHL
{
   [self Add:H :L :SP >> 8 :SP & 0xFF];
}

- (void) Add:(int &)ah :(int &)al :(int)bh :(int)bl
{      
   al += bl;
   int carry = (al > 0xFF) ? 1 : 0;
   al &= 0xFF;
   FH = carry + (ah & 0x0F) + (bh & 0x0F) > 0x0F;      
   ah += bh + carry;
   FC = ah > 0xFF;
   ah &= 0xFF;
   FN = false;
   ticks += 11;
}

- (void) ShiftLeft:(int)ah :(int)al
{
   int address = (ah << 8) | al;
   int value = [self ReadByte:address];
   [self ShiftLeft:value];
   [self WriteByte:address :value];
   ticks += 7;
}

- (void) ShiftLeft:(int &)a
{
   FC = a > 0x7F;
   a = 0xFF & (a << 1);
   FZ = a == 0;
   FN = false;
   FH = false;
   ticks += 8;
}

- (void) UnsignedShiftRight:(int)ah :(int)al
{
   int address = (ah << 8) | al;
   int value = [self ReadByte:address];
   [self UnsignedShiftRight:value];
   [self WriteByte:address :value];
   ticks += 7;
}

- (void) UnsignedShiftRight:(int &)a
{
   FC = (a & 0x01) == 1;
   a >>= 1;
   FZ = a == 0;
   FN = false;
   FH = false;
   ticks += 8;
}

- (void) SignedShiftRight:(int)ah :(int)al
{
   int address = (ah << 8) | al;
   int value = [self ReadByte:address];
   [self SignedShiftRight:value];
   [self WriteByte:address :value];
   ticks += 7;
}

- (void) SignedShiftRight:(int &)a
{
   FC = (a & 0x01) == 1;
   a = (a & 0x80) | (a >> 1);
   FZ = a == 0;
   FN = false;
   FH = false;
   ticks += 8;
}

- (void) RotateARight
{
   int lowBit = A & 0x01;
   FC = lowBit == 1;
   A = (A >> 1) | (lowBit << 7);
   FN = false;
   FH = false;
   ticks += 4;
}

- (void) RotateARightThroughCarry
{
   int highBit = FC ? 0x80 : 0x00;
   FC = (A & 0x01) == 0x01;
   A = highBit | (A >> 1);
   FN = false;
   FH = false;
   ticks += 4;
}

- (void) RotateALeftThroughCarry
{
   int highBit = FC ? 1 : 0;
   FC = A > 0x7F;
   A = ((A << 1) & 0xFF) | highBit;
   FN = false;
   FH = false;
   ticks += 4;
}

- (void) RotateRight:(int &)a
{
   int lowBit = a & 0x01;
   FC = lowBit == 1;
   a = (a >> 1) | (lowBit << 7);
   FZ = a == 0;
   FN = false;
   FH = false;
   ticks += 8;
}

- (void) RotateRightThroughCarry:(int)ah :(int)al
{
   int address = (ah << 8) | al;
   int value = [self ReadByte:address];
   [self RotateRightThroughCarry:value];
   [self WriteByte:address :value];
   ticks += 7;
}

- (void) RotateRightThroughCarry:(int &)a
{
   int lowBit = FC ? 0x80 : 0;
   FC = (a & 0x01) == 1;
   a = (a >> 1) | lowBit;
   FZ = a == 0;
   FN = false;
   FH = false;
   ticks += 8;
}

- (void) RotateLeftThroughCarry:(int)ah :(int)al
{
   int address = (ah << 8) | al;
   int value = [self ReadByte:address];
   [self RotateLeftThroughCarry:value];
   [self WriteByte:address :value];
   ticks += 7;
}

- (void) RotateLeftThroughCarry:(int &)a
{
   int highBit = FC ? 1 : 0;
   FC = (a >> 7) == 1;
   a = ((a << 1) & 0xFF) | highBit;
   FZ = a == 0;
   FN = false;
   FH = false;
   ticks += 8;
}

- (void) RotateLeft:(int)ah :(int)al
{
   int address = (ah << 8) | al;
   int value = [self ReadByte:address];
   [self RotateLeft:value];
   [self WriteByte:address :value];
   ticks += 7;
}

- (void) RotateRight:(int)ah :(int)al
{
   int address = (ah << 8) | al;
   int value = [self ReadByte:address];
   [self RotateRight:value];
   [self WriteByte:address :value];
   ticks += 7;
}

- (void) RotateLeft:(int &)a
{
   int highBit = a >> 7;
   FC = highBit == 1;
   a = ((a << 1) & 0xFF) | highBit;
   FZ = a == 0;
   FN = false;
   FH = false;
   ticks += 8;
}

- (void) RotateALeft
{ 
   int highBit = A >> 7;
   FC = highBit == 1;
   A = ((A << 1) & 0xFF) | highBit;
   FN = false;
   FH = false;
   ticks += 4;
}

- (void) LoadFromImmediateAddress:(int &)r
{
   r = [self ReadByte:[self ReadWord:PC]];
   PC += 2;
   ticks += 13;
}

- (void) LoadImmediate:(int &)r
{
   r = [self ReadByte:PC++];
   ticks += 7;
}

- (void) LoadImmediateWord:(int &)r
{
   r = [self ReadWord:PC];
   PC += 2;
   ticks += 10;
}

- (void) LoadImmediate:(int &)rh :(int &)rl
{
   rl = [self ReadByte:PC++];
   rh = [self ReadByte:PC++];
   ticks += 10;
}

- (void) ReadByte:(int &)r :(int)ah :(int)al
{
   r = [self ReadByte:(ah << 8) | al];
   ticks += 7;
}

- (void) WriteByte:(int)ah :(int)al :(int)value
{
   [self WriteByte:(ah << 8) | al :value];
   ticks += 7;
}

- (void) WriteWordToImmediateAddress:(int)value
{      
   [self WriteWord:[self ReadWord:PC] :value];   
   PC += 2;
   ticks += 20;
}

- (void) Decrement:(int &)rh :(int &)rl
{
   if (rl == 0)
   {
      rh = 0xFF & (rh - 1);
      rl = 0xFF;
   }
   else
   {
      rl--;
   }
   ticks += 6;
}

- (void) IncrementWord:(int &)r
{
   if (r == 0xFFFF)
   {
      r = 0;
   }
   else
   {
      r++;
   }
   ticks += 6;
}

- (void) DecrementWord:(int &)r
{
   if (r == 0)
   {
      r = 0xFFFF;
   }
   else
   {
      r--;
   }
   ticks += 6;
}

- (void) DecrementMemory:(int)ah :(int)al
{
   int address = (ah << 8) | al;
   int r = [self ReadByte:address];
   [self Decrement:r];
   [self WriteByte:address :r];
   ticks += 7;
}

- (void) IncrementMemory:(int)ah :(int)al
{
   int address = (ah << 8) | al;
   int r = [self ReadByte:address];
   [self Increment:r];
   [self WriteByte:address :r];
   ticks += 7;
}

- (void) Increment:(int &)rh :(int &)rl
{
   if (rl == 255)
   {
      rh = 0xFF & (rh + 1);
      rl = 0;
   }
   else
   {
      rl++;
   }
   ticks += 6;
}

- (void) Increment:(int &)r
{
   FH = (r & 0x0F) == 0x0F;
   r++;
   r &= 0xFF;
   FZ = r == 0;
   FN = false;
   ticks += 4;
}

- (void) Decrement:(int &)r
{
   FH = (r & 0x0F) == 0x00;
   r--;
   r &= 0xFF;
   FZ = r == 0;
   FN = true;
   ticks += 4;
}

- (void) PowerUp
{
   A = 0x01;
   B = 0x00;
   C = 0x13;
   D = 0x00;
   E = 0xD8;
   H = 0x01;
   L = 0x4D;
   FZ = true;
   FC = false;
   FH = true;
   FN = true;
   SP = 0xFFFE;
   PC = 0x0100;
   
   [self WriteByte:0xFF05 :0x00]; // TIMA
   [self WriteByte:0xFF06 :0x00]; // TMA
   [self WriteByte:0xFF07 :0x00]; // TAC
   [self WriteByte:0xFF10 :0x80]; // NR10
   [self WriteByte:0xFF11 :0xBF]; // NR11
   [self WriteByte:0xFF12 :0xF3]; // NR12
   [self WriteByte:0xFF14 :0xBF]; // NR14
   [self WriteByte:0xFF16 :0x3F]; // NR21
   [self WriteByte:0xFF17 :0x00]; // NR22
   [self WriteByte:0xFF19 :0xBF]; // NR24
   [self WriteByte:0xFF1A :0x7F]; // NR30
   [self WriteByte:0xFF1B :0xFF]; // NR31
   [self WriteByte:0xFF1C :0x9F]; // NR32
   [self WriteByte:0xFF1E :0xBF]; // NR33
   [self WriteByte:0xFF20 :0xFF]; // NR41
   [self WriteByte:0xFF21 :0x00]; // NR42
   [self WriteByte:0xFF22 :0x00]; // NR43
   [self WriteByte:0xFF23 :0xBF]; // NR30
   [self WriteByte:0xFF24 :0x77]; // NR50
   [self WriteByte:0xFF25 :0xF3]; // NR51
   [self WriteByte:0xFF26 :0xF1]; // NR52
   [self WriteByte:0xFF40 :0x91]; // LCDC
   [self WriteByte:0xFF42 :0x00]; // SCY
   [self WriteByte:0xFF43 :0x00]; // SCX
   [self WriteByte:0xFF45 :0x00]; // LYC
   [self WriteByte:0xFF47 :0xFC]; // BGP
   [self WriteByte:0xFF48 :0xFF]; // OBP0
   [self WriteByte:0xFF49 :0xFF]; // OBP1
   [self WriteByte:0xFF4A :0x00]; // WY
   [self WriteByte:0xFF4B :0x00]; // WX
   [self WriteByte:0xFFFF :0x00]; // IE
   
   running = true;
}

- (void) WriteWord:(int)address :(int)value
{
   [self WriteByte:address :value & 0xFF];
   [self WriteByte:address + 1 :value >> 8];
}

- (int) ReadWord:(int)address
{
   int low = [self ReadByte:address];
   int high = [self ReadByte:address + 1];
   return (high << 8) | low;
}

- (void) WriteByte:(int)address :(int)value
{      
   if (address >= 0xC000 && address <= 0xDFFF)
   {
      workRam[address - 0xC000] = (Byte)value;
   }
   else if (address >= 0xFE00 && address <= 0xFEFF)
   {
      oam[address - 0xFE00] = (Byte)value;
   }
   else if (address >= 0xFF80 && address <= 0xFFFE)
   {
      highRam[0xFF & address] = (Byte)value;
   }
   else if (address >= 0x8000 && address <= 0x9FFF)
   {
      int videoRamIndex = address - 0x8000;
      videoRam[videoRamIndex] = (Byte)value;
      if (address < 0x9000)
      {
         spriteTileInvalidated[videoRamIndex >> 4] = true;
      }
      if (address < 0x9800)
      {
         invalidateAllBackgroundTilesRequest = true;
      }
      else if (address >= 0x9C00)
      {
         int tileIndex = address - 0x9C00;
         backgroundTileInvalidated[tileIndex >> 5][tileIndex & 0x1F] = true;
      }
      else
      {
         int tileIndex = address - 0x9800;
         backgroundTileInvalidated[tileIndex >> 5][tileIndex & 0x1F] = true;
      }
   }
   else if (address <= 0x7FFF || (address >= 0xA000 && address <= 0xBFFF))
   {
      cartridge->writeByte(address, value);
   }
   else if (address >= 0xE000 && address <= 0xFDFF)
   {
      workRam[address - 0xE000] = (Byte)value;
   }
   else
   { 
      switch (address)
      {
         case 0xFF00: // key pad
            keyP14 = (value & 0x10) != 0x10;
            keyP15 = (value & 0x20) != 0x20;
            break;
         case 0xFF04: // Timer divider            
            break;
         case 0xFF05: // Timer counter
            timerCounter = value;
            break;
         case 0xFF06: // Timer modulo
            timerModulo = value;
            break;
         case 0xFF07:  // Time Control
            timerRunning = (value & 0x04) == 0x04;
            timerFrequency = (TimerFrequencyType)(0x03 & value);
            break;
         case 0xFF0F: // Interrupt Flag (an interrupt request)
            keyPressedInterruptRequested = (value & 0x10) == 0x10;
            serialIOTransferCompleteInterruptRequested = (value & 0x08) == 0x08;
            timerOverflowInterruptRequested = (value & 0x04) == 0x04;
            lcdcInterruptRequested = (value & 0x02) == 0x02;
            vBlankInterruptRequested = (value & 0x01) == 0x01;
            break;
         case 0xFF40: // LCDC control
         {
            bool _backgroundAndWindowTileDataSelect = backgroundAndWindowTileDataSelect;
            bool _backgroundTileMapDisplaySelect = backgroundTileMapDisplaySelect;
            bool _windowTileMapDisplaySelect = windowTileMapDisplaySelect;
            
            lcdControlOperationEnabled = (value & 0x80) == 0x80;
            windowTileMapDisplaySelect = (value & 0x40) == 0x40;
            windowDisplayed = (value & 0x20) == 0x20;
            backgroundAndWindowTileDataSelect = (value & 0x10) == 0x10;
            backgroundTileMapDisplaySelect = (value & 0x08) == 0x08;
            largeSprites = (value & 0x04) == 0x04;
            spritesDisplayed = (value & 0x02) == 0x02;
            backgroundDisplayed = (value & 0x01) == 0x01;
            
            if (_backgroundAndWindowTileDataSelect != backgroundAndWindowTileDataSelect
                || _backgroundTileMapDisplaySelect != backgroundTileMapDisplaySelect
                || _windowTileMapDisplaySelect != windowTileMapDisplaySelect)
            {
               invalidateAllBackgroundTilesRequest = true;
            }
            
            break;
         }
         case 0xFF41: // LCDC Status
            lcdcLycLyCoincidenceInterruptEnabled = (value & 0x40) == 0x40;
            lcdcOamInterruptEnabled = (value & 0x20) == 0x20;
            lcdcVBlankInterruptEnabled = (value & 0x10) == 0x10;
            lcdcHBlankInterruptEnabled = (value & 0x08) == 0x08;
            lcdcMode = (LcdcModeType)(value & 0x03);
            break;
         case 0xFF42: // Scroll Y;
            scrollY = value;
            break;
         case 0xFF43: // Scroll X;
            scrollX = value;
            break;
         case 0xFF44: // LY
            ly = value;
            break;
         case 0xFF45: // LY Compare
            lyCompare = value;
            break;
         case 0xFF46: // Memory Transfer
            value <<= 8;
            for(int i = 0; i < 0x8C; i++)
            {
               [self WriteByte:(0xFE00 | i) :[self ReadByte:(value | i)]];
            }
            break;
         case 0xFF47: // Background palette
//            NSLog(@"[0xFF47] = %x", value);
            for(int i = 0; i < 4; i++)
            {
               switch(value & 0x03)
               {
                  case 0:
                     backgroundPalette[i] = WHITE;
                     break;
                  case 1:
                     backgroundPalette[i] = LIGHT_GRAY;
                     break;
                  case 2:
                     backgroundPalette[i] = DARK_GRAY;
                     break;
                  case 3:
                     backgroundPalette[i] = BLACK;
                     break;
               }
               value >>= 2;
            }
            invalidateAllBackgroundTilesRequest = true;
            break;
         case 0xFF48: // Object palette 0
            for (int i = 0; i < 4; i++)
            {
               switch (value & 0x03)
               {
                  case 0:
                     objectPalette0[i] = WHITE;
                     break;
                  case 1:
                     objectPalette0[i] = LIGHT_GRAY;
                     break;
                  case 2:
                     objectPalette0[i] = DARK_GRAY;
                     break;
                  case 3:
                     objectPalette0[i] = BLACK;
                     break;
               }
               value >>= 2;
            }
            invalidateAllSpriteTilesRequest = true;
            break;
         case 0xFF49: // Object palette 1
            for (int i = 0; i < 4; i++)
            {
               switch (value & 0x03)
               {
                  case 0:
                     objectPalette1[i] = WHITE;
                     break;
                  case 1:
                     objectPalette1[i] = LIGHT_GRAY;
                     break;
                  case 2:
                     objectPalette1[i] = DARK_GRAY;
                     break;
                  case 3:
                     objectPalette1[i] = BLACK;
                     break;
               }
               value >>= 2;
            }
            invalidateAllSpriteTilesRequest = true;
            break;
         case 0xFF4A: // Window Y
            windowY = value;
            break;
         case 0xFF4B: // Window X
            windowX = value;
            break;
         case 0xFFFF: // Interrupt Enable
            keyPressedInterruptEnabled = (value & 0x10) == 0x10;
            serialIOTransferCompleteInterruptEnabled = (value & 0x08) == 0x08;
            timerOverflowInterruptEnabled = (value & 0x04) == 0x04;
            lcdcInterruptEnabled = (value & 0x02) == 0x02;
            vBlankInterruptEnabled = (value & 0x01) == 0x01;
            break;
         
         // Audio //
            
         case 0xFF10:
         case 0xFF11:
         case 0xFF12:
         case 0xFF13:
         case 0xFF14:
//            NSLog(@"Sound - Channel 1");
//            [apu writeByte:value toAPUFromCPUAddress:address onCycle:cycle];
            apu->writeByte(value, address, cycle);
            break;
            
         case 0xFF16:
         case 0xFF17:
         case 0xFF19:
//            NSLog(@"Sound - Channel 2");
//            [apu writeByte:value toAPUFromCPUAddress:address onCycle:cycle];
            apu->writeByte(value, address, cycle);
            break;
            
         case 0xFF1A:
         case 0xFF1B:
         case 0xFF1C:
         case 0xFF1D:
         case 0xFF1E:
         //case FF30 - FF3F
//            NSLog(@"Sound - Channel 3");
//            [apu writeByte:value toAPUFromCPUAddress:address onCycle:cycle];
            apu->writeByte(value, address, cycle);
            break;
            
         case 0xFF20:
         case 0xFF21:
         case 0xFF22:
         case 0xFF23:
//            NSLog(@"Sound - Channel 4");
//            [apu writeByte:value toAPUFromCPUAddress:address onCycle:cycle];
            apu->writeByte(value, address, cycle);
            break;
            
         case 0xFF24:
         case 0xFF25:
         case 0xFF26:
//            NSLog(@"Sound - Control Registers");
//            [apu writeByte:value toAPUFromCPUAddress:address onCycle:cycle];
            apu->writeByte(value, address, cycle);
            break;
      }
   }
}

- (int) ReadByte:(int)address
{
   if (address <= 0x7FFF || (address >= 0xA000 && address <= 0xBFFF))
   {
//      return [cartridge ReadByte:address];
      return cartridge->readByte(address);
   }
   else if (address >= 0x8000 && address <= 0x9FFF)
   {
      return videoRam[address - 0x8000];
   }
   else if (address >= 0xC000 && address <= 0xDFFF)
   {
      return workRam[address - 0xC000];
   }
   else if (address >= 0xE000 && address <= 0xFDFF)
   {
      return workRam[address - 0xE000];
   }
   else if (address >= 0xFE00 && address <= 0xFEFF)
   {
      return oam[address - 0xFE00];
   }
   else if (address >= 0xFF80 && address <= 0xFFFE)
   {
      return highRam[0xFF & address];
   }
   else
   { 
      switch (address)
      {
         case 0xFF00: // key pad
            if (keyP14)
            {
               int value = 0;
               if (!downKeyPressed)
               {
                  value |= 0x08;
               }
               if (!upKeyPressed)
               {
                  value |= 0x04;
               }
               if (!leftKeyPressed)
               {
                  value |= 0x02;
               }
               if (!rightKeyPressed)
               {
                  value |= 0x01;
               }
               return value;
            }
            else if (keyP15)
            {
               int value = 0;
               if (!startButtonPressed)
               {
                  value |= 0x08;
               }
               if (!selectButtonPressed)
               {
                  value |= 0x04;
               }
               if (!bButtonPressed)
               {
                  value |= 0x02;
               }
               if (!aButtonPressed)
               {
                  value |= 0x01;
               }
               return value;
            } 
            break;
         case 0xFF04: // Timer divider
            return ticks & 0xFF;
         case 0xFF05: // Timer counter
            return timerCounter & 0xFF;
         case 0xFF06: // Timer modulo
            return timerModulo & 0xFF;
         case 0xFF07: // Time Control
         {
            int value = 0;
            if (timerRunning)
            {
               value |= 0x04;
            }
            value |= (int)timerFrequency;
            return value;
         }
         case 0xFF0F: // Interrupt Flag (an interrupt request)
         {
            int value = 0;
            if (keyPressedInterruptRequested)
            {
               value |= 0x10;
            }
            if (serialIOTransferCompleteInterruptRequested)
            {
               value |= 0x08;
            }
            if (timerOverflowInterruptRequested)
            {
               value |= 0x04;
            }
            if (lcdcInterruptRequested)
            {
               value |= 0x02;
            }
            if (vBlankInterruptRequested)
            {
               value |= 0x01;
            }
            return value;
         }
         case 0xFF40: // LCDC control
         {
            int value = 0;
            if (lcdControlOperationEnabled)
            {
               value |= 0x80;
            }
            if (windowTileMapDisplaySelect)
            {
               value |= 0x40;
            }
            if (windowDisplayed)
            {
               value |= 0x20;
            }
            if (backgroundAndWindowTileDataSelect)
            {
               value |= 0x10;
            }
            if (backgroundTileMapDisplaySelect)
            {
               value |= 0x08;
            }
            if (largeSprites)
            {
               value |= 0x04;
            }
            if (spritesDisplayed)
            {
               value |= 0x02;
            }
            if (backgroundDisplayed)
            {
               value |= 0x01;
            }
            return value;
         }
         case 0xFF41: // LCDC Status
         {
            int value = 0;
            if (lcdcLycLyCoincidenceInterruptEnabled)
            {
               value |= 0x40;
            }
            if (lcdcOamInterruptEnabled)
            {
               value |= 0x20;
            }
            if (lcdcVBlankInterruptEnabled)
            {
               value |= 0x10;
            }
            if (lcdcHBlankInterruptEnabled)
            {
               value |= 0x08;
            }
            if (ly == lyCompare)
            {
               value |= 0x04;
            }
            value |= (int)lcdcMode;
            return value;
         }
         case 0xFF42: // Scroll Y
            return scrollY;
         case 0xFF43: // Scroll X
            return scrollX;
         case 0xFF44: // LY
            return ly;
         case 0xFF45: // LY Compare
            return lyCompare;
         case 0xFF47: // Background palette
         {
            invalidateAllBackgroundTilesRequest = true;
            int value = 0;
            for (int i = 3; i >= 0; i--)
            {
               value <<= 2;
               switch (backgroundPalette[i])
               {
                  case BLACK:
                     value |= 3;
                     break;
                  case DARK_GRAY:
                     value |= 2;
                     break;
                  case LIGHT_GRAY:
                     value |= 1;
                     break;
                  case WHITE:
                     break;
               }              
            }
            return value;
         }
         case 0xFF48: // Object palette 0
         {
            invalidateAllSpriteTilesRequest = true;
            int value = 0;
            for (int i = 3; i >= 0; i--)
            {
               value <<= 2;
               switch (objectPalette0[i])
               {
                  case BLACK:
                     value |= 3;
                     break;
                  case DARK_GRAY:
                     value |= 2;
                     break;
                  case LIGHT_GRAY:
                     value |= 1;
                     break;
                  case WHITE:
                     break;
               }
            }
            return value;
         }
         case 0xFF49: // Object palette 1
         {
            invalidateAllSpriteTilesRequest = true;
            int value = 0;
            for (int i = 3; i >= 0; i--)
            {
               value <<= 2;
               switch (objectPalette1[i])
               {
                  case BLACK:
                     value |= 3;
                     break;
                  case DARK_GRAY:
                     value |= 2;
                     break;
                  case LIGHT_GRAY:
                     value |= 1;
                     break;
                  case WHITE:
                     break;
               }
            }
            return value;
         }
         case 0xFF4A: // Window Y
            return windowY;
         case 0xFF4B: // Window X
            return windowX;
         case 0xFFFF: // Interrupt Enable
         {
            int value = 0;
            if (keyPressedInterruptEnabled)
            {
               value |= 0x10;
            }
            if (serialIOTransferCompleteInterruptEnabled)
            {
               value |= 0x08;
            }
            if (timerOverflowInterruptEnabled)
            {
               value |= 0x04;
            }
            if (lcdcInterruptEnabled)
            {
               value |= 0x02;
            }
            if (vBlankInterruptEnabled)
            {
               value |= 0x01;
            }
            return value;
         }
      }
   }
   return 0;
}

- (void) KeyChanged:(Keys)keyCode :(bool)pressed
{
   switch (keyCode)
   {
      case KeyB:
         bButtonPressed = pressed;
         break;
      case KeyA:
         aButtonPressed = pressed;
         break;
      case Start:
         startButtonPressed = pressed;
         break;
      case Select:
         selectButtonPressed = pressed;
         break;
      case ArrowUp:
         upKeyPressed = pressed;
         break;
      case ArrowDown:
         downKeyPressed = pressed;
         break;
      case ArrowLeft:
         leftKeyPressed = pressed;
         break;
      case ArrowRight:
         rightKeyPressed = pressed;
         break;
      default:
         break;
   }
   
   if (keyPressedInterruptEnabled)
   {
      keyPressedInterruptRequested = true;
   }
}

- (NSString *) description
{
   return @"CPU Description";
//   return String.Format(
//                        "PC={8:X} A={0:X} B={1:X} C={2:X} D={3:X} E={4:X} H={5:X} L={6:X} halted={7} SP={9:X} FZ={10} FH={11} FC={12} FN={13} IV={14} IL={15} IK={16} IT={17} INT={18} scrollX={19} scrollY={20} ly={21} lyCompare={22} LHIE={23} LYIE={24} LOIE={25}" :
//                        A :B :C :D :E :H :L :halted :PC :SP :FZ :FH :FC :FN :vBlankInterruptEnabled :lcdcInterruptEnabled :keyPressedInterruptEnabled :
//                        timerOverflowInterruptEnabled :interruptsEnabled :scrollX :scrollY :ly :lyCompare,
//                        lcdcHBlankInterruptEnabled :lcdcLycLyCoincidenceInterruptEnabled :lcdcOamInterruptEnabled]; 
}

- (void) CheckForBadState
{
//   if (A > 0xFF || A < 0 || B > 0xFF || B < 0 || C > 0xFF || C < 0 || D > 0xFF || D < 0 
//       || E > 0xFF || E < 0 || H > 0xFF || H < 0 || SP > 0xFFFF || SP < 0 || PC > 0xFFFF || PC < 0)
//   {
//      throw new Exception(ToString);
//   }
   
   NSLog(@"CPU: CheckForBadState");
}


- (void) UpdateSpriteTiles
{
   
   for (int i = 0; i < 256; i++)
   {
      if (spriteTileInvalidated[i] || invalidateAllSpriteTilesRequest)
      {
         spriteTileInvalidated[i] = false;
         int address = i << 4;
         for (int y = 0; y < 8; y++)
         {
            int lowByte = videoRam[address++];
            int highByte = videoRam[address++] << 1;
            for (int x = 7; x >= 0; x--)
            {
               int paletteIndex = (0x02 & highByte) | (0x01 & lowByte);
               lowByte >>= 1;
               highByte >>= 1;
               if (paletteIndex > 0)
               {
                  spriteTile[i][y][x][0] = objectPalette0[paletteIndex];
                  spriteTile[i][y][x][1] = objectPalette1[paletteIndex];
               }
               else
               {
                  spriteTile[i][y][x][0] = 0;
                  spriteTile[i][y][x][1] = 0;
               }
            }
         }
      }
   }
   
   invalidateAllSpriteTilesRequest = false;
}

- (void) UpdateWindow
{
   int tileMapAddress = windowTileMapDisplaySelect ? 0x1C00 : 0x1800;
   
   if (backgroundAndWindowTileDataSelect)
   {
      for (int i = 0; i < 18; i++)
      {
         for (int j = 0; j < 21; j++)
         {
            if (backgroundTileInvalidated[i][j] || invalidateAllBackgroundTilesRequest)
            {
               int tileDataAddress = videoRam[tileMapAddress + ((i << 5) | j)] << 4;
               int y = i << 3;
               int x = j << 3;
               for (int k = 0; k < 8; k++)
               {
                  int lowByte = videoRam[tileDataAddress++];
                  int highByte = videoRam[tileDataAddress++] << 1;
                  for (int b = 7; b >= 0; b--)
                  {
                     windowBuffer[y + k][x + b] = backgroundPalette[(0x02 & highByte) | (0x01 & lowByte)];
                     lowByte >>= 1;
                     highByte >>= 1;
                  }
               }
            }
         }
      }
   }
   else
   {
      for (int i = 0; i < 18; i++)
      {
         for (int j = 0; j < 21; j++)
         {
            if (backgroundTileInvalidated[i][j] || invalidateAllBackgroundTilesRequest)
            {
               int tileDataAddress = videoRam[tileMapAddress + ((i << 5) | j)];
               if (tileDataAddress > 127)
               {
                  tileDataAddress -= 256;
               }
               tileDataAddress = 0x1000 + (tileDataAddress << 4);
               int y = i << 3;
               int x = j << 3;
               for (int k = 0; k < 8; k++)
               {
                  int lowByte = videoRam[tileDataAddress++];
                  int highByte = videoRam[tileDataAddress++] << 1;
                  for (int b = 7; b >= 0; b--)
                  {
                     windowBuffer[y + k][x + b] = backgroundPalette[(0x02 & highByte) | (0x01 & lowByte)];
                     lowByte >>= 1;
                     highByte >>= 1;
                  }
               }
            }
         }
      }
   }
}

- (void) UpdateBackground
{
   int tileMapAddress = backgroundTileMapDisplaySelect ? 0x1C00 : 0x1800;
   
   if (backgroundAndWindowTileDataSelect)
   {
      for (int i = 0; i < 32; i++)
      {
         for (int j = 0; j < 32; j++, tileMapAddress++)
         {
            if (backgroundTileInvalidated[i][j] || invalidateAllBackgroundTilesRequest)
            {
               backgroundTileInvalidated[i][j] = false;
               int tileDataAddress = videoRam[tileMapAddress] << 4;
               int y = i << 3;
               int x = j << 3;
               for (int k = 0; k < 8; k++)
               {
                  int lowByte = videoRam[tileDataAddress++];
                  int highByte = videoRam[tileDataAddress++] << 1;
                  for (int b = 7; b >= 0; b--)
                  {
                     backgroundBuffer[y + k][x + b] = backgroundPalette[(0x02 & highByte) | (0x01 & lowByte)];
                     lowByte >>= 1;
                     highByte >>= 1;
                  }
               }
            }
         }
      }
   }
   else
   {
      for (int i = 0; i < 32; i++)
      {
         for (int j = 0; j < 32; j++, tileMapAddress++)
         {
            if (backgroundTileInvalidated[i][j] || invalidateAllBackgroundTilesRequest)
            {
               backgroundTileInvalidated[i][j] = false;
               int tileDataAddress = videoRam[tileMapAddress];
               if (tileDataAddress > 127)
               {
                  tileDataAddress -= 256;
               }
               tileDataAddress = 0x1000 + (tileDataAddress << 4);
               int y = i << 3;
               int x = j << 3;
               for (int k = 0; k < 8; k++)
               {
                  int lowByte = videoRam[tileDataAddress++];
                  int highByte = videoRam[tileDataAddress++] << 1;
                  for (int b = 7; b >= 0; b--)
                  {
                     backgroundBuffer[y + k][x + b] = backgroundPalette[(0x02 & highByte) | (0x01 & lowByte)];
                     lowByte >>= 1;
                     highByte >>= 1;
                  }
               }
            }
         }
      }
   }
   
   invalidateAllBackgroundTilesRequest = false;
}



@end
