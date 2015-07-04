/* Pens!
 * Contains:
 *		Pens
 *		Sleepy Pens
 *		Parapens
 */


/*
 * Pens
 */
/obj/item/weapon/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	m_amt = 10
	var/colour = "black"	//what colour the ink is!
	pressure_resistance = 2


/obj/item/weapon/pen/blue
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/weapon/pen/red
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"

/obj/item/weapon/pen/invisible
	desc = "It's an invisble pen marker."
	icon_state = "pen"
	colour = "white"


/obj/item/weapon/pen/attack(mob/M as mob, mob/user as mob)
	if(!ismob(M))
		return
	user << "<span class='warning'>You stab [M] with the pen.</span>"
//	M << "\red You feel a tiny prick!" //That's a whole lot of meta!
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been stabbed with [name]  by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to stab [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) Used the [name] to stab [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	return


/*
 * Sleepy Pens
 */
/obj/item/weapon/pen/sleepypen
	desc = "It's a black ink pen with a sharp point and a carefully engraved \"Waffle Co.\""
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;syndicate=5"


/obj/item/weapon/pen/sleepypen/New()
	var/datum/reagents/R = new/datum/reagents(30) //Used to be 300
	reagents = R
	R.my_atom = src
	R.add_reagent("chloralhydrate", 22)	//Used to be 100 sleep toxin//30 Chloral seems to be fatal, reducing it to 22./N
	..()
	return


/obj/item/weapon/pen/sleepypen/attack(mob/M as mob, mob/user as mob)
	if(!(istype(M,/mob)))
		return
	..()
	if(reagents.total_volume)
		if(M.reagents) reagents.trans_to(M, 50) //used to be 150
	return


/*
 * Parapens
 */
 /obj/item/weapon/pen/paralysis
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;syndicate=5"


/obj/item/weapon/pen/paralysis/attack(mob/living/M as mob, mob/user as mob)

	if(!(istype(M,/mob)))
		return

	..()


	if(M.can_inject(user,1))
		if(reagents.total_volume)
			if(M.reagents) reagents.trans_to(M, 50)
	return


/obj/item/weapon/pen/paralysis/New()
	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src
	R.add_reagent("zombiepowder", 10)
	R.add_reagent("cryptobiolin", 15)
	..()
	return

/*
 * Gang Boss Pens
 */
/obj/item/weapon/pen/gang
	origin_tech = "materials=2;syndicate=5"
	var/cooldown

/obj/item/weapon/pen/gang/attack(mob/living/M, mob/user)
	if(!istype(M))	return

	..()

	if(ishuman(M) && ishuman(user) && M.stat != DEAD)
		if(user.mind && ((user.mind in ticker.mode.A_bosses) || (user.mind in ticker.mode.B_bosses)))
			if(cooldown)
				user << "<span class='warning'>[src] needs more time to recharge before it can be used.</span>"
				return
			if(M.client)
				M.mind_initialize()		//give them a mind datum if they don't have one.
				if(user.mind in ticker.mode.A_bosses)
					var/recruitable = ticker.mode.add_gangster(M.mind,"A")
					switch(recruitable)
						if(2)
							M.Paralyse(5)
							cooldown(max(0,ticker.mode.B_gang.len - ticker.mode.A_gang.len))
						if(1)
							user << "<span class='warning'>This mind has already been recruited by another gang!</span>"
						else
							user << "<span class='warning'>This mind is resistant to recruitment!</span>"
				else if(user.mind in ticker.mode.B_bosses)
					var/recruitable = ticker.mode.add_gangster(M.mind,"B")
					switch(recruitable)
						if(2)
							M.Paralyse(5)
							cooldown(max(0,ticker.mode.A_gang.len - ticker.mode.B_gang.len))
						if(1)
							user << "<span class='warning'>This mind has already been recruited by another gang!</span>"
						else
							user << "<span class='warning'>This mind is resistant to recruitment!</span>"

/obj/item/weapon/pen/gang/proc/cooldown(modifier)
	cooldown = 1
	icon_state = "pen_blink"
	spawn(max(50,1200-(modifier*100)))
		cooldown = 0
		icon_state = "pen"
		var/mob/M = get(src, /mob)
		M << "<span class='notice'>\icon[src] [src][(src.loc == M)?(""):(" in your [src.loc]")] vibrates softly.</span>"
