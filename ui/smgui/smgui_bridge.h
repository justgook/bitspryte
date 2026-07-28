#ifndef BITSPRYTE_SMGUI_BRIDGE_H
#define BITSPRYTE_SMGUI_BRIDGE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct bs_smgui bs_smgui;

typedef struct bs_smgui_rect {
    int x, y, width, height;
} bs_smgui_rect;

enum {
    BS_SMGUI_PAGE_GENERAL,
    BS_SMGUI_PAGE_FILES,
    BS_SMGUI_PAGE_KEYBOARD_SHORTCUTS,
    BS_SMGUI_PAGE_COLOR,
    BS_SMGUI_PAGE_ALERTS,
    BS_SMGUI_PAGE_EDITOR,
    BS_SMGUI_PAGE_SELECTION,
    BS_SMGUI_PAGE_TIMELINE,
    BS_SMGUI_PAGE_CURSORS,
    BS_SMGUI_PAGE_BACKGROUND,
    BS_SMGUI_PAGE_GRID,
    BS_SMGUI_PAGE_GUIDES_AND_SLICES,
    BS_SMGUI_PAGE_UNDO,
    BS_SMGUI_PAGE_THEME,
    BS_SMGUI_PAGE_EXTENSIONS,
    BS_SMGUI_PAGE_ASEPRITE_FORMAT,
    BS_SMGUI_PAGE_EXPERIMENTAL,
    BS_SMGUI_PAGE_RESET,
    BS_SMGUI_PAGE_COUNT
};

enum {
    BS_SMGUI_EVENT_NONE,
    BS_SMGUI_EVENT_PAGE_SELECTED,
    BS_SMGUI_EVENT_THEME_SELECTED,
    BS_SMGUI_EVENT_ACCEPTED,
    BS_SMGUI_EVENT_APPLY_REQUESTED,
    BS_SMGUI_EVENT_CANCELLED,
    BS_SMGUI_EVENT_CLOSED,
    BS_SMGUI_EVENT_SETTING_CHANGED,
    BS_SMGUI_EVENT_SHORTCUT_CAPTURE_REQUESTED,
    BS_SMGUI_EVENT_PAGE_ACTION
};

enum {
    BS_SMGUI_SETTING_SAVE_FORMAT,
    BS_SMGUI_SETTING_EXPORT_IMAGE_FORMAT,
    BS_SMGUI_SETTING_EXPORT_ANIMATION_FORMAT,
    BS_SMGUI_SETTING_SPRITE_SHEET_FORMAT,
    BS_SMGUI_SETTING_RECENT_ITEMS,
    BS_SMGUI_SETTING_SHOW_FULL_PATH,
    BS_SMGUI_SETTING_AUTO_RECOVERY,
    BS_SMGUI_SETTING_RECOVERY_INTERVAL,
    BS_SMGUI_SETTING_KEEP_EDITED,
    BS_SMGUI_SETTING_KEEP_EDITED_DURATION,
    BS_SMGUI_SETTING_KEEP_CLOSED,
    BS_SMGUI_SETTING_KEEP_CLOSED_DURATION
};

typedef struct bs_smgui_settings {
    int page;
    int theme;
    int close_window_key;
    int save_format;
    int export_image_format;
    int export_animation_format;
    int sprite_sheet_format;
    int recent_items;
    int show_full_path;
    int auto_recovery;
    int recovery_interval;
    int keep_edited;
    int keep_edited_duration;
    int keep_closed;
    int keep_closed_duration;
} bs_smgui_settings;

typedef struct bs_smgui_event {
    int kind;
    int page;
    int field;
    int value;
} bs_smgui_event;

bs_smgui *bs_smgui_create(int width, int height);
void bs_smgui_destroy(bs_smgui *ui);
int bs_smgui_resize(bs_smgui *ui, int width, int height);
int bs_smgui_set_sprite_sheet_font(bs_smgui *ui, const unsigned char *rgba,
    int width, int height, int scale);
void bs_smgui_show(bs_smgui *ui);
void bs_smgui_close(bs_smgui *ui);
void bs_smgui_sync_settings(bs_smgui *ui, const bs_smgui_settings *settings);
void bs_smgui_set_mouse(bs_smgui *ui, int x, int y);
void bs_smgui_mouse_button(bs_smgui *ui, int button, int pressed);
void bs_smgui_mouse_wheel(bs_smgui *ui, float delta);
void bs_smgui_key(bs_smgui *ui, const char *key, int pressed, int modifiers);
void bs_smgui_text(bs_smgui *ui, uint32_t codepoint);
const uint8_t *bs_smgui_frame(bs_smgui *ui);
int bs_smgui_poll_event(bs_smgui *ui, bs_smgui_event *event);
int bs_smgui_content_bounds(const bs_smgui *ui, bs_smgui_rect *bounds);
int bs_smgui_contains(const bs_smgui *ui, int x, int y);
int bs_smgui_captures_keyboard(const bs_smgui *ui);
int bs_smgui_is_open(const bs_smgui *ui);

#ifdef __cplusplus
}
#endif

#endif
