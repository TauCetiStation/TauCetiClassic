/obj/item/device/contraband_finder
	name = "Contrband Finder"
	icon_state = "contraband_scanner"
	item_state = "contraband_scanner"
	desc = "A hand-held body scanner able to detect items that can't go past customs."
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 3
	w_class = SIZE_TINY
	throw_speed = 5
	throw_range = 10
	m_amt = 200
	origin_tech = "magnets=4"

	var/can_scan = TRUE

	var/list/contraband_items = list(/obj/item/weapon/storage/box/syndie_kit/merch,
	                                 /obj/item/weapon/match,
	                                 /obj/item/clothing/mask/cigarette,
	                                 /obj/item/weapon/lighter,
	                                 /obj/item/weapon/storage/fancy/cigarettes,
	                                 /obj/item/weapon/storage/secure/briefcase,
	                                 /obj/item/weapon/storage/pouch/pistol_holster,
	                                 /obj/item/weapon/storage/pouch/baton_holster,
	                                 /obj/item/clothing/accessory/holster,
	                                 /obj/item/device/flash,
	                                 /obj/item/weapon/reagent_containers/hypospray,
	                                 /obj/item/weapon/reagent_containers/syringe,
	                                 /obj/item/weapon/reagent_containers/glass/bottle,
	                                 /obj/item/weapon/reagent_containers/food,
	                                 /obj/item/weapon/cartridge/clown,
	                                 /obj/item/weapon/bananapeel,
	                                 /obj/item/weapon/reagent_containers/food/snacks/soap,
	                                 /obj/item/weapon/bikehorn,
	                                 /obj/item/toy/sound_button,
	                                 /obj/item/device/tabletop_assistant,
	                                 /obj/item/weapon/storage/pill_bottle,
	                                 /obj/item/device/paicard,
	                                 /obj/item/clothing/mask/ecig,
	                                 /obj/item/weapon/game_kit,
	                                 /obj/item/weapon/legcuffs,
	                                 /obj/item/weapon/handcuffs,
	                                 /obj/item/weapon/reagent_containers/spray/pepper
	                                 )

	var/list/danger_items = list(/obj/item/device/uplink,
	                             /obj/item/weapon/gun,
	                             /obj/item/weapon/shield,
	                             /obj/item/clothing/head/helmet,
	                             /obj/item/clothing/suit/armor,
	                             /obj/item/weapon/melee/powerfist,
	                             /obj/item/weapon/melee/energy/sword,
	                             /obj/item/weapon/storage/box/emps,
	                             /obj/item/weapon/grenade/empgrenade,
	                             /obj/item/weapon/grenade/syndieminibomb,
	                             /obj/item/weapon/grenade/spawnergrenade/manhacks,
	                             /obj/item/weapon/antag_spawner/borg_tele,
	                             /obj/item/ammo_box,
	                             /obj/item/ammo_casing,
	                             /obj/item/weapon/storage/box/syndie_kit/cutouts,
	                             /obj/item/cardboard_cutout,
	                             /obj/item/clothing/gloves/black/strip,
	                             /obj/item/weapon/reagent_containers/food/snacks/soap/syndie,
	                             /obj/item/weapon/cartridge/syndicate,
	                             /obj/item/toy/carpplushie/dehy_carp,
	                             /obj/item/weapon/storage/box/syndie_kit/chameleon,
	                             /obj/item/weapon/storage/box/syndie_kit/fake,
	                             /obj/item/weapon/storage/backpack/satchel/flat,
	                             /obj/item/clothing/shoes/syndigaloshes,
	                             /obj/item/clothing/mask/gas/voice,
	                             /obj/item/device/chameleon,
	                             /obj/item/device/camera_bug,
	                             /obj/item/weapon/silencer,
	                             /obj/item/weapon/storage/box/syndie_kit/throwing_weapon,
	                             /obj/item/weapon/pen/edagger,
	                             /obj/item/weapon/grenade/clusterbuster/soap,
	                             /obj/item/device/healthanalyzer/rad_laser,
	                             /obj/item/weapon/card/emag,
	                             /obj/item/weapon/storage/toolbox/syndicate,
	                             /obj/item/weapon/storage/backpack/dufflebag/surgery,
	                             /obj/item/weapon/storage/backpack/dufflebag/c4,
	                             /obj/item/weapon/plastique,
	                             /obj/item/weapon/storage/belt/military,
	                             /obj/item/weapon/storage/firstaid/tactical,
	                             /obj/item/weapon/storage/firstaid/small_firstaid_kit/combat,
	                             /obj/item/weapon/storage/box/syndie_kit/space,
	                             /obj/item/clothing/glasses/thermal/syndi,
	                             /obj/item/device/flashlight/emp,
	                             /obj/item/device/encryptionkey/binary,
	                             /obj/item/device/encryptionkey/syndicate,
	                             /obj/item/weapon/storage/box/syndie_kit/posters,
	                             /obj/item/device/biocan,
	                             /obj/item/device/multitool/ai_detect,
	                             /obj/item/weapon/aiModule/freeform/syndicate,
	                             /obj/item/device/powersink,
	                             /obj/item/device/radio/beacon/syndicate,
	                             /obj/item/device/radio/beacon/syndicate_bomb,
	                             /obj/item/device/syndicatedetonator,
	                             /obj/item/weapon/shield/energy,
	                             /obj/item/device/traitor_caller,
	                             /obj/item/weapon/storage/box/syndie_kit/imp_freedom,
	                             /obj/item/weapon/storage/box/syndie_kit/imp_uplink,
	                             /obj/item/weapon/implanter/storage,
	                             /obj/item/weapon/storage/box/syndicate,
	                             /obj/item/device/assembly/mousetrap
	                             )

	var/list/contraband_reagents = list("sugar",
	                                    "serotrotium",
	                                    "kyphotorin",
	                                    "lube",
	                                    "glycerol",
	                                    "nicotine",
	                                    "nanites",
	                                    "nanites2",
	                                    "nanobots",
	                                    "mednanobots"
	                                    )

	var/list/contraband_reagents_types = list(/datum/reagent/consumable)

	var/list/danger_reagents_types = list(/datum/reagent/toxin)

	var/list/danger_reagents = list("potassium",
	                                "mercury",
	                                "chlorine",
	                                "radium",
	                                "uranium",
	                                "alphaamanitin",
	                                "aflatoxin",
	                                "chefspecial",
	                                "dioxin",
	                                "mulligan",
	                                "mutationtoxin",
	                                "amutationtoxin",
	                                "space_drugs",
	                                "cryptobiolin",
	                                "impedrezene",
	                                "stoxin2",
	                                "hyperzine",
	                                "blood",
	                                "nitroglycerin",
	                                "thermite",
	                                "fuel",
	                                "xenomicrobes",
	                                "ectoplasm"
	                                )

/obj/item/device/contraband_finder/proc/reset_color()
	icon_state = "contraband_scanner"
	item_state = "contraband_scanner"
	if(ismob(loc))
		var/mob/M = loc
		if(M.is_in_hands(src))
			if(M.hand)
				M.update_inv_l_hand()
			else
				M.update_inv_r_hand()
	can_scan = TRUE

/obj/item/device/contraband_finder/attack(mob/M, mob/user)
	return

/obj/item/device/contraband_finder/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	scan(target, user)

/obj/item/device/contraband_finder/MouseDrop_T(atom/dropping, mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return

	scan(dropping, user)

/obj/item/device/contraband_finder/proc/scan(atom/target, mob/user)
	if(!can_scan)
		return

	var/list/to_check = target.get_contents()
	to_check += target

	var/danger_color = "green"

	to_check_loop:
		for(var/atom/A in to_check)
			if(danger_color == "green" && is_type_in_list(A, contraband_items))
				danger_color = "yellow"
			if(A.blood_DNA)
				danger_color = "red"
				break
			if(isitem(A))
				var/obj/item/I = A
				if(I.is_sharp())
					danger_color = "red"
					break
				if(I.force >= 10)
					danger_color = "red"
					break
			if(is_type_in_list(A, danger_items))
				danger_color = "red"
				break

			if(A.reagents)
				if(danger_color == "green")
					for(var/reagent in contraband_reagents_types)
						if(locate(reagent) in A.reagents.reagent_list)
							danger_color = "yellow"

					for(var/reagent_id in contraband_reagents)
						if(A.reagents.has_reagent(reagent_id))
							danger_color = "yellow"

				for(var/reagent in danger_reagents_types)
					if(locate(reagent) in A.reagents.reagent_list)
						danger_color = "red"
						break to_check_loop

				for(var/reagent_id in danger_reagents)
					if(A.reagents.has_reagent(reagent_id))
						danger_color = "red"
						break to_check_loop

	switch(danger_color)
		if("green")
			user.visible_message("[bicon(src)] <span class='notice'>Ping.</span>")
			playsound(user, 'sound/machines/ping.ogg', VOL_EFFECTS_MASTER)
		if("yellow")
			user.visible_message("[bicon(src)] <span class='warning'>Beep!</span>")
			playsound(user, 'sound/rig/shortbeep.ogg', VOL_EFFECTS_MASTER)
		if("red")
			user.visible_message("[bicon(src)] <span class='warning bold'>BE-E-E-EP!</span>")
			playsound(user, 'sound/rig/longbeep.ogg', VOL_EFFECTS_MASTER)

	icon_state = "contraband_scanner_[danger_color]"
	item_state = "contraband_scanner_[danger_color]"
	if(user.hand)
		user.update_inv_l_hand()
	else
		user.update_inv_r_hand()
	can_scan = FALSE
	addtimer(CALLBACK(src, .proc/reset_color), 2 SECONDS)
