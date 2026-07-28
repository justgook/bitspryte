#include "ui/smgui/smgui_bridge.h"

#include <assert.h>
#include <stdlib.h>
#include <string.h>

int main(void)
{
    bs_smgui *ui = bs_smgui_create(1280, 800);
    bs_smgui_rect content;
    bs_smgui_event event;
    bs_smgui_settings settings = {
        .page = BS_SMGUI_PAGE_FILES,
        .theme = 2,
        .close_window_key = 256,
        .recent_items = 16,
        .show_full_path = 1,
        .auto_recovery = 1,
        .keep_edited = 1,
        .keep_closed = 1
    };
    const uint8_t *pixels;
    int min_x = 1280, min_y = 800, max_x = -1;
    int x, y;

    assert(ui);
    bs_smgui_sync_settings(ui, &settings);
    bs_smgui_show(ui);
    pixels = bs_smgui_frame(ui);
    assert(pixels);
    assert(bs_smgui_is_open(ui));
    assert(bs_smgui_content_bounds(ui, &content));
    assert(content.width > 0 && content.height > 0);
    assert(content.x >= 0 && content.y >= 0);

    for (y = 0; y < 800; ++y) {
        for (x = 0; x < 1280; ++x) {
            if (bs_smgui_contains(ui, x, y)) {
                if (x < min_x) min_x = x;
                if (x > max_x) max_x = x;
                if (y < min_y) min_y = y;
            }
        }
    }
    /* The custom 15px close chrome fills the title interior without the
     * black square produced by using the input-background color. */
    {
        int header_height = content.y - min_y - 24; /* popup margin + content y */
        int close_x = max_x - 15;
        int close_y = min_y + 1 + (header_height - 15) / 2;
        const uint32_t *rgba = (const uint32_t *)pixels;
        uint32_t title_color = rgba[(min_y + 2) * 1280 + min_x + 100];
        assert(rgba[(close_y + 2) * 1280 + close_x + 2] == title_color);
        assert(rgba[(close_y + 7) * 1280 + close_x + 7] != title_color);
        assert(rgba[(close_y + 12) * 1280 + close_x + 12] == title_color);
    }
    /* Every page switch settles its layout in one host frame and leaves no
     * transparent holes in the popup framebuffer. */
    for (int page = 0; page < BS_SMGUI_PAGE_COUNT; ++page) {
        settings.page = page;
        bs_smgui_sync_settings(ui, &settings);
        pixels = bs_smgui_frame(ui);
        for (y = 0; y < 800; ++y)
            for (x = 0; x < 1280; ++x)
                if (bs_smgui_contains(ui, x, y))
                    assert(pixels[(y * 1280 + x) * 4 + 3] != 0);
    }
    settings.page = BS_SMGUI_PAGE_FILES;
    bs_smgui_sync_settings(ui, &settings);
    bs_smgui_frame(ui);
    /* Synchronizing application state must not report a user change. */
    assert(!bs_smgui_poll_event(ui, &event));

    /* A Files control emits a semantic field change. */
    bs_smgui_set_mouse(ui, content.x + 29, content.y + 303);
    bs_smgui_mouse_button(ui, 0, 1);
    bs_smgui_frame(ui);
    bs_smgui_mouse_button(ui, 0, 0);
    bs_smgui_frame(ui);
    assert(bs_smgui_poll_event(ui, &event));
    assert(event.kind == BS_SMGUI_EVENT_SETTING_CHANGED);
    assert(event.field == BS_SMGUI_SETTING_SHOW_FULL_PATH && event.value == 0);
    settings.show_full_path = 0;

    /* Closing while editing text releases the edit buffer and ownership. */
    x = content.x - 210 + 18 + 20;
    y = content.y + 10;
    bs_smgui_set_mouse(ui, x, y);
    bs_smgui_mouse_button(ui, 0, 1);
    bs_smgui_frame(ui);
    bs_smgui_mouse_button(ui, 0, 0);
    bs_smgui_frame(ui);
    assert(bs_smgui_captures_keyboard(ui));
    bs_smgui_text(ui, 'A');
    bs_smgui_frame(ui);
    bs_smgui_key(ui, "\x1b", 1, 0);
    bs_smgui_frame(ui);
    assert(!bs_smgui_captures_keyboard(ui));
    bs_smgui_set_mouse(ui, x, y);
    bs_smgui_mouse_button(ui, 0, 1);
    bs_smgui_frame(ui);
    bs_smgui_mouse_button(ui, 0, 0);
    bs_smgui_frame(ui);
    assert(bs_smgui_captures_keyboard(ui));
    bs_smgui_close(ui);
    assert(!bs_smgui_captures_keyboard(ui));
    bs_smgui_show(ui);
    bs_smgui_frame(ui);

    /* Keyboard Shortcuts is SMGUI-owned and requests capture semantically. */
    x = content.x - 210 + 18 + 12;
    y = content.y - 14 + 54 + 2 * 28 + 9;
    bs_smgui_set_mouse(ui, x, y);
    bs_smgui_mouse_button(ui, 0, 1);
    bs_smgui_frame(ui);
    bs_smgui_mouse_button(ui, 0, 0);
    bs_smgui_frame(ui);
    assert(bs_smgui_poll_event(ui, &event));
    assert(event.kind == BS_SMGUI_EVENT_PAGE_SELECTED && event.value == 2);
    bs_smgui_set_mouse(ui, content.x + 360, content.y + 62 + 6 * 22 + 9);
    bs_smgui_mouse_button(ui, 0, 1);
    bs_smgui_frame(ui);
    bs_smgui_mouse_button(ui, 0, 0);
    bs_smgui_frame(ui);
    assert(bs_smgui_poll_event(ui, &event));
    assert(event.kind == BS_SMGUI_EVENT_SHORTCUT_CAPTURE_REQUESTED && event.field == 6);

    /* Select Theme in the SMGUI-owned category navigation. */
    x = content.x - 210 + 18 + 12;
    y = content.y - 14 + 54 + 13 * 28 + 9;
    bs_smgui_set_mouse(ui, x, y);
    bs_smgui_mouse_button(ui, 0, 1);
    bs_smgui_frame(ui);
    bs_smgui_mouse_button(ui, 0, 0);
    bs_smgui_frame(ui);
    assert(bs_smgui_poll_event(ui, &event));
    assert(event.kind == BS_SMGUI_EVENT_PAGE_SELECTED && event.value == 13);
    assert(!bs_smgui_poll_event(ui, &event));

    bs_smgui_key(ui, "Left", 1, 0);
    assert(bs_smgui_frame(ui));
    assert(bs_smgui_resize(ui, 1100, 720) == 0);
    assert(bs_smgui_frame(ui));

    min_x = 1100; min_y = 720; max_x = -1;
    for (y = 0; y < 720; ++y) {
        for (x = 0; x < 1100; ++x) {
            if (bs_smgui_contains(ui, x, y)) {
                if (x < min_x) min_x = x;
                if (x > max_x) max_x = x;
                if (y < min_y) min_y = y;
            }
        }
    }
    assert(max_x >= min_x && min_y < 720);

    /* Closing through SMGUI's title-bar X produces one semantic outcome. */
    bs_smgui_set_mouse(ui, max_x, min_y + 1);
    bs_smgui_mouse_button(ui, 0, 1);
    bs_smgui_frame(ui);
    assert(!bs_smgui_is_open(ui));
    assert(bs_smgui_poll_event(ui, &event));
    assert(event.kind == BS_SMGUI_EVENT_CLOSED);
    assert(!bs_smgui_poll_event(ui, &event));

    bs_smgui_show(ui);
    assert(bs_smgui_is_open(ui));

    /* Programmatic close must clear a drag whose release arrives while the
     * form is hidden. Reopening must not continue moving the popup. */
    assert(bs_smgui_frame(ui));
    assert(bs_smgui_content_bounds(ui, &content));
    bs_smgui_set_mouse(ui, min_x + 20, min_y + 1);
    bs_smgui_mouse_button(ui, 0, 1);
    bs_smgui_frame(ui);
    bs_smgui_close(ui);
    bs_smgui_show(ui);
    bs_smgui_set_mouse(ui, min_x + 100, min_y + 100);
    bs_smgui_frame(ui);
    {
        bs_smgui_rect reopened;
        assert(bs_smgui_content_bounds(ui, &reopened));
        assert(reopened.x == content.x && reopened.y == content.y);
    }

    bs_smgui_close(ui);
    assert(!bs_smgui_is_open(ui));

    /* Parse an Aseprite-style sprite sheet: white separates sequential
     * U+0020 glyph rectangles and transparent pixels form each glyph. */
    {
        enum { glyph_count = 96, font_width = glyph_count * 4 + 1, font_height = 7 };
        unsigned char *sheet = (unsigned char *)malloc(font_width * font_height * 4);
        assert(sheet);
        memset(sheet, 255, font_width * font_height * 4);
        for (int glyph = 0; glyph < glyph_count; ++glyph) {
            int left = glyph * 4 + 1;
            for (y = 1; y < 6; ++y)
                memset(sheet + (y * font_width + left) * 4, 0, 3 * 4);
        }
        assert(bs_smgui_set_sprite_sheet_font(ui, sheet, font_width, font_height, 0) != 0);
        assert(bs_smgui_set_sprite_sheet_font(ui, sheet, font_width, font_height, 2) == 0);
        free(sheet);
        bs_smgui_show(ui);
        assert(bs_smgui_frame(ui));
        assert(bs_smgui_content_bounds(ui, &content));
    }

    bs_smgui_destroy(ui);
    return 0;
}
