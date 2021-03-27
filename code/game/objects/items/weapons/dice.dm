#define AMPLITUDE 3
#define SLIGHTLY_CONFUSED 10
//from tg
/obj/item/weapon/dice
	name = "d6"
	desc = "A die with six sides. Basic and servicable."
	icon = 'icons/obj/dice.dmi'
	icon_state = "d6"
	w_class = ITEM_SIZE_TINY
	var/sides = 6
	var/result
	var/accursed_type = /obj/item/weapon/dice/ghost
	attack_verb = list("diced")

/obj/item/weapon/dice/examine(mob/user)
	..()
	to_chat(user, "The top side is [result].")

/obj/item/weapon/dice/ghost
	desc = "Accursed die with six sides. Basic and servicable."
	var/normal_type = /obj/item/weapon/dice
	icon_state = "gd6"
	attack_verb = list("diced", "accursed")

/obj/item/weapon/dice/ghost/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/occult_scanner))
		var/obj/item/device/occult_scanner/OS = I
		OS.scanned_type = src.type
		to_chat(user, "<span class='notice'>[src] has been succesfully scanned by [OS]</span>")

	else if(istype(I, /obj/item/weapon/nullrod) && isliving(user))
		var/mob/living/L = user
		if(L.getBrainLoss() >= 60 || (L.mind && (L.mind.holy_role || L.mind.role_alt_title == "Paranormal Investigator")))
			poof()

	else
		return ..()

/obj/item/weapon/dice/ghost/proc/poof()
	loc.visible_message("<span class='warning'>[src] trembles in a scary manner.</span>")
	var/time = 30
	var/amplitude
	var/light_range
	while(time > 0)
		amplitude = time/10
		light_range = (30-time)/10
		pixel_x = rand(-amplitude, amplitude)
		pixel_y = rand(-amplitude/3, amplitude/3)
		set_light(light_range, 1, "#a2fad1")
		time--
		sleep(1)
	for(var/mob/living/A in viewers(3,   loc))
		A.confused += SLIGHTLY_CONFUSED
	loc.visible_message("<span class='warning'>You hear a loud pop, as [src] poofs out of existence.</span>")
	playsound(src, 'sound/effects/bubble_pop.ogg', VOL_EFFECTS_MASTER)
	qdel(src)

/obj/item/weapon/dice/atom_init()
	. = ..()
	if(!result)
		result = rand(1, sides)
	icon_state = "[initial(icon_state)][result]"

/obj/item/weapon/dice/d00/atom_init()
	. = ..()
	result = (result - 1)*10

/obj/item/weapon/dice/ghost/d00/atom_init()
	. = ..()
	result = (result - 1)*10

/obj/item/weapon/dice/d2
	name = "d2"
	desc = "A die with two sides. Coins are undignified!"
	icon_state = "d2"
	sides = 2
	accursed_type = /obj/item/weapon/dice/ghost/d2

/obj/item/weapon/dice/ghost/d2
	name = "d2"
	desc = "Accursed die with two sides. Coins are undignified!"
	icon_state = "gd2"
	sides = 2
	normal_type = /obj/item/weapon/dice/d2

/obj/item/weapon/dice/d4
	name = "d4"
	desc = "A die with four sides. The nerd's caltrop."
	icon_state = "d4"
	sides = 4
	accursed_type = /obj/item/weapon/dice/ghost/d4

/obj/item/weapon/dice/ghost/d4
	name = "d4"
	desc = "Accursed die with four sides. The nerd's caltrop."
	icon_state = "gd4"
	sides = 4
	normal_type = /obj/item/weapon/dice/d4

/obj/item/weapon/dice/d8
	name = "d8"
	desc = "A die with eight sides. It feels... lucky."
	icon_state = "d8"
	sides = 8
	accursed_type = /obj/item/weapon/dice/ghost/d8

/obj/item/weapon/dice/ghost/d8
	name = "d8"
	desc = "Accursed die with eight sides. It feels... unlucky."
	icon_state = "gd8"
	sides = 8
	normal_type = /obj/item/weapon/dice/d8

/obj/item/weapon/dice/d10
	name = "d10"
	desc = "A die with ten sides. Useful for percentages."
	icon_state = "d10"
	sides = 10
	accursed_type = /obj/item/weapon/dice/ghost/d10

/obj/item/weapon/dice/ghost/d10
	name = "d10"
	desc = "Accursed die with ten sides. Useful for percentages."
	icon_state = "gd10"
	sides = 10
	normal_type = /obj/item/weapon/dice/d10

/obj/item/weapon/dice/d00
	name = "d00"
	desc = "A die with ten sides. Works better for d100 rolls than a golfball."
	icon_state = "d00"
	sides = 10
	accursed_type = /obj/item/weapon/dice/ghost/d00

/obj/item/weapon/dice/ghost/d00
	name = "d00"
	desc = "Accursed die with ten sides. Works better for d100 rolls than a golfball."
	icon_state = "gd00"
	sides = 10
	normal_type = /obj/item/weapon/dice/d00

/obj/item/weapon/dice/d12
	name = "d12"
	desc = "A die with twelve sides. There's an air of neglect about it."
	icon_state = "d12"
	sides = 12
	accursed_type = /obj/item/weapon/dice/ghost/d12

/obj/item/weapon/dice/ghost/d12
	name = "d12"
	desc = "A die with twelve sides. There's an air of neglect about it."
	icon_state = "gd12"
	sides = 12
	normal_type = /obj/item/weapon/dice/d12

/obj/item/weapon/dice/d20
	name = "d20"
	desc = "A die with twenty sides. The prefered die to throw at the GM."
	icon_state = "d20"
	sides = 20
	accursed_type = /obj/item/weapon/dice/ghost/d20

/obj/item/weapon/dice/ghost/d20
	name = "d20"
	desc = "Accursed die with twenty sides. The prefered die to throw at the GM."
	icon_state = "gd20"
	sides = 20
	normal_type = /obj/item/weapon/dice/d20

/obj/item/weapon/dice/attack_self(mob/user)
	diceroll(user)

/obj/item/weapon/dice/ghost/d20/attack_self(mob/living/user)
	diceroll(user)
	if(result == 20)
		if(user.a_intent == INTENT_HELP)
			to_chat(user, "<span class='notice'>You suddenly feel sligly better because of your own luck.</span>")
			user.adjustBruteLoss(-1)
			user.adjustFireLoss(-1)
		else
			to_chat(user, "<span class='warning'>You suddenly feel bamboozled because of your own luck!</span>")
			user.confused += SLIGHTLY_CONFUSED
	if(result == 1)
		poof()

/obj/item/weapon/dice/ghost/d20/throw_at(mob/living/target, range, speed, mob/living/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback)
	diceroll()
	..()
	if(result == 20 && istype(target) && istype(thrower))
		if(thrower.a_intent == INTENT_HELP)
			to_chat(target, "<span class='notice'>You suddenly feel sligly better because of [thrower]'s luck.</span>")
			target.adjustBruteLoss(-1)
			target.adjustFireLoss(-1)
		else
			to_chat(target, "<span class='warning'>You suddenly feel bamboozled because of [thrower]'s luck!</span>")
			target.confused += SLIGHTLY_CONFUSED
	if(result == 1)
		poof()

/obj/item/weapon/dice/after_throw(datum/callback/callback)
	..()
	diceroll()

/obj/item/weapon/dice/ghost/attack_ghost()
	visible_message("<span class='notice'>\the [src] appears to fly up into the air, levitating.</span>")
	var/time = 15
	while(time > 0)
		pixel_x = rand(-AMPLITUDE/3, AMPLITUDE/3)
		pixel_y = rand(-AMPLITUDE, AMPLITUDE)
		time--
		sleep(1)
	pixel_x = 0
	pixel_y = 0
	diceroll()
	if(prob(1))
		poof()

/obj/item/weapon/dice/proc/diceroll(mob/user)
	result = rand(1, sides)
	var/comment = ""
	if(sides == 20 && result == 20)
		comment = "Nat 20!"
	else if(sides == 20 && result == 1)
		comment = "Ouch, bad luck."
	icon_state = "[initial(icon_state)][result]"
	if(istype(src, /obj/item/weapon/dice/d00) || istype(src, /obj/item/weapon/dice/ghost/d00))
		result = (result - 1)*10
	if(user) //Dice was rolled in someone's hand
		user.visible_message("<span class='notice'>[user] has thrown [src]. It lands on [result]. [comment]</span>",
							 "<span class='notice'>You throw [src]. It lands on [result]. [comment]</span>",
							 "<span class='notice'>You hear [src] landing on [result]. [comment]</span>")
	else //Dice was thrown and is coming to rest
		visible_message("<span class='notice'>[src] rolls to a stop, landing on [result]. [comment]</span>")

/obj/item/weapon/dice/d4/Crossed(atom/movable/AM)
	if(!ishuman(AM))
		return
	var/mob/living/carbon/human/H = AM
	if(!H.shoes && !H.species.flags[NO_MINORCUTS] && !H.buckled  && !HAS_TRAIT(AM, TRAIT_LIGHT_STEP))
		to_chat(H, "<span class='userdanger'>You step on the D4!</span>")
		H.apply_damage(4, BRUTE, pick(BP_L_LEG , BP_R_LEG))
		H.Weaken(3)

/obj/item/weapon/dice/ghost/d4/Crossed(atom/movable/AM)
	if(!ishuman(AM))
		return
	var/mob/living/carbon/human/H = AM
	if(!H.shoes && !H.species.flags[NO_MINORCUTS] && !H.buckled && !HAS_TRAIT(AM, TRAIT_LIGHT_STEP))
		to_chat(H, "<span class='userdanger'>You really regret stepping on the accursed D4!</span>")
		H.apply_damage(4, BRUTE, pick(BP_L_LEG , BP_R_LEG))
		H.Weaken(3)
		H.confused += SLIGHTLY_CONFUSED
		if(prob(25)) // The chance of getting 1 on a D4.
			poof()

//bag
/obj/item/weapon/storage/pill_bottle/dice
	name = "bag of dice"
	desc = "Contains all the luck you'll ever need."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"

/obj/item/weapon/storage/pill_bottle/dice/atom_init()
	. = ..()
	new /obj/item/weapon/dice/d4(src)
	new /obj/item/weapon/dice(src)
	new /obj/item/weapon/dice/d8(src)
	new /obj/item/weapon/dice/d10(src)
	new /obj/item/weapon/dice/d00(src)
	new /obj/item/weapon/dice/d12(src)
	new /obj/item/weapon/dice/d20(src)

/obj/item/weapon/storage/pill_bottle/ghostdice
	name = "bag of dice"
	desc = "Contains all the misfortune you'll ever need."
	icon = 'icons/obj/dice.dmi'
	icon_state = "gdicebag"

/obj/item/weapon/storage/pill_bottle/ghostdice/atom_init()
	. = ..()
	new /obj/item/weapon/dice/ghost/d4(src)
	new /obj/item/weapon/dice/ghost(src)
	new /obj/item/weapon/dice/ghost/d8(src)
	new /obj/item/weapon/dice/ghost/d10(src)
	new /obj/item/weapon/dice/ghost/d00(src)
	new /obj/item/weapon/dice/ghost/d12(src)
	new /obj/item/weapon/dice/ghost/d20(src)

/obj/item/weapon/storage/pill_bottle/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/occult_scanner))
		var/obj/item/device/occult_scanner/OS = I
		OS.scanned_type = src.type
		to_chat(user, "<span class='notice'>[src] has been succesfully scanned by [OS]</span>")

	else
		return ..()

#undef AMPLITUDE
#undef SLIGHTLY_CONFUSED
