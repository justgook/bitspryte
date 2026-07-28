#include "settings_internal.h"

bs_settings_page bs_page_guides_and_slices_create(bs_page_host *host)
{
    return bs_stub_page_create(host, BS_SMGUI_PAGE_GUIDES_AND_SLICES,
        "Guides & Slices", "Guide and slice behavior mock.");
}
