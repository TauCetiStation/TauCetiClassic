/obj/item/device/geoscanner
	name = "Geological Analyzer"
	icon = 'icons/obj/mining/geoscanner.dmi'
	icon_state = "geoscanner"
	item_state = "analyzer"
	w_class = ITEM_SIZE_SMALL
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
	if(!in_range(user, target))
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
//	vision_flags = SEE_TURFS
//	invisa_view = 2
	var/error

/obj/item/clothing/glasses/hud/mining/atom_init()
	. = ..()
	error = pick(-1,1)

/obj/item/clothing/glasses/hud/mining/process_hud(mob/M)
	if(!M)	return
	if(!M.client)	return
	var/client/C = M.client
	var/icon/hudMineral = 'icons/obj/mining/geoscanner.dmi'
	for(var/turf/simulated/mineral/rock in RANGE_TURFS(7, (get_turf(M))))
		if(!C) return

		if(rock.finds && rock.finds.len || rock.artifact_find)
			C.images += image(hudMineral,rock,"hudanomaly")
		else if (rock.mineral)
			C.images += image(hudMineral,rock,"hud[rock.mineral.ore_type]")

/obj/item/clothing/glasses/hud/mining/ancient
	name = "Ancient Mining Hud MK II"
	desc = "This hud for mine work in hostile territory, with builded bioscanner inside."
	icon = 'icons/obj/xenoarchaeology/finds.dmi'
	icon_custom = 'icons/mob/eyes.dmi'
	icon_state = "HUDmining"
	item_state = "HUDmining"
	vision_flags = SEE_MOBS
