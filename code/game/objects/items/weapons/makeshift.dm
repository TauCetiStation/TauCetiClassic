/obj/item/weapon/spear
	icon = 'icons/obj/makeshift.dmi'
	icon_state = "spearglass0"
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	force = 10
	w_class = SIZE_SMALL
	slot_flags = SLOT_FLAGS_BACK
	flags_2 = CANT_BE_INSERTED
	throwforce = 15
	hitsound = list('sound/weapons/bladeslice.ogg')
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")

/obj/item/weapon/spear/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list(/turf, /obj/effect/effect/weapon_sweep)

	SCB.can_push = TRUE
	SCB.can_pull = TRUE

	SCB.can_push_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/spear, can_sweep_push))
	SCB.can_pull_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/spear, can_sweep_pull))

	AddComponent(/datum/component/swiping, SCB)

	var/datum/twohanded_component_builder/TCB = new
	TCB.force_wielded = 18
	TCB.force_unwielded = 10
	TCB.icon_wielded = "spearglass1"

	AddComponent(/datum/component/twohanded, TCB)

/obj/item/weapon/spear/proc/can_sweep_push(atom/target, mob/user)
	return HAS_TRAIT(src, TRAIT_DOUBLE_WIELDED)

/obj/item/weapon/spear/proc/can_sweep_pull(atom/target, mob/user)
	return HAS_TRAIT(src, TRAIT_DOUBLE_WIELDED)

/obj/item/weapon/spear/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/organ/external/head))
		if(loc == user)
			user.drop_from_inventory(src)
		var/obj/structure/headpole/H = new (get_turf(src), I, src)
		user.drop_from_inventory(I, H)

	else
		return ..()

/obj/item/clothing/head/helmet/battlebucket
	icon = 'icons/obj/makeshift.dmi'
	name = "Battle Bucket"
	desc = "This one protects your head and makes your enemies tremble."
	icon_state = "battle_bucket"
	item_state = "bucket"
	armor = list(melee = 20, bullet = 5, laser = 5,energy = 3, bomb = 5, bio = 0, rad = 0)

/obj/item/weapon/melee/cattleprod
	icon = 'icons/obj/makeshift.dmi'
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod"
	item_state = "prod"
	var/obj/item/weapon/stock_parts/cell/bcell = null
	var/stunforce = 5
	var/hitcost = 2000
	force = 3
	throwforce = 5
	var/status = 0
	slot_flags = SLOT_FLAGS_BACK
	flags_2 = CANT_BE_INSERTED
	var/mob/foundmob = "" //Used in throwing proc.

/obj/item/weapon/melee/cattleprod/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())
		return
	if (!prob(50))
		return
	if(!ishuman(hit_atom))
		return
	var/mob/living/carbon/human/H = hit_atom
	if(status)
		H.apply_effect(60,AGONY,0)
		deductcharge(hitcost)
		var/mob/living/carbon/human/T = ishuman(throwingdatum.thrower) ? throwingdatum.thrower : null
		if(!T)
			return
		H.visible_message("<span class='danger'>[src], thrown by [T.name], strikes [H]!</span>")
		H.attack_log += "\[[time_stamp()]\]<font color='orange'> Hit by thrown [src.name] last touched by ([src.fingerprintslast])</font>"
		msg_admin_attack("Flying [src.name], last touched by ([src.fingerprintslast]) hit [key_name(H)]", H)

/obj/item/weapon/melee/cattleprod/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new

	SCB.can_push = TRUE
	SCB.can_pull = TRUE

	AddComponent(/datum/component/swiping, SCB)

	update_icon()

/obj/item/weapon/melee/cattleprod/attack_self(mob/user)
	if(bcell && bcell.charge > hitcost)
		status = !status
		to_chat(user, "<span class='notice'>[src] is now [status ? "on" : "off"].</span>")
		playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
	else
		status = 0
		if(!bcell)
			to_chat(user, "<span class='warning'>[src] does not have a power source!</span>")
		else
			to_chat(user, "<span class='warning'>[src] is out of charge.</span>")
	if(bcell && bcell.rigged)
		bcell.explode()
		qdel(src)
		return
	update_icon()
	add_fingerprint(user)


/obj/item/weapon/melee/cattleprod/proc/deductcharge(chrgdeductamt)
	if(bcell)
		if(bcell.charge < (hitcost+chrgdeductamt)) // If after the deduction the baton doesn't have enough charge for a stun hit it turns off.
			status = 0
			update_icon()
			playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
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

/obj/item/weapon/melee/cattleprod/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/stock_parts/cell))
		var/obj/item/weapon/stock_parts/cell/C = I
		if(C.maxcharge < hitcost)
			to_chat(user, "<span class='notice'>[C]'s maximum capacity seems too small to be useful.</span>")
			return
		if(!bcell)
			user.drop_from_inventory(C, src)
			bcell = C
			to_chat(user, "<span class='notice'>You install \a [C] in \the [src].</span>")
			update_icon()
		else
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")

	else if(isscrewing(I))
		if(bcell)
			to_chat(user, "<span class='notice'>You remove \the [bcell] from the [src].</span>")
			bcell.updateicon()
			bcell.forceMove(get_turf(loc))
			bcell = null
			status = 0
			update_icon()
			return

	else
		return ..()

/obj/item/weapon/melee/cattleprod/attack(mob/M, mob/living/user)
	if(status && user.ClumsyProbabilityCheck(50))
		to_chat(user, "<span class='danger'>You accidentally hit yourself with [src]!</span>")
		user.apply_effect(120, AGONY, 0)
		deductcharge(hitcost)
		return

	var/mob/living/carbon/human/H = M
	if(isrobot(M))
		..()
		return


	if(user.a_intent == INTENT_HARM)
		if(!..()) return
		H.visible_message("<span class='danger'>[M] has been beaten with the [src] by [user]!</span>")

		H.log_combat(user, "attacked with [name]")

		playsound(src, pick(SOUNDIN_GENHIT), VOL_EFFECTS_MASTER)
	else if(!status)
		H.visible_message("<span class='warning'>[M] has been prodded with the [src] by [user]. Luckily it was off.</span>")
		return

	if(status)
		//H.Stun(stunforce)
		//H.Weaken(stunforce)
		//H.apply_effect(STUTTER, stunforce)
		H.apply_effect(60,AGONY,0)
		H.set_lastattacker_info(user)
		if(isrobot(src.loc))
			var/mob/living/silicon/robot/R = src.loc
			if(R && R.cell)
				R.cell.use(hitcost)
		else
			deductcharge(hitcost)
		H.visible_message("<span class='danger'>[M] has been stunned with the [src] by [user]!</span>")

		H.log_combat(user, "stunned with [name]")

		playsound(src, 'sound/weapons/Egloves.ogg', VOL_EFFECTS_MASTER)
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

/obj/item/weapon/wirerod // assembly component for spear and stunprod.
	icon = 'icons/obj/makeshift.dmi'
	icon_state = "wirerod"
	name = "wired rod"
	desc = "A rod with some wire wrapped around the top. It'd be easy to attach something to the top bit."
	item_state = "rods"
	flags = CONDUCT
	force = 9
	throwforce = 10
	w_class = SIZE_SMALL
	m_amt = 1875
	attack_verb = list("hit", "bludgeoned", "whacked", "bonked")

/obj/item/weapon/noose
	name = "noose"
	desc = "A rolled noose."
	icon = 'icons/obj/objects.dmi'
	icon_state = "noose_rolled"
	w_class = SIZE_TINY

/obj/item/weapon/noose/attack_self(mob/user)
	var/turf/user_turf = get_turf(user)
	var/obj/structure/stool/bed/chair/noose/N
	if(user_turf.density)
		to_chat(user, "<span class='notice'>You can't build a noose over that.</span>")
		return
	if(locate(N) in user_turf)
		to_chat(user, "<span class='notice'>You can't build a noose on a tile that has a noose.</span>")
		return
	user.visible_message("<span class='notice'>[user] starts constructing a noose</span>")
	to_chat(user, "<span class='notice'>You begin to construct a noose...</span>")
	if(!do_after(user, 5 SECONDS, target = user))
		return
	N = new(user_turf)
	N.layer = FLY_LAYER // because of bed/chair/atom_init
	N.color = color
	qdel(src)

/obj/item/weapon/noose/attackby(obj/item/W, mob/user)
	if(!iscutter(W))
		return ..()
	user.visible_message("<span class='notice'>[user] cuts the noose.</span>", "<span class='notice'>You cut the noose.</span>")
	var/obj/item/stack/cable_coil/C = new(get_turf(src))
	C.color = color
	C.amount = 25
	qdel(src)

/obj/item/weapon/noose/CheckParts(list/parts_list)
	..()
	for(var/obj/item/stack/cable_coil/C in contents)
		color = C.color

/obj/item/weapon/transparant
	icon_custom ='icons/mob/inhands/transparant.dmi'
	icon_state = "blank"
	item_state = "blank"
	name = "blank sign"
	desc = "Nothing."
	var/not_bloody_state
	var/not_bloody_item_state
	var/delay_msg = 5 SECONDS
	var/last_warn_msg = 0
	force = 8
	w_class = SIZE_NORMAL
	throwforce = 5
		//var/protest_text
 		//	var/protest_text_length = 100
 	//var/image/inhand_blood_overlay
	attack_verb = list("bashed", "pacified", "smashed", "opressed", "flapped")

/obj/item/weapon/transparant/atom_init()
	. = ..()
	not_bloody_state = icon_state
	not_bloody_item_state = item_state

/obj/item/weapon/transparant/attackby(obj/item/I, mob/user, params)
	if(icon_state!="blank")
		to_chat(user, "<span class='notice'>Something allready written on this sign.</span>")
		return

	if(istype(I, /obj/item/weapon/pen))
		var/defaultText = "FUK NT!1"
		var/targName = sanitize(input(usr, "Just write something here", "Transparant text", input_default(defaultText)))
		var/obj/item/weapon/transparant/text/W = new /obj/item/weapon/transparant/text
		W.desc = targName
		user.remove_from_mob(src)
		user.put_in_hands(W)
		qdel(src)
		to_chat(user, "<span class='notice'>You writed: <span class='emojify'>[targName]</span> on your sign.</span>")
		return

	if(istype(I, /obj/item/toy/crayon))
		var/paths = subtypesof(/obj/item/weapon/transparant) - /obj/item/weapon/transparant/text
		var/targName = input(usr, "Choose transparant pattern", "Pattern list") in paths
		if(!targName)
			return
		var/obj/item/weapon/transparant/W = new targName
		qdel(src)
		user.put_in_hands(W)
		to_chat(user, "<span class='notice'>You painted your blank sign as [W.name].</span>")
		return

	return ..()

/obj/item/weapon/transparant/attack_self(mob/user)
	if(last_warn_msg < world.time)
		user.visible_message("[user] shows you: [bicon(src)] [src.blood_DNA ? "bloody " : ""][src.name]: it says: <span class='emojify'>[src.desc]</span>")
		last_warn_msg = world.time + delay_msg
	else
		to_chat(user, "<span class='notice'>You are too tired, to do that.</span>")
		return

/obj/item/weapon/transparant/attack(mob/M, mob/user)
	..()
	M.show_message("<span class='red'>\The <EM>[src.blood_DNA ? "bloody " : ""][bicon(src)][src.name]</EM> says: <span class='emojify bold'>[src.desc]</span></span>", SHOWMSG_VISUAL)

/obj/item/weapon/transparant/update_icon()
	if(blood_DNA)
		icon_state = "bloody"
		item_state = "bloody"
	else
		icon_state = not_bloody_state
		item_state = not_bloody_item_state
	..()

/obj/item/weapon/transparant/clean_blood()
	. = ..()
	update_icon()

/obj/item/weapon/transparant/add_blood()
	. = ..()
	update_icon()

/obj/item/weapon/transparant/no_nt
	icon_state = "no_nt"
	item_state = "no_nt"
	name = "no NT sign"
	desc = "Nanotrasen go home! Nanotrasen go home!"

/obj/item/weapon/transparant/peace
	icon_state = "peace"
	item_state = "peace"
	name = "peace sign"
	desc = "No more war! No more opression! No more violence!"

/obj/item/weapon/transparant/text
	icon_state = "text"
	item_state = "text"
	name = "text sign"
	desc = "..."

/obj/item/stack/sheet/cardboard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		var/list/resources_to_use = list()
		resources_to_use[R] = 1
		resources_to_use[src] = 1
		if(!use_multi(user, resources_to_use))
			return

		var/obj/item/weapon/transparant/W = new /obj/item/weapon/transparant
		user.put_in_hands(W)
		to_chat(user, "<span class='notice'>You attached a big cardboard sign to the metal rod, making a blank transparant.</span>")

	else
		return ..()
