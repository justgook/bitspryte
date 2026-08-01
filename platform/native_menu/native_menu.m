#import <Cocoa/Cocoa.h>

// Keep this order synchronized with app/actions.Kind.
typedef NS_ENUM(NSInteger, BSAction) {
    BSActionNone = 0,
    BSActionNewFile,
    BSActionOpenFile,
    BSActionSaveFile,
    BSActionSaveFileAs,
    BSActionCloseFile,
    BSActionCloseAllFiles,
    BSActionExportAs,
    BSActionExportSpriteSheet,
    BSActionExportTileset,
    BSActionRepeatLastExport,
    BSActionImportSpriteSheet,
    BSActionUndo,
    BSActionRedo,
    BSActionCut,
    BSActionCopy,
    BSActionCopyMerged,
    BSActionPaste,
    BSActionClear,
    BSActionFill,
    BSActionStroke,
    BSActionRotate180,
    BSActionRotate90CW,
    BSActionRotate90CCW,
    BSActionFlipHorizontal,
    BSActionFlipVertical,
    BSActionPreferences,
    BSActionSpriteProperties,
    BSActionColorModeRGB,
    BSActionColorModeGrayscale,
    BSActionColorModeIndexed,
    BSActionDuplicateSprite,
    BSActionSpriteSize,
    BSActionCanvasSize,
    BSActionRotateCanvas180,
    BSActionRotateCanvas90CW,
    BSActionRotateCanvas90CCW,
    BSActionFlipCanvasHorizontal,
    BSActionFlipCanvasVertical,
    BSActionCropSprite,
    BSActionTrimSprite,
    BSActionLayerProperties,
    BSActionLayerVisible,
    BSActionLayerLock,
    BSActionLayerNew,
    BSActionLayerNewGroup,
    BSActionLayerNewViaCopy,
    BSActionLayerNewViaCut,
    BSActionLayerNewTilemap,
    BSActionLayerDelete,
    BSActionLayerDuplicate,
    BSActionLayerMergeDown,
    BSActionLayerFlatten,
    BSActionLayerFlattenVisible,
    BSActionFrameProperties,
    BSActionCelProperties,
    BSActionFrameNew,
    BSActionFrameNewEmpty,
    BSActionFrameDuplicate,
    BSActionFrameDuplicateLinked,
    BSActionFrameDelete,
    BSActionAnimationPlay,
    BSActionFrameTagNew,
    BSActionFrameTagDelete,
    BSActionFrameFirst,
    BSActionFramePrevious,
    BSActionFrameNext,
    BSActionFrameLast,
    BSActionFrameReverse,
    BSActionSelectAll,
    BSActionSelectDeselect,
    BSActionSelectReselect,
    BSActionSelectInverse,
    BSActionSelectColorRange,
    BSActionSelectModifyBorder,
    BSActionSelectModifyExpand,
    BSActionSelectModifyContract,
    BSActionSelectLoad,
    BSActionSelectSave,
    BSActionViewDuplicate,
    BSActionViewShowExtras,
    BSActionViewShowGrid,
    BSActionViewShowPixelGrid,
    BSActionViewSnapToGrid,
    BSActionViewTiledNone,
    BSActionViewTiledBoth,
    BSActionViewTiledX,
    BSActionViewTiledY,
    BSActionViewOnionSkin,
    BSActionViewTimeline,
    BSActionViewPreview,
    BSActionViewFullscreen,
    BSActionViewRefresh,
    BSActionWindowMinimize,
    BSActionWindowZoom,
    BSActionWindowBringAllToFront,
    BSActionHelpQuickReference,
    BSActionHelpDocumentation,
    BSActionHelpTutorial,
    BSActionHelpReleaseNotes,
    BSActionHelpAbout,
};

static NSInteger pendingAction = BSActionNone;

@interface BSMenuActions : NSObject
- (void)performAction:(id)sender;
@end

@implementation BSMenuActions
- (void)performAction:(id)sender
{
    pendingAction = [sender tag];
    switch (pendingAction) {
        case BSActionWindowMinimize:
            [[NSApp keyWindow] performMiniaturize:sender];
            break;
        case BSActionWindowZoom:
            [[NSApp keyWindow] performZoom:sender];
            break;
        case BSActionWindowBringAllToFront:
            [NSApp arrangeInFront:sender];
            break;
        case BSActionHelpAbout:
            [NSApp orderFrontStandardAboutPanel:sender];
            break;
        default:
            break;
    }
}
@end

static BSMenuActions *menuActions;

static NSMenuItem *AddItem(NSMenu *menu, NSString *title, SEL selector, NSString *key)
{
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:selector keyEquivalent:key];
    [menu addItem:item];
    return item;
}

static NSMenuItem *AddAction(NSMenu *menu, NSString *title, BSAction action, NSString *key)
{
    NSMenuItem *item = AddItem(menu, title, @selector(performAction:), key);
    [item setTarget:menuActions];
    [item setTag:action];
    return item;
}

static NSMenu *AddMenu(NSMenu *parent, NSString *title)
{
    NSMenuItem *root = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
    NSMenu *menu = [[NSMenu alloc] initWithTitle:title];
    [root setSubmenu:menu];
    [parent addItem:root];
    return menu;
}

void bs_native_menu_install(void)
{
    @autoreleasepool {
        menuActions = [[BSMenuActions alloc] init];
        NSMenu *main = [[NSMenu alloc] initWithTitle:@"Main Menu"];
        [NSApp setMainMenu:main];

        NSMenu *application = AddMenu(main, @"BitSpryte");
        AddItem(application, @"About BitSpryte", @selector(orderFrontStandardAboutPanel:), @"");
        [application addItem:[NSMenuItem separatorItem]];
        AddAction(application, @"Settings…", BSActionPreferences, @",");
        [application addItem:[NSMenuItem separatorItem]];
        AddItem(application, @"Hide BitSpryte", @selector(hide:), @"h");
        NSMenuItem *hideOthers = AddItem(application, @"Hide Others", @selector(hideOtherApplications:), @"h");
        [hideOthers setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagOption];
        AddItem(application, @"Show All", @selector(unhideAllApplications:), @"");
        [application addItem:[NSMenuItem separatorItem]];
        AddItem(application, @"Quit BitSpryte", @selector(terminate:), @"q");

        NSMenu *file = AddMenu(main, @"File");
        AddAction(file, @"New…", BSActionNewFile, @"n");
        AddAction(file, @"Open…", BSActionOpenFile, @"o");
        [file addItem:[NSMenuItem separatorItem]];
        AddAction(file, @"Save", BSActionSaveFile, @"s");
        NSMenuItem *saveAs = AddAction(file, @"Save As…", BSActionSaveFileAs, @"s");
        [saveAs setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagShift];
        AddAction(file, @"Close", BSActionCloseFile, @"w");
        NSMenuItem *closeAll = AddAction(file, @"Close All", BSActionCloseAllFiles, @"w");
        [closeAll setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagShift];
        [file addItem:[NSMenuItem separatorItem]];
        NSMenu *exportMenu = AddMenu(file, @"Export");
        AddAction(exportMenu, @"Export As…", BSActionExportAs, @"");
        AddAction(exportMenu, @"Export Sprite Sheet…", BSActionExportSpriteSheet, @"e");
        [exportMenu addItem:[NSMenuItem separatorItem]];
        AddAction(exportMenu, @"Export Tileset…", BSActionExportTileset, @"");
        [exportMenu addItem:[NSMenuItem separatorItem]];
        AddAction(exportMenu, @"Repeat Last Export", BSActionRepeatLastExport, @"");
        NSMenu *importMenu = AddMenu(file, @"Import");
        AddAction(importMenu, @"Import Sprite Sheet…", BSActionImportSpriteSheet, @"i");

        NSMenu *edit = AddMenu(main, @"Edit");
        AddAction(edit, @"Undo", BSActionUndo, @"z");
        NSMenuItem *redo = AddAction(edit, @"Redo", BSActionRedo, @"z");
        [redo setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagShift];
        [edit addItem:[NSMenuItem separatorItem]];
        AddAction(edit, @"Cut", BSActionCut, @"x");
        AddAction(edit, @"Copy", BSActionCopy, @"c");
        NSMenuItem *copyMerged = AddAction(edit, @"Copy Merged", BSActionCopyMerged, @"c");
        [copyMerged setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagShift];
        AddAction(edit, @"Paste", BSActionPaste, @"v");
        AddAction(edit, @"Clear", BSActionClear, @"");
        [edit addItem:[NSMenuItem separatorItem]];
        AddAction(edit, @"Fill", BSActionFill, @"");
        AddAction(edit, @"Stroke", BSActionStroke, @"");
        [edit addItem:[NSMenuItem separatorItem]];
        NSMenu *rotate = AddMenu(edit, @"Rotate");
        AddAction(rotate, @"180°", BSActionRotate180, @"");
        AddAction(rotate, @"90° CW", BSActionRotate90CW, @"");
        AddAction(rotate, @"90° CCW", BSActionRotate90CCW, @"");
        AddAction(edit, @"Flip Horizontal", BSActionFlipHorizontal, @"");
        AddAction(edit, @"Flip Vertical", BSActionFlipVertical, @"");
        [edit addItem:[NSMenuItem separatorItem]];
        AddAction(edit, @"Preferences…", BSActionPreferences, @",");

        NSMenu *sprite = AddMenu(main, @"Sprite");
        AddAction(sprite, @"Properties…", BSActionSpriteProperties, @"");
        NSMenu *colorMode = AddMenu(sprite, @"Color Mode");
        AddAction(colorMode, @"RGB Color", BSActionColorModeRGB, @"");
        AddAction(colorMode, @"Grayscale", BSActionColorModeGrayscale, @"");
        AddAction(colorMode, @"Indexed", BSActionColorModeIndexed, @"");
        [sprite addItem:[NSMenuItem separatorItem]];
        AddAction(sprite, @"Duplicate", BSActionDuplicateSprite, @"");
        [sprite addItem:[NSMenuItem separatorItem]];
        AddAction(sprite, @"Sprite Size…", BSActionSpriteSize, @"");
        AddAction(sprite, @"Canvas Size…", BSActionCanvasSize, @"");
        NSMenu *rotateCanvas = AddMenu(sprite, @"Rotate Canvas");
        AddAction(rotateCanvas, @"180°", BSActionRotateCanvas180, @"");
        AddAction(rotateCanvas, @"90° CW", BSActionRotateCanvas90CW, @"");
        AddAction(rotateCanvas, @"90° CCW", BSActionRotateCanvas90CCW, @"");
        AddAction(rotateCanvas, @"Flip Horizontal", BSActionFlipCanvasHorizontal, @"");
        AddAction(rotateCanvas, @"Flip Vertical", BSActionFlipCanvasVertical, @"");
        [sprite addItem:[NSMenuItem separatorItem]];
        AddAction(sprite, @"Crop", BSActionCropSprite, @"");
        AddAction(sprite, @"Trim", BSActionTrimSprite, @"");

        NSMenu *layer = AddMenu(main, @"Layer");
        AddAction(layer, @"Properties…", BSActionLayerProperties, @"");
        AddAction(layer, @"Visible", BSActionLayerVisible, @"");
        AddAction(layer, @"Lock", BSActionLayerLock, @"");
        [layer addItem:[NSMenuItem separatorItem]];
        NSMenu *newLayer = AddMenu(layer, @"New");
        AddAction(newLayer, @"New Layer", BSActionLayerNew, @"");
        AddAction(newLayer, @"New Group", BSActionLayerNewGroup, @"");
        [newLayer addItem:[NSMenuItem separatorItem]];
        AddAction(newLayer, @"Layer via Copy", BSActionLayerNewViaCopy, @"");
        AddAction(newLayer, @"Layer via Cut", BSActionLayerNewViaCut, @"");
        [newLayer addItem:[NSMenuItem separatorItem]];
        AddAction(newLayer, @"New Tilemap Layer", BSActionLayerNewTilemap, @"");
        AddAction(layer, @"Delete Layer", BSActionLayerDelete, @"");
        [layer addItem:[NSMenuItem separatorItem]];
        AddAction(layer, @"Duplicate", BSActionLayerDuplicate, @"");
        AddAction(layer, @"Merge Down", BSActionLayerMergeDown, @"");
        AddAction(layer, @"Flatten", BSActionLayerFlatten, @"");
        AddAction(layer, @"Flatten Visible", BSActionLayerFlattenVisible, @"");

        NSMenu *frame = AddMenu(main, @"Frame");
        AddAction(frame, @"Frame Properties…", BSActionFrameProperties, @"");
        AddAction(frame, @"Cel Properties…", BSActionCelProperties, @"");
        [frame addItem:[NSMenuItem separatorItem]];
        AddAction(frame, @"New Frame", BSActionFrameNew, @"");
        AddAction(frame, @"New Empty Frame", BSActionFrameNewEmpty, @"");
        AddAction(frame, @"Duplicate Cels", BSActionFrameDuplicate, @"");
        AddAction(frame, @"Duplicate Linked Cels", BSActionFrameDuplicateLinked, @"");
        AddAction(frame, @"Delete Frame", BSActionFrameDelete, @"");
        [frame addItem:[NSMenuItem separatorItem]];
        AddAction(frame, @"Play Animation", BSActionAnimationPlay, @"");
        NSMenu *tags = AddMenu(frame, @"Tags");
        AddAction(tags, @"New Tag", BSActionFrameTagNew, @"");
        AddAction(tags, @"Delete Tag", BSActionFrameTagDelete, @"");
        NSMenu *jump = AddMenu(frame, @"Jump To");
        AddAction(jump, @"First Frame", BSActionFrameFirst, @"");
        AddAction(jump, @"Previous Frame", BSActionFramePrevious, @"");
        AddAction(jump, @"Next Frame", BSActionFrameNext, @"");
        AddAction(jump, @"Last Frame", BSActionFrameLast, @"");
        [frame addItem:[NSMenuItem separatorItem]];
        AddAction(frame, @"Reverse Frames", BSActionFrameReverse, @"");

        NSMenu *select = AddMenu(main, @"Select");
        AddAction(select, @"All", BSActionSelectAll, @"a");
        AddAction(select, @"Deselect", BSActionSelectDeselect, @"d");
        AddAction(select, @"Reselect", BSActionSelectReselect, @"");
        AddAction(select, @"Inverse", BSActionSelectInverse, @"");
        [select addItem:[NSMenuItem separatorItem]];
        AddAction(select, @"Color Range…", BSActionSelectColorRange, @"");
        NSMenu *modify = AddMenu(select, @"Modify");
        AddAction(modify, @"Border…", BSActionSelectModifyBorder, @"");
        AddAction(modify, @"Expand…", BSActionSelectModifyExpand, @"");
        AddAction(modify, @"Contract…", BSActionSelectModifyContract, @"");
        [select addItem:[NSMenuItem separatorItem]];
        AddAction(select, @"Load from File…", BSActionSelectLoad, @"");
        AddAction(select, @"Save to File…", BSActionSelectSave, @"");

        NSMenu *view = AddMenu(main, @"View");
        AddAction(view, @"Duplicate View", BSActionViewDuplicate, @"");
        AddAction(view, @"Show Extras", BSActionViewShowExtras, @"");
        NSMenu *show = AddMenu(view, @"Show");
        AddAction(show, @"Grid", BSActionViewShowGrid, @"");
        AddAction(show, @"Pixel Grid", BSActionViewShowPixelGrid, @"");
        AddAction(show, @"Snap to Grid", BSActionViewSnapToGrid, @"");
        NSMenu *tiled = AddMenu(view, @"Tiled Mode");
        AddAction(tiled, @"None", BSActionViewTiledNone, @"");
        AddAction(tiled, @"Both Axes", BSActionViewTiledBoth, @"");
        AddAction(tiled, @"Horizontal", BSActionViewTiledX, @"");
        AddAction(tiled, @"Vertical", BSActionViewTiledY, @"");
        [view addItem:[NSMenuItem separatorItem]];
        AddAction(view, @"Onion Skin", BSActionViewOnionSkin, @"");
        AddAction(view, @"Timeline", BSActionViewTimeline, @"");
        AddAction(view, @"Preview", BSActionViewPreview, @"");
        AddAction(view, @"Fullscreen", BSActionViewFullscreen, @"");
        [view addItem:[NSMenuItem separatorItem]];
        AddAction(view, @"Refresh", BSActionViewRefresh, @"");

        NSMenu *window = AddMenu(main, @"Window");
        AddAction(window, @"Minimize", BSActionWindowMinimize, @"m");
        AddAction(window, @"Zoom", BSActionWindowZoom, @"");
        [window addItem:[NSMenuItem separatorItem]];
        AddAction(window, @"Bring All to Front", BSActionWindowBringAllToFront, @"");
        [NSApp setWindowsMenu:window];

        NSMenu *help = AddMenu(main, @"Help");
        AddAction(help, @"Quick Reference", BSActionHelpQuickReference, @"");
        AddAction(help, @"Documentation", BSActionHelpDocumentation, @"");
        AddAction(help, @"Tutorial", BSActionHelpTutorial, @"");
        [help addItem:[NSMenuItem separatorItem]];
        AddAction(help, @"Release Notes", BSActionHelpReleaseNotes, @"");
        [help addItem:[NSMenuItem separatorItem]];
        AddAction(help, @"About BitSpryte", BSActionHelpAbout, @"");
    }
}

int bs_native_menu_action_count(void)
{
    return (int)BSActionHelpAbout + 1;
}

int bs_native_menu_take_action(void)
{
    NSInteger action = pendingAction;
    pendingAction = BSActionNone;
    return (int)action;
}
