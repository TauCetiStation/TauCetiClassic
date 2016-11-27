/obj/item/clothing/under/shadowling
	name = "blackened flesh"
	desc = "Black, chitonous skin."
	icon_state = "golem"
	item_state = "golem"
	item_color = "golem"
	has_sensor = 0
	canremove = 0
	origin_tech = null
	flags = ABSTRACT
	unacidable = 1


/obj/item/clothing/suit/space/shadowling
	name = "chitin shell"
	desc = "Dark, semi-transparent shell. Protects against vacuum, but not against the light of the stars." //Still takes damage from spacewalking but is immune to space itself
	icon_state = "golem"
	item_state = "golem"
	body_parts_covered = FULL_BODY //Shadowlings are immune to space
	cold_protection = FULL_BODY
	//min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	flags = ABSTRACT | THICKMATERIAL
	slowdown = 0
	unacidable = 1
	heat_protection = null //You didn't expect a light-sensitive creature to have heat resistance, did you?
	max_heat_protection_temperature = null
	canremove = 0
	siemens_coefficient = 0.2


/obj/item/clothing/shoes/shadowling
	name = "chitin feet"
	desc = "Charred-looking feet. They have minature hooks that latch onto flooring."
	icon_state = "golem"
	unacidable = 1
	flags = NOSLIP | ABSTRACT
	canremove = 0


/obj/item/clothing/mask/gas/shadowling
	name = "chitin mask"
	desc = "A mask-like formation with slots for facial features. A red film covers the eyes."
	icon_state = "golem"
	item_state = "golem"
	origin_tech = null
	siemens_coefficient = 0
	unacidable = 1
	flags = ABSTRACT
	canremove = 0
	flags_inv = 0


/obj/item/clothing/gloves/shadowling
	name = "chitin hands"
	desc = "An electricity-resistant yet thin covering of the hands."
	icon_state = "golem"
	item_state = null
	origin_tech = null
	siemens_coefficient = 0
	unacidable = 1
	flags = ABSTRACT
	canremove = 0


/obj/item/clothing/head/shadowling
	name = "chitin helm"
	desc = "A helmet-like enclosure of the head."
	icon_state = "golem"
	item_state = null
	origin_tech = null
	unacidable = 1
	flags = ABSTRACT
	canremove = 0
	flags_inv = 0


/obj/item/clothing/glasses/night/shadowling
	name = "crimson eyes"
	desc = "A shadowling's eyes. Very light-sensitive and can detect body heat through walls."
	icon = null
	icon_state = null
	item_state = null
	origin_tech = null
	vision_flags = SEE_MOBS
	alpha = 0
	darkness_view = 3
	var/vision = 1
	//invis_view = 2
	//invisa_view = 2
	//flash_protect = 2
	unacidable = 1
	flags = ABSTRACT
	canremove = 0
	action_button_name = "Toggle Vision"
	icon = 'icons/mob/shadowling_hud.dmi'
	icon_state = "ling_vision_off"


/obj/item/clothing/glasses/night/shadowling/attack_self()
	toggle()

/obj/item/clothing/glasses/night/shadowling/verb/toggle()
	set category = "Object"
	set name = "Toggle Vision"
	set src in usr

	if(!usr.stat)
		if(src.vision)
			src.vision = !src.vision
			src.icon_state = "ling_vision_on"
			//usr << ""
		else
			src.vision = !src.vision
			src.icon_state = "ling_vision_off"
			//usr << ""

		usr.update_inv_glasses()

/obj/structure/shadow_vortex
	name = "vortex"
	desc = "A swirling hole in the fabric of reality. Eye-watering chimes sound from its depths."
	density = 0
	anchored = 1
	icon = 'icons/effects/genetics.dmi'
	icon_state = "shadow_portal"

/obj/structure/shadow_vortex/New()
	//src.audible_message("<span class='warning'><b>\The [src] lets out a dismaying screech as dimensional barriers are torn apart!</span>")
	playsound(loc, 'sound/effects/supermatter.ogg', 100, 1)
	sleep(100)
	qdel(src)

/obj/structure/shadow_vortex/Crossed(var/td)
	..()
	if(ismob(td))
		to_chat(td, "<span class='userdanger'><font size=3>You enter the rift. Sickening chimes begin to jangle in your ears. \
		All around you is endless blackness. After you see something moving, you realize it isn't entirely lifeless.</font></span>") //A bit of spooking before they die
		var/mob/M = td
		M.ghostize()
	playsound(loc, 'sound/effects/EMPulse.ogg', 25, 1)
	qdel(td)
