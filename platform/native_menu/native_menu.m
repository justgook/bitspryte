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
    BSActionUndoHistory,
    BSActionCut,
    BSActionCopy,
    BSActionCopyMerged,
    BSActionPaste,
    BSActionPasteAsNewSprite,
    BSActionPasteAsNewLayer,
    BSActionPasteAsNewReferenceLayer,
    BSActionClear,
    BSActionFill,
    BSActionStroke,
    BSActionRotate180,
    BSActionRotate90CW,
    BSActionRotate90CCW,
    BSActionFlipHorizontal,
    BSActionFlipVertical,
    BSActionTransform,
    BSActionShiftLeft,
    BSActionShiftRight,
    BSActionShiftUp,
    BSActionShiftDown,
    BSActionNewBrush,
    BSActionNewSpriteFromSelection,
    BSActionReplaceColor,
    BSActionInvert,
    BSActionAdjustBrightnessContrast,
    BSActionAdjustHueSaturation,
    BSActionAdjustColorCurve,
    BSActionFXOutline,
    BSActionFXConvolutionMatrix,
    BSActionFXDespeckle,
    BSActionInsertText,
    BSActionKeyboardShortcuts,
    BSActionPreferences,
    BSActionSpriteProperties,
    BSActionColorModeRGB,
    BSActionColorModeGrayscale,
    BSActionColorModeIndexed,
    BSActionColorModeMoreOptions,
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
    BSActionLayerOpenGroup,
    BSActionLayerNew,
    BSActionLayerNewGroup,
    BSActionLayerNewViaCopy,
    BSActionLayerNewViaCut,
    BSActionLayerNewReferenceFromFile,
    BSActionLayerNewTilemap,
    BSActionLayerDelete,
    BSActionLayerConvertToBackground,
    BSActionLayerConvertToLayer,
    BSActionLayerConvertToTilemap,
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
    BSActionAnimationPlayPreview,
    BSActionPlaybackSpeed025,
    BSActionPlaybackSpeed05,
    BSActionPlaybackSpeed1,
    BSActionPlaybackSpeed15,
    BSActionPlaybackSpeed2,
    BSActionPlaybackSpeed3,
    BSActionPlaybackPlayOnce,
    BSActionPlaybackPlayAllFrames,
    BSActionPlaybackPlaySubtagsRepetitions,
    BSActionPlaybackRewindOnStop,
    BSActionFrameTagProperties,
    BSActionFrameTagNew,
    BSActionFrameTagDelete,
    BSActionFrameFirst,
    BSActionFramePrevious,
    BSActionFrameNext,
    BSActionFrameLast,
    BSActionFrameFirstInTag,
    BSActionFrameLastInTag,
    BSActionFrameGoTo,
    BSActionFrameConstantRate,
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
    BSActionViewWorkspaceLayout,
    BSActionViewRunCommand,
    BSActionViewShowExtras,
    BSActionViewShowLayerEdges,
    BSActionViewShowSelectionEdges,
    BSActionViewShowGrid,
    BSActionViewShowAutoGuides,
    BSActionViewShowSlices,
    BSActionViewShowPixelGrid,
    BSActionViewShowTileNumbers,
    BSActionViewShowBrushPreview,
    BSActionViewGridSettings,
    BSActionViewSelectionAsGrid,
    BSActionViewSnapToGrid,
    BSActionViewTiledNone,
    BSActionViewTiledBoth,
    BSActionViewTiledX,
    BSActionViewTiledY,
    BSActionViewSymmetryOptions,
    BSActionViewSetLoopSection,
    BSActionViewOnionSkin,
    BSActionViewTimeline,
    BSActionViewPreview,
    BSActionViewPreviewHideOtherLayers,
    BSActionViewPreviewBrush,
    BSActionViewAdvancedMode,
    BSActionViewFullscreen,
    BSActionViewFullscreenPreview,
    BSActionViewHome,
    BSActionViewRefresh,
    BSActionViewEnterFullscreen,
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
        case BSActionColorModeRGB:
        case BSActionColorModeGrayscale:
        case BSActionColorModeIndexed: {
            NSMenuItem *selectedItem = (NSMenuItem *)sender;
            for (NSMenuItem *item in [[selectedItem menu] itemArray]) {
                NSInteger tag = [item tag];
                if (tag == BSActionColorModeRGB || tag == BSActionColorModeGrayscale || tag == BSActionColorModeIndexed) {
                    [item setState:NSControlStateValueOff];
                }
            }
            [selectedItem setState:NSControlStateValueOn];
            break;
        }
        case BSActionViewTiledNone:
        case BSActionViewTiledBoth:
        case BSActionViewTiledX:
        case BSActionViewTiledY: {
            NSMenuItem *selectedItem = (NSMenuItem *)sender;
            for (NSMenuItem *item in [[selectedItem menu] itemArray]) {
                NSInteger tag = [item tag];
                if (tag >= BSActionViewTiledNone && tag <= BSActionViewTiledY) {
                    [item setState:NSControlStateValueOff];
                }
            }
            [selectedItem setState:NSControlStateValueOn];
            break;
        }
        case BSActionPlaybackSpeed025:
        case BSActionPlaybackSpeed05:
        case BSActionPlaybackSpeed1:
        case BSActionPlaybackSpeed15:
        case BSActionPlaybackSpeed2:
        case BSActionPlaybackSpeed3: {
            NSMenuItem *selectedItem = (NSMenuItem *)sender;
            for (NSMenuItem *item in [[selectedItem menu] itemArray]) {
                NSInteger tag = [item tag];
                if (tag >= BSActionPlaybackSpeed025 && tag <= BSActionPlaybackSpeed3) {
                    [item setState:NSControlStateValueOff];
                }
            }
            [selectedItem setState:NSControlStateValueOn];
            break;
        }
        case BSActionLayerVisible:
        case BSActionLayerLock:
        case BSActionLayerOpenGroup:
        case BSActionPlaybackPlayOnce:
        case BSActionPlaybackPlayAllFrames:
        case BSActionPlaybackPlaySubtagsRepetitions:
        case BSActionPlaybackRewindOnStop:
        case BSActionFrameConstantRate:
        case BSActionViewShowExtras:
        case BSActionViewShowLayerEdges:
        case BSActionViewShowSelectionEdges:
        case BSActionViewShowGrid:
        case BSActionViewShowAutoGuides:
        case BSActionViewShowSlices:
        case BSActionViewShowPixelGrid:
        case BSActionViewShowTileNumbers:
        case BSActionViewShowBrushPreview:
        case BSActionViewSnapToGrid:
        case BSActionViewSymmetryOptions:
        case BSActionViewOnionSkin:
        case BSActionViewTimeline: {
            NSMenuItem *item = (NSMenuItem *)sender;
            [item setState:[item state] == NSControlStateValueOn ? NSControlStateValueOff : NSControlStateValueOn];
            break;
        }
        case BSActionViewEnterFullscreen:
            [[NSApp keyWindow] toggleFullScreen:sender];
            break;
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
        AddMenu(file, @"Open Recent");
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
        AddAction(edit, @"Redo", BSActionRedo, @"y");
        AddAction(edit, @"Undo History", BSActionUndoHistory, @"");
        [edit addItem:[NSMenuItem separatorItem]];
        AddAction(edit, @"Cut", BSActionCut, @"x");
        AddAction(edit, @"Copy", BSActionCopy, @"c");
        NSMenuItem *copyMerged = AddAction(edit, @"Copy Merged", BSActionCopyMerged, @"c");
        [copyMerged setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagShift];
        AddAction(edit, @"Paste", BSActionPaste, @"v");
        NSMenu *pasteSpecial = AddMenu(edit, @"Paste Special");
        AddAction(pasteSpecial, @"Paste as New Sprite", BSActionPasteAsNewSprite, @"");
        NSMenuItem *pasteAsNewLayer = AddAction(pasteSpecial, @"Paste as New Layer", BSActionPasteAsNewLayer, @"v");
        [pasteAsNewLayer setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagShift];
        AddAction(pasteSpecial, @"Paste as New Reference Layer", BSActionPasteAsNewReferenceLayer, @"");
        NSMenuItem *deleteItem = AddAction(edit, @"Delete", BSActionClear, @"\x7f");
        [deleteItem setKeyEquivalentModifierMask:0];
        [edit addItem:[NSMenuItem separatorItem]];
        NSMenuItem *fill = AddAction(edit, @"Fill", BSActionFill, @"f");
        [fill setKeyEquivalentModifierMask:0];
        NSMenuItem *stroke = AddAction(edit, @"Stroke", BSActionStroke, @"s");
        [stroke setKeyEquivalentModifierMask:0];
        [edit addItem:[NSMenuItem separatorItem]];
        NSMenu *rotate = AddMenu(edit, @"Rotate");
        AddAction(rotate, @"180°", BSActionRotate180, @"");
        AddAction(rotate, @"90° CW", BSActionRotate90CW, @"");
        AddAction(rotate, @"90° CCW", BSActionRotate90CCW, @"");
        NSMenuItem *flipHorizontal = AddAction(edit, @"Flip Horizontal", BSActionFlipHorizontal, @"h");
        [flipHorizontal setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        NSMenuItem *flipVertical = AddAction(edit, @"Flip Vertical", BSActionFlipVertical, @"v");
        [flipVertical setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        AddAction(edit, @"Transform", BSActionTransform, @"t");
        NSMenu *shift = AddMenu(edit, @"Shift");
        AddAction(shift, @"Left", BSActionShiftLeft, @"");
        AddAction(shift, @"Right", BSActionShiftRight, @"");
        AddAction(shift, @"Up", BSActionShiftUp, @"");
        AddAction(shift, @"Down", BSActionShiftDown, @"");
        [edit addItem:[NSMenuItem separatorItem]];
        AddAction(edit, @"New Brush", BSActionNewBrush, @"b");
        NSMenuItem *newSpriteFromSelection = AddAction(edit, @"New Sprite From Selection", BSActionNewSpriteFromSelection, @"n");
        [newSpriteFromSelection setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagOption];
        [edit addItem:[NSMenuItem separatorItem]];
        NSMenuItem *replaceColor = AddAction(edit, @"Replace Color…", BSActionReplaceColor, @"r");
        [replaceColor setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        AddAction(edit, @"Invert…", BSActionInvert, @"");
        NSMenu *adjustments = AddMenu(edit, @"Adjustments");
        AddAction(adjustments, @"Brightness/Contrast…", BSActionAdjustBrightnessContrast, @"");
        AddAction(adjustments, @"Hue/Saturation…", BSActionAdjustHueSaturation, @"u");
        NSMenuItem *colorCurve = AddAction(adjustments, @"Color Curve…", BSActionAdjustColorCurve, @"m");
        [colorCurve setKeyEquivalentModifierMask:NSEventModifierFlagControl];
        NSMenu *fx = AddMenu(edit, @"FX");
        NSMenuItem *outline = AddAction(fx, @"Outline", BSActionFXOutline, @"o");
        [outline setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        NSString *f9Key = [NSString stringWithFormat:@"%C", (unichar)NSF9FunctionKey];
        NSMenuItem *convolutionMatrix = AddAction(fx, @"Convolution Matrix…", BSActionFXConvolutionMatrix, f9Key);
        [convolutionMatrix setKeyEquivalentModifierMask:0];
        AddAction(fx, @"Despeckle (Median Filter)…", BSActionFXDespeckle, @"");
        AddAction(edit, @"Insert Text", BSActionInsertText, @"");
        [edit addItem:[NSMenuItem separatorItem]];
        NSMenuItem *keyboardShortcuts = AddAction(edit, @"Keyboard Shortcuts…", BSActionKeyboardShortcuts, @"k");
        [keyboardShortcuts setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagOption | NSEventModifierFlagShift];
        AddAction(edit, @"Preferences…", BSActionPreferences, @",");

        NSMenu *sprite = AddMenu(main, @"Sprite");
        [sprite setAutoenablesItems:NO];
        AddAction(sprite, @"Properties…", BSActionSpriteProperties, @"p");
        NSMenu *colorMode = AddMenu(sprite, @"Color Mode");
        NSMenuItem *rgbColor = AddAction(colorMode, @"RGB Color", BSActionColorModeRGB, @"");
        [rgbColor setState:NSControlStateValueOn];
        AddAction(colorMode, @"Grayscale", BSActionColorModeGrayscale, @"");
        AddAction(colorMode, @"Indexed", BSActionColorModeIndexed, @"");
        [colorMode addItem:[NSMenuItem separatorItem]];
        AddAction(colorMode, @"More Options", BSActionColorModeMoreOptions, @"");
        [sprite addItem:[NSMenuItem separatorItem]];
        AddAction(sprite, @"Duplicate…", BSActionDuplicateSprite, @"");
        [sprite addItem:[NSMenuItem separatorItem]];
        NSMenuItem *spriteSize = AddAction(sprite, @"Sprite Size…", BSActionSpriteSize, @"i");
        [spriteSize setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagOption];
        NSMenuItem *canvasSize = AddAction(sprite, @"Canvas Size…", BSActionCanvasSize, @"c");
        [canvasSize setKeyEquivalentModifierMask:0];
        NSMenu *rotateCanvas = AddMenu(sprite, @"Rotate Canvas");
        AddAction(rotateCanvas, @"180°", BSActionRotateCanvas180, @"");
        AddAction(rotateCanvas, @"90° CW", BSActionRotateCanvas90CW, @"");
        AddAction(rotateCanvas, @"90° CCW", BSActionRotateCanvas90CCW, @"");
        AddAction(rotateCanvas, @"Flip Horizontal", BSActionFlipCanvasHorizontal, @"");
        AddAction(rotateCanvas, @"Flip Vertical", BSActionFlipCanvasVertical, @"");
        [sprite addItem:[NSMenuItem separatorItem]];
        NSMenuItem *crop = AddAction(sprite, @"Crop", BSActionCropSprite, @"");
        [crop setEnabled:NO];
        AddAction(sprite, @"Trim", BSActionTrimSprite, @"");

        NSMenu *layer = AddMenu(main, @"Layer");
        [layer setAutoenablesItems:NO];
        NSMenuItem *layerProperties = AddAction(layer, @"Properties…", BSActionLayerProperties, @"p");
        [layerProperties setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagShift];
        NSMenuItem *layerVisible = AddAction(layer, @"Visible", BSActionLayerVisible, @"x");
        [layerVisible setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagShift];
        [layerVisible setState:NSControlStateValueOn];
        NSMenuItem *lockLayers = AddAction(layer, @"Lock Layers", BSActionLayerLock, @"");
        [lockLayers setState:NSControlStateValueOn];
        NSMenuItem *openGroup = AddAction(layer, @"Open Group", BSActionLayerOpenGroup, @"e");
        [openGroup setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagShift];
        [openGroup setState:NSControlStateValueOn];
        [layer addItem:[NSMenuItem separatorItem]];
        NSMenu *newLayer = AddMenu(layer, @"New…");
        NSMenuItem *newLayerItem = AddAction(newLayer, @"New Layer", BSActionLayerNew, @"n");
        [newLayerItem setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagShift];
        NSMenuItem *newGroup = AddAction(newLayer, @"New Group", BSActionLayerNewGroup, @"n");
        [newGroup setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagOption | NSEventModifierFlagShift];
        [newLayer addItem:[NSMenuItem separatorItem]];
        AddAction(newLayer, @"New Layer via Copy", BSActionLayerNewViaCopy, @"j");
        NSMenuItem *newLayerViaCut = AddAction(newLayer, @"New Layer via Cut", BSActionLayerNewViaCut, @"j");
        [newLayerViaCut setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagShift];
        [newLayer addItem:[NSMenuItem separatorItem]];
        AddAction(newLayer, @"New Reference Layer from File", BSActionLayerNewReferenceFromFile, @"");
        AddAction(newLayer, @"New Tilemap Layer", BSActionLayerNewTilemap, @"");
        AddAction(layer, @"Delete Layer", BSActionLayerDelete, @"");
        NSMenu *convertTo = AddMenu(layer, @"Convert To…");
        [convertTo setAutoenablesItems:NO];
        NSMenuItem *convertToBackground = AddAction(convertTo, @"Background", BSActionLayerConvertToBackground, @"");
        [convertToBackground setEnabled:NO];
        NSMenuItem *convertToLayer = AddAction(convertTo, @"Layer", BSActionLayerConvertToLayer, @"");
        [convertToLayer setEnabled:NO];
        [convertTo addItem:[NSMenuItem separatorItem]];
        NSMenuItem *convertToTilemap = AddAction(convertTo, @"Tilemap", BSActionLayerConvertToTilemap, @"");
        [convertToTilemap setEnabled:NO];
        [layer addItem:[NSMenuItem separatorItem]];
        AddAction(layer, @"Duplicate", BSActionLayerDuplicate, @"");
        NSMenuItem *mergeDown = AddAction(layer, @"Merge Down", BSActionLayerMergeDown, @"");
        [mergeDown setEnabled:NO];
        AddAction(layer, @"Flatten", BSActionLayerFlatten, @"");
        AddAction(layer, @"Flatten Visible", BSActionLayerFlattenVisible, @"");

        NSMenu *frame = AddMenu(main, @"Frame");
        [frame setAutoenablesItems:NO];
        NSMenuItem *frameProperties = AddAction(frame, @"Frame Properties…", BSActionFrameProperties, @"p");
        [frameProperties setKeyEquivalentModifierMask:0];
        AddAction(frame, @"Cel Properties…", BSActionCelProperties, @"");
        [frame addItem:[NSMenuItem separatorItem]];
        NSMenuItem *newFrame = AddAction(frame, @"New Frame", BSActionFrameNew, @"n");
        [newFrame setKeyEquivalentModifierMask:NSEventModifierFlagOption];
        NSMenuItem *newEmptyFrame = AddAction(frame, @"New Empty Frame", BSActionFrameNewEmpty, @"b");
        [newEmptyFrame setKeyEquivalentModifierMask:NSEventModifierFlagOption];
        NSMenuItem *duplicateCels = AddAction(frame, @"Duplicate Cel(s)", BSActionFrameDuplicate, @"d");
        [duplicateCels setKeyEquivalentModifierMask:NSEventModifierFlagOption];
        NSMenuItem *duplicateLinkedCels = AddAction(frame, @"Duplicate Linked Cel(s)", BSActionFrameDuplicateLinked, @"m");
        [duplicateLinkedCels setKeyEquivalentModifierMask:NSEventModifierFlagOption];
        NSMenuItem *deleteFrame = AddAction(frame, @"Delete Frame", BSActionFrameDelete, @"c");
        [deleteFrame setKeyEquivalentModifierMask:NSEventModifierFlagOption];
        [deleteFrame setEnabled:NO];
        [frame addItem:[NSMenuItem separatorItem]];

        NSMenu *playback = AddMenu(frame, @"Playback");
        NSMenuItem *playAnimation = AddAction(playback, @"Play Animation", BSActionAnimationPlay, @"\r");
        [playAnimation setKeyEquivalentModifierMask:0];
        NSMenuItem *playPreviewAnimation = AddAction(playback, @"Play Preview Animation", BSActionAnimationPlayPreview, @"\r");
        [playPreviewAnimation setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        [playback addItem:[NSMenuItem separatorItem]];
        AddAction(playback, @"Playback Speed 0.25x", BSActionPlaybackSpeed025, @"");
        AddAction(playback, @"Playback Speed 0.5x", BSActionPlaybackSpeed05, @"");
        NSMenuItem *playbackSpeed1 = AddAction(playback, @"Playback Speed 1x", BSActionPlaybackSpeed1, @"");
        [playbackSpeed1 setState:NSControlStateValueOn];
        AddAction(playback, @"Playback Speed 1.5x", BSActionPlaybackSpeed15, @"");
        AddAction(playback, @"Playback Speed 2x", BSActionPlaybackSpeed2, @"");
        AddAction(playback, @"Playback Speed 3x", BSActionPlaybackSpeed3, @"");
        [playback addItem:[NSMenuItem separatorItem]];
        AddAction(playback, @"Play Once", BSActionPlaybackPlayOnce, @"");
        AddAction(playback, @"Play All Frames (Ignore Tags)", BSActionPlaybackPlayAllFrames, @"");
        NSMenuItem *playSubtags = AddAction(playback, @"Play Subtags & Repetitions", BSActionPlaybackPlaySubtagsRepetitions, @"");
        [playSubtags setState:NSControlStateValueOn];
        [playback addItem:[NSMenuItem separatorItem]];
        AddAction(playback, @"Rewind on Stop", BSActionPlaybackRewindOnStop, @"");

        NSMenu *tags = AddMenu(frame, @"Tags");
        AddAction(tags, @"Tag Properties…", BSActionFrameTagProperties, @"");
        [tags addItem:[NSMenuItem separatorItem]];
        AddAction(tags, @"New Tag", BSActionFrameTagNew, @"");
        AddAction(tags, @"Delete Tag", BSActionFrameTagDelete, @"");

        NSMenu *jump = AddMenu(frame, @"Jump to");
        NSString *homeKey = [NSString stringWithFormat:@"%C", (unichar)NSHomeFunctionKey];
        NSMenuItem *firstFrame = AddAction(jump, @"First Frame", BSActionFrameFirst, homeKey);
        [firstFrame setKeyEquivalentModifierMask:0];
        AddAction(jump, @"Previous Frame", BSActionFramePrevious, @"");
        AddAction(jump, @"Next Frame", BSActionFrameNext, @"");
        NSString *endKey = [NSString stringWithFormat:@"%C", (unichar)NSEndFunctionKey];
        NSMenuItem *lastFrame = AddAction(jump, @"Last Frame", BSActionFrameLast, endKey);
        [lastFrame setKeyEquivalentModifierMask:0];
        [jump addItem:[NSMenuItem separatorItem]];
        AddAction(jump, @"First Frame In Tag", BSActionFrameFirstInTag, @"");
        AddAction(jump, @"Last Frame In Tag", BSActionFrameLastInTag, @"");
        [jump addItem:[NSMenuItem separatorItem]];
        NSMenuItem *goToFrame = AddAction(jump, @"Go to Frame", BSActionFrameGoTo, @"g");
        [goToFrame setKeyEquivalentModifierMask:NSEventModifierFlagOption];

        [frame addItem:[NSMenuItem separatorItem]];
        AddAction(frame, @"Constant Frame Rate", BSActionFrameConstantRate, @"");
        NSMenuItem *reverseFrames = AddAction(frame, @"Reverse Frames", BSActionFrameReverse, @"i");
        [reverseFrames setKeyEquivalentModifierMask:NSEventModifierFlagOption];
        [reverseFrames setEnabled:NO];

        NSMenu *select = AddMenu(main, @"Select");
        [select setAutoenablesItems:NO];
        AddAction(select, @"All", BSActionSelectAll, @"a");
        AddAction(select, @"Deselect", BSActionSelectDeselect, @"d");
        NSMenuItem *reselect = AddAction(select, @"Reselect", BSActionSelectReselect, @"d");
        [reselect setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagShift];
        [reselect setEnabled:NO];
        NSMenuItem *inverse = AddAction(select, @"Inverse", BSActionSelectInverse, @"i");
        [inverse setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagShift];
        [select addItem:[NSMenuItem separatorItem]];
        AddAction(select, @"Color Range", BSActionSelectColorRange, @"");
        NSMenu *modify = AddMenu(select, @"Modify");
        AddAction(modify, @"Border", BSActionSelectModifyBorder, @"");
        AddAction(modify, @"Expand", BSActionSelectModifyExpand, @"");
        AddAction(modify, @"Contract", BSActionSelectModifyContract, @"");
        [select addItem:[NSMenuItem separatorItem]];
        AddAction(select, @"Load from MSK file", BSActionSelectLoad, @"");
        AddAction(select, @"Save to MSK file", BSActionSelectSave, @"");

        NSMenu *view = AddMenu(main, @"View");
        AddAction(view, @"Duplicate View", BSActionViewDuplicate, @"");
        NSMenuItem *workspaceLayout = AddAction(view, @"Workspace Layout", BSActionViewWorkspaceLayout, @"w");
        [workspaceLayout setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        NSMenuItem *runCommand = AddAction(view, @"Run Command", BSActionViewRunCommand, @" ");
        [runCommand setKeyEquivalentModifierMask:NSEventModifierFlagControl];
        [view addItem:[NSMenuItem separatorItem]];

        NSMenuItem *extras = AddAction(view, @"Extras", BSActionViewShowExtras, @"h");
        [extras setKeyEquivalentModifierMask:NSEventModifierFlagControl];
        [extras setState:NSControlStateValueOn];
        NSMenu *show = AddMenu(view, @"Show");
        AddAction(show, @"Layer Edges", BSActionViewShowLayerEdges, @"");
        NSMenuItem *selectionEdges = AddAction(show, @"Selection Edges", BSActionViewShowSelectionEdges, @"");
        [selectionEdges setState:NSControlStateValueOn];
        AddAction(show, @"Grid", BSActionViewShowGrid, @"'");
        NSMenuItem *autoGuides = AddAction(show, @"Auto Guides", BSActionViewShowAutoGuides, @"");
        [autoGuides setState:NSControlStateValueOn];
        NSMenuItem *slices = AddAction(show, @"Slices", BSActionViewShowSlices, @"");
        [slices setState:NSControlStateValueOn];
        NSMenuItem *pixelGrid = AddAction(show, @"Pixel Grid", BSActionViewShowPixelGrid, @"'");
        [pixelGrid setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagShift];
        NSMenuItem *tileNumbers = AddAction(show, @"Tile Numbers", BSActionViewShowTileNumbers, @"");
        [tileNumbers setState:NSControlStateValueOn];
        [show addItem:[NSMenuItem separatorItem]];
        NSMenuItem *showBrushPreview = AddAction(show, @"Brush Preview", BSActionViewShowBrushPreview, @"");
        [showBrushPreview setState:NSControlStateValueOn];
        [view addItem:[NSMenuItem separatorItem]];

        NSMenu *grid = AddMenu(view, @"Grid");
        AddAction(grid, @"Grid Settings", BSActionViewGridSettings, @"");
        AddAction(grid, @"Selection as Grid", BSActionViewSelectionAsGrid, @"");
        NSMenuItem *snapToGrid = AddAction(grid, @"Snap to Grid", BSActionViewSnapToGrid, @"s");
        [snapToGrid setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        NSMenu *tiled = AddMenu(view, @"Tiled Mode");
        NSMenuItem *tiledNone = AddAction(tiled, @"None", BSActionViewTiledNone, @"");
        [tiledNone setState:NSControlStateValueOn];
        AddAction(tiled, @"Tiled in Both Axes", BSActionViewTiledBoth, @"");
        AddAction(tiled, @"Tiled in X Axis", BSActionViewTiledX, @"");
        AddAction(tiled, @"Tiled in Y Axis", BSActionViewTiledY, @"");
        NSMenuItem *symmetryOptions = AddAction(view, @"Symmetry Options", BSActionViewSymmetryOptions, @"");
        [symmetryOptions setState:NSControlStateValueOn];
        [view addItem:[NSMenuItem separatorItem]];

        AddAction(view, @"Set Loop Section", BSActionViewSetLoopSection, @"");
        NSString *f3Key = [NSString stringWithFormat:@"%C", (unichar)NSF3FunctionKey];
        NSMenuItem *showOnionSkin = AddAction(view, @"Show Onion Skin", BSActionViewOnionSkin, f3Key);
        [showOnionSkin setKeyEquivalentModifierMask:0];
        [view addItem:[NSMenuItem separatorItem]];

        NSMenuItem *timeline = AddAction(view, @"Timeline", BSActionViewTimeline, @"\t");
        [timeline setKeyEquivalentModifierMask:0];
        [timeline setState:NSControlStateValueOn];
        NSMenu *preview = AddMenu(view, @"Preview");
        NSString *f7Key = [NSString stringWithFormat:@"%C", (unichar)NSF7FunctionKey];
        NSMenuItem *previewAction = AddAction(preview, @"Preview", BSActionViewPreview, f7Key);
        [previewAction setKeyEquivalentModifierMask:0];
        [preview addItem:[NSMenuItem separatorItem]];
        NSMenuItem *hideOtherLayers = AddAction(preview, @"Hide Other Layers", BSActionViewPreviewHideOtherLayers, f7Key);
        [hideOtherLayers setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        AddAction(preview, @"Brush Preview", BSActionViewPreviewBrush, @"");
        NSMenuItem *advancedMode = AddAction(view, @"Advanced Mode", BSActionViewAdvancedMode, @"f");
        [advancedMode setKeyEquivalentModifierMask:NSEventModifierFlagControl];
        NSMenuItem *fullScreenMode = AddAction(view, @"Full Screen Mode", BSActionViewFullscreen, @"f");
        [fullScreenMode setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagControl];
        NSString *f8Key = [NSString stringWithFormat:@"%C", (unichar)NSF8FunctionKey];
        NSMenuItem *fullScreenPreview = AddAction(view, @"Full Screen Preview", BSActionViewFullscreenPreview, f8Key);
        [fullScreenPreview setKeyEquivalentModifierMask:0];
        AddAction(view, @"Home", BSActionViewHome, @"");
        [view addItem:[NSMenuItem separatorItem]];

        NSString *f5Key = [NSString stringWithFormat:@"%C", (unichar)NSF5FunctionKey];
        NSMenuItem *refresh = AddAction(view, @"Refresh & Reload Theme", BSActionViewRefresh, f5Key);
        [refresh setKeyEquivalentModifierMask:0];
        NSMenuItem *enterFullscreen = AddAction(view, @"Enter Full Screen", BSActionViewEnterFullscreen, @"f");
        [enterFullscreen setKeyEquivalentModifierMask:NSEventModifierFlagFunction];

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
