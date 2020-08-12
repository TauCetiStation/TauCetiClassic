/mob/living/simple_animal/spiderbot

	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	minbodytemp = 0
	maxbodytemp = 500

	var/obj/item/device/radio/borg/radio = null
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/weapon/stock_parts/cell/cell = null
	var/obj/machinery/camera/camera = null
	var/obj/item/device/mmi/mmi = null
	var/list/req_access = list(access_robotics) //Access needed to pop out the brain.

	name = "Spider-bot"
	desc = "A skittering robotic friend!"
	icon = 'icons/mob/robots.dmi'
	icon_state = "spiderbot-chassis"
	icon_living = "spiderbot-chassis"
	icon_dead = "spiderbot-smashed"
	universal_speak = 1 //Temp until these are rewritten.

	wander = 0

	health = 10
	maxHealth = 10

	attacktext = "shock"
	melee_damage = 2

	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	ventcrawler = 2

	var/emagged = 0
	var/obj/item/held_item = null //Storage for single item they can hold.
	speed = -1                    //Spiderbots gotta go fast.
	//pass_flags = PASSTABLE      //Maybe griefy?
	small = 1
	speak_emote = list("beeps","clicks","chirps")

/mob/living/simple_animal/spiderbot/attackby(obj/item/O, mob/user)

	if(istype(O, /obj/item/device/mmi) || istype(O, /obj/item/device/mmi/posibrain))
		var/obj/item/device/mmi/B = O
		if(src.mmi) //There's already a brain in it.
			to_chat(user, "<span class='warning'>There's already a brain in [src]!</span>")
			return
		if(!B.brainmob)
			to_chat(user, "<span class='warning'>Sticking an empty MMI into the frame would sort of defeat the purpose.</span>")
			return
		if(!B.brainmob.key)
			var/ghost_can_reenter = 0
			if(B.brainmob.mind)
				for(var/mob/dead/observer/G in player_list)
					if(G.can_reenter_corpse && G.mind == B.brainmob.mind)
						ghost_can_reenter = 1
						break
			if(!ghost_can_reenter)
				to_chat(user, "<span class='notice'>[O] is completely unresponsive; there's no point.</span>")
				return

		if(B.brainmob.stat == DEAD)
			to_chat(user, "<span class='warning'>[O] is dead. Sticking it into the frame would sort of defeat the purpose.</span>")
			return

		if(jobban_isbanned(B.brainmob, "Cyborg"))
			to_chat(user, "<span class='warning'>[O] does not seem to fit.</span>")
			return

		to_chat(user, "<span class='notice'>You install [O] in [src]!</span>")

		user.drop_item()
		src.mmi = O
		src.transfer_personality(O)

		O.loc = src
		src.update_icon()
		return 1

	if (iswelder(O))
		var/obj/item/weapon/weldingtool/WT = O
		user.SetNextMove(CLICK_CD_INTERACT)
		if (WT.use(0))
			if(health < maxHealth)
				health += pick(1,1,1,2,2,3)
				if(health > maxHealth)
					health = maxHealth
				add_fingerprint(user)
				user.visible_message("<span class='warning'>[user] has spot-welded some of the damage to [src]!</span>")
			else
				to_chat(user, "<span class='notice'>[src] is undamaged!</span>")
		else
			to_chat(user, "Need more welding fuel!")
			return
	else if(istype(O, /obj/item/weapon/card/id)||istype(O, /obj/item/device/pda))
		if (!mmi)
			to_chat(user, "<span class='warning'>There's no reason to swipe your ID - the spiderbot has no brain to remove.</span>")
			return 0

		var/obj/item/weapon/card/id/id_card

		if(istype(O, /obj/item/weapon/card/id))
			id_card = O
		else
			var/obj/item/device/pda/pda = O
			id_card = pda.id

		if(access_robotics in id_card.access)
			to_chat(user, "<span class='notice'>You swipe your access card and pop the brain out of [src].</span>")
			eject_brain()

			if(held_item)
				held_item.loc = src.loc
				held_item = null

			return 1
		else
			to_chat(user, "<span class='warning'>You swipe your card, with no effect.</span>")
			return 0

	else
		user.SetNextMove(CLICK_CD_MELEE)
		if(O.force)
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			adjustBruteLoss(damage)
			visible_message("<span class='warning'><b>[src] has been attacked with the [O] by [user].</b></span>")
		else
			to_chat(usr, "<span class='warning'>This weapon is ineffective, it does no damage.</span>")
			visible_message("<span class='warning'>[user] gently taps [src] with the [O].</span>")

/mob/living/simple_animal/spiderbot/transfer_personality(obj/item/device/mmi/M)

		src.mind = M.brainmob.mind
		src.mind.key = M.brainmob.key
		src.ckey = M.brainmob.ckey
		src.name = "Spider-bot ([M.brainmob.name])"

/mob/living/simple_animal/spiderbot/emag_act(mob/user)
	if (emagged)
		to_chat(user, "<span class='warning'>[src] is already overloaded - better run.</span>")
		return FALSE
	else
		emagged = 1
		to_chat(user, "<span class='notice'>You short out the security protocols and overload [src]'s cell, priming it to explode in a short time.</span>")
		spawn(100)
			to_chat(src, "<span class='warning'>Your cell seems to be outputting a lot of power...</span>")
		spawn(200)
			to_chat(src, "<span class='warning'>Internal heat sensors are spiking! Something is badly wrong with your cell!</span>")
		spawn(300)
			src.explode()
		return FALSE

/mob/living/simple_animal/spiderbot/proc/explode() //When emagged.
	visible_message("<span class='warning'>[src] makes an odd warbling noise, fizzles, and explodes.</span>")
	explosion(get_turf(loc), -1, -1, 3, 5)
	eject_brain()
	death()

/mob/living/simple_animal/spiderbot/proc/update_icon()
	if(mmi)
		if(istype(mmi,/obj/item/device/mmi))
			icon_state = "spiderbot-chassis-mmi"
			icon_living = "spiderbot-chassis-mmi"
		if(istype(mmi, /obj/item/device/mmi/posibrain))
			icon_state = "spiderbot-chassis-posi"
			icon_living = "spiderbot-chassis-posi"

	else
		icon_state = "spiderbot-chassis"
		icon_living = "spiderbot-chassis"

/mob/living/simple_animal/spiderbot/proc/eject_brain()
	if(mmi)
		var/turf/T = get_turf(loc)
		if(T)
			mmi.loc = T
		if(mind)	mind.transfer_to(mmi.brainmob)
		mmi = null
		src.name = "Spider-bot"
		update_icon()

/mob/living/simple_animal/spiderbot/Destroy()
	eject_brain()
	return ..()

/mob/living/simple_animal/spiderbot/atom_init()

	radio = new /obj/item/device/radio/borg(src)
	camera = new /obj/machinery/camera(src)
	camera.c_tag = "Spiderbot-[real_name]"
	camera.replace_networks(list("SS13"))

	. = ..()

/mob/living/simple_animal/spiderbot/death()

	alive_mob_list -= src
	dead_mob_list += src

	if(camera)
		camera.status = 0

	if(held_item)
		held_item.loc = loc
		held_item = null

	robogibs(loc, viruses)
	Destroy()

//copy paste from alien/larva, if that func is updated please update this one alsoghost
/mob/living/simple_animal/spiderbot/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Spiderbot"

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
	else
		layer = MOB_LAYER
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))

//Cannibalized from the parrot mob. ~Zuhayr

/mob/living/simple_animal/spiderbot/verb/drop_held_item()
	set name = "Drop held item"
	set category = "Spiderbot"
	set desc = "Drop the item you're holding."

	if(incapacitated())
		return

	if(!held_item)
		to_chat(usr, "<span class='warning'>You have nothing to drop!</span>")
		return 0

	if(istype(held_item, /obj/item/weapon/grenade))
		visible_message("<span class='warning'>[src] launches \the [held_item]!</span>", "<span class='warning'>You launch \the [held_item]!</span>", "You hear a skittering noise and a thump!")
		var/obj/item/weapon/grenade/G = held_item
		G.loc = src.loc
		G.prime()
		held_item = null
		return 1

	visible_message("<span class='notice'>[src] drops \the [held_item]!</span>", "<span class='notice'>You drop \the [held_item]!</span>", "You hear a skittering noise and a soft thump.")

	held_item.loc = src.loc
	held_item = null
	return 1

/mob/living/simple_animal/spiderbot/verb/get_item()
	set name = "Pick up item"
	set category = "Spiderbot"
	set desc = "Allows you to take a nearby small item."

	if(incapacitated())
		return -1

	if(held_item)
		to_chat(src, "<span class='warning'>You are already holding \the [held_item]</span>")
		return 1

	var/list/items = list()
	for(var/obj/item/I in view(1,src))
		if(I.loc != src && I.w_class <= ITEM_SIZE_SMALL)
			items.Add(I)

	var/obj/selection = input("Select an item.", "Pickup") in items

	if(selection)
		for(var/obj/item/I in view(1, src))
			if(selection == I)
				held_item = selection
				selection.loc = src
				visible_message("<span class='notice'>[src] scoops up \the [held_item]!</span>", "<span class='notice'>You grab \the [held_item]!</span>", "You hear a skittering noise and a clink.")
				return held_item
		to_chat(src, "<span class='warning'>\The [selection] is too far away.</span>")
		return 0

	to_chat(src, "<span class='warning'>There is nothing of interest to take.</span>")
	return 0

/mob/living/simple_animal/spiderbot/examine(mob/user)
	..()
	if(src.held_item)
		to_chat(user, "It is carrying \a [src.held_item] [bicon(src.held_item)].")
