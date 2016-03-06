/*
* BearLibTerminal
* Copyright (C) 2016 Cfyz
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
* of the Software, and to permit persons to whom the Software is furnished to do
* so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#if defined(__APPLE__)

#include "CocoaWindow.h"
#include <map>
#include <iostream>
#import <Cocoa/Cocoa.h>

#define TERMINAL_BUILDING_LIBRARY
#include "BearLibTerminal.h"

@interface CocoaTerminalApplication: NSApplication
@end

@interface CocoaTerminalApplicationDelegate: NSObject<NSApplicationDelegate>
@end

@interface CocoaTerminalWindow: NSWindow<NSWindowDelegate>
{
    BearLibTerminal::CocoaWindow::Impl* m_impl;
}
- (id)initWithImpl:(BearLibTerminal::CocoaWindow::Impl*)owner styleMask:(NSUInteger)mask;
@end

@interface CocoaTerminalWindowDelegate: NSObject<NSWindowDelegate>
{
    BearLibTerminal::CocoaWindow::Impl* m_impl;
}
-(id)initWithImpl:(BearLibTerminal::CocoaWindow::Impl*)impl;
@end

namespace BearLibTerminal
{
    static std::map<unsigned short, int> keycodeMapping =
    {
        {0x00, TK_A},
        {0x01, TK_S},
        {0x02, TK_D},
        {0x03, TK_F},
        {0x04, TK_H},
        {0x05, TK_G},
        {0x06, TK_Z},
        {0x07, TK_X},
        {0x08, TK_C},
        {0x09, TK_V},
        {0x0B, TK_B},
        {0x0C, TK_Q},
        {0x0D, TK_W},
        {0x0E, TK_E},
        {0x0F, TK_R},
        {0x10, TK_Y},
        {0x11, TK_T},
        {0x12, TK_1},
        {0x13, TK_2},
        {0x14, TK_3},
        {0x15, TK_4},
        {0x16, TK_6},
        {0x17, TK_5},
        {0x18, TK_EQUALS},
        {0x19, TK_9},
        {0x1A, TK_7},
        {0x1B, TK_MINUS},
        {0x1C, TK_8},
        {0x1D, TK_0},
        {0x1E, TK_RBRACKET},
        {0x1F, TK_O},
        {0x20, TK_U},
        {0x21, TK_LBRACKET},
        {0x22, TK_I},
        {0x23, TK_P},
        {0x25, TK_L},
        {0x26, TK_J},
        {0x27, TK_APOSTROPHE},
        {0x28, TK_K},
        {0x29, TK_SEMICOLON},
        {0x2A, TK_BACKSLASH},
        {0x2B, TK_COMMA},
        {0x2C, TK_SLASH},
        {0x2D, TK_N},
        {0x2E, TK_M},
        {0x2F, TK_PERIOD},
        {0x32, TK_GRAVE},
        {0x41, TK_KP_PERIOD},
        {0x43, TK_KP_MULTIPLY},
        {0x45, TK_KP_PLUS},
        // {0x47, kVK_ANSI_KeypadClear},
        {0x4B, TK_KP_DIVIDE},
        {0x4C, TK_KP_ENTER},
        {0x4E, TK_KP_MINUS},
        // {0x51, kVK_ANSI_KeypadEquals},
        {0x52, TK_KP_0},
        {0x53, TK_KP_1},
        {0x54, TK_KP_2},
        {0x55, TK_KP_3},
        {0x56, TK_KP_4},
        {0x57, TK_KP_5},
        {0x58, TK_KP_6},
        {0x59, TK_KP_7},
        {0x5B, TK_KP_8},
        {0x5C, TK_KP_9},
        {0x24, TK_RETURN},
        {0x30, TK_TAB},
        {0x31, TK_SPACE},
        {0x33, TK_BACKSPACE},
        {0x35, TK_ESCAPE},
        // {0x37, kVK_Command},
        {0x38, TK_SHIFT},
        // {0x39, kVK_CapsLock},
        // {0x3A, kVK_Option}, // This would be TK_ALT
        {0x3B, TK_CONTROL},
        {0x3C, TK_SHIFT},
        // {0x3D, kVK_RightOption},
        {0x3E, TK_CONTROL},
        // {0x3F, kVK_Function},
        {0x60, TK_F5},
        {0x61, TK_F6},
        {0x62, TK_F7},
        {0x63, TK_F3},
        {0x64, TK_F8},
        {0x65, TK_F9},
        {0x67, TK_F11},
        {0x6D, TK_F10},
        {0x6F, TK_F12},
        {0x73, TK_HOME},
        {0x74, TK_PAGEUP},
        {0x75, TK_DELETE},
        {0x76, TK_F4},
        {0x77, TK_END},
        {0x78, TK_F2},
        {0x79, TK_PAGEDOWN},
        {0x7A, TK_F1},
        {0x7B, TK_LEFT},
        {0x7C, TK_RIGHT},
        {0x7D, TK_DOWN},
        {0x7E, TK_UP}
    };
    
    struct CocoaWindow::Impl
    {
        Impl();
        void HandleEvent(NSEvent* e);
        void HandleWindowDidResize();
        NSSize HandleWindowWillResize(NSSize frameSize);
        
        EventHandler m_handler;
        bool m_resizeable;
        Size m_increment;
        Size m_minimum_size;
        id m_window;
        id m_view;
    };
    
    CocoaWindow::Impl::Impl():
        m_resizeable(false)
    { }
    
    void CocoaWindow::Impl::HandleEvent(NSEvent *e)
    {
        switch (e.type)
        {
            case NSKeyDown:
            case NSKeyUp:
            {
                int key = keycodeMapping[e.keyCode];
                if (key <= 0)
                    break;
                
                bool pressed = e.type == NSKeyDown;
                bool printable = (key < TK_RETURN || key >= TK_SPACE) && key < TK_F1;
                int code = key | (pressed? 0: TK_KEY_RELEASED);
                Event event{code, {{key, pressed? 1: 0}}};
                if (pressed && printable)
                {
                    const char* c = e.characters.UTF8String;
                    if (c[0] > 32)
                        event[TK_WCHAR] = (wchar_t)c[0]; // FIXME: wtf
                }
                m_handler(std::move(event));
                break;
            }
                
            case NSFlagsChanged:
            {
                int key = keycodeMapping[e.keyCode];
                if (key <= 0)
                    break;
                
                bool pressed = false;
                if (key == TK_CONTROL)
                    pressed = (e.modifierFlags & NSControlKeyMask);
                else if (key == TK_SHIFT)
                    pressed = (e.modifierFlags & NSShiftKeyMask);
                
                int code = key | (pressed? 0: TK_KEY_RELEASED);
                m_handler({code, {{key, pressed? 1: 0}}});
                break;
            }
                
            case NSLeftMouseDown:
            case NSRightMouseDown:
            case NSOtherMouseDown:
            case NSLeftMouseUp:
            case NSRightMouseUp:
            case NSOtherMouseUp:
            {
                int key = 0;
                
                if (e.type == NSLeftMouseDown || e.type == NSLeftMouseUp)
                    key = TK_MOUSE_LEFT;
                else if (e.type == NSRightMouseUp || e.type == NSRightMouseDown)
                    key = TK_MOUSE_RIGHT;
                else
                    key = TK_MOUSE_MIDDLE;
                
                bool pressed =
                    e.type == NSLeftMouseDown ||
                    e.type == NSRightMouseDown ||
                    e.type == NSOtherMouseDown;
                
                int code = key | (pressed? 0: TK_KEY_RELEASED);
                m_handler({code, {{key, (int)pressed}, {TK_MOUSE_CLICKS, e.clickCount}}});
                break;
            }
                
            case NSMouseMoved:
            case NSLeftMouseDragged:
            case NSRightMouseDragged:
            case NSOtherMouseDragged:
            {
                NSRect rect = [m_view frame];
                NSPoint pos = [e locationInWindow];
                Event event{TK_MOUSE_MOVE};
                event[TK_MOUSE_PIXEL_X] = pos.x;
                event[TK_MOUSE_PIXEL_Y] = rect.size.height - pos.y;
                m_handler(std::move(event));
                break;
            }
                
            case NSScrollWheel:
            {
                CGFloat delta = e.scrollingDeltaY;
                m_handler({TK_MOUSE_SCROLL, {{TK_MOUSE_WHEEL, (int)delta}}});
                break;
            }
                
            default:
                // Ignore.
                break;
        }
    }
    
    void CocoaWindow::Impl::HandleWindowDidResize()
    {
        if (m_resizeable)
        {
            NSRect frame = [[m_window contentView] frame];
            m_handler({TK_RESIZED, {{TK_WIDTH, frame.size.width}, {TK_HEIGHT, frame.size.height}}});
            m_handler(TK_INVALIDATE);
            m_handler(TK_REDRAW);
        }
    }
    
    NSSize CocoaWindow::Impl::HandleWindowWillResize(NSSize frameSize)
    {
        if (!m_resizeable || m_increment.Area() == 0)
            return frameSize;
        
        // This handles the situation when window is unzoomed ignoring the size increments.
        NSRect frame = NSMakeRect(0, 0, frameSize.width, frameSize.height);
        NSRect inner = [m_window contentRectForFrameRect:frame];
        inner.size.width = std::floor(inner.size.width / m_increment.width) * m_increment.width;
        inner.size.height = std::floor(inner.size.height / m_increment.height) * m_increment.height;
        NSRect outer = [m_window frameRectForContentRect:inner];
        return NSMakeSize(outer.size.width, outer.size.height);
    }
    
    CocoaWindow::CocoaWindow(EventHandler handler):
        Window(handler),
        m_impl(new Impl)
    {
        m_impl->m_handler = handler; // TODO: impl ctor
        
        [CocoaTerminalApplication sharedApplication];
        NSApp.delegate = [[CocoaTerminalApplicationDelegate alloc] init];
        NSApp.activationPolicy = NSApplicationActivationPolicyRegular;
        [NSApp activateIgnoringOtherApps:YES];
        [[[NSThread alloc] init] start]; // XXX?
        
        [NSApp run];
        
        NSUInteger styleMask =
            NSTitledWindowMask|
            NSClosableWindowMask|
            NSMiniaturizableWindowMask;
        m_impl->m_window = [[CocoaTerminalWindow alloc] initWithImpl:m_impl.get() styleMask:styleMask];
        [m_impl->m_window setBackgroundColor:[NSColor blueColor]];
        [m_impl->m_window setAcceptsMouseMovedEvents:YES];
        [m_impl->m_window setDelegate:[[CocoaTerminalWindowDelegate alloc] initWithImpl:m_impl.get()]];
        
        // OpenGL
        
        NSOpenGLPixelFormatAttribute attrs[] =
        {
            NSOpenGLPFADoubleBuffer,
            NSOpenGLPFAColorSize, 24,
            NSOpenGLPFAAlphaSize, 8,
            NSOpenGLPFADepthSize, 16, // XXX: depth buffer is not necessary
            0
        };
        
        NSOpenGLPixelFormat* pixFmt = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
        if (pixFmt == nil)
            throw std::runtime_error("Failed to find suitable pixel format");
        
        m_impl->m_view = [[NSOpenGLView alloc] initWithFrame:NSZeroRect pixelFormat:pixFmt];
        if (m_impl->m_view == nil)
            throw std::runtime_error("Failed to create OpenGL view");
        
        [m_impl->m_window setContentView:m_impl->m_view];
        [[m_impl->m_view openGLContext] makeCurrentContext];
        
        // TODO: set vsync
        
        // Zoom and fullscreen buttons: hidden by default.
        [m_impl->m_window standardWindowButton:NSWindowZoomButton].hidden = YES;
        [m_impl->m_window standardWindowButton:NSWindowFullScreenButton].hidden = YES;
    }
    
    CocoaWindow::~CocoaWindow()
    { }
    
    Size CocoaWindow::GetActualSize()
    {
        NSRect frame = [[m_impl->m_window contentView] frame];
        return Size(frame.size.width, frame.size.height);
    }
    
    void CocoaWindow::SetTitle(const std::wstring& title)
    {
        // NYI
    }
    
    void CocoaWindow::SetIcon(const std::wstring& filename)
    {
        // NYI
    }
    
    void CocoaWindow::SetClientSize(const Size& size)
    {
        NSRect prev = [m_impl->m_window frame];
        NSRect next = NSMakeRect(prev.origin.x, prev.origin.y, size.width, size.height);
        NSRect frame = [m_impl->m_window frameRectForContentRect:next];
        [m_impl->m_window setFrame:frame display:YES];
        m_client_size = size;
        // send TK_RESIZE event?
    }
    
    void CocoaWindow::Show()
    {
        [NSApp unhide:nil];
        [m_impl->m_window makeKeyAndOrderFront:nil];
        [m_impl->m_window makeMainWindow];
    }
    
    void CocoaWindow::Hide()
    {
        [m_impl->m_window resignKeyWindow];
        [NSApp hide:nil];
    }
    
    void CocoaWindow::SwapBuffers()
    {
        if (m_impl->m_view == nil)
            return;
        [[m_impl->m_view openGLContext] flushBuffer];
    }
    
    void CocoaWindow::SetVSync(bool enabled)
    {
        // NYI
    }
    
    void CocoaWindow::ApplySizeHints()
    {
        // Enforce discrete size increments...
        NSSize increment = NSMakeSize(m_impl->m_increment.width, m_impl->m_increment.height);
        [m_impl->m_window setContentResizeIncrements:increment];
        
        // ...and minimum size
        NSRect inner = NSMakeRect
            (
                0, 0,
                m_impl->m_minimum_size.width * m_impl->m_increment.width,
                m_impl->m_minimum_size.height * m_impl->m_increment.height
            );
        NSRect outer = [m_impl->m_window frameRectForContentRect:inner];
        NSSize minimum = NSMakeSize(outer.size.width, outer.size.height);
        [m_impl->m_window setMinSize:minimum];
    }
    
    void CocoaWindow::SetSizeHints(Size increment, Size minimum_size)
    {
        m_impl->m_increment = increment;
        m_impl->m_minimum_size = minimum_size;
        
        if (m_impl->m_resizeable)
            ApplySizeHints();
    }
    
    void CocoaWindow::SetResizeable(bool resizeable)
    {
        // Window bar buttons.
        [m_impl->m_window standardWindowButton:NSWindowZoomButton].hidden = !resizeable;
        [m_impl->m_window standardWindowButton:NSWindowFullScreenButton].hidden = !resizeable;
     
        // Window style that actually make window resizeable.
        if (resizeable)
        {
            [m_impl->m_window setStyleMask:[m_impl->m_window styleMask] | NSResizableWindowMask];
            ApplySizeHints();
        }
        else
        {
            [m_impl->m_window setStyleMask:[m_impl->m_window styleMask] & ~NSResizableWindowMask];
        }
        
        m_impl->m_resizeable = resizeable;
    }
    
    void CocoaWindow::SetFullscreen(bool fullscreen)
    {
        // NYI
    }
    
    void CocoaWindow::SetCursorVisibility(bool visible)
    {
        // NYI
    }
    
    int CocoaWindow::PumpEvents()
    {
        int processed = 0;
        while (true)
        {
            NSEvent* event = [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:nil inMode:NSDefaultRunLoopMode dequeue:YES];
            if (event == nil)
                break;
            [NSApp sendEvent:event];
            processed += 1;
        }
        
        return processed;
    }
}

@implementation CocoaTerminalApplication

// Appkit bug workaround:
// http://cocoadev.com/index.pl?GameKeyboardHandlingAlmost
- (void)sendEvent:(NSEvent*)e
{
    if ([e type] == NSKeyUp && ([e modifierFlags] & NSCommandKeyMask))
        [[self keyWindow] sendEvent:e];
    else
        [super sendEvent:e];
}

@end

@implementation CocoaTerminalApplicationDelegate

- (NSApplicationTerminateReply)applicationShouldTerminate: (NSApplication*)sender
{
    return NSTerminateCancel;
}

- (void)applicationDidFinishLaunching: (NSNotification*)notification
{
    [NSApp stop:nil];
}

@end

@implementation CocoaTerminalWindow

- (id)initWithImpl:(BearLibTerminal::CocoaWindow::Impl*)impl styleMask:(NSUInteger)mask
{
    NSRect rect = NSMakeRect(0, 0, 100, 100);
    self = [super initWithContentRect:rect styleMask:mask backing:NSBackingStoreBuffered defer:NO];
    if (self != nil)
        m_impl = impl;
    return self;
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)keyDown:(NSEvent*)e
{
    m_impl->HandleEvent(e);
}

- (void)keyUp:(NSEvent*)e
{
    m_impl->HandleEvent(e);
}

- (void)flagsChanged:(NSEvent*)e
{
    m_impl->HandleEvent(e);
}

- (void)mouseMoved:(NSEvent*)e
{
    m_impl->HandleEvent(e);
}

- (void)scrollWheel:(NSEvent*)e
{
    m_impl->HandleEvent(e);
}

- (void)mouseDown:(NSEvent *)e
{
    m_impl->HandleEvent(e);
}

- (void)mouseUp:(NSEvent*)e
{
    m_impl->HandleEvent(e);
}

- (void)mouseDragged:(NSEvent*)e
{
    m_impl->HandleEvent(e);
}

- (void)rightMouseDown:(NSEvent *)e
{
    m_impl->HandleEvent(e);
}

- (void)rightMouseUp:(NSEvent*)e
{
    m_impl->HandleEvent(e);
}

- (void)rightMouseDragged:(NSEvent*)e
{
    m_impl->HandleEvent(e);
}

- (void)otherMouseDown:(NSEvent *)e
{
    m_impl->HandleEvent(e);
}

- (void)otherMouseUp:(NSEvent*)e
{
    m_impl->HandleEvent(e);
}

- (void)otherMouseDragged:(NSEvent*)e
{
    m_impl->HandleEvent(e);
}

// TODO: other event handlers

@end

@implementation CocoaTerminalWindowDelegate

- (id)initWithImpl: (BearLibTerminal::CocoaWindow::Impl*)impl
{
    self = [super init];
    if (self != nil)
        m_impl = impl;
    return self;
}

- (BOOL)windowShouldClose:(id)sender
{
    m_impl->m_handler(TK_CLOSE);
    return NO;
}

- (NSSize)windowWillResize:(id)sender toSize:(NSSize)frameSize
{
    return m_impl->HandleWindowWillResize(frameSize);
}

- (void)windowDidResize:(NSNotification*)notification
{
    m_impl->HandleWindowDidResize();
}

- (void)windowDidMiniaturize:(NSNotification *)notification
{
    // Leave fullscreen?
}

- (void)windowDidDeminiaturize:(NSNotification *)notification
{
    // Restore fullscreen?
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    // ?
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    // ?
}

@end

#endif // __APPLE__
