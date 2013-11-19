/*
 * Main.cpp
 *
 *  Created on: Oct 14, 2013
 *      Author: Cfyz
 */

#include "BearLibTerminal.h"
#if defined(_WIN32)
#include <Windows.h>
#endif
#if defined(__linux)
#include <unistd.h>
inline void Sleep(int ms) {usleep(ms*1000);}
#endif
#include <GL/gl.h>

TERMINAL_TAKE_CARE_OF_WINMAIN

int main()
{
	terminal_open();
	terminal_setf("window.title='%s'", "Test title");
	terminal_set("window.cellsize=24x24");
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
	terminal_set("0xE700: UbuntuMono-R.ttf, size=24x24");
	terminal_color(0xFF000000);
	terminal_bkcolor(0xFFEE9000);
	terminal_wprint(2, 2, L"Hello, [color=white]world[/color].[U+2250] \x1234 {абв} [base=0xE000]abc");

	terminal_bkcolor(0);
	color_t corners[] = {0xFFFF0000, 0xFF00FF00, 0xFF6060FF, 0xFFFF00FF};
	terminal_put_ext(2, 4, 0, 0, L'я', corners);
	//terminal_bkcolor(0xFFFFFFFF);
	terminal_put_ext(3, 5, 0, 0, 0x2593, corners);
	terminal_put_ext(4, 4, 0, 0, 11*16+2, corners);
	terminal_bkcolor(0);

	terminal_color(0xFFFFFFFF);
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

	terminal_close();
	return 0;

	wchar_t buffer[100] = {0};
	terminal_read_wstr(2, 22, buffer, 16);
	terminal_wprint(2, 23, buffer);
	terminal_refresh();
	terminal_read();

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
		Sleep(125);
	}

	terminal_close();
	return 0;
}
