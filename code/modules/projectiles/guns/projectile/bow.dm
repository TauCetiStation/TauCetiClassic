/obj/item/weapon/arrow

	name = "bolt"
	cases = list("болт", "болта", "болту", "болт", "болтом", "болте")
	desc = "У меня есть подсказка для тебя - найди цель"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bolt"
	item_state = "bolt"
	throwforce = 8
	w_class = SIZE_TINY
	sharp = 1
	edge = 0

/obj/item/weapon/arrow/quill

	name = "vox quill"
	desc = "Колючее перо какого-то диковинного животного."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "quill"
	item_state = "quill"
	throwforce = 5

/obj/item/weapon/crossbow
	name = "powered crossbow"
	cases = list("арбалет", "арбалета", "арбалету", "арбалет", "арбалетом", "арбалете")
	icon = 'icons/obj/weapons.dmi'
	icon_state = "crossbow"
	item_state = "crossbow-solid"
	flags =  CONDUCT
	slot_flags = SLOT_FLAGS_BELT | SLOT_FLAGS_BACK
	w_class = SIZE_SMALL

	var/tension = 0                       // Current draw on the bow.
	var/max_tension = 3                   // Highest possible tension.
	var/release_speed = 4                 // Speed per unit of tension.
	var/mob/living/current_user = null    // Used to see if the person drawing the bow started drawing it.
	var/obj/item/weapon/arrow = null      // Nocked arrow.
	var/obj/item/weapon/stock_parts/cell/cell = null  // Used for firing special projectiles like rods.

/obj/item/weapon/crossbow/atom_init()
	. = ..()
	desc = "Старая классика в стиле [gamestory_start_year+2]. Подними эту банку!"

/obj/item/weapon/crossbow/attackby(obj/item/I, mob/user, params)
	if(!arrow)
		if(istype(I, /obj/item/weapon/arrow))
			user.drop_from_inventory(I, src)
			arrow = I
			user.visible_message("[user] вставляет [CASE(arrow, ACCUSATIVE_CASE)] в [CASE(src, ACCUSATIVE_CASE)].","Вы вставляете [CASE(arrow, ACCUSATIVE_CASE)] в [CASE(src, ACCUSATIVE_CASE)].")
			icon_state = "crossbow-nocked"
			if(cell)
				if(cell.charge >= 500)
					to_chat(user, "<span class='notice'>В результате [CASE(arrow, ACCUSATIVE_CASE)] начинает раскаляться докрасна.</span>")
					arrow.throwforce = 15
					arrow.icon_state = "metal-rod-superheated"
					cell.use(500)
			return

	if(istype(I, /obj/item/weapon/stock_parts/cell))
		if(!cell)
			user.drop_from_inventory(I, src)
			cell = I
			to_chat(user, "<span class='notice'>Вы вставляете батарейку в [CASE(src, ACCUSATIVE_CASE)] и подключаете его к катушке зажигания.</span>")
			if(arrow)
				if(istype(arrow,/obj/item/weapon/arrow) && arrow.throwforce < 15 && cell.charge >= 500)
					to_chat(user, "<span class='notice'>[capitalize(CASE(arrow, ACCUSATIVE_CASE))] мерцает и трещит, раскаляясь докрасна.</span>")
					arrow.throwforce = 15
					arrow.icon_state = "metal-rod-superheated"
					cell.use(500)
		else
			to_chat(user, "<span class='notice'>Батарейка уже установлена в [CASE(src, ACCUSATIVE_CASE)]</span>")

	else if(isscrewing(I))
		if(cell)
			var/obj/item/C = cell
			C.forceMove(get_turf(user))
			cell = null
			to_chat(user, "<span class='notice'>Вы вынимаете батарейку из [CASE(src, GENITIVE_CASE)] [I].</span>")
		else
			to_chat(user, "<span class='notice'>[capitalize(CASE(src, ACCUSATIVE_CASE))] не имеет батарейки внутри.</span>")

	else
		return ..()

/obj/item/weapon/crossbow/attack_self(mob/living/user)
	if(tension)
		if(arrow)
			user.visible_message("[user] ослабляет натяжение тетивы [CASE(src, GENITIVE_CASE)] и вытаскивает [CASE(arrow, ACCUSATIVE_CASE)].","Вы ослабляете натяжение тетивы [CASE(src, GENITIVE_CASE)] и вытаскиваете [CASE(arrow, ACCUSATIVE_CASE)].")
			var/obj/item/weapon/arrow/A = arrow
			A.loc = get_turf(src)
			arrow = null
		else
			user.visible_message("[user] ослабляет натяжение тетивы [CASE(src, GENITIVE_CASE)].", "Вы ослабляете натяжение тетивы [CASE(src, GENITIVE_CASE)].")
		tension = 0
		flags_2 &= ~CANT_BE_INSERTED
		icon_state = "crossbow"
	else
		draw(user)

/obj/item/weapon/crossbow/proc/draw(mob/user)

	if(!arrow)
		to_chat(user, "У вас нет стрелы в [CASE(src, PREPOSITIONAL_CASE)].")
		return

	if(user.restrained())
		return

	current_user = user

	user.visible_message("[user] начинает натягивать тетиву [CASE(src, GENITIVE_CASE)].","Вы начинаете натягивать тетиву [CASE(src, GENITIVE_CASE)].")
	tension = 1
	flags_2 |= CANT_BE_INSERTED
	spawn(25) increase_tension(user)

/obj/item/weapon/crossbow/proc/increase_tension(mob/user)

	if(!arrow || !tension || current_user != user) //Arrow has been fired, bow has been relaxed or user has changed.
		return

	tension++
	icon_state = "crossbow-drawn"

	if(tension>=max_tension)
		tension = max_tension
		to_chat(user, "[capitalize(CASE(src, ACCUSATIVE_CASE))] лязгает, когда вы натягиваете тетиву до максимального натяжения!")
	else
		user.visible_message("[user] натягивает тетиву [CASE(src, GENITIVE_CASE)]!", "Вы продолжаете натягивать тетиву [CASE(src, GENITIVE_CASE)]!")
		spawn(25) increase_tension(user)

/obj/item/weapon/crossbow/afterattack(atom/target, mob/user, proximity, params)
	if (target.loc == user.loc)
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	else if(target == user)
		return

	if(!tension)
		to_chat(user, "Вы не натянули тетиву!")
		return 0

	if (!arrow)
		to_chat(user, "Болт отсутствует в арбалете!")
		return 0
	else
		spawn(0) Fire(target,user,params)

/obj/item/weapon/crossbow/proc/Fire(atom/target, mob/living/user, params, reflex = 0)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/V = H.wear_suit
			V.attack_reaction(H, REACTION_GUN_FIRE)

	add_fingerprint(user)

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	user.visible_message("<span class='danger'>[user] стреляет из [CASE(src, GENITIVE_CASE)] и [CASE(arrow, ACCUSATIVE_CASE)] летит в направлении [target]!</span>","<span class='danger'>Вы отпускаете тетиву [CASE(src, GENITIVE_CASE)] и отправляете в полёт [CASE(arrow, ACCUSATIVE_CASE)] навстречу [target]!</span>")

	var/obj/item/weapon/arrow/A = arrow
	A.loc = get_turf(user)
	A.throw_at(target, (tension * release_speed) + 1, tension * release_speed, user)
	arrow = null
	flags_2 &= ~CANT_BE_INSERTED
	tension = 0
	icon_state = "crossbow"

// *(CROSSBOW craft in recipes.dm)*

/obj/item/weapon/crossbowframe1
	name = "crossbow(1 stage)"
	desc = "Чтобы завершить, вам нужно: добавить 3 стержня; заварить швы; добавить 5 проводов; добавить 3 пластика; добавить 5 проводов; затянуть болты с помощью отвертки."
	icon_state = "crossbowframe1"
	item_state = "crossbow-solid"

/obj/item/weapon/crossbowframe2
	name = "crossbow(2 stage)"
	desc = "Чтобы завершить, вам нужно: заварить швы; добавить 5 проводов; добавить 3 пластика; добавить 5 проводов; затянуть болты с помощью отвертки."
	icon_state = "crossbowframe2"
	item_state = "crossbow-solid"

/obj/item/weapon/crossbowframe3
	name = "crossbow(3 stage)"
	desc = "Чтобы завершить, вам нужно: добавить 5 проводов; добавить 3 пластика; добавить 5 проводов; затянуть болты с помощью отвертки."
	icon_state = "crossbowframe3"
	item_state = "crossbow-solid"

/obj/item/weapon/crossbowframe4
	name = "crossbow(4 stage)"
	desc = "Чтобы завершить, вам нужно: добавить 3 пластика; добавить 5 проводов; затянуть болты с помощью отвертки."
	icon_state = "crossbowframe4"
	item_state = "crossbow-solid"

/obj/item/weapon/crossbowframe5
	name = "crossbow(5 stage)"
	desc = "Чтобы завершить, вам нужно: добавить 5 проводов; затянуть болты с помощью отвертки."
	icon_state = "crossbowframe5"
	item_state = "crossbow-solid"

/obj/item/weapon/crossbowframe6
	name = "crossbow(6 stage)"
	desc = "Чтобы завершить, вам нужно: затянуть болты с помощью отвертки."
	icon_state = "crossbowframe6"
	item_state = "crossbow-solid"

/obj/item/weapon/crossbow/vox
	max_tension = 5
	release_speed = 5
