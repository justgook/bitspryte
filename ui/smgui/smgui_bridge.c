#include "smgui_bridge.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* SMGUI normally owns a GLFW/SDL window. This backend deliberately owns no
 * window: Odin feeds raylib input into it and uploads SMGUI's RGBA buffer to a
 * raylib texture. */
#define UI_BACKEND 1
#include "vendor/ui.h"
#undef UI_H

typedef struct ui_backend_s {
    ui_t *ctx;
    int buttons;
} ui_backend_t;

static int ui_backend_fullscreen(ui_backend_t *backend) { (void)backend; return UI_OK; }
static void *ui_backend_getwindow(ui_backend_t *backend) { (void)backend; return NULL; }
static int ui_backend_settitle(ui_backend_t *backend, char *title) { (void)backend; (void)title; return UI_OK; }
static char *ui_backend_getclipboard(ui_backend_t *backend) { (void)backend; return NULL; }
static int ui_backend_setclipboard(ui_backend_t *backend, char *text) { (void)backend; (void)text; return UI_OK; }
static int ui_backend_hidecursor(ui_backend_t *backend) { (void)backend; return UI_OK; }
static int ui_backend_showcursor(ui_backend_t *backend) { (void)backend; return UI_OK; }
static int ui_backend_hideosk(ui_backend_t *backend) { (void)backend; return UI_OK; }
static int ui_backend_showosk(ui_backend_t *backend) { (void)backend; return UI_OK; }
static int ui_backend_event(ui_backend_t *backend) { (void)backend; return UI_OK; }
static int ui_backend_redraw(ui_backend_t *backend) { (void)backend; return UI_OK; }

static int ui_backend_init(ui_t *ctx, char *title, int width, int height, ui_image_t *icon)
{
    ui_backend_t *backend;
    (void)title; (void)width; (void)height; (void)icon;
    backend = (ui_backend_t *)calloc(1, sizeof(*backend));
    if (!backend) return UI_ERR_NOMEM;
    backend->ctx = ctx;
    ctx->bck = backend;
    return UI_OK;
}

static int ui_backend_free(ui_backend_t *backend)
{
    free(backend);
    return UI_OK;
}

#ifdef __APPLE__
#define L "ll"
#endif
#define UI_IMPLEMENTATION
#include "vendor/ui.h"

#include "settings/settings_internal.h"

#define BS_OUTCOME_CAPACITY 64
#define BS_STRING_CAPACITY 256

_Static_assert(sizeof(bs_smgui_settings) == 15 * sizeof(int), "settings snapshot ABI");
_Static_assert(sizeof(bs_smgui_event) == 4 * sizeof(int), "settings event ABI");
_Static_assert(BS_SMGUI_EVENT_PAGE_ACTION == 9, "settings event ordinal ABI");

typedef struct {
    uint16_t x, y, w;
    uint8_t valid;
} bs_font_glyph;

typedef struct {
    uint8_t *rgba;
    bs_font_glyph *glyphs;
    int width, height, glyph_height, glyph_count, scale;
} bs_sprite_font;

enum {
    TXT_WINDOW_TITLE,
    TXT_POPUP_TITLE,
    TXT_SEARCH,
    TXT_GENERAL,
    TXT_FILES,
    TXT_KEYBOARD_SHORTCUTS,
    TXT_COLOR,
    TXT_ALERTS,
    TXT_EDITOR,
    TXT_SELECTION,
    TXT_TIMELINE,
    TXT_CURSORS,
    TXT_BACKGROUND,
    TXT_GRID,
    TXT_GUIDES,
    TXT_UNDO,
    TXT_THEME,
    TXT_EXTENSIONS,
    TXT_ASEPRITE,
    TXT_EXPERIMENTAL,
    TXT_RESET,
    TXT_THEME_HEADING,
    TXT_THEME_LABEL,
    TXT_OK,
    TXT_APPLY,
    TXT_CANCEL,
    TXT_COUNT
};

struct bs_smgui {
    ui_t ctx;
    int page, previous_page;
    int ok, apply, cancel;
    char search[128];
    char *strings[BS_STRING_CAPACITY];
    int string_count;
    bs_settings_page pages[BS_SMGUI_PAGE_COUNT];
    ui_form_t popup[24];
    ui_form_t form[2];
    ui_form_t *content;
    uint32_t title_pixel;
    uint32_t close_pixels[15 * 15];
    bs_sprite_font font;
    bs_smgui_event outcomes[BS_OUTCOME_CAPACITY];
    int outcome_head, outcome_tail;
};

static uint32_t bs_font_codepoint(char **text, const char *end)
{
    const unsigned char *s = (const unsigned char *)*text;
    uint32_t cp;
    if ((end && (const char *)s >= end) || !*s) return 0;
    if (s[0] < 0x80) { *text += 1; return s[0]; }
    if ((s[0] & 0xe0) == 0xc0 && (!end || (const char *)s + 1 < end)) {
        cp = ((uint32_t)(s[0] & 0x1f) << 6) | (s[1] & 0x3f);
        *text += 2; return cp;
    }
    if ((s[0] & 0xf0) == 0xe0 && (!end || (const char *)s + 2 < end)) {
        cp = ((uint32_t)(s[0] & 0x0f) << 12) |
            ((uint32_t)(s[1] & 0x3f) << 6) | (s[2] & 0x3f);
        *text += 3; return cp;
    }
    if ((s[0] & 0xf8) == 0xf0 && (!end || (const char *)s + 3 < end)) {
        cp = ((uint32_t)(s[0] & 7) << 18) | ((uint32_t)(s[1] & 0x3f) << 12) |
            ((uint32_t)(s[2] & 0x3f) << 6) | (s[3] & 0x3f);
        *text += 4; return cp;
    }
    *text += 1;
    return '?';
}

static const bs_font_glyph *bs_font_glyph_for(const bs_sprite_font *font, uint32_t cp)
{
    int index = (int)cp - ' ';
    if (index >= 0 && index < font->glyph_count && font->glyphs[index].valid)
        return &font->glyphs[index];
    index = '?' - ' ';
    if (index >= 0 && index < font->glyph_count && font->glyphs[index].valid)
        return &font->glyphs[index];
    return NULL;
}

static int bs_font_bbox(void *data, char *text, char *end, int *w, int *h, int *l, int *t)
{
    bs_sprite_font *font = (bs_sprite_font *)data;
    int line = 0, widest = 0, lines = 1;
    uint32_t cp;
    if (!font || !text || !w || !h) return -1;
    while ((cp = bs_font_codepoint(&text, end)) != 0) {
        const bs_font_glyph *glyph;
        if (cp == '\r') { line = 0; continue; }
        if (cp == '\n') { if (line > widest) widest = line; line = 0; ++lines; continue; }
        glyph = bs_font_glyph_for(font, cp);
        if (glyph) line += glyph->w * font->scale;
    }
    if (line > widest) widest = line;
    *w = widest;
    *h = lines * font->glyph_height * font->scale;
    if (l) *l = 0;
    if (t) *t = 0;
    return 0;
}

static int bs_font_draw(void *data, char *text, char *end, uint8_t *dst,
    uint32_t color, int x, int y, int l, int t, int pitch,
    int cx0, int cy0, int cx1, int cy1)
{
    bs_sprite_font *font = (bs_sprite_font *)data;
    int origin_x = x;
    uint32_t cp;
    (void)l; (void)t;
    if (!font || !text || !dst || pitch < 4) return -1;
    while ((cp = bs_font_codepoint(&text, end)) != 0) {
        const bs_font_glyph *glyph;
        int gx, gy, sx, sy;
        if (cp == '\r') { x = origin_x; continue; }
        if (cp == '\n') { x = origin_x; y += font->glyph_height * font->scale; continue; }
        glyph = bs_font_glyph_for(font, cp);
        if (!glyph) continue;
        for (sy = 0; sy < font->glyph_height; ++sy) {
            for (sx = 0; sx < glyph->w; ++sx) {
                const uint8_t *source = font->rgba +
                    ((glyph->y + sy) * font->width + glyph->x + sx) * 4;
                if (source[3] < 128) continue;
                for (gy = 0; gy < font->scale; ++gy) {
                    int dy = y + sy * font->scale + gy;
                    if (dy < cy0 || dy >= cy1) continue;
                    for (gx = 0; gx < font->scale; ++gx) {
                        int dx = x + sx * font->scale + gx;
                        if (dx >= cx0 && dx < cx1)
                            memcpy(dst + dy * pitch + dx * 4, &color, 4);
                    }
                }
            }
        }
        x += glyph->w * font->scale;
    }
    return 0;
}

static void bs_push_outcome(bs_smgui *ui, int kind, int page, int field, int value)
{
    int next = (ui->outcome_head + 1) % BS_OUTCOME_CAPACITY;
    if (next == ui->outcome_tail) return;
    ui->outcomes[ui->outcome_head] = (bs_smgui_event){ kind, page, field, value };
    ui->outcome_head = next;
}

static void bs_page_emit(void *context, int kind, int page, int field, int value)
{
    bs_push_outcome((bs_smgui *)context, kind, page, field, value);
}

int bs_page_text(bs_page_host *host, const char *text)
{
    int id;
    if (!host || !host->strings || !host->string_count || !text ||
        *host->string_count >= host->string_capacity) return -1;
    id = (*host->string_count)++;
    host->strings[id] = (char *)text;
    return id;
}

static void bs_build_default_chrome(bs_smgui *ui)
{
    int x, y;
    uint32_t mark = ui->ctx.theme[UI_BG];

    ui->title_pixel = ui->ctx.theme[UI_TIT];
    for (y = 0; y < 15; ++y) {
        for (x = 0; x < 15; ++x) {
            uint32_t color = ui->title_pixel;
            if ((x >= 4 && x <= 10) && (x == y || x + y == 14)) color = mark;
            ui->close_pixels[y * 15 + x] = color;
        }
    }
    ui->ctx.skin[UI_P_TIT] = (ui_image_t){ 1, 1, 4, (uint8_t *)&ui->title_pixel };
    ui->ctx.skin[UI_P_CLOSE] = (ui_image_t){ 15, 15, 15 * 4, (uint8_t *)ui->close_pixels };
}

static int bs_build_settings_form(bs_smgui *ui)
{
    static const char *categories[BS_SMGUI_PAGE_COUNT] = {
        "General", "Files", "Keyboard Shortcuts", "Color", "Alerts", "Editor",
        "Selection", "Timeline", "Cursors", "Background", "Grid", "Guides & Slices",
        "Undo", "Theme", "Extensions", "Aseprite Format", "Experimental", "Reset"
    };
    bs_page_host host;
    int i, n = 0;

    ui->strings[TXT_WINDOW_TITLE] = "BitSpryte";
    ui->strings[TXT_POPUP_TITLE] = "Preferences";
    ui->strings[TXT_SEARCH] = "Search";
    for (i = 0; i < BS_SMGUI_PAGE_COUNT; ++i)
        ui->strings[TXT_GENERAL + i] = (char *)categories[i];
    ui->strings[TXT_THEME_HEADING] = "APPLICATION THEME";
    ui->strings[TXT_THEME_LABEL] = "Select an application theme:";
    ui->strings[TXT_OK] = "OK";
    ui->strings[TXT_APPLY] = "Apply";
    ui->strings[TXT_CANCEL] = "Cancel";
    ui->string_count = TXT_COUNT;
    host = (bs_page_host){ ui->strings, &ui->string_count, BS_STRING_CAPACITY };

    ui->pages[0] = bs_page_general_create(&host);
    ui->pages[1] = bs_page_files_create(&host);
    ui->pages[2] = bs_page_keyboard_shortcuts_create(&host);
    ui->pages[3] = bs_page_color_create(&host);
    ui->pages[4] = bs_page_alerts_create(&host);
    ui->pages[5] = bs_page_editor_create(&host);
    ui->pages[6] = bs_page_selection_create(&host);
    ui->pages[7] = bs_page_timeline_create(&host);
    ui->pages[8] = bs_page_cursors_create(&host);
    ui->pages[9] = bs_page_background_create(&host);
    ui->pages[10] = bs_page_grid_create(&host);
    ui->pages[11] = bs_page_guides_and_slices_create(&host);
    ui->pages[12] = bs_page_undo_create(&host);
    ui->pages[13] = bs_page_theme_create(&host);
    ui->pages[14] = bs_page_extensions_create(&host);
    ui->pages[15] = bs_page_aseprite_format_create(&host);
    ui->pages[16] = bs_page_experimental_create(&host);
    ui->pages[17] = bs_page_reset_create(&host);
    for (i = 0; i < BS_SMGUI_PAGE_COUNT; ++i)
        if (!ui->pages[i].forms) return 0;

    ui->popup[n++] = (ui_form_t){ .type = UI_TXTINP, .x = UI_ABS(18), .y = UI_ABS(14),
        .w = 176, .h = 30, .m = 6, .ptr = ui->search, .max = sizeof(ui->search) };
    for (i = 0; i < BS_SMGUI_PAGE_COUNT; ++i) {
        ui->popup[n++] = (ui_form_t){ .type = UI_RADIO, .x = UI_ABS(26), .y = UI_ABS(54 + i * 28),
            .w = 168, .h = 18, .m = 5, .ptr = &ui->page, .value = i,
            .label = TXT_GENERAL + i };
    }
    ui->content = &ui->popup[n];
    ui->popup[n++] = (ui_form_t){ .type = UI_DIV, .x = UI_ABS(210), .y = UI_ABS(14),
        .w = 672, .h = 566, .m = 2, .p = 4, .ptr = ui->pages[ui->page].forms };
    ui->popup[n++] = (ui_form_t){ .type = UI_BUTTON, .x = UI_ABS(496), .y = UI_ABS(610),
        .w = 120, .h = 30, .ptr = &ui->ok, .value = 1, .label = TXT_OK };
    ui->popup[n++] = (ui_form_t){ .type = UI_BUTTON, .x = UI_ABS(628), .y = UI_ABS(610),
        .w = 120, .h = 30, .ptr = &ui->apply, .value = 1, .label = TXT_APPLY };
    ui->popup[n++] = (ui_form_t){ .type = UI_BUTTON, .x = UI_ABS(760), .y = UI_ABS(610),
        .w = 120, .h = 30, .ptr = &ui->cancel, .value = 1, .label = TXT_CANCEL };
    ui->popup[n++] = (ui_form_t){ .type = UI_END };

    ui->form[0] = (ui_form_t){ .type = UI_POPUP, .align = UI_CENTER | UI_MIDDLE,
        .flags = UI_DRAGGABLE | UI_HIDDEN, .x = UI_PERCENT(50), .y = UI_PERCENT(50),
        .w = 900, .h = 680, .m = 8, .ptr = ui->popup, .label = TXT_POPUP_TITLE };
    ui->form[1] = (ui_form_t){ .type = UI_END };
    return 1;
}

static void bs_destroy_pages(bs_smgui *ui)
{
    int i;
    for (i = 0; i < BS_SMGUI_PAGE_COUNT; ++i)
        if (ui->pages[i].destroy) ui->pages[i].destroy(&ui->pages[i]);
}

bs_smgui *bs_smgui_create(int width, int height)
{
    bs_smgui *ui;
    if (width < 1 || height < 1) return NULL;
    ui = (bs_smgui *)calloc(1, sizeof(*ui));
    if (!ui) return NULL;
    ui->page = ui->previous_page = BS_SMGUI_PAGE_FILES;
    if (!bs_build_settings_form(ui)) {
        bs_destroy_pages(ui);
        free(ui);
        return NULL;
    }
    if (ui_init(&ui->ctx, ui->string_count, ui->strings, width, height, NULL) != UI_OK ||
        !ui->ctx.screen.buf || !ui->ctx.bck) {
        ui_free(&ui->ctx);
        bs_destroy_pages(ui);
        free(ui);
        return NULL;
    }
    /* The unskinned SMGUI fallback draws a fixed 5px checkbox for close,
     * regardless of title height. A minimal title/close skin keeps the close
     * control aligned with the font-derived header until the full app skin is
     * introduced. */
    bs_build_default_chrome(ui);
    ui_refresh(&ui->ctx);
    return ui;
}

void bs_smgui_destroy(bs_smgui *ui)
{
    if (!ui) return;
    ui_free(&ui->ctx);
    bs_destroy_pages(ui);
    free(ui->font.rgba);
    free(ui->font.glyphs);
    free(ui);
}

static void bs_reset_interaction(bs_smgui *ui);

int bs_smgui_resize(bs_smgui *ui, int width, int height)
{
    uint8_t *buffer;
    ui_event_t *event;
    size_t bytes;
    if (!ui || width < 1 || height < 1 ||
        (size_t)width > SIZE_MAX / 4 / (size_t)height) return UI_ERR_BADINP;
    bytes = (size_t)width * height * 4;
    buffer = (uint8_t *)malloc(bytes);
    if (!buffer) return UI_ERR_NOMEM;
    memset(buffer, 0, bytes);
    free(ui->ctx.screen.buf);
    ui->ctx.screen.buf = buffer;
    ui->ctx.screen.w = width;
    ui->ctx.screen.h = height;
    ui->ctx.screen.p = width * 4;
    bs_reset_interaction(ui);
    ui->ctx.form = ui->ctx.menu = NULL;
    ui->ctx.flags |= UI_CLOSE;
    event = _ui_evtslot(&ui->ctx);
    if (event) { event->x = width; event->y = height; event->type = UI_EVT_RESIZE; }
    return UI_OK;
}

int bs_smgui_set_sprite_sheet_font(bs_smgui *ui, const unsigned char *rgba,
    int width, int height, int scale)
{
    bs_font_glyph *glyphs = NULL;
    uint8_t *copy = NULL;
    int capacity = 0, count = 0, glyph_height = 0;
    int x = 0, y = 0, row_height = 1;
    const uint8_t *key;
    size_t image_size;

    if (!ui || !rgba || width < 2 || height < 2 || width > 65535 || height > 65535 ||
        scale < 1 || scale > 8 || (size_t)width > SIZE_MAX / 4 / (size_t)height)
        return UI_ERR_BADINP;
    key = rgba;
    while (y < height) {
        const uint8_t *pixel;
        int glyph_width, current_height;
        while (y < height && !memcmp(rgba + ((size_t)y * width + x) * 4, key, 4)) {
            if (++x >= width) {
                x = 0;
                y += row_height;
                row_height = 1;
            }
        }
        if (y >= height) break;
        pixel = rgba + ((size_t)y * width + x) * 4;
        for (glyph_width = 0; x + glyph_width < width &&
            memcmp(rgba + ((size_t)y * width + x + glyph_width) * 4, key, 4);
            ++glyph_width) {}
        for (current_height = 0; y + current_height < height &&
            memcmp(rgba + ((size_t)(y + current_height) * width + x) * 4, key, 4);
            ++current_height) {}
        if (glyph_width < 1 || current_height < 1 ||
            (glyph_height && current_height != glyph_height)) {
            free(glyphs);
            return UI_ERR_BADINP;
        }
        glyph_height = current_height;
        if (count == capacity) {
            int next_capacity = capacity ? capacity * 2 : 256;
            bs_font_glyph *next = (bs_font_glyph *)realloc(glyphs,
                (size_t)next_capacity * sizeof(*glyphs));
            if (!next) { free(glyphs); return UI_ERR_NOMEM; }
            glyphs = next;
            capacity = next_capacity;
        }
        glyphs[count++] = (bs_font_glyph){ (uint16_t)x, (uint16_t)y,
            (uint16_t)glyph_width,
            (uint8_t)!(pixel[0] == 255 && pixel[1] == 0 && pixel[2] == 0 && pixel[3] == 255) };
        x += glyph_width;
        row_height = current_height;
    }
    if (count < 1) { free(glyphs); return UI_ERR_BADINP; }
    image_size = (size_t)width * height * 4;
    copy = (uint8_t *)malloc(image_size);
    if (!copy) { free(glyphs); return UI_ERR_NOMEM; }
    memcpy(copy, rgba, image_size);

    bs_reset_interaction(ui);
    free(ui->font.rgba);
    free(ui->font.glyphs);
    ui->font = (bs_sprite_font){ copy, glyphs, width, height, glyph_height, count, scale };
    ui_fonthook(&ui->ctx, bs_font_bbox, bs_font_draw);
    ui_font(&ui->ctx, &ui->font);
    ui_refresh(&ui->ctx);
    return UI_OK;
}

static void bs_reset_interaction(bs_smgui *ui)
{
    ui_backend_t *backend = (ui_backend_t *)ui->ctx.bck;
    backend->buttons = 0;
    if (ui->ctx.text) {
        if (ui->ctx.buf && ui->ctx.text->type != UI_COLOR && ui->ctx.str && ui->ctx.end)
            memcpy(ui->ctx.str, ui->ctx.buf,
                (size_t)((uintptr_t)ui->ctx.end - (uintptr_t)ui->ctx.buf) + 1);
        free(ui->ctx.buf);
        ui->ctx.buf = NULL;
        ui->ctx.scr = NULL;
        ui->ctx.cur = NULL;
        ui->ctx.end = NULL;
        ui->ctx.str = NULL;
        ui->ctx.text = NULL;
        ui_backend_hideosk(backend);
    }
    ui->ctx.drag = NULL;
    ui->ctx.resize = NULL;
    ui->ctx.pressed = NULL;
    ui->ctx.vscr = NULL;
    ui->ctx.hscr = NULL;
    ui->ctx.popup = NULL;
    ui->ctx.pe = NULL;
    ui->ctx.dr = NULL;
}

void bs_smgui_show(bs_smgui *ui)
{
    if (!ui) return;
    bs_reset_interaction(ui);
    ui->form[0].flags &= (short)~UI_HIDDEN;
    ui_refresh(&ui->ctx);
}

void bs_smgui_close(bs_smgui *ui)
{
    if (!ui) return;
    bs_reset_interaction(ui);
    ui->form[0].flags |= UI_HIDDEN;
    ui_refresh(&ui->ctx);
}

void bs_smgui_sync_settings(bs_smgui *ui, const bs_smgui_settings *settings)
{
    int i;
    if (!ui || !settings) return;
    if (settings->page >= 0 && settings->page < BS_SMGUI_PAGE_COUNT) {
        ui->page = ui->previous_page = settings->page;
        ui->content->ptr = ui->pages[ui->page].forms;
    }
    for (i = 0; i < BS_SMGUI_PAGE_COUNT; ++i)
        if (ui->pages[i].sync) ui->pages[i].sync(&ui->pages[i], settings);
    ui_refresh(&ui->ctx);
}

void bs_smgui_set_mouse(bs_smgui *ui, int x, int y)
{
    if (ui) _ui_setmouse(&ui->ctx, x, y);
}

void bs_smgui_mouse_button(bs_smgui *ui, int button, int pressed)
{
    ui_event_t *event;
    ui_backend_t *backend;
    int mask;
    if (!ui || button < 0 || button > 2) return;
    backend = (ui_backend_t *)ui->ctx.bck;
    mask = button == 0 ? UI_BTN_L : button == 1 ? UI_BTN_R : UI_BTN_M;
    if (pressed) backend->buttons |= mask; else backend->buttons &= ~mask;
    event = _ui_evtslot(&ui->ctx);
    if (!event) return;
    event->type = UI_EVT_MOUSE;
    event->x = ui->ctx.mousex;
    event->y = ui->ctx.mousey;
    event->btn = backend->buttons | (pressed ? 0 : UI_BTN_RELEASE);
}

void bs_smgui_mouse_wheel(bs_smgui *ui, float delta)
{
    ui_event_t *event;
    ui_backend_t *backend;
    if (!ui || delta == 0) return;
    backend = (ui_backend_t *)ui->ctx.bck;
    event = _ui_evtslot(&ui->ctx);
    if (!event) return;
    event->type = UI_EVT_MOUSE;
    event->x = ui->ctx.mousex;
    event->y = ui->ctx.mousey;
    event->btn = backend->buttons | (delta > 0 ? UI_BTN_U : UI_BTN_D);
}

void bs_smgui_key(bs_smgui *ui, const char *key, int pressed, int modifiers)
{
    ui_event_t *event;
    if (!ui || !key || !*key) return;
    event = _ui_evtslot(&ui->ctx);
    if (!event) return;
    event->type = UI_EVT_KEY;
    event->btn = modifiers | (pressed ? 0 : UI_BTN_RELEASE);
    strncpy(event->key, key, sizeof(event->key) - 1);
}

void bs_smgui_text(bs_smgui *ui, uint32_t codepoint)
{
    ui_event_t *event;
    if (!ui || codepoint < 32 || codepoint > 0x10ffff) return;
    event = _ui_evtslot(&ui->ctx);
    if (!event) return;
    event->type = UI_EVT_KEY;
    if (codepoint < 0x80) event->key[0] = (char)codepoint;
    else if (codepoint < 0x800) {
        event->key[0] = (char)(0xc0 | (codepoint >> 6));
        event->key[1] = (char)(0x80 | (codepoint & 0x3f));
    } else if (codepoint < 0x10000) {
        event->key[0] = (char)(0xe0 | (codepoint >> 12));
        event->key[1] = (char)(0x80 | ((codepoint >> 6) & 0x3f));
        event->key[2] = (char)(0x80 | (codepoint & 0x3f));
    } else {
        event->key[0] = (char)(0xf0 | (codepoint >> 18));
        event->key[1] = (char)(0x80 | ((codepoint >> 12) & 0x3f));
        event->key[2] = (char)(0x80 | ((codepoint >> 6) & 0x3f));
        event->key[3] = (char)(0x80 | (codepoint & 0x3f));
    }
}

const uint8_t *bs_smgui_frame(bs_smgui *ui)
{
    int was_open, render_pass;
    if (!ui) return NULL;
    was_open = !(ui->form[0].flags & UI_HIDDEN);
    do {
        ui_event(&ui->ctx, ui->form);
    } while (ui->ctx.tail != ui->ctx.head);

    if (ui->page != ui->previous_page) {
        ui->previous_page = ui->page;
        ui->content->ptr = ui->pages[ui->page].forms;
        ui_refresh(&ui->ctx);
        bs_push_outcome(ui, BS_SMGUI_EVENT_PAGE_SELECTED, ui->page, 0, ui->page);
    }
    if (ui->pages[ui->page].update)
        ui->pages[ui->page].update(&ui->pages[ui->page], bs_page_emit, ui);
    if (ui->pages[ui->page].dirty) {
        ui->pages[ui->page].dirty = 0;
        ui_refresh(&ui->ctx);
    }
    if (ui->ok) {
        ui->ok = 0;
        bs_push_outcome(ui, BS_SMGUI_EVENT_ACCEPTED, ui->page, 0, 0);
        bs_smgui_close(ui);
        was_open = 0;
    }
    if (ui->apply) {
        ui->apply = 0;
        bs_push_outcome(ui, BS_SMGUI_EVENT_APPLY_REQUESTED, ui->page, 0, 0);
    }
    if (ui->cancel) {
        ui->cancel = 0;
        bs_push_outcome(ui, BS_SMGUI_EVENT_CANCELLED, ui->page, 0, 0);
        bs_smgui_close(ui);
        was_open = 0;
    }
    if (was_open && (ui->form[0].flags & UI_HIDDEN))
        bs_push_outcome(ui, BS_SMGUI_EVENT_CLOSED, ui->page, 0, 0);
    /* Form-pointer changes can require several layout/refresh passes as child
     * metrics settle. Finish them in this host frame so page switches never
     * expose a partially-cleared framebuffer. */
    for (render_pass = 0; render_pass < 8 && (ui->ctx.flags & UI_REFRESH); ++render_pass)
        ui_event(&ui->ctx, ui->form);
    return ui->ctx.screen.buf;
}

int bs_smgui_poll_event(bs_smgui *ui, bs_smgui_event *event)
{
    if (!ui || !event || ui->outcome_tail == ui->outcome_head) return 0;
    *event = ui->outcomes[ui->outcome_tail];
    ui->outcome_tail = (ui->outcome_tail + 1) % BS_OUTCOME_CAPACITY;
    return 1;
}

int bs_smgui_content_bounds(const bs_smgui *ui, bs_smgui_rect *bounds)
{
    const ui_form_t *popup;
    if (!ui || !bounds || !ui->content || !bs_smgui_is_open(ui)) return 0;
    popup = &ui->form[0];
    bounds->x = popup->ex + popup->m + ui->content->ex;
    bounds->y = popup->ey + popup->m + popup->value + ui->content->ey;
    bounds->width = ui->content->ew;
    bounds->height = ui->content->eh;
    return 1;
}

int bs_smgui_contains(const bs_smgui *ui, int x, int y)
{
    const ui_form_t *popup;
    if (!ui) return 0;
    popup = &ui->form[0];
    if (popup->flags & UI_HIDDEN) return 0;
    return x >= popup->ex && x < popup->ex + popup->ew &&
        y >= popup->ey && y < popup->ey + popup->eh;
}

int bs_smgui_captures_keyboard(const bs_smgui *ui)
{
    return ui && ui->ctx.text != NULL;
}

int bs_smgui_is_open(const bs_smgui *ui)
{
    return ui && !(ui->form[0].flags & UI_HIDDEN);
}
