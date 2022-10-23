var/global/list/bitfields = generate_bitfields()

/// Specifies a bitfield for smarter debugging
/datum/bitfield
	/// The variable name that contains the bitfield
	var/variable

	/// An associative list of the readable flag and its true value
	var/list/flags

/// Turns /datum/bitfield subtypes into a list for use in debugging
/proc/generate_bitfields()
	var/list/bitfields = list()
	for (var/_bitfield in subtypesof(/datum/bitfield))
		var/datum/bitfield/bitfield = new _bitfield
		bitfields[bitfield.variable] = bitfield.flags
	return bitfields

DEFINE_BITFIELD(appearance_flags, list(
	"LONG_GLIDE" = LONG_GLIDE,
	"RESET_COLOR" = RESET_COLOR,
	"RESET_ALPHA" = RESET_ALPHA,
	"RESET_TRANSFORM" = RESET_TRANSFORM,
	"NO_CLIENT_COLOR" = NO_CLIENT_COLOR,
	"KEEP_TOGETHER" = KEEP_TOGETHER,
	"KEEP_APART" = KEEP_APART,
	"PLANE_MASTER" = PLANE_MASTER,
	"TILE_BOUND" = TILE_BOUND,
	"PIXEL_SCALE" = PIXEL_SCALE,
	"PASS_MOUSE" = PASS_MOUSE,
	"TILE_MOVER" = TILE_MOVER,
))

DEFINE_BITFIELD(vis_flags, list(
	"VIS_INHERIT_ICON" = VIS_INHERIT_ICON,
	"VIS_INHERIT_ICON_STATE" = VIS_INHERIT_ICON_STATE,
	"VIS_INHERIT_DIR" = VIS_INHERIT_DIR,
	"VIS_INHERIT_LAYER" = VIS_INHERIT_LAYER,
	"VIS_INHERIT_PLANE" = VIS_INHERIT_PLANE,
	"VIS_INHERIT_ID" = VIS_INHERIT_ID,
	"VIS_UNDERLAY" = VIS_UNDERLAY,
	"VIS_HIDE" = VIS_HIDE
))

DEFINE_BITFIELD(sight, list(
	"SEE_INFRA" = SEE_INFRA,
	"SEE_SELF" = SEE_SELF,
	"SEE_MOBS" = SEE_MOBS,
	"SEE_OBJS" = SEE_OBJS,
	"SEE_TURFS" = SEE_TURFS,
	"SEE_PIXELS" = SEE_PIXELS,
	"SEE_THRU" = SEE_THRU,
	"SEE_BLACKNESS" = SEE_BLACKNESS,
	"BLIND" = BLIND
))

DEFINE_BITFIELD(pass_flags, list(
	"PASSTABLE" = PASSTABLE,
	"PASSGLASS" = PASSGLASS,
	"PASSGRILLE" = PASSGRILLE,
	"PASSBLOB" = PASSBLOB,
	"PASSCRAWL" = PASSCRAWL,
	"PASSMOB" = PASSMOB
))

