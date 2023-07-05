//I still dont think this should be a closet but whatever
/obj/structure/closet/fireaxecabinet
	name = "Fire Axe Cabinet"
	desc = "There is small label that reads \"For Emergency use only\" along with details for safe use of the axe. As if."

	icon_state = "fireaxe1000"
	icon_closed = "fireaxe1000"
	icon_opened = "fireaxe1100"
	anchored = TRUE
	density = FALSE
	opened = TRUE
	locked = TRUE

	integrity_failure = 0.5

	var/obj/item/weapon/fireaxe/fireaxe
	var/localopened = FALSE // Setting this to keep it from behaviouring like a normal closet and obstructing movement in the map. -Agouri
	var/hitstaken = 0
	var/smashed = FALSE

/obj/structure/closet/fireaxecabinet/Destroy()
	QDEL_NULL(fireaxe)
	return ..()

/obj/structure/closet/fireaxecabinet/PopulateContents()
	fireaxe = new /obj/item/weapon/fireaxe(src)

/obj/structure/closet/fireaxecabinet/attackby(obj/item/O, mob/living/user)  //Marker -Agouri
	//..() //That's very useful, Erro

	if (user.is_busy(src))
		return

	if (isrobot(usr) || locked)
		if(ispulsing(O))
			to_chat(user, "<span class='warning'>Resetting circuitry...</span>")
			playsound(user, 'sound/machines/lockreset.ogg', VOL_EFFECTS_MASTER)
			if (do_after(user, 50, target = src))
				locked = FALSE
				to_chat(user, "<span class='notice'>You disable the locking modules.</span>")
				update_icon()
		else if(istype(O, /obj/item/weapon))
			user.SetNextMove(CLICK_CD_MELEE)
			if(smashed || localopened)
				if(localopened)
					localopened = FALSE
					icon_state = text("fireaxe[][][][]closing", !!fireaxe, localopened, hitstaken, smashed)
					addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 10)
				return
			..()

	else if (istype(O, /obj/item/weapon/fireaxe) && localopened)
		if(!fireaxe)
			user.drop_from_inventory(O, src)
			fireaxe = O
			to_chat(user, "<span class='notice'>You place the fire axe back in the [src.name].</span>")
			update_icon()
		else
			if(smashed)
				return
			else
				localopened = !localopened
				if(localopened)
					icon_state = text("fireaxe[][][][]opening", !!fireaxe, localopened, hitstaken, smashed)
					addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 10)
				else
					icon_state = text("fireaxe[][][][]closing", !!fireaxe, localopened, hitstaken, smashed)
					addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 10)
	else
		if(smashed)
			return
		if(ispulsing(O))
			if(localopened)
				localopened = FALSE
				icon_state = text("fireaxe[][][][]closing", !!fireaxe, localopened, hitstaken, smashed)
				addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 10)
			else
				to_chat(user, "<span class='warning'>Resetting circuitry...</span>")
				if(O.use_tool(src, user, 50, volume = 50))
					locked = TRUE
					to_chat(user, "<span class='notice'>You re-enable the locking modules.</span>")
					playsound(user, 'sound/machines/lockenable.ogg', VOL_EFFECTS_MASTER)
		else
			localopened = !localopened
			if(localopened)
				icon_state = text("fireaxe[][][][]opening", !!fireaxe, localopened, hitstaken, smashed)
				addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 10)
			else
				icon_state = text("fireaxe[][][][]closing", !!fireaxe, localopened, hitstaken, smashed)
				addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 10)

/obj/structure/closet/fireaxecabinet/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(smashed)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', VOL_EFFECTS_MASTER, 90, TRUE)
			else
				playsound(loc, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER, 90, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/structure/closet/fireaxecabinet/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = TRUE, attack_dir)
	if(localopened)
		return
	. = ..()
	if(. && hitstaken < 3)
		hitstaken++
		update_icon()

/obj/structure/closet/fireaxecabinet/atom_break(damage_flag)
	if(smashed || flags & NODECONSTRUCT)
		return ..()
	smashed = TRUE
	localopened = TRUE
	locked = FALSE
	hitstaken = 4
	update_icon()
	playsound(loc, 'sound/effects/Glassbr3.ogg', VOL_EFFECTS_MASTER, 100, TRUE)
	new /obj/item/weapon/shard(loc)
	new /obj/item/weapon/shard(loc)
	. = ..()

/obj/structure/closet/fireaxecabinet/deconstruct(disassembled = TRUE)
	if(flags & NODECONSTRUCT)
		return ..()

	if(fireaxe)
		fireaxe.forceMove(loc)
		fireaxe = null
	new /obj/item/stack/sheet/metal(loc, 2)
	if(!smashed)
		new /obj/item/weapon/shard(loc)
		new /obj/item/weapon/shard(loc)
	return ..()

/obj/structure/closet/fireaxecabinet/attack_hand(mob/living/user)
	if(user.is_busy(src))
		return
	user.SetNextMove(CLICK_CD_MELEE)

	if(locked)
		to_chat(user, "<span class='warning'>The cabinet won't budge!</span>")
		return

	if(localopened)
		if(fireaxe)
			user.try_take(fireaxe, loc)
			fireaxe = null
			to_chat(user, "<span class='notice'>You take the fire axe from the [name].</span>")
			add_fingerprint(user)
			update_icon()
		else
			if(smashed)
				return
			else
				localopened = !localopened
				if(localopened)
					icon_state = text("fireaxe[][][][]opening", !!fireaxe, localopened, hitstaken, smashed)
					addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 10)
				else
					icon_state = text("fireaxe[][][][]closing", !!fireaxe, localopened, hitstaken, smashed)
					addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 10)

	else
		localopened = !localopened //I'm pretty sure we don't need an if(src.smashed) in here. In case I'm wrong and it fucks up teh cabinet, **MARKER**. -Agouri
		if(localopened)
			icon_state = text("fireaxe[][][][]opening", !!fireaxe, localopened, hitstaken, smashed)
			addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 10)
		else
			src.icon_state = text("fireaxe[][][][]closing", !!fireaxe, localopened, hitstaken, smashed)
			addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 10)

/obj/structure/closet/fireaxecabinet/attack_paw(mob/user)
	attack_hand(user)

/obj/structure/closet/fireaxecabinet/attack_ai(mob/user)
	if(smashed)
		to_chat(user, "<span class='warning'>The security of the cabinet is compromised.</span>")
	else
		locked = !locked
		if(locked)
			to_chat(user, "<span class='warning'>Cabinet locked.</span>")
		else
			to_chat(user, "<span class='notice'>Cabinet unlocked.</span>")

/obj/structure/closet/fireaxecabinet/update_icon() // Template: fireaxe[has fireaxe][is opened][hits taken][is smashed]. If you want the opening or closing animations, add "opening" or "closing" right after the numbers
	icon_state = text("fireaxe[][][][]", !!fireaxe, localopened, hitstaken, smashed)

/obj/structure/closet/fireaxecabinet/open()
	return

/obj/structure/closet/fireaxecabinet/close()
	return
