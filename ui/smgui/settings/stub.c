#include "settings_internal.h"

#include <stdlib.h>

typedef struct bs_stub_page_state {
    int action;
} bs_stub_page_state;

static void bs_stub_page_update(bs_settings_page *page, bs_page_emit_fn emit,
    void *context)
{
    bs_stub_page_state *state;

    if (!page || !page->state) return;
    state = (bs_stub_page_state *)page->state;
    if (!state->action) return;
    state->action = 0;
    if (emit)
        emit(context, BS_SMGUI_EVENT_PAGE_ACTION, page->page, 0, 0);
}

static void bs_stub_page_destroy(bs_settings_page *page)
{
    if (!page) return;
    free(page->forms);
    free(page->state);
    *page = (bs_settings_page){0};
}

bs_settings_page bs_stub_page_create(bs_page_host *host, int page,
    const char *title, const char *description)
{
    bs_settings_page result = {0};
    bs_stub_page_state *state;
    ui_form_t *forms;
    int title_text, description_text, action_text;

    if (!host || !title || !description) return result;
    state = (bs_stub_page_state *)calloc(1, sizeof(*state));
    forms = (ui_form_t *)calloc(4, sizeof(*forms));
    if (!state || !forms) {
        free(forms);
        free(state);
        return result;
    }

    title_text = bs_page_text(host, title);
    description_text = bs_page_text(host, description);
    action_text = bs_page_text(host, "Run Mock Action");
    if (title_text < 0 || description_text < 0 || action_text < 0) {
        free(forms);
        free(state);
        return result;
    }

    forms[0] = (ui_form_t){ .type = UI_LABEL, .x = UI_ABS(20), .y = UI_ABS(28),
        .w = 620, .h = 24, .label = title_text };
    forms[1] = (ui_form_t){ .type = UI_LABEL, .x = UI_ABS(40), .y = UI_ABS(70),
        .w = 580, .h = 24, .label = description_text };
    forms[2] = (ui_form_t){ .type = UI_BUTTON, .x = UI_ABS(40), .y = UI_ABS(110),
        .w = 180, .h = 28, .ptr = &state->action, .value = 1,
        .label = action_text };
    forms[3] = (ui_form_t){ .type = UI_END };

    result.page = page;
    result.forms = forms;
    result.state = state;
    result.update = bs_stub_page_update;
    result.destroy = bs_stub_page_destroy;
    return result;
}
