#include "settings_internal.h"

#include <stdlib.h>

#define BS_THEME_OPTION_COUNT 15

typedef struct bs_theme_page_state {
    int theme;
    int previous_theme;
    char *options[BS_THEME_OPTION_COUNT];
} bs_theme_page_state;

static void bs_theme_page_sync(bs_settings_page *page,
    const bs_smgui_settings *settings)
{
    bs_theme_page_state *state;

    if (!page || !page->state || !settings) return;
    if (settings->theme < 0 || settings->theme >= BS_THEME_OPTION_COUNT) return;
    state = (bs_theme_page_state *)page->state;
    state->theme = settings->theme;
    state->previous_theme = settings->theme;
}

static void bs_theme_page_update(bs_settings_page *page, bs_page_emit_fn emit,
    void *context)
{
    bs_theme_page_state *state;

    if (!page || !page->state) return;
    state = (bs_theme_page_state *)page->state;
    if (state->theme == state->previous_theme) return;
    if (state->theme < 0 || state->theme >= BS_THEME_OPTION_COUNT) {
        state->theme = state->previous_theme;
        return;
    }
    state->previous_theme = state->theme;
    if (emit)
        emit(context, BS_SMGUI_EVENT_THEME_SELECTED, page->page, 0, state->theme);
}

static void bs_theme_page_destroy(bs_settings_page *page)
{
    if (!page) return;
    free(page->forms);
    free(page->state);
    *page = (bs_settings_page){0};
}

bs_settings_page bs_page_theme_create(bs_page_host *host)
{
    static const char *const option_text[BS_THEME_OPTION_COUNT] = {
        "Default", "Amber", "Ashes", "Bluish", "Candy", "Cherry", "Cyber",
        "Dark", "Enefete", "Genesis", "Jungle", "Lavanda", "RLTech", "Sunny",
        "Terminal"
    };
    bs_settings_page result = {0};
    bs_theme_page_state *state;
    ui_form_t *forms;
    int heading_text, explanation_text;
    int option_ids[BS_THEME_OPTION_COUNT];
    int i;

    if (!host) return result;
    state = (bs_theme_page_state *)calloc(1, sizeof(*state));
    forms = (ui_form_t *)calloc(4, sizeof(*forms));
    if (!state || !forms) {
        free(forms);
        free(state);
        return result;
    }

    heading_text = bs_page_text(host, "APPLICATION THEME");
    explanation_text = bs_page_text(host, "Select a raygui style resource:");
    for (i = 0; i < BS_THEME_OPTION_COUNT; ++i)
        option_ids[i] = bs_page_text(host, option_text[i]);
    if (heading_text < 0 || explanation_text < 0) goto fail;
    for (i = 0; i < BS_THEME_OPTION_COUNT; ++i) {
        if (option_ids[i] < 0) goto fail;
        state->options[i] = host->strings[option_ids[i]];
    }

    forms[0] = (ui_form_t){ .type = UI_LABEL, .x = UI_ABS(20), .y = UI_ABS(28),
        .w = 620, .h = 24, .label = heading_text };
    forms[1] = (ui_form_t){ .type = UI_LABEL, .x = UI_ABS(40), .y = UI_ABS(70),
        .w = 580, .h = 24, .label = explanation_text };
    forms[2] = (ui_form_t){ .type = UI_SELECT, .x = UI_ABS(40), .y = UI_ABS(108),
        .w = 280, .h = 26, .m = 8, .ptr = &state->theme,
        .optc = BS_THEME_OPTION_COUNT, .optv = state->options };
    forms[3] = (ui_form_t){ .type = UI_END };

    result.page = BS_SMGUI_PAGE_THEME;
    result.forms = forms;
    result.state = state;
    result.sync = bs_theme_page_sync;
    result.update = bs_theme_page_update;
    result.destroy = bs_theme_page_destroy;
    return result;

fail:
    free(forms);
    free(state);
    return result;
}
