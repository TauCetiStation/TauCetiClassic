/*
 * Poly prizes
 */
/obj/item/toy/prize/poly
	icon = 'tauceti/items/toys/toy_poly.dmi'
	icon_state = "poly_classic"

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/poly/attack_self(mob/user as mob)
	if(cooldown < world.time - 8)
		user << "<span class='notice'>You play with [src].</span>"
		cooldown = world.time

/obj/item/toy/prize/poly/attack_hand(mob/user as mob)
	if(loc == user)
		if(cooldown < world.time - 8)
			user << "<span class='notice'>You play with [src].</span>"
			cooldown = world.time
			return
	..()

/obj/item/toy/prize/poly/polyclassic
	name = "toy classic Poly"
	desc = "Mini-Borg action figure! Limited edition! 1/11. First in collection. First Poly."

/obj/item/toy/prize/poly/polypink
	name = "toy pink Poly"
	desc = "Mini-Borg action figure! Limited edition! 2/11. Parties. Are. Serious!"
	icon_state = "poly_pink"

/obj/item/toy/prize/poly/polydark
	name = "toy dark Poly"
	desc = "Mini-Borg action figure! Limited edition! 3/11. Dangerously."
	icon_state = "poly_dark"

/obj/item/toy/prize/poly/polywhite
	name = "toy white Poly"
	desc = "Mini-Borg action figure! Limited edition! 4/11. Don't throw at snow."
	icon_state = "poly_white"


/obj/item/toy/prize/poly/polyalien
	name = "toy alien Poly"
	desc = "Mini-Borg action figure! Limited edition! 5/11. ...Huh?"
	icon_state = "poly_alien"

/obj/item/toy/prize/poly/polyjungle
	name = "toy jungle Poly"
	desc = "Mini-Borg action figure! Limited edition! 6/11. Commencing operation Snake Eater."
	icon_state = "poly_jungle"

/obj/item/toy/prize/poly/polyfury
	name = "toy fury Poly"
	desc = "Mini-Borg action figure! Limited edition! 7/11. Behold the flames of fury, the fires in hell shall purge me clean!"
	icon_state = "poly_fury"

/obj/item/toy/prize/poly/polysky
	name = "toy sky Poly"
	desc = "Mini-Borg action figure! Limited edition! 8/11. A little bit of blue sky in a dark space."
	icon_state = "poly_sky"

/obj/item/toy/prize/poly/polysec
	name = "toy security Poly"
	desc = "Mini-Borg action figure! Limited edition! 9/11. Good old security Poly."
	icon_state = "poly_sec"

/obj/item/toy/prize/poly/polycompanion
	name = "toy companion Poly"
	desc = "Mini-Borg action figure! Limited edition! 10/11. He's loves you."
	icon_state = "poly_companion"

	attack_self(mob/user as mob)
		user << "\blue You have clicked a switch behind the toy."
		src.icon_state = "poly_companion" + pick("1","2","")

		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			H.update_inv_l_hand()
			H.update_inv_r_hand()

/obj/item/toy/prize/poly/polygold
	name = "golden Poly"
	desc = "Mini-Borg action figure! Limited edition! 11/11. Fully from gold and platinum"
	icon_state = "poly_gold"

/obj/item/toy/prize/poly/polyspecial
	name = "toy special Poly"
	desc = "Mini-Borg action figure! Limited edition! 11/11. Fully from gold and platinum"
	icon_state = "poly_special"

	attack_self(mob/user as mob)
		user << "\blue You have clicked a switch behind the toy."
		src.icon_state = "poly_special" + pick("1","2","")
		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			H.update_inv_l_hand()
			H.update_inv_r_hand()

