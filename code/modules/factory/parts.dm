/obj/item/manufacturing_parts
	name = "manufacturing parts"
	desc = "детали для сборки"
	icon = 'icons/obj/factory.dmi'
	icon_state = "wood_2"

	var/list/steps = list()
	var/step = 1

	var/parts_state

	var/product_type

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
		if("cut")
			if(!iscutter(I))
				return
			if(!I.use_tool(src, user, 30, volume = 75, quality = QUALITY_CUTTING))
				return

		if("screw")
			if(!isscrewing(I))
				return
			if(!I.use_tool(src, user, 30, volume = 75, quality = QUALITY_SCREWING))
				return

		if("wrench")
			if(!iswrenching(I))
				return
			if(!I.use_tool(src, user, 30, volume = 75, quality = QUALITY_WRENCHING))
				return

		if("weld")
			if(!iswelding(I))
				return
			if(!I.use_tool(src, user, 30, volume = 75, quality = QUALITY_WELDING))
				return

		if("coil")
			if(!iscoil(I))
				return
			if(!I.use_tool(src, user, 30, amount = 1, volume = 75))
				return

		if("pulse")
			if(!ispulsing(I))
				return
			if(!I.use_tool(src, user, 30, volume = 75, quality = QUALITY_PULSING))
				return

		if("sew")
			if(!issewing(I))
				return
			if(!I.use_tool(src, user, 30, amount = 1, volume = 75))
				return
		else
			return

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

/obj/item/manufacturing_parts/wood
	steps = list("cut", "screw")

	parts_state = "wood"

/obj/item/manufacturing_parts/metal
	steps = list("cut", "weld", "wrench")

	parts_state = "metal"

/obj/item/manufacturing_parts/electric
	steps = list("coil", "weld", "pulse", "screw")

	parts_state = "electric"

/obj/item/manufacturing_parts/cloth
	steps = list("cut", "sew", "sew", "sew")

	parts_state = "cloth"
