// BYOND lower-cases color values, and thus we do so as well to ensure atom.color == COLOR_X will work correctly

#define COLOR_INPUT_DISABLED            "#f0f0f0"
#define COLOR_INPUT_ENABLED             "#d3b5b5"

#define COLOR_BLACK                     "#000000"
#define COLOR_NAVY_BLUE                 "#000080"
#define COLOR_ADMIRAL_BLUE              "#051094"
#define COLOR_INDIGO                    "#281e5d"
#define COLOR_GREEN                     "#008000"
#define COLOR_CROCODILE                 "#607d3b"
#define COLOR_SEAWEED                   "#354a21"
#define COLOR_DARK_GRAY                 "#404040"
#define COLOR_MAROON                    "#800000"
#define COLOR_PURPLE                    "#800080"
#define COLOR_DARK_PURPLE               "#6b2b63"
#define COLOR_VIOLET                    "#9933ff"
#define COLOR_OLIVE                     "#808000"
#define COLOR_BROWN_ORANGE              "#824b28"
#define COLOR_DARK_ORANGE               "#b95a00"
#define COLOR_GRAY40                    "#666666"
#define COLOR_SEDONA                    "#cc6600"
#define COLOR_DARK_BROWN                "#917448"
#define COLOR_BLUE                      "#0000ff"
#define COLOR_DEEP_SKY_BLUE             "#00e1ff"
#define COLOR_LIME                      "#00ff00"
#define COLOR_CYAN                      "#00ffff"
#define COLOR_TEAL                      "#33cccc"
#define COLOR_RED                       "#ff0000"
#define COLOR_CRIMSON                   "#dc143c"
#define COLOR_CRIMSON_RED               "#990000"
#define COLOR_PINK                      "#ff00ff"
#define COLOR_ROSE_PINK                 "#ffc0cb"
#define COLOR_LIGHT_PINK                "#ff87ff"
#define COLOR_ORANGE                    "#ff9900"
#define COLOR_TIGER                     "#fc6a03"
#define COLOR_YELLOW                    "#ffff00"
#define COLOR_GOLD                      "#d4af37"
#define COLOR_GRAY                      "#808080"
#define COLOR_RED_GRAY                  "#aa5f61"
#define COLOR_BROWN                     "#b19664"
#define COLOR_GREEN_GRAY                "#8daf6a"
#define COLOR_BLUE_GRAY                 "#6a97b0"
#define COLOR_SUN                       "#ec8b2f"
#define COLOR_PURPLE_GRAY               "#a2819e"
#define COLOR_BLUE_LIGHT                "#33ccff"
#define COLOR_RED_LIGHT                 "#ff3333"
#define COLOR_BEIGE                     "#ceb689"
#define COLOR_PALE_GREEN_GRAY           "#aed18b"
#define COLOR_PALE_RED_GRAY             "#cc9090"
#define COLOR_PALE_PURPLE_GRAY          "#bda2ba"
#define COLOR_PALE_BLUE_GRAY            "#8bbbd5"
#define COLOR_LUMINOL                   "#66ffff"
#define COLOR_SILVER                    "#c0c0c0"
#define COLOR_GRAY80                    "#cccccc"
#define COLOR_OFF_WHITE                 "#eeeeee"
#define COLOR_WHITE                     "#ffffff"
#define COLOR_NT_RED                    "#9d2300"
#define COLOR_BOTTLE_GREEN              "#1f6b4f"
#define COLOR_PALE_BTL_GREEN            "#57967f"
#define COLOR_GUNMETAL                  "#545c68"
#define COLOR_MUZZLE_FLASH              "#ffffb2"
#define COLOR_CHESTNUT                  "#996633"
#define COLOR_BEASTY_BROWN              "#663300"
#define COLOR_WHEAT                     "#ffff99"
#define COLOR_CYAN_BLUE                 "#3366cc"
#define COLOR_LIGHT_CYAN                "#66ccff"
#define COLOR_PAKISTAN_GREEN            "#006600"
#define COLOR_HULL                      "#436b8e"
#define COLOR_AMBER                     "#ffbf00"
#define COLOR_COMMAND_BLUE              "#46698c"
#define COLOR_SKY_BLUE                  "#5ca1cc"
#define COLOR_PALE_ORANGE               "#b88a3b"
#define COLOR_CIVIE_GREEN               "#b7f27d"
#define COLOR_TITANIUM                  "#d1e6e3"
#define COLOR_DARK_GUNMETAL             "#4c535b"
#define COLOR_ADAMANTINE                "#269999"
#define COLOR_HALF_TRANSPARENT_BLACK    "#0000007A"

#define	PIPE_COLOR_GREY		"#ffffff"	// yes white is grey
#define	PIPE_COLOR_RED		"#ff0000"
#define	PIPE_COLOR_BLUE		"#0000ff"
#define	PIPE_COLOR_CYAN		"#00ffff"
#define	PIPE_COLOR_GREEN	"#00ff00"
#define	PIPE_COLOR_YELLOW	"#ffcc00"
#define	PIPE_COLOR_BLACK	"#444444"
#define	PIPE_COLOR_ORANGE	"#b95a00"

//Some defines to generalise colours used in lighting.
//Important note on colors. Colors can end up significantly different from the basic html picture, especially when saturated
#define LIGHT_COLOR_WHITE      "#ffffff"

//These ones aren't a direct colour like the ones above, because nothing would fit
#define LIGHT_COLOR_FIRE         "#faa019" //Warm orange color, leaning strongly towards yellow. rgb(250, 160, 25)
#define LIGHT_COLOR_FIREPLACE    "#f07f13"
#define LIGHT_COLOR_FLARE        "#fa644b" //Bright, non-saturated red. Leaning slightly towards pink for visibility. rgb(250, 100, 75)
#define LIGHT_COLOR_GHOST_CANDLE "#a2fad1" // Used by ghost candles. rgb(162, 250, 209)
#define LIGHT_COLOR_PLASMA       "#2be4b8" // Used in plasma gun. rgb(43, 228, 184)
#define LIGHT_COLOR_PLASMA_OC    "#e88893" // Used in plasma gun overcharge mode. rgb(232, 136, 147)
#define LIGHT_COLOR_LIGHTNING	 "#5eacb6" // Used in lightning bolt projectiles
#define LIGHT_COLOR_NUKE_OPS      "#00f397" // Used in nuclear operatives related things

//Human organ color mods
#define HULK_SKIN_TONE rgb(48, 224, 40) // human
#define HULK_SKIN_COLOR RGB_CONTRAST(0, 180, 60) // xenos
#define NECROSIS_COLOR_MOD list(0.33,0.33,0.33, 0.59,0.59,0.59, 0.11,0.11,0.11)

// Slime color matrices. Used for /datum/component/mob_modifier-s.
#define SLIME_COLOR(r, g, b) list( \
	0.3, 0.0, 0.0, 0.0, \
	0.0, 0.3, 0.0, 0.0, \
	0.0, 0.0, 0.3, 0.0, \
	0.0, 0.0, 0.0, 0.8, \
	r, g, b, 0.0, \
)

#define SLIME_COLOR_RED SLIME_COLOR(0.5, 0.2, 0.3)
#define SLIME_COLOR_GREEN SLIME_COLOR(0.2, 0.5, 0.2)
#define SLIME_COLOR_BLUE SLIME_COLOR(0.2, 0.2, 0.5)
#define SLIME_COLOR_YELLOW SLIME_COLOR(0.5, 0.5, 0.2)
#define SLIME_COLOR_CYAN SLIME_COLOR(0.2, 0.5, 0.5)

#define SADNESS_COLOR(amount) list( \
	0.3 + 0.7 * (1.0 - amount), \
	0.3 - 0.3 * (1.0 - amount), \
	0.2 - 0.2 * (1.0 - amount), \
	0.7 - 0.7 * (1.0 - amount), \
	0.6 + 0.4 * (1.0 - amount), \
	0.5 - 0.5 * (1.0 - amount), \
	0.1 - 0.1 * (1.0 - amount), \
	0.1 - 0.1 * (1.0 - amount), \
	0.1 + 0.9 * (1.0 - amount), \
	0.0, \
	0.0, \
	0.0 \
)


// FILTER EFFECTS
/* #define EFFECT_FILTER 	list(1, 0, 0, 0, \
                                 0, 1, 0, 0, \
                                 0, 0, 1, 0, \
                                 0, 0, 0, 1, \
                                 0, 0, 0, 0) */

#define LOMO_FILTER  list(1.6,  0.1,  0.95, 0, \
                         -0.2,  0.7,  0,    0, \
                          0.2,  0.2, -0.35, 0.5, \
                          0,    0,   -0.35, 1, \
                          0,    0,    0,    0)

#define POSTERIZATION_FILTER   list(5,   -2.5, -2.5, 0, \
                                   -2.5,  5,   -2.5, 0, \
                                   -2.5, -2.5,  5,   0, \
                                    0,    0,    0,   1, \
                                    0,    0,    0,   0)


#define GRAYSCALE_FILTER    list(0.33, 0.33, 0.33, 0, \
                                 0.59, 0.59, 0.59, 0, \
                                 0.11, 0.11, 0.11, 0, \
                                 0,    0,    0,    1, \
                                 0,    0,    0,    0)

#define INVERT_FILTER  list(-1, 0, 0, 0, \
                             0,-1, 0, 0, \
                             0, 0,-1, 0, \
                             0, 0, 0, 1, \
                             1, 1, 1, 0)

#define SEPIA_FILTER    list(0.393, 0.349, 0.272, 0, \
                             0.769, 0.686, 0.534, 0, \
                             0.189, 0.168, 0.131, 0, \
                             0,     0,     0,     1, \
                             0,     0,     0,     0)

#define BLACKANDWHITE_FILTER   list(1.5,  1.5, 1.5, 0, \
                                    1.5,  1.5, 1.5, 0, \
                                    1.5,  1.5, 1.5, 0, \
                                    0,    0,   0,   1, \
                                   -1,   -1,  -1,   0)

#define POLAROID_FILTER list(1.438,  -0.062, -0.062, 0, \
                            -0.122,  1.378, -0.122, 0, \
                            -0.016, -0.016,  1.483, 0, \
                             0,      0,      0,     1, \
                            -0.03,   0.05,  -0.02,  0)

#define OLD_1_FILTER list(0.25,   0.25,   0.25,  0, \
                          0.5,    0.5,    0.5,   0, \
                          0.125,  0.125,  0.125, 0, \
                          0,      0,      0,     1, \
                          0.2,    0.2,    0.2,   0)

#define OLD_2_FILTER list(3,    0,    0,   0, \
                          0,    3,    0,   0, \
                          0,    0,    3,   0, \
                          0,    0,    0,   1, \
                         -0.5, -0.5, -0.5, 0)

#define XRAY_FILTER    list(0.95, 0,    0,     0, \
                            0,    0.95, 0,     0, \
                            0,    0,    1.05, -0.5, \
                            0,    0,    0,     1, \
                           -0.1, -0.1, -0.1,   0)

#define NUDE_FILTER    list(1.2,  0,    0,     0, \
                            0,    1,    0,     0, \
                            0,    0,    1,     0, \
                            0,    0,    0,     1, \
                            0,    0,    0,     0)

