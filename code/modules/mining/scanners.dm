/obj/item/device/geoscanner
	name = "Geological Analyzer"
	icon = 'icons/obj/mining/geoscanner.dmi'
	icon_state = "geoscanner"
	item_state = "analyzer"
	w_class = SIZE_TINY
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	m_amt = 30
	g_amt = 20
	origin_tech = "magnets=1;engineering=2"

/obj/item/device/geoscanner/afterattack(atom/target, mob/user, proximity, params)
	if(!istype(target, /turf/simulated/mineral))
		return
	if(!proximity)
		return
	var/turf/simulated/mineral/M = target
	var/data_message = ""

	user.visible_message("<span class='notice'>[user] scans [M], the air around them humming gently.</span>")

	data_message +="<span class='notice'><B>Results:</B></span>"
	if(M.mineral)
		data_message +="<span class='notice'>Mineral found</span>"
		data_message +="<span class='notice'>Ore class: [M.mineral.ore_type]</span>"
		data_message +="<span class='notice'>Mineral type: [M.mineral]</span>"
		data_message +="<span class='notice'>Ore amount: [M.ore_amount]</span>"
	else
		data_message +="<span class='warning'>No minerals found in [M]</span>"

	if(M.finds && M.finds.len || M.artifact_find)
		data_message +="<span class='warning'>Unidentified signature in [M]. Report to nearby xenoarchaeologist/anomalist.</span>"

	to_chat(user, data_message)

//	user.visible_message("<span class='notice'>[user] paints \the [P] [mode].</span>","<span class='notice'>You paint \the [P] [mode].</span>")
//	user << "[M.mineral], [M.toughness], [M.ore_amount]"
/obj/item/clothing/glasses/hud/mining
	name = "Geological Optical Scanner"
	desc = "A heads-up display that scans the rocks in view and provides some data about their composition."
	icon_custom = 'icons/obj/mining/geoscanner.dmi'
	icon = 'icons/obj/mining/geoscanner.dmi'
	icon_state = "mininghud"
	item_state = "mininghud"
	hud_types = list(DATA_HUD_MINER)

/obj/item/clothing/glasses/hud/mining/meson
	name = "Geological Meson Optical Scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon = 'icons/obj/clothing/glasses.dmi'
	item_state = "glasses"
	icon_state = "mesonmininghud"
	icon_custom = null
	toggleable = TRUE
	sightglassesmod = "sepia"
	hud_types = list(DATA_HUD_MINER)
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	item_action_types = list(/datum/action/item_action/hands_free/toggle_goggles)

/datum/action/item_action/hands_free/toggle_goggles
	name = "Toggle Goggles"
/obj/item/clothing/glasses/hud/mining/ancient
	name = "Ancient Mining Hud MK II"
	desc = "This hud for mine work in hostile territory, with builded bioscanner inside."
	icon = 'icons/obj/xenoarchaeology/finds.dmi'
	icon_custom = 'icons/mob/eyes.dmi'
	icon_state = "HUDmining"
	item_state = "HUDmining"
	vision_flags = SEE_MOBS
