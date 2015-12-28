/obj/item/weapon/present
	name = "gift"
	desc = "Holiday gift. What's in the box?"
	icon = 'tauceti/modules/_holidays/new_year/presents.dmi'
	icon_state = "gift1"

	var/bad_chance = 5
	var/list/gifts = list(/obj/item/weapon/reagent_containers/food/snacks/cookie	  = 3,
						/obj/item/weapon/reagent_containers/food/snacks/chocolatebar  = 3,
						/obj/item/clothing/head/santahat				= 3,
						/obj/item/weapon/contraband/poster				= 2,
						/obj/item/weapon/storage/box/snappops			= 2,
						/obj/item/clothing/tie/holster/waist			= 2,
						/obj/item/clothing/tie/medal/gold				= 2,
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
						/obj/item/toy/prize/poly/polyspecial			= 1
						)

/obj/item/weapon/present/New()
	icon_state = "gift[rand(1,9)]"
	pixel_x = rand(-6,6)
	pixel_y = rand(-6,6)

/obj/item/weapon/present/attack_self(mob/user, var/key as text)
	var/p_warns
	var/giftselect = pickweight(gifts)

	if(user.client.prefs.warnbans)
		p_warns = user.client.prefs.warnbans
		bad_chance = p_warns * 20	//5 warnbans = 100% bad chance

	user.drop_item()
	user.visible_message("<span class='notice'>[user] carefully open [src].</span>","<span class='notice'>You carefully open [src].</span>")
	playsound(src, 'tauceti/sounds/items/crumple.ogg', 40, 1, 1)

	if(bad_chance > 100)
		new /obj/item/weapon/ore/coal/special(src.loc)
		new /obj/item/weapon/ore/coal/special(src.loc)
		new /obj/item/weapon/ore/coal/special(src.loc)
		qdel(src)
		return

	if(prob(bad_chance))
		new /obj/item/weapon/ore/coal/special(src.loc)
	else
		var/present = new giftselect(src.loc)
		user.put_in_active_hand(present)
	qdel(src)

/obj/item/weapon/ore/coal/special
	name = "coal"
	desc = "You've been a bad boy this year."

