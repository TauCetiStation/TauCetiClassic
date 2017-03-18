/obj/item/weapon/banhammer
	desc = "A banhammer."
	name = "banhammer"
	icon = 'icons/obj/items.dmi'
	icon_state = "toyhammer"
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 2.0
	throw_speed = 7
	throw_range = 15
	attack_verb = list("banned")

	suicide_act(mob/user)
		to_chat(viewers(user), "\red <b>[user] is hitting \himself with the [src.name]! It looks like \he's trying to ban \himself from life.</b>")
		return (BRUTELOSS|FIRELOSS|TOXLOSS|OXYLOSS)

/obj/item/weapon/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian, its very presence disrupts and dampens the powers of paranormal phenomenae."
	icon_state = "nullrod"
	item_state = "nullrod"
	slot_flags = SLOT_BELT
	force = 15
	throw_speed = 1
	throw_range = 4
	throwforce = 10
	light_color = "#4c4cff"
	light_power = 3
	w_class = 2
	var/last_process = 0

	suicide_act(mob/user)
		to_chat(viewers(user), "<span class='userdanger'>[user] is impaling \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>")
		return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/nullrod/equipped(mob/user, slot)
	if(user.mind && user.mind.assigned_role == "Chaplain")
		START_PROCESSING(SSobj, src)
	else if(src.isprocessing)
		flame_off()
		STOP_PROCESSING(SSobj, src)
	..()

/obj/item/weapon/nullrod/dropped(mob/user)
	if(src.isprocessing)
		flame_off()
		STOP_PROCESSING(SSobj, src)
	..()

/obj/item/weapon/nullrod/process()
	if(last_process + 60 >= world.time)
		return
	last_process = world.time
	flame_off()
	for(var/atom/A in range(6, loc))
		if(isobserver(A) || iscultist(A) || isshade(A))
			flame_on()
			break
		else if(istype(A, /obj/effect/rune))
			flame_on()
			break
		else if(istype(A,/obj/structure/cult))
			flame_on()
			break


/obj/item/weapon/nullrod/proc/flame_on()
	set_light(3)
	icon_state += "_on"
	item_state += "_on"
	if(ishuman(loc))
		var/mob/living/carbon/human/H
		H.update_inv_l_hand()
		H.update_inv_r_hand()

/obj/item/weapon/nullrod/proc/flame_off()
	set_light(0)
	icon_state = initial(icon_state)
	item_state = initial(item_state)
	if(ishuman(loc))
		var/mob/living/carbon/human/H
		H.update_inv_l_hand()
		H.update_inv_r_hand()

/obj/item/weapon/nullrod/attack(mob/M, mob/living/user) //Paste from old-code to decult with a null rod.

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

	msg_admin_attack("[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		to_chat(user, "<span class='danger'> You don't have the dexterity to do this!</span>")
		return

	if ((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "\red The rod slips out of your hand and hits your head.")
		user.take_organ_damage(10)
		user.Paralyse(20)
		return

	if (M.stat !=2)
		if((M.mind in ticker.mode.cult) && user.mind && user.mind.assigned_role == "Chaplain" && prob(33))
			to_chat(M, "<span class='danger'> The power of [src] clears your mind of the cult's influence!</span>")
			to_chat(user, "<span class='danger'> You wave [src] over [M]'s head and see their eyes become clear, their mind returning to normal.</span>")
			ticker.mode.remove_cultist(M.mind)
			M.visible_message("<span class='danger'>[user] waves [src] over [M.name]'s head</span>")
		else if(prob(10))
			to_chat(user, "<span class='danger'> The rod slips in your hand.</span>")
			..()
		else
			to_chat(user, "<span class='danger'> The rod appears to do nothing.</span>")
			M.visible_message("<span class='danger'>[user] waves [src] over [M.name]'s head</span>")
			return

/obj/item/weapon/nullrod/afterattack(atom/A, mob/user)
	if (istype(A, /turf/simulated/floor))
		to_chat(user, "\blue You hit the floor with the [src].")
		call(/obj/effect/rune/proc/revealrunes)(src)

/obj/item/weapon/sord
	name = "\improper SORD"
	desc = "This thing is so unspeakably shitty you are having a hard time even holding it."
	icon_state = "sord"
	item_state = "sord"
	slot_flags = SLOT_BELT
	force = 2
	throwforce = 1
	sharp = 1
	edge = 1
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	suicide_act(mob/user)
		to_chat(viewers(user), "\red <b>[user] is impaling \himself with the [src.name]! It looks like \he's trying to commit suicide.</b>")
		return(BRUTELOSS)

/obj/item/weapon/sord/attack(mob/living/carbon/M, mob/living/carbon/user)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/obj/item/weapon/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 40
	throwforce = 10
	sharp = 1
	edge = 1
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	Get_shield_chance()
		return 50

	suicide_act(mob/user)
		to_chat(viewers(user), "\red <b>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</b>")
		return(BRUTELOSS)

/obj/item/weapon/claymore/attack(mob/living/carbon/M, mob/living/carbon/user)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/obj/item/weapon/katana
	name = "katana"
	desc = "Woefully underpowered in D20."
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 40
	throwforce = 10
	sharp = 1
	edge = 1
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	suicide_act(mob/user)
		to_chat(viewers(user), "\red <b>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</b>")
		return(BRUTELOSS)

/obj/item/weapon/katana/Get_shield_chance()
		return 50

/obj/item/weapon/katana/attack(mob/living/carbon/M, mob/living/carbon/user)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/obj/item/weapon/harpoon
	name = "harpoon"
	sharp = 1
	edge = 0
	desc = "Tharr she blows!"
	icon_state = "harpoon"
	item_state = "harpoon"
	force = 20
	throwforce = 15
	w_class = 3
	attack_verb = list("jabbed","stabbed","ripped")

/obj/item/weapon/switchblade
	name = "switchblade"
	icon_state = "switchblade"
	desc = "A sharp, concealable, spring-loaded knife."
	flags = CONDUCT
	force = 20
	w_class = 2
	throwforce = 15
	throw_speed = 3
	throw_range = 6
	m_amt = 12000
	origin_tech = "materials=1"
	hitsound = 'sound/weapons/Genhit.ogg'
	attack_verb = list("stubbed", "poked")
	var/extended

/obj/item/weapon/switchblade/attack_self(mob/user)
	extended = !extended
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)
	if(extended)
		force = 20
		w_class = 3
		throwforce = 15
		icon_state = "switchblade_ext"
		attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
		hitsound = 'sound/weapons/bladeslice.ogg'
	else
		force = 1
		w_class = 2
		throwforce = 5
		icon_state = "switchblade"
		attack_verb = list("stubbed", "poked")
		hitsound = 'sound/weapons/Genhit.ogg'

/obj/item/weapon/switchblade/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is slitting \his own throat with the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS)
