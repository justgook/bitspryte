// Canonical registry of application actions.
// Keep action identifiers here so commands are easy to discover and review.
package actions

Kind :: enum {
	Open_Settings,
	Close_Active_Window,
	Export_PNG,
	Clear_Canvas,
	Set_Theme,
}

Source :: enum {
	Application,
	Keyboard,
	Native_Menu,
	User_Interface,
	Script,
}
