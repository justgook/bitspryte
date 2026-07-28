#ifndef BITSPRYTE_SMGUI_SETTINGS_INTERNAL_H
#define BITSPRYTE_SMGUI_SETTINGS_INTERNAL_H

#include "../smgui_bridge.h"

#define UI_BACKEND 1
#include "../vendor/ui.h"
#undef UI_BACKEND

typedef struct bs_page_host {
    char **strings;
    int *string_count;
    int string_capacity;
} bs_page_host;

typedef void (*bs_page_emit_fn)(void *context, int kind, int page, int field, int value);

typedef struct bs_settings_page bs_settings_page;
struct bs_settings_page {
    int page;
    int dirty;
    ui_form_t *forms;
    void *state;
    void (*sync)(bs_settings_page *page, const bs_smgui_settings *settings);
    void (*update)(bs_settings_page *page, bs_page_emit_fn emit, void *context);
    void (*destroy)(bs_settings_page *page);
};

int bs_page_text(bs_page_host *host, const char *text);
bs_settings_page bs_stub_page_create(bs_page_host *host, int page,
    const char *title, const char *description);

bs_settings_page bs_page_general_create(bs_page_host *host);
bs_settings_page bs_page_files_create(bs_page_host *host);
bs_settings_page bs_page_keyboard_shortcuts_create(bs_page_host *host);
bs_settings_page bs_page_color_create(bs_page_host *host);
bs_settings_page bs_page_alerts_create(bs_page_host *host);
bs_settings_page bs_page_editor_create(bs_page_host *host);
bs_settings_page bs_page_selection_create(bs_page_host *host);
bs_settings_page bs_page_timeline_create(bs_page_host *host);
bs_settings_page bs_page_cursors_create(bs_page_host *host);
bs_settings_page bs_page_background_create(bs_page_host *host);
bs_settings_page bs_page_grid_create(bs_page_host *host);
bs_settings_page bs_page_guides_and_slices_create(bs_page_host *host);
bs_settings_page bs_page_undo_create(bs_page_host *host);
bs_settings_page bs_page_theme_create(bs_page_host *host);
bs_settings_page bs_page_extensions_create(bs_page_host *host);
bs_settings_page bs_page_aseprite_format_create(bs_page_host *host);
bs_settings_page bs_page_experimental_create(bs_page_host *host);
bs_settings_page bs_page_reset_create(bs_page_host *host);

#endif
