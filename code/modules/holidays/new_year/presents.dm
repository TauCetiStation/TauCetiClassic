/obj/item/weapon/present
	name = "gift"
	desc = "Holiday gift. What's in the box?"
	icon = 'code/modules/holidays/new_year/presents.dmi'
	icon_state = "gift1"

	var/bad_chance = 0	//Chance of having bad gift
	var/list/gifts = list(/obj/item/weapon/reagent_containers/food/snacks/cookie	  = 3,
						/obj/item/weapon/reagent_containers/food/snacks/chocolatebar  = 3,
						/obj/item/clothing/head/santahat				= 3,
						/obj/item/weapon/poster/contraband				= 2,
						/obj/item/weapon/poster/legit					= 2,
						/obj/item/weapon/storage/box/snappops			= 2,
						/obj/item/clothing/accessory/holster/waist		= 2,
						/obj/item/clothing/accessory/medal/gold			= 2,
						/obj/item/toy/blink								= 2,
						/obj/item/clothing/under/syndicate/tacticool	= 2,
						/obj/item/toy/sword								= 2,
						/obj/item/toy/gun								= 2,
						/obj/item/toy/crossbow							= 2,
						/obj/item/clothing/suit/syndicatefake			= 2,
						/obj/item/weapon/storage/fancy/crayons			= 2,
						/obj/item/toy/spinningtoy						= 2,
						/obj/item/toy/minimeteor						= 2,
						/obj/item/toy/nuke								= 2,
						/obj/item/toy/carpplushie						= 2,
						/obj/item/toy/owl								= 2,
						/obj/item/toy/griffin							= 2,
						/obj/item/toy/prize/ripley						= 1,
						/obj/item/toy/prize/fireripley					= 1,
						/obj/item/toy/prize/deathripley					= 1,
						/obj/item/toy/prize/gygax						= 1,
						/obj/item/toy/prize/durand						= 1,
						/obj/item/toy/prize/honk						= 1,
						/obj/item/toy/prize/marauder					= 1,
						/obj/item/toy/prize/seraph						= 1,
						/obj/item/toy/prize/mauler						= 1,
						/obj/item/toy/prize/odysseus					= 1,
						/obj/item/toy/prize/phazon						= 1,
						/obj/item/toy/waterflower						= 1,
						/obj/item/toy/figure/cmo						= 1,
						/obj/item/toy/figure/assistant					= 1,
						/obj/item/toy/figure/atmos						= 1,
						/obj/item/toy/figure/bartender					= 1,
						/obj/item/toy/figure/borg						= 1,
						/obj/item/toy/figure/botanist					= 1,
						/obj/item/toy/figure/captain					= 1,
						/obj/item/toy/figure/cargotech					= 1,
						/obj/item/toy/figure/ce							= 1,
						/obj/item/toy/figure/chaplain					= 1,
						/obj/item/toy/figure/chef						= 1,
						/obj/item/toy/figure/chemist					= 1,
						/obj/item/toy/figure/clown						= 1,
						/obj/item/toy/figure/ian						= 1,
						/obj/item/toy/figure/detective					= 1,
						/obj/item/toy/figure/dsquad						= 1,
						/obj/item/toy/figure/engineer					= 1,
						/obj/item/toy/figure/geneticist					= 1,
						/obj/item/toy/figure/hop						= 1,
						/obj/item/toy/figure/hos						= 1,
						/obj/item/toy/figure/qm							= 1,
						/obj/item/toy/figure/janitor					= 1,
						/obj/item/toy/figure/lawyer						= 1,
						/obj/item/toy/figure/librarian					= 1,
						/obj/item/toy/figure/md							= 1,
						/obj/item/toy/figure/mime						= 1,
						/obj/item/toy/figure/ninja						= 1,
						/obj/item/toy/figure/wizard						= 1,
						/obj/item/toy/figure/rd							= 1,
						/obj/item/toy/figure/roboticist					= 1,
						/obj/item/toy/figure/scientist					= 1,
						/obj/item/toy/figure/syndie						= 1,
						/obj/item/toy/figure/secofficer					= 1,
						/obj/item/toy/figure/virologist					= 1,
						/obj/item/toy/figure/warden						= 1,
						/obj/item/toy/prize/poly/polyclassic			= 1,
						/obj/item/toy/prize/poly/polypink				= 1,
						/obj/item/toy/prize/poly/polydark				= 1,
						/obj/item/toy/prize/poly/polywhite				= 1,
						/obj/item/toy/prize/poly/polyalien				= 1,
						/obj/item/toy/prize/poly/polyjungle				= 1,
						/obj/item/toy/prize/poly/polyfury				= 1,
						/obj/item/toy/prize/poly/polysky				= 1,
						/obj/item/toy/prize/poly/polysec				= 1,
						/obj/item/toy/prize/poly/polycompanion			= 1,
						/obj/item/toy/prize/poly/polygold				= 1,
						/obj/item/toy/prize/poly/polyspecial			= 1,
						/obj/item/toy/eight_ball						= 2,
						/obj/item/toy/eight_ball/conch					= 2,
						/obj/item/toy/carpplushie						= 4,
						/obj/random/plushie								= 15
						)

/obj/item/weapon/present/atom_init()
	. = ..()
	icon_state = "gift[rand(1,9)]"
	pixel_x = rand(-6,6)
	pixel_y = rand(-6,6)

/obj/item/weapon/present/attack_self(mob/user, key)
	var/giftselect = pickweight(gifts)	// almost random pick from gift list
	var/present

	// Checks for jobbans and increase chance of bad gift
	for(var/datum/job/job in SSjob.occupations)
		if(jobban_isbanned(user, job.title))
			bad_chance += 5
	user.drop_item()
	user.visible_message("<span class='notice'>[user] carefully open [src].</span>","<span class='notice'>You carefully open [src].</span>")
	playsound(src, 'sound/items/crumple.ogg', 40, 1, 1)

	// For absolutely bad players we have special presents ;D
	if(bad_chance >= 20)
		new /obj/item/weapon/ore/coal/special(src.loc)
		new /obj/item/weapon/ore/coal/special(src.loc)
		new /obj/item/weapon/ore/coal/special(src.loc)
		if(prob(5) && ishuman(user))
			var/mob/living/carbon/human/H = user
			H.visible_message("[user] begins balding.", \
									 "<span class='notice'>You become bald from shame.</span>")
			H.h_style = "Bald"
			H.update_hair()
		qdel(src)
		return

	if(prob(bad_chance))
		present = new /obj/item/weapon/ore/coal/special(src.loc)
	else
		present = new giftselect(src.loc)

	user.put_in_active_hand(present)
	qdel(src)

/obj/item/weapon/present/special
	desc = "Gift wrapping of this is extraordinarily beautiful."

/obj/item/weapon/present/special/attack_self(mob/user, key)
	. = ..()
	// Free whitelist adding. It could be OP, but it's fucking New Year, why not?
	if(!bad_chance)
		if(prob(1))
			whitelist_gift()

/obj/item/weapon/present/proc/whitelist_gift(mob/user = usr)
	var/user_ckey = user.ckey
	var/rand_role
	if(role_whitelist[user_ckey])
		var/list/user_roles = whitelisted_roles - role_whitelist[user_ckey] // exclude anything that user already have.
		if(!user_roles.len)
			return
		rand_role = pick(user_roles)
	else
		rand_role = pick(whitelisted_roles)

	var/reason = "New Year [time2text(world.realtime, "YYYY")] Present."
	if(whitelist_DB_add(user_ckey, rand_role, reason, "yourfriendian", added_by_bot = TRUE))
		to_chat(user, "<span class='notice'>You are so lucky bastard. Congratulations!</span>")

/obj/item/weapon/ore/coal/special
	name = "coal"
	desc = "You've been a bad boy this year."
