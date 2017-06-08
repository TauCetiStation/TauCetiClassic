/datum/craft_step
	name = "craft step placeholder"
	desc = "Step Description"

/datum/craft_step/proc/make(var/actiontype, var/actionobj, obj/item/weapon/craft/actionsubj)
	return
/datum/craft_step/sharpen
	desc = "Sharpen your blank."
/datum/craft_step/sharpen/make(var/actiontype, var/actionobj, obj/item/weapon/craft/actionsubj)
	if(actiontype == "attackby")
		if(istype(actionobj, /obj/item/weapon/sharpener))
			. = 0.75
		if(istype(actionobj, /obj/item/weapon/diamond))
			. = 1.25
		if(istype(actionobj, /obj/item/weapon/sandbrick))
			. = 1
	if(.)
		actionsubj.builddescription += "\nSharpened with [actionobj]"
	return

/datum/craft_step/forge
	desc = "Smite your blank."
/datum/craft_step/forge/make(var/actiontype, var/actionobj, obj/item/weapon/craft/actionsubj)
	if(actiontype == "attackby")
		if(istype(actionobj, /obj/item/weapon/extinguisher))
			. = 0.75
		if(istype(actionobj, /obj/item/weapon/toolbox))
			. = 0.75
		if(istype(actionobj, /obj/item/weapon/hammer))
			. = 1.25
	if(.)
		actionsubj.builddescription += "\nSmithed with with [actionobj]"
		actionsubj.heated = 0
	return

/datum/craft_step/heat
	desc = "Heat up your blank."
/datum/craft_step/heat/make(var/actiontype, var/actionobj, obj/item/weapon/craft/actionsubj)
	if(actiontype == "attackby")
		if(istype(actionobj, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/O = actionobj
			if(O.remove_fuel(5,O.loc))
				power = 0.8
	if(actiontype == "afterattack")
		if(istype(actionobj, /obj/machinery/trash_forge))
			if(actionsubj.pinched)
				var/obj/machinery/trash_forge/O = actionobj
				power = actionobj.get_temperature()
			else
				actionsubj.loc << "[actionobj] is too hot withouit forge tongs"
	if(actiontype == "fire_act")
		power = 1
	if(.)
		actionsubj.heated = 1
		actionsubj.builddescription += "\nHeated with with [actionobj]"
	return

/datum/craft_step/handle
	desc = "Add handle to your blank."
/datum/craft_step/handle/make(var/actiontype, var/actionobj, obj/item/weapon/craft/actionsubj)
	if(actiontype == "attackby")
		var/material_name = ""
		if(istype(actionobj, /obj/item/stack/sheet/wood)
			var/obj/item/stack/sheet/wood/O = actionobj
			material_name = "[actionobj]"
			if(O.use(3))
				. = 1
	if(.)
		actionsubj.desc += "\nHandle made of [material_name]"
	return

/datum/craft_step/base
	desc = "Add base material to your blank."
/datum/craft_step/base/make(var/actiontype, var/actionobj, obj/item/weapon/craft/actionsubj)
	if(actiontype == "attackby")
		var/material_name = ""
		var/material_color = ""
		if(istype(actionobj, /obj/item/stack/sheet/mineral)
			var/obj/item/stack/sheet/mineral/AO = actionobj
			material_name = AO.name
			material_color = AO.item_color //not exists yet TODO: Add colors
			var/obj/item/stack/sheet/mineral/O = actionobj
			if(O.use(3)) //TODO: Parametrized material amount
				. = 1 //TODO: Material with different quality
	if(.)
		actionsubj.builddescription += "\nMade of [material_name]"
		actionsubj.base_color = material_color
	return


/obj/item/weapon/craft
	name = "craft step placeholder"
	desc = "You should not see this"
	icon = 'icons/obj/structures/scrap/refine.dmi'
	icon_state = "unrefined"
	var/list/builddescription = list()
	var/list/buildsteps = list()
	var/heated = 0
	var/need_tongs = 0
	var/base_color = "#FFFFFF"
	var/obj/item/weapon/tongs
	w_class = 3
	var/quality = 1
	var/produced_craft = /obj/item/weapon/knife //typepath

/obj/item/weapon/craft/proc/do_build_step(var/actiontype, var/actionobj, obj/item/weapon/craft/actionsubj)
	if(!buildsteps.len)
		return
	var/datum/craft_step/step = buildsteps[0]
	var/craft_result = step.make(actiontype, actionobj, src)
	if(craft_result)
		quality *= craft_result
		buildsteps.Cut(1,0)
	if()

/obj/item/weapon/craft/proc/make_craft()
	if(ishuman(src.loc))
		var/mob/living/carbon/human/H = src.loc
		H.remove_from_mob(src)

	var/obj/item/I = new produced_craft(src.loc)
	I.color = base_color //TODO: Refactor color creation
	I.force *= quality
	I.throw_speed *= quality
	I.throwforce *= quality
	I.throw_range *= quality
	I.desc += src.desc
	if(quality <= 0.5 )
		I.name = "horrible " + I.name
		I.w_class = min(I.w_class + 1, 5)
	if(quality <= 1 && quality > 0.5)
		I.name = "worthless " + I.name
	if(quality <= 1.5 && quality > 1)
		I.name = "fine " + I.name
	if(quality <= 2 && quality > 1.5)
		I.name = "perfect " + I.name
	if(quality > 2)
		I.name = "masterpiece " + I.name
		I.w_class = max(I.w_class - 1, 1)
	qdel(src)

/obj/item/weapon/craft/examine(mob/user)
	..()
	for(var/string in builddescription)
		usr << string

/obj/item/weapon/craft/attack_hand(mob/living/user as mob)
	if(heated) //TODO: Add robot hands check. Add heat resistant gloves check. Add golems check.....
		user << "<span class='notice'>Your hands won't manage the stress of heated metal. You have to use tongs.</span>"
		return
	..()

/obj/item/weapon/craft/attackby(obj/item/I, mob/user, params)
	..()
	if(!tongs && need_tongs)
		if(istype(I, /obj/item/weapon/bonesetter) || istype(I, /obj/item/weapon/tongs) || istype(I, /obj/item/weapon/wirecutters))
			tongs = I
			I.loc = src
	do_build_step("attackby", I, src)


/obj/item/weapon/craft/attack_self(mob/user)
	..()
	if(tongs)
		tongs.loc = src.loc

/obj/item/weapon/craft/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(temperature > T0C+1000)
		do_build_step("fire_act", null, src)

/obj/item/weapon/craft/afterattack(atom/A, mob/user as mob, proximity)
	..()
	do_build_step("afterattack", A, src)

/obj/item/weapon/craft/hammer
	name = "hammer craft blank"
	desc = "Spare parts to create hammer"
	icon = 'icons/obj/structures/scrap/refine.dmi'
	icon_state = "unrefined"
	var/list/buildsteps = list(/datum/craft_step/base, \
								/datum/craft_step/heat, \
								/datum/craft_step/forge, \
								/datum/craft_step/handle)
	var/need_tongs = 1
	var/quality = 1.2 //better quality cause no sharpening step
	var/produced_craft = /obj/item/weapon/hammer

/obj/item/weapon/craft/knife
	name = "knife craft blank"
	desc = "Spare parts to create knife"
	icon = '' //TODO: Add icons
	icon_state = "unrefined"
	var/list/buildsteps = list(/datum/craft_step/base, \
								/datum/craft_step/heat, \
								/datum/craft_step/forge, \
								/datum/craft_step/sharpen, \
								/datum/craft_step/handle)
	var/need_tongs = 1
	var/produced_craft = /obj/item/weapon/knife //typepath

/obj/item/weapon/craft/machete
	name = "machete craft blank"
	desc = "Spare parts to create machete"
	icon = '' //TODO: Add icons
	icon_state = "unrefined"
	var/list/buildsteps = list(/datum/craft_step/base, \
								/datum/craft_step/heat, \
								/datum/craft_step/forge, \
								/datum/craft_step/sharpen, \
								/datum/craft_step/handle)
	var/need_tongs = 1
	var/produced_craft = /obj/item/weapon/machete //typepath

/obj/item/weapon/craft/machete
	name = "machete craft blank"
	desc = "Spare parts to create machete"
	icon = ''//TODO: Add icons
	icon_state = "unrefined"
	var/list/buildsteps = list(/datum/craft_step/base, \
								/datum/craft_step/heat, \
								/datum/craft_step/forge)
	var/need_tongs = 1
	var/produced_craft = /obj/item/weapon/machete //typepath