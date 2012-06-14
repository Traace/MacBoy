//
//  AppDelegate.m
//  MacBoy
//
//  Created by Tom Schroeder on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   // Insert code here to initialize your application
   
   //   cpu = [[CPU alloc] init];
   //   cpu = nil;
   
   [self InitFrame];
   
   for (int i = 0; i < 160 * 144; i++)
      pixels[i] = 0xFF000000;
   
   //   [NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];  
   
   //   [NSThread detachNewThreadSelector:@selector(go) toTarget:self withObject:nil];  
   
   //   romLoader = [[ROMLoader alloc] init];
   //   //      game = romLoader.Load(fileName);
   //   //      game = [romLoader Load:[[romFile filePathURL] absoluteString]];
   //   game = [romLoader Load:nil];
   //   //      x80 = new X80();
   //   cpu = [[CPU alloc] init];
   ////   cpu->cartridge = game->cartridge;
   //   [cpu setCartridge:game->cartridge];
   //   //      cpu->PowerUp();
   //   [cpu PowerUp];
   
   [self loadFile:nil];
   
   [NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];  
}

//- (void) go
//{
//   romLoader = [[ROMLoader alloc] init];
//   //      game = romLoader.Load(fileName);
//   //      game = [romLoader Load:[[romFile filePathURL] absoluteString]];
//   game = [romLoader Load:nil];
//   //      x80 = new X80();
//   cpu = [[CPU alloc] init];
//   cpu->cartridge = game->cartridge;
//   //      cpu->PowerUp();
//   [cpu PowerUp];
//}

- (IBAction)loadFile:(id)sender
{
   NSString * romPath = @"/Users/tomschroeder/Stuff/Roms/Gameboy/SuperMarioLand2.gb";
   NSFileHandle * file = [NSFileHandle fileHandleForReadingAtPath: romPath];
   
   if (file == nil)
      NSLog(@"ERROR: Failed to open file");
   
   romData = [file readDataToEndOfFile];
   
   game = [[Game alloc] initWithData:romData];
   
   //   int x = 1;
   
   //   [cpu setCartridge:game->cartridge];
   id<Cartridge> cartridge = [[MBC1 alloc] initWithData:romData :game->romType :game->romSize :game->romBanks];
   [cpu setCartridge:cartridge];
   [cpu PowerUp];
}

- (void) run
{
   for (;;)
   {
      if (cpu != nil && cpu->running)
      {
         //         NSLog(@"run true");
         [self UpdateModel:true];
         //         [self UpdateModel:false];
         [self RenderFrame];
         //         [NSThread sleepForTimeInterval:0.0016667];
      }
   }
}

/*
 public GameForm() {
 InitializeComponent();
 InitFrame();
 }
 
 private void OnApplicationIdle(object sender, EventArgs e) {
 if (x80 == null || !Focused) {
 return;
 }
 PeekMsg msg;
 while (!PeekMessage(out msg, IntPtr.Zero, 0, 0, 0)) {
 int updates = 0;
 bool updateBitmap = true;          
 do {
 UpdateModel(updateBitmap);
 updateBitmap = false;
 nextFrameStart += TICKS_PER_FRAME;
 } while (nextFrameStart < stopwatch.ElapsedTicks && ++updates < MAX_FRAMES_SKIPPED);
 RenderFrame();       
 long remainingTicks = nextFrameStart - stopwatch.ElapsedTicks;
 if (remainingTicks > 0) {
 Thread.Sleep((int)(1000 * remainingTicks / FREQUENCY));
 } else if (updates == MAX_FRAMES_SKIPPED) {
 nextFrameStart = stopwatch.ElapsedTicks;
 }
 }
 }
 
 */

- (void) UpdateModel:(bool)updateBitmap
{
   //   NSLog(@"%@", NSStringFromSelector(_cmd));
   
   if (updateBitmap)
   {
      //      uint[] backgroundPalette = cpu->backgroundPalette;
      //      uint[] objectPalette0 = cpu->objectPalette0;
      //      uint[] objectPalette1 = cpu->objectPalette1;
      //      uint[,] backgroundBuffer = cpu->backgroundBuffer;
      //      uint[,] windowBuffer = cpu->windowBuffer;
      //      byte[] oam = cpu->oam;
      
      for (int y = 0, pixelIndex = 0; y < 144; y++) {
         
         cpu->ly = y;
         cpu->lcdcMode = SearchingOamRam;
         if (cpu->lcdcInterruptEnabled 
             && (cpu->lcdcOamInterruptEnabled 
                 || (cpu->lcdcLycLyCoincidenceInterruptEnabled && cpu->lyCompare == y))) {
                cpu->lcdcInterruptRequested = true;
             }
         //         ExecuteProcessor(800);
         [self ExecuteProcessor:800];
         cpu->lcdcMode = TransferingData;
         //         ExecuteProcessor(1720);
         [self ExecuteProcessor:1720];
         
         //         cpu->UpdateWindow();
         //         cpu->UpdateBackground();
         //         cpu->UpdateSpriteTiles();
         
         [cpu UpdateWindow];
         [cpu UpdateBackground];
         [cpu UpdateSpriteTiles];
         
         bool backgroundDisplayed = cpu->backgroundDisplayed;
         bool backgroundAndWindowTileDataSelect = cpu->backgroundAndWindowTileDataSelect;
         bool backgroundTileMapDisplaySelect = cpu->backgroundTileMapDisplaySelect;
         int scrollX = cpu->scrollX;
         int scrollY = cpu->scrollY;
         bool windowDisplayed = cpu->windowDisplayed;
         bool windowTileMapDisplaySelect = cpu->windowTileMapDisplaySelect;
         int windowX = cpu->windowX - 7;
         int windowY = cpu->windowY;
         
         int windowPointY = windowY + y;
         
         for (int x = 0; x < 160; x++, pixelIndex++)
         {
            
            uint intensity = 0;
            
            if (backgroundDisplayed)
            {
               intensity = cpu->backgroundBuffer[0xFF & (scrollY + y)][0xFF & (scrollX + x)];
            }
            
            if (windowDisplayed && y >= windowY && y < windowY + 144 && x >= windowX && x < windowX + 160
                && windowX >= -7 && windowX <= 159 && windowY >= 0 && windowY <= 143) {
               intensity = cpu->windowBuffer[y - windowY][x - windowX];
            }
            
            pixels[pixelIndex] = intensity;
         }
         
         if (cpu->spritesDisplayed)
         {
            //            uint[, , ,] spriteTile = cpu->spriteTile;
            if (cpu->largeSprites) {
               for (int address = 0; address < 160; address += 4) {
                  int spriteY = cpu->oam[address];
                  int spriteX = cpu->oam[address + 1];
                  if (spriteY == 0 || spriteX == 0 || spriteY >= 160 || spriteX >= 168) {
                     continue;
                  }
                  spriteY -= 16;
                  if (spriteY > y || spriteY + 15 < y) {
                     continue;
                  }
                  spriteX -= 8;
                  
                  int spriteTileIndex0 = 0xFE & cpu->oam[address + 2];
                  int spriteTileIndex1 = spriteTileIndex0 | 0x01;
                  int spriteFlags = cpu->oam[address + 3];
                  bool spritePriority = (0x80 & spriteFlags) == 0x80;
                  bool spriteYFlipped = (0x40 & spriteFlags) == 0x40;
                  bool spriteXFlipped = (0x20 & spriteFlags) == 0x20;
                  int spritePalette = (0x10 & spriteFlags) == 0x10 ? 1 : 0;
                  
                  if (spriteYFlipped)
                  {
                     int temp = spriteTileIndex0;
                     spriteTileIndex0 = spriteTileIndex1;
                     spriteTileIndex1 = temp;
                  }
                  
                  int spriteRow = y - spriteY;
                  if (spriteRow >= 0 && spriteRow < 8)
                  {
                     int screenAddress = (y << 7) + (y << 5) + spriteX;
                     for (int x = 0; x < 8; x++, screenAddress++)
                     {
                        int screenX = spriteX + x;
                        if (screenX >= 0 && screenX < 160)
                        {
                           uint color = cpu->spriteTile[spriteTileIndex0]
                           [spriteYFlipped ? 7 - spriteRow : spriteRow]
                           [spriteXFlipped ? 7 - x : x]
                           [spritePalette];
                           if (color > 0)
                           {
                              if (spritePriority)
                              {
                                 if (pixels[screenAddress] == 0xFFFFFFFF)
                                 {
                                    pixels[screenAddress] = color;
                                 }
                              }
                              else
                              {
                                 pixels[screenAddress] = color;
                              }
                           }
                        }
                     }
                     continue;
                  }
                  
                  spriteY += 8;
                  
                  spriteRow = y - spriteY;
                  if (spriteRow >= 0 && spriteRow < 8)
                  {
                     int screenAddress = (y << 7) + (y << 5) + spriteX;
                     for (int x = 0; x < 8; x++, screenAddress++)
                     {
                        int screenX = spriteX + x;
                        if (screenX >= 0 && screenX < 160)
                        {
                           uint color = cpu->spriteTile[spriteTileIndex1]
                           [spriteYFlipped ? 7 - spriteRow : spriteRow]
                           [spriteXFlipped ? 7 - x : x]
                           [spritePalette];
                           if (color > 0)
                           {
                              if (spritePriority)
                              {
                                 if (pixels[screenAddress] == 0xFFFFFFFF)
                                 {
                                    pixels[screenAddress] = color;
                                 }
                              }
                              else
                              {
                                 pixels[screenAddress] = color;
                              }
                           }
                        }
                     }
                  }
               }
            }
            else
            {
               for (int address = 0; address < 160; address += 4)
               {
                  int spriteY = cpu->oam[address];
                  int spriteX = cpu->oam[address + 1];
                  if (spriteY == 0 || spriteX == 0 || spriteY >= 160 || spriteX >= 168)
                  {
                     continue;
                  }
                  spriteY -= 16;
                  if (spriteY > y || spriteY + 7 < y)
                  {
                     continue;
                  }
                  spriteX -= 8;
                  
                  int spriteTileIndex = cpu->oam[address + 2];
                  int spriteFlags = cpu->oam[address + 3];
                  bool spritePriority = (0x80 & spriteFlags) == 0x80;
                  bool spriteYFlipped = (0x40 & spriteFlags) == 0x40;
                  bool spriteXFlipped = (0x20 & spriteFlags) == 0x20;
                  int spritePalette = (0x10 & spriteFlags) == 0x10 ? 1 : 0;
                  
                  int spriteRow = y - spriteY;
                  int screenAddress = (y << 7) + (y << 5) + spriteX;
                  for (int x = 0; x < 8; x++, screenAddress++)
                  {
                     int screenX = spriteX + x;
                     if (screenX >= 0 && screenX < 160)
                     {
                        uint color = cpu->spriteTile[spriteTileIndex]
                        [spriteYFlipped ? 7 - spriteRow : spriteRow] 
                        [spriteXFlipped ? 7 - x : x]
                        [spritePalette];
                        if (color > 0)
                        {
                           if (spritePriority)
                           {
                              if (pixels[screenAddress] == 0xFFFFFFFF)
                              {
                                 pixels[screenAddress] = color;
                              }
                           }
                           else
                           {
                              pixels[screenAddress] = color;
                           }
                        }
                     }
                  }
               }
            }
         }
         
         cpu->lcdcMode = HBlank;
         if (cpu->lcdcInterruptEnabled && cpu->lcdcHBlankInterruptEnabled)
         {
            cpu->lcdcInterruptRequested = true;
         }
         //         ExecuteProcessor(2040);
         [self ExecuteProcessor:2040];
         //         AddTicksPerScanLine();
         [self AddTicksPerScanLine];
      }
   }
   else
   {
      for (int y = 0; y < 144; y++)
      {
         cpu->ly = y;
         cpu->lcdcMode = SearchingOamRam;
         if (cpu->lcdcInterruptEnabled
             && (cpu->lcdcOamInterruptEnabled
                 || (cpu->lcdcLycLyCoincidenceInterruptEnabled && cpu->lyCompare == y)))
         {
            cpu->lcdcInterruptRequested = true;
         }
         
         //         ExecuteProcessor(800);
         [self ExecuteProcessor:800];
         cpu->lcdcMode = TransferingData;
         //         ExecuteProcessor(1720);
         [self ExecuteProcessor:1720];
         cpu->lcdcMode = HBlank;
         if (cpu->lcdcInterruptEnabled && cpu->lcdcHBlankInterruptEnabled)
         {
            cpu->lcdcInterruptRequested = true;
         }
         //         ExecuteProcessor(2040);
         [self ExecuteProcessor:2040];
         //         AddTicksPerScanLine();
         [self AddTicksPerScanLine];
      }
   }
   
   cpu->lcdcMode = VBlank;
   if (cpu->vBlankInterruptEnabled)
   {
      cpu->vBlankInterruptRequested = true;
   }
   if (cpu->lcdcInterruptEnabled && cpu->lcdcVBlankInterruptEnabled)
   {
      cpu->lcdcInterruptRequested = true;
   }
   for (int y = 144; y <= 153; y++)
   {
      cpu->ly = y;
      if (cpu->lcdcInterruptEnabled && cpu->lcdcLycLyCoincidenceInterruptEnabled
          && cpu->lyCompare == y)
      {
         cpu->lcdcInterruptRequested = true;
      }
      //      ExecuteProcessor(4560);
      [self ExecuteProcessor:4560];
      //      AddTicksPerScanLine();
      [self AddTicksPerScanLine];
   }
}

- (void) AddTicksPerScanLine
{
   switch (cpu->timerFrequency)
   {
      case hz4096:
         scanLineTicks += 0.44329004329004329004329004329004;
         break;
      case hz16384:
         scanLineTicks += 1.7731601731601731601731601731602;
         break;
      case hz65536:
         scanLineTicks += 7.0926406926406926406926406926407;
         break;
      case hz262144:
         scanLineTicks += 28.370562770562770562770562770563;
         break;
   }
   while (scanLineTicks >= 1.0)
   {
      scanLineTicks -= 1.0;
      if (cpu->timerCounter == 0xFF)
      {
         cpu->timerCounter = cpu->timerModulo;
         if (cpu->lcdcInterruptEnabled && cpu->timerOverflowInterruptEnabled)
         {
            cpu->timerOverflowInterruptRequested = true;
         }          
      }
      else
      {
         cpu->timerCounter++;
      }
   }
}

- (void) ExecuteProcessor:(int)maxTicks
{   
   do
   {
      //      cpu->Step();
      [cpu Step];
      if (cpu->halted)
      {
         cpu->ticks = ((maxTicks - cpu->ticks) & 0x03);
         return;
      }
   } while (cpu->ticks < maxTicks);
   
   cpu->ticks -= maxTicks;
}

- (void) RenderFrame
{
   //   graphics.DrawImage(bitmap, 0, menuStrip1.Height, WIDTH, HEIGHT);
   
   //   NSLog(@"RenderFrame");
   
   for (int y = 0; y < screenSize.height; ++y)
   {
      for (int x = 0; x < screenSize.width; ++x)
      {
         NSColor * pixelColor;
         uint pixel = pixels[y * (int)screenSize.width + x];
         //         if (pixel != 0)
         //            NSLog(@"%x", pixel);
         if (pixel == 0xFF000000)
         {
            pixelColor = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1];
         }
         else if (pixel == 0xFF555555)
         {
            pixelColor = [NSColor colorWithCalibratedRed:0.25 green:0.25 blue:0.25 alpha:1];
         }
         else if (pixel == 0xFFAAAAAA)
         {
            pixelColor = [NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1];
         }
         else if (pixel == 0xFFFFFFFF)
         {
            pixelColor = [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1];
         }
         else
         {
            pixelColor = [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1];
         }
         
         //         [bitmapImageRep setColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1] atX:screenSize.width - x y:y];
         [bitmapImageRep setColor:pixelColor atX:x y:y];
      }
   }
   
   NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0]
                                                          forKey:NSImageCompressionFactor];
   NSData * imageData = [bitmapImageRep representationUsingType:NSPNGFileType properties:imageProps];
   
   [imageView setImage:[[NSImage alloc] initWithData:imageData]];
   
}

- (void) InitFrame
{
   //   rect = new Rectangle(0, 0, 160, 144);      
   //   StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
   //   SetStyle(ControlStyles.UserPaint, true);
   //   SetStyle(ControlStyles.AllPaintingInWmPaint, true);
   
   screenSize = NSMakeSize(160, 144);
   //   NSBitmapImageRep* bitmapImageRep = nil;
   bitmapImageRep = nil;
   bitmapImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil
                                                            pixelsWide:screenSize.width
                                                            pixelsHigh:screenSize.height
                                                         bitsPerSample:8
                                                       samplesPerPixel:4
                                                              hasAlpha:YES
                                                              isPlanar:NO
                                                        colorSpaceName:NSCalibratedRGBColorSpace
                                                          bitmapFormat:0
                                                           bytesPerRow:(4 * screenSize.width)
                                                          bitsPerPixel:32];
   
   for (int y = 0; y < screenSize.height; ++y)
   {
      for (int x = 0; x < screenSize.width; ++x)
      {
         [bitmapImageRep setColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1] atX:screenSize.width - x y:y];
      }
   }
   
   NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0]
                                                          forKey:NSImageCompressionFactor];
   NSData * imageData = [bitmapImageRep representationUsingType:NSPNGFileType properties:imageProps];
   
   [imageView setImage:[[NSImage alloc] initWithData:imageData]];
   
}

- (IBAction)openFile:(id)sender
{
   NSOpenPanel * openPanel = [NSOpenPanel openPanel];
   if ([openPanel runModal] == NSOKButton)
   {
      //      NSString *filename = [op filename];
      NSArray * urls = [openPanel URLs];
      NSURL * romFile = [urls objectAtIndex:0];
      
      NSLog(@"%@", [[romFile filePathURL] absoluteString]);
      
      //      ROMLoader romLoader = new ROMLoader();
      ROMLoader * romLoader = [[ROMLoader alloc] init];
      //      game = romLoader.Load(fileName);
      //      game = [romLoader Load:[[romFile filePathURL] absoluteString]];
      game = [romLoader Load:romFile];
      //      x80 = new X80();
      cpu = [[CPU alloc] init];
      cpu->cartridge = game->cartridge;
      //      cpu->PowerUp();
      [cpu PowerUp];
   }
}

//private void GameForm_KeyDown(object sender, KeyEventArgs e) {
//   cpu->KeyChanged(e.KeyCode, true);
//}



//private void GameForm_KeyUp(object sender, KeyEventArgs e) {
//   cpu->KeyChanged(e.KeyCode, false);
//}



/*
 private void SetImageSize(int scale) {
 WIDTH = scale * 160;
 HEIGHT = scale * 144;
 ClientSize = new Size(WIDTH, HEIGHT + menuStrip1.Height);
 InitGraphics();
 Invalidate();
 }
 
 private void InitGraphics() {
 if (graphics != null) {
 graphics.Dispose();
 }
 graphics = CreateGraphics();
 graphics.CompositingQuality = System.Drawing.Drawing2D.CompositingQuality.HighSpeed;
 graphics.CompositingMode = System.Drawing.Drawing2D.CompositingMode.SourceCopy;
 graphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
 }
 
 private void InitImage() {
 InitGraphics();
 for (int i = 0; i < pixels.Length; i++) {
 pixels[i] = 0xFF000000;
 }
 GCHandle handle = GCHandle.Alloc(pixels, GCHandleType.Pinned);
 IntPtr pointer = Marshal.UnsafeAddrOfPinnedArrayElement(pixels, 0);
 bitmap = new Bitmap(160, 144, 160 * 4, PixelFormat.Format32bppPArgb, pointer);
 }
 
 private void GameForm_Load(object sender, EventArgs e) {
 InitImage();
 SetImageSize(2);
 stopwatch.Start();
 nextFrameStart = stopwatch.ElapsedTicks;
 Application.Idle += OnApplicationIdle;
 }
 
 private void GameForm_KeyDown(object sender, KeyEventArgs e) {
 cpu->KeyChanged(e.KeyCode, true);
 }
 
 private void GameForm_KeyUp(object sender, KeyEventArgs e) {
 cpu->KeyChanged(e.KeyCode, false);
 }
 
 private void GameForm_Paint(object sender, PaintEventArgs e) {
 e.Graphics.CompositingQuality = System.Drawing.Drawing2D.CompositingQuality.HighSpeed;
 e.Graphics.CompositingMode = System.Drawing.Drawing2D.CompositingMode.SourceCopy;
 e.Graphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
 e.Graphics.DrawImage(bitmap, 0, menuStrip1.Height, WIDTH, HEIGHT);
 }
 
 private void exitToolStripMenuItem_Click(object sender, EventArgs e) {
 Application.Exit();
 }
 
 private void openToolStripMenuItem_Click(object sender, EventArgs e) {
 if (openFileDialog.ShowDialog(this) == DialogResult.OK) {
 string fileName = openFileDialog.FileName;
 ROMLoader romLoader = new ROMLoader();
 game = romLoader.Load(fileName);
 x80 = new X80();
 cpu->cartridge = game.cartridge;
 cpu->PowerUp();
 catridgeInfoMenuItem.Enabled = true;
 }      
 }
 
 private void maxFramesSkippedMenuItemClicked(object sender, EventArgs e) {
 ToolStripMenuItem menuItem = (ToolStripMenuItem)sender;
 skip0.Checked = false;
 skip1.Checked = false;
 skip10.Checked = false;
 skip100.Checked = false;
 skip2.Checked = false;
 skip20.Checked = false;
 skip4.Checked = false;
 skip50.Checked = false;
 skip6.Checked = false;
 skip8.Checked = false;
 menuItem.Checked = true;
 MAX_FRAMES_SKIPPED = int.Parse((string)menuItem.Tag);
 }
 
 private void aboutToolStripMenuItem_Click(object sender, EventArgs e) {
 new AboutBox().ShowDialog(this);
 }
 
 private void catridgeInfoMenuItem_Click(object sender, EventArgs e) {
 CartridgeInfoBox cartridgeInfoBox = new CartridgeInfoBox();
 cartridgeInfoBox.CartridgeInfoLines = game.ToString().Split('\n');
 cartridgeInfoBox.ShowDialog(this);
 }
 
 private void videoSizeMenuItemClicked(object sender, EventArgs e) {
 ToolStripMenuItem menuItem = (ToolStripMenuItem)sender;
 x1ToolStripMenuItem.Checked = false;
 x2ToolStripMenuItem.Checked = false;
 x3ToolStripMenuItem.Checked = false;
 x4ToolStripMenuItem.Checked = false;
 x5ToolStripMenuItem.Checked = false;
 x6ToolStripMenuItem.Checked = false;
 x7ToolStripMenuItem.Checked = false;
 x8ToolStripMenuItem.Checked = false;
 menuItem.Checked = true;
 SetImageSize(int.Parse((string)menuItem.Tag));
 }
 
 private void copyImageMenuItem_Click(object sender, EventArgs e) {
 Clipboard.SetImage(bitmap);
 }
 
 private void saveImageAsMenuItem_Click_1(object sender, EventArgs e) {
 SaveFileDialog saveFileDialog = new SaveFileDialog();
 saveFileDialog.Filter = "png files (*.png)|*.png|gif files (*.gif)|*.gif|jpg files (*.jpg)|*.jpg|All files (*.*)|*.*";
 if (saveFileDialog.ShowDialog() == DialogResult.OK) {        
 bitmap.Save(saveFileDialog.FileName);
 }
 }
 */

@end
