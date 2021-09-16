var/global/list/contraband_listings

/datum/contraband_listing
	var/default_color = "green"
	var/max_priority = "red"

	var/list/color_to_priority = list(
		"red" = 4,
		"orange" = 3,
		"yellow" = 2,
		"green" = 1,
	)

	var/list/items_to_color

	var/list/reagents_to_color
	var/list/reagent_type_to_color

	var/list/tech_to_color

/datum/contraband_listing/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list

/datum/contraband_listing/proc/get_danger_color(atom/target, mob/user)
	. = default_color

	if(target.blood_DNA)
		return "orange"

	if(color_to_priority[.] < color_to_priority["orange"])
		if(istype(target, /obj/item))
			var/obj/item/I = target
			if(I.is_sharp())
				. = "orange"
			if(I.force >= 10)
				. = "orange"

	for(var/c in items_to_color)
		if(is_type_in_typecache(target, items_to_color[c]))
			. = c

			if(. == max_priority)
				return

	if(!target.reagents)
		return

	for(var/c in reagent_type_to_color)
		for(var/r in reagent_type_to_color[c])
			if(locate(r) in target.reagents.reagent_list)
				. = c

				if(. == max_priority)
					return

	for(var/c in reagents_to_color)
		for(var/r in reagents_to_color[c])
			if(target.reagents.has_reagent(r))
				. = c

				if(. == max_priority)
					return

	if(!isobj(target))
		return
	var/obj/O = target

	var/list/temp_tech = ConvertReqString2List(O.origin_tech)

	for(var/c in tech_to_color)
		for(var/t in tech_to_color[c])
			if(temp_tech[t])
				. = c

				if(. == max_priority)
					return

/datum/contraband_listing/velocity
	items_to_color = list(
		"yellow" = list(
			/obj/item/weapon/storage/box/syndie_kit/merch,
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
			/obj/item/weapon/soap,
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
		),
		"red" = list(
			/obj/item/device/uplink,
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
			/obj/item/weapon/soap/syndie,
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
		),
	)

	reagents_to_color = list(
		"yellow" = list(
			"sugar",
			"serotrotium",
			"kyphotorin",
			"lube",
			"glycerol",
			"nicotine",
			"nanites",
			"nanites2",
			"nanobots",
			"mednanobots"
		),
		"red" = list(
			"potassium",
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
		),
	)

	reagent_type_to_color = list(
		"yellow" = list(/datum/reagent/consumable),
		"red" = list(/datum/reagent/toxin),
	)

	tech_to_color = list(
		"yellow" = list("phorontech", "bluespace"),
		"orange" = list("combat"),
		"red" = list("syndicate"),
	)

/datum/contraband_listing/New()
	..()
	if(!items_to_color)
		return

	var/list/temp_items_to_color = items_to_color.Copy()
	items_to_color = list()

	for(var/c in temp_items_to_color)
		items_to_color[c] = list()
		for(var/t in temp_items_to_color[c])
			items_to_color[c] += typecacheof(t)



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
	origin_tech = "magnets=4;biotech=4"

	var/scanner_ready = TRUE

	var/contraband_listing = /datum/contraband_listing/velocity

	var/flash_danger_color = TRUE
	var/display_item = TRUE

	var/display_item_delay = 2

	var/obj/effect/overlay/item_image

/obj/item/device/contraband_finder/atom_init()
	. = ..()

	set_light(2)

/obj/item/device/contraband_finder/Destroy()
	set_item_image(null)
	return ..()

/obj/item/device/contraband_finder/proc/reset_color()
	icon_state = "contraband_scanner"
	item_state = "contraband_scanner"
	set_item_image(null)
	update_inv_mob()
	scanner_ready = TRUE

/obj/item/device/contraband_finder/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(!ismob(loc))
		return ..()
	if(!CanMouseDrop(src))
		return

	var/mob/M = loc

	if(M.get_active_hand() != src)
		return

	if(!M.IsAdvancedToolUser())
		to_chat(M, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return FALSE

	add_fingerprint(M)
	INVOKE_ASYNC(src, .proc/scan, over, M)
	return TRUE

/obj/item/device/contraband_finder/proc/can_scan(atom/target, mob/user)
	if(!scanner_ready)
		return FALSE

	if(!ishuman(target))
		return TRUE

	if(!PDA_Manifest.len)
		return TRUE

	var/mob/living/carbon/human/H = target

	if(H.incapacitated())
		return TRUE

	var/obj/item/weapon/card/id/I = H.get_idcard()
	if(!I)
		return TRUE

	for(var/dep in PDA_Manifest)
		for(var/person in PDA_Manifest[dep])
			if(person["name"] == I.registered_name)
				return FALSE

	return TRUE

/obj/item/device/contraband_finder/proc/get_item_image(atom/target)
	var/obj/effect/overlay/mask = new
	mask.icon = 'icons/obj/device.dmi'
	mask.icon_state = "contraband_scanner_mask"

	mask.plane = plane
	mask.layer = layer + 0.1

	mask.appearance_flags |= KEEP_TOGETHER

	mask.blend_mode = BLEND_MULTIPLY

	var/image/I = image(target.icon, mask, target.icon_state)

	I.pixel_x = -target.pixel_x
	I.pixel_y = -target.pixel_y

	I.appearance = target

	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT//So you can't click on it.
	I.name = target.name

	I.plane = plane
	I.layer = layer + 0.1

	I.blend_mode = BLEND_MULTIPLY

	I.appearance_flags |= KEEP_TOGETHER|PIXEL_SCALE

	I.color = rgb(125, 180, 225)
	I.alpha = 200

	var/matrix/M = matrix()
	M.Scale(0.6, 0.6)
	I.transform = M

	var/image/holo_mask = image('icons/effects/effects.dmi', I, "scanline")
	holo_mask.plane = plane
	holo_mask.layer = layer + 0.1
	holo_mask.blend_mode = BLEND_MULTIPLY
	I.overlays += holo_mask

	mask.overlays += I

	return mask

/obj/item/device/contraband_finder/proc/set_item_image(atom/target)
	if(item_image)
		vis_contents -= item_image
		QDEL_NULL(item_image)

	if(!target)
		return

	var/image/I = get_item_image(target)
	item_image = I

	vis_contents += item_image

/obj/item/device/contraband_finder/proc/scan_item(atom/target, mob/user, datum/contraband_listing/CL)
	return CL.get_danger_color(target, user)

/obj/item/device/contraband_finder/proc/scan(atom/target, mob/user)
	if(!can_scan(target, user))
		return

	scanner_ready = FALSE

	var/datum/contraband_listing/CL = global.contraband_listings[contraband_listing]

	var/max_priority_danger_color = CL.default_color
	var/max_priority_item = null

	var/list/to_check = target.get_contents()
	to_check += target

	for(var/atom/A as anything in to_check)
		var/danger_color = scan_item(A, user, CL)

		if(CL.color_to_priority[danger_color] > CL.color_to_priority[max_priority_danger_color])
			max_priority_danger_color = danger_color
			max_priority_item = A

		if(display_item)
			set_item_image(A)

		if(!flash_danger_color)
			if(danger_color == CL.max_priority)
				break

			continue

		icon_state = "contraband_scanner_[danger_color]"
		item_state = "contraband_scanner_[danger_color]"

		update_inv_mob()

		if(!do_after(user, display_item_delay, TRUE, A, FALSE, FALSE))
			scanner_ready = TRUE
			reset_color()
			return

	ping(user, max_priority_danger_color)

	icon_state = "contraband_scanner_[max_priority_danger_color]"
	item_state = "contraband_scanner_[max_priority_danger_color]"

	set_item_image(max_priority_item)

	update_inv_mob()
	addtimer(CALLBACK(src, .proc/reset_color), 2 SECONDS)

/obj/item/device/contraband_finder/proc/ping(mob/living/user, danger_color)
	switch(danger_color)
		if("green")
			user.visible_message("[bicon(src)] <span class='notice'>Ping.</span>")
			playsound(user, 'sound/machines/ping.ogg', VOL_EFFECTS_MASTER)
		if("yellow")
			user.visible_message("[bicon(src)] <span class='warning'>Beep!</span>")
			playsound(user, 'sound/rig/shortbeep.ogg', VOL_EFFECTS_MASTER)
		if("orange")
			user.visible_message("[bicon(src)] <span class='warning'>BEEP!</span>")
			playsound(user, 'sound/rig/loudbeep.ogg', VOL_EFFECTS_MASTER)
		if("red")
			user.visible_message("[bicon(src)] <span class='warning bold'>BE-E-E-EP!</span>")
			playsound(user, 'sound/rig/longbeep.ogg', VOL_EFFECTS_MASTER)
