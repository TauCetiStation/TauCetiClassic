#define COMPOST_PER_AMOUNT 25
#define COMPOST_PER_REAGENT 2

/obj/structure/composter
	name = "composter"
	cases = list("компостер", "компостера", "компостеру", "компостер", "компостером", "компостере")
	desc = "Компостирует компост."

	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "composter"

	density = TRUE
	anchored = TRUE

	max_integrity = 150
	resistance_flags = CAN_BE_HIT

	var/save_id = "common_id"
	var/compost_amount = 0

/obj/structure/composter/botany
	save_id = "botany"

/obj/structure/composter/examine(mob/user)
	..()

	if(!user.Adjacent(src))
		return

	flick("composter_opening", src)
	if(do_after(user, 1 SECONDS, target = src))
		to_chat(user, "Высота компоста примерно [round(compost_amount / 5)]%.[contents.len ? " Сверху лежит начавшая гнить еда." : ""]")

/obj/structure/composter/atom_init()
	. = ..()

	AddComponent(/datum/component/continuity_object, CALLBACK(src, PROC_REF(Write_Memory)), CALLBACK(src, PROC_REF(Read_Memory)), "/objects/composters/composter_[save_id]", list(
			"compost_amount" = new /datum/continuity_field/int(
				min_num = 0,
				max_num = 500
			)
		))

/obj/structure/composter/proc/Write_Memory()
	var/list/preserved_reagents = list()

	for(var/obj/item/weapon/reagent_containers/food/snacks/to_compost in contents)
		for(var/datum/reagent/reagent in to_compost.reagents.reagent_list)
			if(!preserved_reagents[reagent.id])
				preserved_reagents[reagent.id] = reagent.volume
				continue

			preserved_reagents[reagent.id] += reagent.volume

	var/nutriment_amount = preserved_reagents["nutriment"] ? preserved_reagents["nutriment"] : 0
	var/protein_amount = preserved_reagents["protein"] ? preserved_reagents["protein"] : 0
	var/plantmatter_amount = preserved_reagents["plantmatter"] ? preserved_reagents["plantmatter"] : 0
	var/dairy_amount = preserved_reagents["dairy"] ? preserved_reagents["dairy"] : 0

	compost_amount += round((nutriment_amount - protein_amount * 2 + plantmatter_amount * 2 - dairy_amount) * COMPOST_PER_REAGENT) //nutriment and plantmatter is good, protein and diary is bad

	return list("compost_amount" = clamp(compost_amount, 0, 500))

/obj/structure/composter/proc/Read_Memory(list/save_data)
	compost_amount = save_data["compost_amount"]

/obj/structure/composter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks) || istype(I, /obj/item/nutrient/compost))
		flick("composter_opening", src)
		user.drop_from_inventory(I, src)
		visible_message("[user] выбрасывает [CASE(I, ACCUSATIVE_CASE)] в [CASE(src, ACCUSATIVE_CASE)]", "<span class='notice'>Вы выбрасываете [CASE(I, ACCUSATIVE_CASE)] в [CASE(src, ACCUSATIVE_CASE)].</span>")
		if(istype(I, /obj/item/nutrient/compost))
			compost_amount += COMPOST_PER_AMOUNT
			qdel(I)
	else
		return ..()

/obj/structure/composter/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(user.is_busy() || isAI(user))
		return

	if(compost_amount < COMPOST_PER_AMOUNT || !do_after(user, 2 SECONDS, target = src))
		return

	var/obj/item/I = new /obj/item/nutrient/compost(src)
	flick("composter_opening", src)
	user.put_in_hands(I)
	visible_message("[user] копается в [CASE(src, PREPOSITIONAL_CASE)] и достаёт [CASE(I, ACCUSATIVE_CASE)].", "<span class='notice'>Вы копаетесь в [CASE(src, PREPOSITIONAL_CASE)] и достаёте [CASE(I, ACCUSATIVE_CASE)].</span>")
	compost_amount -= COMPOST_PER_AMOUNT


/obj/item/nutrient/compost
	name = "compost"
	cases = list("компост", "компоста", "компосту", "компост", "компостом", "компосте")
	desc = "Пахучая куча из компостной ямы."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "compost"
	mutmod = 0
	yieldmod = 5

#undef COMPOST_PER_REAGENT
#undef COMPOST_PER_AMOUNT
