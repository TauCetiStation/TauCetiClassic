/obj/item/weapon/grenade/chem_grenade
	name = "grenade casing"
	cases = list("граната", "гранаты", "гранате", "гранату", "гранатой", "гранате")
	icon_state = "chemg"
	item_state = "flashbang"
	desc = "Химическая граната ручного изготовления."
	w_class = SIZE_TINY
	force = 2.0
	flags = HEAR_TALK
	var/stage = 0
	var/state = 0
	var/path = 0
	var/obj/item/device/assembly_holder/detonator = null
	var/list/beakers = list()
	var/list/allowed_containers = list(/obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/reagent_containers/glass/bottle)
	var/affected_area = 3

/obj/item/weapon/grenade/chem_grenade/atom_init()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src

/obj/item/weapon/grenade/chem_grenade/attack_self(mob/user)
	if(!stage || stage==1)
		if(detonator)
//				detonator.loc=src.loc
			detonator.detached()
			usr.put_in_hands(detonator)
			detonator=null
			stage=0
			icon_state = initial(icon_state)
		else if(beakers.len)
			for(var/obj/B in beakers)
				if(istype(B))
					beakers -= B
					user.put_in_hands(B)
		name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"

	if(stage > 1)
		..()

/obj/item/weapon/grenade/chem_grenade/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/assembly_holder) && (!stage || stage==1) && path != 2)
		var/obj/item/device/assembly_holder/det = I
		if(istype(det.a_left,det.a_right.type) || (!isigniter(det.a_left) && !isigniter(det.a_right)))
			to_chat(user, "<span class='red'>В корпусе гранаты должен быть воспламенитель.</span>")
			return
		if(!det.secured)
			to_chat(user, "<span class='red'>Корпус гранаты необходимо скрепить отверткой.</span>")
			return
		path = 1
		to_chat(user, "<span class='notice'>Вы помещаете [CASE(I, ACCUSATIVE_CASE)] в корпус гранаты.</span>")
		playsound(src, 'sound/items/Screwdriver2.ogg', VOL_EFFECTS_MASTER)
		user.drop_from_inventory(det, src)
		detonator = det
		if(istimer(det.a_left))
			var/obj/item/device/assembly/timer/T = det.a_left
			det_time = T.time * 10
		else if(istimer(det.a_right))
			var/obj/item/device/assembly/timer/T = det.a_right
			det_time = T.time * 10
		icon_state = initial(icon_state) +"_ass"
		name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
		stage = 1

	else if(isscrewing(I) && path != 2)
		if(stage == 1)
			path = 1
			if(!detonator)
				det_time = 1
			if(beakers.len)
				to_chat(user, "<span class='notice'>Вы скрепляете корпус гранаты.</span>")
				name = "grenade"
			else
//					user << "<span class='warning'>You need to add at least one beaker before locking the assembly.</span>"
				to_chat(user, "<span class='notice'>Вы скрепляете пустой корпус.</span>")
				name = "fake grenade"
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			icon_state = initial(icon_state) +"_locked"
			stage = 2
		else if(stage == 2)
			if(active && prob(95))
				to_chat(user, "<span class='red'>Вы активируете гранату!</span>")
				prime()
				return
			else
				to_chat(user, "<span class='notice'>Вы открываете корпус гранаты.</span>")
				playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
				name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
				icon_state = initial(icon_state) + (detonator?"_ass":"")
				stage = 1
				active = 0

	else if(is_type_in_list(I, allowed_containers) && (!stage || stage==1) && path != 2)
		path = 1
		if(beakers.len == 2)
			to_chat(user, "<span class='red'>В гранату не поместится больше сосудов.</span>")
			return
		else
			if(I.reagents && I.reagents.total_volume)
				to_chat(user, "<span class='notice'>Вы помещаете [CASE(I, ACCUSATIVE_CASE)] в корпус гранаты.</span>")
				user.drop_from_inventory(I, src)
				beakers += I
				stage = 1
				name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
			else
				to_chat(user, "<span class='red'> В [CASE(I, DATIVE_CASE)] ничего нет.</span>")
	else
		return ..()

/obj/item/weapon/grenade/chem_grenade/examine(mob/user)
	..()
	if(src in user && detonator)
		to_chat(user, "С закрепленным [CASE(detonator, ABLATIVE_CASE)]")

/obj/item/weapon/grenade/chem_grenade/activate(mob/user)
	if(active) return

	if(detonator)
		if(!isigniter(detonator.a_left))
			detonator.a_left.activate()
			active = 1
		if(!isigniter(detonator.a_right))
			detonator.a_right.activate()
			active = 1
	if(active)
		playsound(src, activate_sound, VOL_EFFECTS_MASTER, null, FALSE, null, -3)
		icon_state = initial(icon_state) + "_active"

		if(user)
			msg_admin_attack("[user.name] ([user.ckey]) primed \a [src]", user)

	return

/obj/item/weapon/grenade/chem_grenade/proc/primed(primed = 1)
	if(active)
		icon_state = initial(icon_state) + (primed?"_primed":"_active")

/obj/item/weapon/grenade/chem_grenade/prime()
	if(!stage || stage<2) return

	//if(prob(reliability))
	var/has_reagents = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
		if(G.reagents.total_volume) has_reagents = 1

	active = 0
	if(!has_reagents)
		icon_state = initial(icon_state) +"_locked"
		playsound(src, 'sound/items/Screwdriver2.ogg', VOL_EFFECTS_MASTER)
		return

	playsound(src, 'sound/effects/bamf.ogg', VOL_EFFECTS_MASTER)

	for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
		G.reagents.trans_to(src, G.reagents.total_volume)

	if(src.reagents.total_volume) //The possible reactions didnt use up all reagents.
		var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
		steam.set_up(10, 0, get_turf(src))
		steam.attach(src)
		steam.start()

		for(var/atom/A in view(affected_area, src.loc))
			if( A == src ) continue
			reagents.reaction(A, 1, 10)

	if(iscarbon(loc))		//drop dat grenade if it goes off in your hand
		var/mob/living/carbon/C = loc
		C.drop_from_inventory(src)
		C.throw_mode_off()

	invisibility = INVISIBILITY_MAXIMUM //Why am i doing this?
	spawn(50)		   //To make sure all reagents can work
		qdel(src)	   //correctly before deleting the grenade.

/obj/item/weapon/grenade/chem_grenade/Crossed(atom/movable/AM)
	. = ..()
	if (detonator)
		detonator.Crossed(AM)

/obj/item/weapon/grenade/chem_grenade/hear_talk(mob/living/M, msg)
	if (detonator)
		detonator.hear_talk(M,msg)

/obj/item/weapon/grenade/chem_grenade/on_found(mob/finder)
	if(detonator)
		detonator.on_found(finder)

/obj/item/weapon/grenade/chem_grenade/large
	name = "large chem grenade"
	desc = "Крупная граната, поражающая большую область."
	icon_state = "large_grenade"
	allowed_containers = list(/obj/item/weapon/reagent_containers/glass)
	origin_tech = "combat=3;materials=3"
	affected_area = 4


///////Metalfoam
/obj/item/weapon/grenade/chem_grenade/metalfoam
	name = "metal-foam grenade"
	desc = "Используется для экстренной герметизации."
	path = 1
	stage = 2

/obj/item/weapon/grenade/chem_grenade/metalfoam/atom_init()
	. = ..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("aluminum", 30)
	B2.reagents.add_reagent("foaming_agent", 10)
	B2.reagents.add_reagent("pacid", 10)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"


///////Incendiary
/obj/item/weapon/grenade/chem_grenade/incendiary
	name = "incendiary grenade"
	desc = "Используется для очистки помещений от живых существ."
	path = 1
	stage = 2

/obj/item/weapon/grenade/chem_grenade/incendiary/atom_init()
	. = ..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("fuel",20)
	B1.reagents.add_reagent("aluminum", 15)
	B2.reagents.add_reagent("phoron", 15)
	B2.reagents.add_reagent("sacid", 15)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"


///////Antiweed
/obj/item/weapon/grenade/chem_grenade/antiweed
	name = "weedkiller grenade"
	desc = "Используется для очистки больших площадей от инвазивных видов растений. Содержимое под давлением. Не вдыхайте содержимое напрямую."
	path = 1
	stage = 2

/obj/item/weapon/grenade/chem_grenade/antiweed/atom_init()
	. = ..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("plantbgone", 25)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = "grenade"


///////Cleaner
/obj/item/weapon/grenade/chem_grenade/cleaner
	name = "cleaner grenade"
	desc = "БЛАМ! – пенящееся чистящее средство в специальном аппликаторе для быстрой очистки больших площадей."
	stage = 2
	path = 1

/obj/item/weapon/grenade/chem_grenade/cleaner/atom_init()
	. = ..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("fluorosurfactant", 40)
	B2.reagents.add_reagent("water", 40)
	B2.reagents.add_reagent("cleaner", 10)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"


///////Teargas
/obj/item/weapon/grenade/chem_grenade/teargas
	name = "teargas grenade"
	desc = "Используется для подавления беспорядков. Содержимое под давлением. Не вдыхайте содержимое напрямую."
	stage = 2
	path = 1

/obj/item/weapon/grenade/chem_grenade/teargas/atom_init()
	. = ..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("condensedcapsaicin", 25)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"

///////Acid
/obj/item/weapon/grenade/chem_grenade/acid
	name = "Acid grenade"
	desc = "Используется для сжигания брони, вещей и человеческой плоти."
	stage = 2
	path = 1

/obj/item/weapon/grenade/chem_grenade/acid/atom_init()
	. = ..()
	var/obj/item/weapon/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/large/B2 = new(src)
	B1.reagents.add_reagent("sacid", 50)
	B1.reagents.add_reagent("sugar", 50)
	B1.reagents.add_reagent("potassium", 50)
	B2.reagents.add_reagent("pacid", 100)
	B2.reagents.add_reagent("phosphorus", 50)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"

///Drugs
/obj/item/weapon/grenade/chem_grenade/drugs
	name = "Drugs grenade"
	desc = "Граната с запрещенными химическими веществами, используемая в качестве наркотика."
	path = 1
	stage = 2

/obj/item/weapon/grenade/chem_grenade/drugs/atom_init()
	. = ..()
	var/obj/item/weapon/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/large/B2 = new(src)
	B1.reagents.add_reagent("space_drugs", 50)
	B1.reagents.add_reagent("sugar", 50)
	B1.reagents.add_reagent("potassium", 50)
	B2.reagents.add_reagent("space_drugs", 100)
	B2.reagents.add_reagent("phosphorus", 50)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"
