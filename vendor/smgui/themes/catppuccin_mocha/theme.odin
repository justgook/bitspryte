package catppuccin_mocha

// Generated from Catppuccin Lavender by Sofy: https://github.com/catppuccin/aseprite at 3113df487afbb564f20e6e9402ee077f002f926c.
// Values use SMGUI's little-endian RGBA u32 representation.

THEME_COLOR_COUNT :: 33
THEME := [THEME_COLOR_COUNT]u32 {
	0xffaca0eb, // Foreground <- text
	0xffffffff, // Title <- window_titlebar_text
	0xff443231, // Background <- window_face
	0xff2e1e1e, // Shadow <- background
	0xffaca0eb, // Toggle_Foreground <- text
	0xff443231, // Toggle_Background <- check_focus_face
	0xffffffff, // Highlight_Foreground <- menuitem_hot_text
	0xff86706c, // Highlight_Background <- menuitem_hot_face
	0xfff4d6cd, // Disabled_Foreground <- disabled
	0xff2e1e1e, // Disabled_Background <- face
	0xff2e1e1e, // Scrollbar_Background <- editor_view_face
	0xffffffff, // Input_Foreground <- textbox_text
	0xff86706c, // Input_Light_Border <- check_hot_face
	0xff2e1e1e, // Input_Dark_Border <- background
	0xff2e1e1e, // Input_Background <- textbox_face
	0xff2e1e1e, // Input_Selected_Foreground <- selected_text
	0xfff7a6cb, // Input_Selected_Border <- selected
	0xfff7a6cb, // Input_Cursor <- selected
	0xffffffff, // Button_Foreground <- button_normal_text
	0xffa88bf3, // Button_Light_Shadow <- hot_face
	0xff2e1e1e, // Button_Dark_Shadow <- background
	0xff2e1e1e, // Button_Normal_Border <- background
	0xffffffff, // Button_Selected_Foreground <- button_selected_text
	0xfff7a6cb, // Button_Selected_Light_Shadow <- selected
	0xff443231, // Button_Selected_Dark_Shadow <- check_focus_face
	0xfff7a6cb, // Button_Selected_Border <- selected
	0xff86706c, // Button_Light_Inner_Border <- check_hot_face
	0xff2e1e1e, // Button_Dark_Inner_Border <- background
	0xff2e1e1e, // Button_Light_Background <- face
	0xff443231, // Button_Dark_Background <- window_face
	0xfff7a6cb, // Progress_Light <- selected
	0xff2e1e1e, // Progress_Background <- face
	0xff2e1e1e, // Progress_Dark <- background
}

Named_Color :: struct {name: string, value: u32}
ASEPRITE_COLORS := [80]Named_Color {
	{"background", 0xff2e1e1e},
	{"button_hot_text", 0xffffffff},
	{"button_normal_text", 0xffffffff},
	{"button_selected_text", 0xffffffff},
	{"check_focus_face", 0xff443231},
	{"check_hot_face", 0xff86706c},
	{"disabled", 0xfff4d6cd},
	{"edit_pal_face", 0xff412d30},
	{"editor_face", 0xff2e1e1e},
	{"editor_sprite_border", 0xff000000},
	{"editor_sprite_bottom_border", 0xff000000},
	{"editor_view_face", 0xff2e1e1e},
	{"entry_suffix", 0xffffffff},
	{"face", 0xff2e1e1e},
	{"filelist_disabled_row_text", 0xffc8c8ff},
	{"filelist_even_row_face", 0xff2e1e1e},
	{"filelist_even_row_text", 0xffffffff},
	{"filelist_odd_row_face", 0xff2e1e1e},
	{"filelist_odd_row_text", 0xffffffff},
	{"filelist_selected_row_face", 0xff86706c},
	{"filelist_selected_row_text", 0xffffffff},
	{"flag_active", 0xff0000ff},
	{"flag_clicked", 0xffa88bf3},
	{"flag_normal", 0xff443231},
	{"hot_face", 0xffa88bf3},
	{"link_hover", 0xffa88bf3},
	{"link_text", 0xfffdfdfd},
	{"listitem_normal_face", 0xff2e1e1e},
	{"listitem_normal_text", 0xffffffff},
	{"listitem_selected_face", 0xff86706c},
	{"listitem_selected_text", 0xffffffff},
	{"menuitem_highlight_face", 0xff86706c},
	{"menuitem_highlight_text", 0xffffffff},
	{"menuitem_hot_face", 0xff86706c},
	{"menuitem_hot_text", 0xffffffff},
	{"menuitem_normal_face", 0xff443231},
	{"menuitem_normal_text", 0xffffffff},
	{"palette_entries_separator", 0xff2e1e1e},
	{"popup_window_border", 0xff000000},
	{"radio_focus_face", 0xff443231},
	{"radio_hot_face", 0xffa88bf3},
	{"select_box_grid", 0xff64c864},
	{"select_box_ruler", 0xffff0000},
	{"selected", 0xfff7a6cb},
	{"selected_text", 0xff2e1e1e},
	{"separator_label", 0xffa88bf3},
	{"slider_empty_text", 0xff86706c},
	{"slider_full_text", 0xffffffff},
	{"status_bar_face", 0xff443231},
	{"status_bar_text", 0xffa88bf3},
	{"tab_active_face", 0xff443231},
	{"tab_active_text", 0xffffffff},
	{"tab_normal_text", 0xffffffff},
	{"text", 0xffaca0eb},
	{"textbox_code_face", 0xffeeeeee},
	{"textbox_face", 0xff2e1e1e},
	{"textbox_text", 0xffffffff},
	{"timeline_active", 0xff9e927d},
	{"timeline_active_hover", 0xffc2b399},
	{"timeline_active_hover_text", 0xffffffff},
	{"timeline_active_text", 0xffffffff},
	{"timeline_band_bg", 0xff8e8576},
	{"timeline_band_highlight", 0xffbbad93},
	{"timeline_clicked", 0xff696053},
	{"timeline_clicked_text", 0xffffffff},
	{"timeline_focused_text", 0xffffffff},
	{"timeline_hover", 0xffd9d9d9},
	{"timeline_hover_text", 0xffffffff},
	{"timeline_normal", 0xffc6c6c6},
	{"timeline_normal_text", 0xffffffff},
	{"timeline_padding", 0xff9e927d},
	{"tooltip_face", 0xff86706c},
	{"tooltip_text", 0xffffffff},
	{"window_face", 0xff443231},
	{"window_titlebar_face", 0xff86706c},
	{"window_titlebar_text", 0xffffffff},
	{"workspace", 0xff443231},
	{"workspace_link", 0xfffdfdfd},
	{"workspace_link_hover", 0xffaca0eb},
	{"workspace_text", 0xffdec2ba},
}

Dimension :: struct {name: string, value: int}
DIMENSIONS := [20]Dimension {
	{"brush_type_width", 16},
	{"color_bar_buttons_height", 16},
	{"color_selector_bar_size", 8},
	{"color_slider_height", 14},
	{"context_bar_height", 18},
	{"docked_tabs_height", 12},
	{"mini_scrollbar_size", 6},
	{"palette_entries_separator", 1},
	{"palette_outline_width", 3},
	{"scrollbar_size", 12},
	{"tabs_bottom_height", 5},
	{"tabs_close_icon_height", 12},
	{"tabs_close_icon_width", 14},
	{"tabs_height", 17},
	{"tabs_icon_width", 10},
	{"tabs_width", 80},
	{"timeline_base_size", 12},
	{"timeline_outline_width", 2},
	{"timeline_tags_area_height", 4},
	{"timeline_top_border", 2},
}
