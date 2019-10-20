/obj/structure/closet/critter
	name = "critter crate"
	desc = "A crate designed for safe transport of animals. Only openable from the the outside."
	icon_state = "critter"
	icon_opened = "critteropen"
	icon_closed = "critter"
	var/already_opened = 0
	var/content_mob = null

/obj/structure/closet/critter/can_open()
	if(locked || welded)
		return 0
	return 1

/obj/structure/closet/critter/open()
	if(!can_open())
		return 0

	if(content_mob == null) //making sure we don't spawn anything too eldritch
		already_opened = 1
		return ..()
	var/mob/living/to_die
	if(content_mob != null && already_opened == 0)
		if(content_mob == /mob/living/simple_animal/shiba)
			new/obj/item/weapon/bikehorn/dogtoy(src)
		if(content_mob == /mob/living/simple_animal/chick)
			var/num = rand(4, 6)
			for(var/i = 0, i < num, i++)
				to_die = new content_mob(loc)
				to_die.health = to_die.health * (!crit_fail)
		else if(content_mob == /mob/living/simple_animal/corgi)
			var/num = rand(0, 1)
			if(num) //No more matriarchy for cargo
				content_mob = /mob/living/simple_animal/corgi/Lisa
			to_die = new content_mob(loc)
			to_die.health = to_die.health * (!crit_fail)
		else
			to_die = new content_mob(loc)
			to_die.health = to_die.health * (!crit_fail)
		already_opened = 1
	..()

/obj/structure/closet/critter/close()
	..()
	locked = 1
	return 1

/obj/structure/closet/critter/attack_hand(mob/user)
	src.add_fingerprint(user)
	user.SetNextMove(CLICK_CD_RAPID)

	if(src.loc == user.loc)
		to_chat(user, "<span class='notice'>It won't budge!</span>")
		toggle()
	else
		locked = 0
		toggle()

/obj/structure/closet/critter/corgi
	name = "corgi crate"
	content_mob = /mob/living/simple_animal/corgi //This statement is (not) false. See above.

/obj/structure/closet/critter/cow
	name = "cow crate"
	content_mob = /mob/living/simple_animal/cow

/obj/structure/closet/critter/goat
	name = "goat crate"
	content_mob = /mob/living/simple_animal/hostile/retaliate/goat

/obj/structure/closet/critter/chick
	name = "chicken crate"
	content_mob = /mob/living/simple_animal/chick

/obj/structure/closet/critter/cat
	name = "cat crate"
	content_mob = /mob/living/simple_animal/cat

/obj/structure/closet/critter/pug
	name = "pug crate"
	content_mob = /mob/living/simple_animal/pug

/obj/structure/closet/critter/shiba
	name = "shiba crate"
	content_mob = /mob/living/simple_animal/shiba

/obj/structure/closet/critter/pig
	name = "pig crate"
	content_mob = /mob/living/simple_animal/pig

/obj/structure/closet/critter/turkey
	name = "turkey crate"
	content_mob = /mob/living/simple_animal/turkey

/obj/structure/closet/critter/goose
	name = "goose crate"
	content_mob = /mob/living/simple_animal/goose

/obj/structure/closet/critter/seal
	name = "seal crate"
	content_mob = /mob/living/simple_animal/seal

/obj/structure/closet/critter/walrus
	name = "walrus crate"
	content_mob = /mob/living/simple_animal/walrus