// This is a mapping from JS keys to Byond - ref: https://keycode.info/
var/global/list/_kbMap = list(
	"UP" = "North",
	"RIGHT" = "East",
	"DOWN" = "South",
	"LEFT" = "West",
	"INSERT" = "Insert",
	"HOME" = "Northwest",
	"PAGEUP" = "Northeast",
	"DEL" = "Delete",
	"END" = "Southwest",
	"PAGEDOWN" = "Southeast",
	"SPACEBAR" = "Space",
	"ALT" = "Alt",
	"SHIFT" = "Shift",
	"CONTROL" = "Ctrl"
	)

// Without alt, shift, ctrl and etc because its not necessary
var/global/list/_kbMap_reverse = list(
	"North" = "Up",
	"East" = "Right",
	"South" = "Down",
	"West" = "Left",
	"Southeast" = "PageDown",
	"Northeast" = "PageUp",
	"Northwest" = "Home",
	"Southwest" = "End",
	)

// list of valid byond keyboard keys based on https://www.byond.com/docs/ref/#/{skin}/macros
// + some missing from the table that were found experimentally
// not all of them are mapped with js keys and available to bind currently
var/global/list/byond_valid_keys = list (
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", 
	"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
	"`", "-", "=", "\\",
	"\[", "\]", ";", "'", ",", ".", "/",
	"Numpad0", "Numpad1", "Numpad2", "Numpad3", "Numpad4", "Numpad5", "Numpad6", "Numpad7", "Numpad8", "Numpad9",
	"North", "South", "East", "West", "Northwest", "Southwest", "Northeast", "Southeast",
	"Center", "Return", "Escape", "Tab", "Space", "Back", "Insert", "Delete", "Pause", "Snapshot", 
	"LWin", "RWin", "Apps",
	"Multiply", "Add", "Subtract", "Divide", "Separator",
	"Shift", "Ctrl", "Alt",
	"VolumeMute", "VolumeUp", "VolumeDown", "MediaPlayPause", "MediaStop", "MediaNext", "MediaPrev",
	)

// Converts (some) browser keycodes to BYOND keycodes.
/proc/browser_keycode_to_byond(keycode)
	keycode = text2num(keycode)
	switch(keycode)
		// letters and numbers
		if(65 to 90, 48 to 57)
			return ascii2text(keycode)
		if(17)
			return "Ctrl"
		if(18)
			return "Alt"
		if(16)
			return "Shift"
		if(37)
			return "West"
		if(38)
			return "North"
		if(39)
			return "East"
		if(40)
			return "South"
		if(45)
			return "Insert"
		if(46)
			return "Delete"
		if(36)
			return "Northwest"
		if(35)
			return "Southwest"
		if(33)
			return "Northeast"
		if(34)
			return "Southeast"
		if(112 to 123)
			return "F[keycode-111]"
		if(96 to 105)
			return "Numpad[keycode-96]"
		if(188)
			return ","
		if(190)
			return "."
		if(189)
			return "-"
