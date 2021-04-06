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
	desc = "Это обычная чёрная ручка."
	name = "Ручка"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	slot_flags = SLOT_FLAGS_BELT | SLOT_FLAGS_EARS
	throwforce = 0
	w_class = ITEM_SIZE_TINY
	throw_speed = 7
	throw_range = 15
	m_amt = 10
	var/colour = "black"	//what colour the ink is!
	var/click_cooldown = 0

/obj/item/weapon/pen/proc/get_signature(mob/user)
	return (user && user.real_name) ? user.real_name : "Anonymous"

/obj/item/weapon/pen/attack_self(mob/user)
	if(click_cooldown <= world.time)
		click_cooldown = world.time + 2
		to_chat(user, "<span class='notice'>Click.</span>")
		playsound(src, 'sound/items/penclick.ogg', VOL_EFFECTS_MASTER, 50)

/obj/item/weapon/pen/ghost
	desc = "Это ручка выглядит очень дорогой. Интересно, сколько она стоит?"
	colour = "purple"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "fountainpen" //paththegreat: Eli Stevens
	var/entity = ""

/obj/item/weapon/pen/ghost/attack_self(mob/living/carbon/human/user)
	..()
	if(user.getBrainLoss() >= 60 || (user.mind && (user.mind.holy_role || user.mind.role_alt_title == "Paranormal Investigator")))
		if(!entity)
			to_chat(user, "<span class='notice'>Вы чувствуете как ваш [src] дрожит, что-то иное пытается его захватить.</span>")
			var/list/choices = list()
			for(var/mob/dead/observer/D in observer_list)
				if(D.started_as_observer)
					choices += D.name
			if(choices.len)
				entity = sanitize(pick(choices))

/obj/item/weapon/pen/ghost/afterattack(atom/target, mob/user, proximity, params)
	..()
	if(!proximity || !entity)
		return
	var/list/phrases = list("Зачем ты это сделал, [user]?", "Ты не мог сделать что-нибудь лучше?", "Убийца! Убийца! УБИЙЦА!", "Разве [target] заслуживает этого?",
	                        "Почему ты снова это сделал?", "Не надо, [user].", "Не каждый думает о таких вещах!", "Заслуживаю ли я вечно наблюдать за твоими страданиями?",
	                        "Почему я здесь?", "Теперь мы можем идти?", "Послушай, [target] не имеет к этому никакого отношения.", "Оостановииии это.", "Позовите военных!",
	                        "Поднимайте тревогу!", "Ты, [user], хоть немного лучше?", "Ты всегда можешь сдаться.", "Почему бы и нет?")
	to_chat(user, "<span class='bold'>[entity]</span> [pick("moans", "laments", "whines", "blubbers")], \"[pick(phrases)]\"")

/obj/item/weapon/pen/ghost/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/occult_scanner))
		var/obj/item/device/occult_scanner/OS = I
		OS.scanned_type = src.type
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60 || user.mind.holy_role || user.mind.role_alt_title == "Paranormal Investigator")
			if(entity && istype(I, /obj/item/weapon/nullrod))
				entity = ""
				to_chat(user, "<span class='warning'>[capitalize(src.name)]дёргает и тресёт, это выходит сущность!</span>")
				return
			else if(istype(I, /obj/item/weapon/storage/bible))
				var/obj/item/weapon/storage/bible/B = I
				to_chat(user, "<span class='notice'>Вы чувствуете божественное прозрение, как [capitalize(B.deity_name)] овладевает [src].</span>") //как перевести ceratin divine intelligence?
				entity = B.deity_name
				return
			else if(istype(I, /obj/item/weapon/photo))
				var/obj/item/weapon/photo/P = I
				for(var/A in P.photographed_names)
					if(P.photographed_names[A] == /mob/dead/observer)
						entity = A
						to_chat(user, "<span class='notice'>Вы чувствуете как тресёт [src] ,когда другая сущность пытается овладеть им. .</span>")
						break
				return
	return ..()

/obj/item/weapon/pen/ghost/get_signature(mob/user)
	return entity ? entity : (user && user.real_name) ? user.real_name : "Anonymous"

/obj/item/weapon/pen/blue
	desc = "Это обычная синяя ручка."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/weapon/pen/red
	desc = "Это обычная красная ручка."
	icon_state = "pen_red"
	colour = "red"

/obj/item/weapon/pen/invisible
	desc = "Это ручка с невидимыми чернилами."
	icon_state = "pen"
	colour = "white"

/*
 * Sleepy Pens
 */
/obj/item/weapon/pen/sleepypen
	desc = "Это черная чернильная ручка с острым пером и тщательно выгравированной надписью.\"Waffle Co.\""
	flags = OPENCONTAINER
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = "materials=2;syndicate=5"


/obj/item/weapon/pen/sleepypen/atom_init()
	var/datum/reagents/R = new/datum/reagents(30) //Used to be 300
	reagents = R
	R.my_atom = src
	R.add_reagent("chloralhydrate", 22)	//Used to be 100 sleep toxin//30 Chloral seems to be fatal, reducing it to 22./N
	. = ..()


/obj/item/weapon/pen/sleepypen/attack(mob/M, mob/user)
	..()
	if(!(istype(M,/mob)))
		return

	if(reagents.total_volume)
		if(M.reagents) reagents.trans_to(M, 50) //used to be 150
	return


/*
 * Parapens
 */
/obj/item/weapon/pen/paralysis
	flags = OPENCONTAINER
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = "materials=2;syndicate=5"

/obj/item/weapon/pen/paralysis/attack(mob/living/M, mob/user)
	..()

	if(!istype(M))
		return

	if(reagents.total_volume && M.reagents && M.try_inject(user, TRUE, TRUE, TRUE))
		reagents.trans_to(M, 50)

/obj/item/weapon/pen/paralysis/atom_init()
	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src
	R.add_reagent("zombiepowder", 10)
	R.add_reagent("cryptobiolin", 15)
	. = ..()

/obj/item/weapon/pen/edagger
	origin_tech = "combat=3;syndicate=1"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut") //these wont show up if the pen is off
	tools = list()
	var/on = 0

/obj/item/weapon/pen/edagger/attack_self(mob/living/user)
	..()
	if(on)
		on = 0
		force = initial(force)
		w_class = initial(w_class)
		edge = initial(edge)
		name = initial(name)
		hitsound = initial(hitsound)
		throwforce = initial(throwforce)
		playsound(user, 'sound/weapons/saberoff.ogg', VOL_EFFECTS_MASTER, 5)
		to_chat(user, "<span class='warning'>[src] теперь его можно скрыть.</span>")
		tools = list()
	else
		on = 1
		force = 18
		w_class = ITEM_SIZE_NORMAL
		edge = 1
		name = "energy dagger"
		hitsound = list('sound/weapons/blade1.ogg')
		throwforce = 35
		playsound(user, 'sound/weapons/saberon.ogg', VOL_EFFECTS_MASTER, 5)
		to_chat(user, "<span class='warning'>[src] теперь можно использовать.</span>")
		tools = list(
			TOOL_KNIFE = 1
			)
	update_icon()

/obj/item/weapon/pen/edagger/update_icon()
	if(on)
		icon_state = "edagger"
		item_state = "edagger"
	else
		clean_blood()
		icon_state = initial(icon_state) //looks like a normal pen when off.
		item_state = initial(item_state)

/*
 * Chameleon pen
 */
/obj/item/weapon/pen/chameleon
	var/signature = ""

/obj/item/weapon/pen/chameleon/attack_self(mob/user)
	..()
	signature = sanitize(input("Введите новую подпись. Оставьте пустым, чтобы быть 'Аноним'", "Новая подпись", input_default(signature)))

/obj/item/weapon/pen/chameleon/get_signature(mob/user)
	return signature ? signature : "Аноним"

/obj/item/weapon/pen/chameleon/verb/set_colour()
	set name = "Change Pen Colour"
	set category = "Object"

	var/list/possible_colours = list ("Yellow", "Green", "Pink", "Blue", "Orange", "Cyan", "Red", "Invisible", "Black")
	var/selected_type = input("Выберете новый цвет.", "Цвета ручки", null, null) as null|anything in possible_colours

	if(selected_type)
		switch(selected_type)
			if("Yellow")
				colour = "жёлтый"
			if("Green")
				colour = "зелёный"
			if("Pink")
				colour = "розовый"
			if("Blue")
				colour = "синий"
			if("Orange")
				colour = "оранжевый"
			if("Cyan")
				colour = "ядовито-голубой"
			if("Red")
				colour = "красный"
			if("Invisible")
				colour = "белый"
			else
				colour = "чёрный"
		to_chat(usr, "<span class='info'>Вы выбрали [lowertext(selected_type)] цвет.</span>")
