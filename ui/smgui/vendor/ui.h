/*
 * ui.h
 * https://gitlab.com/bztsrc/smgui
 *
 * Copyright (C) 2024 bzt (bztsrc@gitlab), MIT license
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL ANY
 * DEVELOPER OR DISTRIBUTOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 * IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * @brief Single header, State-Mode Graphical User Interface ANSI C/C++ library
 */

#ifndef UI_H
#define UI_H

#include <stdint.h>
#include <string.h>
#include <stdlib.h>

#ifndef UI_OK
/* return codes */
#define UI_OK            0
#define UI_ERR_BADINP   -1
#define UI_ERR_BACKEND  -2
#define UI_ERR_NOMEM    -3

#ifndef UI_MAXEVENTS
#define UI_MAXEVENTS 16
#endif

#ifndef UI_MAXPOPUPS
#define UI_MAXPOPUPS 16
#endif

#ifdef  __cplusplus
extern "C" {
#endif

/* theme colors */
enum {
    UI_FG,      /* foreground color */
    UI_TIT,     /* popup and menu title color */
    UI_BG,      /* popup and menu background color */
    UI_SH,      /* popup and menu shadow color */
    UI_TFG,     /* toggle active foreground color */
    UI_TBG,     /* toggle active background color */
    UI_HLFG,    /* menu highlight foreground color */
    UI_HLBG,    /* menu highlight background color */
    UI_DFG,     /* disabled foreground color */
    UI_DBG,     /* disabled background color */
    UI_SBG,     /* scrollbar background color */
    UI_IFG,     /* input box foreground color */
    UI_IL,      /* input box light border color */
    UI_ID,      /* input box dark border color */
    UI_IBG,     /* input box background color */
    UI_ICF,     /* input box selected foreground color */
    UI_IB,      /* input box selected border color */
    UI_IC,      /* input box selected cursor color */
    UI_BFG,     /* button foreground color */
    UI_SBL,     /* button light shadow color */
    UI_SBD,     /* button dark shadow color */
    UI_BN,      /* button normal outter border color */
    UI_SFG,     /* button selected foreground color */
    UI_SSL,     /* button selected light shadow color */
    UI_SSD,     /* button selected dark shadow color */
    UI_BS,      /* button selected outter border color */
    UI_BL,      /* button light inner border color */
    UI_BD,      /* button dark inner border color */
    UI_BGL,     /* button light background color */
    UI_BGD,     /* button dark background color */
    UI_PL,      /* progressbar light color */
    UI_PB,      /* progressbar background color */
    UI_PD,      /* progressbar dark color */
    UI_NUMTHEME
};
/* skin images */
enum {
    UI_CURSOR,                      /* the mouse cursor */
    UI_P_TL, UI_P_TM, UI_P_TR,      /* popup and menu top left corner, top middle, top right corner */
    UI_P_ML, UI_P_BG, UI_P_MR,      /* popup and menu left, background, right */
    UI_P_BL, UI_P_BM, UI_P_BR,      /* popup and menu bottom left corner, bottom middle, bottom right corner */
    UI_P_TIT, UI_P_CLOSE,           /* popup and menu title background, close button */
    UI_A_TL, UI_A_TM, UI_A_TR,      /* same, but with alternative images */
    UI_A_ML, UI_A_BG, UI_A_MR,
    UI_A_BL, UI_A_BM, UI_A_BR,
    UI_A_TIT, UI_A_CLOSE,
    UI_M_L, UI_M_BG, UI_M_R,        /* menu alternative left side, background and right side */
    UI_HL,                          /* menu highlight background */
    UI_INP,                         /* input box background */
    UI_PBG,                         /* progress bar button background */
    UI_S_L, UI_S_M, UI_S_R, UI_S_B, /* slider left side, background, right side and button */
    UI_SV_T, UI_SV_M, UI_SV_B,      /* vertical scrollbar background top, middle, bottom */
    UI_SV_BT, UI_SV_BM, UI_SV_BB,   /* vertical scrollbar button top, middle, bottom */
    UI_SH_L, UI_SH_M, UI_SH_R,      /* horizontal scrollbar background left, middle, right */
    UI_SH_BL, UI_SH_BM, UI_SH_BR,   /* horizontal scrollbar button left, middle, right */
    UI_CHK0, UI_CHK1,               /* checkbox unchecked, checked */
    UI_RADIO0, UI_RADIO1,           /* radiobutton unchecked, checked */
    UI_BNL, UI_BNM, UI_BNR,         /* normal button left, middle, right */
    UI_BPL, UI_BPM, UI_BPR,         /* pressed button left, middle, right */
    UI_BSL, UI_BSM, UI_BSR,         /* selected button left, middle, right */
    UI_LN, UI_DN, UI_RN,            /* normal arrow button left, down, right */
    UI_LP, UI_DP, UI_RP,            /* pressed arrow button left, down, right */
    UI_LS, UI_DS, UI_RS,            /* selected arrow button left, down, right */
    UI_NUMSKIN };
/* field types */
enum { UI_END,
    /* containers */
    UI_POPUP, UI_MENU, UI_DIV,
    /* display labels */
    UI_LABEL, UI_MLINE, UI_STATUS, UI_DEC_FLOAT, UI_PBAR, UI_IMAGE, UI_ICON, UI_DEC8, UI_DEC16, UI_DEC32, UI_DEC64, UI_HEX8, UI_HEX16, UI_HEX32, UI_HEX64,
    /* input fields */
    UI_TXTINP, UI_SELECT, UI_OPTION, UI_FLOAT, UI_INT8, UI_INT16, UI_INT32, UI_INT64, UI_SLIDER, UI_VSCRBAR, UI_HSCRBAR, UI_COLOR,
    /* buttons */
    UI_TOGGLE, UI_CHECK, UI_RADIO, UI_BUTTON, UI_BTNTGL, UI_BTNICN,
    /* lines */
    UI_LINES, UI_VCONNECT, UI_HCONNECT, UI_CURVE,
    /* custom implemented widget */
    UI_CUSTOM
};
#define UI_CONTAINER(x) ((x) > UI_END && (x) <= UI_DIV)
/* ui_form_t positions */
#define UI_REL(x)       ((x) & 0xffff)
#define UI_ABS(x)       (((x) & 0xffff) | 0x800000)
#define UI_PERCENT(x)   (((x)<<16) | 0x800000)
#define UI_PERPLUS(x,p) (((x)<<16) | ((p) & 0xffff))
#define UI_ABS_RIGHT(x)     (-((int16_t)(x)) | 0x800000)
#define UI_ABS_BOTTOM(x)    (-((int16_t)(x)) | 0x800000)
/* ui_form_t alignments */
#define UI_LEFT    0
#define UI_RIGHT   1
#define UI_CENTER  2
#define UI_TOP     (0<<2)
#define UI_BOTTOM  (1<<2)
#define UI_MIDDLE  (2<<2)
/* ui_form_t flags */
#define UI_HIDDEN          1
#define UI_NOBULLET        2
#define UI_NOHEADER        2
#define UI_NOBR            4
#define UI_FORCEBR         8
#define UI_POINTER         8
#define UI_NOBORDER       16
#define UI_NOSHADOW       32
#define UI_ALTSKIN        64
#define UI_HSCROLL       128
#define UI_VSCROLL       256
#define UI_SCROLL        384
#define UI_DRAGGABLE     512
#define UI_RESIZABLE    1024
#define UI_SELECTED     2048
#define UI_DISABLED     4096

#define UI_REFRESH         1
#define UI_RECALC          2
#define UI_CLOSE           4
#define UI_DONE            8

enum { UI_FILTER_NONE, UI_FILTER_ID, UI_FILTER_VAR, UI_FILTER_EXPR, UI_FILTER_HEX, UI_FILTER_PASS };
enum { UI_EVT_NONE, UI_EVT_MOUSE, UI_EVT_GAMEPAD, UI_EVT_KEY, UI_EVT_DROP, UI_EVT_RESIZE };
enum { UI_BTN_L = 1, UI_BTN_M = 2, UI_BTN_R = 4, UI_BTN_U = 8, UI_BTN_D = 16,
    UI_BTN_A = 32, UI_BTN_B = 64, UI_BTN_X = 128, UI_BTN_Y = 256, UI_BTN_BA = 512, UI_BTN_ST = 1024, UI_BTN_GU = 2048,
    UI_BTN_LT = 4096, UI_BTN_RT = 8192, UI_BTN_LS = 16384, UI_BTN_RS = 32768 };
enum { UI_BTN_RELEASE = 0x80000, UI_BTN_SHIFT = 0x100000, UI_BTN_CONTROL = 0x200000, UI_BTN_ALT = 0x400000, UI_BTN_GUI = 0x800000 };
typedef struct {
    int type, btn, x, y, rx, ry;
    char key[8];
    const char *fn;
} ui_event_t;

typedef struct ui_form_s ui_form_t;
typedef struct ui_s ui_t;

/**
 * The font and custom widget callbacks
 */
typedef int (*ui_font_bbox)(void *fnt, char *str, char *end, int *w, int *h, int *l, int *t);
typedef int (*ui_font_draw)(void *fnt, char *str, char *end, uint8_t *dst, uint32_t color, int x, int y, int l, int t, int p,
    int cx0, int cy0, int cx1, int cy1);
typedef int (*ui_bbox)(ui_t *ctx, int x, int y, int w, int h, ui_form_t *form, int *dw, int *dh);
typedef int (*ui_view)(ui_t *ctx, int x, int y, int w, int h, ui_form_t *form);
typedef int (*ui_ctrl)(ui_t *ctx, int x, int y, int w, int h, ui_form_t *form, ui_event_t *evt);
typedef int (*ui_fini)(ui_t *ctx, ui_form_t *form);
typedef int (*ui_comp)(const void *a, const void *b);

/**
 * Pixel buffer type
 */
typedef struct {
    int w, h, p;
    uint8_t *buf;
} ui_image_t;

/**
 * Form element
 */
typedef struct ui_form_s {
    char type, align;
    short flags;
    int x, y, w, h, m, p, l, t, desc;
    int ex, ey, ew, eh;
    void *ptr;
    int64_t min, max, inc;
    union {
        struct { float fmin, fmax, finc; };
        struct { ui_image_t *icon; int value, label, ox, oy, mw, mh, sw, sh; uint32_t fg, bg; };
        struct { ui_bbox bbox; ui_view view; ui_ctrl ctrl; ui_fini fini; ui_comp *cmps; void *data; int str, *idx; char *tblstr; };
        struct { char **optv; int optc, sel; };
    };
} ui_form_t;

/**
 * The main UI context
 */
typedef struct ui_s {
    ui_image_t screen;              /* important this must be at offset(0) */
    ui_image_t skin[UI_NUMSKIN];    /* skin images */
    void *bck;                      /* backend specific */
    uint8_t *skinbuf;               /* skin buffer if loaded from packed PNG */
    uint32_t theme[UI_NUMTHEME];    /* color theme */
    int txtc;                       /* number of texts */
    char **txtv;                    /* texts, localized string array */
    void *fnt;                      /* selected font */
    ui_font_bbox bbox;              /* font bounding box hook */
    ui_font_draw draw;              /* font rendering hook */
    ui_form_t *form, *menu, *hover, *drag, *resize, *pressed, *vscr, *hscr, *text, *popup; /* for states */
    int dx, dy;                     /* drag delta coordinates */
    int ds, dt;                     /* default font size and default top baseline */
    int numpopups;                  /* number of visible popups */
    ui_form_t *popups[UI_MAXPOPUPS];/* visible popups in z order */
    volatile int head, tail;        /* event queue */
    ui_event_t events[UI_MAXEVENTS];
    ui_ctrl pe;                     /* popup event handler */
    ui_view dr;                     /* popup draw handler */
    int px, py, pw, ph;             /* popup position and size */
    volatile uint64_t flags;        /* pupop flags */
    int hue, sat, val;              /* color picker HSV */
    uint32_t color, hist[16];       /* color picker current color and history */
    char *scr, *cur, *end, *buf, *str; /* edited text buffer */
    int maxlen;                     /* edited text buffer max length */
    int mousex, mousey;             /* current mouse coordinates */
    int lastx, lasty;               /* last mouse coordinates */
    ui_image_t mouse;               /* mouse backbuffer */
    int cx0, cy0, cx1, cy1;         /* crop area */
    int bx, by;                     /* prev coorindates for Bezier */
    int sw, sh, sb, sm, s1, s2;     /* scrollbar width, height and some temp variables */
} ui_t;

/* public API */
int ui_fonthook(ui_t *ctx, ui_font_bbox bbox, ui_font_draw draw);
int ui_font(ui_t *ctx, void *fnt);
int ui_swcursor(ui_t *ctx, ui_image_t *cursor);
int ui_hwcursor(ui_t *ctx);
int ui_theme(ui_t *ctx, uint32_t *theme);
int ui_skin(ui_t *ctx, ui_image_t *skin);
int ui_pngskin(ui_t *ctx, uint8_t *png, int size);
int ui_refresh(ui_t *ctx);
int ui_settxt(ui_t *ctx, char **txtv);
char *ui_getclipboard(ui_t *ctx);
int ui_setclipboard(ui_t *ctx, char *str);
int ui_getmouse(ui_t *ctx, int *x, int *y);
int ui_init(ui_t *ctx, int txtc, char **txtv, int w, int h, ui_image_t *icon);
int ui_fullscreen(ui_t *ctx);
void *ui_getwindow(ui_t *ctx);
ui_event_t *ui_event(ui_t *ctx, ui_form_t *form);
int ui_free(ui_t *ctx);

/* private API (for modules) */
void _ui_fit(int mw, int mh, int sw, int sh, int *w, int *h);
void _ui_rgb2hsv(uint32_t c, int *h, int *s, int *v);
uint32_t _ui_hsv2rgb(int a, int h, int s, int v);
void _ui_line(ui_t *ctx, int16_t x0, int16_t y0, int16_t x1, int16_t y1, uint32_t color);
void _ui_qbez(ui_t *ctx, int16_t x0, int16_t y0, int16_t x1, int16_t y1, int16_t cx, int16_t cy, uint32_t color);
void _ui_cbez(ui_t *ctx, int16_t x0, int16_t y0, int16_t x1, int16_t y1, int16_t cx0, int16_t cy0, int16_t cx1, int16_t cy1, uint32_t color);
void _ui_bmp16(ui_t *ctx, int x, int y, uint16_t *glyph, uint32_t color);
void _ui_tri(ui_t *ctx, int x, int y, int type, uint32_t l, uint32_t b, uint32_t d);
void _ui_rect(ui_t *ctx, int x, int y, int w, int h, uint32_t l, uint32_t c, uint32_t d);
void _ui_frect(ui_t *ctx, int x, int y, int w, int h, uint32_t color);
void _ui_checker(ui_t *ctx, int x, int y, int w, int h, uint32_t color);
void _ui_blit(ui_t *ctx, int x, int y, int w, int h, ui_image_t *img, int sx, int sy, int grscale);
void _ui_scaled(ui_t *ctx, int x, int y, int w, int h, ui_image_t *img, int grscale);
void _ui_copy(ui_image_t *dst, int x, int y, int w, int h, ui_image_t *src, int sx, int sy);
void _ui_blend(ui_image_t *dst, int x, int y, int w, int h, ui_image_t *src, int sx, int sy);
void _ui_boxbg(ui_t *ctx, int x, int y, int w, int h, int row, int col, int scr);
int _ui_font(ui_t *ctx, void *fnt, char *str, char *end, uint8_t *dst, uint32_t color, int x, int y, int l, int t, int p,
    int cx0, int cy0, int cx1, int cy1);
void _ui_checkbox(ui_t *ctx, int x, int y, int checked, int flags);
void _ui_radiobtn(ui_t *ctx, int x, int y, int checked, int flags);
void _ui_button(ui_t *ctx, int x, int y, int w, int h, int pressed, int flags, ui_image_t *icon, int label, int top);
void _ui_slider(ui_t *ctx, int x, int y, int w, int h, int cur, int max, int flags);
void _ui_pbar(ui_t *ctx, int x, int y, int w, int h, int64_t cur, int64_t max, int flags);
int _ui_scr(int s, int cur, int max, int bmin, int *b);
void _ui_vscrbar(ui_t *ctx, int x, int y, int h, int cur, int max, int pressed);
void _ui_hscrbar(ui_t *ctx, int x, int y, int w, int cur, int max, int pressed);
void _ui_text(ui_t *ctx, int x, int y, int w, int h, int l, int t, int flags, int edit, char *str, char *end);
void _ui_header(ui_t *ctx, int x, int y, int w, int h, int pressed, int align, int tri, char *str);
void _ui_option(ui_t *ctx, int x, int y, int w, int h, int l, int t, int flags, int pressed, int right, int m, char *str);
void _ui_select(ui_t *ctx, int x, int y, int w, int h, int l, int t, int flags, int pressed, int m, char *str);
void _ui_color(ui_t *ctx, int x, int y, int w, int h, int l, int t, int flags, uint32_t color);
int _ui_popup(ui_t *ctx, int x, int y, ui_form_t *form);
int _ui_recalc(ui_t *ctx, int x, int y, int w, int h, int p, ui_form_t *form, int *ow, int *oh);
int _ui_draw(ui_t *ctx, int x, int y, int w, int h, int ox, int oy, ui_form_t *form, int parent);
int _ui_redraw(ui_t *ctx, ui_form_t *form);
int _ui_setmouse(ui_t *ctx, int x, int y);
ui_event_t *_ui_evtslot(ui_t *ctx);
int _ui_resize(ui_t *ctx, int w, int h);
int _ui_evtproc(ui_t *ctx, int x, int y, int w, int h, ui_form_t *form, int parent, ui_event_t *evt);
int _ui_select_ctrl(ui_t *ctx, int x, int y, int w, int h, ui_form_t *form, ui_event_t *evt);
void _ui_select_start(ui_t *ctx, int x, int y, int w, int h, ui_form_t *form);
void _ui_text_start(ui_t *ctx, int x, int y, int w, int h, ui_form_t *form, char *str, int maxlen);
void _ui_text_add(ui_t *ctx, char *k, int i);
void _ui_text_ctrl(ui_t *ctx, ui_event_t *evt);
int _ui_color_ctrl(ui_t *ctx, int x, int y, int w, int h, ui_form_t *form, ui_event_t *evt);
void _ui_color_start(ui_t *ctx, int x, int y, int w, int h, ui_form_t *form);

#ifdef  __cplusplus
}
#endif

#endif /* UI_OK */
#ifdef UI_IMPLEMENTATION

#ifndef UI_NOAA
#include <math.h>
#endif

#ifndef UI_BACKEND
#include <ui_glfw.h>
#endif
#ifndef UI_FONT
#define UI_DEFAULTFONT
#include <ui_psf2.h>
#endif

/* PRId64 is a mess and doesn't work, since it comes from inttypes.h, however it is actually compiler and libc dependent.
 * On Windows, MSVC and mingw might expect different prefix, but might end up using the same header file...
 * So allow the user to define L to overcome these weird situations. */
#ifndef L
#ifdef __WIN32__
#define L "I64"
#else
#if (defined(__BITS_PER_LONG) && __BITS_PER_LONG == 32) || (defined(__SIZEOF_LONG__) && __SIZEOF_LONG__ == 4)
#define L "ll"
#else
#define L "l"
#endif
#endif
#endif

#ifndef UI_TEXT
#define UI_TEXT UI_TXTINP
#endif

#ifdef  __cplusplus
extern "C" {
#endif

/**
 * The default theme
 */
static const uint32_t ui_default[UI_NUMTHEME] = {
    0xffa0a0a0 /*fg*/, 0xff707070 /*tit*/, 0xff3f3f3f /*bg*/, 0x3f000000 /*sh*/, 0xffffffff /*tfg*/, 0xff3f3f3f /*tbg*/,
    0xffffffff /*hlfg*/, 0xff7f7f7f /*hlbg*/, 0xff2f2f2f /*dfg*/, 0xff373737 /*dbg*/, 0xff101010 /*sbg*/,
    0xffc0c0c0 /*ifg*/, 0xff5f5f5f /*il*/, 0xff2f2f2f /*id*/, 0xff1f1f1f /*ibg*/, 0xffffffff /*icf*/, 0xffffffff /*ib*/, 0xffffffff /*ic*/,
    0xff000000 /*bfg*/, 0xff5f5f5f /*sbl*/, 0xff373737 /*sbd*/, 0xff101010 /*bn*/,
    0xff000000 /*sfg*/, 0xff5f5f5f /*ssl*/, 0xff373737 /*ssd*/, 0xff001010 /*bs*/,
    0xff5f5f5f /*bl*/, 0xff1f1f1f /*bd*/, 0xff474747 /*bgl*/, 0xff373737 /*bgd*/,
    0xffaf0000 /*pl*/, 0xff7f0000 /*pb*/, 0xff5f0000 /*pd*/ };

/**
 * Recalculate size (sw, sh) to fit into (mw, mh) keeping aspect ratio
 */
void _ui_fit(int mw, int mh, int sw, int sh, int *w, int *h)
{
    if(!w || !h) return;
    if(mw < 1 || mh < 1 || sw < 1 || sh < 1) { *w = *h = 0; return; }
    *w = mw; *h = sh * mw / sw;
    if(*h > mh) { *h = mh; *w = sw * mh / sh; }
    if(*w < 1) *w = 1;
    if(*h < 1) *h = 1;
}

/**
 * Color conversion sRGB to HSV
 */
void _ui_rgb2hsv(uint32_t c, int *h, int *s, int *v)
{
    int r = (int)(((uint8_t*)&c)[2]), g = (int)(((uint8_t*)&c)[1]), b = (int)(((uint8_t*)&c)[0]), m, d;

    m = r < g? r : g; if(b < m) m = b;
    *v = r > g? r : g; if(b > *v) *v = b;
    d = *v - m; *h = 0;
    if(!*v) { *s = 0; return; }
    *s = d * 255 / *v;
    if(!*s) return;

    if(r == *v) *h = 43*(g - b) / d;
    else if(g == *v) *h = 85 + 43*(b - r) / d;
    else *h = 171 + 43*(r - g) / d;
    if(*h < 0) *h += 256;
}

/**
 * Color conversion HSV to sRGB
 */
uint32_t _ui_hsv2rgb(int a, int h, int s, int v)
{
    int i, f, p, q, t;
    uint32_t c = (a & 255) << 24;

    if(!s) { ((uint8_t*)&c)[2] = ((uint8_t*)&c)[1] = ((uint8_t*)&c)[0] = v; }
    else {
        if(h > 255) i = 0; else i = h / 43;
        f = (h - i * 43) * 6;
        p = (v * (255 - s) + 127) >> 8;
        q = (v * (255 - ((s * f + 127) >> 8)) + 127) >> 8;
        t = (v * (255 - ((s * (255 - f) + 127) >> 8)) + 127) >> 8;
        switch(i) {
            case 0:  ((uint8_t*)&c)[2] = v; ((uint8_t*)&c)[1] = t; ((uint8_t*)&c)[0] = p; break;
            case 1:  ((uint8_t*)&c)[2] = q; ((uint8_t*)&c)[1] = v; ((uint8_t*)&c)[0] = p; break;
            case 2:  ((uint8_t*)&c)[2] = p; ((uint8_t*)&c)[1] = v; ((uint8_t*)&c)[0] = t; break;
            case 3:  ((uint8_t*)&c)[2] = p; ((uint8_t*)&c)[1] = q; ((uint8_t*)&c)[0] = v; break;
            case 4:  ((uint8_t*)&c)[2] = t; ((uint8_t*)&c)[1] = p; ((uint8_t*)&c)[0] = v; break;
            default: ((uint8_t*)&c)[2] = v; ((uint8_t*)&c)[1] = p; ((uint8_t*)&c)[0] = q; break;
        }
    }
    return c;
}

/**
 * Draw a line
 */
void _ui_line(ui_t *ctx, int16_t x0, int16_t y0, int16_t x1, int16_t y1, uint32_t color)
{
#ifdef UI_NOAA
    int dx =  abs(x1-x0), sx = x0<x1 ? 1 : -1;
    int dy = -abs(y1-y0), sy = y0<y1 ? 1 : -1;
    int err = dx+dy, e2, p;
    uint8_t *a, *b = (uint8_t*)&color;
    uint32_t *d, b0, b1, b2, b3, c;

    if(!ctx || !ctx->screen.buf || !b[3] || (x0 == x1 && y0 == y1)) return;
    d = (uint32_t*)ctx->screen.buf; p = ctx->screen.p / 4;

    b0 = b[0]*b[3]; b1 = b[1]*b[3]; b2 = b[2]*b[3]; b3 = b[3]*b[3]; c = 255 - b[3];
    for (;;){
        if(x0 >= ctx->cx0 && x0 < ctx->cx1 && y0 >= ctx->cy0 && y0 < ctx->cy1) {
            a = (uint8_t*)&d[y0 * p + x0];
            a[3] = (b3 + c*a[3]) >> 8;
            a[2] = (b2 + c*a[2]) >> 8;
            a[1] = (b1 + c*a[1]) >> 8;
            a[0] = (b0 + c*a[0]) >> 8;
        }
        e2 = 2*err;
        if (e2 >= dy) { if (x0 == x1) { break; } err += dy; x0 += sx; }
        if (e2 <= dx) { if (y0 == y1) { break; } err += dx; y0 += sy; }
    }
#else
    uint8_t *b = (uint8_t*)&color, *e;
    uint32_t *d, c;
    int sx = x0 < x1 ? 1 : -1, sy = y0 < y1 ? 1 : -1, x2, a, i, p;
    int dx = abs(x1-x0), dy = abs(y1-y0), err = dx*dx+dy*dy;
    int e2 = err == 0 ? 1 : 0xffff7fl/sqrt(err);

    if(!ctx || !ctx->screen.buf || !b[3] || (x0 == x1 && y0 == y1)) return;
    d = (uint32_t*)ctx->screen.buf; p = ctx->screen.p / 4;

    dx *= e2; dy *= e2; err = dx-dy;
    while(1) {
        if(x0 >= ctx->cx0 && x0 < ctx->cx1 && y0 >= ctx->cy0 && y0 < ctx->cy1) {
            a = err-dx+dy; if(a < 0) a = -a;
            a = 255 - (a >> 16); a = a * b[3] / 255; c = 255 - a;
            e = (uint8_t*)&d[y0 * p + x0];
            e[3] = (b[3]*a + c*e[3]) >> 8;
            e[2] = (b[2]*a + c*e[2]) >> 8;
            e[1] = (b[1]*a + c*e[1]) >> 8;
            e[0] = (b[0]*a + c*e[0]) >> 8;
        }
        e2 = err; x2 = x0;
        if(2*e2 >= -dx) {
            if(x0 == x1) break;
            i = y0 + sy;
            if(e2+dy < 0xff0000l && x0 >= ctx->cx0 && x0 < ctx->cx1 && i >= ctx->cy0 && i < ctx->cy1) {
                a = 255 - ((e2+dy) >> 16); a = a * b[3] / 255; c = 255 - a;
                e = (uint8_t*)&d[i * p + x0];
                e[3] = (b[3]*a + c*e[3]) >> 8;
                e[2] = (b[2]*a + c*e[2]) >> 8;
                e[1] = (b[1]*a + c*e[1]) >> 8;
                e[0] = (b[0]*a + c*e[0]) >> 8;
            }
            err -= dy; x0 += sx;
        }
        if(2*e2 <= dy) {
            if(y0 == y1) break;
            i = x2 + sx;
            if(dx-e2 < 0xff0000l && i >= ctx->cx0 && i < ctx->cx1 && y0 >= ctx->cy0 && y0 < ctx->cy1) {
                a = 255 - ((dx-e2) >> 16); a = a * b[3] / 255; c = 255 - a;
                e = (uint8_t*)&d[y0 * p + i];
                e[3] = (b[3]*a + c*e[3]) >> 8;
                e[2] = (b[2]*a + c*e[2]) >> 8;
                e[1] = (b[1]*a + c*e[1]) >> 8;
                e[0] = (b[0]*a + c*e[0]) >> 8;
            }
            err += dx; y0 += sy;
        }
    }
#endif
}

/**
 * Recursively calculate Bezier curve
 */
static void __ui_b(ui_t *ctx, uint32_t color, int x0,int y0, int x1,int y1, int x2,int y2, int x3,int y3, int l)
{
    int m0x, m0y, m1x, m1y, m2x, m2y, m3x, m3y, m4x, m4y,m5x, m5y;
    if(l < 8 && (x0 != x3 || y0 != y3)) {
        m0x = ((x1-x0)/2) + x0;     m0y = ((y1-y0)/2) + y0;
        m1x = ((x2-x1)/2) + x1;     m1y = ((y2-y1)/2) + y1;
        m2x = ((x3-x2)/2) + x2;     m2y = ((y3-y2)/2) + y2;
        m3x = ((m1x-m0x)/2) + m0x;  m3y = ((m1y-m0y)/2) + m0y;
        m4x = ((m2x-m1x)/2) + m1x;  m4y = ((m2y-m1y)/2) + m1y;
        m5x = ((m4x-m3x)/2) + m3x;  m5y = ((m4y-m3y)/2) + m3y;
        __ui_b(ctx, color, x0,y0, m0x,m0y, m3x,m3y, m5x,m5y, l + 1);
        __ui_b(ctx, color, m5x,m5y, m4x,m4y, m2x,m2y, x3,y3, l + 1);
    }
    if(l) {
        _ui_line(ctx, ctx->bx >> 8, ctx->by >> 8, x3 >> 8, y3 >> 8, color);
        ctx->bx = x3; ctx->by = y3;
    }
}

/**
 * Draws a quadratic Bezier curve
 */
void _ui_qbez(ui_t *ctx, int16_t x0, int16_t y0, int16_t x1, int16_t y1,
    int16_t cx, int16_t cy, uint32_t color)
{
    if(!ctx || !ctx->screen.buf || !(color & 0xff000000)) return;
    ctx->bx = x0 << 8; ctx->by = y0 << 8;
    __ui_b(ctx, color, x0 << 8, y0 << 8, (x0 << 8) + (((cx << 8) - (x0 << 8)) >> 1), (y0 << 8) + (((cy << 8) - (y0 << 8)) >> 1),
        (cx << 8) + (((x1 << 8) - (cx << 8)) >> 1), (cy << 8) + (((y1 << 8) - (cy << 8)) >> 1), (x1 << 8), (y1 << 8), 0);
}

/**
 * Draws a cubic Bezier curve
 */
void _ui_cbez(ui_t *ctx, int16_t x0, int16_t y0, int16_t x1, int16_t y1,
    int16_t cx0, int16_t cy0, int16_t cx1, int16_t cy1, uint32_t color)
{
    if(!ctx || !ctx->screen.buf || !(color & 0xff000000)) return;
    ctx->bx = x0 << 8; ctx->by = y0 << 8;
    __ui_b(ctx, color, x0 << 8, y0 << 8, cx0 << 8, cy0 << 8, cx1 << 8, cy1 << 8, x1 << 8, y1 << 8, 0);
}

/**
 * Draw a 16 x 16 pixel bitmap icon
 */
void _ui_bmp16(ui_t *ctx, int x, int y, uint16_t *glyph, uint32_t color)
{
    uint8_t *dst;
    int i = 0, j = 0, k = x + 16, l = 16, m, n;

    if(!ctx || !ctx->screen.buf || !glyph || !color || y >= ctx->cy1 || y + 16 < ctx->cy0 || x >= ctx->cx1 || k < ctx->cx0) return;
    if(y < ctx->cy0) { i = ctx->cy0 - y; glyph += i; l -= i; y = ctx->cy0; }
    if(x < ctx->cx0) { j = ctx->cx0 - x; k -= i; x = ctx->cx0; }
    for(i = 0; i < l && y + i < ctx->cy1; i++, glyph++) {
        dst = ctx->screen.buf + (y + i) * ctx->screen.p + x * 4;
        for(m = (1 << j), n = j; m < 0x10000 && x + n < k; m <<= 1, dst += 4, n++)
            if(*glyph & m) *((uint32_t*)dst) = color;
    }
}

/**
 * Draw a small, up or down or left or right triangle with shadowed border
 */
void _ui_tri(ui_t *ctx, int x, int y, int type, uint32_t l, uint32_t b, uint32_t d)
{
    int i, j, p;
    uint32_t *data;

    if(!ctx || x < ctx->cx0 || y < ctx->cy0 || x + 7 >= ctx->cx1 || y + 7 >= ctx->cy1) return;
    data = (uint32_t*)ctx->screen.buf; p = ctx->screen.p / 4;

    j = p * y + x;
    switch(type) {
        case 1:
            /* up */
            data[j+3] = b; j += p;
            data[j+2] = d; data[j+3] = b; data[j+4] = l; j += p;
            data[j+1] = d; data[j+2] = data[j+3] = data[j+4] = b; data[j+5] = l; j += p;
            data[j] = d; data[j+1] = data[j+2] = data[j+3] = data[j+4] = data[j+5] = b; data[j+6] = l; j += p;
            for(i = 0; i < 7; i++)
                data[j + i] = l;
        break;
        case 2:
            /* left */
            data[j+3] = d; data[j+4] = b; j += p;
            data[j+2] = d; data[j+3] = b; data[j+4] = l; j += p;
            data[j+1] = d; data[j+2] = data[j+3] = b; data[j+4] = l; j += p;
            data[j] = d; data[j+1] = data[j+2] = data[j+3] = b; data[j+4] = l; j += p;
            data[j+1] = b; data[j+2] = data[j+3] = b; data[j+4] = l; j += p;
            data[j+2] = b; data[j+3] = b; data[j+4] = l; j += p;
            data[j+3] = b; data[j+4] = l; j += p;
        break;
        case 3:
            /* right */
            data[j] = b; data[j+1] = d; j += p;
            data[j] = b; data[j+1] = b; data[j+2] = d; j += p;
            data[j] = b; data[j+1] = data[j+2] = b; data[j+3] = d; j += p;
            data[j] = b; data[j+1] = data[j+2] = data[j+3] = b; data[j+4] = l; j += p;
            data[j] = b; data[j+1] = data[j+2] = b; data[j+3] = l; j += p;
            data[j] = b; data[j+1] = b; data[j+2] = l; j += p;
            data[j] = b; data[j+1] = l; j += p;
        break;
        case 4:
            /* right - down */
            j += 2 * p;
            data[j+6] = l; j += p;
            data[j+5] = data[j+6] = l; j += p;
            data[j+4] = data[j+5] = data[j+6] = l; j += p;
            data[j+3] = data[j+4] = data[j+5] = data[j+6] = l; j += p;
            data[j+2] = data[j+3] = data[j+4] = data[j+5] = data[j+6] = l; j += p;
        break;
        default:
            /* down */
            for(i = 0; i < 7; i++)
                data[j + i] = d;
            j += p;
            data[j] = d; data[j+1] = data[j+2] = data[j+3] = data[j+4] = data[j+5] = b; data[j+6] = l; j += p;
            data[j+1] = d; data[j+2] = data[j+3] = data[j+4] = b; data[j+5] = l; j += p;
            data[j+2] = d; data[j+3] = b; data[j+4] = l; j += p;
            data[j+3] = l;
        break;
    }
}

/**
 * Draw a rectangle
 */
void _ui_rect(ui_t *ctx, int x, int y, int w, int h, uint32_t l, uint32_t c, uint32_t d)
{
    int i, j, p, p2, pitch;
    uint8_t *a, *b;
    uint32_t *data, l0, l1, l2, l3, lc, d0, d1, d2, d3, dc, cc;

    if(!ctx || !ctx->screen.buf || x >= ctx->cx1 || x + w < ctx->cx0 || y >= ctx->cy1 || y + h < ctx->cy0 || w < 2 || h < 2)
        return;

    b = (uint8_t*)&l; l0 = b[0]*b[3]; l1 = b[1]*b[3]; l2 = b[2]*b[3]; l3 = b[3]*b[3]; lc = 255 - b[3];
    b = (uint8_t*)&d; d0 = b[0]*b[3]; d1 = b[1]*b[3]; d2 = b[2]*b[3]; d3 = b[3]*b[3]; dc = 255 - b[3];
    data = (uint32_t*)ctx->screen.buf; pitch = ctx->screen.p / 4;
    p = y * pitch + x;
    p2 = (y + h - 1) * pitch + x;
    for(i=!c; i + 1 < w && x + i + 1 < ctx->cx1; i++) {
        if(y >= ctx->cy0 && x + i >= ctx->cx0) {
            a = (uint8_t*)&data[p + i];
            a[3] = (l3 + lc*a[3]) >> 8;
            a[2] = (l2 + lc*a[2]) >> 8;
            a[1] = (l1 + lc*a[1]) >> 8;
            a[0] = (l0 + lc*a[0]) >> 8;
        }
        if(y + h - 1 >= ctx->cy0 && y + h - 1 < ctx->cy1 && x + i >= ctx->cx0) {
            a = (uint8_t*)&data[p2 + i + 1 - !c];
            a[3] = (d3 + dc*a[3]) >> 8;
            a[2] = (d2 + dc*a[2]) >> 8;
            a[1] = (d1 + dc*a[1]) >> 8;
            a[0] = (d0 + dc*a[0]) >> 8;
        }
    }
    if(c) {
        b = (uint8_t*)&c; cc = 255 - b[3];
        if(y >= ctx->cy0 && x + i >= ctx->cx0) {
            a = (uint8_t*)&data[p + i];
            a[3] = (b[3]*b[3] + cc*a[3]) >> 8;
            a[2] = (b[2]*b[3] + cc*a[2]) >> 8;
            a[1] = (b[1]*b[3] + cc*a[1]) >> 8;
            a[0] = (b[0]*b[3] + cc*a[0]) >> 8;
        }
        if(y + h - 1 >= ctx->cy0 && y + h - 1 < ctx->cy1 && x >= ctx->cx0) {
            a = (uint8_t*)&data[p2];
            a[3] = (b[3]*b[3] + cc*a[3]) >> 8;
            a[2] = (b[2]*b[3] + cc*a[2]) >> 8;
            a[1] = (b[1]*b[3] + cc*a[1]) >> 8;
            a[0] = (b[0]*b[3] + cc*a[0]) >> 8;
        }
    }
    p += pitch;
    for(j=1; j + 1 < h && y + j < ctx->cy1; j++, p += pitch)
        if(y + j >= ctx->cy0) {
            if(x >= ctx->cx0) {
                a = (uint8_t*)&data[p];
                a[3] = (l3 + lc*a[3]) >> 8;
                a[2] = (l2 + lc*a[2]) >> 8;
                a[1] = (l1 + lc*a[1]) >> 8;
                a[0] = (l0 + lc*a[0]) >> 8;
            }
            if(x + w - 1 < ctx->cx1) {
                a = (uint8_t*)&data[p + w - 1];
                a[3] = (d3 + dc*a[3]) >> 8;
                a[2] = (d2 + dc*a[2]) >> 8;
                a[1] = (d1 + dc*a[1]) >> 8;
                a[0] = (d0 + dc*a[0]) >> 8;
            }
        }
}

/**
 * Draw a filled rectangle
 */
void _ui_frect(ui_t *ctx, int x, int y, int w, int h, uint32_t color)
{
    int i, j, p;
    uint8_t *d, *a, *b = (uint8_t*)&color;
    uint32_t b0, b1, b2, b3, c;

    if(!ctx || !ctx->screen.buf || !b[3]) return;
    d = ctx->screen.buf; p = ctx->screen.p;

    if(x < ctx->cx0) { w -= ctx->cx0 - x; x = ctx->cx0; }
    if(y < ctx->cy0) { h -= ctx->cy0 - y; y = ctx->cy0; }
    if(x + w > ctx->cx1) w = ctx->cx1 - x;
    if(y + h > ctx->cy1) h = ctx->cy1 - y;
    if(x >= ctx->cx1 || y >= ctx->cy1 || w < 1 || h < 1) return;

    b0 = b[0]*b[3]; b1 = b[1]*b[3]; b2 = b[2]*b[3]; b3 = b[3]*b[3]; c = 255 - b[3];
    d += p * y + x * 4;
    for(j = 0; j < h; j++, d += p) {
        for(i = 0, a = d; i < w; i++, a += 4) {
            a[3] = (b3 + c*a[3]) >> 8;
            a[2] = (b2 + c*a[2]) >> 8;
            a[1] = (b1 + c*a[1]) >> 8;
            a[0] = (b0 + c*a[0]) >> 8;
        }
    }
}

/**
 * Draw a filled rectangle with checker background (for opaque colors, same as ui_frect)
 */
void _ui_checker(ui_t *ctx, int x, int y, int w, int h, uint32_t color)
{
    int i, j, k, p;
    uint8_t *d, *a, *b = (uint8_t*)&color;
    uint32_t b0, b1, b2, c, e;

    if(!ctx || !ctx->screen.buf) return;
    d = ctx->screen.buf; p = ctx->screen.p;
    k = (w < h ? w : h) / 2; if(k < 1) k = 1;

    if(x < ctx->cx0) { w -= ctx->cx0 - x; x = ctx->cx0; }
    if(y < ctx->cy0) { h -= ctx->cy0 - y; y = ctx->cy0; }
    if(x + w > ctx->cx1) w = ctx->cx1 - x;
    if(y + h > ctx->cy1) h = ctx->cy1 - y;
    if(x >= ctx->cx1 || y >= ctx->cy1 || w < 1 || h < 1) return;

    b0 = b[0]*b[3]; b1 = b[1]*b[3]; b2 = b[2]*b[3]; c = 255 - b[3];
    d += p * y + x * 4;
    for(j = 0; j < h; j++, d += p) {
        for(i = 0, a = d; i < w; i++, a += 4) {
            e = c * (((j / k) & 1) ^ ((i / k) & 1) ? 0x9f : 0x5f);
            a[3] = 255;
            a[2] = (b2 + e) >> 8;
            a[1] = (b1 + e) >> 8;
            a[0] = (b0 + e) >> 8;
        }
    }
}

/**
 * Blit a pixel buffer to the screen
 */
void _ui_blit(ui_t *ctx, int x, int y, int w, int h, ui_image_t *img, int sx, int sy, int grscale)
{
    int i, j, p, sp, sw, sh;
    uint8_t *s, *d, *a, *b;
    register uint32_t c, P;

    if(!ctx || !ctx->screen.buf || !img || !img->buf) return;
    d = ctx->screen.buf; p = ctx->screen.p;
    s = img->buf; sw = img->w; sh = img->h; sp = img->p;

    if(x < ctx->cx0) { w -= ctx->cx0 - x; sx += ctx->cx0 - x; x = ctx->cx0; }
    if(y < ctx->cy0) { h -= ctx->cy0 - y; sy += ctx->cy0 - y; y = ctx->cy0; }
    if(x + w > ctx->cx1) w = ctx->cx1 - x;
    if(y + h > ctx->cy1) h = ctx->cy1 - y;
    if(x >= ctx->cx1 || y >= ctx->cy1 || w < 1 || h < 1) return;
    d += p * y + x * 4;

    for(j = 0; j < h; j++, d += p) {
        for(i = 0, a = d; i < w; i++, a += 4) {
            b = s + ((sy + j) % sh) * sp + ((sx + i) % sw) * 4;
            if(b[3]) {
                if(grscale > 0) {
                    c = 255 - b[3];
                    P = ((b[2] + b[1] + b[0]) >> 3)*b[3];
                    a[3] = (b[3]*b[3] + c*a[3]) >> 8;
                    a[2] = (P + c*a[2]) >> 8;
                    a[1] = (P + c*a[1]) >> 8;
                    a[0] = (P + c*a[0]) >> 8;
                } else {
                    c = 255 - b[3];
                    a[3] = (b[3]*b[3] + c*a[3]) >> 8;
                    a[2] = (b[2]*b[3] + c*a[2]) >> 8;
                    a[1] = (b[1]*b[3] + c*a[1]) >> 8;
                    a[0] = (b[0]*b[3] + c*a[0]) >> 8;
                }
            }
        }
    }
}

/**
 * Blit a scaled pixel buffer to the screen
 */
#define UI_SCALEMAX 4096
void _ui_scaled(ui_t *ctx, int x, int y, int w, int h, ui_image_t *img, int grscale)
{
    static int sax[UI_SCALEMAX + 1], say[UI_SCALEMAX + 1];
    uint8_t b[4], *dp;
    uint32_t *c00, *c01, *c10, *c11, *csp, *ep;
    int o, p, sx, sy, sp, sw, sh, dw, dh, *csax, *csay, csx, csy, ex, ey, t1, t2, sstep, lx, ly, X, Y;
    register uint32_t c, P;

    if(!ctx || !ctx->screen.buf || !img || !img->buf || !img->w || !img->h) return;
    sw = img->w; sh = img->h;
    dw = w; dh = sh * w / sw;
    if(dh > h) { dh = h; dw = sw * h / sh; }
    x += (w - dw) / 2; w = dw;
    y += (h - dh) / 2; h = dh;
    if(x >= ctx->cx1 || y >= ctx->cy1 || w < 2 || h < 2 || w >= UI_SCALEMAX || h >= UI_SCALEMAX) return;

    sx = (int) (65536.0 * (float)sw / (float)w);
    sy = (int) (65536.0 * (float)sh / (float)h);
    sp = img->p / 4; p = ctx->screen.p;
    csp = (uint32_t*)img->buf; ep = (uint32_t*)img->buf + sp * sh - 1;
    csx = 0; csax = sax; for(o = 0; o <= w; o++) { *csax = csx; csax++; csx &= 0xffff; csx += sx; }
    csy = 0; csay = say; for(o = 0; o <= h; o++) { *csay = csy; csay++; csy &= 0xffff; csy += sy; }
    if(x + w > ctx->cx1) w = ctx->cx1 - x;
    if(y + h > ctx->cy1) h = ctx->cy1 - y;
    if(w < 2 || h < 2 || x + w < ctx->cx0 || y + h < ctx->cy0) return;
    o = y * p + x * 4;
    csay = say; ly = 0;
    for(; y < ctx->cy0; y++) {
        c00 = csp; c01 = csp; c01++; c10 = csp; c10 += sp; c11 = c10; c11++;
        csay++;
        if(*csay > 0) { sstep = (*csay >> 16); ly += sstep; if(ly < sh) csp += (sstep * sp); }
        o += p;
    }
    dp = ctx->screen.buf + o;
    for(Y = 0; Y < h - 1; Y++) {
        c00 = csp; c01 = csp; c01++; c10 = csp; c10 += sp; c11 = c10; c11++;
        csax = sax; lx = 0;
        for(X = x; X < ctx->cx0; X++) {
            dp += 4; csax++;
            if(*csax > 0) {
                sstep = (*csax >> 16); lx += sstep;
                if(lx < sw) { c00 += sstep; c01 += sstep; c10 += sstep; c11 += sstep; }
            }
        }
        for(X = 0; X < w - 1; X++) {
            if(c00 > ep) c00 = ep;
            if(c01 > ep) c01 = ep;
            if(c10 > ep) c10 = ep;
            if(c11 > ep) c11 = ep;
            ex = (*csax & 0xffff); ey = (*csay & 0xffff);
            t1 = (((((*c01 >> 24) - (*c00 >> 24)) * ex) >> 16) + (*c00 >> 24)) & 0xff;
            t2 = (((((*c11 >> 24) - (*c10 >> 24)) * ex) >> 16) + (*c10 >> 24)) & 0xff;
            b[3] = ((((t2 - t1) * ey) >> 16) + t1); if(b[3] == 254) b[3] = 255;
            t1 = (((((*c01 & 0xff) - (*c00 & 0xff)) * ex) >> 16) + (*c00 & 0xff)) & 0xff;
            t2 = (((((*c11 & 0xff) - (*c10 & 0xff)) * ex) >> 16) + (*c10 & 0xff)) & 0xff;
            b[0] = ((((t2 - t1) * ey) >> 16) + t1);
            t1 = ((((((*c01 >> 8) & 0xff) - ((*c00 >> 8) & 0xff)) * ex) >> 16) + ((*c00 >> 8) & 0xff)) & 0xff;
            t2 = ((((((*c11 >> 8) & 0xff) - ((*c10 >> 8) & 0xff)) * ex) >> 16) + ((*c10 >> 8) & 0xff)) & 0xff;
            b[1] = ((((t2 - t1) * ey) >> 16) + t1);
            t1 = ((((((*c01 >> 16) & 0xff) - ((*c00 >> 16) & 0xff)) * ex) >> 16) + ((*c00 >> 16) & 0xff)) & 0xff;
            t2 = ((((((*c11 >> 16) & 0xff) - ((*c10 >> 16) & 0xff)) * ex) >> 16) + ((*c10 >> 16) & 0xff)) & 0xff;
            b[2] = ((((t2 - t1) * ey) >> 16) + t1);
            if(b[3]) {
                if(grscale > 0) {
                    c = 255 - b[3];
                    P = ((b[2] + b[1] + b[0]) >> 3)*b[3];
                    dp[3] = (b[3]*b[3] + c*dp[3]) >> 8;
                    dp[2] = (P + c*dp[2]) >> 8;
                    dp[1] = (P + c*dp[1]) >> 8;
                    dp[0] = (P + c*dp[0]) >> 8;
                } else {
                    c = 255 - b[3];
                    dp[3] = (b[3]*b[3] + c*dp[3]) >> 8;
                    dp[2] = (b[2]*b[3] + c*dp[2]) >> 8;
                    dp[1] = (b[1]*b[3] + c*dp[1]) >> 8;
                    dp[0] = (b[0]*b[3] + c*dp[0]) >> 8;
                }
            }
            dp += 4; csax++;
            if(*csax > 0) {
                sstep = (*csax >> 16); lx += sstep;
                if(lx < sw) { c00 += sstep; c01 += sstep; c10 += sstep; c11 += sstep; }
            }
        }
        csay++;
        if(*csay > 0) { sstep = (*csay >> 16); ly += sstep; if(ly < sh) csp += (sstep * sp); }
        o += p;
        dp = ctx->screen.buf + o;
    }
}

/**
 * Copy a pixel buffer to another
 */
void _ui_copy(ui_image_t *dst, int x, int y, int w, int h, ui_image_t *src, int sx, int sy)
{
    int n, j;
    uint8_t *s, *d;

    if(!src || !src->buf || !dst || !dst->buf) return;

    if(x < 0) { w += x; sx -= x; x = 0; }
    if(y < 0) { h += y; sy -= y; y = 0; }
    if(x + w > dst->w) w = dst->w - x;
    if(y + h > dst->h) h = dst->h - y;
    if(sx < 0) { w += sx; x -= sx; sx = 0; }
    if(sy < 0) { h += sy; y -= sy; sy = 0; }
    if(sx + w > src->w) w = src->w - sx;
    if(sy + h > src->h) h = src->h - sy;
    if(x >= dst->w || y >= dst->h || sx >= src->w || sy >= src->h || w < 1 || h < 1) return;

    s = src->buf + src->p * sy + sx * 4;
    d = dst->buf + dst->p * y + x * 4;
    n = w * 4;
    for(j = 0; j < h; j++, d += dst->p, s += src->p)
        memcpy(d, s, n);
}

/**
 * Copy a pixel buffer to another with alpha blending
 */
void _ui_blend(ui_image_t *dst, int x, int y, int w, int h, ui_image_t *src, int sx, int sy)
{
    int i, j;
    uint8_t *s, *d, *a, *b;
    register uint32_t c;

    if(!src || !src->buf || !dst || !dst->buf) return;

    if(x < 0) { w += x; sx -= x; x = 0; }
    if(y < 0) { h += y; sy -= y; y = 0; }
    if(x + w > dst->w) w = dst->w - x;
    if(y + h > dst->h) h = dst->h - y;
    if(sx < 0) { w += sx; x -= sx; sx = 0; }
    if(sy < 0) { h += sy; y -= sy; sy = 0; }
    if(sx + w > src->w) w = src->w - sx;
    if(sy + h > src->h) h = src->h - sy;
    if(x >= dst->w || y >= dst->h || sx >= src->w || sy >= src->h || w < 1 || h < 1) return;

    s = src->buf + src->p * sy + sx * 4;
    d = dst->buf + dst->p * y + x * 4;
    for(j = 0; j < h; j++, d += dst->p, s += src->p)
        for(i = 0, a = d, b = s; i < w; i++, a += 4, b += 4)
            if(b[3]) {
                c = 255 - b[3];
                a[3] = (b[3]*b[3] + c*a[3]) >> 8;
                a[2] = (b[2]*b[3] + c*a[2]) >> 8;
                a[1] = (b[1]*b[3] + c*a[1]) >> 8;
                a[0] = (b[0]*b[3] + c*a[0]) >> 8;
            }
}

/**
 * Draw an input background filled with altering boxes
 */
void _ui_boxbg(ui_t *ctx, int x, int y, int w, int h, int row, int col, int scr)
{
    int i, j, p, sp, sw, sh, sx = 0, sy = 0;
    uint8_t *s, *d, *a, *b;
    uint32_t b0[2], b1[2], b2[2], b3, c, g = 8;

    if(!ctx || !ctx->screen.buf) return;
    if(!row) row = h;
    if(!col) col = w;
    d = ctx->screen.buf; p = ctx->screen.p;

    if(x < ctx->cx0) { w -= ctx->cx0 - x; sx += ctx->cx0 - x; x = ctx->cx0; }
    if(y < ctx->cy0) { h -= ctx->cy0 - y; sy += ctx->cy0 - y; y = ctx->cy0; }
    if(x + w > ctx->cx1) w = ctx->cx1 - x;
    if(y + h > ctx->cy1) h = ctx->cy1 - y;
    if(x > ctx->cx1 || y > ctx->cy1 || w < 1 || h < 1) return;
    d += p * y + x * 4;

    if(ctx->skin[UI_INP].buf) {
        s = ctx->skin[UI_INP].buf; sw = ctx->skin[UI_INP].w; sh = ctx->skin[UI_INP].h; sp = ctx->skin[UI_INP].p;
        sy += scr;
        for(j = 0; j < h; j++, d += p)
            for(i = 0, a = d; i < w; i++, a += 4) {
                b = s + ((sy + j) % sh) * sp + ((sx + i) % sw) * 4;
                c = 255 - b[3];
                a[3] = (b[3]*b[3] + c*a[3]) >> 8;
                a[2] = (b[2]*b[3] + c*a[2]) >> 8;
                a[1] = (b[1]*b[3] + c*a[1]) >> 8;
                a[0] = (b[0]*b[3] + c*a[0]) >> 8;
                if((((j + scr) / row) & 1) ^ ((i / col) & 1)) {
                    if(a[2] > g) a[2] -= g; else a[2] = 0;
                    if(a[1] > g) a[1] -= g; else a[1] = 0;
                    if(a[0] > g) a[0] -= g; else a[0] = 0;
                }
            }
    } else {
        b = (uint8_t*)&ctx->theme[UI_IBG];
        b0[0] = b[0]*b[3]; b1[0] = b[1]*b[3]; b2[0] = b[2]*b[3]; b3 = b[3]*b[3]; c = 255 - b[3];
        b0[1] = b[0]>g?(b[0]-g)*b[3] : 0; b1[1] = b[1]>g?(b[1]-g)*b[3] : 0; b2[1] = b[2]>g?(b[2]-g)*b[3] : 0;
        for(j = 0; j < h; j++, d += p)
            for(i = 0, a = d; i < w; i++, a += 4) {
                g = (((j + scr) / row) & 1) ^ ((i / col) & 1);
                a[3] = (b3 + c*a[3]) >> 8;
                a[2] = (b2[g] + c*a[2]) >> 8;
                a[1] = (b1[g] + c*a[1]) >> 8;
                a[0] = (b0[g] + c*a[0]) >> 8;
            }
    }
}

/**
 * Draw string with font
 */
int _ui_font(ui_t *ctx, void *fnt, char *str, char *end, uint8_t *dst, uint32_t color, int x, int y, int l, int t, int p,
    int cx0, int cy0, int cx1, int cy1)
{
    if(!ctx || !ctx->draw || !fnt || !str || !dst) return 0;
    if(cx0 < ctx->cx0) cx0 = ctx->cx0;
    if(cx1 > ctx->cx1) cx1 = ctx->cx1;
    if(cy0 < ctx->cy0) cy0 = ctx->cy0;
    if(cy1 > ctx->cy1) cy1 = ctx->cy1;
    return (*ctx->draw)(fnt, str, end, dst, color, x, y, l, t, p, cx0, cy0, cx1, cy1);
}

/**
 * Draw checkbox (reused as non-skinned popup close icon)
 */
void _ui_checkbox(ui_t *ctx, int x, int y, int checked, int flags)
{
    ui_image_t *s;
    int p, id = UI_ID, il = UI_IL, ifg = UI_IFG, ibg = UI_IBG;
    uint32_t *buf;

    if(!ctx || !ctx->screen.buf || x - 5 < ctx->cx0 || y - 5 < ctx->cy0 || x + 4 >= ctx->cx1 || y + 4 >= ctx->cy1) return;

    if(checked == -2) { id = il = ibg = UI_TIT; ifg = UI_BG; }
    if(checked == -1) { id = il = ifg = UI_DFG; ibg = UI_DBG; }
    if(ctx->skin[UI_CHK0].buf && checked >= -1) {
        s = &ctx->skin[checked > 0 ? UI_CHK1 : UI_CHK0];
        _ui_blit(ctx, x - s->w / 2, y - s->h / 2, s->w, s->h, s, 0, 0, flags & UI_DISABLED ? 1 : 0);
    } else {
        _ui_rect(ctx, x - 5, y - 5, 9, 9, ctx->theme[id], ctx->theme[ibg], ctx->theme[il]);
        _ui_frect(ctx, x - 4, y - 4, 7, 7, ctx->theme[ibg]);
        if(checked) {
            buf = (uint32_t*)(ctx->screen.buf + (y - 3) * ctx->screen.p + (x - 3) * 4);
            p = ctx->screen.p / 4;
            buf[0] = buf[4] = ctx->theme[ifg]; buf += p;
            buf[1] = buf[3] = ctx->theme[ifg]; buf += p;
            buf[2] = ctx->theme[ifg]; buf += p;
            buf[1] = buf[3] = ctx->theme[ifg]; buf += p;
            buf[0] = buf[4] = ctx->theme[ifg];
        }
    }
}

/**
 * Draw radio button (reused as non-skinned slider button)
 */
void _ui_radiobtn(ui_t *ctx, int x, int y, int checked, int flags)
{
    ui_image_t *s;
    int p, id = UI_ID, il = UI_IL, ibg = UI_IBG, ifg = UI_IFG;
    uint32_t *buf, b;

    if(!ctx || !ctx->screen.buf || x - 5 < ctx->cx0 || y - 5 < ctx->cy0 || x + 4 >= ctx->cx1 || y + 4 >= ctx->cy1) return;

    if(checked == -3) id = il = ibg = ifg = UI_DFG;
    if(checked == -2) id = il = ibg = ifg = UI_IFG;
    if(checked == -1) { id = il = ifg = UI_DFG; ibg = UI_DBG; }
    if(ctx->skin[UI_RADIO0].buf && checked >= -1) {
        s = &ctx->skin[checked > 0 ? UI_RADIO1 : UI_RADIO0];
        _ui_blit(ctx, x - s->w / 2, y - s->h / 2, s->w, s->h, s, 0, 0, flags & UI_DISABLED ? 1 : 0);
    } else {
        buf = (uint32_t*)(ctx->screen.buf + (y - 5) * ctx->screen.p + (x - 5) * 4);
        p = ctx->screen.p / 4;
        b = ctx->theme[checked ? ifg : ibg];
        buf[2] = buf[3] = buf[4] = buf[5] = buf[6] = ctx->theme[id]; buf += p;
        buf[1] = buf[7] = ctx->theme[id];
        buf[2] = buf[3] = buf[4] = buf[5] = buf[6] = ctx->theme[ibg]; buf += p;
        buf[0] = ctx->theme[id]; buf[8] = ctx->theme[il]; buf[1] = buf[2] = buf[6] = buf[7] = ctx->theme[ibg];
        buf[3] = buf[4] = buf[5] = b; buf += p;
        buf[0] = ctx->theme[id]; buf[8] = ctx->theme[il]; buf[1] = buf[7] = ctx->theme[ibg];
        buf[2] = buf[3] = buf[4] = buf[5] = buf[6] = b; buf += p;
        buf[0] = ctx->theme[id]; buf[8] = ctx->theme[il]; buf[1] = buf[7] = ctx->theme[ibg];
        buf[2] = buf[3] = buf[4] = buf[5] = buf[6] = b; buf += p;
        buf[0] = ctx->theme[id]; buf[8] = ctx->theme[il]; buf[1] = buf[7] = ctx->theme[ibg];
        buf[2] = buf[3] = buf[4] = buf[5] = buf[6] = b; buf += p;
        buf[0] = ctx->theme[id]; buf[8] = ctx->theme[il]; buf[1] = buf[2] = buf[6] = buf[7] = ctx->theme[ibg];
        buf[3] = buf[4] = buf[5] = b; buf += p;
        buf[1] = buf[7] = ctx->theme[il];
        buf[2] = buf[3] = buf[4] = buf[5] = buf[6] = ctx->theme[ibg]; buf += p;
        buf[2] = buf[3] = buf[4] = buf[5] = buf[6] = ctx->theme[il]; buf += p;
    }
}

/**
 * Draw a button
 */
void _ui_button(ui_t *ctx, int x, int y, int w, int h, int pressed, int flags, ui_image_t *icon, int label, int top)
{
    ui_image_t *s;
    int H = h * 5 / 8, dw = 0, dh = 0, tx, ty, l = 0, t = 0;
    uint32_t c;

    if(!ctx || !ctx->screen.buf || x + w + 2 < ctx->cx0 || y + h + 2 < ctx->cy0 || x - 1 >= ctx->cx1 || y - 1 >= ctx->cy1) return;
    dh = ctx->ds;
    if(ctx->fnt && ctx->bbox && ctx->txtv && label > 0 && label < ctx->txtc) {
        (*ctx->bbox)(ctx->fnt, ctx->txtv[label], NULL, &dw, &dh, &l, &t);
        if(icon && icon->buf) dw += 4;
    }
    if(icon && icon->buf) dw += icon->w;
    tx = x + (w - dw) / 2;
    ty = y + (h - dh) / 2 + top;

    if(!(flags & UI_NOBORDER) && !ctx->skin[UI_BNM].buf) {
        c = ctx->theme[pressed == -1 || flags & UI_DISABLED ? UI_DFG : (pressed < 0 ? UI_BS : UI_BN)];
        _ui_rect(ctx, x - 1, y - 1, w + 2, h + 2, c, 0, c);
    }
    if(pressed > 0) ty++;
    s = &ctx->skin[pressed > 0 ? UI_BPL : (pressed < 0 ? UI_BSL : UI_BNL)];
    if(s[1].buf) {
        c = pressed == -1 || flags & UI_DISABLED;
        _ui_blit(ctx, x, y + (h - s[0].h)/2, s[0].w, s[0].h, &s[0], 0, 0, c);
        _ui_blit(ctx, x + s[0].w, y + (h - s[1].h)/2, w - s[0].w - s[2].w, s[1].h, &s[1], 0, 0, c);
        _ui_blit(ctx, x + w - s[2].w, y + (h - s[2].h)/2, s[2].w, s[2].h, &s[2], 0, 0, c);
    } else
    if(pressed > 0 && !(flags & UI_DISABLED)) {
        _ui_rect(ctx, x, y, w, h, ctx->theme[UI_BD], ctx->theme[UI_BGD], ctx->theme[UI_BL]);
        _ui_frect(ctx, x + 1, y + 1, w - 2, h - H - 1, ctx->theme[UI_BGD]);
        _ui_frect(ctx, x + 1, y + h - H - 1, w - 2, H, ctx->theme[UI_BGL]);
    } else
    if(pressed == -1 || (flags & UI_DISABLED)) {
        _ui_frect(ctx, x, y, w, h, ctx->theme[UI_DBG]);
    } else {
        _ui_rect(ctx, x, y, w, h, ctx->theme[UI_BL], ctx->theme[UI_BGL], ctx->theme[UI_BD]);
        _ui_frect(ctx, x + 1, y + 1, w - 2, H, ctx->theme[UI_BGL]);
        _ui_frect(ctx, x + 1, y + H, w - 2, h - H - 1, ctx->theme[UI_BGD]);
    }
    if(icon && icon->buf) {
        _ui_blit(ctx, tx, y + top + (h - icon->h) / 2 + !!(pressed > 0), icon->w, icon->h, icon, 0, 0, flags & UI_DISABLED);
        tx += icon->w + 4;
    }
    if(ctx->fnt && ctx->draw && ctx->txtv && label > 0 && label < ctx->txtc) {
        if(pressed != -1) {
            if(ctx->theme[UI_SBD])
                (*ctx->draw)(ctx->fnt, ctx->txtv[label], NULL, ctx->screen.buf, ctx->theme[pressed == -2 ? UI_SSD : UI_SBD],
                    tx - 1 - l , ty - 1, l, t, ctx->screen.p, ctx->cx0 + 1, ctx->cy0 + 1, ctx->cx1 - 1, ctx->cy1 - 1);
            if(ctx->theme[UI_SBL])
                (*ctx->draw)(ctx->fnt, ctx->txtv[label], NULL, ctx->screen.buf, ctx->theme[pressed == -2 ? UI_SSL : UI_SBL],
                    tx + 1 - l , ty + 1, l, t, ctx->screen.p, ctx->cx0 + 1, ctx->cy0 + 1, ctx->cx1 - 1, ctx->cy1 - 1);
        }
        (*ctx->draw)(ctx->fnt, ctx->txtv[label], NULL, ctx->screen.buf, ctx->theme[pressed == -1 ? UI_DFG :
            (pressed == -2 ? UI_SFG : UI_BFG)], tx - l, ty, l, t, ctx->screen.p,
            ctx->cx0 + 1, ctx->cy0 + 1, ctx->cx1 - 1, ctx->cy1 - 1);
    }
}

/**
 * Draw a slider
 */
void _ui_slider(ui_t *ctx, int x, int y, int w, int h, int cur, int max, int flags)
{
    ui_image_t *s;
    int n, id = UI_ID, il = UI_IL, ifg = UI_IFG, ibg = UI_IBG;

    if(!ctx || !ctx->screen.buf || x + w < ctx->cx0 || y + h < ctx->cy0 || x >= ctx->cx1 || y >= ctx->cy1 || w < 7) return;
    if(max < 1) max = 1;
    if(cur < 0) cur = 0;
    if(cur > max) cur = max;
    if(flags & UI_SELECTED) { id = il = UI_BS; }
    if(flags & UI_DISABLED) { id = il = ibg = UI_DBG; ifg = UI_DFG; }
    n = cur * (w - 9) / max;
    if(ctx->skin[UI_S_B].buf) {
        s = &ctx->skin[UI_S_L];
        _ui_blit(ctx, x, y + (h - s->h)/2, s->w, s->h, s, 0, 0, flags & UI_DISABLED);
        _ui_blit(ctx, x + s->w, y + (h - ctx->skin[UI_S_M].h)/2, w - s->w - ctx->skin[UI_S_R].w, ctx->skin[UI_S_M].h,
            &ctx->skin[UI_S_M], 0, 0, flags & UI_DISABLED);
        s = &ctx->skin[UI_S_R];
        _ui_blit(ctx, x + w - s->w, y + (h - s->h)/2, s->w, s->h, s, 0, 0, flags & UI_DISABLED);
        s = &ctx->skin[UI_S_B];
        _ui_blit(ctx, x + n + 3 - s->w/2, y + (h - s->h)/2, s->w, s->h, s, 0, 0, flags & UI_DISABLED);
    } else {
        h /= 2;
        if(flags & UI_NOBORDER) {
            _ui_frect(ctx, x + 1, y + h - 3, n + 3, 5, ctx->theme[ifg]);
            _ui_frect(ctx, x + n + 3, y + h - 3, w - 4 - n, 5, ctx->theme[ibg]);
        } else {
            _ui_rect(ctx, x, y + h - 3, w, 5, ctx->theme[id], ctx->theme[ibg], ctx->theme[il]);
            _ui_frect(ctx, x + 1, y + h - 2, n + 3, 3, ctx->theme[ifg]);
            _ui_frect(ctx, x + n + 3, y + h - 2, w - 4 - n, 3, ctx->theme[ibg]);
        }
        _ui_radiobtn(ctx, x + n + 5, y + h, -2 - !!(flags & UI_DISABLED), 0);
    }
}

/**
 * Draw a progressbar
 */
void _ui_pbar(ui_t *ctx, int x, int y, int w, int h, int64_t cur, int64_t max, int flags)
{
    char tmp[16];
    int n, dw, dh, l = 0, t = 0, X, Y, W, H;

    if(!ctx || !ctx->screen.buf || x + w < ctx->cx0 || y + h < ctx->cy0 || x >= ctx->cx1 || y >= ctx->cy1) return;
    if(max < 1) max = 1;
    if(cur < 0) cur = 0;
    if(cur > max) cur = max;
    if(!(flags & UI_NOBORDER)) {
        _ui_rect(ctx, x, y, w, h, ctx->theme[UI_ID], ctx->theme[UI_IBG], ctx->theme[UI_IL]);
        x++; y++; w -= 2; h -= 2;
    }
    n = (int)(cur * (int64_t)w / max);
    X = x; Y = y; W = n; H = h;
    if(n > 1 && ctx->theme[UI_PL] && ctx->theme[UI_PD]) {
        _ui_rect(ctx, x, y, n, h, ctx->theme[UI_PL], ctx->theme[UI_PB], ctx->theme[UI_PD]);
        X++; Y++; W -= 2; H -= 2;
    }
    if(ctx->skin[UI_PBG].buf)
        _ui_blit(ctx, X, Y, W, H, &ctx->skin[UI_PBG], 0, 0, 0);
    else
        _ui_frect(ctx, X, Y, W, H, ctx->theme[UI_PB]);
    if(ctx->skin[UI_INP].buf)
        _ui_blit(ctx, x + n, y, w - n, h, &ctx->skin[UI_INP], n % ctx->skin[UI_INP].w, 0, 0);
    else
        _ui_frect(ctx, x + n, y, w - n, h, ctx->theme[UI_IBG]);
    n = (int)(cur * 1000 / max);
    sprintf(tmp, "%u.%u%%", n / 10, n % 10);
    if(ctx->fnt && ctx->bbox && ctx->draw) {
        (*ctx->bbox)(ctx->fnt, tmp, NULL, &dw, &dh, &l, &t);
        _ui_font(ctx, ctx->fnt, tmp, NULL, ctx->screen.buf, ctx->theme[UI_IFG], x + (w - dw) / 2 - l, y + (h - dh) / 2, l, t,
            ctx->screen.p, x + 1, y + 1, x + w - 2, y + h - 2);
    }
}

/**
 * Calculate scrollbar button size and position
 */
int _ui_scr(int s, int cur, int max, int bmin, int *b)
{
    if(cur < 0) cur = 0;
    if(cur > max) cur = max;
    if(s >= max || max < 1) { *b = s; return 0; }
    *b = s * s / max;
    if(*b < bmin) *b = bmin;
    return (s - *b) * cur / (max - s);
}

/**
 * Draw a vertical scrollbar
 */
void _ui_vscrbar(ui_t *ctx, int x, int y, int h, int cur, int max, int pressed)
{
    ui_image_t *st, *sm, *sb;
    int il = UI_IL, id = UI_ID, sbg = UI_SBG, bgl = UI_BGL, p, b;

    if(!ctx || !ctx->screen.buf || x + ctx->sw < ctx->cx0 || y + h < ctx->cy0 || x >= ctx->cx1 || y >= ctx->cy1) return;
    p = _ui_scr(h, cur, max, ctx->sw, &b);
    if(ctx->skin[UI_SV_BM].buf) {
        st = &ctx->skin[UI_SV_T]; sm = &ctx->skin[UI_SV_M]; sb = &ctx->skin[UI_SV_B];
        _ui_blit(ctx, x + (ctx->sw - st->w)/2, y, st->w, st->h, st, 0, 0, pressed < 0);
        _ui_blit(ctx, x + (ctx->sw - sm->w)/2, y + st->h, sm->w, h - st->h - sb->h, sm, 0, 0, pressed < 0);
        _ui_blit(ctx, x + (ctx->sw - sb->w)/2, y + h - sb->h, sb->w, sb->h, sb, 0, 0, pressed < 0);
        st = &ctx->skin[UI_SV_BT]; sm = &ctx->skin[UI_SV_BM]; sb = &ctx->skin[UI_SV_BB];
        _ui_blit(ctx, x + (ctx->sw - st->w)/2, y + p, st->w, st->h, st, 0, 0, pressed < 0);
        _ui_blit(ctx, x + (ctx->sw - sm->w)/2, y + p + st->h, sm->w, b - st->h - sb->h, sm, 0, 0, pressed < 0);
        _ui_blit(ctx, x + (ctx->sw - sb->w)/2, y + p + b - sb->h, sb->w, sb->h, sb, 0, 0, pressed < 0);
    } else {
        if(pressed > 0) { il = UI_ID; id = UI_IL; }
        if(pressed < 0) { sbg = UI_DBG; il = id = bgl = UI_DFG; }
        _ui_frect(ctx, x, y, ctx->sw, p, ctx->theme[sbg]);
        _ui_rect(ctx, x, y + p, ctx->sw, b, ctx->theme[il], ctx->theme[bgl], ctx->theme[id]);
        _ui_frect(ctx, x + 1, y + p + 1, ctx->sw - 2, b - 2, ctx->theme[bgl]);
        _ui_frect(ctx, x, y + p + b, ctx->sw, h - p - b, ctx->theme[sbg]);
    }
}

/**
 * Draw a horizontal scrollbar
 */
void _ui_hscrbar(ui_t *ctx, int x, int y, int w, int cur, int max, int pressed)
{
    ui_image_t *sl, *sm, *sr;
    int il = UI_IL, id = UI_ID, sbg = UI_SBG, bgl = UI_BGL, p, b;

    if(!ctx || !ctx->screen.buf || x + w < ctx->cx0 || y + ctx->sh < ctx->cy0 || x >= ctx->cx1 || y >= ctx->cy1) return;
    p = _ui_scr(w, cur, max, ctx->sh, &b);
    if(ctx->skin[UI_SH_BM].buf) {
        sl = &ctx->skin[UI_SH_L]; sm = &ctx->skin[UI_SH_M]; sr = &ctx->skin[UI_SH_R];
        _ui_blit(ctx, x, y + (ctx->sh - sl->h)/2, sl->w, sl->h, sl, 0, 0, pressed < 0);
        _ui_blit(ctx, x + sl->w, y + (ctx->sh - sm->h)/2, w - sl->w - sr->w, sm->h, sm, 0, 0, pressed < 0);
        _ui_blit(ctx, x + w - sr->w, y + (ctx->sh - sm->h)/2, sr->w, sr->h, sr, 0, 0, pressed < 0);
        sl = &ctx->skin[UI_SH_BL]; sm = &ctx->skin[UI_SH_BM]; sr = &ctx->skin[UI_SH_BR];
        _ui_blit(ctx, x + p, y + (ctx->sh - sl->h)/2, sl->w, sl->h, sl, 0, 0, pressed < 0);
        _ui_blit(ctx, x + p + sl->w, y + (ctx->sh - sm->h)/2, b - sl->w - sr->w, sm->h, sm, 0, 0, pressed < 0);
        _ui_blit(ctx, x + p + b - sr->w, y + (ctx->sh - sm->h)/2, sr->w, sr->h, sr, 0, 0, pressed < 0);
    } else {
        if(pressed > 0) { il = UI_ID; id = UI_IL; }
        if(pressed < 0) { sbg = UI_DBG; il = id = bgl = UI_DFG; }
        _ui_frect(ctx, x, y, p, ctx->sh, ctx->theme[sbg]);
        _ui_rect(ctx, x + p, y, b, ctx->sh, ctx->theme[il], ctx->theme[bgl], ctx->theme[id]);
        _ui_frect(ctx, x + p + 1, y + 1, b - 2, ctx->sh - 2, ctx->theme[bgl]);
        _ui_frect(ctx, x + p + b, y, w - p - b, ctx->sh, ctx->theme[sbg]);
    }
}

/**
 * Draw a text field
 */
void _ui_text(ui_t *ctx, int x, int y, int w, int h, int l, int t, int flags, int edit, char *str, char *end)
{
    char pass[128] = { 0 }, *ptr;
    int il = UI_IL, id = UI_ID, ibg = UI_IBG, ifg = UI_IFG, is = UI_INP, dw, dh, i, p;
    uint32_t *buf;

    if(!ctx || !ctx->screen.buf || x + w < ctx->cx0 || y + h < ctx->cy0 || x >= ctx->cx1 || y >= ctx->cy1) return;
    p = ctx->screen.p / 4;

    if(flags & UI_SELECTED) { id = il = UI_BS; }
    if(edit & 1) il = id = UI_IB;
    if(edit & 16) { il = UI_ID; id = UI_IL; }
    if(edit & 64 && !ctx->popup) { ibg = UI_BG; is = UI_P_BG; }
    if(flags & UI_DISABLED) { il = id = ibg = UI_DBG; ifg = UI_DFG; edit = 0; }
    if(!(edit & 8)) {
        if(!(flags & UI_NOBORDER)) {
            _ui_rect(ctx, x, y, w, h, ctx->theme[id], ctx->theme[ibg], ctx->theme[il]);
            x++; y++; w -= 2; h -= 2;
        }
        if(ctx->skin[is].buf)
            _ui_blit(ctx, x, y, w, h, &ctx->skin[is], 0, 0, flags & UI_DISABLED);
        else
            _ui_frect(ctx, x, y, w, h, ctx->theme[ibg]);
    }
    if(ctx->fnt && ctx->draw && ctx->bbox) {
        if(edit & 1) {
            if(ctx->cur < ctx->scr) ctx->scr = ctx->cur;
            do {
                (*ctx->bbox)(ctx->fnt, ctx->scr, ctx->cur, &dw, &dh, NULL, NULL);
                if(dw < w - 4) break;
                do { ctx->scr++; } while(ctx->scr < ctx->end && (*ctx->scr & 0xC0) == 0x80);
            } while(1);
            if(edit & 2) {
                for(i = 0, ptr = ctx->scr; i < (int)sizeof(pass) - 1 && *ptr; i++) {
                    pass[i] = '*'; do { ptr++; } while(ptr < ctx->end && *ptr && (*ptr & 0xC0) == 0x80);
                }
                pass[i] = 0;
                ptr = pass;
            } else ptr = ctx->scr;
            _ui_font(ctx, ctx->fnt, ptr, NULL, ctx->screen.buf, ctx->theme[UI_ICF], x + 2 - l, y + 1, l, t, ctx->screen.p,
                x + 2, y + 1, x + w - 2, y + h - 2);
            y++; h -= 2;
            if(y < ctx->cy0) { h -= ctx->cy0 - y; y = ctx->cy0; }
            if(ctx->cy0 + h >= ctx->cy1) h = ctx->cy1 - ctx->cy0 - 1;
            buf = (uint32_t*)(ctx->screen.buf + y * ctx->screen.p + (x + dw + 2) * 4);
            for(i = 0; i < h; i++, buf += p) *buf = ctx->theme[UI_IC];
        } else
        if(str) {
            if(edit & 2) {
                for(i = 0, ptr = str; i < (int)sizeof(pass) - 1 && *ptr; i++) {
                    pass[i] = '*'; do { ptr++; } while(*ptr && (*ptr & 0xC0) == 0x80);
                }
                pass[i] = 0;
                ptr = pass;
                end = NULL;
            } else ptr = str;
            y++; if(edit & 32) y++;
            _ui_font(ctx, ctx->fnt, ptr, end, ctx->screen.buf, ctx->theme[ifg], x + 2 - l, y, l, t, ctx->screen.p,
                x + 2, y, x + w - 2, y + h - 1);
        }
    }
}

/**
 * Draw a header
 */
void _ui_header(ui_t *ctx, int x, int y, int w, int h, int pressed, int align, int tri, char *str)
{
    int j = 0, il = UI_IL, id = UI_ID, ibg = UI_IBG, is = UI_INP, mw, mh, dw, dh, t, l;

    if(!ctx || !ctx->screen.buf || x + w < ctx->cx0 || y + h < ctx->cy0 || x >= ctx->cx1 || y >= ctx->cy1) return;

    if(!ctx->popup || (pressed & 0x80000)) { ibg = UI_BG; is = UI_P_BG; }
    if(ctx->skin[is].buf)
        _ui_blit(ctx, x + 1, y + 1, w - 2, h - 2, &ctx->skin[is], 0, 0, 0);
    else
        _ui_frect(ctx, x + 1, y + 1, w - 2, h - 2, ctx->theme[ibg]);

    if(pressed & 1) { il = UI_ID; id = UI_IL; j = 1; }
    if(str && *str && ctx->fnt && ctx->bbox && ctx->draw) {
        mw = x + w - 2; if(mw > ctx->cx1) mw = ctx->cx1;
        mh = y + h - 2; if(mh > ctx->cy1) mh = ctx->cy1;
        (*ctx->bbox)(ctx->fnt, str, NULL, &dw, &dh, NULL, &t);
        switch(align) {
            case UI_RIGHT: l = w - dw - 2; break;
            case UI_CENTER: l = 1 + (w - dw) / 2; break;
            default: l = 4; break;
        }
        _ui_font(ctx, ctx->fnt, str, NULL, ctx->screen.buf, ctx->theme[UI_SBD], x + l - 1, y + (h - dh) / 2 - 1 + j, 0, t, ctx->screen.p, x + 2, y + 2, mw, mh);
        _ui_font(ctx, ctx->fnt, str, NULL, ctx->screen.buf, ctx->theme[UI_SBL], x + l + 1, y + (h - dh) / 2 + 1 + j, 0, t, ctx->screen.p, x + 2, y + 2, mw, mh);
        _ui_font(ctx, ctx->fnt, str, NULL, ctx->screen.buf, ctx->theme[UI_BFG], x + l, y + (h - dh) / 2 + j, 0, t, ctx->screen.p, x + 2, y + 2, mw, mh);
    }
    if(tri == 0) _ui_tri(ctx, x + w - 10, y + h / 2 - 2, 0, ctx->theme[UI_IL], ctx->theme[UI_BFG], ctx->theme[UI_ID]); else
    if(tri == 1) _ui_tri(ctx, x + w - 10, y + h / 2 - 2, 1, ctx->theme[UI_IL], ctx->theme[UI_BFG], ctx->theme[UI_ID]);
    _ui_rect(ctx, x, y, w, h, ctx->theme[il], ctx->theme[UI_IBG], ctx->theme[id]);
}

/**
 * Draw an option list or number input field
 */
void _ui_option(ui_t *ctx, int x, int y, int w, int h, int l, int t, int flags, int pressed, int right, int m, char *str)
{
    ui_image_t *s;
    int il = UI_IL, id = UI_ID, ibg = UI_IBG, ifg = UI_IFG, ibl = UI_BGL, bil = UI_BL, bid = UI_BD, bbg = UI_IBG, dw = 0, dh, bl, bd;
    int p;

    if(!ctx || !ctx->screen.buf || x + w < ctx->cx0 || y + h < ctx->cy0 || x >= ctx->cx1 || y >= ctx->cy1 || h < 2 || w < 2 * h)
        return;

    if(flags & UI_SELECTED) { bid = bil = UI_BS; }
    if(flags & UI_DISABLED) { ibg = bil = bid = bbg = UI_DBG; id = il = ifg = ibl = UI_DFG; pressed = 0; }
    if(!(flags & UI_NOBORDER)) {
        _ui_rect(ctx, x + m, y, w - 2 * m, h, ctx->theme[id], ctx->theme[ibg], ctx->theme[il]);
        x++; y++; w -= 2; h -= 2;
    }

    if(ctx->skin[UI_INP].buf)
        _ui_blit(ctx, x + m, y, w - 2 * m, h, &ctx->skin[UI_INP], 0, 0, flags & UI_DISABLED);
    else
        _ui_frect(ctx, x + h + m, y, w - 2 * (h + m), h, ctx->theme[ibg]);
    s = &ctx->skin[pressed & 1 ? UI_LP : (flags & UI_SELECTED && !(flags & UI_DISABLED) ? UI_LS : UI_LN)];
    if(s->buf)
        _ui_blit(ctx, x, y + 1 + (h - s->h)/2, s->w, s->h, s, 0, 0, flags & UI_DISABLED);
    else {
        if(pressed & 1) { bd = bil; bl = bid; p = 1; } else { bd = bid; bl = bil; p = 0; }
        _ui_rect(ctx, x, y, h, h, ctx->theme[bl], ctx->theme[ibl], ctx->theme[bd]);
        _ui_frect(ctx, x + 1, y + 1, h - 2, h - 2, ctx->theme[ibl]);
        _ui_tri(ctx, x + h / 2 - 3, y + h / 2 - 4 + p, 2, ctx->theme[il], ctx->theme[bbg], ctx->theme[id]);
    }
    s = &ctx->skin[pressed & 2 ? UI_RP : (flags & UI_SELECTED && !(flags & UI_DISABLED) ? UI_RS : UI_RN)];
    if(s->buf)
        _ui_blit(ctx, x + w - s->w, y + 1 + (h - s->h)/2, s->w, s->h, s, 0, 0, flags & UI_DISABLED);
    else {
        if(pressed & 2) { bd = bil; bl = bid; p = 1; } else { bd = bid; bl = bil; p = 0; }
        _ui_rect(ctx, x + w - h, y, h, h, ctx->theme[bl], ctx->theme[ibl], ctx->theme[bd]);
        _ui_frect(ctx, x + w - h + 1, y + 1, h - 2, h - 2, ctx->theme[ibl]);
        _ui_tri(ctx, x + w - h / 2 - 2, y + h / 2 - 4 + p, 3, ctx->theme[il], ctx->theme[bbg], ctx->theme[id]);
    }

    if(ctx->fnt && ctx->draw && str) {
        if(right && ctx->bbox) {
            (*ctx->bbox)(ctx->fnt, str, NULL, &dw, &dh, NULL, NULL);
            dw = w - 2 * h - 4 - dw;
        }
        _ui_font(ctx, ctx->fnt, str, NULL, ctx->screen.buf, ctx->theme[ifg], x + h + 2 + dw - l, y + 1, l, t, ctx->screen.p,
            x + h + 2 - l, y + 1, x + w - h - 2, y + h - 2);
    }
}

/**
 * Draw a selectbox
 */
void _ui_select(ui_t *ctx, int x, int y, int w, int h, int l, int t, int flags, int pressed, int m, char *str)
{
    ui_image_t *s;
    int il = UI_IL, id = UI_ID, ibg = UI_IBG, ifg = UI_IFG, ibl = UI_BGL, bil = UI_BL, bid = UI_BD, bbg = UI_IBG, bl, bd, p;

    if(!ctx || !ctx->screen.buf || x + w < ctx->cx0 || y + h < ctx->cy0 || x >= ctx->cx1 || y >= ctx->cy1 || h < 2 || w < h)
        return;

    if(flags & UI_SELECTED) { bid = bil = UI_BS; }
    if(flags & UI_DISABLED) { ibg = bil = bid = bbg = UI_DBG; il = id = ifg = ibl = UI_DFG; pressed = 0; }
    if(!(flags & UI_NOBORDER)) {
        _ui_rect(ctx, x, y, w - m, h, ctx->theme[id], ctx->theme[ibg], ctx->theme[il]);
        x++; y++; w -= 2; h -= 2;
    }
    if(ctx->skin[UI_INP].buf)
        _ui_blit(ctx, x, y, w - m, h, &ctx->skin[UI_INP], 0, 0, flags & UI_DISABLED);
    else
        _ui_frect(ctx, x, y, w - h - m, h, ctx->theme[ibg]);
    s = &ctx->skin[pressed & 1 ? UI_DP : (flags & UI_SELECTED && !(flags & UI_DISABLED) ? UI_DS : UI_DN)];
    if(s->buf)
        _ui_blit(ctx, x + w - s->w, y + 1 + (h - s->h)/2, s->w, s->h, s, 0, 0, flags & UI_DISABLED);
    else {
        if(pressed & 1) { bd = bil; bl = bid; p = 1; } else { bd = bid; bl = bil; p = 0; }
        _ui_rect(ctx, x + w - h, y, h, h, ctx->theme[bl], ctx->theme[ibl], ctx->theme[bd]);
        _ui_frect(ctx, x + w - h + 1, y + 1, h - 2, h - 2, ctx->theme[ibl]);
        _ui_tri(ctx, x + w - h / 2 - 3, y + h / 2 - 2 + p, 0, ctx->theme[il], ctx->theme[bbg], ctx->theme[id]);
    }
    _ui_font(ctx, ctx->fnt, str, NULL, ctx->screen.buf, ctx->theme[ifg], x + 2 - l, y + 1, l, t, ctx->screen.p,
        x + 2, y + 1, x + w - h - 2, y + h - 2);
}

/**
 * Draw a selectbox popup
 */
int _ui_select_popup(ui_t *ctx, int x, int y, int w, int h, ui_form_t *form)
{
    int i, n;

    if(!ctx || !ctx->screen.buf || !form || !form->optv || form->optc < 1 || x >= ctx->screen.w || y >= ctx->screen.h || w < 1 || h < 1)
        return UI_ERR_BADINP;
    if(!(form->flags & UI_NOBORDER)) {
        _ui_rect(ctx, x, y, w, h, ctx->theme[UI_IB], ctx->theme[UI_IBG], ctx->theme[UI_IB]);
        x++; y++; w -= 2; h -= 2;
        if(!(form->flags & UI_NOSHADOW)) {
            _ui_frect(ctx, x + w + 1, y + 3, 4, h - 2, ctx->theme[UI_SH]);
            _ui_frect(ctx, x + 3, y + h + 1, w + 2, 4, ctx->theme[UI_SH]);
        }
    }
    if(ctx->skin[UI_INP].buf)
        _ui_blit(ctx, x, y, w, h, &ctx->skin[UI_INP], 0, 0, 0);
    else
        _ui_frect(ctx, x, y, w, h, ctx->theme[UI_IBG]);
    for(i = form->str; i < form->optc && y + form->t < ctx->cy1; i++, y += form->eh - 4) {
        if(ctx->mousey >= y + 1 && ctx->mousey < y + 1 + (form->eh - 4)) {
            if(form->sel != i) { form->sel = i; ctx->flags |= UI_REFRESH; }
            if(ctx->skin[UI_HL].buf)
                _ui_blit(ctx, x + 1, y + 1, w - 2, form->eh - 4, &ctx->skin[UI_HL], 0, 0, 0);
            else
                _ui_frect(ctx, x + 1, y + 1, w - 2, form->eh - 4, ctx->theme[UI_HLBG]);
            n = UI_HLFG;
        } else n = UI_IFG;
        if(ctx->fnt && ctx->draw)
            (*ctx->draw)(ctx->fnt, form->optv[i], NULL, ctx->screen.buf, ctx->theme[n], x + 2 - form->l, y + 1, form->l, form->t,
                ctx->screen.p, x + 2, y + 1, x + w, y + 1 + (form->eh - 4));
    }
    return UI_OK;
}

/**
 * Draw a color field
 */
void _ui_color(ui_t *ctx, int x, int y, int w, int h, int l, int t, int flags, uint32_t color)
{
    char tmp[16];
    int il = UI_IL, id = UI_ID, ibg = UI_IBG, ifg = UI_IFG;

    if(!ctx || !ctx->screen.buf || x + w < ctx->cx0 || y + h < ctx->cy0 || x >= ctx->cx1 || y >= ctx->cy1) return;

    if(flags & UI_SELECTED) { id = il = UI_BS; }
    if(flags & UI_DISABLED) { il = id = ibg = UI_DBG; ifg = UI_DFG; }
    if(!(flags & UI_NOBORDER)) {
        _ui_rect(ctx, x, y, w, h, ctx->theme[id], ctx->theme[ibg], ctx->theme[il]);
        x++; y++; w -= 2; h -= 2;
    }
    if(ctx->skin[UI_INP].buf)
        _ui_blit(ctx, x, y, w, h, &ctx->skin[UI_INP], 0, 0, flags & UI_DISABLED);
    else
        _ui_frect(ctx, x, y, w, h, ctx->theme[ibg]);
    if(flags & UI_DISABLED) _ui_checker(ctx, x + 2, y + 2, h - 4, h - 4, ctx->theme[ifg]);
    else _ui_checker(ctx, x + 2, y + 2, h - 4, h - 4, color);
    sprintf(tmp, "%08x", color);
    _ui_font(ctx, ctx->fnt, tmp, NULL, ctx->screen.buf, ctx->theme[ifg], x + h - l, y + 1, l, t, ctx->screen.p,
        x + h, y + 1, x + w - 2, y + h - 2);
}

/**
 * Draw a color popup
 */
int _ui_color_popup(ui_t *ctx, int x, int y, int w, int h, ui_form_t *form)
{
    int cw, dw = 0, dh, i, j, p, pitch;
    uint8_t *C;
    uint32_t *buf, c, d, H;

    if(!ctx || !ctx->screen.buf || !form || !form->ptr || x >= ctx->screen.w || y >= ctx->screen.h || w < 56+256 || h < 16+256)
        return UI_ERR_BADINP;

    C = (uint8_t*)&ctx->color; cw = form->eh - 4; pitch = ctx->screen.p / 4;

    if(!(form->flags & UI_NOBORDER)) {
        _ui_rect(ctx, x, y, w, h, ctx->theme[UI_IB], ctx->theme[UI_IBG], ctx->theme[UI_IB]);
        x++; y++; w -= 2; h -= 2; cw -= 2;
        if(!(form->flags & UI_NOSHADOW)) {
            _ui_frect(ctx, x + w + 1, y + 3, 4, h - 2, ctx->theme[UI_SH]);
            _ui_frect(ctx, x + 3, y + h + 1, w + 2, 4, ctx->theme[UI_SH]);
        }
    }
    if(ctx->skin[UI_INP].buf)
        _ui_blit(ctx, x, y, w, h, &ctx->skin[UI_INP], 0, 0, 0);
    else
        _ui_frect(ctx, x, y, w, h, ctx->theme[UI_IBG]);
    _ui_checker(ctx, x + 2, y + 2, cw, cw, ctx->color);
    if(ctx->fnt && ctx->draw && ctx->bbox && ctx->buf) {
        (*ctx->bbox)(ctx->fnt, ctx->buf, ctx->cur, &dw, &dh, NULL, NULL);
        (*ctx->draw)(ctx->fnt, ctx->buf, NULL, ctx->screen.buf, ctx->theme[UI_ICF], x + cw + 4 - form->l, y + 1, form->l, form->t,
            ctx->screen.p, x + cw + 4, y + 1, x + w - 2, y + 3 + cw);
        buf = (uint32_t*)(ctx->screen.buf + (y + 1) * ctx->screen.p + (x + cw + dw + 4) * 4);
        for(i = 0; i < cw + 2; i++, buf += pitch) *buf = ctx->theme[UI_IC];
    }
    x += 2; y += form->eh + 6;
    for(i = 0; i < 16; i++)
        _ui_checker(ctx, x + 1, y + 2 + (i << 4), 12, 12, ctx->hist[i]);
    buf = (uint32_t*)(ctx->screen.buf + y * ctx->screen.p + x * 4);
    for(p = 20, j = 0; j < 256; j++, p += pitch) {
        if(C[3] == 255 - j) {
            buf[p - 4] = buf[p - 3] = buf[p - 2] = buf[p - 3 - pitch] = buf[p - 3 + pitch] = buf[p - 4 - 2*pitch] =
            buf[p - 4 - pitch] = buf[p - 4 + pitch] = buf[p - 4 + 2*pitch] = ctx->theme[UI_IC];
            for(i = 0; i < 16; i++)
                buf[p + i] = ctx->theme[UI_IC];
        } else {
            c = 256 - j;
            for(i = 0; i < 16; i++) {
                d = j * ((j & 8) ^ (i & 8) ? 0x9f : 0x5f);
                ((uint8_t*)&buf[p+i])[3] = 255;
                ((uint8_t*)&buf[p+i])[2] = (d + c*C[2]) >> 8;
                ((uint8_t*)&buf[p+i])[1] = (d + c*C[1]) >> 8;
                ((uint8_t*)&buf[p+i])[0] = (d + c*C[0]) >> 8;
            }
        }
    }
    for(p = 38, j = 0; j < 256; j++, p += pitch) {
        for(i = 0; i < 256; i++) {
            H = 255 - j == ctx->val ? j + (((ctx->val * i) >> 8) & 0xFF) : j; H |= 0xFF000000 | (H << 16) | (H << 8);
            buf[p + i] = ctx->sat == i || 255-j == ctx->val ? H : _ui_hsv2rgb(255, ctx->hue, i, 255 - j);
        }
    }
    for(p = 40 + 256, j = 0; j < 256; j++, p += pitch) {
        H = _ui_hsv2rgb(255, j, 255, 255);
        if(ctx->hue == j) {
            H = ctx->theme[UI_IC];
            buf[p + 20] = buf[p + 19] = buf[p + 18] = buf[p + 19 - pitch] = buf[p + 19 + pitch] = buf[p + 20 - 2*pitch] =
            buf[p + 20 - pitch] = buf[p + 20 + pitch] = buf[p + 20 + 2*pitch] = H;
        }
        for(i = 0; i < 16; i++)
            buf[p + i] = H;
    }
    return UI_OK;
}

/**
 * Display a popup
 */
int _ui_popup(ui_t *ctx, int x, int y, ui_form_t *form)
{
    ui_image_t *s;
    int n = UI_TIT, w, h, m, m2, top;

    if(!ctx || !ctx->screen.buf || !form || x >= ctx->screen.w || y >= ctx->screen.h || form->ew < 1 || form->eh < 1)
        return UI_ERR_BADINP;
    if(x < 0) x = 0;
    if(y < 0) y = 0;
    w = form->ew; h = form->eh; m = form->m - 2;
    if(m < 0) m = 0;
    m2 = 2 * m;
    top = form->value < 0 ? 0 : form->value;
    ctx->cx0 = ctx->cy0 = 0; ctx->cx1 = ctx->screen.w - 1; ctx->cy1 = ctx->screen.h - 1;
    if((form->type == UI_POPUP || form->type == UI_MENU) && !(form->flags & UI_NOBORDER)) {
        x++; y++; w -= 2; h -= 2;
        if(ctx->skin[UI_P_BG].buf || ((form->flags & UI_ALTSKIN) && ctx->skin[UI_A_BG].buf)) {
            s = &ctx->skin[form->flags & UI_ALTSKIN ? UI_A_TL : UI_P_TL];
            _ui_blit(ctx, x - s[0].w, y - s[0].h, s[0].w, s[0].h, &s[0], 0, 0, 0);
            _ui_blit(ctx, x, y - s[1].h, w, s[1].h, &s[1], 0, 0, 0);
            _ui_blit(ctx, x + w, y - s[2].h, s[2].w, s[2].h, &s[2], 0, 0, 0);
            _ui_blit(ctx, x - s[3].w, y, s[3].w, h, &s[3], 0, 0, 0);
            _ui_blit(ctx, x + w, y, s[5].w, h, &s[5], 0, 0, 0);
            _ui_blit(ctx, x - s[6].w, y  + h, s[6].w, s[6].h, &s[6], 0, 0, 0);
            _ui_blit(ctx, x, y + h, w, s[7].h, &s[7], 0, 0, 0);
            _ui_blit(ctx, x + w, y + h, s[8].w, s[8].h, &s[8], 0, 0, 0);
        } else {
            _ui_rect(ctx, x - 1, y - 1, w + 2, h + 2, ctx->theme[UI_IL], ctx->theme[UI_BG], ctx->theme[UI_ID]);
            if(!(form->flags & UI_NOSHADOW)) {
                _ui_frect(ctx, x + w + 1, y + 3, 4, h - 2, ctx->theme[UI_SH]);
                _ui_frect(ctx, x + 3, y + h + 1, w + 2, 4, ctx->theme[UI_SH]);
            }
        }
    }
    ctx->cx0 = x; ctx->cy0 = y; ctx->cx1 = x + w + 1; ctx->cy1 = y + h + 1;
    if(ctx->cx1 >= ctx->screen.w) ctx->cx1 = ctx->screen.w - 1;
    if(ctx->cy1 >= ctx->screen.h) ctx->cy1 = ctx->screen.h - 1;
    if(form->type != UI_DIV) {
        if((form->flags & UI_ALTSKIN) && ctx->skin[UI_A_BG].buf)
            _ui_blit(ctx, x, y, w, h, &ctx->skin[UI_A_BG], 0, 0, 0);
        else
        if(ctx->skin[UI_P_BG].buf)
            _ui_blit(ctx, x, y, w, h, &ctx->skin[UI_P_BG], 0, 0, 0);
        else
            _ui_frect(ctx, x, y, w, h, ctx->theme[UI_BG]);
    }
    form->sw = form->sh = 0;
    if(form->type == UI_POPUP) {
        if(form->flags & UI_RESIZABLE)
            _ui_tri(ctx, x + w - 7, y + h - 7, 4, ctx->theme[UI_IL], ctx->theme[UI_IL], ctx->theme[UI_IL]);
        if(form->flags & UI_DRAGGABLE) {
            if((form->flags & UI_ALTSKIN) && ctx->skin[UI_A_TIT].buf) {
                _ui_blit(ctx, x + 1, y + 1, w - ctx->skin[UI_A_CLOSE].w - 1, top - 2, &ctx->skin[UI_A_TIT], 0, 0, 0);
                _ui_blit(ctx, x + w - ctx->skin[UI_A_CLOSE].w, y + (top - ctx->skin[UI_A_CLOSE].h) / 2,
                    ctx->skin[UI_A_CLOSE].w, ctx->skin[UI_A_CLOSE].h, &ctx->skin[UI_A_CLOSE], 0, 0, 0);
            } else
            if(ctx->skin[UI_P_TIT].buf) {
                _ui_blit(ctx, x + 1, y + 1, w - ctx->skin[UI_P_CLOSE].w - 1, top - 2, &ctx->skin[UI_P_TIT], 0, 0, 0);
                _ui_blit(ctx, x + w - ctx->skin[UI_P_CLOSE].w, y + (top - ctx->skin[UI_P_CLOSE].h) / 2,
                    ctx->skin[UI_P_CLOSE].w, ctx->skin[UI_P_CLOSE].h, &ctx->skin[UI_P_CLOSE], 0, 0, 0);
            } else {
                _ui_frect(ctx, x + 1, y + 1, w - 12, top - 2, ctx->theme[UI_TIT]);
                _ui_checkbox(ctx, x + w - 5, y + (top + 1) / 2, -2, 0);
            }
            n = UI_BG;
        }
        if(ctx->fnt && ctx->draw && ctx->txtv && form->label > 0 && form->label < ctx->txtc)
            (*ctx->draw)(ctx->fnt, ctx->txtv[form->label], NULL, ctx->screen.buf, ctx->theme[n],
                x + 2 - form->l, y + 1, form->l, form->t, ctx->screen.p, ctx->cx0, ctx->cy0, ctx->cx1 - 16, ctx->cy1);
        y += top; h -= top;
        if((form->flags & UI_HSCROLL) && w - m2 < form->mw) {
            h -= ctx->sh;
            form->sw = w - m2 - ((form->flags & UI_VSCROLL) && h - m2 < form->mh ? ctx->sw : 0);
            if(form->ox > form->mw - form->sw) form->ox = form->mw - form->sw;
            if(form->ox < 0) form->ox = 0;
            _ui_hscrbar(ctx, x + m, y + h - m, form->sw, form->ox, form->mw, ctx->hscr == form);
        } else form->ox = 0;
        if((form->flags & UI_VSCROLL) && h - m2 < form->mh) {
            w -= ctx->sw;
            form->sh = h - m2;
            if(form->oy > form->mh - form->sh) form->oy = form->mh - form->sh;
            if(form->oy < 0) form->oy = 0;
            _ui_vscrbar(ctx, x + w - m, y + m, form->sh, form->oy, form->mh, ctx->vscr == form);
        } else form->oy = 0;
    }
    if(form->ptr) _ui_draw(ctx, x + m, y + m, w - m2, h - m2, form->ox, form->oy, form->ptr, form->type);
    return UI_OK;
}

/**
 * Set font hooks. Only needed if you want custom driver
 */
int ui_fonthook(ui_t *ctx, ui_font_bbox bbox, ui_font_draw draw)
{
    if(!ctx || !bbox || !draw) return UI_ERR_BADINP;
    ctx->bbox = bbox; ctx->draw = draw;
    return UI_OK;
}

/**
 * Set the UI font (driver specific, opaque to UI)
 */
int ui_font(ui_t *ctx, void *fnt)
{
    if(!ctx || !fnt) return UI_ERR_BADINP;
    ctx->fnt = fnt;
    return UI_OK;
}

/**
 * Set the software mouse cursor
 */
int ui_swcursor(ui_t *ctx, ui_image_t *cursor)
{
    if(!ctx) return UI_ERR_BADINP;
    ctx->mouse.w = ctx->mouse.h = 0;
    if(!cursor || !cursor->buf || cursor->w < 1 || cursor->h < 1) return UI_ERR_BADINP;
    if(!(ctx->mouse.buf = (uint8_t*)realloc(ctx->mouse.buf, cursor->w * cursor->h * 4))) return UI_ERR_NOMEM;
    memset(ctx->mouse.buf, 0, cursor->w * cursor->h * 4);
    ctx->mouse.p = cursor->w * 4;
    ctx->mouse.w = cursor->w;
    ctx->mouse.h = cursor->h;
    ui_backend_hidecursor(ctx->bck);
    return UI_OK;
}

/**
 * Set the hardware mouse cursor
 */
int ui_hwcursor(ui_t *ctx)
{
    if(!ctx) return UI_ERR_BADINP;
    if(ctx->mouse.buf) free(ctx->mouse.buf);
    ctx->mouse.buf = NULL;
    ctx->mouse.w = ctx->mouse.h = ctx->mouse.p = 0;
    ui_backend_showcursor(ctx->bck);
    return UI_OK;
}

/**
 * Set the color theme
 */
int ui_theme(ui_t *ctx, uint32_t *theme)
{
    if(!ctx || !theme) return UI_ERR_BADINP;
    memcpy(&ctx->theme, theme, UI_NUMTHEME * sizeof(uint32_t));
    return UI_OK;
}

/**
 * Set the skin from multiple images
 */
int ui_skin(ui_t *ctx, ui_image_t *skin)
{
    if(!ctx || !skin) return UI_ERR_BADINP;
    memcpy(&ctx->skin, skin, UI_NUMSKIN * sizeof(ui_image_t));
    ctx->sw = ctx->sh = 0;
    if(ctx->sw < ctx->skin[UI_SV_BT].w) ctx->sw = ctx->skin[UI_SV_BT].w;
    if(ctx->sw < ctx->skin[UI_SV_BM].w) ctx->sw = ctx->skin[UI_SV_BM].w;
    if(ctx->sw < ctx->skin[UI_SV_BB].w) ctx->sw = ctx->skin[UI_SV_BB].w;
    if(ctx->sh < ctx->skin[UI_SH_BL].h) ctx->sh = ctx->skin[UI_SH_BL].h;
    if(ctx->sh < ctx->skin[UI_SH_BM].h) ctx->sh = ctx->skin[UI_SH_BM].h;
    if(ctx->sh < ctx->skin[UI_SH_BR].h) ctx->sh = ctx->skin[UI_SH_BR].h;
    ui_swcursor(ctx, &ctx->skin[UI_CURSOR]);
    return UI_OK;
}

/**
 * Set the skin from a single PNG file
 */
int ui_pngskin(ui_t *ctx, uint8_t *png, int size)
{
#if defined(STBI_INCLUDE_STB_IMAGE_H) && !defined(STBI_NO_PNG)
    ui_image_t skin[UI_NUMSKIN] = { 0 };
    uint8_t *ret, *end, *ptr, *comment = NULL, *cend;
    uint32_t cs;
    int i, x, y, w, h, W, H, p;
    stbi__context s = { 0 };
    stbi__result_info ri = { 0 };

    /* decode the png */
    s.img_buffer = s.img_buffer_original = png;
    s.img_buffer_end = s.img_buffer_original_end = end = png + size;
    ri.bits_per_channel = 8;
    if(!ctx || !png || size < 16 || !(ret = (uint8_t*)stbi__png_load(&s, &W, &H, &p, 4, &ri))) return UI_ERR_BADINP;
    /* locate the comment */
    for(ptr = png + 8; ptr < end; ptr += cs + 12) {
        cs = ((ptr[0] << 24) | (ptr[1] << 16) | (ptr[2] << 8) | ptr[3]);
        if(!memcmp(ptr + 4, "zTXtComment", 12)) {
            comment = (uint8_t*)stbi_zlib_decode_malloc_guesssize_headerflag((const char *)ptr + 17, cs, 65536, &p, 1);
            cend = comment + p;
            break;
        } else
        if(!memcmp(ptr + 4, "tEXtComment", 12)) {
            comment = ptr + 16;
            cend = comment + cs - 4;
            break;
        }
    }
    if(comment) {
        for(i = 0, ptr = comment; ptr < cend && i < UI_NUMSKIN;) {
            /* only parse numbers in each line, so this can work with tabtext, json and xml as well */
            while(ptr < cend && (*ptr < '0' || *ptr > '9')) { ptr++; } if(ptr >= cend) break;
            x = atoi((char*)ptr); while(ptr < cend && *ptr >= '0' && *ptr <= '9') { ptr++; }
            while(ptr < cend && (*ptr < '0' || *ptr > '9')) { ptr++; } if(ptr >= cend) break;
            y = atoi((char*)ptr); while(ptr < cend && *ptr >= '0' && *ptr <= '9') { ptr++; }
            while(ptr < cend && (*ptr < '0' || *ptr > '9')) { ptr++; } if(ptr >= cend) break;
            w = atoi((char*)ptr); while(ptr < cend && *ptr >= '0' && *ptr <= '9') { ptr++; }
            while(ptr < cend && (*ptr < '0' || *ptr > '9')) { ptr++; } if(ptr >= cend) break;
            h = atoi((char*)ptr); while(ptr < cend && *ptr >= '0' && *ptr <= '9') { ptr++; }
            while(ptr < cend && *ptr != '\n' && *ptr != ')' && *ptr != ']' && *ptr != '}' && *ptr != '>') ptr++;
            if(w > 0 && h > 0 && x >= 0 && x + w <= W && y >= 0 && y + h <= H) {
                skin[i].w = w; skin[i].h = h; skin[i].p = W * 4;
                skin[i++].buf = ret + (y * W + x) * 4;
            }
        }
        if(comment < png || comment >= end) free(comment);
        ui_skin(ctx, skin);
        if(ctx->skinbuf) free(ctx->skinbuf);
        ctx->skinbuf = ret;
        return UI_OK;
    } else
        free(ret);
#else
    (void)ctx; (void)png; (void)size;
#endif
    return UI_ERR_BADINP;
}

/**
 * Recalculate form element positions
 */
int _ui_recalc(ui_t *ctx, int x, int y, int w, int h, int p, ui_form_t *form, int *ow, int *oh)
{
    ui_form_t *last = NULL;
    char tmp[32], *ls, *le;
    int ret, i, rx = 0, dx = 0, dy = 0, dw, dh, lh = 0, mw = 0, mh = 0, tw, th, tl, tt, nw;
    int16_t sx, sy, sw, sh, px, py, pw, ph;

    if(!ctx) return UI_ERR_BADINP;
    if(!form) return UI_OK;
    if(w < 0) w = 0;
    if(h < 0) h = 0;
    rx = w - 2;
    ctx->flags |= UI_REFRESH;

    /* get the default size and default top */
    if(!ctx->ds && ctx->fnt && ctx->bbox)
        (*ctx->bbox)(ctx->fnt, "Ag", NULL, &dw, &ctx->ds, NULL, &ctx->dt);

    for(; form->type != UI_END; last = form++) {
        /* calculate effective values from user provided values */
        sx = (int16_t)form->x; sy = (int16_t)form->y;
        sw = (int16_t)form->w; sh = (int16_t)form->h;
        px = (form->x & 0x7f0000) >> 16; py = (form->y & 0x7f0000) >> 16;
        pw = (form->w & 0x7f0000) >> 16; ph = (form->h & 0x7f0000) >> 16;
        form->ex = x + (px ? w * px / 100 + sx : (form->x & 0x800000 ? (sx < 0 ? w + sx : sx) : dx + sx));
        form->ey = y + (py ? h * py / 100 + sy : (form->y & 0x800000 ? (sy < 0 ? h + sy : sy) : dy + sy));
        form->ew = pw ? w * pw / 100 + sw : (form->w & 0x800000 ? w - (sw & 0x7fff) - form->ex : (sw & 0x7fff));
        form->eh = ph ? h * ph / 100 + sh : (form->h & 0x800000 ? h - (sh & 0x7fff) - form->ey : (sh & 0x7fff));
        /* measure the size */
        dw = dh = 0;
        switch(form->type) {
            case UI_POPUP:
            case UI_MENU:
            case UI_DIV:
                dw = form->ew - 2 * form->m - (form->flags & UI_VSCROLL ? ctx->sw + 2 : 0); if(dw < 0) dw = 0;
                dh = form->eh - 2 * form->m - (form->flags & UI_HSCROLL ? ctx->sw + ctx->sh + 2 : 0); if(dh < 0) dh = 0;
                dw += 4; dh += 4;
                if(w && dw > w) dw = w;
                form->mw = dw; form->mh = dh;
                /* calculate container's contents */
                if((ret = _ui_recalc(ctx, 2, 2, dw, dh, form->p, form->ptr, &dw, &dh)) != UI_OK) continue;
                /* add 2 + 2 pixel margin */
                if(form->mw < dw + 4) form->mw = dw + 4;
                if(form->mh < dh + 4) form->mh = dh + 4;
                /* add popup title */
                form->value = 0;
                if(form->type == UI_POPUP) {
                    if(ctx->fnt && ctx->bbox && ctx->txtv && form->label > 0 && form->label < ctx->txtc) {
                        (*ctx->bbox)(ctx->fnt, ctx->txtv[form->label], NULL, &tw, &th, &form->l, &form->t);
                        if(form->flags & UI_DRAGGABLE && th < 9) th = 9;
                        if(dw < tw) dw = tw;
                        form->value = th + 2;
                    }
                    if(form->flags & UI_DRAGGABLE) {
                        form->value = form->value > 11 ? form->value : 11;
                        if((form->flags & UI_ALTSKIN) && ctx->skin[UI_A_TIT].buf && form->value < ctx->skin[UI_A_CLOSE].h + 2)
                            form->value = ctx->skin[UI_A_CLOSE].h + 2;
                        else
                        if(ctx->skin[UI_P_TIT].buf && form->value < ctx->skin[UI_P_CLOSE].h + 2)
                            form->value = ctx->skin[UI_P_CLOSE].h + 2;
                    }
                }
                dw += 2 * form->m + 2;
                dh += 2 * form->m + form->value + 2;
                if(dw < 16) dw = 16;
                if(dh < 16) dh = 16;
                if(form->type == UI_DIV) { dw += 2; dh += 2; }
                if(!(form->flags & UI_SCROLL) || form->ew < 1 || form->eh < 1) {
                    if(form->ew < dw) form->ew = dw;
                    if(form->eh < dh) form->eh = dh;
                }
                if(form->type == UI_MENU) form->flags |= UI_HIDDEN;
                if(last && last->type == UI_TOGGLE && !form->x && !form->y) {
                    form->ex = last->ex + (last->flags & UI_NOBULLET ? 0 : last->m + 7);
                    form->ey = last->ey + last->eh;
                    if(form->ex + form->ew > x + w) form->ew = x + w - form->ex;
                    if(form->type == UI_DIV && !(form->flags & UI_HIDDEN)) {
                        dx = form->ex; dy = form->ey;
                    }
                }
                dw = form->ew; dh = form->eh;
            break;
            case UI_TOGGLE:
            case UI_STATUS:
            case UI_LABEL:
            case UI_CHECK:
            case UI_RADIO:
                if(ctx->fnt && ctx->bbox) {
                    if(ctx->txtv && form->type != UI_STATUS && form->label > 0 && form->label < ctx->txtc)
                        (*ctx->bbox)(ctx->fnt, ctx->txtv[form->label], NULL, &dw, &dh, &form->l, &form->t);
                    else if(form->ptr && (form->type == UI_LABEL || form->type == UI_TOGGLE))
                        (*ctx->bbox)(ctx->fnt, (char*)form->ptr, NULL, &dw, &dh, &form->l, &form->t);
                    else if(form->type == UI_STATUS) { dh = ctx->ds; form->t = ctx->dt; }
                    dh += 4;
                } else if(form->type != UI_TOGGLE) {
                    dw = 0;
                    dh = ctx->ds;
                }
                if(dh < 9) dh = 9;
                if(form->type == UI_TOGGLE)
                    dw += (form->flags & UI_NOBULLET ? 2 * form->m : 9);
                else
                if(!(form->flags & UI_NOBULLET) && form->type > UI_STATUS)
                    dw += dh;
                if(form->icon && form->icon->buf) dw += dh;
            break;
            case UI_MLINE:
                dw = dh = 0;
                if(ctx->fnt && ctx->bbox && (ls = ctx->txtv && form->label > 0 && form->label < ctx->txtc ? ctx->txtv[form->label] : (char*)form->ptr)) {
                    while(*ls) {
                        for(le = ls; *le && *le != '\n'; le++);
                        (*ctx->bbox)(ctx->fnt, ls, le, &tw, NULL, &tl, NULL);
                        if(tw > dw) dw = tw;
                        if(tl > form->l) form->l = tl;
                        dh += ctx->ds;
                        ls = le;
                        if(*ls == '\n') ls++;
                    }
                }
                if(dh < 9) dh = 9;
                form->t = ctx->dt;
            break;
            case UI_BUTTON:
            case UI_BTNTGL:
                if(ctx->fnt && ctx->bbox && ctx->txtv && form->label > 0 && form->label < ctx->txtc) {
                    (*ctx->bbox)(ctx->fnt, ctx->txtv[form->label], NULL, &dw, &dh, NULL, NULL);
                    if(form->icon && form->icon->buf) dw += 4;
                }
                if(form->icon && form->icon->buf) {
                    dw += form->icon->w;
                    if(dh < form->icon->h) dh = form->icon->h;
                }
                dw += 8 + form->min; dh += 4;
                if(ctx->skin[UI_BNM].buf) {
                    dw += ctx->skin[UI_BNL].w + ctx->skin[UI_BNR].w;
                    if(dh < ctx->skin[UI_BNL].h) dh = ctx->skin[UI_BNL].h;
                    if(dh < ctx->skin[UI_BNM].h) dh = ctx->skin[UI_BNM].h;
                    if(dh < ctx->skin[UI_BNR].h) dh = ctx->skin[UI_BNR].h;
                }
            break;
            case UI_DEC8: case UI_DEC16: case UI_DEC32: case UI_DEC64:
            case UI_HEX8: case UI_HEX16: case UI_HEX32: case UI_HEX64:
            case UI_DEC_FLOAT:
                sprintf(tmp, "0.000");
                if(ctx->fnt && ctx->bbox) {
                    (*ctx->bbox)(ctx->fnt, tmp, NULL, &dw, &dh, &form->l, &form->t);
                    dh += 4;
                }
            break;
            case UI_SLIDER:
            case UI_PBAR:
                sprintf(tmp, "100.0%%");
                if(ctx->fnt && ctx->bbox) {
                    (*ctx->bbox)(ctx->fnt, tmp, NULL, &dw, &dh, NULL, NULL);
                    dh += 4;
                }
                nw = x + mw - form->ex;
                if(form->ew < 1) form->ew = nw > 100 ? nw : 100;
                if(form->type == UI_SLIDER) {
                    if(dh < ctx->skin[UI_S_L].h) dh = ctx->skin[UI_S_L].h;
                    if(dh < ctx->skin[UI_S_M].h) dh = ctx->skin[UI_S_M].h;
                    if(dh < ctx->skin[UI_S_R].h) dh = ctx->skin[UI_S_R].h;
                    if(dh < ctx->skin[UI_S_B].h) dh = ctx->skin[UI_S_B].h;
                }
            break;
            case UI_VSCRBAR:
                form->ew = ctx->sw;
                if(form->eh < ctx->sh) form->eh = ctx->sh;
            break;
            case UI_HSCRBAR:
                if(form->ew < ctx->sw) form->ew = ctx->sw;
                form->eh = ctx->sh;
            break;
            case UI_IMAGE:
            case UI_BTNICN:
                if(form->icon && form->icon->buf && form->icon->w > 0 && form->icon->h > 0) {
                    dw = form->icon->w; dh = form->icon->h;
                }
            break;
            case UI_ICON:
                dw = form->ew;
                dh = form->eh;
            break;
            case UI_TXTINP:
                if(ctx->fnt && ctx->bbox) {
                    /* if string is empty, use a default one to get height and baseline correctly */
                    (*ctx->bbox)(ctx->fnt, form->ptr, NULL, &dw, &dh, &form->l, &form->t);
                    if(!form->ptr || !*((char*)form->ptr)) { dw = 0; dh = ctx->ds; form->t = ctx->dt; }
                    dh += 4;
                }
                if(form->ew > 0) dw = form->ew;
            break;
            case UI_SELECT:
            case UI_OPTION:
                form->l = form->t = 0;
                if(form->optv && form->optc && ctx->bbox) {
                    for(tl = tt = i = 0; i < form->optc; i++) {
                        (*ctx->bbox)(ctx->fnt, form->optv[i], NULL, &tw, &th, &tl, &tt);
                        th += 4;
                        if(dw < tw) dw = tw;
                        if(dh < th) dh = th;
                        if(form->l < tl) form->l = tl;
                        if(form->t < tt) form->t = tt;
                    }
                    dw += 4 + (form->type == UI_SELECT ? dh : 2 * dh);
                }
            break;
            case UI_INT8: case UI_INT16: case UI_INT32: case UI_INT64:
            case UI_FLOAT:
                if(form->type == UI_FLOAT)
                    sprintf(tmp, "%g.000", -form->fmin > form->fmax ? form->fmin : form->fmax);
                else
                    sprintf(tmp, "%" L "d", -form->min > form->max ? form->min : form->max);
                if(ctx->fnt && ctx->bbox) {
                    (*ctx->bbox)(ctx->fnt, tmp, NULL, &dw, &dh, &form->l, &form->t);
                    dh += 4; dw += 4 + 2 * dh;
                }
            break;
            case UI_COLOR:
                sprintf(tmp, "FFFFFFFF");
                if(ctx->fnt && ctx->bbox) {
                    (*ctx->bbox)(ctx->fnt, tmp, NULL, &dw, &dh, &form->l, &form->t);
                    dh += 4; dw += dh;
                }
            break;
            case UI_CUSTOM:
                if(form->bbox)
                    (*form->bbox)(ctx, form->ex, form->ey, form->ew, form->eh, form, &dw, &dh);
            break;
        }
        if(form->ew < dw) form->ew = dw;
        if(form->eh < dh) form->eh = dh;
        dw = form->ew; dh = form->eh;
        /* handle alignment */
        switch(form->align & 3) {
            case 1: form->ex -= dw; break;
            case 2: form->ex -= dw / 2; break;
            case 3: form->ex = x; break;
        }
        switch((form->align >> 2) & 3) {
            case 1: form->ey -= dh; break;
            case 2: form->ey -= dh / 2; break;
            case 3: form->ey = y; break;
        }
        /* make sure popups and menus are always on screen */
        if(form->type == UI_POPUP || form->type == UI_MENU) {
            if(form->ex + form->ew + 1 > ctx->screen.w) {
                form->ex = ctx->screen.w - form->ew - 1;
                if(form->ex < 1) { form->ex = 1; form->ew = ctx->screen.w - 2; }
            }
            if(form->ey + form->eh + 1 > ctx->screen.h) {
                form->ey = ctx->screen.h - form->eh - 1;
                if(form->ey < 1) { form->ey = 1; form->eh = ctx->screen.h - 2; }
            }
        }
        /* handle flow */
        if(!(form->flags & UI_HIDDEN)) {
            if(form->type != UI_POPUP && form->type != UI_MENU && !(form->x & 0xff0000) && !(form->y & 0xff0000)) {
                i = (last && (last->flags & UI_NOBR));
                if((form->align & 3) == 1 && !form->x) {
                    /* subtract mandatory 2 pixel margin */
                    if(rx < w - 2) rx -= p;
                    rx -= dw;
                    if(lh < form->eh) lh = form->eh;
                    if(rx < x) { rx = w - dw - 2; if(lh) { lh += p; } form->ey += lh; dy += lh; lh = 0; }
                    form->ex = rx;
                } else {
                    if(form->ex > x) form->ex += p;
                    if((w > 0 && !(form->flags & UI_FORCEBR)) || i) {
                        if(!i && form->ex + form->ew + 2 >= w) {
                            if(lh) { lh += p; } form->ex = x; form->ey += lh; dy += lh; lh = 0;
                        }
                        if(!(form->y & 0x800000)) dy += sy;
                        if(lh < form->eh) lh = form->eh;
                        dx = form->ex + form->ew;
                    } else {
                        if(lh < form->eh) lh = form->eh;
                        dy += lh + p;
                        dx = lh = 0;
                    }
                    dw = form->ex + form->ew - x; if(mw < dw) mw = dw;
                    dh = form->ey + form->eh - y; if(mh < dh) mh = dh;
                }
            }
        }
    }
    if(ow) *ow = mw;
    if(oh) *oh = mh;
    return UI_OK;
}

/**
 * Display a form
 */
int _ui_draw(ui_t *ctx, int x, int y, int w, int h, int ox, int oy, ui_form_t *form, int parent)
{
    ui_form_t *popup;
    char tmp[32], *ls, *le;
    int i, s, e, n, m, tx, ty, cx0, cx1, cy0, cy1, x0, x1, dw, dh;
    int16_t *ints, bx0, bx1, by0, by1;
    uint32_t fg;

    if(!ctx || !ctx->screen.buf || x >= ctx->screen.w || y >= ctx->screen.h)
        return UI_ERR_BADINP;
    if(!form || w < 1 || h < 1) return UI_OK;

    cx0 = ctx->cx0; cx1 = ctx->cx1; cy0 = ctx->cy0; cy1 = ctx->cy1;
    if(ctx->cx0 < x) ctx->cx0 = x;
    if(ctx->cy0 < y) ctx->cy0 = y;
    if(ctx->cx1 > x + w) ctx->cx1 = x + w;
    if(ctx->cy1 > y + h) ctx->cy1 = y + h;
    x0 = ctx->cx0; x1 = ctx->cx1;
    for(; form->type != UI_END; form++) {
        if((form->flags & UI_HIDDEN)) { if(parent < 0) break; else continue; }
        tx = x + form->ex - ox; ty = y + form->ey - oy;
        ctx->cx0 = x0; ctx->cx1 = x1;
        switch(form->type) {
            case UI_POPUP:
            case UI_MENU:
                if(ctx->numpopups < UI_MAXPOPUPS) {
                    for(n = 0; n < ctx->numpopups && ctx->popups[n]->min > form->min; n++);
                    if(ctx->numpopups > n)
                        memmove(&ctx->popups[n + 1], &ctx->popups[n], (ctx->numpopups - n) * sizeof(void*));
                    ctx->popups[n] = form;
                    ctx->numpopups++;
                }
            break;
            case UI_DIV:
                n = ctx->cy0; m = ctx->cy1;
                _ui_popup(ctx, tx, ty, form);
                ctx->cy0 = n; ctx->cy1 = m;
            break;
            case UI_TOGGLE:
                popup = !form->value && UI_CONTAINER(form[1].type) ? &form[1] : &ctx->form[form->value];
                s = UI_CONTAINER(popup->type) ? !(popup->flags & UI_HIDDEN) : 0;
                n = parent == -1 ? UI_HLFG : UI_FG;
                if(form->flags & UI_DISABLED) {
                    n = UI_DFG;
                } else {
                    if(parent == UI_MENU) {
                        if(ctx->hover == form) {
                            if(ctx->skin[UI_HL].buf)
                                _ui_blit(ctx, x, ty, w, form->eh, &ctx->skin[UI_HL], 0, 0, 0);
                            else
                                _ui_frect(ctx, x, ty, w, form->eh, ctx->theme[UI_HLBG]);
                            n = UI_HLFG;
                        }
                    } else {
                        if(form->flags & UI_NOBULLET) {
                            if(s) n = UI_TFG;
                            if((form->flags & UI_ALTSKIN) && ctx->skin[UI_A_BG].buf) {
                                _ui_blit(ctx, tx, ty, ctx->skin[UI_M_L].w, form->eh, &ctx->skin[UI_M_L], 0, 0, !s);
                                _ui_blit(ctx, tx + ctx->skin[UI_M_L].w, ty, form->ew - ctx->skin[UI_M_L].w - ctx->skin[UI_M_R].w,
                                    form->eh, &ctx->skin[UI_M_BG], 0, 0, !s);
                                _ui_blit(ctx, tx + form->ew - ctx->skin[UI_M_R].w, ty, ctx->skin[UI_M_R].w, form->eh,
                                    &ctx->skin[UI_M_R], 0, 0, !s);
                            } else
                            if(ctx->skin[UI_P_BG].buf && s)
                                _ui_blit(ctx, tx, ty, form->ew, form->eh, &ctx->skin[UI_P_BG], 0, 0, 0);
                            else
                            if(s)
                                _ui_frect(ctx, tx, ty, form->ew, form->eh, ctx->theme[UI_TBG]);
                            tx += form->m;
                        } else {
                            m = ty + (form->eh - 5) / 2;
                            if(s) _ui_tri(ctx, tx + 1, m, 0, ctx->theme[UI_FG], ctx->theme[UI_FG], ctx->theme[UI_FG]);
                            else _ui_tri(ctx, tx + 2, m - 2, 3, ctx->theme[UI_FG], ctx->theme[UI_FG], ctx->theme[UI_FG]);
                            tx += 9;
                        }
                    }
                    if(form->icon && form->icon->buf) {
                        ctx->cx0 = tx;
                        if(ctx->cx1 > tx + form->eh) ctx->cx1 = tx + form->eh;
                        _ui_blit(ctx, tx + (form->eh - form->icon->w) / 2, ty + (form->eh - form->icon->h) / 2,
                            form->icon->w, form->icon->h, form->icon, 0, 0, form->flags & UI_DISABLED);
                        ctx->cx1 = x1;
                        tx += form->eh;
                    }
                }
                if(ctx->fnt && ctx->draw) {
                    if(ctx->txtv && form->label > 0 && form->label < ctx->txtc)
                        (*ctx->draw)(ctx->fnt, ctx->txtv[form->label], NULL, ctx->screen.buf, ctx->theme[n],
                            tx - form->l, ty + 2, form->l, form->t, ctx->screen.p, ctx->cx0, ctx->cy0, ctx->cx1, ctx->cy1);
                    else if(form->ptr)
                        (*ctx->draw)(ctx->fnt, (char*)form->ptr, NULL, ctx->screen.buf, ctx->theme[n],
                            tx - form->l, ty + 2, form->l, form->t, ctx->screen.p, ctx->cx0, ctx->cy0, ctx->cx1, ctx->cy1);
                }
            break;
            case UI_STATUS:
            case UI_LABEL:
                n = form->flags & UI_DISABLED ? UI_DFG : (parent == -1 ? UI_HLFG : UI_FG);
                if(form->type == UI_LABEL && !(form->flags & UI_DISABLED) && parent == UI_MENU && ctx->hover == form) {
                    if(ctx->skin[UI_HL].buf)
                        _ui_blit(ctx, x, ty, w, form->eh, &ctx->skin[UI_HL], 0, 0, 0);
                    else
                        _ui_frect(ctx, x, ty, w, form->eh, ctx->theme[UI_HLBG]);
                    n = UI_HLFG;
                }
                if(form->type == UI_STATUS) {
                    if(ctx->skin[UI_P_BG].buf)
                        _ui_blit(ctx, tx, ty, form->ew, form->eh, &ctx->skin[UI_INP], 0, 0, 0);
                    else
                        _ui_frect(ctx, tx, ty, form->ew, form->eh, ctx->theme[UI_IBG]);
                    s = ctx->hover ? ctx->hover->desc : 0;
                } else
                    s = form->label;
                if(form->icon && form->icon->buf) {
                    ctx->cx0 = tx;
                    if(ctx->cx1 > tx + form->eh) ctx->cx1 = tx + form->eh;
                    _ui_blit(ctx, tx + (form->eh - form->icon->w) / 2, ty + (form->eh - form->icon->h) / 2,
                        form->icon->w, form->icon->h, form->icon, 0, 0, form->flags & UI_DISABLED);
                    ctx->cx1 = x1;
                    tx += form->eh;
                }
                if(ctx->fnt && ctx->draw) {
                    if(ctx->txtv && s > 0 && s < ctx->txtc)
                        (*ctx->draw)(ctx->fnt, ctx->txtv[s], NULL, ctx->screen.buf, ctx->theme[n],
                            tx - form->l, ty + 2, form->l, form->t, ctx->screen.p, ctx->cx0, ctx->cy0, ctx->cx1, ctx->cy1);
                    else if(form->ptr)
                        (*ctx->draw)(ctx->fnt, (char*)form->ptr, NULL, ctx->screen.buf, ctx->theme[n],
                            tx - form->l, ty + 2, form->l, form->t, ctx->screen.p, ctx->cx0, ctx->cy0, ctx->cx1, ctx->cy1);
                }
            break;
            case UI_MLINE:
                if(form->bg && !(form->flags & UI_DISABLED))
                    _ui_frect(ctx, x, y, w, h, form->bg);
                if(ctx->fnt && ctx->draw && (ls = ctx->txtv && form->label > 0 && form->label < ctx->txtc ? ctx->txtv[form->label] : (char*)form->ptr)) {
                    fg = form->flags & UI_DISABLED ? ctx->theme[UI_DFG] : (form->fg ? form->fg : ctx->theme[UI_FG]);
                    while(*ls && ty < ctx->cy1) {
                        for(le = ls; *le && *le != '\n'; le++);
                        (*ctx->draw)(ctx->fnt, ls, le, ctx->screen.buf, fg,
                            tx - form->l, ty + 2, form->l, form->t, ctx->screen.p, ctx->cx0, ctx->cy0, ctx->cx1, ctx->cy1);
                        ty += ctx->ds;
                        ls = le;
                        if(*ls == '\n') ls++;
                    }
                }
            break;
            case UI_CHECK:
            case UI_RADIO:
                n = form->flags & UI_DISABLED ? UI_DFG : (parent == -1 ? UI_HLFG : UI_FG);
                if(!(form->flags & UI_DISABLED) && parent == UI_MENU && ctx->hover == form) {
                    if(ctx->skin[UI_HL].buf)
                        _ui_blit(ctx, x, ty, w, form->eh, &ctx->skin[UI_HL], 0, 0, 0);
                    else
                        _ui_frect(ctx, x, ty, w, form->eh, ctx->theme[UI_HLBG]);
                    n = UI_HLFG;
                }
                if(!(form->flags & UI_NOBULLET)) {
                    s = form->eh / 2;
                    ctx->cx0 = tx;
                    if(ctx->cx1 > tx + form->eh) ctx->cx1 = tx + form->eh;
                    if(form->type == UI_CHECK)
                        _ui_checkbox(ctx, tx + s, ty + s,
                            form->flags & UI_DISABLED ? -1 : (form->ptr ? *((int*)form->ptr) & (form->value ? form->value : 1) : 0),
                            form->flags);
                    else
                        _ui_radiobtn(ctx, tx + s, ty + s,
                            form->flags & UI_DISABLED ? -1 : (form->ptr ? *((int*)form->ptr) == form->value : 0),
                            form->flags);
                    ctx->cx1 = x1;
                    tx += form->eh;
                }
                if(form->icon && form->icon->buf) {
                    ctx->cx0 = tx;
                    if(ctx->cx1 > tx + form->eh) ctx->cx1 = tx + form->eh;
                    _ui_blit(ctx, tx + (form->eh - form->icon->w) / 2, ty + (form->eh - form->icon->h) / 2,
                        form->icon->w, form->icon->h, form->icon, 0, 0, form->flags & UI_DISABLED);
                    ctx->cx1 = x1;
                    tx += form->eh;
                }
                if(ctx->fnt && ctx->draw && ctx->txtv && form->label > 0 && form->label < ctx->txtc)
                    (*ctx->draw)(ctx->fnt, ctx->txtv[form->label], NULL, ctx->screen.buf, ctx->theme[n],
                        tx - form->l, ty + 2, form->l, form->t, ctx->screen.p, ctx->cx0, ctx->cy0, ctx->cx1, ctx->cy1);
            break;
            case UI_BUTTON:
                _ui_button(ctx, tx, ty, form->ew, form->eh, form->flags & UI_DISABLED ? -1 :
                    (ctx->pressed == form || (form->ptr && *((int*)form->ptr) == form->value) ? 1 :
                    (ctx->hover == form ? -2 : 0)), form->flags, form->icon, form->label, ctx->skin[UI_BNM].buf ? form->m : 0);
            break;
            case UI_BTNTGL:
                popup = form->ptr && UI_CONTAINER(((ui_form_t*)form->ptr)->type) ? (ui_form_t*)form->ptr : &ctx->form[form->value];
                _ui_button(ctx, tx, ty, form->ew, form->eh, form->flags & UI_DISABLED ? -1 :
                    (ctx->pressed == form ? 1 : (ctx->hover == form ? -2 : 0)), form->flags, form->icon, form->label,
                    ctx->skin[UI_BNM].buf ? form->m : 0);
            break;
            case UI_BTNICN:
                if(form->icon && form->icon->buf && form->icon->w > 0 && form->icon->h > 0 && form->ptr &&
                  *((int*)form->ptr) & (form->value ? form->value : 1))
                    _ui_blit(ctx, tx + (form->ew - form->icon->w) / 2, ty + (form->eh - form->icon->h) / 2,
                        form->icon->w, form->icon->h, form->icon, 0, 0, form->flags & UI_DISABLED);
            break;
            case UI_SLIDER:
                _ui_slider(ctx, tx, ty, form->ew, form->eh, form->ptr ? *((int*)form->ptr) : 0, form->max - form->min, form->flags);
            break;
            case UI_VSCRBAR:
                _ui_vscrbar(ctx, tx, ty, form->eh, form->ptr ? *((int*)form->ptr) : 0, form->max,
                    form->flags & UI_DISABLED ? -1 : ctx->vscr == form);
            break;
            case UI_HSCRBAR:
                _ui_hscrbar(ctx, tx, ty, form->ew, form->ptr ? *((int*)form->ptr) : 0, form->max,
                    form->flags & UI_DISABLED ? -1 : ctx->hscr == form);
            break;
            case UI_PBAR: _ui_pbar(ctx, tx, ty, form->ew, form->eh, form->ptr ? *((int64_t*)form->ptr) : 0, form->max, form->flags); break;
            case UI_DEC8: case UI_DEC16: case UI_DEC32: case UI_DEC64:
            case UI_HEX8: case UI_HEX16: case UI_HEX32: case UI_HEX64:
            case UI_DEC_FLOAT:
                if(form->ptr) {
                    n = form->flags & UI_DISABLED ? UI_DFG : (parent == -1 ? UI_HLFG : UI_FG);
                    switch(form->type) {
                        case UI_DEC8: sprintf(tmp, "%d", *((int8_t*)form->ptr)); break;
                        case UI_DEC16: sprintf(tmp, "%d", *((int16_t*)form->ptr)); break;
                        case UI_DEC32: sprintf(tmp, "%d", *((int32_t*)form->ptr)); break;
                        case UI_DEC64: sprintf(tmp, "%" L "d", *((int64_t*)form->ptr)); break;
                        case UI_HEX8: sprintf(tmp, "%x", *((uint8_t*)form->ptr)); break;
                        case UI_HEX16: sprintf(tmp, "%x", *((uint16_t*)form->ptr)); break;
                        case UI_HEX32: sprintf(tmp, "%x", *((uint32_t*)form->ptr)); break;
                        case UI_HEX64: sprintf(tmp, "%" L "x", *((uint64_t*)form->ptr)); break;
                        case UI_DEC_FLOAT: sprintf(tmp, "%.4g", *((float*)form->ptr)); break;
                    }
                    if(ctx->fnt && ctx->bbox && ctx->draw) {
                        (*ctx->bbox)(ctx->fnt, tmp, NULL, &dw, &dh, NULL, NULL);
                        (*ctx->draw)(ctx->fnt, tmp, NULL, ctx->screen.buf, ctx->theme[n],
                            tx + form->ew - dw - form->l, ty + 2, form->l, form->t, ctx->screen.p,
                            ctx->cx0, ctx->cy0, ctx->cx1, ctx->cy1);
                    }
                }
            break;
            case UI_IMAGE:
                if(form->icon && form->icon->buf && form->icon->w > 0 && form->icon->h > 0)
                    _ui_blit(ctx, tx, ty, form->ew, form->eh, form->icon, 0, 0, form->flags & UI_DISABLED);
            break;
            case UI_ICON:
                if(form->icon && form->icon->buf && form->icon->w > 0 && form->icon->h > 0)
                    _ui_scaled(ctx, tx, ty, form->ew, form->eh, form->icon, form->flags & UI_DISABLED);
            break;
            case UI_LINES:
                if((ints = (int16_t*)form->ptr)) {
                    for(s = 0; ints[s + 2] || ints[s + 3]; s += 2)
                        _ui_line(ctx, ints[s], ints[s + 1], ints[s + 2], ints[s + 3], form->value);
                }
            break;
            case UI_VCONNECT:
            case UI_HCONNECT:
                if(form->ptr) {
                    bx0 = ((int16_t*)form->ptr)[0]; by0 = ((int16_t*)form->ptr)[1];
                    bx1 = ((int16_t*)form->ptr)[2]; by1 = ((int16_t*)form->ptr)[3];
                    if(bx0 > bx1) { i = bx0; bx0 = bx1; bx1 = i; }
                    if(by0 > by1) { i = by0; by0 = by1; by1 = i; }
                    if(form->type == UI_HCONNECT)
                        _ui_cbez(ctx, bx0,by0, bx1,by1, bx1,by0, bx0,by1, form->value);
                    else
                        _ui_cbez(ctx, bx0,by0, bx1,by1, bx0,by1, bx1,by0, form->value);
                }
            break;
            case UI_CURVE:
                if((ints = (int16_t*)form->ptr))
                    _ui_cbez(ctx, ints[0], ints[1], ints[2], ints[3], ints[4], ints[5], ints[6], ints[7], form->value);
            break;
            case UI_TXTINP:
                _ui_text(ctx, tx, ty, form->ew, form->eh, form->l, form->t, form->flags,
                    (ctx->text == form) | (form->inc == UI_FILTER_PASS ? 2 : 0), form->ptr, NULL);
            break;
            case UI_SELECT:
                _ui_select(ctx, tx, ty, form->ew, form->eh, form->l, form->t, form->flags, ctx->pressed == form,
                    ctx->skin[UI_INP].buf ? form->m : 0,
                    form->optv && form->ptr && *((int*)form->ptr) >= 0 && *((int*)form->ptr) < form->optc ? form->optv[*((int*)form->ptr)] : "");
            break;
            case UI_OPTION:
                _ui_option(ctx, tx, ty, form->ew, form->eh, form->l, form->t, form->flags, ctx->pressed == form ? ctx->maxlen : 0, UI_LEFT,
                    ctx->skin[UI_INP].buf ? form->m : 0,
                    form->optv && form->ptr && *((int*)form->ptr) >= 0 && *((int*)form->ptr) < form->optc ? form->optv[*((int*)form->ptr)] : "");
            break;
            case UI_INT8: case UI_INT16: case UI_INT32: case UI_INT64:
            case UI_FLOAT:
                if(form->ptr) {
                    switch(form->type) {
                        case UI_INT8: sprintf(tmp, "%d", *((int8_t*)form->ptr)); break;
                        case UI_INT16: sprintf(tmp, "%d", *((int16_t*)form->ptr)); break;
                        case UI_INT32: sprintf(tmp, "%d", *((int32_t*)form->ptr)); break;
                        case UI_INT64: sprintf(tmp, "%" L "d", *((int64_t*)form->ptr)); break;
                        case UI_FLOAT: sprintf(tmp, "%.4g", *((float*)form->ptr)); break;
                    }
                    _ui_option(ctx, tx, ty, form->ew, form->eh, form->l, form->t, form->flags, ctx->pressed == form ? ctx->maxlen : 0,
                        UI_RIGHT, ctx->skin[UI_INP].buf ? form->m : 0, tmp);
                }
            break;
            case UI_COLOR:
                _ui_color(ctx, tx, ty, form->ew, form->eh, form->l, form->t, form->flags, form->ptr ? *((uint32_t*)form->ptr) : 0xff000000);
            break;
            case UI_CUSTOM:
                if(form->view) {
                    s = ctx->cx0; e = ctx->cx1; n = ctx->cy0; m = ctx->cy1;
                    if(ctx->cx0 < tx) ctx->cx0 = tx;
                    if(ctx->cy0 < ty) ctx->cy0 = ty;
                    if(ctx->cx1 > tx + form->ew) ctx->cx1 = tx + form->ew;
                    if(ctx->cy1 > ty + form->eh) ctx->cy1 = ty + form->eh;
                    (*form->view)(ctx, tx, ty, form->ew, form->eh, form);
                    ctx->cx0 = s; ctx->cx1 = e; ctx->cy0 = n; ctx->cy1 = m;
                }
            break;
        }
        if(parent < 0) break;
    }
    ctx->cx0 = cx0; ctx->cx1 = cx1; ctx->cy0 = cy0; ctx->cy1 = cy1;
    return UI_OK;
}

/**
 * Redraw form elements
 */
int _ui_redraw(ui_t *ctx, ui_form_t *form)
{
    int64_t mz = 0;
    int ret, i;

    if(!ctx || !ctx->screen.buf) return UI_ERR_BADINP;
    memset(ctx->screen.buf, 0, ctx->screen.p * ctx->screen.h);
    ctx->menu = NULL;
    ctx->numpopups = 0;
    ctx->cx0 = ctx->cy0 = 0; ctx->cx1 = ctx->screen.w; ctx->cy1 = ctx->screen.h;
    ret = _ui_draw(ctx, 0, 0, ctx->screen.w, ctx->screen.h, 0, 0, form, UI_END);
    for(i = ctx->numpopups - 1; i >= 0; i--) {
        if(mz < ctx->popups[i]->min) mz = ctx->popups[i]->min;
        if(ctx->popups[i]->type == UI_MENU && !(ctx->popups[i]->flags & UI_HIDDEN)) ctx->menu = ctx->popups[i];
        _ui_popup(ctx, ctx->popups[i]->ex, ctx->popups[i]->ey, ctx->popups[i]);
    }
    if(mz >= 0x7fffffffffff8000L)
        for(i = 0; i < ctx->numpopups; i++)
            ctx->popups[i]->min >>= 16;
    if(ctx->popup && ctx->dr) {
        ctx->cx0 = ctx->cy0 = 0; ctx->cx1 = ctx->screen.w; ctx->cy1 = ctx->screen.h;
        if(ctx->px + ctx->pw + 2 >= ctx->screen.w) ctx->px = ctx->screen.w - ctx->pw - 2;
        if(ctx->py + ctx->ph + 2 >= ctx->screen.h) ctx->py = ctx->screen.h - ctx->ph - 2;
        if(ctx->px < 0) { ctx->pw += ctx->px; ctx->px = 0; }
        if(ctx->py < 0) { ctx->ph += ctx->py; ctx->py = 0; }
        (*ctx->dr)(ctx, ctx->px, ctx->py, ctx->pw, ctx->ph, ctx->popup);
    }
    return ret;
}

/**
 * Force refresh
 */
int ui_refresh(ui_t *ctx)
{
    if(!ctx) return UI_ERR_BADINP;
    ctx->flags |= UI_REFRESH | UI_RECALC;
    return UI_OK;
}

/**
 * Set the localized string array
 */
int ui_settxt(ui_t *ctx, char **txtv)
{
    if(!ctx || !ctx->txtc || !txtv || !*txtv) return UI_ERR_BADINP;
    ctx->txtv = txtv;
    ui_backend_settitle(ctx->bck, *txtv);
    ctx->ds = ctx->dt = 0;
    _ui_recalc(ctx, 0, 0, ctx->screen.w, ctx->screen.h, 0, ctx->form, NULL, NULL);
    ctx->flags |= UI_REFRESH;
    return UI_OK;
}

/**
 * Get the clipboard's text
 */
char *ui_getclipboard(ui_t *ctx)
{
    return ctx ? ui_backend_getclipboard(ctx->bck) : NULL;
}

/**
 * Set the clipboard's text
 */
int ui_setclipboard(ui_t *ctx, char *str)
{
    return ctx && str && *str ? ui_backend_setclipboard(ctx->bck, str) : UI_ERR_BADINP;
}

/**
 * Set mouse position
 */
int _ui_setmouse(ui_t *ctx, int x, int y)
{
    if(!ctx) return UI_ERR_BADINP;
    ctx->mousex = x; ctx->mousey = y;
    return UI_OK;
}

/**
 * Get mouse position
 */
int ui_getmouse(ui_t *ctx, int *x, int *y)
{
    if(!ctx || !x || !y) return UI_ERR_BADINP;
    *x = ctx->mousex; *y = ctx->mousey;
    return UI_OK;
}

/**
 * Get the next free event slot
 */
ui_event_t *_ui_evtslot(ui_t *ctx)
{
    ui_event_t *evt = NULL;

    if(ctx && (ctx->head + 1) % UI_MAXEVENTS != ctx->tail) {
        evt = &ctx->events[ctx->head++];
        ctx->head %= UI_MAXEVENTS;
        memset(evt, 0, sizeof(ui_event_t));
    }
    return evt;
}

/**
 * Resize the window backbuffer
 */
int _ui_resize(ui_t *ctx, int w, int h)
{
    ui_event_t *evt;

    if(!ctx || w < 1 || h < 1) return UI_ERR_BADINP;
    ctx->screen.w = w; ctx->screen.h = h; ctx->screen.p = w * 4;
    if((ctx->screen.buf = (uint8_t*)realloc(ctx->screen.buf, w * h * 4))) {
        memset(ctx->screen.buf, 0, w * h * 4);
        if(ctx->menu) ctx->menu->flags |= UI_HIDDEN;
        ctx->form = ctx->menu = ctx->text = NULL;
        ctx->flags |= UI_CLOSE;
        if((evt = _ui_evtslot(ctx))) { evt->x = w; evt->y = h; evt->type = UI_EVT_RESIZE; }
        return UI_OK;
    }
    return UI_ERR_NOMEM;
}

/**
 * Increment an option list or number field
 */
void _ui_inc(ui_form_t *form)
{
    if(form && form->ptr)
        switch(form->type) {
            case UI_SELECT:
            case UI_OPTION:
                *((int*)form->ptr) += 1;
                if(*((int*)form->ptr) >= form->optc) *((int*)form->ptr) = 0;
            break;
            case UI_FLOAT:
                *((float*)form->ptr) += form->finc != 0.0 ? form->finc : 1.0;
                if(*((float*)form->ptr) > form->fmax) *((float*)form->ptr) = form->fmax;
            break;
            case UI_INT8:
                *((int8_t*)form->ptr) += form->inc ? form->inc : 1;
                if(*((int8_t*)form->ptr) > form->max) *((int8_t*)form->ptr) = form->max;
            break;
            case UI_INT16:
                *((int16_t*)form->ptr) += form->inc ? form->inc : 1;
                if(*((int16_t*)form->ptr) > form->max) *((int16_t*)form->ptr) = form->max;
            break;
            case UI_INT32:
                *((int32_t*)form->ptr) += form->inc ? form->inc : 1;
                if(*((int32_t*)form->ptr) > form->max) *((int32_t*)form->ptr) = form->max;
            break;
            case UI_INT64:
                *((int64_t*)form->ptr) += form->inc ? form->inc : 1;
                if(*((int64_t*)form->ptr) > form->max) *((int64_t*)form->ptr) = form->max;
            break;
        }
}

/**
 * Decrement an option list or number field
 */
void _ui_dec(ui_form_t *form)
{
    if(form && form->ptr)
        switch(form->type) {
            case UI_SELECT:
            case UI_OPTION:
                *((int*)form->ptr) -= 1;
                if(*((int*)form->ptr) < 0) *((int*)form->ptr) = form->optc - 1;
            break;
            case UI_FLOAT:
                *((float*)form->ptr) -= form->finc != 0.0 ? form->finc : 1.0;
                if(*((float*)form->ptr) < form->fmin) *((float*)form->ptr) = form->fmin;
            break;
            case UI_INT8:
                *((int8_t*)form->ptr) -= form->inc ? form->inc : 1;
                if(*((int8_t*)form->ptr) < form->min) *((int8_t*)form->ptr) = form->min;
            break;
            case UI_INT16:
                *((int16_t*)form->ptr) -= form->inc ? form->inc : 1;
                if(*((int16_t*)form->ptr) < form->min) *((int16_t*)form->ptr) = form->min;
            break;
            case UI_INT32:
                *((int32_t*)form->ptr) -= form->inc ? form->inc : 1;
                if(*((int32_t*)form->ptr) < form->min) *((int32_t*)form->ptr) = form->min;
            break;
            case UI_INT64:
                *((int64_t*)form->ptr) -= form->inc ? form->inc : 1;
                if(*((int64_t*)form->ptr) < form->min) *((int64_t*)form->ptr) = form->min;
            break;
        }
}

/**
 * Selectbox controller
 */
int _ui_select_ctrl(ui_t *ctx, int x, int y, int w, int h, ui_form_t *form, ui_event_t *evt)
{
    if(!ctx || !ctx->screen.buf || !form || !form->ptr || form->eh <= 4 || x >= ctx->screen.w || y >= ctx->screen.h ||
      w < 1 || h < 1 || !evt || evt->type == UI_EVT_NONE)
        return UI_ERR_BADINP;
    if(evt->type == UI_EVT_MOUSE) {
        if((evt->btn & UI_BTN_U) && form->str > 0) form->str--;
        if((evt->btn & UI_BTN_D) && form->str < form->optc - (h / (form->eh - 4))) form->str++;
    }
    if((evt->type == UI_EVT_MOUSE && (evt->btn & UI_BTN_L) && (ctx->mousey - y - 2) / (form->eh - 4) + form->str == form->sel) ||
      (evt->type == UI_EVT_KEY && evt->key[0] == '\n')) {
        *((int*)form->ptr) = form->sel;
        ctx->flags |= UI_CLOSE;
    }
    return UI_OK;
}

/**
 * Start select input
 */
void _ui_select_start(ui_t *ctx, int x, int y, int w, int h, ui_form_t *form)
{
    int i;

    if(!ctx || !form || form->type != UI_SELECT || !form->ptr || !form->optv || form->optc < 1) return;
    form->str = 0;
    form->sel = *((int*)form->ptr);
    if(form->sel < 0) form->sel = 0;
    if(form->sel >= form->optc) form->sel = form->optc - 1;
    ctx->px = x; ctx->py = y - (h - 4) * form->sel; ctx->pw = w; ctx->ph = 4 + (h - 4) * form->optc;
    ctx->popup = form;
    ctx->pe = &_ui_select_ctrl;
    ctx->dr = &_ui_select_popup;
    if(ctx->fnt && ctx->bbox)
        for(i = 0; i < form->optc; i++) {
            (*ctx->bbox)(ctx->fnt, form->optv[i], NULL, &w, &h, NULL, NULL);
            if(ctx->pw < w) ctx->pw = w;
        }
}

/**
 * Start text input
 */
void _ui_text_start(ui_t *ctx, int x, int y, int w, int h, ui_form_t *form, char *str, int maxlen)
{
    int l;

    if(!ctx || !form || !str || maxlen < 1) return;

    ctx->px = x; ctx->py = y; ctx->pw = w; ctx->ph = h;
    l = strlen(str); if(l >= maxlen) l = maxlen - 1;
    if((ctx->buf = (char*)realloc(ctx->buf, maxlen))) {
        memcpy(ctx->buf, str, l + 1);
        ctx->maxlen = maxlen;
        ctx->scr = ctx->buf;
        ctx->cur = ctx->end = ctx->buf + l;
        ctx->text = form;
        ctx->str = str;
        ui_backend_showosk(ctx->bck);
    }
}

/**
 * Add key to input string
 */
void _ui_text_add(ui_t *ctx, char *k, int i)
{
    char *s;
    int ok;

    if(!ctx || !ctx->text || i < 1 || i > 4 || !k || !k[0] || k[0] == '\\' || (uint8_t)k[0] < ' ') return;
    switch(ctx->text->type == UI_COLOR ? UI_FILTER_HEX : ctx->text->inc) {
        /* 1, a unix id, only 0-9a-zA-Z allowed, and _ if not first */
        case UI_FILTER_ID: ok = (k[0] >= '0' && k[0] <= '9') || (k[0] >= 'a' && k[0] <= 'z') || (k[0] >= 'A' && k[0] <= 'Z') ||
            (ctx->cur > ctx->buf && k[0] == '_'); break;
        /* 2, a variable id, same as 1 except 0-9 not allowed as first */
        case UI_FILTER_VAR: ok = (k[0] >= 'a' && k[0] <= 'z') || (k[0] >= 'A' && k[0] <= 'Z') ||
            (ctx->cur > ctx->buf && (k[0] == '_' || (k[0] >= '0' && k[0] <= '9'))); break;
        /* 3, an expression */
        case UI_FILTER_EXPR: ok = (k[0] >= 'a' && k[0] <= 'z') || (k[0] >= 'A' && k[0] <= 'Z') || (k[0] == '.' || k[0] == '_') ||
            (k[0] >= '0' && k[0] <= '9') || k[0] == '(' || k[0] == '-' || k[0] == '@' || (ctx->cur > ctx->buf &&
            ((k[0] == ')' || k[0] == '+' || k[0] == '*' || k[0] == '/' || k[0] == '%' || k[0] == '>' || k[0] == '<' ||
            k[0] == '=' || k[0] == '!' || k[0] == '&' || k[0] == '|' || k[0] == ','))); break;
        /* 4, a hex value */
        case UI_FILTER_HEX:
            if(k[0] >= 'A' && k[0] <= 'F') k[0] += 'a' - 'A';
            ok = (k[0] >= '0' && k[0] <= '9') || (k[0] >= 'a' && k[0] <= 'f');
        break;
        /* 0, not an id, everything allowed except space as first */
        default: ok = (ctx->cur > ctx->buf || k[0] != ' '); break;
    }
    if(ok && ctx->end - ctx->buf + i < ctx->maxlen) {
            for(s = ctx->end; s >= ctx->cur; s--) s[i] = s[0];
            memcpy(ctx->cur, k, i);
            ctx->cur += i;
            ctx->end += i;
            *ctx->end = 0;
    }
}

/**
 * Text input box controller
 */
void _ui_text_ctrl(ui_t *ctx, ui_event_t *evt)
{
    int i, dw, dh;
    char *s, *c, tmp[8];

    if(!ctx || !ctx->text || !evt || evt->type == UI_EVT_NONE) return;

    if((evt->type == UI_EVT_KEY && (evt->key[0] == '\x1b' || evt->key[0] == '\n')) ||
      (evt->type == UI_EVT_MOUSE && !(evt->btn & UI_BTN_RELEASE) &&
      (ctx->mousex < ctx->px || ctx->mousex >= ctx->px + ctx->pw ||
       ctx->mousey < ctx->py || ctx->mousey >= ctx->py + ctx->ph)) || (ctx->flags & UI_CLOSE)) {
        /* ESC or Enter pressed, or clicked outside: we must close */
        if(ctx->buf) {
            if(ctx->text->type == UI_COLOR && evt->type == UI_EVT_KEY && evt->key[0] == '\n') return;
            if(ctx->text->type != UI_COLOR && ctx->str && (evt->type != UI_EVT_KEY || evt->key[0] != '\x1b')) {
                memcpy((char*)ctx->str, ctx->buf, (uintptr_t)ctx->end - (uintptr_t)ctx->buf + 1);
                if(ctx->text->type == UI_CUSTOM && ctx->text->ctrl)
                    (*ctx->text->ctrl)(ctx, ctx->text->ex, ctx->text->ey, ctx->text->ew, ctx->text->eh, ctx->text, evt);
            }
            free(ctx->buf); ctx->buf = NULL;
        }
        ctx->buf = ctx->scr = ctx->cur = ctx->end = ctx->str = NULL;
        ctx->text = NULL;
        ui_backend_hideosk(ctx->bck);
        ctx->flags |= UI_CLOSE;
    } else
    if(evt->type == UI_EVT_MOUSE && !(evt->btn & UI_BTN_RELEASE) && ctx->scr && ctx->fnt && ctx->bbox && ctx->px > 0 &&
       ctx->mousex >= ctx->px && ctx->mousex < ctx->px + ctx->pw && ctx->mousey >= ctx->py && ctx->mousey < ctx->py + ctx->text->eh) {
        /* the text input field clicked, move text cursor to mouse cursor */
        i = ctx->mousex - ctx->px - (ctx->text->type == UI_COLOR ? ctx->text->eh : 2);
        for(s = ctx->scr, dw = 0; s <= ctx->end;) {
            (*ctx->bbox)(ctx->fnt, ctx->scr, s, &dw, &dh, NULL, NULL);
            if(dw > i) break;
            do { s++; } while(s < ctx->end && (*s & 0xC0) == 0x80);
        }
        ctx->cur = s > ctx->end ? ctx->end : s;
    } else
    if(evt->type == UI_EVT_KEY && !(evt->btn & (UI_BTN_ALT | UI_BTN_GUI))) {
        /* key pressed */
        if(!memcmp(evt->key, "Home", 5)) { ctx->cur = ctx->buf; } else
        if(!memcmp(evt->key, "End", 4)) { ctx->cur = ctx->end; } else
        if(!memcmp(evt->key, "Left", 5)) {
            if(ctx->cur > ctx->buf)
                do { ctx->cur--; } while(ctx->cur > ctx->buf && (*ctx->cur & 0xC0) == 0x80);
        } else
        if(!memcmp(evt->key, "Right", 6)) {
            if(ctx->cur < ctx->end)
                do { ctx->cur++; } while(ctx->cur < ctx->end && (*ctx->cur & 0xC0) == 0x80);
        } else
        if(!memcmp(evt->key, "Copy", 5)) {
            if(ctx->buf && ctx->end > ctx->buf)
                ui_backend_setclipboard(ctx->bck, ctx->buf);
        } else
        if(!memcmp(evt->key, "Paste", 6)) {
            if((s = c = ui_backend_getclipboard(ctx->bck))) {
                while(*s) {
                    memset(&tmp, 0, sizeof(tmp)); i = 0;
                    if(!(*s & 128)) { i = 1; tmp[0] = *s++; } else
                    if(!(*s & 32)) { i = 2; memcpy(&tmp, s, 2); s += 2; } else
                    if(!(*s & 16)) { i = 3; memcpy(&tmp, s, 3); s += 3; } else
                    if(!(*s & 8)) { i = 4; memcpy(&tmp, s, 4); s += 4; }
                    if(tmp[0] < ' ') break;
                    _ui_text_add(ctx, (char*)&tmp, i);
                }
                free(c);
            }
        } else
        if(!memcmp(evt->key, "Del", 4)) {
            if(ctx->cur < ctx->end) {
                s = ctx->cur;
                do { s++; } while(s < ctx->end && (*s & 0xC0) == 0x80);
                for(i = 0; s + i <= ctx->end; i++) ctx->cur[i] = s[i];
                ctx->end -= (uintptr_t)s - (uintptr_t)ctx->cur;
            }
        } else
        if(evt->key[0] == '\b') {
            if(ctx->cur > ctx->buf) {
                s = ctx->cur;
                do { ctx->cur--; } while(ctx->cur > ctx->buf && (*ctx->cur & 0xC0) == 0x80);
                for(i = 0; s + i <= ctx->end; i++) ctx->cur[i] = s[i];
                ctx->end -= (uintptr_t)s - (uintptr_t)ctx->cur;
            }
        } else
        if((uint8_t)evt->key[0] >= ' ' && (!evt->key[1] || (evt->key[0] & 0x80)))
            _ui_text_add(ctx, evt->key, strlen(evt->key));
        if(ctx->text->type == UI_CUSTOM && ctx->text->ctrl)
            (*ctx->text->ctrl)(ctx, ctx->text->ex, ctx->text->ey, ctx->text->ew, ctx->text->eh, ctx->text, evt);
    }
}

/**
 * Color picker controller
 */
int _ui_color_ctrl(ui_t *ctx, int x, int y, int w, int h, ui_form_t *form, ui_event_t *evt)
{
    int i, X, Y;
    uint8_t *C;

    if(!ctx || !ctx->screen.buf || !form || !form->ptr || x >= ctx->screen.w || y >= ctx->screen.h || w < 56+256 || h < 16+256 || !evt)
        return UI_ERR_BADINP;

    if(!ctx->buf) {
        if(evt->type != UI_EVT_KEY || evt->key[0] == '\n') {
setcolor:   for(i = 0; i < 16 && ctx->hist[i] != ctx->color; i++) {}
            if(i) memmove(&ctx->hist[1], &ctx->hist[0], (i > 15 ? 15 : i) * sizeof(uint32_t));
            ctx->hist[0] = ctx->color;
            *((uint32_t*)form->ptr) = ctx->color;
        }
        if(ctx->text) ui_backend_hideosk(ctx->bck);
        if(ctx->buf) free(ctx->buf);
        ctx->buf = ctx->scr = ctx->cur = ctx->end = NULL;
        ctx->text = NULL;
        ctx->flags |= UI_CLOSE;
        return UI_OK;
    }
    if(evt->type == UI_EVT_KEY) {
        if(evt->key[0] == '\n') goto setcolor;
        if(ctx->buf && (uintptr_t)ctx->end - (uintptr_t)ctx->buf == 8) {
            for(ctx->color = i = 0; i < 8; i++) {
                ctx->color <<= 4;
                ctx->color |= ctx->buf[i] >= '0' && ctx->buf[i] <= '9' ? ctx->buf[i] - '0' :
                    (ctx->buf[i] >= 'a' && ctx->buf[i] <= 'f' ? ctx->buf[i] - 'a' + 10 : 0);
            }
            _ui_rgb2hsv(ctx->color, &ctx->hue, &ctx->sat, &ctx->val);
        }
        return UI_OK;
    }
    C = (uint8_t*)&ctx->color;
    Y = ctx->mousey - y - form->eh - 8;
    if(evt->type == UI_EVT_MOUSE) {
        if(evt->btn & UI_BTN_RELEASE) { ctx->s1 = ctx->mousex; ctx->s2 = ctx->mousey; ctx->sm = 0; } else
        if(evt->btn & UI_BTN_L) {
            if(ctx->mousex == ctx->s1 && ctx->mousey == ctx->s2) goto setcolor;
            X = ctx->mousex - x - 2;
            if(Y >= 0 && Y < 256) {
                if(X < 16) ctx->sm = 1; else
                if(X >= 20 && X < 36) ctx->sm = 2; else
                if(X >= 38 && X < 38 + 256) ctx->sm = 3; else
                if(X >= 296 && X < 296 + 16) ctx->sm = 4;
            }
        }
    }
    if(ctx->sm) {
        X = ctx->mousex - x - 42; if(X < 0) { X = 0; } if(X > 255) X = 255;
        if(Y < 0) { Y = 0; } if(Y > 255) Y = 255;
        switch(ctx->sm) {
            case 1: ctx->sm = 0; ctx->color = ctx->hist[Y >> 4]; _ui_rgb2hsv(ctx->color, &ctx->hue, &ctx->sat, &ctx->val); break;
            case 2: C[3] = 255 - Y; break;
            case 3: ctx->sat = X; ctx->val = 255 - Y; ctx->color = _ui_hsv2rgb(C[3], ctx->hue, ctx->sat, ctx->val); break;
            case 4: ctx->hue = Y; ctx->color = _ui_hsv2rgb(C[3], ctx->hue, ctx->sat, ctx->val); break;
        }
        sprintf(ctx->buf, "%08x", ctx->color);
    }
    return UI_OK;
}

/**
 * Start color picker
 */
void _ui_color_start(ui_t *ctx, int x, int y, int w, int h, ui_form_t *form)
{
    if(!ctx || !form || form->type != UI_COLOR || !form->ptr) return;

    (void)w;
    ctx->px = x; ctx->py = y; ctx->pw = 42 + 256 + 26; ctx->ph = h + 256 + 16;
    ctx->s1 = ctx->s2 = ctx->sm = 0;
    if((ctx->buf = (char*)realloc(ctx->buf, 16))) {
        ctx->color = *((uint32_t*)form->ptr);
        sprintf(ctx->buf, "%08x", ctx->color);
        _ui_rgb2hsv(ctx->color, &ctx->hue, &ctx->sat, &ctx->val);
        ctx->maxlen = 9;
        ctx->scr = ctx->buf;
        ctx->cur = ctx->end = ctx->buf + 8;
        ctx->popup = ctx->text = form;
        ctx->pe = &_ui_color_ctrl;
        ctx->dr = &_ui_color_popup;
    }
}

/**
 * Get container scrollbars
 */
int _ui_evtscr(ui_t *ctx, int x, int y, ui_form_t *form, ui_event_t *evt)
{
    int b, t;

    if(ctx && form && evt) {
        b = (UI_CONTAINER(form->type) && !(form->flags & UI_NOBORDER)) ? 2 : 0;
        t = form->type == UI_POPUP ? form->value : 0;
        if(form->sh && ctx->mousex < x + form->ew + b - form->m && ctx->mousex >= x + form->ew + b - form->m - ctx->sw &&
          ctx->mousey >= y + form->m + t && ctx->mousey < y + form->m + t + form->sh) {
            if(evt->type == UI_EVT_MOUSE && !(evt->btn & UI_BTN_RELEASE)) {
                ctx->vscr = form;
                ctx->s1 = y + form->m + t;
                ctx->sm = form->mh - form->sh;
                t = _ui_scr(form->sh, form->oy, form->mh, ctx->sw, &b);
                ctx->sb = ctx->mousey >= ctx->s1 + t && ctx->mousey < ctx->s1 + t + b ? ctx->mousey - ctx->s1 - t : b / 2;
                ctx->s2 = ctx->s1 + form->sh - b + ctx->sb;
                ctx->flags |= UI_REFRESH;
            }
            return 1;
        }
        if(form->sw && ctx->mousex >= x + form->m && ctx->mousex < x + form->m + form->sw &&
          ctx->mousey >= y + form->eh + b - form->m - ctx->sh && ctx->mousey < y + form->eh + b - form->m) {
            if(evt->type == UI_EVT_MOUSE && !(evt->btn & UI_BTN_RELEASE)) {
                ctx->hscr = form;
                ctx->s1 = x + form->m;
                ctx->sm = form->mw - form->sw;
                t = _ui_scr(form->sw, form->ox, form->mw, ctx->sh, &b);
                ctx->sb = ctx->mousex >= ctx->s1 + t && ctx->mousex < ctx->s1 + t + b ? ctx->mousex - ctx->s1 - t : b / 2;
                ctx->s2 = ctx->s1 + form->sw - b + ctx->sb;
                ctx->flags |= UI_REFRESH;
            }
            return 1;
        }
    }
    return 0;
}

/**
 * Process events
 */
int _ui_evtproc(ui_t *ctx, int x, int y, int w, int h, ui_form_t *form, int parent, ui_event_t *evt)
{
    ui_form_t *popup;
    int tx, ty, x2, y2, t, b;

    (void)h;
    if(!ctx) return UI_ERR_BADINP;
    if(!form || !evt) return 0;

    for(; form->type != UI_END; form++) {
        if(form->flags & UI_HIDDEN) continue;
        tx = x + form->ex; ty = y + form->ey;
        x2 = parent == UI_MENU ? x + w : tx + form->ew;
        y2 = ty + form->eh;
        if(x2 > x + w) x2 = x + w;
        if(y2 > y + h) y2 = y + h;
        if(ctx->mousex >= tx && ctx->mousex < x2 && ctx->mousey >= ty && ctx->mousey < y2) {
            if(form->type == UI_DIV && !(form->flags & UI_DISABLED)) {
                tx -= form->ox; ty -= form->oy;
                return _ui_evtscr(ctx, tx, ty, form, evt) || _ui_evtproc(ctx, tx, ty, form->ew, form->eh, form->ptr, parent, evt);
            }
            ctx->hover = form;
            if(form->flags & UI_DISABLED) continue;
            if(form->type == UI_CUSTOM) {
                if(form->ctrl) {
                    ctx->px = tx; ctx->py = ty; ctx->pw = x2 - tx; ctx->ph = y2 - ty;
                    ctx->pe = form->ctrl;
                    (*form->ctrl)(ctx, tx, ty, ctx->pw, ctx->ph, form, evt);
                    ctx->flags |= UI_REFRESH;
                }
                break;
            } else
            if(form->type == UI_BUTTON || form->type == UI_BTNTGL) {
                if(evt->type == UI_EVT_MOUSE && (evt->btn & (UI_BTN_L | UI_BTN_RELEASE))) {
                    if(evt->btn & UI_BTN_L) ctx->pressed = form; else
                    if((evt->btn & UI_BTN_RELEASE) && ctx->pressed == form) {
                        if(form->type == UI_BTNTGL) {
                            popup = form->ptr && UI_CONTAINER(((ui_form_t*)form->ptr)->type) ? (ui_form_t*)form->ptr : &ctx->form[form->value];
                            goto toggle;
                        } else
                        if(form->ptr) *((int*)form->ptr) = form->value;
                    }
                    ctx->flags |= UI_REFRESH;
                    return 1;
                }
                break;
            } else
            if(evt->type == UI_EVT_MOUSE && (evt->btn & (UI_BTN_U | UI_BTN_D) && (form->type >= UI_SELECT && form->type <= UI_INT64))) {
                if((form->type <= UI_OPTION && evt->btn & UI_BTN_D) || (evt->btn & UI_BTN_U)) _ui_inc(form); else _ui_dec(form);
                ctx->flags |= UI_REFRESH;
                return 1;
            } else
            if(form->type == UI_SELECT) {
                if(evt->type == UI_EVT_MOUSE && (evt->btn & (UI_BTN_L | UI_BTN_RELEASE))) {
                    if(evt->btn & UI_BTN_L) ctx->pressed = form; else
                    if((evt->btn & UI_BTN_RELEASE) && ctx->pressed == form && form->ptr)
                        _ui_select_start(ctx, tx, ty, form->ew, form->eh, form);
                    ctx->flags |= UI_REFRESH;
                    return 1;
                }
                break;
            } else
            if(evt->type == UI_EVT_MOUSE && (evt->btn & UI_BTN_L)) {
                switch(form->type) {
                    case UI_TOGGLE:
                        popup = !form->value && UI_CONTAINER(form[1].type) ? &form[1] : &ctx->form[form->value];
toggle:                 switch(popup->type) {
                            case UI_MENU:
                                /* note: could be ctx->menu == popups! */
                                if(popup->flags & UI_HIDDEN) {
                                    if(ctx->menu) ctx->menu->flags |= UI_HIDDEN;
                                    ctx->menu = popup;
                                    popup->flags &= ~UI_HIDDEN;
                                } else {
                                    if(ctx->menu) ctx->menu->flags |= UI_HIDDEN;
                                    ctx->menu = NULL;
                                    popup->flags |= UI_HIDDEN;
                                }
                            break;
                            case UI_POPUP: popup->flags ^= UI_HIDDEN; break;
                            case UI_DIV: popup->flags ^= UI_HIDDEN; ctx->flags |= UI_RECALC; break;
                        }
                        if(!(popup->flags & UI_HIDDEN) && ctx->popups[0])
                            popup->min = ctx->popups[0]->min + 1;
                    break;
                    case UI_BTNICN:
                    case UI_CHECK:
                        if(form->ptr) *((int*)form->ptr) ^= (form->value ? form->value : 1);
                    break;
                    case UI_RADIO:
                        if(form->ptr) *((int*)form->ptr) = form->value;
                        if(ctx->menu) {
                            ctx->menu->flags |= UI_HIDDEN;
                            ctx->menu = NULL;
                        }
                    break;
                    case UI_SLIDER:
                        ctx->hscr = form;
                        ctx->s1 = tx + 4; ctx->s2 = tx + form->ew - 5;
                        ctx->sm = form->max - form->min; ctx->sb = 0;
                    break;
                    case UI_HSCRBAR:
                        ctx->hscr = form;
                        ctx->sm = form->max - form->ew;
                        t = _ui_scr(form->ew, form->ptr ? *((int*)form->ptr) : 0, form->max, ctx->sh, &b);
                        ctx->sb = ctx->mousex >= tx + t && ctx->mousex < tx + t + b ? ctx->mousex - tx - t : b / 2;
                        ctx->s1 = tx; ctx->s2 = tx + form->ew - b + ctx->sb;
                    break;
                    case UI_VSCRBAR:
                        ctx->vscr = form;
                        ctx->sm = form->max - form->eh;
                        t = _ui_scr(form->eh, form->ptr ? *((int*)form->ptr) : 0, form->max, ctx->sw, &b);
                        ctx->sb = ctx->mousey >= ty + t && ctx->mousey < ty + t + b ? ctx->mousey - ty - t : b / 2;
                        ctx->s1 = ty; ctx->s2 = ty + form->eh - b + ctx->sb;
                    break;
                    case UI_TXTINP:
                        if(form->ptr && form->max > 0) {
                            ((char*)form->ptr)[form->max - 1] = 0;
                            _ui_text_start(ctx, tx, ty, x2 - tx, y2 - ty, form, form->ptr, form->max);
                        }
                    break;
                    case UI_OPTION: case UI_INT8: case UI_INT16: case UI_INT32: case UI_INT64: case UI_FLOAT:
                        ctx->maxlen = 0;
                        if(form->ptr) {
                            if(ctx->mousex < tx + form->eh) { ctx->pressed = form; ctx->maxlen = 1; _ui_dec(form); }
                            if(ctx->mousex >= x2 - form->eh) { ctx->pressed = form; ctx->maxlen = 2; _ui_inc(form); }
                        }
                    break;
                    case UI_IMAGE: case UI_ICON: if(form->ptr) *((int*)form->ptr) = form->value; break;
                    case UI_COLOR: _ui_color_start(ctx, tx, ty, form->ew, form->eh, form); break;
                }
                ctx->flags |= UI_REFRESH;
                return 1;
            }
            break;
        }
    }
    return 0;
}

/**
 * Initialize the main UI context
 * Gets a string array with translatable UTF-8 strings, window size and a window icon
 */
int ui_init(ui_t *ctx, int txtc, char **txtv, int w, int h, ui_image_t *icon)
{
    if(!ctx || txtc < 1 || !txtv || !*txtv) return UI_ERR_BADINP;

    memset(ctx, 0, sizeof(ui_t));
    ctx->txtc = txtc;
    ctx->txtv = txtv;
#ifdef UI_DEFAULTFONT
    ctx->fnt = ui_psf2_default;
    ctx->bbox = &ui_psf2_bbox; ctx->draw = &ui_psf2_draw;
#else
#ifdef UI_SETFONTHOOK
    ui_fonthook(ctx, UI_SETFONTHOOK);
#endif
#endif
    ctx->sw = ctx->sh = 10;
    ui_theme(ctx, (uint32_t*)&ui_default);
    _ui_resize(ctx, w, h);
    return ui_backend_init(ctx, txtv[0], w, h, icon);
}

/**
 * Toggle fullscreen mode
 */
int ui_fullscreen(ui_t *ctx)
{
    return ctx ? ui_backend_fullscreen(ctx->bck) : UI_ERR_BADINP;
}

/**
 * Return a backend specific window handle
 */
void *ui_getwindow(ui_t *ctx)
{
    return ctx ? ui_backend_getwindow(ctx->bck) : NULL;
}

/**
 * Main event loop
 * Returns event on success, NULL if you should exit the loop
 */
ui_event_t *ui_event(ui_t *ctx, ui_form_t *form)
{
    static ui_event_t empty = { 0 };
    ui_event_t *ret = &empty, *evt = &empty;
    ui_form_t *lasthover;
    int i, j, k, l, clk;

    if(ctx) {
        lasthover = ctx->hover;
        ctx->hover = NULL;
        ctx->flags &= ~UI_DONE;
        /* pump events */
        if(ui_backend_event(ctx->bck)) return NULL;
        if(ctx->tail != ctx->head) {
            ret = evt = &ctx->events[ctx->tail++];
            ctx->tail %= UI_MAXEVENTS;
        }
        if(!ctx->drag && !ctx->resize && !ctx->vscr && !ctx->hscr && !ctx->text && !ctx->popup) {
            /* recalculate positions */
            if(form && ctx->form != form) {
                ctx->form = form;
                _ui_recalc(ctx, 0, 0, ctx->screen.w, ctx->screen.h, 0, ctx->form, NULL, NULL);
            }
            /* check events for popups, in reverse z order */
            clk = ret->type == UI_EVT_MOUSE && !(ret->btn & UI_BTN_RELEASE);
            for(i = 0; i < ctx->numpopups; i++) {
                if(ctx->mousex >= ctx->popups[i]->ex && ctx->mousex < ctx->popups[i]->ex + ctx->popups[i]->ew &&
                   ctx->mousey >= ctx->popups[i]->ey && ctx->mousey < ctx->popups[i]->ey + ctx->popups[i]->eh) {
                    if(clk) {
                        ret = &empty;
                        /* a popup or menu clicked, handle z order, bring to foreground */
                        if(i) {
                            ctx->popups[i]->min = ctx->popups[0]->min + 1;
                            ctx->flags |= UI_REFRESH;
                        }
                        /* popup header clicked */
                        if(ctx->popups[i]->type == UI_POPUP && (ctx->popups[i]->flags & UI_DRAGGABLE) &&
                          ctx->mousey < ctx->popups[i]->ey + ctx->popups[i]->value) {
                            if(ctx->mousex > ctx->popups[i]->ex + ctx->popups[i]->ew - ctx->popups[i]->value) {
                                /* close button */
                                ctx->popups[i]->flags |= UI_HIDDEN;
                                ctx->flags |= UI_REFRESH;
                            } else {
                                /* drag popup */
                                ctx->drag = ctx->popups[i];
                                ctx->dx = ctx->mousex - ctx->popups[i]->ex;
                                ctx->dy = ctx->mousey - ctx->popups[i]->ey;
                            }
                            break;
                        } else
                        if(ctx->popups[i]->type == UI_POPUP && (ctx->popups[i]->flags & UI_RESIZABLE) &&
                          ctx->mousex > ctx->popups[i]->ex + ctx->popups[i]->ew - 7 &&
                          ctx->mousey > ctx->popups[i]->ey + ctx->popups[i]->eh - 7) {
                            /* resize corner clicked */
                            ctx->resize = ctx->popups[i];
                            ctx->dx = ctx->popups[i]->ex + ctx->popups[i]->ew - ctx->mousex;
                            ctx->dy = ctx->popups[i]->ey + ctx->popups[i]->eh - ctx->mousey;
                            break;
                        }
                    }
                    /* scrollbars clicked */
                    if(_ui_evtscr(ctx, ctx->popups[i]->ex, ctx->popups[i]->ey, ctx->popups[i], evt))
                        break;
                    /* bubble event down to its children */
                    if(!_ui_evtproc(ctx, ctx->popups[i]->ex + ctx->popups[i]->m - ctx->popups[i]->ox,
                      ctx->popups[i]->ey + ctx->popups[i]->m + ctx->popups[i]->value - ctx->popups[i]->oy,
                      ctx->popups[i]->ew - 2 * ctx->popups[i]->m - (ctx->popups[i]->sh ? ctx->sw : 0),
                      ctx->popups[i]->eh - 2 * ctx->popups[i]->m - (ctx->popups[i]->sw ? ctx->sh : 0),
                      ctx->popups[i]->ptr, ctx->popups[i]->type, evt) && evt->type == UI_EVT_MOUSE) {
                        /* if no children caught the wheel event, try to scroll the popup */
                        k = ctx->popups[i]->eh / 10; if(k < 4) k = 4;
                        l = ctx->popups[i]->ew / 10; if(l < 4) l = 4;
                        if(evt->btn & UI_BTN_U) ctx->popups[i]->oy -= k; else
                        if(evt->btn & UI_BTN_D) ctx->popups[i]->oy += k; else
                        if(evt->btn & UI_BTN_A) ctx->popups[i]->ox -= l; else
                        if(evt->btn & UI_BTN_B) ctx->popups[i]->ox += l;
                        if(ctx->popups[i]->oy > ctx->popups[i]->mh) ctx->popups[i]->oy = ctx->popups[i]->mh;
                        if(ctx->popups[i]->oy < 0) ctx->popups[i]->oy = 0;
                        if(ctx->popups[i]->ox > ctx->popups[i]->mw) ctx->popups[i]->ox = ctx->popups[i]->mw;
                        if(ctx->popups[i]->ox < 0) ctx->popups[i]->ox = 0;
                        ctx->flags |= UI_REFRESH;
                        ret = &empty;
                    }
                    break;
                }
            }
            /* if menu active and clicked outside or Esc pressed */
            if(ctx->menu && (clk || (evt->type == UI_EVT_KEY && evt->key[0] == '\x1b'))) {
                ctx->menu->flags |= UI_HIDDEN;
                ctx->menu = NULL;
                ctx->flags |= UI_REFRESH;
                ret = &empty;
                i = ctx->numpopups;
            }
            /* check if we need to swallow this event */
            if(i >= ctx->numpopups && _ui_evtproc(ctx, 0, 0, ctx->screen.w, ctx->screen.h, form, UI_END, ret) && ret->type == UI_EVT_MOUSE)
                ret = &empty;
        }
        /* if a button was pressed, but released outside */
        if((ctx->pressed || ctx->drag || ctx->resize || ctx->vscr || ctx->hscr) &&
          evt->type == UI_EVT_MOUSE && (evt->btn & UI_BTN_RELEASE)) {
            ctx->pressed = ctx->drag = ctx->resize = ctx->vscr = ctx->hscr = NULL;
            ctx->flags |= UI_REFRESH;
            ret = &empty;
        }
        /* handle "window" operations */
        if(ctx->drag) {
            i = ctx->mousex - ctx->dx; if(i < 1) { i = 1; } clk = ctx->screen.w - ctx->drag->ew - 1; if(i > clk) i = clk;
            j = ctx->mousey - ctx->dy; if(j < 1) { j = 1; } clk = ctx->screen.h - ctx->drag->eh - 1; if(j > clk) j = clk;
            ctx->drag->align = 0;
            ctx->drag->x = UI_ABS(i);
            ctx->drag->y = UI_ABS(j);
            ctx->drag->ex = i;
            ctx->drag->ey = j;
            ctx->flags |= UI_REFRESH;
        }
        if(ctx->resize) {
            k = ctx->resize->sh ? ctx->sw : 0;
            l = ctx->resize->sw ? ctx->sh : 0;
            i = ctx->mousex - ctx->resize->ex + ctx->dx;
            j = ctx->mousey - ctx->resize->ey + ctx->dy;
            clk = 8 + 2 * ctx->resize->m + k; if(i < clk) i = clk;
            clk = 8 + ctx->resize->value + 2 * ctx->resize->m + l; if(j < clk) j = clk;
            _ui_recalc(ctx, 2, 2, i - 2 * ctx->resize->m - k, j - 2 * ctx->resize->m - l, ctx->resize->p, ctx->resize->ptr,
                NULL, NULL);
            ctx->resize->align = 0;
            ctx->resize->h = ctx->resize->ew = i;
            ctx->resize->h = ctx->resize->eh = j;
            ctx->flags |= UI_REFRESH;
        }
        if((ctx->vscr || ctx->hscr) && ctx->sm > 0) {
            i = (ctx->vscr ? ctx->mousey : ctx->mousex) - ctx->sb + 1;
            if(i > ctx->s2) i = ctx->s2;
            i = i > ctx->s1 ? i - ctx->s1 : 0;
            j = ctx->s2 - ctx->s1 - ctx->sb;
            k = i * ctx->sm / (j < 1 ? 1 : j);
            if(k > ctx->sm) k = ctx->sm;
            if(ctx->hscr) {
                if(ctx->hscr->type == UI_SLIDER) {
                    k += ctx->hscr->min;
                    if(ctx->hscr->inc > 0) k -= k % ctx->hscr->inc;
                    if(ctx->hscr->ptr) *((int*)ctx->hscr->ptr) = k;
                } else
                if(ctx->hscr->type == UI_HSCRBAR) {
                    if(ctx->hscr->ptr) *((int*)ctx->hscr->ptr) = k;
                } else
                    ctx->hscr->ox = k;
            } else {
                if(ctx->vscr->type == UI_VSCRBAR) {
                    if(ctx->vscr->ptr) *((int*)ctx->vscr->ptr) = k;
                } else
                    ctx->vscr->oy = k;
            }
            ctx->flags |= UI_REFRESH;
        }
        /* if text input active */
        if(ctx->text) {
            _ui_text_ctrl(ctx, evt);
            ctx->flags |= UI_REFRESH;
            ret = &empty;
        }
        /* if custom popup active */
        if(ctx->popup) {
            if(!ctx->pe || (ctx->flags & UI_CLOSE) || (evt->type == UI_EVT_MOUSE && !(evt->btn & UI_BTN_RELEASE) &&
              (ctx->mousex < ctx->px || ctx->mousex >= ctx->px + ctx->pw ||
               ctx->mousey < ctx->py || ctx->mousey >= ctx->py + ctx->ph))) {
close:          if(ctx->popup->type == UI_CUSTOM && ctx->popup->fini)
                    (*ctx->popup->fini)(ctx, ctx->popup);
                ctx->flags |= UI_REFRESH;
                ctx->popup = NULL;
                ctx->pe = NULL;
                ctx->dr = NULL;
            } else
            if(ctx->pe) {
                (*ctx->pe)(ctx, ctx->px, ctx->py, ctx->pw, ctx->ph, ctx->popup, evt);
                if(ctx->flags & UI_CLOSE) goto close;
                ctx->flags |= UI_REFRESH;
            }
            ret = &empty;
        }
        ctx->flags &= ~UI_CLOSE;
        /* recalculate positions */
        if(ctx->flags & UI_RECALC) {
            _ui_recalc(ctx, 0, 0, ctx->screen.w, ctx->screen.h, 0, ctx->form, NULL, NULL);
            ctx->flags &= ~UI_RECALC;
        }
        /* if we have to redraw the form */
        if((ctx->flags & UI_REFRESH) || (ctx->hover != lasthover)) {
            _ui_redraw(ctx, form);
            ctx->lastx = -1;
            ctx->flags &= ~UI_REFRESH;
        }
        /* display software cursor */
        if(ctx->mouse.buf && ctx->mouse.w > 0 && (ctx->lastx != ctx->mousex || ctx->lasty != ctx->mousey)) {
            ctx->cx0 = ctx->cy0 = 0; ctx->cx1 = ctx->screen.w; ctx->cy1 = ctx->screen.h;
            if(ctx->lastx != -1)
                _ui_copy(&ctx->screen, ctx->lastx - ctx->mouse.w / 2, ctx->lasty - ctx->mouse.h / 2,
                    ctx->mouse.w, ctx->mouse.h, &ctx->mouse, 0, 0);
            ctx->lastx = ctx->mousex; ctx->lasty = ctx->mousey;
            _ui_copy(&ctx->mouse, 0, 0, ctx->mouse.w, ctx->mouse.h, &ctx->screen,
                ctx->mousex - ctx->mouse.w / 2, ctx->mousey - ctx->mouse.h / 2);
            _ui_blit(ctx, ctx->mousex - ctx->mouse.w / 2, ctx->mousey - ctx->mouse.h / 2,
                ctx->mouse.w, ctx->mouse.h, &ctx->skin[UI_CURSOR], 0, 0, 0);
        }
        /* put the (potentially updated) UI layer on screen */
        ui_backend_redraw(ctx->bck);
    }
    return ret;
}

/**
 * Free all UI resources
 */
int _ui_free(ui_t *ctx, ui_form_t *form)
{
    if(!ctx || !form) return UI_ERR_BADINP;
    for(; form->type != UI_END; form++) {
        if(form->type == UI_CUSTOM && form->fini)
            (*form->fini)(ctx, form);
        if(UI_CONTAINER(form->type))
            _ui_free(ctx, form->ptr);
    }
    return UI_OK;
}
int ui_free(ui_t *ctx)
{
    if(!ctx) return UI_ERR_BADINP;

    _ui_free(ctx, ctx->form);
    ui_backend_free(ctx->bck);
    if(ctx->screen.buf) free(ctx->screen.buf);
    if(ctx->mouse.buf) free(ctx->mouse.buf);
    if(ctx->skinbuf) free(ctx->skinbuf);
    memset(ctx, 0, sizeof(ui_t));
    return UI_OK;
}

#ifdef  __cplusplus
}
#endif

#endif /* UI_IMPLEMENTATION */

#endif /* UI_H */
