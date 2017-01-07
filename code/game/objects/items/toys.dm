/* Toys!
 * ContainsL
 *		Balloons
 *		Fake telebeacon
 *		Fake singularity
 *		Toy gun
 *		Toy crossbow
 *		Toy swords
 *		Crayons
 *		Snap pops
 *		Water flower
 */


/obj/item/toy
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	force = 0


/*
 * Balloons
 */
/obj/item/toy/balloon
	name = "water balloon"
	desc = "A translucent balloon. There's nothing in it."
	icon = 'icons/obj/toy.dmi'
	icon_state = "waterballoon-e"
	item_state = "balloon-empty"

/obj/item/toy/balloon/New()
	var/datum/reagents/R = new/datum/reagents(10)
	reagents = R
	R.my_atom = src

/obj/item/toy/balloon/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/toy/balloon/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return
	if (istype(A, /obj/structure/reagent_dispensers/watertank) && get_dist(src,A) <= 1)
		A.reagents.trans_to(src, 10)
		to_chat(user, "\blue You fill the balloon with the contents of [A].")
		src.desc = "A translucent balloon with some form of liquid sloshing around in it."
		src.update_icon()
	return

/obj/item/toy/balloon/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/weapon/reagent_containers/glass))
		if(O.reagents)
			if(O.reagents.total_volume < 1)
				to_chat(user, "The [O] is empty.")
			else if(O.reagents.total_volume >= 1)
				if(O.reagents.has_reagent("pacid", 1))
					to_chat(user, "The acid chews through the balloon!")
					O.reagents.reaction(user)
					qdel(src)
				else
					src.desc = "A translucent balloon with some form of liquid sloshing around in it."
					to_chat(user, "\blue You fill the balloon with the contents of [O].")
					O.reagents.trans_to(src, 10)
	src.update_icon()
	return

/obj/item/toy/balloon/throw_impact(atom/hit_atom)
	if(src.reagents.total_volume >= 1)
		src.visible_message("\red The [src] bursts!","You hear a pop and a splash.")
		src.reagents.reaction(get_turf(hit_atom))
		for(var/atom/A in get_turf(hit_atom))
			src.reagents.reaction(A)
		src.icon_state = "burst"
		spawn(5)
			if(src)
				qdel(src)
	return

/obj/item/toy/balloon/update_icon()
	if(src.reagents.total_volume >= 1)
		icon_state = "waterballoon"
		item_state = "balloon"
	else
		icon_state = "waterballoon-e"
		item_state = "balloon-empty"

/obj/item/toy/syndicateballoon
	name = "syndicate balloon"
	desc = "There is a tag on the back that reads \"FUK NT!11!\"."
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	force = 0
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	item_state = "syndballoon"
	w_class = 4.0

/*
 * Fake telebeacon
 */
/obj/item/toy/blink
	name = "electronic blink toy game"
	desc = "Blink.  Blink.  Blink. Ages 8 and up."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"

/*
 * Fake singularity
 */
/obj/item/toy/spinningtoy
	name = "Gravitational Singularity"
	desc = "\"Singulo\" brand spinning toy."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"

/*
 * Toy gun: Why isnt this an /obj/item/weapon/gun?
 */
/obj/item/toy/gun
	name = "cap gun"
	desc = "Looks almost like the real thing! Ages 8 and up. Please recycle in an autolathe when you're out of caps!"
	icon = 'icons/obj/gun.dmi'
	icon_state = "revolver"
	item_state = "gun"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	flags =  CONDUCT
	slot_flags = SLOT_BELT
	w_class = 3.0
	g_amt = 10
	m_amt = 10
	attack_verb = list("struck", "pistol whipped", "hit", "bashed")
	var/bullets = 7.0

	examine(mob/user)
		..()
		if(src in user)
			to_chat(user, "<span class='notice'>There are [bullets] caps\s left.</span>")

	attackby(obj/item/toy/ammo/gun/A, mob/user)

		if (istype(A, /obj/item/toy/ammo/gun))
			if (src.bullets >= 7)
				to_chat(user, "\blue It's already fully loaded!")
				return 1
			if (A.amount_left <= 0)
				to_chat(user, "\red There is no more caps!")
				return 1
			if (A.amount_left < (7 - src.bullets))
				src.bullets += A.amount_left
				to_chat(user, text("\red You reload [] caps\s!", A.amount_left))
				A.amount_left = 0
			else
				to_chat(user, text("\red You reload [] caps\s!", 7 - src.bullets))
				A.amount_left -= 7 - src.bullets
				src.bullets = 7
			A.update_icon()
			return 1
		return

	afterattack(atom/target, mob/user, flag)
		if (flag)
			return
		if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
			to_chat(usr, "\red You don't have the dexterity to do this!")
			return
		src.add_fingerprint(user)
		if (src.bullets < 1)
			user.show_message("\red *click* *click*", 2)
			playsound(user, 'sound/weapons/empty.ogg', 100, 1)
			return
		playsound(user, 'sound/weapons/Gunshot.ogg', 100, 1)
		src.bullets--
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red <B>[] fires a cap gun at []!</B>", user, target), 1, "\red You hear a gunshot", 2)

/obj/item/toy/ammo/gun
	name = "ammo-caps"
	desc = "There are 7 caps left! Make sure to recyle the box in an autolathe when it gets empty."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "357-7"
	flags = CONDUCT
	w_class = 1.0
	g_amt = 10
	m_amt = 10
	var/amount_left = 7.0

	update_icon()
		src.icon_state = text("357-[]", src.amount_left)
		src.desc = text("There are [] caps\s left! Make sure to recycle the box in an autolathe when it gets empty.", src.amount_left)
		return

/*
 * Toy crossbow
 */

/obj/item/toy/crossbow
	name = "foam dart crossbow"
	desc = "A weapon favored by many overactive children. Ages 8 and up."
	icon = 'icons/obj/gun.dmi'
	icon_state = "crossbow"
	item_state = "crossbow"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	w_class = 2.0
	attack_verb = list("attacked", "struck", "hit")
	var/bullets = 5

	examine(mob/user)
		..()
		if (bullets && src in view(2, user))
			to_chat(user, "<span class='notice'>It is loaded with [bullets] foam darts!</span>")

	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/toy/ammo/crossbow))
			if(bullets <= 4)
				user.drop_item()
				qdel(I)
				bullets++
				to_chat(user, "\blue You load the foam dart into the crossbow.")
			else
				to_chat(usr, "\red It's already fully loaded.")


	afterattack(atom/target, mob/user, flag)
		if(!isturf(target.loc) || target == user) return
		if(flag) return

		if (locate (/obj/structure/table, src.loc))
			return
		else if (bullets)
			var/turf/trg = get_turf(target)
			var/obj/effect/foam_dart_dummy/D = new/obj/effect/foam_dart_dummy(get_turf(src))
			bullets--
			D.icon_state = "foamdart"
			D.name = "foam dart"
			playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)

			for(var/i=0, i<6, i++)
				if (D)
					if(D.loc == trg) break
					step_towards(D,trg)

					for(var/mob/living/M in D.loc)
						if(!istype(M,/mob/living)) continue
						if(M == user) continue
						for(var/mob/O in viewers(world.view, D))
							O.show_message(text("\red [] was hit by the foam dart!", M), 1)
						new /obj/item/toy/ammo/crossbow(M.loc)
						qdel(D)
						return

					for(var/atom/A in D.loc)
						if(A == user) continue
						if(A.density)
							new /obj/item/toy/ammo/crossbow(A.loc)
							qdel(D)

				sleep(1)

			spawn(10)
				if(D)
					new /obj/item/toy/ammo/crossbow(D.loc)
					qdel(D)

			return
		else if (bullets == 0)
			user.Weaken(5)
			for(var/mob/O in viewers(world.view, user))
				O.show_message(text("\red [] realized they were out of ammo and starting scrounging for some!", user), 1)


	attack(mob/M, mob/user)
		src.add_fingerprint(user)

// ******* Check

		if (src.bullets > 0 && M.lying)

			for(var/mob/O in viewers(M, null))
				if(O.client)
					O.show_message(text("\red <B>[] casually lines up a shot with []'s head and pulls the trigger!</B>", user, M), 1, "\red You hear the sound of foam against skull", 2)
					O.show_message(text("\red [] was hit in the head by the foam dart!", M), 1)

			playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)
			new /obj/item/toy/ammo/crossbow(M.loc)
			src.bullets--
		else if (M.lying && src.bullets == 0)
			for(var/mob/O in viewers(M, null))
				if (O.client)	O.show_message(text("\red <B>[] casually lines up a shot with []'s head, pulls the trigger, then realizes they are out of ammo and drops to the floor in search of some!</B>", user, M), 1, "\red You hear someone fall", 2)
			user.Weaken(5)
		return

/obj/item/toy/ammo/crossbow
	name = "foam dart"
	desc = "It's nerf or nothing! Ages 8 and up."
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamdart"
	w_class = 1.0

/obj/effect/foam_dart_dummy
	name = ""
	desc = ""
	icon = 'icons/obj/toy.dmi'
	icon_state = "null"
	anchored = 1
	density = 0


/*
 * Toy swords
 */
/obj/item/toy/sword
	name = "toy sword"
	desc = "A cheap, plastic replica of an energy sword. Realistic sounds! Ages 8 and up."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "sword0"
	item_state = "sword0"
	var/active = 0.0
	w_class = 2.0
	flags = NOSHIELD
	attack_verb = list("attacked", "struck", "hit")

	attack_self(mob/user)
		src.active = !( src.active )
		if (src.active)
			to_chat(user, "\blue You extend the plastic blade with a quick flick of your wrist.")
			playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
			src.icon_state = "swordblue"
			src.item_state = "swordblue"
			src.w_class = 4
		else
			to_chat(user, "\blue You push the plastic blade back down into the handle.")
			playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
			src.icon_state = "sword0"
			src.item_state = "sword0"
			src.w_class = 2

		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			H.update_inv_l_hand()
			H.update_inv_r_hand()

		src.add_fingerprint(user)
		return

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 5
	throwforce = 5
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced")

/*
 * Crayons
 */

/obj/item/toy/crayon
	name = "crayon"
	desc = "A colourful crayon. Please refrain from eating it or putting it in your nose."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonred"
	w_class = 1.0
	attack_verb = list("attacked", "coloured")
	var/colour = "#FF0000" //RGB
	var/shadeColour = "#220000" //RGB
	var/uses = 30 //0 for unlimited uses
	var/instant = 0
	var/colourName = "red" //for updateIcon purposes
	var/list/validSurfaces = list(/turf/simulated/floor)
	var/gang = 0 //For marking territory
	var/edible = 1

	suicide_act(mob/user)
		to_chat(viewers(user), "\red <b>[user] is jamming the [src.name] up \his nose and into \his brain. It looks like \he's trying to commit suicide.</b>")
		return (BRUTELOSS|OXYLOSS)

/*
 * Snap pops
 */
/obj/item/toy/snappop
	name = "snap pop"
	desc = "Wow!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	w_class = 1

	throw_impact(atom/hit_atom)
		..()
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		new /obj/effect/decal/cleanable/ash(src.loc)
		src.visible_message("\red The [src.name] explodes!","\red You hear a snap!")
		playsound(src, 'sound/effects/snap.ogg', 50, 1)
		qdel(src)

/obj/item/toy/snappop/Crossed(H as mob|obj)
	if((ishuman(H))) //i guess carp and shit shouldn't set them off
		var/mob/living/carbon/M = H
		if(M.m_intent == "run")
			to_chat(M, "\red You step on the snap pop!")

			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(2, 0, src)
			s.start()
			new /obj/effect/decal/cleanable/ash(src.loc)
			src.visible_message("\red The [src.name] explodes!","\red You hear a snap!")
			playsound(src, 'sound/effects/snap.ogg', 50, 1)
			qdel(src)

/*
 * Water flower
 */
/obj/item/toy/waterflower
	name = "Water Flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	var/empty = 0

/obj/item/toy/waterflower/New()
	var/datum/reagents/R = new/datum/reagents(10)
	reagents = R
	R.my_atom = src
	R.add_reagent("water", 10)

/obj/item/toy/waterflower/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/toy/waterflower/afterattack(atom/A, mob/user)

	if (istype(A, /obj/item/weapon/storage/backpack ))
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	else if (istype(A, /obj/structure/reagent_dispensers/watertank) && get_dist(src,A) <= 1)
		A.reagents.trans_to(src, 10)
		to_chat(user, "\blue You refill your flower!")
		return

	else if (src.reagents.total_volume < 1)
		src.empty = 1
		to_chat(user, "\blue Your flower has run dry!")
		return

	else
		src.empty = 0


		var/obj/effect/decal/D = new/obj/effect/decal/(get_turf(src))
		D.name = "water"
		D.icon = 'icons/obj/chemical.dmi'
		D.icon_state = "chempuff"
		D.create_reagents(5)
		src.reagents.trans_to(D, 1)
		playsound(src.loc, 'sound/effects/spray3.ogg', 50, 1, -6)

		spawn(0)
			for(var/i=0, i<1, i++)
				step_towards(D,A)
				D.reagents.reaction(get_turf(D))
				for(var/atom/T in get_turf(D))
					D.reagents.reaction(T)
					if(ismob(T) && T:client)
						to_chat(T:client, "\red [user] has sprayed you with water!")
					if(ishuman(T))
						var/mob/living/carbon/human/H = T
						var/list/inv_contents = list()
						for(var/obj/item/I in H.contents)
							if(I == src) continue
							if(istype(I, /obj/item/weapon/implant)) continue
							inv_contents += I
						if(inv_contents.len)
							for(var/n=3,n>0,n--)
								var/obj/item/I = pick(inv_contents)
								I.make_wet()
				sleep(4)
			qdel(D)

		return

/obj/item/toy/waterflower/examine(mob/user)
	..()
	if(src in user)
		to_chat(user, "[reagents.total_volume] unit\s of water left!")


/*
 * Mech prizes
 */
/obj/item/toy/prize
	icon = 'icons/obj/toy.dmi'
	icon_state = "ripleytoy"
	var/cooldown = 0

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/attack_self(mob/user)
	if(cooldown < world.time - 8)
		to_chat(user, "<span class='notice'>You play with [src].</span>")
		playsound(user, 'sound/mecha/mechstep.ogg', 20, 1)
		cooldown = world.time

/obj/item/toy/prize/attack_hand(mob/user)
	if(loc == user)
		if(cooldown < world.time - 8)
			to_chat(user, "<span class='notice'>You play with [src].</span>")
			playsound(user, 'sound/mecha/mechturn.ogg', 20, 1)
			cooldown = world.time
			return
	..()

/obj/item/toy/prize/ripley
	name = "toy ripley"
	desc = "Mini-Mecha action figure! Collect them all! 1/11."

/obj/item/toy/prize/fireripley
	name = "toy firefighting ripley"
	desc = "Mini-Mecha action figure! Collect them all! 2/11."
	icon_state = "fireripleytoy"

/obj/item/toy/prize/deathripley
	name = "toy deathsquad ripley"
	desc = "Mini-Mecha action figure! Collect them all! 3/11."
	icon_state = "deathripleytoy"

/obj/item/toy/prize/gygax
	name = "toy gygax"
	desc = "Mini-Mecha action figure! Collect them all! 4/11."
	icon_state = "gygaxtoy"


/obj/item/toy/prize/durand
	name = "toy durand"
	desc = "Mini-Mecha action figure! Collect them all! 5/11."
	icon_state = "durandprize"

/obj/item/toy/prize/honk
	name = "toy H.O.N.K."
	desc = "Mini-Mecha action figure! Collect them all! 6/11."
	icon_state = "honkprize"

/obj/item/toy/prize/marauder
	name = "toy marauder"
	desc = "Mini-Mecha action figure! Collect them all! 7/11."
	icon_state = "marauderprize"

/obj/item/toy/prize/seraph
	name = "toy seraph"
	desc = "Mini-Mecha action figure! Collect them all! 8/11."
	icon_state = "seraphprize"

/obj/item/toy/prize/mauler
	name = "toy mauler"
	desc = "Mini-Mecha action figure! Collect them all! 9/11."
	icon_state = "maulerprize"

/obj/item/toy/prize/odysseus
	name = "toy odysseus"
	desc = "Mini-Mecha action figure! Collect them all! 10/11."
	icon_state = "odysseusprize"

/obj/item/toy/prize/phazon
	name = "toy phazon"
	desc = "Mini-Mecha action figure! Collect them all! 11/11."
	icon_state = "phazonprize"

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 5
	throwforce = 5
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced")

/* NYET.
/obj/item/weapon/toddler
	icon_state = "toddler"
	name = "toddler"
	desc = "This baby looks almost real. Wait, did it just burp?"
	force = 5
	w_class = 4.0
	slot_flags = SLOT_BACK
*/

//This should really be somewhere else but I don't know where. w/e
/obj/item/weapon/inflatable_duck
	name = "inflatable duck"
	desc = "No bother to sink or swim when you can just float!"
	icon_state = "inflatable"
	item_state = "inflatable"
	icon = 'icons/obj/clothing/belts.dmi'
	slot_flags = SLOT_BELT

/*
 * Action Figures
 */

/obj/item/toy/figure
	name = "Non-Specific Action Figure action figure"
	desc = null
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoy"
	var/cooldown = 0
	var/toysay = "What the fuck did you do?"

/obj/item/toy/figure/New()
    desc = "A \"Space Life\" brand [src]."

/obj/item/toy/figure/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = world.time + 50
		to_chat(user, "<span class='notice'>The [src] says \"[toysay]\"</span>")
		playsound(user, 'sound/machines/click.ogg', 20, 1)

/obj/item/toy/figure/cmo
	name = "Chief Medical Officer action figure"
	icon_state = "cmo"
	toysay = "Suit sensors!"

/obj/item/toy/figure/assistant
	name = "Assistant action figure"
	icon_state = "assistant"
	toysay = "Grey tide world wide!"

/obj/item/toy/figure/atmos
	name = "Atmospheric Technician action figure"
	icon_state = "atmos"
	toysay = "Glory to Atmosia!"

/obj/item/toy/figure/bartender
	name = "Bartender action figure"
	icon_state = "bartender"
	toysay = "Where is Pun Pun?"

/obj/item/toy/figure/borg
	name = "Cyborg action figure"
	icon_state = "borg"
	toysay = "I. LIVE. AGAIN."

/obj/item/toy/figure/botanist
	name = "Botanist action figure"
	icon_state = "botanist"
	toysay = "Dude, I see colors..."

/obj/item/toy/figure/captain
	name = "Captain action figure"
	icon_state = "captain"
	toysay = "Any heads of staff?"

/obj/item/toy/figure/cargotech
	name = "Cargo Technician action figure"
	icon_state = "cargotech"
	toysay = "For Cargonia!"

/obj/item/toy/figure/ce
	name = "Chief Engineer action figure"
	icon_state = "ce"
	toysay = "Wire the solars!"

/obj/item/toy/figure/chaplain
	name = "Chaplain action figure"
	icon_state = "chaplain"
	toysay = "Praise Space Jesus!"

/obj/item/toy/figure/chef
	name = "Chef action figure"
	icon_state = "chef"
	toysay = "Pun-Pun is a tasty burger."

/obj/item/toy/figure/chemist
	name = "Chemist action figure"
	icon_state = "chemist"
	toysay = "Get your pills!"

/obj/item/toy/figure/clown
	name = "Clown action figure"
	icon_state = "clown"
	toysay = "Honk!"

/obj/item/toy/figure/ian
	name = "Ian action figure"
	icon_state = "ian"
	toysay = "Arf!"

/obj/item/toy/figure/detective
	name = "Detective action figure"
	icon_state = "detective"
	toysay = "This airlock has grey jumpsuit and insulated glove fibers on it."

/obj/item/toy/figure/dsquad
	name = "Death Squad Officer action figure"
	icon_state = "dsquad"
	toysay = "Eliminate all threats!"

/obj/item/toy/figure/engineer
	name = "Engineer action figure"
	icon_state = "engineer"
	toysay = "Oh god, the singularity is loose!"

/obj/item/toy/figure/geneticist
	name = "Geneticist action figure"
	icon_state = "geneticist"
	toysay = "Smash!"

/obj/item/toy/figure/hop
	name = "Head of Personel action figure"
	icon_state = "hop"
	toysay = "Giving out all access!"

/obj/item/toy/figure/hos
	name = "Head of Security action figure"
	icon_state = "hos"
	toysay = "Get the justice chamber ready, I think we got a joker here."

/obj/item/toy/figure/qm
	name = "Quartermaster action figure"
	icon_state = "qm"
	toysay = "Please sign this form in triplicate and we will see about geting you a welding mask within 3 business days."

/obj/item/toy/figure/janitor
	name = "Janitor action figure"
	icon_state = "janitor"
	toysay = "Look at the signs, you idiot."

/obj/item/toy/figure/lawyer
	name = "Lawyer action figure"
	icon_state = "lawyer"
	toysay = "My client is a dirty traitor!"

/obj/item/toy/figure/librarian
	name = "Librarian action figure"
	icon_state = "librarian"
	toysay = "One day while..."

/obj/item/toy/figure/md
	name = "Medical Doctor action figure"
	icon_state = "md"
	toysay = "The patient is already dead!"

/obj/item/toy/figure/mime
	name = "Mime action figure"
	icon_state = "mime"
	toysay = "..."

/obj/item/toy/figure/miner
	name = "Shaft Miner action figure"
	icon_state = "miner"
	toysay = "Oh god it's eating my intestines!"

/obj/item/toy/figure/ninja
	name = "Ninja action figure"
	icon_state = "ninja"
	toysay = "Oh god! Stop shooting, I'm friendly!"

/obj/item/toy/figure/wizard
	name = "Wizard action figure"
	icon_state = "wizard"
	toysay = "Ei Nath!"

/obj/item/toy/figure/rd
	name = "Research Director action figure"
	icon_state = "rd"
	toysay = "Blowing all of the borgs!"

/obj/item/toy/figure/roboticist
	name = "Roboticist action figure"
	icon_state = "roboticist"
	toysay = "Big stompy mechs!"

/obj/item/toy/figure/scientist
	name = "Scientist action figure"
	icon_state = "scientist"
	toysay = "For science!"

/obj/item/toy/figure/syndie
	name = "Nuclear Operative action figure"
	icon_state = "syndie"
	toysay = "Get that fucking disk!"

/obj/item/toy/figure/secofficer
	name = "Security Officer action figure"
	icon_state = "secofficer"
	toysay = "I am the law!"

/obj/item/toy/figure/virologist
	name = "Virologist action figure"
	icon_state = "virologist"
	toysay = "The cure is potassium!"

/obj/item/toy/figure/warden
	name = "Warden action figure"
	icon_state = "warden"
	toysay = "Seventeen minutes for coughing at an officer!"

/*
Owl & Griffin toys
*/
/obj/item/toy/owl
	name = "owl action figure"
	desc = "An action figure modeled after 'The Owl', defender of justice."
	icon = 'icons/obj/toy.dmi'
	icon_state = "owlprize"
	w_class = 2
	var/cooldown = 0

/obj/item/toy/owl/attack_self(mob/user)
	if(!cooldown) //for the sanity of everyone
		var/message = pick("You won't get away this time, Griffin!", "Stop right there, criminal!", "Hoot! Hoot!", "I am the night!")
		to_chat(user, "<span class='notice'>You pull the string on the [src].</span>")
		playsound(user, 'sound/machines/click.ogg', 20, 1)
		src.loc.visible_message("<span class='danger'>[bicon(src)] [message]</span>")
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

/obj/item/toy/griffin
	name = "griffin action figure"
	desc = "An action figure modeled after 'The Griffin', criminal mastermind."
	icon = 'icons/obj/toy.dmi'
	icon_state = "griffinprize"
	w_class = 2
	var/cooldown = 0

/obj/item/toy/griffin/attack_self(mob/user)
	if(!cooldown) //for the sanity of everyone
		var/message = pick("You can't stop me, Owl!", "My plan is flawless! The vault is mine!", "Caaaawwww!", "You will never catch me!")
		to_chat(user, "<span class='notice'>You pull the string on the [src].</span>")
		playsound(user, 'sound/machines/click.ogg', 20, 1)
		src.loc.visible_message("<span class='danger'>[bicon(src)] [message]</span>")
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

/*
 * Fake nuke
 */
/obj/item/toy/nuke
	name = "\improper Nuclear Fission Explosive toy"
	desc = "A plastic model of a Nuclear Fission Explosive."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoyidle"
	w_class = 2
	var/cooldown = 0

/obj/item/toy/nuke/attack_self(mob/user)
	if (cooldown < world.time)
		cooldown = world.time + 1800 //3 minutes
		user.visible_message("<span class='warning'>[user] presses a button on [src].</span>", "<span class='notice'>You activate [src], it plays a loud noise!</span>", "<span class='italics'>You hear the click of a button.</span>")
		spawn(5) //gia said so
			icon_state = "nuketoy"
			playsound(src, 'sound/machines/Alarm.ogg', 50, 0)
			sleep(135)
			icon_state = "nuketoycool"
			sleep(cooldown - world.time)
			icon_state = "nuketoyidle"
	else
		var/timeleft = (cooldown - world.time)
		to_chat(user, "<span class='alert'>Nothing happens, and '</span>[round(timeleft/10)]<span class='alert'>' appears on a small display.</span>")
/*
 * Fake meteor
 */
/obj/item/toy/minimeteor
	name = "\improper Mini-Meteor"
	desc = "Relive the excitement of a meteor shower! SweetMeat-eor. Co is not responsible for any injuries, headaches or hearing loss caused by Mini-Meteor?"
	icon = 'icons/obj/toy.dmi'
	icon_state = "minimeteor"
	w_class = 2

/obj/item/toy/minimeteor/throw_impact(atom/hit_atom)
	if(!..())
		playsound(src, 'sound/effects/meteorimpact.ogg', 40, 1)
		for(var/mob/M in orange(10, src))
			if(!M.stat && !istype(M, /mob/living/silicon/ai))\
				shake_camera(M, 3, 1)
		qdel(src)
/*
 * Carp plushie
 */
/obj/item/toy/carpplushie
	name = "space carp plushie"
	desc = "An adorable stuffed toy that resembles a space carp."
	icon = 'icons/obj/toy.dmi'
	icon_state = "carpplushie"
	item_state = "carp_plushie"
	w_class = 2
	attack_verb = list("bitten", "eaten", "fin slapped")
//	burn_state = 0 //Burnable
	var/bitesound = 'sound/weapons/bite.ogg'

// Attack mob
/obj/item/toy/carpplushie/attack(mob/M, mob/user)
	playsound(loc, bitesound, 20, 1)	// Play bite sound in local area
	return ..()

// Attack self
/obj/item/toy/carpplushie/attack_self(mob/user)
	playsound(src.loc, bitesound, 20, 1)
	to_chat(user, "<span class='notice'>You pet [src]. D'awww.</span>")
	return ..()


/*
 * A Deck of Cards
 */

/obj/item/toy/cards
	name = "deck of cards"
	desc = "A deck of space-grade playing cards."
	icon = 'icons/obj/cards.dmi'
	icon_state = "deck_full"
	w_class = 2.0
	var/list/cards = list()

/obj/item/toy/cards/New()
	..()
	for(var/i = 2; i <= 10; i++)
		cards += "[i] of Hearts"
		cards += "[i] of Spades"
		cards += "[i] of Clubs"
		cards += "[i] of Diamonds"
	cards += "King of Hearts"
	cards += "King of Spades"
	cards += "King of Clubs"
	cards += "King of Diamonds"
	cards += "Queen of Hearts"
	cards += "Queen of Spades"
	cards += "Queen of Clubs"
	cards += "Queen of Diamonds"
	cards += "Jack of Hearts"
	cards += "Jack of Spades"
	cards += "Jack of Clubs"
	cards += "Jack of Diamonds"
	cards += "Ace of Hearts"
	cards += "Ace of Spades"
	cards += "Ace of Clubs"
	cards += "Ace of Diamonds"


/obj/item/toy/cards/attack_hand(mob/user)
	var/choice = null
	if(cards.len == 0)
		src.icon_state = "deck_empty"
		to_chat(user, "<span class='notice'>There are no more cards to draw.</span>")
		return
	var/obj/item/toy/singlecard/H = new/obj/item/toy/singlecard(user.loc)
	choice = cards[1]
	H.cardname = choice
	H.parentdeck = src
	src.cards -= choice
	H.pickup(user)
	user.put_in_active_hand(H)
	src.visible_message("<span class='notice'>[user] draws a card from the deck.</span>", "<span class='notice'>You draw a card from the deck.</span>")
	if(cards.len > 26)
		src.icon_state = "deck_full"
	else if(cards.len > 10)
		src.icon_state = "deck_half"
	else if(cards.len > 1)
		src.icon_state = "deck_low"

/obj/item/toy/cards/attack_self(mob/user)
	cards = shuffle(cards)
	playsound(user, 'sound/items/cardshuffle.ogg', 50, 1)
	user.visible_message("<span class='notice'>[user] shuffles the deck.</span>", "<span class='notice'>You shuffle the deck.</span>")

/obj/item/toy/cards/attackby(obj/item/toy/singlecard/C, mob/living/user)
	..()
	if(istype(C))
		if(C.parentdeck == src)
			src.cards += C.cardname
			user.remove_from_mob(C)
			user.visible_message("<span class='notice'>[user] adds a card to the bottom of the deck.</span>","<span class='notice'>You add the card to the bottom of the deck.</span>")
			qdel(C)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")
		if(cards.len > 26)
			src.icon_state = "deck_full"
		else if(cards.len > 10)
			src.icon_state = "deck_half"
		else if(cards.len > 1)
			src.icon_state = "deck_low"


/obj/item/toy/cards/attackby(obj/item/toy/cardhand/C, mob/living/user)
	..()
	if(istype(C))
		if(C.parentdeck == src)
			src.cards += C.currenthand
			user.remove_from_mob(C)
			user.visible_message("<span class='notice'>[user] puts their hand of cards in the deck.</span>", "<span class='notice'>You put the hand of cards in the deck.</span>")
			qdel(C)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")
		if(cards.len > 26)
			src.icon_state = "deck_full"
		else if(cards.len > 10)
			src.icon_state = "deck_half"
		else if(cards.len > 1)
			src.icon_state = "deck_low"

/obj/item/toy/cards/MouseDrop(atom/over_object)
	var/mob/M = usr
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	if(Adjacent(usr))
		if(over_object == M)
			M.put_in_hands(src)
			to_chat(usr, "<span class='notice'>You pick up the deck.</span>")

		else if(istype(over_object, /obj/screen))
			switch(over_object.name)
				if("r_hand")
					M.u_equip(src)
					M.put_in_r_hand(src)
					to_chat(usr, "<span class='notice'>You pick up the deck.</span>")
				if("l_hand")
					M.u_equip(src)
					M.put_in_l_hand(src)
					to_chat(usr, "<span class='notice'>You pick up the deck.</span>")
	else
		to_chat(usr, "<span class='notice'>You can't reach it from here.</span>")



/obj/item/toy/cardhand
	name = "hand of cards"
	desc = "A number of cards not in a deck, customarily held in ones hand."
	icon = 'icons/obj/cards.dmi'
	icon_state = "hand2"
	w_class = 1.0
	var/list/currenthand = list()
	var/obj/item/toy/cards/parentdeck = null
	var/choice = null


/obj/item/toy/cardhand/attack_self(mob/user)
	user.set_machine(src)
	interact(user)

/obj/item/toy/cardhand/interact(mob/user)
	var/dat = "You have:<BR>"
	for(var/t in currenthand)
		dat += "<A href='?src=\ref[src];pick=[t]'>A [t].</A><BR>"
	dat += "Which card will you remove next?"
	var/datum/browser/popup = new(user, "cardhand", "Hand of Cards", 400, 240)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.set_content(dat)
	popup.open()


/obj/item/toy/cardhand/Topic(href, href_list)
	if(..())
		return
	if(usr.stat || !ishuman(usr) || !usr.canmove)
		return
	var/mob/living/carbon/human/cardUser = usr
	if(href_list["pick"])
		if (cardUser.get_item_by_slot(slot_l_hand) == src || cardUser.get_item_by_slot(slot_r_hand) == src)
			var/choice = href_list["pick"]
			var/obj/item/toy/singlecard/C = new/obj/item/toy/singlecard(cardUser.loc)
			src.currenthand -= choice
			C.parentdeck = src.parentdeck
			C.cardname = choice
			C.pickup(cardUser)
			cardUser.put_in_any_hand_if_possible(C)
			cardUser.visible_message("<span class='notice'>[cardUser] draws a card from \his hand.</span>", "<span class='notice'>You take the [C.cardname] from your hand.</span>")

			interact(cardUser)

			if(src.currenthand.len < 3)
				src.icon_state = "hand2"
			else if(src.currenthand.len < 4)
				src.icon_state = "hand3"
			else if(src.currenthand.len < 5)
				src.icon_state = "hand4"

			if(src.currenthand.len == 1)
				var/obj/item/toy/singlecard/N = new/obj/item/toy/singlecard(src.loc)
				N.parentdeck = src.parentdeck
				N.cardname = src.currenthand[1]
				cardUser.remove_from_mob(src)
				N.pickup(cardUser)
				cardUser.put_in_any_hand_if_possible(N)
				to_chat(cardUser, "<span class='notice'>You also take [currenthand[1]] and hold it.</span>")
				cardUser << browse(null, "window=cardhand")
				qdel(src)
		return

/obj/item/toy/cardhand/attackby(obj/item/toy/singlecard/C, mob/living/user)
	if(istype(C))
		if(C.parentdeck == src.parentdeck)
			src.currenthand += C.cardname
			user.remove_from_mob(C)
			user.visible_message("<span class='notice'>[user] adds a card to their hand.</span>", "<span class='notice'>You add the [C.cardname] to your hand.</span>")
			interact(user)
			if(currenthand.len > 4)
				src.icon_state = "hand5"
			else if(currenthand.len > 3)
				src.icon_state = "hand4"
			else if(currenthand.len > 2)
				src.icon_state = "hand3"
			qdel(C)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")





/obj/item/toy/singlecard
	name = "card"
	desc = "A card."
	icon = 'icons/obj/cards.dmi'
	icon_state = "singlecard_down"
	w_class = 1.0
	var/cardname = null
	var/obj/item/toy/cards/parentdeck = null
	var/flipped = 0
	pixel_x = -5

/obj/item/toy/singlecard/examine(mob/user)
	..()
	if(src in user && ishuman(user))
		var/mob/living/carbon/human/cardUser = user
		if(cardUser.get_item_by_slot(slot_l_hand) == src || cardUser.get_item_by_slot(slot_r_hand) == src)
			cardUser.visible_message("<span class='notice'>[cardUser] checks \his card.</span>", "<span class='notice'>The card reads: [src.cardname]</span>")
		else
			to_chat(cardUser, "<span class='notice'>You need to have the card in your hand to check it.</span>")


/obj/item/toy/singlecard/verb/Flip()
	set name = "Flip Card"
	set category = "Object"
	set src in range(1)
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	if(!flipped)
		src.flipped = 1
		if (cardname)
			src.icon_state = "sc_[cardname]"
			src.name = src.cardname
		else
			src.icon_state = "sc_Ace of Spades"
			src.name = "What Card"
		src.pixel_x = 5
	else if(flipped)
		src.flipped = 0
		src.icon_state = "singlecard_down"
		src.name = "card"
		src.pixel_x = -5

/obj/item/toy/singlecard/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/toy/singlecard/))
		var/obj/item/toy/singlecard/C = I
		if(C.parentdeck == src.parentdeck)
			var/obj/item/toy/cardhand/H = new/obj/item/toy/cardhand(user.loc)
			H.currenthand += C.cardname
			H.currenthand += src.cardname
			H.parentdeck = C.parentdeck
			user.remove_from_mob(C)
			H.pickup(user)
			user.put_in_active_hand(H)
			to_chat(user, "<span class='notice'>You combine the [C.cardname] and the [src.cardname] into a hand.</span>")
			qdel(C)
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")

	if(istype(I, /obj/item/toy/cardhand/))
		var/obj/item/toy/cardhand/H = I
		if(H.parentdeck == parentdeck)
			H.currenthand += cardname
			user.remove_from_mob(src)
			user.visible_message("<span class='notice'>[user] adds a card to \his hand.</span>", "<span class='notice'>You add the [cardname] to your hand.</span>")
			H.interact(user)
			if(H.currenthand.len > 4)
				H.icon_state = "hand5"
			else if(H.currenthand.len > 3)
				H.icon_state = "hand4"
			else if(H.currenthand.len > 2)
				H.icon_state = "hand3"
			qdel(src)
		else
			to_chat(user, "<span class='notice'>You can't mix cards from other decks.</span>")


/obj/item/toy/singlecard/attack_self(mob/user)
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	Flip()


/*
 * Poly prizes
 */
/obj/item/toy/prize/poly
	icon_state = "poly_classic"

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/poly/attack_self(mob/user)
	if(cooldown < world.time - 8)
		to_chat(user, "<span class='notice'>You play with [src].</span>")
		cooldown = world.time

/obj/item/toy/prize/poly/attack_hand(mob/user)
	if(loc == user)
		if(cooldown < world.time - 8)
			to_chat(user, "<span class='notice'>You play with [src].</span>")
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

	attack_self(mob/user)
		to_chat(user, "\blue You have clicked a switch behind the toy.")
		src.icon_state = "poly_companion" + pick("1","2","")

		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			H.update_inv_l_hand()
			H.update_inv_r_hand()

/obj/item/toy/prize/poly/polygold
	name = "golden Poly"
	desc = "Mini-Borg action figure! Limited edition! 11/11. Fully from gold and platinum."
	icon_state = "poly_gold"

/obj/item/toy/prize/poly/polyspecial
	name = "toy special Poly"
	desc = "Mini-Borg action figure! Limited edition! 11/11. Fully from gold and platinum."
	icon_state = "poly_special"

	attack_self(mob/user)
		to_chat(user, "\blue You have clicked a switch behind the toy.")
		src.icon_state = "poly_special" + pick("1","2","")
		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			H.update_inv_l_hand()
			H.update_inv_r_hand()
