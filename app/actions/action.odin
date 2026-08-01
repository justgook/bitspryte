package actions

// Keep this order synchronized with the native menu action IDs.
Kind :: enum i32 {
	None,

	// File
	New_File,
	Open_File,
	Save_File,
	Save_File_As,
	Close_File,
	Close_All_Files,
	Export_As,
	Export_Sprite_Sheet,
	Export_Tileset,
	Repeat_Last_Export,
	Import_Sprite_Sheet,

	// Edit
	Undo,
	Redo,
	Undo_History,
	Cut,
	Copy,
	Copy_Merged,
	Paste,
	Paste_As_New_Sprite,
	Paste_As_New_Layer,
	Paste_As_New_Reference_Layer,
	Clear,
	Fill,
	Stroke,
	Rotate_180,
	Rotate_90_CW,
	Rotate_90_CCW,
	Flip_Horizontal,
	Flip_Vertical,
	Transform,
	Shift_Left,
	Shift_Right,
	Shift_Up,
	Shift_Down,
	New_Brush,
	New_Sprite_From_Selection,
	Replace_Color,
	Invert,
	Adjust_Brightness_Contrast,
	Adjust_Hue_Saturation,
	Adjust_Color_Curve,
	FX_Outline,
	FX_Convolution_Matrix,
	FX_Despeckle,
	Insert_Text,
	Keyboard_Shortcuts,
	Preferences,

	// Sprite
	Sprite_Properties,
	Color_Mode_RGB,
	Color_Mode_Grayscale,
	Color_Mode_Indexed,
	Duplicate_Sprite,
	Sprite_Size,
	Canvas_Size,
	Rotate_Canvas_180,
	Rotate_Canvas_90_CW,
	Rotate_Canvas_90_CCW,
	Flip_Canvas_Horizontal,
	Flip_Canvas_Vertical,
	Crop_Sprite,
	Trim_Sprite,

	// Layer
	Layer_Properties,
	Layer_Visible,
	Layer_Lock,
	Layer_Open_Group,
	Layer_New,
	Layer_New_Group,
	Layer_New_Via_Copy,
	Layer_New_Via_Cut,
	Layer_New_Reference_From_File,
	Layer_New_Tilemap,
	Layer_Delete,
	Layer_Duplicate,
	Layer_Merge_Down,
	Layer_Flatten,
	Layer_Flatten_Visible,

	// Frame
	Frame_Properties,
	Cel_Properties,
	Frame_New,
	Frame_New_Empty,
	Frame_Duplicate,
	Frame_Duplicate_Linked,
	Frame_Delete,
	Animation_Play,
	Frame_Tag_New,
	Frame_Tag_Delete,
	Frame_First,
	Frame_Previous,
	Frame_Next,
	Frame_Last,
	Frame_Reverse,

	// Select
	Select_All,
	Select_Deselect,
	Select_Reselect,
	Select_Inverse,
	Select_Color_Range,
	Select_Modify_Border,
	Select_Modify_Expand,
	Select_Modify_Contract,
	Select_Load,
	Select_Save,

	// View
	View_Duplicate,
	View_Show_Extras,
	View_Show_Grid,
	View_Show_Pixel_Grid,
	View_Snap_To_Grid,
	View_Tiled_None,
	View_Tiled_Both,
	View_Tiled_X,
	View_Tiled_Y,
	View_Onion_Skin,
	View_Timeline,
	View_Preview,
	View_Fullscreen,
	View_Refresh,

	// Window
	Window_Minimize,
	Window_Zoom,
	Window_Bring_All_To_Front,

	// Help
	Help_Quick_Reference,
	Help_Documentation,
	Help_Tutorial,
	Help_Release_Notes,
	Help_About,
}

Source :: enum {
	Application,
	Keyboard,
	Native_Menu,
	Pointer,
	User_Interface,
	Script,
}

Action :: struct {
	kind:      Kind,
	source:    Source,
	int_value: i32,
}

make :: proc(kind: Kind, source := Source.Application) -> Action {
	assert(kind != .None)
	return {kind = kind, source = source}
}
