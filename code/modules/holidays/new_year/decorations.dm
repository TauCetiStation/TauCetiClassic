#define FLICKER_CD_MAX 5
#define FLICKER_CD_MIN 4

/obj/item/decoration
	name = "decoration"
	desc = "Winter is coming!"
	icon = 'icons/holidays/new_year/decorations.dmi'
	icon_state = "santa"
	layer = 4.1

/obj/item/decoration/attack_hand(mob/user)
	var/choice = input("Do you want to take \the [src]?") in list("Yes", "Cancel")
	if(choice == "Yes" && get_dist(src, user) <= 1)
		..()

/obj/item/decoration/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(iswallturf(target))
		usr.remove_from_mob(src)
		forceMove(target)

// Garland
/obj/item/decoration/garland
	name = "garland"
	desc = "Beautiful lights! Shinee!"
	icon_state = "garland_1"
	var/icon_state_off = "garland"
	var/light_colors = list("#ff0000", "#6111ff", "#ffa500", "#44faff")
	var/on = TRUE
	var/brightness = 4
	var/random = TRUE
	var/variations = 3
	glow_icon = 'icons/holidays/new_year/decorations.dmi'

/obj/item/decoration/garland/long
	icon_state = "garland_1"
	icon_state_off = "garland_1"
	glow_icon_state = "garland_1_lights"
	random = FALSE

/obj/item/decoration/garland/medium
	icon_state = "garland_2"
	icon_state_off = "garland_2"
	glow_icon_state = "garland_2_lights"
	random = FALSE

/obj/item/decoration/garland/short
	icon_state = "garland_3"
	icon_state_off = "garland_3"
	glow_icon_state = "garland_3_lights"
	random = FALSE

/obj/item/decoration/garland/proc/update_garland()
	if(on)
		icon_state = "[icon_state_off]_on"
		set_light(brightness)
	else
		icon_state = "[icon_state_off]"
		set_light(0)

/obj/item/decoration/garland/atom_init()
	. = ..()
	if(random)
		icon_state_off = "garland_[rand(1, variations)]"
		glow_icon_state = "[icon_state_off]_lights"

	light_color = pick(light_colors)
	update_garland()

/obj/item/decoration/garland/attack_self(mob/user)
	. = ..()
	if(user.is_busy())
		return
	if(do_after(user, 5, target = src))
		toggle()

/obj/item/decoration/garland/verb/toggle()
	set name = "Toggle garland"
	set category = "Object"
	set src in view(1)

	var/mob/living/carbon/C = usr
	on = !on
	C.visible_message("<span class='notice'>[C] turns \the [src] [on ? "on" : "off"].</span>", "<span class='notice'>You turn \the [src] [on ? "on" : "off"].</span>")
	update_garland()

// Tinsels
/obj/item/decoration/tinsel
	name = "tinsel"
	desc = "What's this? What's this? There's color everywhere!"
	icon = 'icons/holidays/new_year/tinsel.dmi'
	icon_state = "1"
	var/variations = 20
	var/random = TRUE

/obj/item/decoration/tinsel/atom_init()
	. = ..()
	if(random)
		icon_state = "[rand(1, variations)]"

/obj/item/decoration/tinsel/attack_self(mob/user)
	. = ..()
	if(user.is_busy())
		return
	set_dir(turn(dir,-90))

/obj/item/decoration/tinsel/socks
	icon_state = "1"
	random = FALSE

/obj/item/decoration/tinsel/snowmen
	icon_state = "2"
	random = FALSE

/obj/item/decoration/tinsel/pines
	icon_state = "3"
	random = FALSE

/obj/item/decoration/tinsel/stars
	icon_state = "4"
	random = FALSE

/obj/item/decoration/tinsel/balls
	icon_state = "5"
	random = FALSE

// Snowflakes
/obj/item/decoration/snowflake
	name = "snowflake"
	desc = "Snowflakes from very soft and pleasant to touch material."
	icon_state = "snowflakes_1"

/obj/item/decoration/snowflake/atom_init()
	. = ..()
	icon_state = "snowflakes_[rand(1, 4)]"

// Snowman head
/obj/item/decoration/snowman
	name = "snowman head"
	desc = "Snowman head, which looks right into your soul."
	icon_state = "snowman"

// Xmas tree
/obj/item/device/flashlight/lamp/fir/special
	name = "present xmas tree"
	desc = "Hello, happy holidays, we have got presents..."

	layer = FLY_LAYER
	var/gifts_dealt = 0
	var/flicker_raising = FALSE
	var/light_flicker = 5

/obj/item/device/flashlight/lamp/fir/special/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/clickplace)

/obj/item/device/flashlight/lamp/fir/special/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return

	if(light_flicker >= FLICKER_CD_MAX)
		flicker_raising = FALSE
	else if(light_flicker <= FLICKER_CD_MIN)
		flicker_raising = TRUE
	light_color = pick("#39ff49", "#ff2f2f", "#248aff", "#fffa18")
	light_flicker += flicker_raising ? 1 : -1
	set_light(light_flicker)

/obj/item/device/flashlight/lamp/fir/special/attack_self(mob/user)
	. = ..()
	if(!.)
		return
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/device/flashlight/lamp/fir/special/examine(mob/user)
	..()
	if(!gifts_dealt || ((world.time - gifts_dealt) > 5000))
		to_chat(user, "<span class='notice'>Looks like there is something stuck between the branches... Have you been a good boy this year?</span>")
	to_chat(user, "<span class='notice'>You can place a wrapped item here as a gift to someone special.</span>")

/obj/item/device/flashlight/lamp/fir/special/attackby(obj/item/I, mob/user, params)
	if(iswrenching(I))
		return ..()
	if(I.flags & ABSTRACT)
		return
	if(istype(I, /obj/item/weapon/gift))
		var/obj/item/weapon/gift/present = I
		var/recipient = sanitize(input("Who is that present for? Write a name (Do it right):") as text|null)
		var/sender = sanitize(input("Enter your name:") as text|null)
		if(src && recipient && sender && present && get_dist(src, user) <= 1)
			present.recipient = recipient
			present.sender = sender
			user.drop_from_inventory(present, src)
			user.visible_message("[user] gently puts a gift under \the [src] .", "<span class='notice'>You gently put a gift under \the [src].</span>")
		return
	user.visible_message("<span class='notice'>[user] stands on \his tiptoes to hang [I] on [src].</span>")
	if(!do_after(user, 10, TRUE, src))
		to_chat(user, "<span class='warning'>You fail to hang [I] on [src]!</span>")
		return
	. = ..()
	if(istype(I, /obj/item/organ/external/head))
		I.set_dir(2) // Rotate head face to us
		I.transform = turn(null, null)	//Turn it to initial angle
	I.layer = layer + 0.1

/obj/item/device/flashlight/lamp/fir/special/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/how_many_gifts = 0
	var/choosen_gift
	for(var/O in src.contents)
		if(istype(O, /obj/item/weapon/gift))
			var/obj/item/weapon/gift/present = O
			if(present.recipient == H.name)
				how_many_gifts++
				choosen_gift = present
	if(how_many_gifts)
		var/obj/item/weapon/gift/G = choosen_gift
		to_chat(user, "<span class='notice'>Looks like there is [how_many_gifts] gifts for you under the tree!</span>")
		visible_message("<span class='notice'>[H] takes a gift from \the [src].</span>",
			"<span class='notice'>You take a gift from \the [src].</span>")
		G.forceMove(H.loc)
		user.put_in_active_hand(G)
	else
		shake()
	return

/obj/item/device/flashlight/lamp/fir/special/verb/shake()
	set name = "Shake tree"
	set category = "Object"
	set src in view(1)

	var/mob/living/carbon/C = usr

	if(iscarbon(C))
		if(!gifts_dealt || ((world.time - gifts_dealt) > 5000))

			C.visible_message("<span class='notice'>[C] shakes [src].</span>","<span class='notice'>You shake [src].</span>")

			var/bad_boy = 0
			for(var/datum/job/job in SSjob.all_occupations)
				if(jobban_isbanned(C, job.title))
					bad_boy += 1
			if(!bad_boy)
				to_chat(C, "<span class='notice'>You understand that this year you was good boy!</span>")
				C.adjustBruteLoss(-1)
				C.adjustToxLoss(-1)
				C.adjustFireLoss(-1)
			if(bad_boy >= 5)
				to_chat(C, "<span class='notice'>You understand that this year you was bad boy!</span>")
				C.adjustBruteLoss(10)
				C.adjustToxLoss(10)
				C.adjustFireLoss(10)

			new /obj/item/weapon/present(src.loc)
			new /obj/item/weapon/present(src.loc)
			new /obj/item/weapon/present(src.loc)
			if(prob(10))
				new	/obj/item/weapon/present/special(src.loc)
				new	/obj/item/weapon/present/special(src.loc)
				new	/obj/item/weapon/present/special(src.loc)
			else
				new /obj/item/weapon/present(src.loc)
				new /obj/item/weapon/present(src.loc)
				new /obj/item/weapon/present(src.loc)
			gifts_dealt = world.time
		else
			C.visible_message("<span class='notice'>[C] shakes [src].</span>", "<span class='notice'>You shake [src] but nothing happens. Have patience!</span>")

/obj/item/device/flashlight/lamp/fir/special/alternative
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_c"

/obj/structure/snowman
	name = "snowman"
	desc = "That's a snowman. He is staring at you. Where is his hat, though?"
	icon = 'icons/holidays/new_year/decorations.dmi'
	icon_state = "snowman_s"
	anchored = FALSE

	max_integrity = 50
	damage_deflection = 5
	resistance_flags = CAN_BE_HIT

/obj/structure/snowman/attackby(obj/item/W, mob/user)
	. = ..()
	if(istype(W, /obj/item/clothing/head/that))
		if(icon_state == "snowman_s")
			qdel(W)
			icon_state = "snowman_hat"
			visible_message("<span class='notice'>[user] puts a hat on the snowman. He looks happy!</span>",
			"<span class='notice'>You put a hat on the snowman. He looks happy!</span>")
		else
			to_chat(user, "<span class='warning'>But snowman already has a hat!</span>")
		return
	..()

/obj/structure/snowman/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir)
	. = ..()
	if(. && !QDELING(src))
		visible_message("<span class='notice'>[src] is damaged!</span>")

/obj/structure/snowman/deconstruct(disassembled)
	if(flags & NODECONSTRUCT)
		return ..()
	visible_message("<span class='warning'>[src] is destroyed!</span>")
	for(var/i in 1 to 6)
		new /obj/item/snowball(loc)
	if(icon_state == "snowman_hat")
		new /obj/item/clothing/head/that(loc)
	..()


/obj/item/device/flashlight/lamp/fir_small
	name = "small fir"
	desc = "Маленькая ёлочка."
	icon = 'icons/holidays/new_year/decorations.dmi'
	icon_state = "small_christmas_tree"
	brightness_on = 2
	light_power = 0.6
	light_color = list("#ff0000", "#6111ff", "#ffa500", "#44faff")

	glow_icon = 'icons/holidays/new_year/decorations.dmi'
	glow_icon_state = "small_christmas_tree_lights"


/obj/item/decoration/wreath
	name = "chistmas wreath"
	desc = "Merry Christmas!"
	icon_state = "wreath"

/obj/item/weapon/cracker
	name = "cracker"
	cases = list("хлопушка", "хлопушки", "хлопушке", "хлопушку", "хлопушкой", "хлопушке")
	desc = "Трубка с пружинкой на дне, наполненная конфетти."

	icon = 'icons/holidays/new_year/decorations.dmi'
	icon_state = "cracker_0"
	item_state_world= "cracker_0_world"

	w_class = SIZE_TINY

	var/used = FALSE

/obj/item/weapon/cracker/afterattack(atom/target, mob/user, proximity, params)
	if(used)
		return

	var/turf/L = get_turf(src)
	var/shot_angle = Get_Angle(L,get_turf(target))
	var/travel_x = round(sin(shot_angle) * 96)
	var/travel_y = round(cos(shot_angle) * 96) + 16

	var/obj/effect/abstract/particle_holder/Holder = new /obj/effect/abstract/particle_holder(L, /particles/cracker, PARTICLE_FADEOUT|PARTICLE_FLICK)
	Holder.modify_particles_value("velocity", generator("vector", list(travel_x, travel_y), list(travel_x, travel_y), UNIFORM_RAND) + generator("circle", 16, 16, UNIFORM_RAND))

	playsound(src, 'sound/effects/snap.ogg', VOL_EFFECTS_MASTER)

	used = TRUE

	update_icon()

/obj/item/weapon/cracker/update_world_icon()
	update_icon()

/obj/item/weapon/cracker/update_icon()
	if(item_state_world && (flags_2 & IN_INVENTORY || flags_2 & IN_STORAGE)) // big inventory icon, if we have it
		icon_state = "cracker_[used]"
	else // default or small icon
		icon_state = "cracker_[used]_world"

/obj/item/weapon/sparkler
	name = "sparkler"
	cases = list("бенгальский огонь", "бенгальского огня", "бенгальскому огню", "бенгальский огонь", "бенгальский огнём", "бенгальском огне")
	desc = "Новый-новый-новый-новый год. Все мечты исполнит."

	icon = 'icons/holidays/new_year/decorations.dmi'
	icon_state = "sparkler_0"

	w_class = SIZE_TINY

	var/used = FALSE
	var/obj/effect/abstract/particle_holder/Holder_1
	var/obj/effect/abstract/particle_holder/Holder_2

/obj/item/weapon/sparkler/Destroy()
	Holder_1.delete_particle()
	Holder_2.delete_particle()
	return ..()

/obj/item/weapon/sparkler/attack_self(mob/user)
	if(used)
		return

	Holder_1 = new /obj/effect/abstract/particle_holder(src, /particles/sparkler_inner, PARTICLE_FADEOUT|PARTICLE_NO_TRANSFORM|PARTICLE_ATTACH_MOB|PARTICLE_LIGHT)
	Holder_2 = new /obj/effect/abstract/particle_holder(src, /particles/sparkler_outer, PARTICLE_FADEOUT|PARTICLE_NO_TRANSFORM|PARTICLE_ATTACH_MOB|PARTICLE_LIGHT)
	addtimer(CALLBACK(src, PROC_REF(stop_sparkler)), 30 SECONDS)

	playsound(src, 'sound/items/matchstick_light.ogg', VOL_EFFECTS_MASTER)

	used = TRUE

/obj/item/weapon/sparkler/proc/stop_sparkler()
	icon_state = "sparkler_1"
	Holder_1.delete_particle()
	Holder_2.delete_particle()

#undef FLICKER_CD_MAX
#undef FLICKER_CD_MIN
