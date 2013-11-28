/*
 * Main.cpp
 *
 *  Created on: Oct 14, 2013
 *      Author: Cfyz
 */

#include "BearLibTerminal.h"

#include <GL/gl.h>
#include <vector>
#include <string>
#include <set>

#include "Common.hpp"

void Menu();

TERMINAL_TAKE_CARE_OF_WINMAIN

int main()
{
	terminal_open();
	Menu();
	terminal_close();
	return 0;

	terminal_open();
	terminal_setf("window.title='%s'", "Test title");
	terminal_set("window.cellsize=23x23");
	terminal_set("0xE000: default.png, size=16x16");
	terminal_set("0xE200: sample.jpeg");
	terminal_set("0xE201: sample2.jpg");
	terminal_set("0xE300: circle.png, align=top-left, bbox=2x2");
	terminal_set("0xE301: circle.png, align=top-right, bbox=2x2");
	terminal_set("0xE302: circle.png, align=bottom-left, bbox=2x2");
	terminal_set("0xE303: circle.png, align=bottom-right, bbox=2x2");
	terminal_set("0xE304: circle.png, align=center, bbox=2x2");
	terminal_set("0xE400: UbuntuMono-R.ttf, size=12");
	terminal_set("0xE500: Ubuntu-R.ttf, size=12");
	terminal_set("0xE600: UbuntuMono-RI.ttf, size=12");
	//terminal_set("0xE700: UbuntuMono-R.ttf, size=24x24");
	terminal_set("0xE700: Tigrex3drunes_16x16_437.PNG");
	terminal_color("black");
	terminal_bkcolor("orange");
	terminal_print(2, 2, L"Hello, [color=white]world[/color].[U+2250] \x1234 {абв} [base=0xE000]abc");

	terminal_bkcolor("black");
	color_t corners[] = {0xFFFF0000, 0xFF00FF00, 0xFF6060FF, 0xFFFF00FF};
	terminal_put_ext(2, 4, 0, 0, L'я', corners);
	//terminal_bkcolor(0xFFFFFFFF);
	terminal_put_ext(3, 5, 0, 0, 0x2593, corners);
	terminal_put_ext(4, 4, 0, 0, 11*16+2, corners);
	terminal_bkcolor("black");

	terminal_color("white");
	terminal_wprint(2, 3, L"a[+]ˆ, c[+][color=red]/[/color], d[+][color=orange][U+2044]");



	//terminal_bkcolor(0xFFEE9000);
	/*
	for (int y=0; y<16; y++)
	{
		for (int x=0; x<16; x++)
		{
			//terminal_put(6+x, 6+y, y*16+x);
			terminal_put(6+x, 6+y, 0x2500+y*16+x);
		}
	}
	/*/
	terminal_composition(TK_COMPOSITION_ON);
	int cw = terminal_state(TK_CELL_WIDTH);
	int ch = terminal_state(TK_CELL_HEIGHT);
	for (int y=0; y<16; y++)
	{
		for (int x=0; x<16; x++)
		{
			//terminal_put_ext(6, 6, x*(cw+1), y*(ch+1), 0x2500+y*16+x, NULL);
			terminal_put_ext(6, 6, x*(cw+2), y*(ch+2), 0x2500+y*16+x, NULL);
		}
	}
	//*/

	terminal_color(0xFFFFFFFF);
	terminal_put(28, 10, 0xE200);

	terminal_layer(1);
	terminal_put(27, 9, 0xE201);

	terminal_layer(0);
	terminal_composition(TK_COMPOSITION_ON);
	terminal_put(24, 9, 0xE300);
	terminal_put(24, 9, 0xE301);
	terminal_put(24, 9, 0xE302);
	terminal_put(24, 9, 0xE303);
	terminal_put(24, 9, 0xE304);

	terminal_put(24, 12, 0xE400+'A');
	terminal_put(25, 12, 0xE400+'b');
	terminal_put(26, 12, 0xE400+'c');
	for (int i=0; i<20; i++) terminal_put(24+i, 14, 0xFFFD);
	terminal_print(24, 14, "[base=0xE400]Hello, world!");

	for (int i=0; i<20; i++) terminal_put(24+i, 16, 0xFFFD);
	terminal_print(24, 16, "[base=0xE500]Hello, world!");

	for (int i=0; i<20; i++) terminal_put(24+i, 18, 0xFFFD);
	terminal_print(24, 18, "[base=0xE600]Hello, world!");

	for (int i=0; i<20; i++) terminal_put(24+i, 20, 0xFFFD);
	terminal_print(24, 20, "[base=0xE700]Hello, world!");

	for (int i=0; i<10; i++)
	{
		terminal_put(2+i, 23, 0xFFFD);
		terminal_put(2+i, 23, 0x2500+i);
	}

	terminal_refresh();
	terminal_read();


	//terminal_set("window.icon=icon.ico");

	//TestWGL4();
	Menu();

	//*
	terminal_close();
	return 0;
	//*/

	/*
	wchar_t buffer[100] = {0};
	terminal_read_wstr(2, 22, buffer, 16);
	terminal_wprint(2, 23, buffer);
	terminal_refresh();
	terminal_read();
	//*/

	//terminal_set("");
	terminal_set("output.vsync=false");
	terminal_set("window.cellsize=auto; font: UbuntuMono-R.ttf, size=12; output.asynchronous=false");
	for (int i=0; i<25; i++)
	{
		terminal_clear();
		terminal_put(1+i, 1, L'Ы');
		terminal_custom(1);
		glDisable(GL_TEXTURE_2D);
		glBegin(GL_LINES);
		glVertex2i(10, 48);
		glVertex2i(10+i*8, 64);
		glEnd();
		glEnable(GL_TEXTURE_2D);
		terminal_custom(0);
		terminal_refresh();
		//Sleep(125);
		delay(125);
	}

	terminal_close();
	return 0;
}

#include <vector>

struct TestEntry
{
	const char* name;
	void (*func)();
};

void Menu()
{
	auto reset = []()
	{
		terminal_set("window: size=80x25, cellsize=auto, title='Omni: menu'; font=default");
	};

	std::vector<TestEntry> entries =
	{
		{"Basic output", TestBasicOutput},
		{"Default font", TestDefaultFont},
		{"Tilesets", TestTilesets}, // NYI
		{"Sprites", TestSprites}, // NYI
		{"Manual cellsize", TestManualCellsize},
		{"Auto-generated tileset", TestAutoGenerated},
		{"Multiple fonts", TestMultipleFonts},
		{"Font viewer", TestFontViewer}, // NYI
		{"Layers", TestFontViewer}, // NYI
		{"Extended 1: basics", TestExtendedBasics}, // NYI
		{"Extended 2: inter-layer animation", TestExtendedInterlayer}, // NYI
		{"Extended 3: smooth scroll", TestFontViewer}, // NYI
		{"Dynamic sprites", TestFontViewer}, // NYI
		{"Synchronous rendering", TestFontViewer}, // NYI
		{"Custom rendering", TestFontViewer}, // NYI
		{"Input 1: keyboard", TestKeyboard},
		{"Input 2: mouse", TestFontViewer}, // NYI
		{"Input 3: text input", TestFontViewer} // NYI
	};

	reset();

	for (bool proceed=true; proceed;)
	{
		terminal_clear();
		for (size_t i=0; i<entries.size(); i++)
		{
			char shortcut = i < 9? '1'+i: 'a'+(i-9);
			terminal_printf(2, 1+i, "[color=orange]%c.[/color] %s", shortcut, entries[i].name);
		}
		terminal_printf(2, 23, "[color=orange]ESC.[/color] Exit");
		terminal_refresh();

		do
		{
			int key = terminal_read();

			if (key == TK_ESCAPE || key == TK_CLOSE)
			{
				proceed = false;
			}
			else if ((key >= TK_1 && key <= TK_9) || (key >= TK_A && key <= TK_Z))
			{
				int index = key >= TK_A? 9+(key-TK_A): (key-TK_1);
				if (index >= 0 && index < entries.size())
				{
					entries[index].func();
					reset();
				}
			}
		}
		while (proceed && terminal_has_input());
	}
}




// U+0020..U+007F: C0 Controls and Basic Latin
// U+00A0..U+00FF: C1 Controls and Latin-1 Supplement
// U+0100..U+017F: Latin Extended-A
// U+0190..U+019F: Latin Extended-B
// U+01F0..U+01FF: --||--
// U+02C0..U+02CF: Spacing Modifier Letters
// U+02D0..U+02DF: --||--
// U+0370..U+03CF: Greek
// U+0400..U+045F: Cyrillic
// U+0490..U+049F: --||--
// U+1E80..U+1E8F: Latin Extended Additional
// U+1EF0..U+1EFF: --||--
// U+2010..U+204F: General Punctuation
// U+2070..U+207F: Super/Subscripts
// U+20A0..U+20AF: Currency Symbols
// U+2100..U+212F: Letterlike symbols
// U+2150..U+215F: Number Forms
// U+2190..U+219F: Arrows
// U+21A0..U+21AF: --||--
// U+2200..U+222F: Mathematical Operators
// U+2240..U+224F: --||--
// U+2260..U+226F: --||--
// U+2300..U+232F: Miscellaneous Technical
// U+2500..U+257F: Box drawing characters
// U+2580..U+259F: Block Elements
// U+25A0..U+25EF: Geometric Shapes
// U+2630..U+264F: Miscellaneous Symbols
// U+2660..U+266F: --||--
// U+F000..U+F00F: Private Use Area
// U+FB00..U+FB00: Alphabetic Presentation Forms

