#include "settings_internal.h"

bs_settings_page bs_page_selection_create(bs_page_host *host)
{
    return bs_stub_page_create(host, BS_SMGUI_PAGE_SELECTION, "Selection",
        "Selection behavior mock.");
}
