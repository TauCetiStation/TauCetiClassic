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
	icon_state = "garland_on"
	var/icon_state_off = "garland"
	var/light_colors = list("#ff0000", "#6111ff", "#ffa500", "#44faff")
	var/on = TRUE
	var/brightness = 4

/obj/item/decoration/garland/proc/update_garland()
	if(on)
		icon_state = "[icon_state_off]_on"
		set_light(brightness)
	else
		icon_state = "[icon_state_off]"
		set_light(0)

/obj/item/decoration/garland/atom_init()
	. = ..()
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
	desc = "Soft tinsel, pleasant to the touch. Ahhh..."
	icon = 'icons/holidays/new_year/tinsel.dmi'
	icon_state = "1"
	var/variations = 4
	var/random = TRUE // random color

/obj/item/decoration/tinsel/atom_init()
	. = ..()
	if(random)
		icon_state = "[rand(1, variations)]"

/obj/item/decoration/tinsel/green
	icon_state = "1"
	random = FALSE

/obj/item/decoration/tinsel/red
	icon_state = "2"
	random = FALSE

/obj/item/decoration/tinsel/yellow
	icon_state = "3"
	random = FALSE

/obj/item/decoration/tinsel/white
	icon_state = "4"
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
		to_chat(user, "<span class='notice'>Looks like there is [how_many_gifts] gifts for you under \the tree!</span>")
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
			for(var/datum/job/job in SSjob.occupations)
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

#undef FLICKER_CD_MAX
#undef FLICKER_CD_MIN
