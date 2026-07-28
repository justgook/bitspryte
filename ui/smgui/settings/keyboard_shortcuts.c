#include "settings_internal.h"

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BS_SHORTCUT_COUNT 20
#define BS_CLOSE_SHORTCUT_ROW 6

typedef struct bs_shortcuts_page_state {
    char search[128];
    char previous_search[128];
    const char *action_names[BS_SHORTCUT_COUNT];
    char key_labels[BS_SHORTCUT_COUNT][32];
    char default_key_labels[BS_SHORTCUT_COUNT][32];
    int key_text[BS_SHORTCUT_COUNT];
    int edit[BS_SHORTCUT_COUNT];
    int import_action, export_action, reset_action;
    int close_window_key;
} bs_shortcuts_page_state;

static const char *bs_key_name(int key)
{
    static char single[2];
    if (key >= 'A' && key <= 'Z') { single[0] = (char)key; single[1] = 0; return single; }
    if (key >= '0' && key <= '9') { single[0] = (char)key; single[1] = 0; return single; }
    switch (key) {
        case 256: return "Esc";
        case 257: return "Enter";
        case 258: return "Tab";
        case 259: return "Backspace";
        case 261: return "Delete";
        case 262: return "Right";
        case 263: return "Left";
        case 264: return "Down";
        case 265: return "Up";
        case 290: return "F1"; case 291: return "F2"; case 292: return "F3";
        case 293: return "F4"; case 294: return "F5"; case 295: return "F6";
        case 296: return "F7"; case 297: return "F8"; case 298: return "F9";
        case 299: return "F10"; case 300: return "F11"; case 301: return "F12";
        case 32: return "Space";
        default: return "Custom Key";
    }
}

static void bs_shortcuts_sync(bs_settings_page *page, const bs_smgui_settings *settings)
{
    bs_shortcuts_page_state *state;
    if (!page || !page->state || !settings) return;
    state = (bs_shortcuts_page_state *)page->state;
    state->close_window_key = settings->close_window_key;
    for (int i = 0; i < BS_SHORTCUT_COUNT; ++i)
        snprintf(state->key_labels[i], sizeof(state->key_labels[i]), "%s",
            state->default_key_labels[i]);
    snprintf(state->key_labels[BS_CLOSE_SHORTCUT_ROW],
        sizeof(state->key_labels[BS_CLOSE_SHORTCUT_ROW]), "%s",
        bs_key_name(settings->close_window_key));
    page->dirty = 1;
}

static int bs_contains_case_insensitive(const char *text, const char *query)
{
    const char *start;
    if (!query || !*query) return 1;
    for (start = text; *start; ++start) {
        const char *a = start, *b = query;
        while (*a && *b && tolower((unsigned char)*a) == tolower((unsigned char)*b)) {
            ++a; ++b;
        }
        if (!*b) return 1;
    }
    return 0;
}

static void bs_shortcuts_update(bs_settings_page *page, bs_page_emit_fn emit,
    void *context)
{
    bs_shortcuts_page_state *state;
    int i;
    if (!page || !page->state) return;
    state = (bs_shortcuts_page_state *)page->state;
    if (strcmp(state->search, state->previous_search)) {
        snprintf(state->previous_search, sizeof(state->previous_search), "%s", state->search);
        for (i = 0; i < BS_SHORTCUT_COUNT; ++i) {
            int hidden = !bs_contains_case_insensitive(state->action_names[i], state->search);
            for (int column = 0; column < 3; ++column) {
                ui_form_t *form = &page->forms[4 + i * 3 + column];
                if (hidden) form->flags |= UI_HIDDEN;
                else form->flags &= (short)~UI_HIDDEN;
            }
        }
        page->dirty = 1;
    }
    for (i = 0; i < BS_SHORTCUT_COUNT; ++i) {
        if (!state->edit[i]) continue;
        state->edit[i] = 0;
        snprintf(state->key_labels[i], sizeof(state->key_labels[i]), "Press a key...");
        page->dirty = 1;
        if (emit) emit(context, BS_SMGUI_EVENT_SHORTCUT_CAPTURE_REQUESTED,
            page->page, i, 0);
    }
    if (state->import_action) {
        state->import_action = 0;
        if (emit) emit(context, BS_SMGUI_EVENT_PAGE_ACTION, page->page, 1, 0);
    }
    if (state->export_action) {
        state->export_action = 0;
        if (emit) emit(context, BS_SMGUI_EVENT_PAGE_ACTION, page->page, 2, 0);
    }
    if (state->reset_action) {
        state->reset_action = 0;
        if (emit) emit(context, BS_SMGUI_EVENT_PAGE_ACTION, page->page, 3, 0);
    }
}

static void bs_shortcuts_destroy(bs_settings_page *page)
{
    if (!page) return;
    free(page->forms);
    free(page->state);
    *page = (bs_settings_page){0};
}

bs_settings_page bs_page_keyboard_shortcuts_create(bs_page_host *host)
{
    static const char *const actions[BS_SHORTCUT_COUNT] = {
        "About", "Add Background Color to Palette", "Add Foreground Color to Palette",
        "Adjust Brightness/Contrast", "Adjust Hue/Saturation", "Apply",
        "Close Active Window", "Canvas Size", "Change Brush: Custom Brush #1",
        "Change Brush: Custom Brush #2", "Change Brush: Custom Brush #3",
        "Change Brush: Custom Brush #4", "Change Brush: Flip Horizontally",
        "Change Brush: Flip Vertically", "Change Brush: Increment Size",
        "Change Brush: Decrement Size", "Clear Canvas", "Export PNG",
        "Open Settings", "Pencil Tool"
    };
    static const char *const keys[BS_SHORTCUT_COUNT] = {
        "", "", "", "", "Cmd+U", "Enter", "Esc", "C", "Alt+1", "Alt+2",
        "Alt+3", "Alt+4", "Space+H", "Space+V", "+", "-", "", "Cmd+E", "Cmd+,", "B"
    };
    static const char *const scopes[BS_SHORTCUT_COUNT] = {
        "Global", "Editor", "Editor", "Editor", "Editor", "Transformation",
        "Global", "Sprite", "Editor", "Editor", "Editor", "Editor", "Editor",
        "Editor", "Editor", "Editor", "Sprite", "Global", "Global", "Editor"
    };
    bs_settings_page result = {0};
    bs_shortcuts_page_state *state;
    ui_form_t *forms;
    int action_text[BS_SHORTCUT_COUNT], scope_text[BS_SHORTCUT_COUNT];
    int search_text, action_header, key_header, context_header;
    int import_text, export_text, reset_text, hint_text;
    int i, n = 0;

    if (!host) return result;
    state = (bs_shortcuts_page_state *)calloc(1, sizeof(*state));
    forms = (ui_form_t *)calloc(70, sizeof(*forms));
    if (!state || !forms) goto fail;
    search_text = bs_page_text(host, "Search shortcuts");
    action_header = bs_page_text(host, "Action");
    key_header = bs_page_text(host, "Key");
    context_header = bs_page_text(host, "Context");
    import_text = bs_page_text(host, "Import");
    export_text = bs_page_text(host, "Export");
    reset_text = bs_page_text(host, "Reset");
    hint_text = bs_page_text(host, "Select a key field, then press a replacement key.");
    if (search_text < 0 || action_header < 0 || key_header < 0 || context_header < 0 ||
        import_text < 0 || export_text < 0 || reset_text < 0 || hint_text < 0) goto fail;
    for (i = 0; i < BS_SHORTCUT_COUNT; ++i) {
        state->action_names[i] = actions[i];
        action_text[i] = bs_page_text(host, actions[i]);
        scope_text[i] = bs_page_text(host, scopes[i]);
        snprintf(state->default_key_labels[i], sizeof(state->default_key_labels[i]), "%s", keys[i]);
        snprintf(state->key_labels[i], sizeof(state->key_labels[i]), "%s", keys[i]);
        state->key_text[i] = bs_page_text(host, state->key_labels[i]);
        if (action_text[i] < 0 || scope_text[i] < 0 || state->key_text[i] < 0) goto fail;
    }

    forms[n++] = (ui_form_t){ .type=UI_TXTINP, .x=UI_ABS(12), .y=UI_ABS(10),
        .w=300, .h=24, .m=6, .ptr=state->search, .max=sizeof(state->search), .str=search_text };
    forms[n++] = (ui_form_t){ .type=UI_LABEL, .x=UI_ABS(12), .y=UI_ABS(40), .w=320, .h=18, .label=action_header };
    forms[n++] = (ui_form_t){ .type=UI_LABEL, .x=UI_ABS(350), .y=UI_ABS(40), .w=120, .h=18, .label=key_header };
    forms[n++] = (ui_form_t){ .type=UI_LABEL, .x=UI_ABS(486), .y=UI_ABS(40), .w=130, .h=18, .label=context_header };
    for (i = 0; i < BS_SHORTCUT_COUNT; ++i) {
        int row_y = 62 + i * 22;
        forms[n++] = (ui_form_t){ .type=UI_LABEL, .x=UI_ABS(12), .y=UI_ABS(row_y),
            .w=326, .h=18, .label=action_text[i] };
        forms[n++] = (ui_form_t){ .type=UI_BUTTON, .x=UI_ABS(350), .y=UI_ABS(row_y),
            .w=120, .h=18, .ptr=&state->edit[i], .value=1, .label=state->key_text[i] };
        forms[n++] = (ui_form_t){ .type=UI_LABEL, .x=UI_ABS(486), .y=UI_ABS(row_y),
            .w=130, .h=18, .label=scope_text[i] };
    }
    forms[n++] = (ui_form_t){ .type=UI_BUTTON, .x=UI_ABS(12), .y=UI_ABS(510),
        .w=90, .h=24, .ptr=&state->import_action, .value=1, .label=import_text };
    forms[n++] = (ui_form_t){ .type=UI_BUTTON, .x=UI_ABS(112), .y=UI_ABS(510),
        .w=90, .h=24, .ptr=&state->export_action, .value=1, .label=export_text };
    forms[n++] = (ui_form_t){ .type=UI_BUTTON, .x=UI_ABS(212), .y=UI_ABS(510),
        .w=90, .h=24, .ptr=&state->reset_action, .value=1, .label=reset_text };
    forms[n++] = (ui_form_t){ .type=UI_LABEL, .x=UI_ABS(320), .y=UI_ABS(512),
        .w=330, .h=20, .label=hint_text };
    forms[n++] = (ui_form_t){ .type=UI_END };

    result.page = BS_SMGUI_PAGE_KEYBOARD_SHORTCUTS;
    result.forms = forms;
    result.state = state;
    result.sync = bs_shortcuts_sync;
    result.update = bs_shortcuts_update;
    result.destroy = bs_shortcuts_destroy;
    return result;
fail:
    free(forms);
    free(state);
    return result;
}
