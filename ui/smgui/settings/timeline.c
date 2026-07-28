#include "settings_internal.h"

bs_settings_page bs_page_timeline_create(bs_page_host *host)
{
    return bs_stub_page_create(host, BS_SMGUI_PAGE_TIMELINE, "Timeline",
        "Animation timeline preferences mock.");
}
