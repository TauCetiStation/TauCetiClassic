/* Hydroponic stuff
 * Contains:
 *		Sunflowers
 *		Nettle
 *		Deathnettle
 *		Corbcob
 */



/*
 * SeedBag
 */
//uncomment when this is updated to match storage update
/*
/obj/item/weapon/seedbag
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "seedbag"
	name = "Seed Bag"
	desc = "A small satchel made for organizing seeds."
	var/mode = 1;  //0 = pick one at a time, 1 = pick all on tile
	var/capacity = 500; //the number of seeds it can carry.
	slot_flags = SLOT_FLAGS_BELT
	w_class = ITEM_SIZE_TINY
	var/list/item_quants = list()

/obj/item/weapon/seedbag/attack_self(mob/user)
	user.machine = src
	interact(user)

/obj/item/weapon/seedbag/verb/toggle_mode()
	set name = "Switch Bagging Method"
	set category = "Object"

	mode = !mode
	switch (mode)
		if(1)
			to_chat(usr, "The bag now picks up all seeds in a tile at once.")
		if(0)
			to_chat(usr, "The bag now picks up one seed pouch at a time.")

/obj/item/seeds/attackby(obj/item/O, mob/user)
	..()
	if (istype(O, /obj/item/weapon/seedbag))
		var/obj/item/weapon/seedbag/S = O
		if (S.mode == 1)
			for (var/obj/item/seeds/G in locate(src.x,src.y,src.z))
				if (S.contents.len < S.capacity)
					S.contents += G;
					if(S.item_quants[G.name])
						S.item_quants[G.name]++
					else
						S.item_quants[G.name] = 1
				else
					to_chat(user, "<span class='notice'>The seed bag is full.</span>")
					S.updateUsrDialog()
					return
			to_chat(user, "<span class='notice'>You pick up all the seeds.</span>")
		else
			if (S.contents.len < S.capacity)
				S.contents += src;
				if(S.item_quants[name])
					S.item_quants[name]++
				else
					S.item_quants[name] = 1
			else
				to_chat(user, "<span class='notice'>The seed bag is full.</span>")
		S.updateUsrDialog()
	return

/obj/item/weapon/seedbag/interact(mob/user)

	var/dat = "<TT><b>Select an item:</b><br>"

	if (contents.len == 0)
		dat += "<font color = 'red'>No seeds loaded!</font>"
	else
		for (var/O in item_quants)
			if(item_quants[O] > 0)
				var/N = item_quants[O]
				dat += "<FONT color = 'blue'><B>[capitalize(O)]</B>:"
				dat += " [N] </font>"
				dat += "<a href='byond://?src=\ref[src];vend=[O]'>Vend</A>"
				dat += "<br>"

		dat += "<br><a href='byond://?src=\ref[src];unload=1'>Unload All</A>"
		dat += "</TT>"
	user << browse("<HEAD><TITLE>Seedbag Supplies</TITLE></HEAD><TT>[dat]</TT>", "window=seedbag")
	onclose(user, "seedbag")
	return

/obj/item/weapon/seedbag/Topic(href, href_list)
	if(..())
		return

	usr.machine = src
	if ( href_list["vend"] )
		var/N = href_list["vend"]

		if(item_quants[N] <= 0) // Sanity check, there are probably ways to press the button when it shouldn't be possible.
			return

		item_quants[N] -= 1
		for(var/obj/O in contents)
			if(O.name == N)
				O.loc = get_turf(src)
				usr.put_in_hands(O)
				break

	else if ( href_list["unload"] )
		item_quants.Cut()
		for(var/obj/O in contents )
			O.loc = get_turf(src)

	src.updateUsrDialog()
	return

/obj/item/weapon/seedbag/updateUsrDialog()
	var/list/nearby = range(1, src)
	for(var/mob/M in nearby)
		if ((M.client && M.machine == src))
			src.attack_self(M)
*/
/*
 * Sunflower
 */

/obj/item/weapon/grown/sunflower/attack(mob/M, mob/user)
	to_chat(M, "<font color='green'><b>[user]</b> smacks you with a sunflower!</font><font color='yellow'><b>FLOWER POWER</b></font>")
	to_chat(user, "<font color='green'>Your sunflower's </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'> strikes [M]</font>")


/*
 * Nettle
 */
/obj/item/weapon/grown/nettle/pickup(mob/living/carbon/human/user)
	if(!user.gloves)
		to_chat(user, "<span class='warning'>The nettle burns your bare hand!</span>")
		if(istype(user, /mob/living/carbon/human))
			var/obj/item/organ/external/BP = user.bodyparts_by_name[user.hand ? BP_L_ARM : BP_R_ARM]
			BP.take_damage(0, force)
		else
			user.take_bodypart_damage(0, force)

/obj/item/weapon/grown/nettle/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(force > 0)
		force -= rand(1,(force/3)+1) // When you whack someone with it, leaves fall off
		playsound(src, 'sound/weapons/bladeslice.ogg', VOL_EFFECTS_MASTER)
	else
		to_chat(usr, "All the leaves have fallen off the nettle from violent whacking.")
		qdel(src)

/obj/item/weapon/grown/nettle/changePotency(newValue) //-QualityVan
	potency = newValue
	force = round((5+potency/5), 1)

/*
 * Deathnettle
 */

/obj/item/weapon/grown/deathnettle/pickup(mob/living/carbon/human/user)
	if(!user.gloves)
		if(istype(user, /mob/living/carbon/human))
			var/obj/item/organ/external/BP = user.bodyparts_by_name[user.hand ? BP_L_ARM : BP_R_ARM]
			BP.take_damage(0, force)
		else
			user.take_bodypart_damage(0, force)
		if(prob(50))
			user.Paralyse(5)
			to_chat(user, "<span class='warning'>You are stunned by the Deathnettle when you try picking it up!</span>")

/obj/item/weapon/grown/deathnettle/attack(mob/living/carbon/M, mob/user)
	if(!..()) return
	if(istype(M, /mob/living))
		to_chat(M, "<span class='warning'>You are stunned by the powerful acid of the Deathnettle!</span>")

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Had the [src.name] used on them by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] on [M.name] ([M.ckey])</font>")
		msg_admin_attack("[user.name] ([user.ckey]) used the [src.name] on [M.name] ([M.ckey])", user)

		playsound(src, 'sound/weapons/bladeslice.ogg', VOL_EFFECTS_MASTER)

		M.eye_blurry += force/7
		if(prob(20))
			M.Paralyse(force/6)
			M.Weaken(force/15)
		M.drop_item()

/obj/item/weapon/grown/deathnettle/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if (force > 0)
		force -= rand(1,(force/3)+1) // When you whack someone with it, leaves fall off

	else
		to_chat(usr, "All the leaves have fallen off the deathnettle from violent whacking.")
		qdel(src)

/obj/item/weapon/grown/deathnettle/changePotency(newValue) //-QualityVan
	potency = newValue
	force = round((5+potency/2.5), 1)


/*
 * Corncob
 */
/obj/item/weapon/corncob/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/hatchet) || istype(W, /obj/item/weapon/kitchenknife) || istype(W, /obj/item/weapon/kitchenknife/ritual))
		to_chat(user, "<span class='notice'>You use [W] to fashion a pipe out of the corn cob!</span>")
		new /obj/item/clothing/mask/cigarette/pipe/cobpipe (user.loc)
		qdel(src)
		return
