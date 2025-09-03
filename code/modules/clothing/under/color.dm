
/obj/item/clothing/under/colored
	name = "colored uniform"
	icon_state = "red"
	item_state_inventory= "colored"
	item_state_world = "colored_w"
	item_state = "colored"
	color = "#386b89"
	flags = ONESIZEFITSALL
	var/mutable_appearance/item_under_overlay

// if needed, this can easily be changed to /obj/item/clothing/under
// in case of adding support for /obj/item/clothing, this proc will require some tweaking
/obj/item/clothing/under/colored/get_standing_overlay(mob/living/carbon/human/H, def_icon_path, sprite_sheet_slot, layer, bloodied_icon_state = null, icon_state_appendix = null)
	var/mutable_appearance/I = ..()

	var/icon_path = def_icon_path
	var/t_state = item_state ? item_state : icon_state

	var/datum/species/S = H.species

	if(S.sprite_sheets[sprite_sheet_slot])
		icon_path = S.sprite_sheets[sprite_sheet_slot]

	var/fem_appendix = ""

	// we dont have female sprites for fat uniforms
	if(H.gender == FEMALE && S.gender_limb_icons && sprite_sheet_slot != SPRITE_SHEET_UNIFORM_FAT)
		fem_appendix = "_fem"

	// checks if we have a colorless overlay we need to apply
	if(rolled_down || !icon_exists(icon_path, "[t_state]_overlay[fem_appendix]"))
		return I

	// add the colorless overlay
	I.cut_overlays()
	var/mutable_appearance/under_mob_overlay = mutable_appearance(icon = icon_path, icon_state = "[t_state]_overlay[fem_appendix]")
	under_mob_overlay.appearance_flags = RESET_COLOR
	I.add_overlay(under_mob_overlay)

	// re-apply blood & dirt
	if(dirt_overlay && bloodied_icon_state)
		var/mutable_appearance/bloodsies = mutable_appearance(icon = 'icons/effects/blood.dmi', icon_state = bloodied_icon_state)
		bloodsies.color = dirt_overlay.color
		I.add_overlay(bloodsies)

	return I

/obj/item/clothing/under/colored/update_icon()
	..()

	// add the colorless overlay
	//var/mutable_appearance/under_overlay = mutable_appearance(icon, "[icon_state]_overlay")
	//under_overlay.appearance_flags = RESET_COLOR
	//add_overlay(under_overlay)

/obj/item/clothing/under/colored/dropped()
	. = ..()
	update_world_icon()

/obj/item/clothing/under/colored/update_world_icon()
	..()

	// add the colorless overlay
	cut_overlay(item_under_overlay)
	item_under_overlay = image(icon, "[icon_state]_overlay")
	item_under_overlay.appearance_flags = RESET_COLOR
	add_overlay(item_under_overlay)

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
