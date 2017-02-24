/obj/item/weapon/twohanded/spear
		icon = 'icons/obj/makeshift.dmi'
		icon_state = "spearglass0"
		name = "spear"
		desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
		force = 10
		w_class = 4.0
		slot_flags = SLOT_BACK
		force_unwielded = 10
		force_wielded = 18 // Was 13, Buffed - RR
		throwforce = 15
		flags = NOSHIELD
		hitsound = 'sound/weapons/bladeslice.ogg'
		attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")

/obj/item/weapon/twohanded/spear/update_icon()
	icon_state = "spearglass[wielded]"


/obj/item/clothing/head/helmet/battlebucket
	icon = 'icons/obj/makeshift.dmi'
	name = "Battle Bucket"
	desc = "This one protects your head and makes your enemies tremble."
	icon_state = "battle_bucket"
	item_state = "bucket"
	armor = list(melee = 20, bullet = 5, laser = 5,energy = 3, bomb = 5, bio = 0, rad = 0)

/obj/item/weapon/handcuffs/cable/attackby(obj/item/I, mob/user)
	..()
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if(!R.use(1))
			return

		var/obj/item/weapon/wirerod/W = new /obj/item/weapon/wirerod

		user.remove_from_mob(src)

		user.put_in_hands(W)
		to_chat(user, "<span class='notice'>You wrap the cable restraint around the top of the rod.</span>")

		qdel(src)

/obj/item/weapon/melee/cattleprod
		icon = 'icons/obj/makeshift.dmi'
		name = "stunprod"
		desc = "An improvised stun baton."
		icon_state = "stunprod"
		item_state = "prod"
		var/obj/item/weapon/stock_parts/cell/bcell = null
		var/stunforce = 5
		var/hitcost = 2500
		force = 3
		throwforce = 5
		var/status = 0
		slot_flags = null


/obj/item/weapon/melee/cattleprod/New()
	..()
	update_icon()
	return

/obj/item/weapon/melee/cattleprod/attack_self(mob/user)
	if(bcell && bcell.charge > hitcost)
		status = !status
		to_chat(user, "<span class='notice'>[src] is now [status ? "on" : "off"].</span>")
		playsound(loc, "sparks", 75, 1, -1)
	else
		status = 0
		if(!bcell)
			to_chat(user, "<span class='warning'>[src] does not have a power source!</span>")
		else
			to_chat(user, "<span class='warning'>[src] is out of charge.</span>")
	if(bcell && bcell.rigged)
		bcell.explode()
		if(user.hand)
			user.update_inv_l_hand()
		else
			user.update_inv_r_hand()
		qdel(src)
		return
	update_icon()
	add_fingerprint(user)


/obj/item/weapon/melee/cattleprod/proc/deductcharge(chrgdeductamt)
	if(bcell)
		if(bcell.charge < (hitcost+chrgdeductamt)) // If after the deduction the baton doesn't have enough charge for a stun hit it turns off.
			status = 0
			update_icon()
			playsound(loc, "sparks", 75, 1, -1)
		if(bcell.use(chrgdeductamt))
			return 1
		else
			return 0

/obj/item/weapon/melee/cattleprod/update_icon()
	if(status)
		icon_state = "[initial(name)]_active"
	else if(!bcell)
		icon_state = "[initial(name)]_nocell"
	else
		icon_state = "[initial(name)]"

/obj/item/weapon/melee/cattleprod/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/stock_parts/cell))
		if(!bcell)
			user.drop_item()
			W.loc = src
			bcell = W
			to_chat(user, "<span class='notice'>You install a cell in [src].</span>")
			update_icon()
		else
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")
	else if(istype(W, /obj/item/weapon/screwdriver))
		if(bcell)
			bcell.updateicon()
			bcell.loc = get_turf(src.loc)
			bcell = null
			to_chat(user, "<span class='notice'>You remove the cell from the [src].</span>")
			status = 0
			update_icon()
			return
		..()
	return

/obj/item/weapon/melee/cattleprod/attack(mob/M, mob/user)
	if(status && (CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='danger'>You accidentally hit yourself with [src]!</span>")
		user.Weaken(stunforce*3)
		deductcharge(hitcost)
		return

	var/mob/living/carbon/human/H = M
	if(isrobot(M))
		..()
		return

	if(user.a_intent == "hurt")
		if(!..()) return
		H.visible_message("<span class='danger'>[M] has been beaten with the [src] by [user]!</span>")
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Beat [H.name] ([H.ckey]) with [src.name]</font>"
		H.attack_log += "\[[time_stamp()]\]<font color='orange'> Beaten by [user.name] ([user.ckey]) with [src.name]</font>"
		msg_admin_attack("[user.name] ([user.ckey]) beat [H.name] ([H.ckey]) with [src.name] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		playsound(src.loc, "swing_hit", 50, 1, -1)
	else if(!status)
		H.visible_message("<span class='warning'>[M] has been prodded with the [src] by [user]. Luckily it was off.</span>")
		return

	if(status)
		//H.Stun(stunforce)
		//H.Weaken(stunforce)
		//H.apply_effect(STUTTER, stunforce)
		H.apply_effect(60,AGONY,0)
		user.lastattacked = M
		H.lastattacker = user
		if(isrobot(src.loc))
			var/mob/living/silicon/robot/R = src.loc
			if(R && R.cell)
				R.cell.use(hitcost)
		else
			deductcharge(hitcost)
		H.visible_message("<span class='danger'>[M] has been stunned with the [src] by [user]!</span>")

		user.attack_log += "\[[time_stamp()]\]<font color='red'> Stunned [H.name] ([H.ckey]) with [src.name]</font>"
		H.attack_log += "\[[time_stamp()]\]<font color='orange'> Stunned by [user.name] ([user.ckey]) with [src.name]</font>"
		msg_admin_attack("[key_name(user)] stunned [key_name(H)] with [src.name]")

		playsound(src.loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
	//	if(charges < 1)
	//		status = 0
	//		update_icon()

	add_fingerprint(user)


/obj/item/weapon/melee/cattleprod/emp_act(severity)
	if(bcell)
		deductcharge(1000 / severity)
		if(bcell.reliability != 100 && prob(50/severity))
			bcell.reliability -= 10 / severity
	..()

/obj/item/weapon/wirerod
		icon = 'icons/obj/makeshift.dmi'
		icon_state = "wirerod"
		name = "wired rod"
		desc = "A rod with some wire wrapped around the top. It'd be easy to attach something to the top bit."
		item_state = "rods"
		flags = CONDUCT
		force = 9
		throwforce = 10
		w_class = 3
		m_amt = 1875
		attack_verb = list("hit", "bludgeoned", "whacked", "bonked")


/obj/item/weapon/wirerod/attackby(obj/item/I, mob/user)
	..()
	if(istype(I, /obj/item/weapon/shard))
		var/obj/item/weapon/twohanded/spear/S = new /obj/item/weapon/twohanded/spear

		user.remove_from_mob(I)
		user.remove_from_mob(src)

		user.put_in_hands(S)
		to_chat(user, "<span class='notice'>You fasten the glass shard to the top of the rod with the cable.</span>")
		qdel(I)
		qdel(src)

	else if(istype(I, /obj/item/weapon/wirecutters))

		var/obj/item/weapon/melee/cattleprod/P = new /obj/item/weapon/melee/cattleprod

		user.remove_from_mob(I)
		user.remove_from_mob(src)

		user.put_in_hands(P)
		to_chat(user, "<span class='notice'>You fasten the wirecutters to the top of the rod with the cable, prongs outward.</span>")
		qdel(I)
		qdel(src)
