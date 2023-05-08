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

	var/list/color_to_name = list(
		"red" = "illicit",
		"orange" = "high-risk",
		"yellow" = "contraband",
		"green" = "safe",
	)

	var/list/items_to_color

	var/list/reagents_to_color
	var/list/reagent_type_to_color

	var/list/tech_to_color

	var/static/list/tech_names = list(
		"materials" = "Materials",
		"engineering" = "Engineering",
		"phorontech" = "Phoron",
		"powerstorage" = "Power",
		"bluespace" = "Bluespace",
		"biotech" = "Biotech",
		"combat" = "Combat",
		"magnets" = "Electromagnetic",
		"programming" = "Programming",
		"syndicate" = "Illegal"
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
			var/set_val = TRUE
			if(temp_items_to_color[c][t])
				set_val = temp_items_to_color[c][t]
			for(var/subt in typesof(t))
				items_to_color[c][subt] = set_val

/datum/contraband_listing/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list

/datum/contraband_listing/proc/create_info()
	return list("color"=default_color, "colors"=list())

/datum/contraband_listing/proc/merge_info(list/to_info, list/from_info, full)
	if(!from_info)
		return

	set_color(to_info, from_info["color"])
	for(var/c in from_info["colors"])
		for(var/t in from_info["colors"][c])
			add_tip(to_info, c, t)

	if(!full && to_info["color"] == max_priority)
		return TRUE

/datum/contraband_listing/proc/set_color(list/info, color)
	var/cur = info["color"]

	if(color_to_priority[cur] < color_to_priority[color])
		info["color"] = color

/datum/contraband_listing/proc/add_tip(list/info, color, tip)
	LAZYADD(info["colors"][color], tip)

// Returns TRUE in case that there is nothing else to look for on the item.
/datum/contraband_listing/proc/add_info(list/info, color, tip, full)
	set_color(info, color)
	if(full)
		add_tip(info, color, tip)

/datum/contraband_listing/proc/high_risk_checks(atom/target, mob/user, full)
	. = create_info()

	if(target.blood_DNA)
		add_info(., "orange", "Has traces of blood.", full)

	if(isitem(target))
		var/obj/item/I = target
		if(I.is_sharp())
			add_info(., "orange", "Is a sharp object.", full)
		if(I.force >= 10)
			add_info(., "orange", "Is a weapon.", full)

/datum/contraband_listing/proc/item_lists_checks(atom/target, mob/user, full)
	. = create_info()

	for(var/c in items_to_color)
		var/flavour = items_to_color[c][target.type]
		if(flavour)
			add_info(., c, "Is in a list of [color_to_name[c]] items.[istext(flavour) ? "([flavour])" : ""]", full)

			if(.["color"] == max_priority && !full)
				return

/datum/contraband_listing/proc/reagents_lists_checks(atom/target, mob/user, full)
	if(!target.reagents)
		return

	. = create_info()

	for(var/c in reagent_type_to_color)
		for(var/r in reagent_type_to_color[c])
			var/datum/reagent/R = locate(r) in target.reagents.reagent_list
			if(R)
				var/list/reason = reagent_type_to_color[c][r]
				var/category = null
				var/flavour = null
				if(reason)
					category = reason[0]
					flavour = reason[1]

				add_info(., c, "Contains a substance ([R.name])[category ? " of category ([category]) " : " "]belonging to [color_to_name[c]] classification.[istext(flavour) ? "([flavour])" : ""]", full)

				if(.["color"] == max_priority && !full)
					return

	for(var/c in reagents_to_color)
		for(var/r in reagents_to_color[c])
			var/datum/reagent/R = target.reagents.has_reagent(r)
			if(R)
				var/flavour = reagents_to_color[c][r]
				add_info(., c, "Contains a substance ([R.name]) belonging to [color_to_name[c]] classification.[istext(flavour) ? "([flavour])" : ""]", full)

				if(.["color"] == max_priority && !full)
					return

/datum/contraband_listing/proc/tech_lists_checks(atom/target, mob/user, full)
	if(!istype(target, /obj))
		return

	. = create_info()

	var/obj/O = target

	var/list/temp_tech = ConvertReqString2List(O.origin_tech)

	for(var/c in tech_to_color)
		for(var/t in tech_to_color[c])
			if(temp_tech[t])
				var/flavour = tech_to_color[c][t]
				add_info(., c, "Some technical components ([tech_names[t]]) are considered to be belonging to [color_to_name[c]] classification.[istext(flavour) ? "([flavour])" : ""]", full)

				if(.["color"] == max_priority && !full)
					return

/datum/contraband_listing/proc/sort_info(list/info)
	var/list/colors = list()
	for(var/c in color_to_priority)
		if(!info["colors"][c])
			continue
		colors[c] = info["colors"][c]
	info["colors"] = colors

/datum/contraband_listing/proc/get_info(atom/target, mob/user, full=FALSE)
	. = create_info()

	if(merge_info(., high_risk_checks(target, user, full), full))
		sort_info(.)
		return

	if(merge_info(., item_lists_checks(target, user, full), full))
		sort_info(.)
		return

	if(merge_info(., reagents_lists_checks(target, user, full), full))
		sort_info(.)
		return

	if(merge_info(., tech_lists_checks(target, user, full), full))
		sort_info(.)
		return

	sort_info(.)

/datum/contraband_listing/velocity
	items_to_color = list(
		"yellow" = list(
			/obj/item/weapon/storage/box/syndie_kit/merch,
			/obj/item/weapon/match,
			/obj/item/clothing/mask/cigarette="Cancer",
			/obj/item/weapon/lighter,
			/obj/item/weapon/storage/fancy/cigarettes,
			/obj/item/weapon/storage/secure/briefcase,
			/obj/item/weapon/storage/pouch/pistol_holster,
			/obj/item/weapon/storage/pouch/baton_holster,
			/obj/item/clothing/accessory/holster,
			/obj/item/device/flash="Three cases of unrobust Velocity Officers",
			/obj/item/weapon/reagent_containers/hypospray,
			/obj/item/weapon/reagent_containers/syringe="Common fear of syringes",
			/obj/item/weapon/reagent_containers/glass/bottle,
			/obj/item/weapon/reagent_containers/food,
			/obj/item/weapon/cartridge/clown="Workplace fatalities.",
			/obj/item/weapon/bananapeel="Workplace accidents",
			/obj/item/weapon/reagent_containers/food/snacks/soap="Workplace accidents",
			/obj/item/weapon/bikehorn="Loud sounds",
			/obj/item/toy/sound_button="Loud sounds",
			/obj/item/device/tabletop_assistant,
			/obj/item/weapon/storage/pill_bottle,
			/obj/item/device/paicard="Ethics commitee unsure of whether this is sentient life trafficing",
			/obj/item/clothing/mask/ecig,
			/obj/item/weapon/game_kit,
			/obj/item/weapon/legcuffs="Corporate policy prohibiting BDSM",
			/obj/item/weapon/handcuffs="Corporate policy prohibiting BDSM",
			/obj/item/weapon/reagent_containers/spray/pepper,
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
			/obj/item/weapon/reagent_containers/food/snacks/soap/syndie,
			/obj/item/weapon/cartridge/syndicate,
			/obj/item/toy/carpplushie/dehy_carp="DO NOT ADD WATER",
			/obj/item/weapon/storage/box/syndie_kit/chameleon,
			/obj/item/weapon/storage/box/syndie_kit/fake,
			/obj/item/weapon/storage/backpack/satchel/flat,
			/obj/item/clothing/shoes/syndigaloshes,
			/obj/item/clothing/mask/gas/voice,
			/obj/item/device/chameleon,
			/obj/item/device/camera_bug,
			/obj/item/weapon/silencer,
			/obj/item/weapon/storage/box/syndie_kit/throwing_weapon,
			/obj/item/weapon/pen/edagger="Blueshield accidents",
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
			/obj/item/device/biocan="A case of a worker pretending to be Walt Disney",
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
			/obj/item/device/assembly/mousetrap,
		),
	)

	reagents_to_color = list(
		"yellow" = list(
			"sugar"="Sugar rushes detrimental to waiting in queues",
			"serotrotium",
			"kyphotorin",
			"lube"="Workplace accidents",
			"glycerol",
			"nicotine",
			"nanites2",
			"nanobots"="Two cases of cronenberging",
			"mednanobots",
		),
		"orange" = list(
			"blood",
		),
		"red" = list(
			"potassium",
			"mercury"="Loud sounds",
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
			"nitroglycerin",
			"thermite",
			"fuel",
			"ectoplasm",
		),
	)

	reagent_type_to_color = list(
		"yellow" = list(/datum/reagent/consumable = list("food", "")),
		"red" = list(/datum/reagent/toxin = list("toxic", "")),
	)

	tech_to_color = list(
		"yellow" = list("phorontech", "bluespace"="Detrimental to transport industry competetiveness"),
		"orange" = list("combat"),
		"red" = list("syndicate"),
	)
