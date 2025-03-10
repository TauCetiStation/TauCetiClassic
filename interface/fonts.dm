/// A font datum, it exists to define a custom font to use in a span style later.
/datum/font
	/// Font name, just so people know what to put in their span style.
	var/name
	/// The font file we link to.
	var/font_family

/// Base font
/datum/font/grand9k
	name = "Grand9K Pixel"
	font_family = 'interface/fonts/Grand9K_Pixel_Rus.ttf'
