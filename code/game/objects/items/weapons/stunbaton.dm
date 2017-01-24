/obj/item/weapon/melee/baton
	name = "stun baton"
	desc = "A stun baton for incapacitating people with."
	icon_state = "stunbaton"
	item_state = "baton"
	slot_flags = SLOT_BELT
	force = 10
	throwforce = 7
	w_class = 3
	var/charges = 10
	var/status = 0
	var/mob/foundmob = "" //Used in throwing proc.
	var/agony = 60

	origin_tech = "combat=2"

	suicide_act(mob/user)
		to_chat(viewers(user), "\red <b>[user] is putting the live [src.name] in \his mouth! It looks like \he's trying to commit suicide.</b>")
		return (FIRELOSS)

/obj/item/weapon/melee/baton/update_icon()
	if(status)
		icon_state = "stunbaton_active"
	else
		icon_state = "stunbaton"

/obj/item/weapon/melee/baton/attack_self(mob/user)
	if(status && (CLUMSY in user.mutations) && prob(50))
		to_chat(user, "\red You grab the [src] on the wrong side.")
		user.Weaken(30)
		charges--
		if(charges < 1)
			status = 0
			update_icon()
		return
	if(charges > 0)
		status = !status
		to_chat(user, "<span class='notice'>\The [src] is now [status ? "on" : "off"].</span>")
		playsound(src.loc, "sparks", 75, 1, -1)
		update_icon()
	else
		status = 0
		to_chat(user, "<span class='warning'>\The [src] is out of charge.</span>")
	add_fingerprint(user)

/obj/item/weapon/melee/baton/attack(mob/M, mob/user)
	if(status && (CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='danger'>You accidentally hit yourself with the [src]!</span>")
		user.Weaken(30)
		charges--
		if(charges < 1)
			status = 0
			update_icon()
		return

	var/mob/living/carbon/human/H = M
	if(isrobot(M))
		..()
		return

	if(user.a_intent == "hurt")
		if(!..()) return
		//H.apply_effect(5, WEAKEN, 0)
		H.visible_message("<span class='danger'>[M] has been beaten with the [src] by [user]!</span>")

		playsound(src.loc, "swing_hit", 50, 1, -1)

	if(!status)
		H.visible_message("<span class='warning'>[M] has been prodded with the [src] by [user]. Luckily it was off.</span>")
		return
	else
		user.do_attack_animation(M)
		//H.apply_effect(10, STUN, 0)
		//H.apply_effect(10, WEAKEN, 0)
		//H.apply_effect(10, STUTTER, 0)
		H.apply_effect(agony,AGONY,0)
		user.lastattacked = M
		H.lastattacker = user
		if(isrobot(src.loc))
			var/mob/living/silicon/robot/R = src.loc
			if(R && R.cell)
				R.cell.use(50)
		else
			charges--
		H.visible_message("<span class='danger'>[M] has been attacked with the [src] by [user]!</span>")

		if(!(user.a_intent == "hurt"))
			user.attack_log += "\[[time_stamp()]\]<font color='red'> attempted to stun [H.name] ([H.ckey]) with [src.name]</font>"
			H.attack_log += "\[[time_stamp()]\]<font color='orange'> stunned by [user.name] ([user.ckey]) with [src.name]</font>"
			msg_admin_attack("[key_name(user)] attempted to stun [key_name(H)] with [src.name]")

		playsound(src.loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
		if(charges < 1)
			status = 0
			update_icon()

	add_fingerprint(user)

/obj/item/weapon/melee/baton/throw_impact(atom/hit_atom)
	. = ..()
	if (prob(50))
		if(istype(hit_atom, /mob/living))
			var/mob/living/carbon/human/H = hit_atom
			if(status)
				//H.apply_effect(10, STUN, 0)
				//H.apply_effect(10, WEAKEN, 0)
				//H.apply_effect(10, STUTTER, 0)
				H.apply_effect(agony,AGONY,0)
				charges--

				for(var/mob/M in player_list) if(M.key == src.fingerprintslast)
					foundmob = M
					break

				H.visible_message("<span class='danger'>[src], thrown by [foundmob.name], strikes [H]!</span>")

				H.attack_log += "\[[time_stamp()]\]<font color='orange'> Hit by thrown [src.name] last touched by ([src.fingerprintslast])</font>"
				msg_admin_attack("Flying [src.name], last touched by ([src.fingerprintslast]) hit [key_name(H)]" )

/obj/item/weapon/melee/baton/emp_act(severity)
	switch(severity)
		if(1)
			charges = 0
		if(2)
			charges = max(0, charges - 5)
	if(charges < 1)
		status = 0
		update_icon()
