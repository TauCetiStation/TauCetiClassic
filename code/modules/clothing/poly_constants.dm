// Polychromic jumpsuit system — shared constants used across clothing, prefs, and UI.
// Style/pattern key #defines live in code/__DEFINES/clothing.dm (included before consumers).

var/global/list/poly_style_display = list(
	POLY_STYLE_JOB  = "Job Default",
	POLY_STYLE_STD  = "Poly-Standard",
	POLY_STYLE_BELT = "Poly-Belt",
	POLY_STYLE_TURT = "Poly-Turtleneck"
)

var/global/list/poly_pattern_display = list(
	"1"               = "Vey Med",
	"2"               = "Einstein Engines",
	"3"               = "Solarian",
	"4"               = "Nanotrasen",
	"5"               = "Hephaestus Industries",
	POLY_PATTERN_TURT = "Turtleneck"
)

var/global/list/poly_valid_styles = list(POLY_STYLE_JOB, POLY_STYLE_STD, POLY_STYLE_BELT, POLY_STYLE_TURT)

// White-base styles support base color tinting (the "_w" greyscale sprites).
var/global/list/poly_white_base_styles = list(POLY_STYLE_STD, POLY_STYLE_BELT, POLY_STYLE_TURT)

/proc/is_poly_white_base(style)
	return (style in poly_white_base_styles)

/proc/sanitize_poly_color(color, default = "#ffffff")
	for(var/key in poly_color_palette)
		if(poly_color_palette[key] == color)
			return color
	return default
