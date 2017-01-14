/obj/item/device/geoscanner
	name = "Geological Analyzer"
	icon = 'icons/obj/mining/geoscanner.dmi'
	icon_state = "geoscanner"
	item_state = "analyzer"
	w_class = 2.0
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	m_amt = 30
	g_amt = 20
	origin_tech = "magnets=1;engineering=2"

/obj/item/device/geoscanner/afterattack(atom/A, mob/user)
	if(!istype(A,/turf/simulated/mineral))
		return
	if(!in_range(user, A))
		return
	var/turf/simulated/mineral/M = A
	user.visible_message("\blue [user] scans [A], the air around them humming gently.")
	user.show_message("\blue <B>Results:</B>", 1)
	if(M.mineral)
		user.show_message("\green Mineral found", 1)
		user.show_message("\blue Ore class: [M.mineral.ore_type]", 1)
		user.show_message("\blue Mineral type: [M.mineral]", 1)
		user.show_message("\blue Ore amount: [M.ore_amount]", 1)
	else
		user.show_message("\red No minerals found in [M]", 1)

	if(M.finds && M.finds.len || M.artifact_find)
		user.show_message("\red Unidentified signature in [M]. Report to nearby xenoarchaeologist/anomalist.", 1)

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

/obj/item/clothing/glasses/hud/mining/New()
	..()
	error = pick(-1,1)

/obj/item/clothing/glasses/hud/mining/process_hud(mob/M)
	if(!M)	return
	if(!M.client)	return
	var/client/C = M.client
	var/icon/hudMineral = 'icons/obj/mining/geoscanner.dmi'
	for(var/turf/simulated/mineral/rock in view(get_turf(M)))
		if(!C) return

		if(rock.finds && rock.finds.len || rock.artifact_find)
			C.images += image(hudMineral,rock,"hudanomaly")
		else if (rock.mineral)
			C.images += image(hudMineral,rock,"hud[rock.mineral.ore_type]")
