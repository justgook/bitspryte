package native_menu

import actions "../../app/actions"
import intrinsics "base:intrinsics"
import F "core:sys/darwin/Foundation"

when ODIN_OS == .Darwin {

	msg_send :: intrinsics.objc_send

	@(objc_class = "BSMenuActions")
	Menu_Actions :: struct {
		using _: F.Object,
	}

	menu_actions: ^Menu_Actions
	pending_action: actions.Kind

	ns_string :: proc "c" (text: cstring) -> ^F.String {
		value := F.String_initWithCString(F.String_alloc(), text, .UTF8)
		msg_send(nil, value, "autorelease")
		return value
	}

	new_menu :: proc "c" (title: cstring) -> ^F.Menu {
		return F.Menu_initWithTitle(F.alloc(F.Menu), ns_string(title))
	}

	add_item :: proc "c" (menu: ^F.Menu, title, selector, key: cstring) -> ^F.MenuItem {
		action: F.SEL
		if len(string(selector)) != 0 {
			action = F.sel_registerName(selector)
		}
		item := F.MenuItem_initWithTitle(F.alloc(F.MenuItem), ns_string(title), action, ns_string(key))
		F.Menu_addItem(menu, item)
		return item
	}

	add_action :: proc "c" (menu: ^F.Menu, title: cstring, action: actions.Kind, key: cstring) -> ^F.MenuItem {
		item := add_item(menu, title, "performAction:", key)
		F.MenuItem_setTarget(item, auto_cast menu_actions)
		F.MenuItem_setTag(item, F.Integer(action))
		return item
	}

	add_menu :: proc "c" (parent: ^F.Menu, title: cstring) -> ^F.Menu {
		root := add_item(parent, title, "", "")
		menu := new_menu(title)
		F.MenuItem_setSubmenu(root, menu)
		return menu
	}

	add_separator :: proc "c" (menu: ^F.Menu) {
		F.Menu_addItem(menu, F.MenuItem_separatorItem())
	}

	set_modifiers :: proc "c" (item: ^F.MenuItem, modifiers: F.EventModifierFlags) {
		F.MenuItem_setKeyEquivalentModifierMask(item, modifiers)
	}

	Menu_State :: enum F.Integer {
		Off = 0,
		On  = 1,
	}

	set_state :: proc "c" (item: ^F.MenuItem, state: Menu_State) {
		msg_send(nil, item, "setState:", state)
	}

	state :: proc "c" (item: ^F.MenuItem) -> Menu_State {
		return msg_send(Menu_State, item, "state")
	}

	set_enabled :: proc "c" (item: ^F.MenuItem, enabled: bool) {
		F.MenuItem_setEnabled(item, enabled)
	}

	set_autoenables :: proc "c" (menu: ^F.Menu, enabled: bool) {
		F.Menu_setAutoenablesItems(menu, enabled)
	}

	set_exclusive_state :: proc "c" (selected: ^F.MenuItem, first, last: actions.Kind) {
		menu := F.MenuItem_menu(selected)
		count := F.Menu_numberOfItems(menu)
		for index in 0 ..< count {
			item := F.Menu_itemAtIndex(menu, index)
			action := actions.Kind(F.MenuItem_tag(item))
			if action >= first && action <= last {
				set_state(item, .Off)
			}
		}
		set_state(selected, .On)
	}

	perform_action :: proc "c" (_: F.id, _: F.SEL, sender: F.id) {
		item: ^F.MenuItem = auto_cast sender
		pending_action = actions.Kind(F.MenuItem_tag(item))

		#partial switch pending_action {
		case .Color_Mode_RGB, .Color_Mode_Grayscale, .Color_Mode_Indexed:
			set_exclusive_state(item, .Color_Mode_RGB, .Color_Mode_Indexed)
		case .View_Tiled_None, .View_Tiled_Both, .View_Tiled_X, .View_Tiled_Y:
			set_exclusive_state(item, .View_Tiled_None, .View_Tiled_Y)
		case .Playback_Speed_025,
		     .Playback_Speed_05,
		     .Playback_Speed_1,
		     .Playback_Speed_15,
		     .Playback_Speed_2,
		     .Playback_Speed_3:
			set_exclusive_state(item, .Playback_Speed_025, .Playback_Speed_3)
		case .Layer_Visible,
		     .Layer_Lock,
		     .Layer_Open_Group,
		     .Playback_Play_Once,
		     .Playback_Play_All_Frames,
		     .Playback_Play_Subtags_Repetitions,
		     .Playback_Rewind_On_Stop,
		     .Frame_Constant_Rate,
		     .View_Show_Extras,
		     .View_Show_Layer_Edges,
		     .View_Show_Selection_Edges,
		     .View_Show_Grid,
		     .View_Show_Auto_Guides,
		     .View_Show_Slices,
		     .View_Show_Pixel_Grid,
		     .View_Show_Tile_Numbers,
		     .View_Show_Brush_Preview,
		     .View_Snap_To_Grid,
		     .View_Symmetry_Options,
		     .View_Onion_Skin,
		     .View_Timeline:
			set_state(item, state(item) == .On ? .Off : .On)
		case .View_Enter_Fullscreen:
			window := F.Application_keyWindow(F.Application_sharedApplication())
			F.Window_toggleFullScreen(window, sender)
		case .Window_Minimize:
			window := F.Application_keyWindow(F.Application_sharedApplication())
			msg_send(nil, window, "performMiniaturize:", sender)
		case .Window_Zoom:
			window := F.Application_keyWindow(F.Application_sharedApplication())
			msg_send(nil, window, "performZoom:", sender)
		case .Window_Bring_All_To_Front:
			msg_send(nil, F.Application_sharedApplication(), "arrangeInFront:", sender)
		case .Help_About:
			msg_send(nil, F.Application_sharedApplication(), "orderFrontStandardAboutPanel:", sender)
		case:
		}
	}

	new_menu_actions :: proc "c" () -> ^Menu_Actions {
		class := F.objc_lookUpClass("BSMenuActions")
		if class == nil {
			class = F.objc_allocateClassPair(F.objc_lookUpClass("NSObject"), "BSMenuActions", {})
			if class == nil {
				return nil
			}
			if !F.class_addMethod(class, F.sel_registerName("performAction:"), auto_cast perform_action, "v@:@") {
				F.objc_disposeClassPair(class)
				return nil
			}
			F.objc_registerClassPair(class)
		}
		instance: ^Menu_Actions = auto_cast F.class_createInstance(class, {})
		return F.init(instance)
	}

	install :: proc() {
		_ = F.scoped_autoreleasepool()
		app := F.Application_sharedApplication()
		menu_actions = new_menu_actions()
		assert(menu_actions != nil)
		main := new_menu("Main Menu")
		F.Application_setMainMenu(app, main)
		application := add_menu(main, "BitSpryte")
		add_item(application, "About BitSpryte", "orderFrontStandardAboutPanel:", "")
		add_separator(application)
		add_action(application, "Settings…", .Preferences, ",")
		add_separator(application)
		add_item(application, "Hide BitSpryte", "hide:", "h")
		hideOthers := add_item(application, "Hide Others", "hideOtherApplications:", "h")
		set_modifiers(hideOthers, {.Command, .Option})
		add_item(application, "Show All", "unhideAllApplications:", "")
		add_separator(application)
		add_item(application, "Quit BitSpryte", "terminate:", "q")
		file := add_menu(main, "File")
		add_action(file, "New…", .New_File, "n")
		add_action(file, "Open…", .Open_File, "o")
		add_menu(file, "Open Recent")
		add_separator(file)
		add_action(file, "Save", .Save_File, "s")
		saveAs := add_action(file, "Save As…", .Save_File_As, "s")
		set_modifiers(saveAs, {.Command, .Shift})
		add_action(file, "Close", .Close_File, "w")
		closeAll := add_action(file, "Close All", .Close_All_Files, "w")
		set_modifiers(closeAll, {.Command, .Shift})
		add_separator(file)
		exportMenu := add_menu(file, "Export")
		add_action(exportMenu, "Export As…", .Export_As, "")
		add_action(exportMenu, "Export Sprite Sheet…", .Export_Sprite_Sheet, "e")
		add_separator(exportMenu)
		add_action(exportMenu, "Export Tileset…", .Export_Tileset, "")
		add_separator(exportMenu)
		add_action(exportMenu, "Repeat Last Export", .Repeat_Last_Export, "")
		importMenu := add_menu(file, "Import")
		add_action(importMenu, "Import Sprite Sheet…", .Import_Sprite_Sheet, "i")
		edit := add_menu(main, "Edit")
		add_action(edit, "Undo", .Undo, "z")
		add_action(edit, "Redo", .Redo, "y")
		add_action(edit, "Undo History", .Undo_History, "")
		add_separator(edit)
		add_action(edit, "Cut", .Cut, "x")
		add_action(edit, "Copy", .Copy, "c")
		copyMerged := add_action(edit, "Copy Merged", .Copy_Merged, "c")
		set_modifiers(copyMerged, {.Command, .Shift})
		add_action(edit, "Paste", .Paste, "v")
		pasteSpecial := add_menu(edit, "Paste Special")
		add_action(pasteSpecial, "Paste as New Sprite", .Paste_As_New_Sprite, "")
		pasteAsNewLayer := add_action(pasteSpecial, "Paste as New Layer", .Paste_As_New_Layer, "v")
		set_modifiers(pasteAsNewLayer, {.Command, .Shift})
		add_action(pasteSpecial, "Paste as New Reference Layer", .Paste_As_New_Reference_Layer, "")
		deleteItem := add_action(edit, "Delete", .Clear, "\x7f")
		set_modifiers(deleteItem, {})
		add_separator(edit)
		fill := add_action(edit, "Fill", .Fill, "f")
		set_modifiers(fill, {})
		stroke := add_action(edit, "Stroke", .Stroke, "s")
		set_modifiers(stroke, {})
		add_separator(edit)
		rotate := add_menu(edit, "Rotate")
		add_action(rotate, "180°", .Rotate_180, "")
		add_action(rotate, "90° CW", .Rotate_90_CW, "")
		add_action(rotate, "90° CCW", .Rotate_90_CCW, "")
		flipHorizontal := add_action(edit, "Flip Horizontal", .Flip_Horizontal, "h")
		set_modifiers(flipHorizontal, {.Shift})
		flipVertical := add_action(edit, "Flip Vertical", .Flip_Vertical, "v")
		set_modifiers(flipVertical, {.Shift})
		add_action(edit, "Transform", .Transform, "t")
		shift := add_menu(edit, "Shift")
		add_action(shift, "Left", .Shift_Left, "")
		add_action(shift, "Right", .Shift_Right, "")
		add_action(shift, "Up", .Shift_Up, "")
		add_action(shift, "Down", .Shift_Down, "")
		add_separator(edit)
		add_action(edit, "New Brush", .New_Brush, "b")
		newSpriteFromSelection := add_action(edit, "New Sprite From Selection", .New_Sprite_From_Selection, "n")
		set_modifiers(newSpriteFromSelection, {.Command, .Option})
		add_separator(edit)
		replaceColor := add_action(edit, "Replace Color…", .Replace_Color, "r")
		set_modifiers(replaceColor, {.Shift})
		add_action(edit, "Invert…", .Invert, "")
		adjustments := add_menu(edit, "Adjustments")
		add_action(adjustments, "Brightness/Contrast…", .Adjust_Brightness_Contrast, "")
		add_action(adjustments, "Hue/Saturation…", .Adjust_Hue_Saturation, "u")
		colorCurve := add_action(adjustments, "Color Curve…", .Adjust_Color_Curve, "m")
		set_modifiers(colorCurve, {.Control})
		fx := add_menu(edit, "FX")
		outline := add_action(fx, "Outline", .FX_Outline, "o")
		set_modifiers(outline, {.Shift})
		f9Key: cstring = "\uf70c"
		convolutionMatrix := add_action(fx, "Convolution Matrix…", .FX_Convolution_Matrix, f9Key)
		set_modifiers(convolutionMatrix, {})
		add_action(fx, "Despeckle (Median Filter)…", .FX_Despeckle, "")
		add_action(edit, "Insert Text", .Insert_Text, "")
		add_separator(edit)
		keyboardShortcuts := add_action(edit, "Keyboard Shortcuts…", .Keyboard_Shortcuts, "k")
		set_modifiers(keyboardShortcuts, {.Command, .Option, .Shift})
		add_action(edit, "Preferences…", .Preferences, ",")
		sprite := add_menu(main, "Sprite")
		set_autoenables(sprite, false)
		add_action(sprite, "Properties…", .Sprite_Properties, "p")
		colorMode := add_menu(sprite, "Color Mode")
		rgbColor := add_action(colorMode, "RGB Color", .Color_Mode_RGB, "")
		set_state(rgbColor, .On)
		add_action(colorMode, "Grayscale", .Color_Mode_Grayscale, "")
		add_action(colorMode, "Indexed", .Color_Mode_Indexed, "")
		add_separator(colorMode)
		add_action(colorMode, "More Options", .Color_Mode_More_Options, "")
		add_separator(sprite)
		add_action(sprite, "Duplicate…", .Duplicate_Sprite, "")
		add_separator(sprite)
		spriteSize := add_action(sprite, "Sprite Size…", .Sprite_Size, "i")
		set_modifiers(spriteSize, {.Command, .Option})
		canvasSize := add_action(sprite, "Canvas Size…", .Canvas_Size, "c")
		set_modifiers(canvasSize, {})
		rotateCanvas := add_menu(sprite, "Rotate Canvas")
		add_action(rotateCanvas, "180°", .Rotate_Canvas_180, "")
		add_action(rotateCanvas, "90° CW", .Rotate_Canvas_90_CW, "")
		add_action(rotateCanvas, "90° CCW", .Rotate_Canvas_90_CCW, "")
		add_action(rotateCanvas, "Flip Horizontal", .Flip_Canvas_Horizontal, "")
		add_action(rotateCanvas, "Flip Vertical", .Flip_Canvas_Vertical, "")
		add_separator(sprite)
		crop := add_action(sprite, "Crop", .Crop_Sprite, "")
		set_enabled(crop, false)
		add_action(sprite, "Trim", .Trim_Sprite, "")
		layer := add_menu(main, "Layer")
		set_autoenables(layer, false)
		layerProperties := add_action(layer, "Properties…", .Layer_Properties, "p")
		set_modifiers(layerProperties, {.Command, .Shift})
		layerVisible := add_action(layer, "Visible", .Layer_Visible, "x")
		set_modifiers(layerVisible, {.Command, .Shift})
		set_state(layerVisible, .On)
		lockLayers := add_action(layer, "Lock Layers", .Layer_Lock, "")
		set_state(lockLayers, .On)
		openGroup := add_action(layer, "Open Group", .Layer_Open_Group, "e")
		set_modifiers(openGroup, {.Command, .Shift})
		set_state(openGroup, .On)
		add_separator(layer)
		newLayer := add_menu(layer, "New…")
		newLayerItem := add_action(newLayer, "New Layer", .Layer_New, "n")
		set_modifiers(newLayerItem, {.Command, .Shift})
		newGroup := add_action(newLayer, "New Group", .Layer_New_Group, "n")
		set_modifiers(newGroup, {.Command, .Option, .Shift})
		add_separator(newLayer)
		add_action(newLayer, "New Layer via Copy", .Layer_New_Via_Copy, "j")
		newLayerViaCut := add_action(newLayer, "New Layer via Cut", .Layer_New_Via_Cut, "j")
		set_modifiers(newLayerViaCut, {.Command, .Shift})
		add_separator(newLayer)
		add_action(newLayer, "New Reference Layer from File", .Layer_New_Reference_From_File, "")
		add_action(newLayer, "New Tilemap Layer", .Layer_New_Tilemap, "")
		add_action(layer, "Delete Layer", .Layer_Delete, "")
		convertTo := add_menu(layer, "Convert To…")
		set_autoenables(convertTo, false)
		convertToBackground := add_action(convertTo, "Background", .Layer_Convert_To_Background, "")
		set_enabled(convertToBackground, false)
		convertToLayer := add_action(convertTo, "Layer", .Layer_Convert_To_Layer, "")
		set_enabled(convertToLayer, false)
		add_separator(convertTo)
		convertToTilemap := add_action(convertTo, "Tilemap", .Layer_Convert_To_Tilemap, "")
		set_enabled(convertToTilemap, false)
		add_separator(layer)
		add_action(layer, "Duplicate", .Layer_Duplicate, "")
		mergeDown := add_action(layer, "Merge Down", .Layer_Merge_Down, "")
		set_enabled(mergeDown, false)
		add_action(layer, "Flatten", .Layer_Flatten, "")
		add_action(layer, "Flatten Visible", .Layer_Flatten_Visible, "")
		frame := add_menu(main, "Frame")
		set_autoenables(frame, false)
		frameProperties := add_action(frame, "Frame Properties…", .Frame_Properties, "p")
		set_modifiers(frameProperties, {})
		add_action(frame, "Cel Properties…", .Cel_Properties, "")
		add_separator(frame)
		newFrame := add_action(frame, "New Frame", .Frame_New, "n")
		set_modifiers(newFrame, {.Option})
		newEmptyFrame := add_action(frame, "New Empty Frame", .Frame_New_Empty, "b")
		set_modifiers(newEmptyFrame, {.Option})
		duplicateCels := add_action(frame, "Duplicate Cel(s)", .Frame_Duplicate, "d")
		set_modifiers(duplicateCels, {.Option})
		duplicateLinkedCels := add_action(frame, "Duplicate Linked Cel(s)", .Frame_Duplicate_Linked, "m")
		set_modifiers(duplicateLinkedCels, {.Option})
		deleteFrame := add_action(frame, "Delete Frame", .Frame_Delete, "c")
		set_modifiers(deleteFrame, {.Option})
		set_enabled(deleteFrame, false)
		add_separator(frame)
		playback := add_menu(frame, "Playback")
		playAnimation := add_action(playback, "Play Animation", .Animation_Play, "\r")
		set_modifiers(playAnimation, {})
		playPreviewAnimation := add_action(playback, "Play Preview Animation", .Animation_Play_Preview, "\r")
		set_modifiers(playPreviewAnimation, {.Shift})
		add_separator(playback)
		add_action(playback, "Playback Speed 0.25x", .Playback_Speed_025, "")
		add_action(playback, "Playback Speed 0.5x", .Playback_Speed_05, "")
		playbackSpeed1 := add_action(playback, "Playback Speed 1x", .Playback_Speed_1, "")
		set_state(playbackSpeed1, .On)
		add_action(playback, "Playback Speed 1.5x", .Playback_Speed_15, "")
		add_action(playback, "Playback Speed 2x", .Playback_Speed_2, "")
		add_action(playback, "Playback Speed 3x", .Playback_Speed_3, "")
		add_separator(playback)
		add_action(playback, "Play Once", .Playback_Play_Once, "")
		add_action(playback, "Play All Frames (Ignore Tags)", .Playback_Play_All_Frames, "")
		playSubtags := add_action(playback, "Play Subtags & Repetitions", .Playback_Play_Subtags_Repetitions, "")
		set_state(playSubtags, .On)
		add_separator(playback)
		add_action(playback, "Rewind on Stop", .Playback_Rewind_On_Stop, "")
		tags := add_menu(frame, "Tags")
		add_action(tags, "Tag Properties…", .Frame_Tag_Properties, "")
		add_separator(tags)
		add_action(tags, "New Tag", .Frame_Tag_New, "")
		add_action(tags, "Delete Tag", .Frame_Tag_Delete, "")
		jump := add_menu(frame, "Jump to")
		homeKey: cstring = "\uf729"
		firstFrame := add_action(jump, "First Frame", .Frame_First, homeKey)
		set_modifiers(firstFrame, {})
		add_action(jump, "Previous Frame", .Frame_Previous, "")
		add_action(jump, "Next Frame", .Frame_Next, "")
		endKey: cstring = "\uf72b"
		lastFrame := add_action(jump, "Last Frame", .Frame_Last, endKey)
		set_modifiers(lastFrame, {})
		add_separator(jump)
		add_action(jump, "First Frame In Tag", .Frame_First_In_Tag, "")
		add_action(jump, "Last Frame In Tag", .Frame_Last_In_Tag, "")
		add_separator(jump)
		goToFrame := add_action(jump, "Go to Frame", .Frame_Go_To, "g")
		set_modifiers(goToFrame, {.Option})
		add_separator(frame)
		add_action(frame, "Constant Frame Rate", .Frame_Constant_Rate, "")
		reverseFrames := add_action(frame, "Reverse Frames", .Frame_Reverse, "i")
		set_modifiers(reverseFrames, {.Option})
		set_enabled(reverseFrames, false)
		select := add_menu(main, "Select")
		set_autoenables(select, false)
		add_action(select, "All", .Select_All, "a")
		add_action(select, "Deselect", .Select_Deselect, "d")
		reselect := add_action(select, "Reselect", .Select_Reselect, "d")
		set_modifiers(reselect, {.Command, .Shift})
		set_enabled(reselect, false)
		inverse := add_action(select, "Inverse", .Select_Inverse, "i")
		set_modifiers(inverse, {.Command, .Shift})
		add_separator(select)
		add_action(select, "Color Range", .Select_Color_Range, "")
		modify := add_menu(select, "Modify")
		add_action(modify, "Border", .Select_Modify_Border, "")
		add_action(modify, "Expand", .Select_Modify_Expand, "")
		add_action(modify, "Contract", .Select_Modify_Contract, "")
		add_separator(select)
		add_action(select, "Load from MSK file", .Select_Load, "")
		add_action(select, "Save to MSK file", .Select_Save, "")
		view := add_menu(main, "View")
		add_action(view, "Duplicate View", .View_Duplicate, "")
		workspaceLayout := add_action(view, "Workspace Layout", .View_Workspace_Layout, "w")
		set_modifiers(workspaceLayout, {.Shift})
		runCommand := add_action(view, "Run Command", .View_Run_Command, " ")
		set_modifiers(runCommand, {.Control})
		add_separator(view)
		extras := add_action(view, "Extras", .View_Show_Extras, "h")
		set_modifiers(extras, {.Control})
		set_state(extras, .On)
		show := add_menu(view, "Show")
		add_action(show, "Layer Edges", .View_Show_Layer_Edges, "")
		selectionEdges := add_action(show, "Selection Edges", .View_Show_Selection_Edges, "")
		set_state(selectionEdges, .On)
		add_action(show, "Grid", .View_Show_Grid, "'")
		autoGuides := add_action(show, "Auto Guides", .View_Show_Auto_Guides, "")
		set_state(autoGuides, .On)
		slices := add_action(show, "Slices", .View_Show_Slices, "")
		set_state(slices, .On)
		pixelGrid := add_action(show, "Pixel Grid", .View_Show_Pixel_Grid, "'")
		set_modifiers(pixelGrid, {.Command, .Shift})
		tileNumbers := add_action(show, "Tile Numbers", .View_Show_Tile_Numbers, "")
		set_state(tileNumbers, .On)
		add_separator(show)
		showBrushPreview := add_action(show, "Brush Preview", .View_Show_Brush_Preview, "")
		set_state(showBrushPreview, .On)
		add_separator(view)
		grid := add_menu(view, "Grid")
		add_action(grid, "Grid Settings", .View_Grid_Settings, "")
		add_action(grid, "Selection as Grid", .View_Selection_As_Grid, "")
		snapToGrid := add_action(grid, "Snap to Grid", .View_Snap_To_Grid, "s")
		set_modifiers(snapToGrid, {.Shift})
		tiled := add_menu(view, "Tiled Mode")
		tiledNone := add_action(tiled, "None", .View_Tiled_None, "")
		set_state(tiledNone, .On)
		add_action(tiled, "Tiled in Both Axes", .View_Tiled_Both, "")
		add_action(tiled, "Tiled in X Axis", .View_Tiled_X, "")
		add_action(tiled, "Tiled in Y Axis", .View_Tiled_Y, "")
		symmetryOptions := add_action(view, "Symmetry Options", .View_Symmetry_Options, "")
		set_state(symmetryOptions, .On)
		add_separator(view)
		add_action(view, "Set Loop Section", .View_Set_Loop_Section, "")
		f3Key: cstring = "\uf706"
		showOnionSkin := add_action(view, "Show Onion Skin", .View_Onion_Skin, f3Key)
		set_modifiers(showOnionSkin, {})
		add_separator(view)
		timeline := add_action(view, "Timeline", .View_Timeline, "\t")
		set_modifiers(timeline, {})
		set_state(timeline, .On)
		preview := add_menu(view, "Preview")
		f7Key: cstring = "\uf70a"
		previewAction := add_action(preview, "Preview", .View_Preview, f7Key)
		set_modifiers(previewAction, {})
		add_separator(preview)
		hideOtherLayers := add_action(preview, "Hide Other Layers", .View_Preview_Hide_Other_Layers, f7Key)
		set_modifiers(hideOtherLayers, {.Shift})
		add_action(preview, "Brush Preview", .View_Preview_Brush, "")
		advancedMode := add_action(view, "Advanced Mode", .View_Advanced_Mode, "f")
		set_modifiers(advancedMode, {.Control})
		fullScreenMode := add_action(view, "Full Screen Mode", .View_Fullscreen, "f")
		set_modifiers(fullScreenMode, {.Command, .Control})
		f8Key: cstring = "\uf70b"
		fullScreenPreview := add_action(view, "Full Screen Preview", .View_Fullscreen_Preview, f8Key)
		set_modifiers(fullScreenPreview, {})
		add_action(view, "Home", .View_Home, "")
		add_separator(view)
		f5Key: cstring = "\uf708"
		refresh := add_action(view, "Refresh & Reload Theme", .View_Refresh, f5Key)
		set_modifiers(refresh, {})
		enterFullscreen := add_action(view, "Enter Full Screen", .View_Enter_Fullscreen, "f")
		set_modifiers(enterFullscreen, {.Command})
		window := add_menu(main, "Window")
		add_action(window, "Minimize", .Window_Minimize, "m")
		add_action(window, "Zoom", .Window_Zoom, "")
		add_separator(window)
		add_action(window, "Bring All to Front", .Window_Bring_All_To_Front, "")
		F.Application_setWindowsMenu(app, window)
		help := add_menu(main, "Help")
		add_action(help, "Quick Reference", .Help_Quick_Reference, "")
		add_action(help, "Documentation", .Help_Documentation, "")
		add_action(help, "Tutorial", .Help_Tutorial, "")
		add_separator(help)
		add_action(help, "Release Notes", .Help_Release_Notes, "")
		add_separator(help)
		add_action(help, "About BitSpryte", .Help_About, "")
	}

	take_action :: proc() -> actions.Kind {
		action := pending_action
		pending_action = .None
		return action
	}
} else {
	install :: proc() {}
	take_action :: proc() -> actions.Kind {
		return .None
	}
}
