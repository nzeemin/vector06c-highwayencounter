using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;

namespace SpriteRotate
{
    class Program
    {
        private static readonly byte[] memdmp = File.ReadAllBytes("memdmp.bin");

        static void Main(string[] args)
        {
            PrepareTitleScreen();

            Bitmap bmpTiles = new Bitmap(52 * 6 + 12, 28 * 10 + 12, PixelFormat.Format32bppArgb);

            FileStream fs = new FileStream("hwyencsprites.asm", FileMode.Create);
            StreamWriter writer = new StreamWriter(fs);
            writer.WriteLine();

            ProcessFont(writer);
            writer.WriteLine();

            ProcessSmallFont(writer);
            writer.WriteLine();

            ProcessSprite6020(writer);
            writer.WriteLine();

            ProcessSprites6AD0(writer);
            writer.WriteLine();

            ProcessDataPattSeq(writer);
            writer.WriteLine();

            ProcessZoneData(writer);
            writer.WriteLine();

            ProcessPatts(writer);
            writer.WriteLine();

            ProcessSprListData(writer);
            writer.WriteLine();

            ProcessSpriteVortexLogo(writer);
            writer.WriteLine();

            ProcessData7900(writer);
            writer.WriteLine();

            ProcessData7A00(writer);
            writer.WriteLine();

            ProcessFontDigits(writer);
            writer.WriteLine();

            ProcessFontA490(writer);
            writer.WriteLine();

            ProcessMasksAndSprites(writer, bmpTiles);
            writer.WriteLine();

            ProcessSpacecraft(writer);
            writer.WriteLine();

            writer.Flush();

            bmpTiles.Save("sprites.png");
        }

        static void PrepareTitleScreen()
        {
            var bmp = new Bitmap(@"..\..\hwyenc-title.png");
            var palette = new Color[]
            {
                Color.FromArgb(12, 11, 10),
                Color.FromArgb(27, 196, 6),
                Color.FromArgb(99, 101, 90),
                Color.FromArgb(157, 140, 144),
                Color.FromArgb(191, 191, 191),
                Color.FromArgb(193, 193, 22),
                Color.FromArgb(220, 220, 217),
                Color.FromArgb(255, 255, 255),
            };

            var planes = new[] { new byte[8192], new byte[8192], new byte[8192] };

            for (int col = 0; col < 32; col++)
            {
                for (int row = 0; row < 256; row++)
                {
                    int b0 = 0, b1 = 0, b2 = 0;
                    for (int b = 0; b < 8; b++)
                    {
                        var color = bmp.GetPixel(col * 8 + b, 255 - row);

                        int index = -1;
                        for (int i = 0; i < 8; i++)
                        {
                            if (palette[i] == color)
                            {
                                index = i;
                                break;
                            }
                        }

                        if (index == -1)
                            throw new Exception($"Color not found: {color}");

                        b0 = b0 << 1;
                        b0 |= index & 1;
                        b1 = b1 << 1;
                        b1 |= (index & 2) >> 1;
                        b2 = b2 << 1;
                        b2 |= (index & 4) >> 2;
                    }

                    planes[0][col * 256 + row] = (byte)b0;
                    planes[1][col * 256 + row] = (byte)b1;
                    planes[2][col * 256 + row] = (byte)b2;
                }
            }

            const string outfilename = "hwyenctitle.asm";
            using (var writer = new StreamWriter(outfilename))
            {
                writer.WriteLine("TitleScreen:");
                WriteByteArray(planes[2], writer);
                writer.WriteLine("TitleScreen1:");
                WriteByteArray(planes[1], writer);
                writer.WriteLine("TitleScreen0:");
                WriteByteArray(planes[0], writer);
            }

            Console.WriteLine($"{outfilename} saved");

            for (int i = 0; i < palette.Length; i++)
            {
                var c = palette[i];
                var b = ((int)(c.B / 255.0 * 4) << 6) | ((int)(c.G / 255.0 * 8) << 3) | ((int)(c.R / 255.0 * 8));
                Console.WriteLine($"Color {i}: ${(byte)b:X2}");
            }

            const string binfilename = "hwyenctitle.bin";
            using (var stream = new FileStream(binfilename, FileMode.Create))
            using (var writer = new BinaryWriter(stream))
            {
                writer.Write(planes[2]);
                writer.Write(planes[1]);
                writer.Write(planes[0]);
            }

            Console.WriteLine($"{binfilename} saved");
        }

        static void ProcessFont(StreamWriter writer)
        {
            const string TileChars = "0123456789 :/.-?!ABCDEFGHIJKLMNOPQRSTUVWXYZ";

            writer.Write("Font85:");
            for (int tile = 0; tile < 43; tile++)
            {
                int addr = 0x5B00 + tile * 5;
                writer.Write("\t.db\t");
                for (int i = 0; i < 5; i++)
                {
                    byte b = memdmp[addr + i];
                    writer.Write($"${b:X2}");
                    if (i < 4) writer.Write(",");
                }
                writer.WriteLine("\t; {0:X2} {1}", (byte)tile, TileChars[tile]);
            }
        }

        static void ProcessFontA490(StreamWriter writer)
        {
            const string TileChars = " 0123456789";

            writer.Write("LA490:");
            for (int tile = 0; tile < 11; tile++)
            {
                int addr = 0xA490 + tile * 5;
                writer.Write("\t.db\t");
                for (int i = 0; i < 5; i++)
                {
                    byte b = RotateByte(memdmp[addr + i]);

                    writer.Write(EncodeOctalString(b));
                    if (i < 4) writer.Write(",");
                }
                writer.WriteLine("\t; {0} {1}", EncodeOctalString((byte)tile), TileChars[tile]);
            }
        }

        static void ProcessSpriteVortexLogo(StreamWriter writer)
        {
            writer.WriteLine("LogoVortex:");
            int addr = 0x5E60;
            for (int i = 0; i < 8 * 56; i++)
            {
                if ((i % 16) == 0) writer.Write("\t.db\t");

                byte b = memdmp[addr + i];
                b = (byte)~b;
                writer.Write($"${b:X2}");

                if ((i % 16) < 15)
                    writer.Write(",");
                else
                    writer.WriteLine();
            }
        }

        static void ProcessSmallFont(StreamWriter writer)
        {
            writer.WriteLine("; Small Font");
            writer.Write("LB5D7:");
            int addr = 0xB5D7;
            for (int i = 0; i < 80; i++)
            {
                if ((i % 16) == 0) writer.Write("\t.db\t");

                byte b = RotateByte(memdmp[addr + i]);

                writer.Write($"${b:X2}");
                if ((i % 16) < 15)
                    writer.Write(",");
                else
                    writer.WriteLine();
            }
        }

        static void ProcessSprite6020(StreamWriter writer)
        {
            writer.WriteLine("; Indicators panel sprite");
            writer.WriteLine("GamePanel:");
            int addr = 0x6020;
            for (int i = 0; i < 32 * 34; i++)
            {
                if ((i % 16) == 0) writer.Write("\t.db\t");

                byte b = memdmp[addr + i];
                writer.Write($"${b:X2}");

                if ((i % 16) < 15)
                    writer.Write(",");
                else
                    writer.WriteLine();
            }
        }

        static void ProcessSprites6AD0(StreamWriter writer)
        {
            writer.WriteLine("L6AD0::\t; Data");
            int addr = 0x6AD0;
            for (int sprite = 0; sprite < 99; sprite++)
            {
                writer.Write("\t.db\t");
                for (int i = 0; i < 16; i++) // bytes
                {
                    byte b = memdmp[addr];
                    writer.Write($"${b:X2}");

                    if (i < 15) writer.Write(",");

                    addr++;
                }
                writer.WriteLine();
            }
        }

        static void ProcessDataPattSeq(StreamWriter writer)
        {
            byte[] datadmp = File.ReadAllBytes(@"..\..\patt-seq.bin");

            writer.WriteLine("PattSeq:");
            //int addr = 0x6500;
            for (int i = 0; i < 1536; i++)
            {
                if ((i % 12) == 0) writer.Write("\t.db\t");

                byte b = datadmp[i];
                writer.Write($"${b:X2}");

                if ((i % 12) < 11 && i < 1536 - 1)
                    writer.Write(",");
                else
                    writer.WriteLine();
            }
        }

        static void ProcessZoneData(StreamWriter writer)
        {
            byte[] datadmp = File.ReadAllBytes(@"..\..\zone-data.bin");

            writer.WriteLine("ZoneData:");
            //int addr = 0x6B00;
            for (int i = 0; i < 1536; i++)
            {
                if ((i % 16) == 0) writer.Write("\t.db\t");
                if ((i % 16) == 8) writer.Write(" ");

                byte b = datadmp[i];
                writer.Write($"${b:X2}");

                if ((i % 16) < 15 && i < 1536 - 1)
                    writer.Write(",");
                else
                    writer.WriteLine();
            }
        }

        static void ProcessPatts(StreamWriter writer)
        {
            //byte[] pattsdmp = File.ReadAllBytes(@"..\..\patts.bin");

            writer.WriteLine("Patts:");
            int addr = 0x7100;
            for (int i = 0; i < 2048; i++)
            {
                if ((i % 16) == 0) writer.Write("\t.db\t");
                if ((i % 16) == 8) writer.Write(" ");

                byte b = memdmp[addr + i];
                writer.Write($"${b:X2}");

                if ((i % 16) < 15 && i < 2048 - 1)
                    writer.Write(",");
                else
                    writer.WriteLine();
            }
        }

        static void ProcessSprListData(StreamWriter writer)
        {
            //byte[] datadmp = File.ReadAllBytes(@"..\..\spr-data.bin");

            writer.WriteLine("SprList:");
            int addr = 0x7B00;
            for (int i = 0; i < 3984; i++)
            {
                if ((i % 16) == 0) writer.Write("\t.db\t");
                if ((i % 16) == 8) writer.Write(" ");

                byte b = memdmp[addr + i];
                writer.Write($"${b:X2}");

                if ((i % 16) < 15 && i < 3984 - 1)
                    writer.Write(",");
                else
                    writer.WriteLine();
            }
        }

        static void ProcessData7900(StreamWriter writer)
        {
            writer.WriteLine("; Data");
            writer.Write("L7900:");
            int addr = 0x7900;
            for (int i = 0; i < 5632; i++)
            {
                if ((i % 16) == 0) writer.Write("\t.db\t");
                if ((i % 16) == 8) writer.Write(" ");

                byte b = memdmp[addr + i];
                writer.Write($"${b:X2}");
                if ((i % 16) < 15 && i < 5632 - 1)
                    writer.Write(",");
                else
                    writer.WriteLine();
            }
        }

        static void ProcessData7A00(StreamWriter writer)
        {
            writer.WriteLine("L7A00:\t;");
            int addr = 0x7A00;
            for (int i = 0; i < 16; i++)
            {
                writer.Write("\t.dw\t");
                for (int j = 0; j < 8; j++)
                {
                    int word = memdmp[addr] + memdmp[addr + 1] * 256;
                    writer.Write("L" + word.ToString("X4"));
                    if (j < 7) writer.Write(", ");

                    addr += 2;
                }

                writer.WriteLine();
            }
        }

        static void ProcessFontDigits(StreamWriter writer)
        {
            byte[] datadmp = File.ReadAllBytes(@"..\..\font-digits.bin");

            writer.WriteLine("Font88:");
            for (int sprite = 0; sprite < 21; sprite++) // sprites
            {
                writer.Write("\t.db\t");
                for (int i = 0; i < 8; i++) // bytes
                {
                    byte b = RotateByte(datadmp[sprite * 8 + i]);
                    writer.Write($"${b:X2}");

                    if (i < 7) writer.Write(",");
                }
                writer.WriteLine();
            }
        }

        static void ProcessMasksAndSprites(StreamWriter writer, Bitmap bmpTiles)
        {
            writer.WriteLine("; Masks and Sprites, 57. sprites, 6 * 24 = 144 bytes each, 8208 bytes in total");
            writer.WriteLine("Sprites:");
            for (int sprite = 0; sprite < 57; sprite++)  // sprites
            {
                int addr = 0xB8F0 + sprite * 6 * 24;
                //int x = 8 + (sprite % 6) * 52;
                //int y = 8 + (sprite / 6) * 28;

                writer.Write("L{0:X4}:", addr);

                for (int i = 0; i < 6 * 24; i++)  // bytes
                {
                    if ((i % 12) == 0) writer.Write("\t.db\t");

                    byte b = memdmp[addr + i];
                    writer.Write($"${b:X2}");

                    if ((i % 12) != 11)
                    {
                        writer.Write(",");
                        if ((i % 12) == 5) writer.Write(" ");
                    }
                    else
                    {
                        if (i == 11)
                            writer.Write(" ; {0}", sprite);
                        writer.WriteLine();
                    }
                }
            }
        }

        static void ProcessSpacecraft(StreamWriter writer)
        {
            const int numberOfTiles = 12 + 13 + 17 + 18 + 21 + 21 + 21 + 21 + 19 + 17 + 8;

            writer.WriteLine("Starcraft:");
            int addr = 0xAAFF;
            for (int tile = 0; tile < numberOfTiles; tile++)
            {
                writer.Write("\t.db\t");
                for (int i = 0; i < 8; i++)
                {
                    byte b = memdmp[addr];
                    writer.Write($"${b:X2}");
                    if (i < 7) writer.Write(",");

                    addr++;
                }
                writer.WriteLine();
            }
        }

        static void WriteByteArray(byte[] octets, StreamWriter writer)
        {
            int cnt = 0;
            for (int i = 0; i < octets.Length; i++)
            {
                if (cnt == 0)
                    writer.Write("\t.db\t");
                else
                    writer.Write(",");

                writer.Write($"${octets[i]:X2}");

                cnt++;
                if (cnt >= 16)
                {
                    writer.WriteLine();
                    cnt = 0;
                }
            }
            if (cnt != 0)
                writer.WriteLine();
        }

        static string EncodeOctalString(byte value)
        {
            //convert to int, for cleaner syntax below. 
            int x = (int)value;

            return string.Format(
                @"{0}{1}{2}",
                ((x >> 6) & 7),
                ((x >> 3) & 7),
                (x & 7)
            );
        }

        static byte RotateByte(byte b)
        {
            int bb = 0;
            for (int j = 0; j < 8; j++)
                bb |= ((b >> (7 - j)) & 1) << j;
            return (byte)bb;
        }
    }
}
