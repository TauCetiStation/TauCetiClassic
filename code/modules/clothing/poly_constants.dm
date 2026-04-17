// Polychromic jumpsuit system — shared constants used across clothing, prefs, and UI.

/// Human-readable display names for all poly_style values.
var/global/list/poly_style_display = list(
	"job"    = "Job Default",
	"std"    = "Standard",
	"std_w"  = "Poly-Standard",
	"belt"   = "Belt",
	"belt_w" = "Poly-Belt",
	"turt"   = "Turtleneck",
	"turt_w" = "Poly-Turtleneck"
)

/// Human-readable display names for all poly_pattern values.
var/global/list/poly_pattern_display = list(
	"1"    = "Vey Med",
	"2"    = "Einstein Engines",
	"3"    = "Solarian",
	"4"    = "Nanotrasen",
	"5"    = "Hephaestus Industries",
	"turt" = "Turtleneck"
)

/// All valid poly_style values (used for savefile validation).
var/global/list/poly_valid_styles = list("job", "std", "std_w", "belt", "belt_w", "turt", "turt_w")

/// Styles that use a white (greyscale) sprite base and support base color tinting.
var/global/list/poly_white_base_styles = list("std_w", "belt_w", "turt_w")

/// Returns TRUE if style uses the white sprite base (i.e. has a "_w" suffix).
/proc/is_poly_white_base(style)
	return (style in poly_white_base_styles)
