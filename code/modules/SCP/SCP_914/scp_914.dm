/obj/machinery/scp914
	name = "SCP-914"
	desc = "Looks like a very complicated clockwork machine."
	icon = 'code/modules/SCP/SCP_914/scp-914.dmi'
	icon_state = "center"
	layer = 2.9
	anchored = 1
	density = 1
	var/process_time = 160
	var/list/items_to_process = list()
	var/list/humans_to_process = list()
	var/list/to_output = list()
	var/obj/machinery/scp914_input/input_obj = null
	var/obj/machinery/scp914_output/output_obj = null
	var/list/item_tree = null
	var/obj/machinery/scp914_left/left_obj = null
	var/obj/machinery/scp914_right/right_obj = null
	var/active = FALSE


/obj/machinery/scp914_input
	name = "SCP-914 INPUT"
	desc = "Looks like a very complicated clockwork machine."
	icon = 'code/modules/SCP/SCP_914/scp-914.dmi'
	icon_state = "in"
	layer = 2.9
	anchored = 1
	density = 0

/obj/machinery/scp914_output
	name = "SCP-914 OUTPUT"
	desc = "Looks like a very complicated clockwork machine."
	icon = 'code/modules/SCP/SCP_914/scp-914.dmi'
	icon_state = "out"
	layer = 2.9
	anchored = 1
	density = 0

/obj/machinery/scp914_left
	name = "SCP-914"
	desc = "Looks like a very complicated clockwork machine."
	icon = 'code/modules/SCP/SCP_914/scp-914.dmi'
	icon_state = "left"
	layer = 2.9
	anchored = 1
	density = 1

/obj/machinery/scp914_right
	name = "SCP-914"
	desc = "Looks like a very complicated clockwork machine."
	icon = 'code/modules/SCP/SCP_914/scp-914.dmi'
	icon_state = "right"
	layer = 2.9
	anchored = 1
	density = 1

/obj/machinery/scp914/atom_init()
	. = ..()
	left_obj = new /obj/machinery/scp914_left(get_step(loc, WEST))
	right_obj = new /obj/machinery/scp914_right(get_step(loc, EAST))
	input_obj = new /obj/machinery/scp914_input(get_step(get_step(loc, WEST), WEST))
	output_obj = new /obj/machinery/scp914_output(get_step(get_step(loc, EAST), EAST))

	item_tree = list(
		"teir1glasses" = list(
				"types" = subtypesof(/obj/item/clothing/glasses) - list(/obj/item/clothing/glasses/chameleon, /obj/item/clothing/glasses/material, /obj/item/clothing/glasses, /obj/item/clothing/glasses/fluff) - subtypesof(/obj/item/clothing/glasses/hud) - subtypesof(/obj/item/clothing/glasses/meson) - subtypesof(/obj/item/clothing/glasses/night) - subtypesof(/obj/item/clothing/glasses/sunglasses) - subtypesof(/obj/item/clothing/glasses/thermal),
				"upgrade" = list("teir2glasses"),
				"degrade" = list("trash")
			),
		"teir2glasses" = list(
				"types" = subtypesof(/obj/item/clothing/glasses/hud) + subtypesof(/obj/item/clothing/glasses/night) + subtypesof(/obj/item/clothing/glasses/sunglasses) - list(/obj/item/clothing/glasses/hud, /obj/item/clothing/glasses/hud/broken, /obj/item/clothing/glasses/hud/health/night, /obj/item/clothing/glasses/night/shadowling) - subtypesof(/obj/item/clothing/glasses/sunglasses/hud) - subtypesof(/obj/item/clothing/glasses/sunglasses/sechud),
				"upgrade" = list("teir3glasses"),
				"degrade" = list("teir1glasses")
			),

		"teir3glasses" = list(
				"types" = list(/obj/item/clothing/glasses/hud/health/night, /obj/item/clothing/glasses/chameleon, /obj/item/clothing/glasses/material) + subtypesof(/obj/item/clothing/glasses/sunglasses/hud) + typesof(/obj/item/clothing/glasses/sunglasses/sechud) + typesof(/obj/item/clothing/glasses/meson) + typesof(/obj/item/clothing/glasses/thermal),
				"upgrade" = list("clothes", "trash"),
				"degrade" = list("teir2glasses")
			),
		"teir1gloves" = list(
				"types" = subtypesof(/obj/item/clothing/gloves) - list(/obj/item/clothing/gloves/golem, /obj/item/clothing/gloves/shadowling),
				"upgrade" = list("clothes"),
				"degrade" = list("trash")
			),
		"teir1hat" = list(
				"types" = subtypesof(/obj/item/clothing/head) + subtypesof(/obj/item/clothing/head/helmet) - list(/obj/item/clothing/head/shadowling, /obj/item/clothing/head/helmet/space/golem, /obj/item/clothing/head/chameleon),
				"upgrade" = list("teir2hat"),
				"degrade" = list("trash")
			),
		"teir2hat" = list(
				"types" = list (/obj/item/clothing/head/chameleon) + subtypesof(/obj/item/clothing/head/helmet),
				"upgrade" = list("clothes", "trash"),
				"degrade" = list("teir1hat")
			),
		"teir1mask" = list(
				"types" = subtypesof(/obj/item/clothing/mask) - list(/obj/item/clothing/mask/facehugger, /obj/item/clothing/mask/gas/shadowling, /obj/item/clothing/mask/gas/golem),
				"upgrade" = list("clothes", "trash"),
				"degrade" = list("trash")
			),
		"teir1shoes" = list(
				"types" = subtypesof(/obj/item/clothing/shoes) - list(/obj/item/clothing/shoes, /obj/item/clothing/shoes/golem, /obj/item/clothing/shoes/shadowling),
				"upgrade" = list("clothes", "trash"),
				"degrade" = list("trash")
			),
		"teir1suit" = list(
				"types" = subtypesof(/obj/item/clothing/suit) - typesof(/obj/item/clothing/suit/armor) + typesof(/obj/item/clothing/suit/bio_suit) + list(/obj/item/clothing/suit/chameleon),
				"upgrade" = list("teir2suit"),
				"degrade" = list("trash")
			),
		"teir2suit" = list(
				"types" = subtypesof(/obj/item/clothing/suit/armor) + subtypesof(/obj/item/clothing/suit/bio_suit) + list(/obj/item/clothing/suit/chameleon) - list(/obj/item/clothing/shoes, /obj/item/clothing/shoes/golem, /obj/item/clothing/shoes/shadowling),
				"upgrade" = list("clothes", "trash"),
				"degrade" = list("teir1suit")
			),
		"labcoats" = list(
				"types" = typesof(/obj/item/clothing/suit/storage/labcoat),
				"upgrade" = list("clothes", "trash"),
				"degrade" = list("clothes")
			),
		"clothes" = list(
				"types" = typesof(/obj/item/clothing/under) - list(/obj/item/clothing/under/chameleon, /obj/item/clothing/under/golem, /obj/item/clothing/under/gimmick),
				"upgrade" = list("labcoats", "teir1glasses", "teir1gloves", "teir1hat", "teir1mask", "teir1shoes", "teir1suit"),
				"degrade" = list("trash")
			),
		"goodtools" = list(
				"types" = list(
					/obj/item/weapon/wirecutters/power,
					/obj/item/weapon/crowbar/power,
					/obj/item/weapon/screwdriver/power,
					/obj/item/weapon/wrench/power,
					/obj/item/weapon/weldingtool/largetank,
					/obj/item/weapon/weldingtool/hugetank,
					/obj/item/weapon/weldingtool/experimental
					),
				"upgrade" = list(),
				"degrade" = list("tools")
			),
		"toolbelts" = list(
				"types" = typesof(/obj/item/weapon/storage/belt) + subtypesof(/obj/item/weapon/storage/toolbox),
				"upgrade" = list(),
				"degrade" = list("tools")
			),
		"tools" = list(
				"types" = list(
					/obj/item/weapon/screwdriver,
					/obj/item/weapon/wrench,
					/obj/item/weapon/weldingtool,
					/obj/item/device/analyzer,
					/obj/item/weapon/wirecutters,
					/obj/item/device/multitool,
					/obj/item/weapon/crowbar,
					/obj/item/device/t_scanner
					),
				"upgrade" = list("goodtools", "toolbelts", "devices"),
				"degrade" = list("trash")
			),
		"devices" = list(
				"types" = subtypesof(/obj/item/device) - typesof(/obj/item/device/drop_caller) - list(/obj/item/device/radio/uplink, /obj/item/device/scp113, /obj/item/device/uplink, /obj/item/device/wormhole_jaunter),
				"upgrade" = list("goodtools", "trash"),
				"degrade" = list("tools")
			),
		"trash" = list(
				"types" = list(
					/obj/item/stack/sheet/metal,
					/obj/item/stack/sheet/glass,
					/obj/item/stack/rods,
					/obj/item/weapon/shard
					) + subtypesof(/obj/item/trash),
				"upgrade" = list("tools", "clothes"),
				"degrade" = list()
			),
		"teir1guns" = list(
				"types" = subtypesof(/obj/item/weapon/gun/projectile) + list(/obj/item/weapon/gun/syringe, /obj/item/weapon/gun/energy/stunrevolver, /obj/item/weapon/gun/energy/taser) - typesof(/obj/item/weapon/gun/projectile/shotgun) - typesof(/obj/item/weapon/gun/projectile/automatic) - list(/obj/item/weapon/gun/projectile/revolver/rocketlauncher, /obj/item/weapon/gun/projectile/heavyrifle, /obj/item/weapon/gun/projectile/revolver/mateba),
				"upgrade" = list("teir2guns"),
				"degrade" = list("trash")
			),
		"teir2guns" = list(
				"types" = typesof(/obj/item/weapon/gun/projectile/shotgun) + typesof(/obj/item/weapon/gun/projectile/automatic) + typesof(/obj/item/weapon/gun/energy) +subtypesof(/obj/item/weapon/gun/syringe) - typesof(/obj/item/weapon/gun/energy/meteorgun) - list(/obj/item/weapon/gun/energy/gun/nuclear, /obj/item/weapon/gun/energy/stunrevolver, /obj/item/weapon/gun/energy/taser, /obj/item/weapon/gun/projectile/revolver/rocketlauncher, /obj/item/weapon/gun/projectile/heavyrifle),
				"upgrade" = list("teir3guns"),
				"degrade" = list("teir1guns")
			),
		"teir3guns" = list(
				"types" = list(/obj/item/weapon/gun/energy/gun/nuclear, /obj/item/weapon/gun/projectile/revolver/rocketlauncher, /obj/item/weapon/gun/projectile/heavyrifle, /obj/item/weapon/gun/grenadelauncher),
				"upgrade" = list("trash"),
				"degrade" = list("teir2guns")
			),
	)

	//START_PROCESSING(SSobj, src)

/obj/machinery/scp914/Destroy()
	QDEL_NULL(input_obj)
	QDEL_NULL(output_obj)
	QDEL_NULL(left_obj)
	QDEL_NULL(right_obj)
	//STOP_PROCESSING(SSobj, src)
	return ..()

/obj/machinery/scp914/proc/get_category(obj/item/I)
	for(var/category in item_tree)
		var/list/category_obj = item_tree[category]
		for(var/e in category_obj["types"])
			if((I.type == e))
				return category
	return null

/obj/machinery/scp914/proc/process_human(mob/living/carbon/human/H, mode)
	if(mode == "1:1")
		H.gender = pick(MALE, FEMALE)
		if(H.gender == MALE)
			H.name = pick(first_names_male)
		else
			H.name = pick(first_names_female)
		H.name += " [pick(last_names)]"
		H.real_name = H.name
		var/datum/preferences/A = new()	//Randomize appearance for the human
		A.randomize_appearance_for(H)
		H.h_style = random_hair_style(H.gender, H.species.name)
		H.f_style = random_facial_hair_style(H.gender, H.species.name)
		H.update_hair()
		to_chat(H, "<span class='notice'>You feel like a completely different person</span>")
		H.forceMove(output_obj)
		to_output += H
		return
	if(mode == "Coarse")
		to_chat(H, "<span class='warning'>OUCH</span>")
		H.forceMove(src)
		for (var/i in 1 to rand(1,3))
			if(prob(50))
				H.adjustBruteLoss(20)
			else
				H.adjustFireLoss(20)
		H.forceMove(output_obj)
		to_output += H
		return
	if(mode == "Rough")
		to_chat(H, "<span class='warning'>OUCH</span>")
		H.forceMove(src)
		for (var/i in 1 to rand(7,8))
			if(prob(50))
				H.adjustBruteLoss(20)
			else
				H.adjustFireLoss(20)
		H.forceMove(output_obj)
		to_output += H
		return
	if(mode == "Fine")
		to_chat(H, "<span class='notice'>I feel better</span>")
		H.heal_overall_damage(H.getBruteLoss(), H.getFireLoss())
		H.restore_blood()
		H.restore_all_bodyparts()
		H.forceMove(output_obj)
		H.blinded = 0
		H.eye_blind = 0
		H.eye_blurry = 0
		H.ear_deaf = 0
		H.ear_damage = 0
		if(H.stat == DEAD)
			H.tod = worldtime2text()
			H.timeofdeath = world.time
		to_output += H
		return
	if(mode == "Very fine")
		var/list/variants = list("revive", "species","mutations")
		var/variant = pick(variants)
		if(variant == "revive")
			H.revive()
			H.remove_any_mutations()
			domutcheck(H, null)
			to_chat(H, "<span class='notice'>I feel alive</span>")
			H.forceMove(output_obj)
			to_output += H
			return
		if(variant == "species" && (H.species.name in list(HUMAN,UNATHI,TAJARAN,SKRELL)))
			to_chat(H, "<span class='notice'>What Am I??</span>")
			H.set_species(pick(list(HUMAN,UNATHI,TAJARAN,SKRELL) - H.species.name), FALSE, TRUE)
			H.h_style = random_hair_style(H.gender, H.species.name)
			H.f_style = random_facial_hair_style(H.gender, H.species.name)
			H.update_hair()
			H.forceMove(output_obj)
			to_output += H
			return
		if(variant == "mutations")
			to_chat(H, "<span class='notice'>Something is changing inside me</span>")
			for (var/i in 1 to rand(1,4))
				if(prob(10))
					randmutb(H)
				else
					randmutg(H)
			domutcheck(H, null)
			H.forceMove(output_obj)
			to_output += H
			return


	H.forceMove(output_obj)
	to_output += H

/obj/machinery/scp914/proc/process_item(obj/item/I, mode)
	if(mode == "1:1")
		var/category = get_category(I)
		if(category)
			var/newtype = pick(item_tree[category]["types"])
			var/newitem = new newtype(output_obj)
			qdel(I)
			to_output += newitem
			return
	if(mode == "Fine")
		to_output += upgrade_item(I)
		return
	if(mode == "Coarse")
		to_output += degrade_item(I)
		return
	if(mode == "Rough")
		for (var/i in 1 to rand(1,3))
			if(prob(80))
				I = degrade_item(I)
			else
				I = upgrade_item(I)
		to_output += I
		return
	if(mode == "Very fine")
		for (var/i in 1 to rand(1,3))
			if(prob(80))
				I = upgrade_item(I)
			else
				I = degrade_item(I)
		to_output += I
		return

	I.forceMove(output_obj)
	to_output += I

/obj/machinery/scp914/proc/upgrade_item(obj/item/I)
	var/category = get_category(I)
	if(category)
		var/category_obj = item_tree[category]
		if(category_obj["upgrade"] && category_obj["upgrade"].len > 0)
			var/newcategory = pick(category_obj["upgrade"])

			var/newtype = pick(item_tree[newcategory]["types"])
			var/newitem = new newtype(output_obj)
			qdel(I)
			return newitem
	I.forceMove(output_obj)
	return I

/obj/machinery/scp914/proc/degrade_item(obj/item/I)
	var/category = get_category(I)
	if(category)
		var/category_obj = item_tree[category]
		if(category_obj["degrade"] && category_obj["degrade"].len > 0)
			var/newcategory = pick(category_obj["degrade"])

			var/newtype = pick(item_tree[newcategory]["types"])
			var/newitem = new newtype(output_obj)
			qdel(I)
			return newitem
	I.forceMove(output_obj)
	return I

/obj/machinery/scp914/attack_hand(mob/user)
	if(active)
		to_chat(user, "<span class='notice'>The machine seems to be busy</span>")
		return

	var/picked = input("Select mode", "Select mode")as null|anything in list("Rough", "Coarse", "1:1", "Fine", "Very fine")
	if(active)
		to_chat(user, "<span class='notice'>The machine seems to be busy</span>")
		return
	if(!picked || !in_range(user, src))
		return
	active = TRUE
	input_obj.icon_state = "in_closed"
	output_obj.icon_state = "out_closed"
	input_obj.density = 1
	output_obj.density = 1
	var/process_mode = picked
	playsound(loc, 'sound/effects/gibber.ogg', 100, 1)
	visible_message("<span class='warning'>Machine's gears start to move</span>")

	items_to_process = list()
	to_output = list()
	for(var/obj/item/I in input_obj.loc.contents)
		I.forceMove(input_obj)
		items_to_process += I
	for(var/mob/living/carbon/human/H in input_obj.loc.contents)
		H.forceMove(input_obj)
		humans_to_process += H

	spawn(process_time/2)
		playsound(loc, 'sound/effects/gibber.ogg', 100, 1)
		for(var/obj/item/I in items_to_process)
			process_item(I, process_mode)
		items_to_process = list()
		for(var/mob/living/carbon/human/H in humans_to_process)
			process_human(H, process_mode)
		humans_to_process = list()

		spawn(process_time/2)
			for(var/obj/A in to_output)
				A.forceMove(output_obj.loc)
			for(var/mob/A in to_output)
				A.forceMove(output_obj.loc)
			to_output = list()
			input_obj.icon_state = "in"
			output_obj.icon_state = "out"
			active = FALSE
			input_obj.density = 0
			output_obj.density = 0
			playsound(loc, 'sound/machines/ding.ogg', 60, 1)
