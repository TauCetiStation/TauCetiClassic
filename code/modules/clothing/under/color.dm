// Polychromic jumpsuit - greyscale base + pattern overlay with independent colors
/obj/item/clothing/under/color/polychromic
	name = "polychromic jumpsuit"
	desc = "A jumpsuit with custom coloring."
	icon = 'icons/mob/uniform_poly.dmi'
	icon_state = "world_base_standard"
	item_state = "white"
	flags = ONESIZEFITSALL|HEAR_TALK
	poly_colors = list("#ffffff", "#ffffff")
	// This cached ref is for the icon/dye/worn render paths below.
	// TODO: rework update_icon and add COMSIG_ATOM_UPDATE_ICON
	var/datum/element/polychromic/poly

/obj/item/clothing/under/color/polychromic/atom_init()
	poly_style = global.poly_styles_by_key[POLY_STYLE_STD]
	AddElement(/datum/element/polychromic)
	poly = SSdcs.GetElement(list(/datum/element/polychromic))
	. = ..()

/obj/item/clothing/under/color/polychromic/update_icon()
	..()
	poly.build_icon(src)

/obj/item/clothing/under/color/polychromic/update_world_icon()
	update_icon()

/obj/item/clothing/under/color/polychromic/get_standing_overlay(mob/living/carbon/human/H, def_icon_path, sprite_sheet_slot, layer, bloodied_icon_state = null, icon_state_appendix = null)
	if(sprite_sheet_slot == SPRITE_SHEET_HELD || !length(poly_colors))
		return ..()
	return poly.build_worn(src, H, layer, bloodied_icon_state)

/obj/item/clothing/under/color/polychromic/wash_act(w_color)
	if(w_color && poly.try_dye(src, w_color))
		return
	return ..()

/obj/item/clothing/under/color/polychromic/rollsuit()
	set name = "Roll Down Jumpsuit"
	set category = "Object"
	set src in usr
	if(!can_rollsuit(usr))
		return
	if(!poly_style.can_roll)
		to_chat(usr, "<span class='notice'>You cannot roll down a turtleneck!</span>")
		return
	rolled_down = !rolled_down
	update_inv_mob()

/obj/item/clothing/under/color/black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "black"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/color/blackf
	name = "feminine black jumpsuit"
	desc = "It's very smart and in a ladies-size!"
	icon_state = "black"
	item_state = "blackf"

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	icon_state = "blue"
	item_state = "blue"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	icon_state = "green"
	item_state = "green"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	icon_state = "grey"
	item_state = "grey"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/color/orange
	name = "orange jumpsuit"
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "orange"
	item_state = "orange"
	has_sensor = 2
	sensor_mode = SUIT_SENSOR_TRACKING
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	icon_state = "pink"
	item_state = "pink"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	icon_state = "red"
	item_state = "red"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	icon_state = "white"
	item_state = "white"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	icon_state = "yellow"
	item_state = "yellow"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/psyche
	name = "psychedelic"
	desc = "Groovy!"
	icon_state = "psyche"

/obj/item/clothing/under/lightblue
	name = "lightblue"
	desc = "lightblue"
	icon_state = "lightblue"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/aqua
	name = "aqua"
	desc = "aqua"
	icon_state = "aqua"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/purple
	name = "purple"
	desc = "purple"
	icon_state = "purple"
	item_state = "purple"

/obj/item/clothing/under/lightpurple
	name = "lightpurple"
	desc = "lightpurple"
	icon_state = "lightpurple"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/lightgreen
	name = "lightgreen"
	desc = "lightgreen"
	icon_state = "lightgreen"

/obj/item/clothing/under/lightblue
	name = "lightblue"
	desc = "lightblue"
	icon_state = "lightblue"

/obj/item/clothing/under/lightbrown
	name = "lightbrown"
	desc = "lightbrown"
	icon_state = "lightbrown"

/obj/item/clothing/under/brown
	name = "brown"
	desc = "brown"
	icon_state = "brown"

/obj/item/clothing/under/yellowgreen
	name = "yellowgreen"
	desc = "yellowgreen"
	icon_state = "yellowgreen"

/obj/item/clothing/under/darkblue
	name = "darkblue"
	desc = "darkblue"
	icon_state = "darkblue"
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/under/lightred
	name = "lightred"
	desc = "lightred"
	icon_state = "lightred"

/obj/item/clothing/under/darkred
	name = "darkred"
	desc = "darkred"
	icon_state = "darkred"
	flags = ONESIZEFITSALL|HEAR_TALK
