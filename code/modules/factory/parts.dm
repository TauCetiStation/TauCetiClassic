/obj/item/manufacturing_parts
	name = "manufacturing parts"
	desc = "детали для сборки"
	icon = 'icons/obj/factory.dmi'
	icon_state = "wood_2"

	var/list/steps = list()
	var/step = 1

	var/parts_state

	var/product_type

	var/dismantle_types = list()

/obj/item/manufacturing_parts/atom_init(mapload)
	. = ..()

	if(product_type)
		if(islist(product_type))
			product_type = pick(product_type)

	update_icon()

/obj/item/manufacturing_parts/attackby(obj/item/I, mob/user)
	if(user.a_intent == INTENT_HARM)
		return ..()

	var/obj/structure/table/table = locate(/obj/structure/table, get_turf(src))
	if(!table)
		to_chat(user, "Положите детали на стол.")
		return

	switch(steps[step])
		if(QUALITY_CUTTING)
			if(!iscutter(I))
				return
			if(!I.use_tool(src, user, 30, volume = 75, quality = QUALITY_CUTTING))
				return

		if(QUALITY_SCREWING)
			if(!isscrewing(I))
				return
			if(!I.use_tool(src, user, 30, volume = 75, quality = QUALITY_SCREWING))
				return

		if(QUALITY_WRENCHING)
			if(!iswrenching(I))
				return
			if(!I.use_tool(src, user, 30, volume = 75, quality = QUALITY_WRENCHING))
				return

		if(QUALITY_WELDING)
			if(!iswelding(I))
				return
			if(!I.use_tool(src, user, 30, volume = 75, quality = QUALITY_WELDING))
				return

		if(QUALITY_COILING)
			if(!iscoil(I))
				return
			if(!I.use_tool(src, user, 30, amount = 1, volume = 75, quality = QUALITY_COILING))
				return

		if(QUALITY_PULSING)
			if(!ispulsing(I))
				return
			if(!I.use_tool(src, user, 30, volume = 75, quality = QUALITY_PULSING))
				return

		if(QUALITY_SEWING)
			if(!issewing(I))
				return
			if(!I.use_tool(src, user, 30, amount = 1, volume = 75, quality = QUALITY_SEWING))
				return
		else
			return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/BP = H.get_bodypart(BP_ACTIVE_ARM)
		if(!BP)
			return

		BP.adjust_pumped(1, 15)


	step++
	if(step > steps.len)
		finish_assemble()
		return
	update_icon()

/obj/item/manufacturing_parts/update_icon()
	icon_state = "[parts_state]_[step]"

/obj/item/manufacturing_parts/proc/finish_assemble()
	var/atom/movable/thing = new product_type(get_turf(src))
	if(isitem(thing))
		thing.pixel_x = pixel_x
		thing.pixel_y = pixel_y

	qdel(src)

/obj/item/manufacturing_parts/proc/generate_instructions()
	var/obj/item/weapon/paper/paper = new(loc)
	var/obj/item/weapon/pen/Pen = new
	paper.name = "инструкция по сборке"

	var/dat = @"[center][large][b]Порядок сборки:[/b][/large][/center][br]"
	dat += @"[list]"
	for(var/manufacture_step in steps)
		dat += @"[*]"
		dat += "[manufacture_step]"
	dat += @"[/list]"

	paper.info = paper.parsepencode(dat, Pen)
	paper.updateinfolinks()
	paper.update_icon()

/obj/item/manufacturing_parts/wash_act()
	var/iterations = rand(0, 2)
	if(iterations)
		for(var/i = 1; i <= iterations; i++)
			var/dismantle_type = pick(dismantle_types)
			new dismantle_type(loc)

	for(var/i = 1; i <= (5 - iterations); i++)
		new /obj/item/weapon/scrap_lump(loc)

	qdel(src)

/obj/item/manufacturing_parts/wood
	steps = list(QUALITY_CUTTING, QUALITY_SCREWING)

	parts_state = "wood"

	dismantle_types = list(/obj/item/stack/sheet/wood, /obj/item/weapon/table_parts/wood, /obj/item/stack/tile/wood, /obj/item/weapon/grown/log, /obj/random/meds/medical_pills)

/obj/item/manufacturing_parts/metal
	steps = list(QUALITY_CUTTING, QUALITY_WELDING, QUALITY_WRENCHING)

	parts_state = "metal"

	dismantle_types = list(/obj/item/stack/sheet/metal, /obj/item/stack/sheet/plasteel, /obj/item/stack/rods, /obj/item/stack/sheet/mineral/plastic, /obj/random/tools/tech_supply)

/obj/item/manufacturing_parts/electric
	steps = list(QUALITY_COILING, QUALITY_WELDING, QUALITY_PULSING, QUALITY_SCREWING)

	parts_state = "electric"

	dismantle_types = list(/obj/item/stack/sheet/metal, /obj/item/stack/sheet/mineral/plastic, /obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/mineral/silver, /obj/item/stack/sheet/mineral/platinum, /obj/random/science/science_supply)

/obj/item/manufacturing_parts/cloth
	steps = list(QUALITY_CUTTING, QUALITY_SEWING, QUALITY_SEWING, QUALITY_SEWING)

	parts_state = "cloth"

	dismantle_types = list(/obj/item/stack/sheet/cloth, /obj/item/stack/sheet/leather, /obj/random/cloth/shittysuit)
