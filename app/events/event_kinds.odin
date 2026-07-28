// Canonical registry of application events.
// Events describe facts that already happened; add new identifiers here.
package events

Kind :: enum {
	Settings_Opened,
	Active_Window_Closed,
	PNG_Exported,
	PNG_Export_Failed,
	Canvas_Cleared,
	Theme_Changed,
}
