#import <Cocoa/Cocoa.h>

// Keep the platform boundary as a tiny C ABI. Menu commands are polled by the
// Sokol frame callback and then published through the Odin event bus.
enum {
    BS_MENU_NONE = 0,
    BS_MENU_SETTINGS = 1,
    BS_MENU_EXPORT = 2,
    BS_MENU_CLEAR = 3,
};

static NSInteger pendingAction = BS_MENU_NONE;

@interface BSMenuActions : NSObject
- (void)openSettings:(id)sender;
- (void)exportPNG:(id)sender;
- (void)clearCanvas:(id)sender;
@end

@implementation BSMenuActions
- (void)openSettings:(id)sender { pendingAction = BS_MENU_SETTINGS; }
- (void)exportPNG:(id)sender { pendingAction = BS_MENU_EXPORT; }
- (void)clearCanvas:(id)sender { pendingAction = BS_MENU_CLEAR; }
@end

static BSMenuActions *menuActions;

static NSMenuItem *AddItem(NSMenu *menu, NSString *title, SEL action, NSString *key)
{
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:key];
    [menu addItem:item];
    return item;
}

void bs_native_menu_install(void)
{
    @autoreleasepool {
        menuActions = [[BSMenuActions alloc] init];

        NSMenu *mainMenu = [[NSMenu alloc] initWithTitle:@"Main Menu"];
        [NSApp setMainMenu:mainMenu];

        NSMenuItem *applicationRoot = [[NSMenuItem alloc] initWithTitle:@"BitSpryte" action:nil keyEquivalent:@""];
        [mainMenu addItem:applicationRoot];
        NSMenu *applicationMenu = [[NSMenu alloc] initWithTitle:@"BitSpryte"];
        [applicationRoot setSubmenu:applicationMenu];

        AddItem(applicationMenu, @"About BitSpryte", @selector(orderFrontStandardAboutPanel:), @"");
        [applicationMenu addItem:[NSMenuItem separatorItem]];
        NSMenuItem *settings = AddItem(applicationMenu, @"Settings…", @selector(openSettings:), @",");
        [settings setTarget:menuActions];
        [applicationMenu addItem:[NSMenuItem separatorItem]];
        AddItem(applicationMenu, @"Hide BitSpryte", @selector(hide:), @"h");
        NSMenuItem *hideOthers = AddItem(applicationMenu, @"Hide Others", @selector(hideOtherApplications:), @"h");
        [hideOthers setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagOption];
        AddItem(applicationMenu, @"Show All", @selector(unhideAllApplications:), @"");
        [applicationMenu addItem:[NSMenuItem separatorItem]];
        AddItem(applicationMenu, @"Quit BitSpryte", @selector(terminate:), @"q");

        NSMenuItem *fileRoot = [[NSMenuItem alloc] initWithTitle:@"File" action:nil keyEquivalent:@""];
        [mainMenu addItem:fileRoot];
        NSMenu *fileMenu = [[NSMenu alloc] initWithTitle:@"File"];
        [fileRoot setSubmenu:fileMenu];
        NSMenuItem *exportItem = AddItem(fileMenu, @"Export PNG…", @selector(exportPNG:), @"e");
        [exportItem setTarget:menuActions];

        NSMenuItem *editRoot = [[NSMenuItem alloc] initWithTitle:@"Edit" action:nil keyEquivalent:@""];
        [mainMenu addItem:editRoot];
        NSMenu *editMenu = [[NSMenu alloc] initWithTitle:@"Edit"];
        [editRoot setSubmenu:editMenu];
        NSMenuItem *clearItem = AddItem(editMenu, @"Clear Canvas", @selector(clearCanvas:), @"");
        [clearItem setTarget:menuActions];

        NSMenuItem *windowRoot = [[NSMenuItem alloc] initWithTitle:@"Window" action:nil keyEquivalent:@""];
        [mainMenu addItem:windowRoot];
        NSMenu *windowMenu = [[NSMenu alloc] initWithTitle:@"Window"];
        [windowRoot setSubmenu:windowMenu];
        AddItem(windowMenu, @"Minimize", @selector(performMiniaturize:), @"m");
        AddItem(windowMenu, @"Zoom", @selector(performZoom:), @"");
        [windowMenu addItem:[NSMenuItem separatorItem]];
        AddItem(windowMenu, @"Bring All to Front", @selector(arrangeInFront:), @"");
        [NSApp setWindowsMenu:windowMenu];
    }
}

int bs_native_menu_take_action(void)
{
    NSInteger action = pendingAction;
    pendingAction = BS_MENU_NONE;
    return (int)action;
}
