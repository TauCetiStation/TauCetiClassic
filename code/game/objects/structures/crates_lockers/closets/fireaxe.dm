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

	var/obj/item/weapon/twohanded/fireaxe/fireaxe
	var/localopened = FALSE // Setting this to keep it from behaviouring like a normal closet and obstructing movement in the map. -Agouri
	var/hitstaken = 0
	var/smashed = FALSE

/obj/structure/closet/fireaxecabinet/Destroy()
	fireaxe = null
	return ..()

/obj/structure/closet/fireaxecabinet/PopulateContents()
	fireaxe = new /obj/item/weapon/twohanded/fireaxe(src)

/obj/structure/closet/fireaxecabinet/attackby(obj/item/O, mob/user)  //Marker -Agouri
	//..() //That's very useful, Erro

	if (user.is_busy(src))
		return

	if (isrobot(usr) || locked)
		if(ismultitool(O))
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
					addtimer(CALLBACK(src, .proc/update_icon), 10)
				return
			else
				user.do_attack_animation(src)
				playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER) //We don't want this playing every time
			if(O.force < 15)
				visible_message("<span class='notice'>The cabinet's protective glass glances off the hit.</span>")
			else
				hitstaken++
				if(hitstaken == 4)
					playsound(src, 'sound/effects/Glassbr3.ogg', VOL_EFFECTS_MASTER) //Break cabinet, receive goodies. Cabinet's fucked for life after that.
					smashed = TRUE
					locked = FALSE
					localopened = TRUE
			update_icon()
	else if (istype(O, /obj/item/weapon/twohanded/fireaxe) && localopened)
		if(!fireaxe)
			var/obj/item/weapon/twohanded/fireaxe/FA = O
			if(FA.wielded)
				to_chat(user, "<span class='warning'>Unwield the axe first.</span>")
				return
			user.drop_item()
			O.forceMove(src)
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
					addtimer(CALLBACK(src, .proc/update_icon), 10)
				else
					icon_state = text("fireaxe[][][][]closing", !!fireaxe, localopened, hitstaken, smashed)
					addtimer(CALLBACK(src, .proc/update_icon), 10)
	else
		if(smashed)
			return
		if(ismultitool(O))
			if(localopened)
				localopened = FALSE
				icon_state = text("fireaxe[][][][]closing", !!fireaxe, localopened, hitstaken, smashed)
				addtimer(CALLBACK(src, .proc/update_icon), 10)
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
				addtimer(CALLBACK(src, .proc/update_icon), 10)
			else
				icon_state = text("fireaxe[][][][]closing", !!fireaxe, localopened, hitstaken, smashed)
				addtimer(CALLBACK(src, .proc/update_icon), 10)

/obj/structure/closet/fireaxecabinet/attack_hand(mob/user)
	if(user.is_busy(src))
		return
	user.SetNextMove(CLICK_CD_MELEE)

	if(locked)
		to_chat(user, "<span class='warning'>The cabinet won't budge!</span>")
		return

	if(localopened)
		if(fireaxe)
			user.put_in_hands(fireaxe)
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
					addtimer(CALLBACK(src, .proc/update_icon), 10)
				else
					icon_state = text("fireaxe[][][][]closing", !!fireaxe, localopened, hitstaken, smashed)
					addtimer(CALLBACK(src, .proc/update_icon), 10)

	else
		localopened = !localopened //I'm pretty sure we don't need an if(src.smashed) in here. In case I'm wrong and it fucks up teh cabinet, **MARKER**. -Agouri
		if(localopened)
			icon_state = text("fireaxe[][][][]opening", !!fireaxe, localopened, hitstaken, smashed)
			addtimer(CALLBACK(src, .proc/update_icon), 10)
		else
			src.icon_state = text("fireaxe[][][][]closing", !!fireaxe, localopened, hitstaken, smashed)
			addtimer(CALLBACK(src, .proc/update_icon), 10)

/obj/structure/closet/fireaxecabinet/attack_tk(mob/user)
	if(user.is_busy(src))
		return

	if(localopened && fireaxe)
		fireaxe.forceMove(loc)
		to_chat(user, "<span class='notice'>You telekinetically remove the fire axe.</span>")
		fireaxe = null
		update_icon()
		return
	attack_hand(user)

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
