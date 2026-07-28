#include "settings_internal.h"

#include <stdlib.h>

typedef struct bs_files_page_state {
    int values[12];
    int previous[12];
    int clear_recent;
    char *save_options[2];
    char *image_options[3];
    char *animation_options[2];
    char *sheet_options[2];
    char *recovery_options[3];
    char *edited_options[3];
    char *closed_options[3];
} bs_files_page_state;

static void bs_files_remember(bs_files_page_state *state)
{
    int i;
    for (i = 0; i < 12; ++i) state->previous[i] = state->values[i];
}

static void bs_files_sync(bs_settings_page *page, const bs_smgui_settings *settings)
{
    bs_files_page_state *state;
    if (!page || !page->state || !settings) return;
    state = (bs_files_page_state *)page->state;
    state->values[BS_SMGUI_SETTING_SAVE_FORMAT] = settings->save_format;
    state->values[BS_SMGUI_SETTING_EXPORT_IMAGE_FORMAT] = settings->export_image_format;
    state->values[BS_SMGUI_SETTING_EXPORT_ANIMATION_FORMAT] = settings->export_animation_format;
    state->values[BS_SMGUI_SETTING_SPRITE_SHEET_FORMAT] = settings->sprite_sheet_format;
    state->values[BS_SMGUI_SETTING_RECENT_ITEMS] = settings->recent_items;
    state->values[BS_SMGUI_SETTING_SHOW_FULL_PATH] = settings->show_full_path;
    state->values[BS_SMGUI_SETTING_AUTO_RECOVERY] = settings->auto_recovery;
    state->values[BS_SMGUI_SETTING_RECOVERY_INTERVAL] = settings->recovery_interval;
    state->values[BS_SMGUI_SETTING_KEEP_EDITED] = settings->keep_edited;
    state->values[BS_SMGUI_SETTING_KEEP_EDITED_DURATION] = settings->keep_edited_duration;
    state->values[BS_SMGUI_SETTING_KEEP_CLOSED] = settings->keep_closed;
    state->values[BS_SMGUI_SETTING_KEEP_CLOSED_DURATION] = settings->keep_closed_duration;
    bs_files_remember(state);
}

static void bs_files_update(bs_settings_page *page, bs_page_emit_fn emit, void *context)
{
    bs_files_page_state *state;
    int i;
    if (!page || !page->state) return;
    state = (bs_files_page_state *)page->state;
    if (state->clear_recent) {
        state->clear_recent = 0;
        state->values[BS_SMGUI_SETTING_RECENT_ITEMS] = 0;
        page->dirty = 1;
    }
    for (i = 0; i < 12; ++i) {
        if (state->values[i] != state->previous[i]) {
            state->previous[i] = state->values[i];
            if (emit) emit(context, BS_SMGUI_EVENT_SETTING_CHANGED,
                page->page, i, state->values[i]);
        }
    }
}

static void bs_files_destroy(bs_settings_page *page)
{
    if (!page) return;
    free(page->forms);
    free(page->state);
    *page = (bs_settings_page){0};
}

static int bs_register_options(bs_page_host *host, char **destination,
    const char *const *source, int count)
{
    int i, id;
    for (i = 0; i < count; ++i) {
        id = bs_page_text(host, source[i]);
        if (id < 0) return 0;
        destination[i] = host->strings[id];
    }
    return 1;
}

bs_settings_page bs_page_files_create(bs_page_host *host)
{
    static const char *const save[] = { "aseprite", "png" };
    static const char *const image[] = { "png", "jpg", "bmp" };
    static const char *const animation[] = { "gif", "png" };
    static const char *const sheet[] = { "png", "jpg" };
    static const char *const recovery[] = { "2 Minutes", "5 Minutes", "10 Minutes" };
    static const char *const edited[] = { "1 Week", "1 Month", "Forever" };
    static const char *const closed[] = { "15 Minutes", "1 Hour", "1 Day" };
    static const char *const labels[] = {
        "Files", "Default extension for:", "File > Save:",
        "File > Export (one image):", "File > Export (animation):",
        "File > Export Sprite Sheet:", "Recent Items:", "Clear",
        "Show full file name path", "Recover Files",
        "Automatically save recovery data every", "Keep edited sprite data for",
        "Keep closed sprite in memory for"
    };
    bs_settings_page result = {0};
    bs_files_page_state *state;
    ui_form_t *forms;
    int text[13], i, n = 0;

    if (!host) return result;
    state = (bs_files_page_state *)calloc(1, sizeof(*state));
    forms = (ui_form_t *)calloc(25, sizeof(*forms));
    if (!state || !forms) goto fail;
    for (i = 0; i < 13; ++i) {
        text[i] = bs_page_text(host, labels[i]);
        if (text[i] < 0) goto fail;
    }
    if (!bs_register_options(host, state->save_options, save, 2) ||
        !bs_register_options(host, state->image_options, image, 3) ||
        !bs_register_options(host, state->animation_options, animation, 2) ||
        !bs_register_options(host, state->sheet_options, sheet, 2) ||
        !bs_register_options(host, state->recovery_options, recovery, 3) ||
        !bs_register_options(host, state->edited_options, edited, 3) ||
        !bs_register_options(host, state->closed_options, closed, 3)) goto fail;

#define LABEL(X,Y,W,T) forms[n++] = (ui_form_t){ .type=UI_LABEL, .x=UI_ABS(X), .y=UI_ABS(Y), .w=W, .h=22, .label=text[T] }
#define SELECT(X,Y,P,C,O) forms[n++] = (ui_form_t){ .type=UI_SELECT, .x=UI_ABS(X), .y=UI_ABS(Y), .w=180, .h=24, .m=7, .ptr=(P), .optc=(C), .optv=(O) }
    LABEL(20, 10, 632, 0);
    LABEL(20, 54, 632, 1);
    LABEL(20, 90, 220, 2); SELECT(258, 90, &state->values[BS_SMGUI_SETTING_SAVE_FORMAT], 2, state->save_options);
    LABEL(20, 130, 220, 3); SELECT(258, 130, &state->values[BS_SMGUI_SETTING_EXPORT_IMAGE_FORMAT], 3, state->image_options);
    LABEL(20, 170, 220, 4); SELECT(258, 170, &state->values[BS_SMGUI_SETTING_EXPORT_ANIMATION_FORMAT], 2, state->animation_options);
    LABEL(20, 210, 220, 5); SELECT(258, 210, &state->values[BS_SMGUI_SETTING_SPRITE_SHEET_FORMAT], 2, state->sheet_options);
    LABEL(20, 258, 120, 6);
    forms[n++] = (ui_form_t){ .type=UI_SLIDER, .x=UI_ABS(150), .y=UI_ABS(260), .w=250, .h=20,
        .ptr=&state->values[BS_SMGUI_SETTING_RECENT_ITEMS], .min=0, .max=32 };
    forms[n++] = (ui_form_t){ .type=UI_BUTTON, .x=UI_ABS(414), .y=UI_ABS(256), .w=120, .h=26,
        .ptr=&state->clear_recent, .value=1, .label=text[7] };
    forms[n++] = (ui_form_t){ .type=UI_CHECK, .x=UI_ABS(20), .y=UI_ABS(294), .w=382, .h=18,
        .ptr=&state->values[BS_SMGUI_SETTING_SHOW_FULL_PATH], .value=1, .label=text[8] };
    LABEL(20, 340, 632, 9);
    forms[n++] = (ui_form_t){ .type=UI_CHECK, .x=UI_ABS(20), .y=UI_ABS(384), .w=360, .h=18,
        .ptr=&state->values[BS_SMGUI_SETTING_AUTO_RECOVERY], .value=1, .label=text[10] };
    SELECT(398, 382, &state->values[BS_SMGUI_SETTING_RECOVERY_INTERVAL], 3, state->recovery_options);
    forms[n++] = (ui_form_t){ .type=UI_CHECK, .x=UI_ABS(20), .y=UI_ABS(424), .w=360, .h=18,
        .ptr=&state->values[BS_SMGUI_SETTING_KEEP_EDITED], .value=1, .label=text[11] };
    SELECT(398, 422, &state->values[BS_SMGUI_SETTING_KEEP_EDITED_DURATION], 3, state->edited_options);
    forms[n++] = (ui_form_t){ .type=UI_CHECK, .x=UI_ABS(20), .y=UI_ABS(464), .w=360, .h=18,
        .ptr=&state->values[BS_SMGUI_SETTING_KEEP_CLOSED], .value=1, .label=text[12] };
    SELECT(398, 462, &state->values[BS_SMGUI_SETTING_KEEP_CLOSED_DURATION], 3, state->closed_options);
    forms[n++] = (ui_form_t){ .type=UI_END };
#undef LABEL
#undef SELECT

    result.page = BS_SMGUI_PAGE_FILES;
    result.forms = forms;
    result.state = state;
    result.sync = bs_files_sync;
    result.update = bs_files_update;
    result.destroy = bs_files_destroy;
    return result;
fail:
    free(forms);
    free(state);
    return result;
}
