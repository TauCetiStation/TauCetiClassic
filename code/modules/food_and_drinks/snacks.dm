
///-----------------------------------------------------//
///														//
///						Snacks							//
///			Food items that you surely can eat.			//
///		For example - raw meat isn't snack. Steak - is.	//
///			Most of the food has this type.				//
///														//
///-----------------------------------------------------//

//Items in the "Snacks" subcategory are food items that people actually eat. The key points are that they are created
//	already filled with reagents and are destroyed when empty. Additionally, they make a "munching" noise when eaten.

//Notes by Darem: Food in the "snacks" subtype can hold a maximum of 50 units Generally speaking, you don't want to go over 40
//	total for the item because you want to leave space for extra condiments. If you want effect besides healing, add a reagent for
//	it. Try to stick to existing reagents when possible (so if you want a stronger healing effect, just use Tricordrazine). On use
//	effect (such as the old officer eating a donut code) requires a unique reagent (unless you can figure out a better way).

//The nutriment reagent and bitesize variable replace the old heal_amt and amount variables. Each unit of nutriment is equal to
//	2 of the old heal_amt variable. Bitesize is the rate at which the reagents are consumed. So if you have 6 nutriment and a
//	bitesize of 2, then it'll take 3 bites to eat. Unlike the old system, the contained reagents are evenly spread among all
//	the bites. No more contained reagents = no more bites.

/obj/item/weapon/reagent_containers/food/snacks
	name = "snack"
	desc = "Yummy!"
	icon = 'icons/obj/food_and_drinks/snacks.dmi'
	icon_state = null

	var/trash = null

	var/slice_path

	var/bitesize = 2
	var/bitecount = 0

	var/slices_num

	var/deepfried = 0
//--------------------------------------------------------------------------//
//								Sauced Icon									//
//					Very few items has that									//
	var/sauced_icon = null//= icon with ketchup/hotsauce on it
//																			//
//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
//								Etiquette									//
//				Can we eat it without a spoon or fork or plate				//
//				and at the same time aint look like like pigs?				//
//		If FALSE then we dont care about using fork/spoon(example: an egg)	//
	var/needs_plate = FALSE//FALSE = Can eat this normally without a plate; 1 = cant
	var/cant_be_put_on_plate = FALSE//etc. - soups and salads(for now) cant be put on plate.
	var/needs_spoon = FALSE
	var/needs_fork = FALSE
//																			//
//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
//								Raw Food is BAD								//
//				Eating raw food is a bad idea, to be honest.				//
	var/raw = FALSE
//																			//
//--------------------------------------------------------------------------//
//--------------------------------------------------------------------------//
//								Eatverb										//
//	How do I eat thing ? (Note : Used for message, "bite", "chew", etc...)	//
	var/eatverb
//																			//
//--------------------------------------------------------------------------//

//Placeholder for effect that trigger on eating that aren't tied to reagents.
/obj/item/weapon/reagent_containers/food/snacks/proc/On_Consume(mob/M)
	if(!usr)	return
	if(isliving(M))
		var/mob/living/L = M
		if(raw && prob(70))//raw food is bad for your stomach
			L.adjustToxLoss(rand(1,5))
			to_chat(L, "<span class='rose'>You can hear your belly purring loudly. Perhaps it was not worth eating raw [name]?</span>")
		if(taste)
			L.taste_reagents(reagents)

	if(!reagents.total_volume)
		if(M == usr)
			to_chat(usr, "<span class='notice'>You finish eating \the [src].</span>")
		M.visible_message("<span class='notice'>[M] finishes eating \the [src].</span>")
		score["foodeaten"]++
		usr.drop_from_inventory(src)	//so icons update :[

		if(trash)
			if(ispath(trash,/obj/item))
				var/obj/item/TrashItem = new trash(usr)
				usr.put_in_hands(TrashItem)
			else if(istype(trash,/obj/item))
				usr.put_in_hands(trash)
		qdel(src)
	return

/obj/item/weapon/reagent_containers/food/snacks/attack_self(mob/user)
	return

/obj/item/weapon/reagent_containers/food/snacks/attack(mob/M, mob/user, def_zone)
	if(!eatverb)
		eatverb = pick("bite", "chew", "nibble", "gnaw", "gobble", "chomp")
	if(!reagents || !reagents.total_volume)				//Shouldn't be needed but it checks to see if it has anything left in it.
		to_chat(user, "<span class='rose'>None of [src] left, oh no!</span>")
		M.drop_from_inventory(src)	//so icons update :[
		qdel(src)
		return 0

	if(!CanEat(user, M, src, "eat")) return	//tc code

	if(iscarbon(M))
		var/mob/living/carbon/C = M
		var/fullness = C.get_nutrition()
		if(C == user)								//If you're eating it yourself
			if(ishuman(C))
				var/mob/living/carbon/human/H = M
				if(H.species.flags[IS_SYNTHETIC])
					to_chat(H, "<span class='rose'>You have a monitor for a head, where do you think you're going to put that?</span>")
					return
			if (fullness <= 50)
				C.visible_message("<span class='notice'>[C] hungrily [eatverb]s some of \the [src] and gobbles it down!</span>", \
				"<span class='notice'>You hungrily [eatverb] some of \the [src] and gobble it down!</span>")
			if (fullness > 50 && fullness <= 150)
				C.visible_message("<span class='notice'>[C] hungrily [eatverb]s \the [src].</span>", \
				"<span class='notice'>You hungrily [eatverb] \the [src].</span>")
			if (fullness > 150 && fullness <= 350)
				C.visible_message("<span class='notice'>[C] [eatverb]s \the [src].</span>", \
				"<span class='notice'>You [eatverb] \the [src].</span>")
			if (fullness > 350 && fullness <= 550)
				C.visible_message("<span class='notice'>[C] unwillingly [eatverb]s some of \the [src].</span>", \
				"<span class='notice'>You unwillingly [eatverb] some of \the [src].</span>")
			if (fullness > (550 * (1 + M.overeatduration / 2000)))	// The more you eat - the more you can eat
				to_chat(M, "<span class='rose'>You cannot force any more of [src] to go down your throat.</span>")
				return 0
		else
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.species.flags[IS_SYNTHETIC])
					to_chat(H, "<span class='rose'>They have a monitor for a head, where do you think you're going to put that?</span>")
					return

			if(!istype(M, /mob/living/carbon/slime))		//If you're feeding it to someone else.

				if (fullness <= (550 * (1 + M.overeatduration / 1000)))
					for(var/mob/O in viewers(world.view, user))
						O.show_message("<span class='rose'>[user] attempts to feed [M] [src].</span>", 1)
				else
					for(var/mob/O in viewers(world.view, user))
						O.show_message("<span class='rose'>[user] cannot force anymore of [src] down [M]'s throat.</span>", 1)
						return 0

				if(!do_mob(user, M)) return

				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagentlist(src)]</font>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [src.name] by [M.name] ([M.ckey]) Reagents: [reagentlist(src)]</font>")
				msg_admin_attack("[key_name(user)] fed [key_name(M)] with [src.name] Reagents: [reagentlist(src)] (INTENT: [uppertext(user.a_intent)])")

				for(var/mob/O in viewers(world.view, user))
					O.show_message("<span class='rose'>[user] feeds [M] [src].</span>", 1)

			else
				to_chat(user, "This creature does not seem to have a mouth!</span>")
				return


		if(reagents)								//Handle ingestion of the reagent.
			playsound(M.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
			if(needs_plate)
				if(!(trash == /obj/item/weapon/kitchen/dirty_plate))
					M.visible_message("<span class='rose'>[M] [eatverb]s [src] without using plate. How indecent!</span>", \
				"<span class='rose'>Why are you [eatverb]ing [src] without using plate? How indecent!</span>")
			if(reagents.total_volume)
				if(reagents.total_volume > bitesize)
					/*
					 * I totally cannot understand what this code supposed to do.
					 * Right now every snack consumes in 2 bites, my popcorn does not work right, so I simplify it. -- rastaf0
					var/temp_bitesize =  max(reagents.total_volume /2, bitesize)
					reagents.trans_to(M, temp_bitesize)
					*/
					reagents.trans_to_ingest(M, bitesize)
				else
					reagents.trans_to_ingest(M, reagents.total_volume)
				bitecount++
				On_Consume(M)
			return 1

	return 0

/obj/item/weapon/reagent_containers/food/snacks/afterattack(obj/target, mob/user, proximity)
	return

/obj/item/weapon/reagent_containers/food/snacks/examine(mob/user)
	..()
	if(src in user)
		if (bitecount == 0)
			return
		else if (bitecount == 1)
			to_chat(user, "<span class='info'>\The [src] was bitten by someone!</span>")
		else if (bitecount <= 3)
			to_chat(user, "<span class='info'>\The [src] was bitten [bitecount] times!</span>")
		else
			to_chat(user, "<span class='info'>\The [src] was bitten multiple times!</span>")

/obj/item/weapon/reagent_containers/food/snacks/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/storage))
		..() // -> item/attackby()
	if(istype(W,/obj/item/weapon/kitchen/utensil))

		var/obj/item/weapon/kitchen/utensil/U = W

		if(U.contents.len >= U.max_contents)
			to_chat(user, "<span class='warning'>You cannot fit anything else on your [U].")
			return

		user.visible_message( \
			"[user] scoops up some [src] with \the [U]!", \
			"<span class='notice'>You scoop up some [src] with \the [U]!" \
		)

		bitecount++
		U.overlays.Cut()
		if(istype(W,/obj/item/weapon/kitchen/utensil/woodenspoon))
			var/image/I = new(U.icon, "loadedfood_woodenspoon")
		else
			var/image/I = new(U.icon, "loadedfood")
		I.color = filling_color
		U.overlays += I

		var/obj/item/weapon/reagent_containers/food/snacks/collected = new type
		collected.loc = U
		collected.reagents.remove_any(collected.reagents.total_volume)
		collected.trash = null
		if(reagents.total_volume > bitesize)
			reagents.trans_to(collected, bitesize)
		else
			reagents.trans_to(collected, reagents.total_volume)
			if(trash)
				var/obj/item/TrashItem
				if(ispath(trash,/obj/item))
					TrashItem = new trash(src)
				else if(istype(trash,/obj/item))
					TrashItem = trash
				TrashItem.forceMove(loc)
			qdel(src)
		return 1
	if((slices_num <= 0 || !slices_num) || !slice_path)
		return 0
	var/inaccurate = 0
	if( \
			istype(W, /obj/item/weapon/kitchenknife) || \
			istype(W, /obj/item/weapon/butch) || \
			istype(W, /obj/item/weapon/scalpel) \
		)
	else if( \
			istype(W, /obj/item/weapon/circular_saw) || \
			istype(W, /obj/item/weapon/melee/energy/sword) && W:active || \
			istype(W, /obj/item/weapon/melee/energy/blade) || \
			istype(W, /obj/item/weapon/shovel) || \
			istype(W, /obj/item/weapon/hatchet) || \
			istype(W, /obj/item/weapon/shard) \
		)
		inaccurate = 1
	else if(W.w_class <= 2 && istype(src,/obj/item/weapon/reagent_containers/food/snacks/sliceable))
		if(!iscarbon(user))
			return 1
		to_chat(user, "<span class='rose'>You slip [W] inside [src].</span>")
		user.remove_from_mob(W)
		add_fingerprint(user)
		contents += W
		return
	else
		return 1
	if ( \
			!isturf(src.loc) || \
			!(locate(/obj/structure/table) in src.loc) && \
			!(locate(/obj/machinery/optable) in src.loc) && \
			!(locate(/obj/item/weapon/tray) in src.loc) \
		)
		to_chat(user, "<span class='rose'>You cannot slice [src] here! You need a table or at least a tray to do it.</span>")
		return 1
	var/slices_lost = 0
	if (!inaccurate)
		user.visible_message( \
			"<span class='info'>[user] slices \the [src]!</span>", \
			"<span class='notice'>You slice \the [src]!</span>" \
		)
	else
		user.visible_message( \
			"<span class='info'>[user] inaccurately slices \the [src] with [W]!</span>", \
			"<span class='notice'>You inaccurately slice \the [src] with your [W]!</span>" \
		)
		slices_lost = rand(1,min(1,round(slices_num/2)))
	var/reagents_per_slice = reagents.total_volume/slices_num
	for(var/i=1 to (slices_num-slices_lost))
		var/obj/slice = new slice_path (src.loc)
		reagents.trans_to(slice,reagents_per_slice)
	qdel(src)
	return

/obj/item/weapon/reagent_containers/food/snacks/Destroy()
	if(contents)
		for(var/atom/movable/something in contents)
			something.loc = get_turf(src)
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/attack_animal(mob/M)
	..()
	if(iscorgi(M) || isIAN(M))
		if(bitecount == 0 || prob(50))
			M.visible_message("<b>[M]</b> nibbles away at the [src]")
		bitecount++
		if(bitecount >= 5)
			var/sattisfaction_text = pick("burps from enjoyment", "yaps for more", "woofs twice", "looks at the area where the [src] was")
			M.visible_message("<b>[M]</b> [sattisfaction_text]")
			qdel(src)
	if(ismouse(M))
		var/mob/living/simple_animal/mouse/N = M
		to_chat(N, text("<span class='notice'>You nibble away at [src].</span>"))
		if(prob(50))
			N.visible_message("<b>[N]</b> nibbles away at [src].", "")
		N.health = min(N.health + 1, N.maxHealth)

//////////////////////////////////////////////////////////////////////////////
//								SNACKS LIST									//
//////////////////////////////////////////////////////////////////////////////
//Here is an example of the new formatting for anyone who wants to add more food items:
//
///obj/item/weapon/reagent_containers/food/snacks/candy_corn		//Identification path for the object.
//	name = "candy corn"												//Name that displays in the UI.
//	desc = "It's a handful of candy corn."							//Desc
//	icon_state = "candy_corn"										//Refers to an icon in icons/obj/food_ad_drinks/snacks.dmi
//	filling_color = "#FFFCB0"										//Color of this snack inside a sandwich
//	bitesize = 2													//This is the amount each bite consumes.
//
//	/obj/item/weapon/reagent_containers/food/snacks/candy_corn/atom_init()	//Atom_init() proc - when snack is created
//	. = ..()																//No comments
//	reagents.add_reagent("nutriment", 4)									//So here we add the reagents inside the snack that we need
//	reagents.add_reagent("sugar", 2)										//Same/
//////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Cannot be stored in a detective's hat, alas."
	icon_state = "candy_corn"
	filling_color = "#FFFCB0"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy_corn/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("sugar", 2)

/obj/item/weapon/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips"
	trash = /obj/item/trash/chips
	filling_color = "#E8C31E"
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/chips/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("sugar", 1)

/obj/item/weapon/reagent_containers/food/snacks/cookie
	name = "cookie"
	desc = "COOKIE!!!"
	icon_state = "COOKIE!!!"
	filling_color = "#DBC94F"
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/cookie/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
	name = "Chocolate Bar"
	desc = "Such sweet, fattening food."
	icon_state = "chocolatebar"
	filling_color = "#7D5F46"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("sugar", 2)
	reagents.add_reagent("coco", 2)

/obj/item/weapon/reagent_containers/food/snacks/chocolateegg
	name = "Chocolate Egg"
	desc = "Such sweet, fattening food."
	icon_state = "chocolateegg"
	filling_color = "#7D5F46"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chocolateegg/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("sugar", 2)
	reagents.add_reagent("coco", 2)
	reagents.add_reagent("egg", 5)

/obj/item/weapon/reagent_containers/food/snacks/donut
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	filling_color = "#D9C386"

/obj/item/weapon/reagent_containers/food/snacks/donut/normal
	name = "donut"
	desc = "Goes great with Robust Coffee."
	icon_state = "donut1"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/donut/normal/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sprinkles", 1)
	if(prob(30))
		icon_state = "donut2"
		name = "frosted donut"
		reagents.add_reagent("sprinkles", 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/chaos
	name = "Chaos Donut"
	desc = "Like life, it never quite tastes the same."
	icon_state = "donut1"
	filling_color = "#ED11E6"
	bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/donut/chaos/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("sprinkles", 1)
	var/chaosselect = pick(1,2,3,4,5,6,7,8,9,10)
	switch(chaosselect)
		if(1)
			reagents.add_reagent("nutriment", 3)
		if(2)
			reagents.add_reagent("capsaicin", 3)
		if(3)
			reagents.add_reagent("frostoil", 3)
		if(4)
			reagents.add_reagent("sprinkles", 3)
		if(5)
			reagents.add_reagent("phoron", 3)
		if(6)
			reagents.add_reagent("coco", 3)
		if(7)
			reagents.add_reagent("slimejelly", 3)
		if(8)
			reagents.add_reagent("banana", 3)
		if(9)
			reagents.add_reagent("berryjuice", 3)
		if(10)
			reagents.add_reagent("tricordrazine", 3)
	if(prob(30))
		src.icon_state = "donut2"
		src.name = "Frosted Chaos Donut"
		reagents.add_reagent("sprinkles", 2)


/obj/item/weapon/reagent_containers/food/snacks/donut/jelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ED1169"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/donut/jelly/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sprinkles", 1)
	reagents.add_reagent("berryjuice", 5)
	if(prob(30))
		src.icon_state = "jdonut2"
		src.name = "Frosted Jelly Donut"
		reagents.add_reagent("sprinkles", 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/slimejelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ED1169"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/donut/slimejelly/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sprinkles", 1)
	reagents.add_reagent("slimejelly", 5)
	if(prob(30))
		src.icon_state = "jdonut2"
		src.name = "Frosted Jelly Donut"
		reagents.add_reagent("sprinkles", 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ED1169"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sprinkles", 1)
	reagents.add_reagent("cherryjelly", 5)
	if(prob(30))
		src.icon_state = "jdonut2"
		src.name = "Frosted Jelly Donut"
		reagents.add_reagent("sprinkles", 2)

/obj/item/weapon/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"
	filling_color = "#FDFFD1"

/obj/item/weapon/reagent_containers/food/snacks/egg/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("egg", 5)

/obj/item/weapon/reagent_containers/food/snacks/egg/throw_impact(atom/hit_atom)
	..()
	new /obj/effect/decal/cleanable/egg_smudge(loc)
	reagents.reaction(hit_atom, TOUCH)
	visible_message("<span class='rose'>\The [src.name] has been squashed.</span>", "<span class='rose'>You hear a smack.</span>")
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/egg/attackby(obj/item/weapon/W, mob/user)
	if(istype( W, /obj/item/toy/crayon ))
		var/obj/item/toy/crayon/C = W
		var/clr = C.colourName

		if(!(clr in list("blue","green","mime","orange","purple","rainbow","red","yellow")))
			to_chat(usr, "<span class='info'>The egg refuses to take on this color!</span>")
			return

		to_chat(usr, "<span class='notice'>You color \the [src] [clr].</span>")
		icon_state = "egg-[clr]"
		item_color = clr
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/egg/blue
	icon_state = "egg-blue"
	item_color = "blue"

/obj/item/weapon/reagent_containers/food/snacks/egg/green
	icon_state = "egg-green"
	item_color = "green"

/obj/item/weapon/reagent_containers/food/snacks/egg/mime
	icon_state = "egg-mime"
	item_color = "mime"

/obj/item/weapon/reagent_containers/food/snacks/egg/orange
	icon_state = "egg-orange"
	item_color = "orange"

/obj/item/weapon/reagent_containers/food/snacks/egg/purple
	icon_state = "egg-purple"
	item_color = "purple"

/obj/item/weapon/reagent_containers/food/snacks/egg/rainbow
	icon_state = "egg-rainbow"
	item_color = "rainbow"

/obj/item/weapon/reagent_containers/food/snacks/egg/red
	icon_state = "egg-red"
	item_color = "red"

/obj/item/weapon/reagent_containers/food/snacks/egg/yellow
	icon_state = "egg-yellow"
	item_color = "yellow"

/obj/item/weapon/reagent_containers/food/snacks/friedegg
	name = "Fried egg"
	desc = "A fried egg, with a touch of salt and pepper."
	icon_state = "friedegg"
	filling_color = "#FFDF78"
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/friedegg/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("blackpepper", 1)
	reagents.add_reagent("egg", 5)

/obj/item/weapon/reagent_containers/food/snacks/boiledegg
	name = "Boiled egg"
	desc = "A hard boiled egg."
	icon_state = "egg"
	filling_color = "#FFFFFF"

/obj/item/weapon/reagent_containers/food/snacks/boiledegg/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("vitamin", 1)
	reagents.add_reagent("egg", 5)

/obj/item/weapon/reagent_containers/food/snacks/flour
	name = "flour"
	desc = "A small bag filled with some flour."
	icon_state = "flour"

/obj/item/weapon/reagent_containers/food/snacks/flour/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)

/obj/item/weapon/reagent_containers/food/snacks/appendix
//yes, this is the same as meat. I might do something different in future
	name = "appendix"
	desc = "An appendix which looks perfectly healthy."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "appendix"
	filling_color = "#E00D34"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/appendix/atom_init()
	. = ..()
	reagents.add_reagent("protein", 3)
	reagents.add_reagent("vitamin", 2)


/obj/item/weapon/reagent_containers/food/snacks/appendix/inflamed
	name = "inflamed appendix"
	desc = "An appendix which appears to be inflamed."
	icon_state = "appendixinflamed"
	filling_color = "#E00D7A"

/obj/item/weapon/reagent_containers/food/snacks/tofu
	name = "Tofu"
	icon_state = "tofu"
	desc = "We all love tofu."
	filling_color = "#FFFEE0"
	bitesize = 3


/obj/item/weapon/reagent_containers/food/snacks/tofu/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 3)

/obj/item/weapon/reagent_containers/food/snacks/tofurkey
	name = "Tofurkey"
	desc = "A fake turkey made from tofu."
	icon_state = "tofurkey"
	filling_color = "#FFFEE0"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/tofurkey/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 12)
	reagents.add_reagent("stoxin", 3)

/obj/item/weapon/reagent_containers/food/snacks/stuffing
	name = "Stuffing"
	desc = "Moist, peppery breadcrumbs for filling the body cavities of dead birds. Dig in!"
	icon_state = "stuffing"
	filling_color = "#C9AC83"
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/stuffing/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)

/obj/item/weapon/reagent_containers/food/snacks/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat"
	icon_state = "fishfillet"
	filling_color = "#FFDEFE"
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/carpmeat/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("carpotoxin", 3)

/obj/item/weapon/reagent_containers/food/snacks/fishfingers
	name = "Fish Fingers"
	desc = "A finger of fish."
	icon_state = "fishfingers"
	filling_color = "#FFDEFE"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fishfingers/atom_init()
	. = ..()
	reagents.add_reagent("protein", 4)
	reagents.add_reagent("carpotoxin", 3)

/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"
	filling_color = "#E0D7C5"
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 3)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato"
	icon_state = "tomatomeat"
	filling_color = "#DB0000"
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/tomatomeat/atom_init()
	. = ..()
	reagents.add_reagent("protein", 2)

/obj/item/weapon/reagent_containers/food/snacks/bearmeat
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	filling_color = "#DB0000"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/bearmeat/atom_init()
	. = ..()
	reagents.add_reagent("protein", 12)
	reagents.add_reagent("hyperzine", 5)
	reagents.add_reagent("vitamin", 2)

/obj/item/weapon/reagent_containers/food/snacks/xenomeat
	name = "meat"
	desc = "A slab of meat."
	icon_state = "xenomeat"
	filling_color = "#43DE18"
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/xenomeat/atom_init()
	. = ..()
	reagents.add_reagent("protein", 3)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/spidermeat
	name = "spider meat"
	desc = "A slab of spider meat."
	icon_state = "spidermeat"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spidermeat/atom_init()
	. = ..()
	reagents.add_reagent("protein", 3)
	reagents.add_reagent("toxin", 2)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/spiderleg
	name = "spider leg"
	desc = "A still twitching leg of a giant spider... you don't really want to eat this, do you?"
	icon_state = "spiderleg"

/obj/item/weapon/reagent_containers/food/snacks/spiderleg/atom_init()
	. = ..()
	reagents.add_reagent("protein", 2)
	reagents.add_reagent("toxin", 2)

/obj/item/weapon/reagent_containers/food/snacks/sausage
	name = "Sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	filling_color = "#DB0000"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sausage/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	name = "Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	filling_color = "#DEDEAB"
	var/warm = 0

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 4)

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/proc/cooltime() //Not working, derp?
	if (src.warm)
		spawn( 4200 )
			src.warm = 0
			src.reagents.del_reagent("tricordrazine")
			src.name = "donk-pocket"
	return

/obj/item/weapon/reagent_containers/food/snacks/omelette
	name = "Omelette Du Fromage"
	desc = "That's all you can say!"
	icon_state = "omelette"
	sauced_icon = "sauced_omelette"
	trash = /obj/item/trash/plate
	filling_color = "#FFF9A8"
	bitesize = 1

	//var/herp = 0
/obj/item/weapon/reagent_containers/food/snacks/omelette/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/muffin
	name = "Muffin"
	desc = "A delicious and spongy little cake"
	icon_state = "muffin"
	filling_color = "#E0CF9B"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/muffin/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)

/obj/item/weapon/reagent_containers/food/snacks/pie
	name = "Banana Cream Pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/plate
	filling_color = "#FBFFB8"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 6)
	reagents.add_reagent("banana",5)
	reagents.add_reagent("vitamin", 2)

/obj/item/weapon/reagent_containers/food/snacks/pie/throw_impact(atom/hit_atom)
	..()
	new/obj/effect/decal/cleanable/pie_smudge(src.loc)
	src.visible_message("<span class='rose'>[src.name] splats.</span>","<span class='rose'>You hear a splat.</span>")
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/berryclafoutis
	name = "Berry Clafoutis"
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	trash = /obj/item/trash/plate
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/berryclafoutis/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 10)
	reagents.add_reagent("berryjuice", 5)

/obj/item/weapon/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles."
	icon_state = "waffles"
	trash = /obj/item/trash/waffles
	filling_color = "#E6DEB5"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/waffles/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/eggplantparm
	name = "Eggplant Parmigiana"
	desc = "The only good recipe for eggplant."
	icon_state = "eggplantparm"
	trash = /obj/item/trash/plate
	filling_color = "#4D2F5E"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/eggplantparm/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("vitamin", 2)

/obj/item/weapon/reagent_containers/food/snacks/soylentgreen
	name = "Soylent Green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles
	filling_color = "#B8E6B5"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soylentgreen/atom_init()
	. = ..()
	reagents.add_reagent("protein", 10)
	reagents.add_reagent("vitamin", 2)

/obj/item/weapon/reagent_containers/food/snacks/soylenviridians
	name = "Soylen Virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles
	filling_color = "#E6FA61"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soylenviridians/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 10)
	reagents.add_reagent("vitamin", 1)


/obj/item/weapon/reagent_containers/food/snacks/meatpie
	name = "Meat-pie"
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	trash = /obj/item/trash/plate
	filling_color = "#948051"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatpie/atom_init()
	. = ..()
	reagents.add_reagent("protein", 10)
	reagents.add_reagent("vitamin", 2)

/obj/item/weapon/reagent_containers/food/snacks/tofupie
	name = "Tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	trash = /obj/item/trash/plate
	filling_color = "#FFFEE0"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofupie/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 10)
	reagents.add_reagent("vitamin", 2)

/obj/item/weapon/reagent_containers/food/snacks/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	filling_color = "#FFCCCC"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/amanita_pie/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 5)
	reagents.add_reagent("amatoxin", 3)
	reagents.add_reagent("psilocybin", 1)
	reagents.add_reagent("vitamin", 4)

/obj/item/weapon/reagent_containers/food/snacks/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	filling_color = "#B8279B"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/plump_pie/atom_init()
	. = ..()
	if(prob(10))
		name = "exceptional plump pie"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump pie!"
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("tricordrazine", 5)
		reagents.add_reagent("vitamin", 2)
	else
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("vitamin", 2)

/obj/item/weapon/reagent_containers/food/snacks/xemeatpie
	name = "Xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	trash = /obj/item/trash/plate
	filling_color = "#43DE18"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/xemeatpie/atom_init()
	. = ..()
	reagents.add_reagent("protein", 10)
	reagents.add_reagent("vitamin", 2)

/obj/item/weapon/reagent_containers/food/snacks/kabob/human
	name = "-kabob"
	icon_state = "kabob"
	desc = "A human meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/human/kabob/atom_init()
	. = ..()
	reagents.add_reagent("protein", 8)

/obj/item/weapon/reagent_containers/food/snacks/monkeykabob
	name = "Meat-kabob"
	icon_state = "kabob"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#A85340"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/monkeykabob/atom_init()
	. = ..()
	reagents.add_reagent("protein", 8)

/obj/item/weapon/reagent_containers/food/snacks/tofukabob
	name = "Tofu-kabob"
	icon_state = "kabob"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#FFFEE0"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofukabob/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 8)

/obj/item/weapon/reagent_containers/food/snacks/cubancarp
	name = "Cuban Carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate
	filling_color = "#E9ADFF"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/cubancarp/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)
	reagents.add_reagent("carpotoxin", 3)
	reagents.add_reagent("capsaicin", 3)

/obj/item/weapon/reagent_containers/food/snacks/popcorn
	name = "Popcorn"
	desc = "Now let's find some cinema."
	icon_state = "popcorn"
	trash = /obj/item/trash/popcorn
	var/unpopped = 0
	filling_color = "#FFFAD4"
	bitesize = 0.1 //this snack is supposed to be eating during looooong time. And this it not dinner food! --rastaf0

/obj/item/weapon/reagent_containers/food/snacks/popcorn/atom_init()
	. = ..()
	unpopped = rand(1,10)
	reagents.add_reagent("nutriment", 2)

/obj/item/weapon/reagent_containers/food/snacks/popcorn/On_Consume()
	if(prob(unpopped))	//lol ...what's the point?
		to_chat(usr, "<span class='rose'>You bite down on an un-popped kernel!</span>")
		unpopped = max(0, unpopped-1)
	..()


/obj/item/weapon/reagent_containers/food/snacks/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows."
	trash = /obj/item/trash/sosjerky
	filling_color = "#631212"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sosjerky/atom_init()
	. = ..()
	reagents.add_reagent("protein", 1)
	reagents.add_reagent("sugar", 3)

/obj/item/weapon/reagent_containers/food/snacks/no_raisin
	name = "4no Raisins"
	icon_state = "4no_raisins"
	desc = "Best raisins in the universe. Not sure why."
	trash = /obj/item/trash/raisins
	filling_color = "#343834"

/obj/item/weapon/reagent_containers/food/snacks/no_raisin/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 2)
	reagents.add_reagent("sugar", 4)

/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie
	name = "Space Twinkie"
	icon_state = "space_twinkie"
	desc = "Guaranteed to survive longer then you will."
	filling_color = "#FFE591"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 4)

/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers
	name = "Cheesie Honkers"
	icon_state = "cheesie_honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	trash = /obj/item/trash/cheesie
	filling_color = "#FFA305"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("sugar", 3)

/obj/item/weapon/reagent_containers/food/snacks/chinese/chowmein
	name = "chow mein"
	desc = "What is in this anyways?"
	icon_state = "chinese1"

/obj/item/weapon/reagent_containers/food/snacks/chinese/chowmein/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("beans", 3)
	reagents.add_reagent("sugar", 2)

/obj/item/weapon/reagent_containers/food/snacks/chinese/sweetsourchickenball
	name = "Sweet & Sour Chicken Balls"
	desc = "Is this chicken cooked? The odds are better than wok paper scissors."
	icon_state = "chickenball"

/obj/item/weapon/reagent_containers/food/snacks/chinese/sweetsourchickenball/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("sugar", 2)

/obj/item/weapon/reagent_containers/food/snacks/chinese/tao
	name = "Admiral Yamamoto carp"
	desc = "Tastes like chicken."
	icon_state = "chinese2"

/obj/item/weapon/reagent_containers/food/snacks/chinese/tao/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("protein", 1)
	reagents.add_reagent("sugar", 4)

/obj/item/weapon/reagent_containers/food/snacks/chinese/newdles
	name = "chinese newdles"
	desc = "Made fresh, weekly!"
	icon_state = "chinese3"

/obj/item/weapon/reagent_containers/food/snacks/chinese/newdles/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("sugar", 3)

/obj/item/weapon/reagent_containers/food/snacks/chinese/rice
	name = "fried rice"
	desc = "A timeless classic."
	icon_state = "chinese4"

/obj/item/weapon/reagent_containers/food/snacks/chinese/rice/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("sugar", 2)
	reagents.add_reagent("rice", 3)

/obj/item/weapon/reagent_containers/food/snacks/syndicake
	name = "Syndi-Cakes"
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	filling_color = "#FF5D05"
	bitesize = 3

	trash = /obj/item/trash/syndi_cakes

/obj/item/weapon/reagent_containers/food/snacks/syndicake/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("syndicream", 5)

/obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato
	name = "Loaded Baked Potato"
	desc = "Totally baked."
	icon_state = "loadedbakedpotato"
	filling_color = "#9C7A68"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)

/obj/item/weapon/reagent_containers/food/snacks/fries
	name = "Space Fries"
	desc = "AKA: French Fries, Freedom Fries, etc."
	icon_state = "fries"
	trash = /obj/item/trash/plate
	filling_color = "#EDDD00"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fries/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 4)

/obj/item/weapon/reagent_containers/food/snacks/soydope
	name = "Soy Dope"
	desc = "Dope from a soy."
	icon_state = "soydope"
	filling_color = "#C4BF76"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soydope/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries
	name = "Cheesy Fries"
	desc = "Fries. Covered in cheese. Duh."
	icon_state = "cheesyfries"
	trash = /obj/item/trash/plate
	filling_color = "#EDDD00"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)

/obj/item/weapon/reagent_containers/food/snacks/fortunecookie
	name = "Fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"
	filling_color = "#E8E79E"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fortunecookie/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)

/obj/item/weapon/reagent_containers/food/snacks/badrecipe
	name = "Burned mess"
	desc = "Someone should be demoted from chef for this."
	icon_state = "badrecipe"
	filling_color = "#211F02"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/badrecipe/atom_init()
	. = ..()
	reagents.add_reagent("toxin", 1)
	reagents.add_reagent("carbon", 3)

/obj/item/weapon/reagent_containers/food/snacks/meatsteak
	name = "Meat steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatstake"
	trash = /obj/item/trash/plate
	filling_color = "#7A3D11"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meatsteak/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("blackpepper", 1)

/obj/item/weapon/reagent_containers/food/snacks/meatsteak/human
	name = "Human steak"
	desc = "A bloody piece of hot spicy meat."

/obj/item/weapon/reagent_containers/food/snacks/amanitajelly
	name = "Amanita Jelly"
	desc = "Looks curiously toxic."
	icon_state = "amanitajelly"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#ED0758"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/amanitajelly/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 6)
	reagents.add_reagent("amatoxin", 6)
	reagents.add_reagent("psilocybin", 3)

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel
	name = "Poppy pretzel"
	desc = "It's all twisted up!"
	icon_state = "poppypretzel"
	bitesize = 2
	filling_color = "#916E36"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 5)

/* No more of this
/obj/item/weapon/reagent_containers/food/snacks/telebacon
	name = "Tele Bacon"
	desc = "It tastes a little odd but it is still delicious."
	icon_state = "bacon"
	var/obj/item/device/radio/beacon/bacon/baconbeacon
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/telebacon/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 4)
	baconbeacon = new /obj/item/device/radio/beacon/bacon(src)

/obj/item/weapon/reagent_containers/food/snacks/telebacon/On_Consume()
	if(!reagents.total_volume)
		baconbeacon.loc = usr
		baconbeacon.digest_delay()
*/

/obj/item/weapon/reagent_containers/food/snacks/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	icon_state = "monkeycube"
	bitesize = 12
	filling_color = "#ADAC7F"

	var/wrapped = 0
	var/monkey_type = /mob/living/carbon/monkey

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/atom_init()
	. = ..()
	reagents.add_reagent("nutriment",10)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/afterattack(obj/O, mob/user, proximity)
	if(!proximity) return
	if(istype(O,/obj/structure/sink) && !wrapped)
		to_chat(user, "<span class='notice'>You place \the [name] under a stream of water...</span>")
		user.drop_item()
		loc = get_turf(O)
		return Expand()
	..()

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/On_Consume(mob/M)
	to_chat(M, "<span class = 'warning'>Something inside of you suddently expands!</span>")

	if (istype(M, /mob/living/carbon/human))
		//Do not try to understand.
		var/obj/item/weapon/surprise = new/obj/item/weapon(M)
		var/mob/living/carbon/monkey/ook = new monkey_type(null) //no other way to get access to the vars, alas
		surprise.icon = ook.icon
		surprise.icon_state = ook.icon_state
		surprise.name = "malformed [ook.name]"
		surprise.desc = "Looks like \a very deformed [ook.name], a little small for its kind. It shows no signs of life."
		qdel(ook)	//rip nullspace monkey
		surprise.transform *= 0.6
		surprise.add_blood(M)
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_CHEST]
		BP.fracture()
		for (var/obj/item/organ/internal/IO in BP.bodypart_organs)
			IO.take_damage(rand(IO.min_bruised_damage, IO.min_broken_damage + 1))

		if (!BP.hidden && prob(60)) //set it snuggly
			BP.hidden = surprise
			BP.cavity = 0
		else 		//someone is having a bad day
			BP.createwound(CUT, 30)
			BP.embed(surprise)
	else if (ismonkey(M))
		M.visible_message("<span class='danger'>[M] suddenly tears in half!</span>")
		var/mob/living/carbon/monkey/ook = new monkey_type(M.loc)
		ook.name = "malformed [ook.name]"
		ook.transform *= 0.6
		ook.add_blood(M)
		M.gib()
	..()

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/proc/Expand()
	for(var/mob/M in viewers(src,7))
		to_chat(M, "<span class='rose'>\The [src] expands!</span>")
	new monkey_type(src)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/proc/Unwrap(mob/user)
	icon_state = "monkeycube"
	desc = "Just add water!"
	to_chat(user, "You unwrap the cube.")
	wrapped = 0
	return

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped
	desc = "Still wrapped in some paper."
	icon_state = "monkeycubewrap"
	wrapped = 1


/obj/item/weapon/reagent_containers/food/snacks/monkeycube/farwacube
	name = "farwa cube"
	monkey_type = /mob/living/carbon/monkey/tajara

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/farwacube
	name = "farwa cube"
	monkey_type = /mob/living/carbon/monkey/tajara


/obj/item/weapon/reagent_containers/food/snacks/monkeycube/stokcube
	name = "stok cube"
	monkey_type = /mob/living/carbon/monkey/unathi

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/stokcube
	name = "stok cube"
	monkey_type = /mob/living/carbon/monkey/unathi


/obj/item/weapon/reagent_containers/food/snacks/monkeycube/neaeracube
	name = "neaera cube"
	monkey_type = /mob/living/carbon/monkey/skrell

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube
	name = "neaera cube"
	monkey_type = /mob/living/carbon/monkey/skrell

/obj/item/weapon/reagent_containers/food/snacks/enchiladas
	name = "Enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"
	trash = /obj/item/trash/tray
	filling_color = "#A36A1F"
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/enchiladas/atom_init()
	. = ..()
	reagents.add_reagent("protein",8)
	reagents.add_reagent("capsaicin", 6)

/obj/item/weapon/reagent_containers/food/snacks/monkeysdelight
	name = "monkey's Delight"
	desc = "Eeee Eee!"
	icon_state = "monkeysdelight"
	trash = /obj/item/trash/tray
	filling_color = "#5C3C11"
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/monkeysdelight/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("banana", 5)
	reagents.add_reagent("blackpepper", 1)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("vitamin", 5)

/obj/item/weapon/reagent_containers/food/snacks/baguette
	name = "Baguette"
	desc = "Bon appetit!"
	icon_state = "baguette"
	filling_color = "#E3D796"

/obj/item/weapon/reagent_containers/food/snacks/baguette/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("blackpepper", 1)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("vitamin", 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fishandchips
	name = "Fish and Chips"
	desc = "I do say so myself chap."
	icon_state = "fishandchips"
	filling_color = "#E3D796"

/obj/item/weapon/reagent_containers/food/snacks/fishandchips/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)
	reagents.add_reagent("carpotoxin", 3)
	reagents.add_reagent("vitamin", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sashimi
	name = "Carp sashimi"
	desc = "Celebrate surviving attack from hostile alien lifeforms by hospitalising yourself."
	icon_state = "sashimi"

/obj/item/weapon/reagent_containers/food/snacks/sashimi/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)
	reagents.add_reagent("capsaicin", 3)
	reagents.add_reagent("vitamin", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sandwich
	name = "Sandwich"
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon_state = "sandwich"
	trash = /obj/item/trash/plate
	filling_color = "#D9BE29"

/obj/item/weapon/reagent_containers/food/snacks/sandwich/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("vitamin", 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/toastedsandwich
	name = "Toasted Sandwich"
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	filling_color = "#D9BE29"

/obj/item/weapon/reagent_containers/food/snacks/toastedsandwich/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("carbon", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/grilledcheese
	name = "Grilled Cheese Sandwich"
	desc = "Goes great with Tomato soup!"
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	filling_color = "#D9BE29"

/obj/item/weapon/reagent_containers/food/snacks/grilledcheese/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 7)
	reagents.add_reagent("vitamin", 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/rofflewaffles
	name = "Roffle Waffles"
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	filling_color = "#FF00F7"

/obj/item/weapon/reagent_containers/food/snacks/rofflewaffles/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("psilocybin", 8)
	reagents.add_reagent("vitamin", 2)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/stew
	name = "Stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	filling_color = "#9E673A"

/obj/item/weapon/reagent_containers/food/snacks/stew/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("tomatojuice", 5)
	reagents.add_reagent("imidazoline", 5)
	reagents.add_reagent("water", 5)
	reagents.add_reagent("vitamin", 5)
	bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast
	name = "Jellied Toast"
	desc = "A slice of bread covered with delicious jam."
	icon_state = "jellytoast"
	trash = /obj/item/trash/plate
	filling_color = "#B572AB"

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("vitamin", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/cherry

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/cherry/atom_init()
	. = ..()
	reagents.add_reagent("cherryjelly", 5)

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/slime

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/slime/atom_init()
	. = ..()
	reagents.add_reagent("slimejelly", 5)

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat
	name = "Stewed Soy Meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/boiledrice
	name = "Boiled Rice"
	desc = "A boring dish of boring rice."
	icon_state = "boiledrice"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#FFFBDB"

/obj/item/weapon/reagent_containers/food/snacks/boiledrice/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 5)
	reagents.add_reagent("vitamin", 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sushi
	name = "Sushi"
	desc = "This is the Japanese preparation and serving of specially prepared vinegared rice combined with varied ingredients such as chiefly seafood"
	icon_state = "sushi"
	filling_color = "#FFFBDB"

/obj/item/weapon/reagent_containers/food/snacks/sushi/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("vitamin", 2)
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/ricepudding
	name = "Rice Pudding"
	desc = "Where's the Jam!"
	icon_state = "rpudding"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#FFFBDB"

/obj/item/weapon/reagent_containers/food/snacks/ricepudding/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 4)
	reagents.add_reagent("vitamin", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel
	name = "Poppy Pretzel"
	desc = "A large soft pretzel full of POP!"
	icon_state = "poppypretzel"
	filling_color = "#AB7D2E"

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/carrotfries
	name = "Carrot Fries"
	desc = "Tasty fries from fresh Carrots."
	icon_state = "carrotfries"
	trash = /obj/item/trash/plate
	filling_color = "#FAA005"

/obj/item/weapon/reagent_containers/food/snacks/carrotfries/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 3)
	reagents.add_reagent("imidazoline", 3)
	reagents.add_reagent("vitamin", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candiedapple
	name = "Candied Apple"
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"
	filling_color = "#F21873"

/obj/item/weapon/reagent_containers/food/snacks/candiedapple/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sugar", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/applepie
	name = "Apple Pie"
	desc = "A pie containing sweet sweet love... or apple."
	icon_state = "applepie"
	filling_color = "#E0EDC5"

/obj/item/weapon/reagent_containers/food/snacks/applepie/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("vitamin", 2)
	bitesize = 3


/obj/item/weapon/reagent_containers/food/snacks/cherrypie
	name = "Cherry Pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	filling_color = "#FF525A"

/obj/item/weapon/reagent_containers/food/snacks/cherrypie/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("vitamin", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/twobread
	name = "Two Bread"
	desc = "It is very bitter and winy."
	icon_state = "twobread"
	filling_color = "#DBCC9A"

/obj/item/weapon/reagent_containers/food/snacks/twobread/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("vitamin", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich
	name = "Jelly Sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon_state = "jellysandwich"
	trash = /obj/item/trash/plate
	filling_color = "#9E3A78"

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("vitamin", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime/atom_init()
	. = ..()
	reagents.add_reagent("slimejelly", 5)

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry/atom_init()
	. = ..()
	reagents.add_reagent("cherryjelly", 5)

/obj/item/weapon/reagent_containers/food/snacks/boiledslimecore
	name = "Boiled slime Core"
	desc = "A boiled red thing."
	icon_state = "boiledslimecore"
	list_reagents = list("slimejelly" = 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mint
	name = "mint"
	desc = "it is only wafer thin."
	icon_state = "mint"
	filling_color = "#F2F2F2"
	bitesize = 1
	list_reagents = list("minttoxin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"
	filling_color = "#CFB4C4"

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit/atom_init()
	. = ..()
	if(prob(10))
		name = "exceptional plump helmet biscuit"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump helmet biscuit!"
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("tricordrazine", 5)
		bitesize = 2
	else
		reagents.add_reagent("nutriment", 5)
		bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	trash = /obj/item/trash/plate
	filling_color = "#FFFF00"

/obj/item/weapon/reagent_containers/food/snacks/appletart/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 8)
	reagents.add_reagent("gold", 5)
	reagents.add_reagent("vitamin", 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/dionaroast
	name = "roast diona"
	desc = "It's like an enormous, leathery carrot. With an eye."
	icon_state = "dionaroast"
	trash = /obj/item/trash/plate
	filling_color = "#75754B"

/obj/item/weapon/reagent_containers/food/snacks/dionaroast/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 4)
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("radium", 2)
	reagents.add_reagent("vitamin", 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg
	name = "boiled spider leg"
	desc = "A giant spider's leg that's still twitching after being cooked. Gross!"
	icon_state = "spiderlegcooked"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("capsaicin", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spidereggs
	name = "spider eggs"
	desc = "A cluster of juicy spider eggs. A great side dish for when you care not for your health."
	icon_state = "spidereggs"

/obj/item/weapon/reagent_containers/food/snacks/spidereggs/atom_init()
	. = ..()
	reagents.add_reagent("protein", 2)
	reagents.add_reagent("toxin", 2)

/obj/item/weapon/reagent_containers/food/snacks/spidereggsham
	name = "green eggs and ham"
	desc = "Would you eat them on a train? Would you eat them on a plane? Would you eat them on a state of the art corporate deathtrap floating through space?"
	icon_state = "spidereggsham"
	trash = /obj/item/trash/plate


/obj/item/weapon/reagent_containers/food/snacks/spidereggsham/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Unrelated to dogs, maybe."
	icon_state = "hotdog"
	sauced_icon = "sauced_hotdog"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/hotdog/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)

////////////////////////////////FOOD ADDITIONS////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/beans
	name = "tin of beans"
	desc = "Musical fruit in a slightly less musical container."
	icon_state = "beans"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/beans/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("vitamin", 3)
	reagents.add_reagent("beans", 10)

/obj/item/weapon/reagent_containers/food/snacks/wrap
	name = "egg wrap"
	desc = "The precursor to Pigs in a Blanket."
	icon_state = "wrap"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/wrap/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 5)

/obj/item/weapon/reagent_containers/food/snacks/benedict
	name = "eggs benedict"
	desc = "There is only one egg on this, how rude."
	icon_state = "benedict"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/benedict/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("vitamin", 4)
	reagents.add_reagent("egg", 3)

/obj/item/weapon/reagent_containers/food/snacks/meatbun
	name = "meat bun"
	desc = "Has the potential to not be Dog."
	icon_state = "meatbun"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatbun/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)

/obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich
	name = "icecream sandwich"
	desc = "Portable Ice-cream in it's own packaging."
	icon_state = "icecreamsanwich"
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("ice", 2)

/obj/item/weapon/reagent_containers/food/snacks/notasandwich
	name = "not-a-sandwich"
	desc = "Something seems to be wrong with this, you can't quite figure what. Maybe it's his moustache."
	icon_state = "notasandwich"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/notasandwich/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("vitamin", 6)

/obj/item/weapon/reagent_containers/food/snacks/sugarcookie
	name = "sugar cookie"
	desc = "Just like your little sister used to make."
	icon_state = "sugarcookie"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sugarcookie/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sugar", 3)

/obj/item/weapon/reagent_containers/food/snacks/friedbanana
	name = "Fried Banana"
	desc = "Goreng Pisang, also known as fried bananas."
	icon_state = "friedbanana"
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/friedbanana/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 5)
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("cornoil", 4)

/obj/item/weapon/reagent_containers/food/snacks/taco
	name = "taco"
	desc = "Take a bite!"
	icon_state = "taco"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/taco/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 7)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/burrito
	name = "Burrito"
	desc = "Meat, beans, cheese, and rice wrapped up as an easy-to-hold meal."
	icon_state = "burrito"
	trash = /obj/item/trash/plate
	filling_color = "#A36A1F"
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/burrito/atom_init()
	. = ..()
	reagents.add_reagent("protein", 5)

/obj/item/weapon/reagent_containers/food/snacks/bacon
	name = "bacon"
	desc = "It looks juicy and tastes amazing!"
	icon_state = "bacon"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/bacon/atom_init()
	. = ..()
	reagents.add_reagent("protein", 7)

/obj/item/weapon/reagent_containers/food/snacks/telebacon
	name = "Tele Bacon"
	desc = "It tastes a little odd but it is still delicious."
	icon_state = "bacon_tele"
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/telebacon/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)

/obj/item/weapon/reagent_containers/food/snacks/salmonsteak
	name = "Salmon steak"
	desc = "A piece of freshly-grilled salmon meat."
	icon_state = "salmonsteak"
	trash = /obj/item/trash/plate
	filling_color = "#7A3D11"
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/salmonsteak/atom_init()
	. = ..()
	reagents.add_reagent("protein", 4)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("blackpepper", 1)
	reagents.add_reagent("anti_toxin", 5)
