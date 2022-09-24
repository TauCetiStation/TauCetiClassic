
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox0"
	name = "Ore Box"
	desc = "A heavy box used for storing ore."
	density = TRUE
	var/max_integrity = 150
	var/integrity = 100
	var/last_update = 0
	var/list/stored_ore = list()

	resistance_flags = CAN_BE_HIT

/obj/structure/ore_box/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/ore))
		user.drop_from_inventory(W, src)
	else if(istype(W, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = W
		user.SetNextMove(CLICK_CD_INTERACT)
		for(var/obj/item/weapon/ore/O in S.contents)
			S.remove_from_storage(O, src) //This will move the item to this item's contents
		to_chat(user, "<span class='notice'>You empty the satchel into the box.</span>")
	else if(istype(W, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = W
		var/choosed_quantity = round(input("How many sheets do you want to add?") as num)
		if(!S)
			return
		if(choosed_quantity > S.get_amount())
			choosed_quantity = S.get_amount()
		var/int_amount
		if(istype(S, /obj/item/stack/sheet/wood))
			int_amount = (5 * choosed_quantity)
		if(istype(S, /obj/item/stack/sheet/metal))
			int_amount = (2 * choosed_quantity)	//metal is infinite in asteroid, no need much repair wood box
		if(istype(S, /obj/item/stack/sheet/plasteel))
			int_amount = (40 * choosed_quantity)
		if(can_increase_integrity(int_amount, user))
			if(S.use(choosed_quantity))
				increase_integrity(int_amount)
				to_chat(user, "The box is reinforced by [S]")

/obj/structure/ore_box/proc/dump_box_contents()
	for (var/obj/item/weapon/ore/O as anything in contents)
		O.Move(loc)

/obj/structure/ore_box/deconstruct(disassembled)
	dump_box_contents()
	if(flags & NODECONSTRUCT)
		return ..()
	new /obj/item/stack/sheet/wood(loc, 4)
	..()

/obj/structure/ore_box/Entered(atom/movable/ORE)
	if(istype(ORE, /obj/item/weapon/ore))
		stored_ore[ORE.name]++

/obj/structure/ore_box/Exited(atom/movable/ORE)
	if(istype(ORE, /obj/item/weapon/ore))
		stored_ore[ORE.name]--
	if(!contents.len)
		stored_ore = list()

/obj/structure/ore_box/attack_hand(mob/user)
	var/dat = ""
	for(var/ore in stored_ore)
		dat += "[ore]: [stored_ore[ore]]<br>"

	dat += "<br><br><A href='?src=\ref[src];removeall=1'>Empty box</A>"

	var/datum/browser/popup = new(user, "orebox", "The contents of the ore box reveal...")
	popup.set_content(dat)
	popup.open()

	return

/obj/structure/ore_box/attack_animal(mob/living/simple_animal/animal)
	. = ..()
	if(istype(animal, /mob/living/simple_animal/hostile/asteroid))
		take_damage(animal.melee_damage)

/obj/structure/ore_box/examine(mob/user)
	..()

	// Borgs can now check contents too.
	if((!ishuman(user)) && (!isrobot(user)))
		return

	if(!Adjacent(user)) //Can only check the contents of ore boxes if you can physically reach them.
		return

	add_fingerprint(user)
	if(integrity)
		if(integrity >= 40)
			to_chat(user, "<span class='notice'>looks reinforced</span>")
		if(isSeriouslyDamaged())
			to_chat(user, "<span class='warning'>looks seriously damaged</span>")

	if(!contents.len)
		to_chat(user, "It is empty.")
		return

	to_chat(user, "It holds:")
	for(var/ore in stored_ore)
		to_chat(user, "- [stored_ore[ore]] [ore]")
	return

/obj/structure/ore_box/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)
	if(href_list["removeall"])
		for (var/obj/item/weapon/ore/O in contents)
			O.Move(src.loc)
		to_chat(usr, "<span class='notice'>You empty the box</span>")
	updateUsrDialog()
	return

/obj/structure/ore_box/verb/empty_box()
	set name = "Empty Ore Box"
	set category = "Object"
	set src in view(1)

	if(!ishuman(usr)) //Only living, intelligent creatures with hands can empty ore boxes.
		to_chat(usr, "<span class='warning'>You are physically incapable of emptying the ore box.</span>")
		return

	if(usr.incapacitated())
		return

	if(!Adjacent(usr)) //You can only empty the box if you can physically reach it
		to_chat(usr, "You cannot reach the ore box.")
		return

	add_fingerprint(usr)

	if(contents.len < 1)
		to_chat(usr, "<span class='warning'>The ore box is empty</span>")
		return

	dump_box_contents()

	to_chat(usr, "<span class='notice'>You empty the ore box</span>")

	return

/obj/structure/ore_box/proc/take_damage(amount)
	if(integrity <= 0 || max_integrity <= 0 || amount <= 0)
		return
	integrity -= amount
	check_integrity()

/obj/structure/ore_box/proc/can_increase_integrity(amount, mob/user)
	if(amount + integrity >= max_integrity)
		to_chat(user, "<span class='notice'>There is too much for ore box</span>")
		return FALSE
	if(max_integrity <= 0)
		return FALSE
	if(integrity <= 0)
		return FALSE
	return TRUE

/obj/structure/ore_box/proc/increase_integrity(amount)
	integrity += amount
	if(integrity > max_integrity)
		integrity = max_integrity

/obj/structure/ore_box/proc/check_integrity()
	if(integrity <= 0)
		broke_box()
	else if(integrity < 40)
		make_hole()
	else if(integrity >= 40)
		repair_hole()

/obj/structure/ore_box/proc/broke_box()
	if(contents.len > 0)
		for(var/obj/item/weapon/ore/O in contents)
			O.forceMove(loc)
	new /obj/item/stack/sheet/wood(loc, 4)
	new /obj/item/stack/sheet/metal(loc)
	STOP_PROCESSING(SSobj, src)
	qdel(src)

/obj/structure/ore_box/proc/make_hole()
	if(isSeriouslyDamaged())
		return
	START_PROCESSING(SSobj, src)

/obj/structure/ore_box/proc/repair_hole()
	if(!isSeriouslyDamaged())
		return
	STOP_PROCESSING(SSobj, src)

/obj/structure/ore_box/proc/isSeriouslyDamaged()
	if(integrity <= 0)
		return FALSE
	else if(integrity < 40)
		return TRUE
	return FALSE

/obj/structure/ore_box/process()
	if(contents.len > 0)
		for(var/obj/item/weapon/ore/O in contents)
			if(prob(20))
				O.forceMove(loc)
	check_integrity()
