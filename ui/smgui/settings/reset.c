#include "settings_internal.h"

bs_settings_page bs_page_reset_create(bs_page_host *host)
{
    return bs_stub_page_create(host, BS_SMGUI_PAGE_RESET, "Reset",
        "Reset preferences to defaults mock.");
}
