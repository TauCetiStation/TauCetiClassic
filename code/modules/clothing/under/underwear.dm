// Undershirt

//!!!!!!!!!!!!!!!!!!!!!!!MUST NOT GET INTO PRODUCTION!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// This is a prototype for test only.
// TODO port all those items and proper dmi icon_state names.

/obj/item/clothing/under/undershirt
	icon = 'icons/mob/human_undershirt.dmi' // until proper dmi file.
	name = "undershirt"
	item_state = "gy_suit"
	body_parts_covered = UPPER_TORSO
	permeability_coefficient = 0.90
	slot_flags = SLOT_UNDERWEAR
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	w_class = 3

	has_sensor = 0//For the crew computer 2 = unable to change mode
	sensor_mode = 0

	hastie = null
	displays_id = 0
	rolled_down = 0
	//basecolor
	//sprite_sheets = list(S_VOX = 'icons/mob/species/vox/uniform.dmi')

/obj/item/clothing/under/undershirt/blacktanktop // TODO, port all underclothes.
	name = "Black Tank top"
	icon_state = "undershirt1_s"
	item_color = "undershirt1_s"

/obj/item/clothing/under/undershirt/redtop // TODO, port all underclothes.
	name = "Red top"
	icon_state = "undershirt31_f_s"
	item_color = "undershirt31_f_s"

// Underwear
/obj/item/clothing/under/underwear
	icon = 'icons/mob/human_underwear.dmi' // until proper dmi file.
	name = "underwear"
	item_state = "gy_suit"
	body_parts_covered = LOWER_TORSO // armored pants anyone? :D
	permeability_coefficient = 0.90
	slot_flags = SLOT_UNDERWEAR
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	w_class = 3

	has_sensor = 0//For the crew computer 2 = unable to change mode
	sensor_mode = 0

	hastie = null
	displays_id = 0
	rolled_down = 0

/obj/item/clothing/under/underwear/ms
	name = "ms"
	icon_state = "underwear1_m_s"
	item_color = "underwear1_m_s"

//Socks
/obj/item/clothing/shoes/socks
	icon = 'icons/mob/human_socks.dmi' // until proper dmi file.
	name = "socks"
	item_state = "gy_suit"
	desc = "Pair of socks."
	siemens_coefficient = 0.9
	body_parts_covered = FEET
	slot_flags = SLOT_UNDERWEAR

	permeability_coefficient = 0.50
	slowdown = 0
	//species_restricted = list("exclude", S_UNATHI, S_TAJARAN)
	footstep = 0	//used for squeeks whilst walking(tc)
	//sprite_sheets = list(S_VOX = 'icons/mob/species/vox/shoes.dmi')

/obj/item/clothing/shoes/socks
	name = "socks"
	icon_state = "socks1_s"
	item_color = "socks1_s"
