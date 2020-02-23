//Food items that are eaten normally and don't leave anything behind.
/obj/item/weapon/reagent_containers/food/snacks
	name = "snack"
	desc = "Yummy!"
	icon = 'icons/obj/food.dmi'
	icon_state = null
	var/bitesize = 1
	var/bitecount = 0
	var/trash = null
	var/slice_path
	var/slices_num
	var/deepfried = 0

	//Placeholder for effect that trigger on eating that aren't tied to reagents.
/obj/item/weapon/reagent_containers/food/snacks/proc/On_Consume(mob/M)
	if(!usr)	return
	if(isliving(M))
		var/mob/living/L = M
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
				to_chat(C, "<span class='rose'>You hungrily chew out a piece of [src] and gobble it!</span>")
			if (fullness > 50 && fullness <= 150)
				to_chat(C, "<span class='notice'>You hungrily begin to eat [src].</span>")
			if (fullness > 150 && fullness <= 350)
				to_chat(C, "<span class='notice'>You take a bite of [src].</span>")
			if (fullness > 350 && fullness <= 550)
				to_chat(C, "<span class='notice'>You unwillingly chew a bit of [src].</span>")
			if (fullness > (550 * (1 + M.overeatduration / 2000)))	// The more you eat - the more you can eat
				to_chat(C, "<span class='rose'>You cannot force any more of [src] to go down your throat.</span>")
				return 0
		else
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.species.flags[IS_SYNTHETIC])
					to_chat(H, "<span class='rose'>They have a monitor for a head, where do you think you're going to put that?</span>")
					return

			if(!istype(M, /mob/living/carbon/slime))		//If you're feeding it to someone else.

				if (fullness <= (550 * (1 + M.overeatduration / 1000)))
					user.visible_message("<span class='rose'>[user] attempts to feed [M] [src].</span>")
				else
					user.visible_message("<span class='rose'>[user] cannot force anymore of [src] down [M]'s throat.</span>")
					return

				if(!do_mob(user, M)) return

				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagentlist(src)]</font>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [src.name] by [M.name] ([M.ckey]) Reagents: [reagentlist(src)]</font>")
				msg_admin_attack("[key_name(user)] fed [key_name(M)] with [src.name] Reagents: [reagentlist(src)] (INTENT: [uppertext(user.a_intent)])", user)

				user.visible_message("<span class='rose'>[user] feeds [M] [src].</span>")

			else
				to_chat(user, "This creature does not seem to have a mouth!</span>")
				return


		if(reagents)								//Handle ingestion of the reagent.
			playsound(M, 'sound/items/eatfood.ogg', VOL_EFFECTS_MASTER, rand(10, 50))
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

	if (user.is_busy(src))
		return

	if(istype(W,/obj/item/weapon/storage))
		..() // -> item/attackby()
	if(istype(W,/obj/item/weapon/kitchen/utensil))

		var/obj/item/weapon/kitchen/utensil/U = W

		if(U.contents.len >= U.max_contents)
			to_chat(user, "<span class='warning'>You cannot fit anything else on your [U].")
			return

		user.visible_message( \
			"[user] scoops up some [src] with \the [U]!", \
			"<span class='notice'>You scoop up some [src] with \the [U]!</span>" \
		)

		bitecount++
		U.cut_overlays()
		var/image/I = new(U.icon, "loadedfood")
		I.color = filling_color
		U.add_overlay(I)

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
	else if(W.w_class <= ITEM_SIZE_SMALL && istype(src,/obj/item/weapon/reagent_containers/food/snacks/sliceable))
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
	if (inaccurate)
		if (istype(W, /obj/item/weapon/melee/energy/sword))
			playsound(user, 'sound/items/esword_cutting.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		else
			playsound(user, 'sound/items/shard_cutting.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	else
		playsound(src, pick(SOUNDIN_KNIFE_CUTTING), VOL_EFFECTS_MASTER, null, FALSE)
		slices_lost = rand(1,min(1,round(slices_num/2)))
	if (do_after(user, 35, target = src))
		if (!inaccurate)
			user.visible_message("<span class='info'>[user] slices \the [src]!</span>", "<span class='notice'>You slice \the [src]!</span>")
		else
			user.visible_message("<span class='info'>[user] inaccurately slices \the [src] with [W]!</span>", "<span class='notice'>You inaccurately slice \the [src] with your [W]!</span>")
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


////////////////////////////////////////////////////////////////////////////////
/// FOOD END
////////////////////////////////////////////////////////////////////////////////











//////////////////////////////////////////////////
////////////////////////////////////////////Snacks
//////////////////////////////////////////////////
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

//Here is an example of the new formatting for anyone who wants to add more food items.
///obj/item/weapon/reagent_containers/food/snacks/xenoburger			//Identification path for the object.
//	name = "Xenoburger"													//Name that displays in the UI.
//	desc = "Smells caustic. Tastes like heresy."						//Duh
//	icon_state = "xburger"												//Refers to an icon in food.dmi
//	New()																//Don't mess with this.
//		..()															//Same here.
//		reagents.add_reagent("xenomicrobes", 10)						//This is what is in the food item. you may copy/paste
//		reagents.add_reagent("nutriment", 2)							//	this line of code for all the contents.
//		bitesize = 3													//This is the amount each bite consumes.




/obj/item/weapon/reagent_containers/food/snacks/aesirsalad
	name = "Aesir salad"
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#468c00"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/aesirsalad/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("doctorsdelight", 8)
	reagents.add_reagent("vitamin", 6)

/obj/item/weapon/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Nougat, love it or hate it."
	filling_color = "#7d5f46"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("sugar", 3)

/obj/item/weapon/reagent_containers/food/snacks/candy/donor
	name = "Donor Candy"
	desc = "A little treat for blood donors."
	trash = /obj/item/trash/candy
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/candy/donor/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("sugar", 3)


/obj/item/weapon/reagent_containers/food/snacks/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Cannot be stored in a detective's hat, alas."
	icon_state = "candy_corn"
	filling_color = "#fffcb0"
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
	filling_color = "#e8c31e"
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
	filling_color = "#dbc94f"
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/cookie/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
	name = "Chocolate Bar"
	desc = "Such sweet, fattening food."
	icon_state = "chocolatebar"
	filling_color = "#7d5f46"
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
	filling_color = "#7d5f46"
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
	filling_color = "#d9c386"

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
	filling_color = "#ed11e6"
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
	filling_color = "#ed1169"
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
	filling_color = "#ed1169"
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
	filling_color = "#ed1169"
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
	filling_color = "#fdffd1"

/obj/item/weapon/reagent_containers/food/snacks/egg/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("egg", 5)

/obj/item/weapon/reagent_containers/food/snacks/egg/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	new /obj/effect/decal/cleanable/egg_smudge(loc)
	if(prob(13))
		if(global.chicken_count < MAX_CHICKENS)
			new /mob/living/simple_animal/chick(loc)
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
	filling_color = "#ffdf78"
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
	filling_color = "#ffffff"

/obj/item/weapon/reagent_containers/food/snacks/boiledegg/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("vitamin", 1)
	reagents.add_reagent("egg", 5)

/obj/item/weapon/reagent_containers/food/snacks/appendix
//yes, this is the same as meat. I might do something different in future
	name = "appendix"
	desc = "An appendix which looks perfectly healthy."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "appendix"
	filling_color = "#e00d34"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/appendix/atom_init()
	. = ..()
	reagents.add_reagent("protein", 3)
	reagents.add_reagent("vitamin", 2)


/obj/item/weapon/reagent_containers/food/snacks/appendix/inflamed
	name = "inflamed appendix"
	desc = "An appendix which appears to be inflamed."
	icon_state = "appendixinflamed"
	filling_color = "#e00d7a"

/obj/item/weapon/reagent_containers/food/snacks/tofu
	name = "Tofu"
	icon_state = "tofu"
	desc = "We all love tofu."
	filling_color = "#fffee0"
	bitesize = 3


/obj/item/weapon/reagent_containers/food/snacks/tofu/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 3)

/obj/item/weapon/reagent_containers/food/snacks/tofurkey
	name = "Tofurkey"
	desc = "A fake turkey made from tofu."
	icon_state = "tofurkey"
	filling_color = "#fffee0"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/tofurkey/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 12)
	reagents.add_reagent("stoxin", 3)

/obj/item/weapon/reagent_containers/food/snacks/stuffing
	name = "Stuffing"
	desc = "Moist, peppery breadcrumbs for filling the body cavities of dead birds. Dig in!"
	icon_state = "stuffing"
	filling_color = "#c9ac83"
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/stuffing/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)

/obj/item/weapon/reagent_containers/food/snacks/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat"
	icon_state = "fishfillet"
	filling_color = "#ffdefe"
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/carpmeat/atom_init()
	. = ..()
	reagents.add_reagent("protein", 3)
	reagents.add_reagent("carpotoxin", 3)

/obj/item/weapon/reagent_containers/food/snacks/fishfingers
	name = "Fish Fingers"
	desc = "A finger of fish."
	icon_state = "fishfingers"
	filling_color = "#ffdefe"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fishfingers/atom_init()
	. = ..()
	reagents.add_reagent("protein", 4)
	reagents.add_reagent("carpotoxin", 3)

/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"
	filling_color = "#e0d7c5"
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 3)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato"
	icon_state = "tomatomeat"
	filling_color = "#db0000"
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/tomatomeat/atom_init()
	. = ..()
	reagents.add_reagent("protein", 2)

/obj/item/weapon/reagent_containers/food/snacks/bearmeat
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	filling_color = "#db0000"
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
	filling_color = "#43de18"
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

/obj/item/weapon/reagent_containers/food/snacks/meatball
	name = "meatball"
	desc = "A great meal all round."
	icon_state = "meatball"
	filling_color = "#db0000"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatball/atom_init()
	. = ..()
	reagents.add_reagent("protein", 4)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/sausage
	name = "Sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	filling_color = "#db0000"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sausage/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	name = "Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	filling_color = "#dedeab"
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

/obj/item/weapon/reagent_containers/food/snacks/brainburger
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	filling_color = "#f2b6ea"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/brainburger/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("protein", 4)
	reagents.add_reagent("alkysine", 6)

/obj/item/weapon/reagent_containers/food/snacks/ghostburger
	name = "Ghost Burger"
	desc = "Spooky! It doesn't look very filling."
	icon_state = "ghostburger"
	filling_color = "#fff2ff"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/ghostburger/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("ectoplasm", 1)


/obj/item/weapon/reagent_containers/food/snacks/human
	var/hname = ""
	var/job = null
	filling_color = "#d63c3c"

/obj/item/weapon/reagent_containers/food/snacks/human/burger
	name = "-burger"
	desc = "A bloody burger."
	icon_state = "hburger"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/human/burger/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("protein", 4)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/cheeseburger
	name = "cheeseburger"
	desc = "The cheese adds a good flavor."
	icon_state = "cheeseburger"

/obj/item/weapon/reagent_containers/food/snacks/cheeseburger/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("cheese", 4)
	reagents.add_reagent("vitamin", 1)


/obj/item/weapon/reagent_containers/food/snacks/monkeyburger
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	filling_color = "#d63c3c"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/monkeyburger/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("protein", 4)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/fishburger
	name = "Fillet -o- Carp Sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon_state = "fishburger"
	filling_color = "#ffdefe"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fishburger/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)
	reagents.add_reagent("carpotoxin", 3)

/obj/item/weapon/reagent_containers/food/snacks/tofuburger
	name = "Tofu Burger"
	desc = "What.. is that meat?"
	icon_state = "tofuburger"
	filling_color = "#fffee0"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofuburger/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 6)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	filling_color = "#cccccc"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/roburger/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)
	if(prob(5))
		reagents.add_reagent("nanites", 2)
		reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/roburgerbig
	name = "roburger"
	desc = "This massive patty looks like poison. Beep."
	icon_state = "roburger"
	filling_color = "#cccccc"
	volume = 100
	bitesize = 0.1

/obj/item/weapon/reagent_containers/food/snacks/roburgerbig/atom_init()
	. = ..()
	reagents.add_reagent("nanites", 100)
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("vitamin", 5)

/obj/item/weapon/reagent_containers/food/snacks/xenoburger
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	filling_color = "#43de18"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/xenoburger/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/clownburger
	name = "Clown Burger"
	desc = "This tastes funny... And HONKS!"
	icon_state = "clownburger"
	filling_color = "#ff00ff"
	bitesize = 2
	var/cooldown = FALSE

/obj/item/weapon/reagent_containers/food/snacks/clownburger/atom_init()
	. = ..()
/*
	var/datum/disease/F = new /datum/disease/pierrot_throat(0)
	var/list/data = list("viruses"= list(F))
	reagents.add_reagent("blood", 4, data)
*/
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/clownburger/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = world.time + 8
		playsound(src, 'sound/items/bikehorn.ogg', VOL_EFFECTS_MISC)
		src.add_fingerprint(user)
	return

/obj/item/weapon/reagent_containers/food/snacks/mimeburger
	name = "Mime Burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	filling_color = "#ffffff"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mimeburger/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)

/obj/item/weapon/reagent_containers/food/snacks/omelette
	name = "Omelette Du Fromage"
	desc = "That's all you can say!"
	icon_state = "omelette"
	trash = /obj/item/trash/plate
	filling_color = "#fff9a8"
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
	filling_color = "#e0cf9b"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/muffin/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)

/obj/item/weapon/reagent_containers/food/snacks/pie
	name = "Banana Cream Pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/plate
	filling_color = "#fbffb8"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/pie/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 6)
	reagents.add_reagent("banana",5)
	reagents.add_reagent("vitamin", 2)

/obj/item/weapon/reagent_containers/food/snacks/pie/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
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
	filling_color = "#e6deb5"
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
	filling_color = "#4d2f5e"
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
	filling_color = "#b8e6b5"
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
	filling_color = "#e6fa61"
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
	filling_color = "#fffee0"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofupie/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 10)
	reagents.add_reagent("vitamin", 2)

/obj/item/weapon/reagent_containers/food/snacks/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	filling_color = "#ffcccc"
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
	filling_color = "#b8279b"
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
	filling_color = "#43de18"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/xemeatpie/atom_init()
	. = ..()
	reagents.add_reagent("protein", 10)
	reagents.add_reagent("vitamin", 2)

/obj/item/weapon/reagent_containers/food/snacks/wingfangchu
	name = "Wing Fang Chu"
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#43de18"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/wingfangchu/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)
	reagents.add_reagent("vitamin", 2)


/obj/item/weapon/reagent_containers/food/snacks/human/kabob
	name = "-kabob"
	icon_state = "kabob"
	desc = "A human meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#a85340"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/human/kabob/atom_init()
	. = ..()
	reagents.add_reagent("protein", 8)

/obj/item/weapon/reagent_containers/food/snacks/kabob
	name = "Meat-kabob"
	icon_state = "kabob"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#a85340"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/kabob/atom_init()
	. = ..()
	reagents.add_reagent("protein", 8)

/obj/item/weapon/reagent_containers/food/snacks/tofukabob
	name = "Tofu-kabob"
	icon_state = "kabob"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#fffee0"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofukabob/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 8)

/obj/item/weapon/reagent_containers/food/snacks/cubancarp
	name = "Cuban Carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate
	filling_color = "#e9adff"
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
	filling_color = "#fffad4"
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
	reagents.add_reagent("protein", 3)
	reagents.add_reagent("sugar", 1)

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
	filling_color = "#ffe591"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 4)

/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers
	name = "Cheesie Honkers"
	icon_state = "cheesie_honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	trash = /obj/item/trash/cheesie
	filling_color = "#ffa305"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("sugar", 3)

/obj/item/weapon/reagent_containers/food/snacks/chinese/chowmein
	name = "chow mein"
	desc = "What is in this anyways?"
	icon_state = "chinese1"
	trash = /obj/item/trash/chinese1

/obj/item/weapon/reagent_containers/food/snacks/chinese/chowmein/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("beans", 3)
	reagents.add_reagent("sugar", 2)

/obj/item/weapon/reagent_containers/food/snacks/chinese/sweetsourchickenball
	name = "Sweet & Sour Chicken Balls"
	desc = "Is this chicken cooked? The odds are better than wok paper scissors."
	icon_state = "chickenball"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/chinese/sweetsourchickenball/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("sugar", 2)

/obj/item/weapon/reagent_containers/food/snacks/chinese/tao
	name = "Admiral Yamamoto carp"
	desc = "Tastes like chicken."
	icon_state = "chinese2"
	trash = /obj/item/trash/chinese2

/obj/item/weapon/reagent_containers/food/snacks/chinese/tao/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("protein", 1)
	reagents.add_reagent("sugar", 4)

/obj/item/weapon/reagent_containers/food/snacks/chinese/newdles
	name = "chinese newdles"
	desc = "Made fresh, weekly!"
	icon_state = "chinese3"
	trash = /obj/item/trash/chinese3

/obj/item/weapon/reagent_containers/food/snacks/chinese/newdles/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("sugar", 3)

/obj/item/weapon/reagent_containers/food/snacks/chinese/rice
	name = "fried rice"
	desc = "A timeless classic."
	icon_state = "chinese4"
	trash = /obj/item/trash/chinese4

/obj/item/weapon/reagent_containers/food/snacks/chinese/rice/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("sugar", 2)
	reagents.add_reagent("rice", 3)

/obj/item/weapon/reagent_containers/food/snacks/syndicake
	name = "Syndi-Cakes"
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	filling_color = "#ff5d05"
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
	filling_color = "#9c7a68"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)

/obj/item/weapon/reagent_containers/food/snacks/fries
	name = "Space Fries"
	desc = "AKA: French Fries, Freedom Fries, etc."
	icon_state = "fries"
	trash = /obj/item/trash/plate
	filling_color = "#eddd00"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fries/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 4)

/obj/item/weapon/reagent_containers/food/snacks/soydope
	name = "Soy Dope"
	desc = "Dope from a soy."
	icon_state = "soydope"
	trash = /obj/item/trash/plate
	filling_color = "#c4bf76"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soydope/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)

/obj/item/weapon/reagent_containers/food/snacks/spagetti
	name = "Spaghetti"
	desc = "A bundle of raw spaghetti."
	icon_state = "spagetti"
	filling_color = "#eddd00"
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/spagetti/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries
	name = "Cheesy Fries"
	desc = "Fries. Covered in cheese. Duh."
	icon_state = "cheesyfries"
	trash = /obj/item/trash/plate
	filling_color = "#eddd00"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)

/obj/item/weapon/reagent_containers/food/snacks/fortunecookie
	name = "Fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"
	filling_color = "#e8e79e"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fortunecookie/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)

/obj/item/weapon/reagent_containers/food/snacks/badrecipe
	name = "Burned mess"
	desc = "Someone should be demoted from chef for this."
	icon_state = "badrecipe"
	filling_color = "#211f02"
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
	filling_color = "#7a3d11"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meatsteak/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("blackpepper", 1)

/obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff
	name = "Spacy Liberty Duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook."
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#42b873"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 6)
	reagents.add_reagent("psilocybin", 6)

/obj/item/weapon/reagent_containers/food/snacks/amanitajelly
	name = "Amanita Jelly"
	desc = "Looks curiously toxic."
	icon_state = "amanitajelly"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#ed0758"
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
	filling_color = "#916e36"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 5)


/obj/item/weapon/reagent_containers/food/snacks/meatballsoup
	name = "Meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#785210"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/meatballsoup/atom_init()
	. = ..()
	reagents.add_reagent("protein", 8)
	reagents.add_reagent("water", 5)
	reagents.add_reagent("vitamin", 4)

/obj/item/weapon/reagent_containers/food/snacks/slimesoup
	name = "slime soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup"
	filling_color = "#c4dba0"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/slimesoup/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("slimejelly", 5)
	reagents.add_reagent("water", 10)
	reagents.add_reagent("vitamin", 4)

/obj/item/weapon/reagent_containers/food/snacks/bloodsoup
	name = "Tomato soup"
	desc = "Smells like copper."
	icon_state = "tomatosoup"
	filling_color = "#ff0000"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/bloodsoup/atom_init()
	. = ..()
	reagents.add_reagent("protein", 2)
	reagents.add_reagent("blood", 10)
	reagents.add_reagent("water", 5)
	reagents.add_reagent("vitamin", 4)

/obj/item/weapon/reagent_containers/food/snacks/clownstears
	name = "Clown's Tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	filling_color = "#c4fbff"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/clownstears/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("banana", 5)
	reagents.add_reagent("water", 10)
	reagents.add_reagent("vitamin", 8)

/obj/item/weapon/reagent_containers/food/snacks/vegetablesoup
	name = "Vegetable soup"
	desc = "A true vegan meal." //TODO
	icon_state = "vegetablesoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#afc4b5"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/vegetablesoup/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 8)  //done!
	reagents.add_reagent("water", 5)
	reagents.add_reagent("vitamin", 4)

/obj/item/weapon/reagent_containers/food/snacks/nettlesoup
	name = "Nettle soup"
	desc = "To think, the botanist would've beat you to death with one of these."
	icon_state = "nettlesoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#afc4b5"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/nettlesoup/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 8)
	reagents.add_reagent("water", 5)
	reagents.add_reagent("tricordrazine", 5)
	reagents.add_reagent("vitamin", 4)

/obj/item/weapon/reagent_containers/food/snacks/mysterysoup
	name = "Mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#f082ff"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/mysterysoup/atom_init()
	. = ..()
	var/mysteryselect = pick(1,2,3,4,5,6,7,8,9,10)
	switch(mysteryselect)
		if(1)
			reagents.add_reagent("nutriment", 6)
			reagents.add_reagent("capsaicin", 3)
			reagents.add_reagent("tomatojuice", 2)
		if(2)
			reagents.add_reagent("nutriment", 6)
			reagents.add_reagent("frostoil", 3)
			reagents.add_reagent("tomatojuice", 2)
		if(3)
			reagents.add_reagent("nutriment", 5)
			reagents.add_reagent("water", 5)
			reagents.add_reagent("tricordrazine", 5)
		if(4)
			reagents.add_reagent("nutriment", 5)
			reagents.add_reagent("water", 10)
		if(5)
			reagents.add_reagent("nutriment", 2)
			reagents.add_reagent("banana", 10)
		if(6)
			reagents.add_reagent("nutriment", 6)
			reagents.add_reagent("blood", 10)
		if(7)
			reagents.add_reagent("slimejelly", 10)
			reagents.add_reagent("water", 10)
		if(8)
			reagents.add_reagent("carbon", 10)
			reagents.add_reagent("toxin", 10)
		if(9)
			reagents.add_reagent("nutriment", 5)
			reagents.add_reagent("tomatojuice", 10)
		if(10)
			reagents.add_reagent("nutriment", 6)
			reagents.add_reagent("tomatojuice", 5)
			reagents.add_reagent("imidazoline", 5)

/obj/item/weapon/reagent_containers/food/snacks/wishsoup
	name = "Wish Soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#d1f4ff"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/wishsoup/atom_init()
	. = ..()
	reagents.add_reagent("water", 10)
	if(prob(25))
		src.desc = "A wish come true!"
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/hotchili
	name = "Hot Chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#ff3c00"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/hotchili/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 6)
	reagents.add_reagent("capsaicin", 3)
	reagents.add_reagent("tomatojuice", 2)
	reagents.add_reagent("vitamin", 2)


/obj/item/weapon/reagent_containers/food/snacks/coldchili
	name = "Cold Chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	filling_color = "#2b00ff"
	bitesize = 5

	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/coldchili/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 6)
	reagents.add_reagent("frostoil", 3)
	reagents.add_reagent("tomatojuice", 2)
	reagents.add_reagent("vitamin", 2)

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
	filling_color = "#adac7f"

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
			BP.embed(surprise)
			BP.take_damage(30, 0, DAM_SHARP|DAM_EDGE, "Animal escaping the ribcage")
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


/obj/item/weapon/reagent_containers/food/snacks/spellburger
	name = "Spell Burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"
	filling_color = "#d505ff"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spellburger/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/bigbiteburger
	name = "Big Bite Burger"
	desc = "Forget the Big Mac. THIS is the future!"
	icon_state = "bigbiteburger"
	filling_color = "#e3d681"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/bigbiteburger/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("protein", 10)
	reagents.add_reagent("vitamin", 2)

/obj/item/weapon/reagent_containers/food/snacks/enchiladas
	name = "Enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"
	trash = /obj/item/trash/tray
	filling_color = "#a36a1f"
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
	filling_color = "#5c3c11"
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
	filling_color = "#e3d796"

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
	filling_color = "#e3d796"

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
	filling_color = "#d9be29"

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
	filling_color = "#d9be29"

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
	filling_color = "#d9be29"

/obj/item/weapon/reagent_containers/food/snacks/grilledcheese/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 7)
	reagents.add_reagent("vitamin", 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tomatosoup
	name = "Tomato Soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#d92929"

/obj/item/weapon/reagent_containers/food/snacks/tomatosoup/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 5)
	reagents.add_reagent("tomatojuice", 10)
	reagents.add_reagent("vitamin", 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/rofflewaffles
	name = "Roffle Waffles"
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	filling_color = "#ff00f7"

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
	filling_color = "#9e673a"

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
	filling_color = "#b572ab"

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

/obj/item/weapon/reagent_containers/food/snacks/jellyburger
	name = "Jelly Burger"
	desc = "Culinary delight..?"
	icon_state = "jellyburger"
	filling_color = "#b572ab"

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/slime

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/slime/atom_init()
	. = ..()
	reagents.add_reagent("slimejelly", 5)

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/cherry

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/cherry/atom_init()
	. = ..()
	reagents.add_reagent("cherryjelly", 5)

/obj/item/weapon/reagent_containers/food/snacks/milosoup
	name = "Milosoup"
	desc = "The universes best soup! Yum!!!"
	icon_state = "milosoup"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/milosoup/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("water", 5)
	reagents.add_reagent("vitamin", 2)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat
	name = "Stewed Soy Meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/boiledspagetti
	name = "Boiled Spaghetti"
	desc = "A plain dish of noodles, this sucks."
	icon_state = "spagettiboiled"
	trash = /obj/item/trash/plate
	filling_color = "#fcee81"

/obj/item/weapon/reagent_containers/food/snacks/boiledspagetti/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 2)
	reagents.add_reagent("vitamin", 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/boiledrice
	name = "Boiled Rice"
	desc = "A boring dish of boring rice."
	icon_state = "boiledrice"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#fffbdb"

/obj/item/weapon/reagent_containers/food/snacks/boiledrice/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 5)
	reagents.add_reagent("vitamin", 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sushi
	name = "Sushi"
	desc = "This is the Japanese preparation and serving of specially prepared vinegared rice combined with varied ingredients such as chiefly seafood"
	icon_state = "sushi"
	filling_color = "#fffbdb"

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
	filling_color = "#fffbdb"

/obj/item/weapon/reagent_containers/food/snacks/ricepudding/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 4)
	reagents.add_reagent("vitamin", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pastatomato
	name = "Spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	trash = /obj/item/trash/plate
	filling_color = "#de4545"

/obj/item/weapon/reagent_containers/food/snacks/pastatomato/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 6)
	reagents.add_reagent("tomatojuice", 10)
	reagents.add_reagent("vitamin", 4)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/meatballspagetti
	name = "Spaghetti & Meatballs"
	desc = "Now thats a nic'e meatball!"
	icon_state = "meatballspagetti"
	trash = /obj/item/trash/plate
	filling_color = "#de4545"

/obj/item/weapon/reagent_containers/food/snacks/meatballspagetti/atom_init()
	. = ..()
	reagents.add_reagent("protein", 8)
	reagents.add_reagent("vitamin", 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/spesslaw
	name = "Spesslaw"
	desc = "A lawyers favourite"
	icon_state = "spesslaw"
	filling_color = "#de4545"

/obj/item/weapon/reagent_containers/food/snacks/spesslaw/atom_init()
	. = ..()
	reagents.add_reagent("protein", 8)
	reagents.add_reagent("vitamin", 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel
	name = "Poppy Pretzel"
	desc = "A large soft pretzel full of POP!"
	icon_state = "poppypretzel"
	filling_color = "#ab7d2e"

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/carrotfries
	name = "Carrot Fries"
	desc = "Tasty fries from fresh Carrots."
	icon_state = "carrotfries"
	trash = /obj/item/trash/plate
	filling_color = "#faa005"

/obj/item/weapon/reagent_containers/food/snacks/carrotfries/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 3)
	reagents.add_reagent("imidazoline", 3)
	reagents.add_reagent("vitamin", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/superbiteburger
	name = "Super Bite Burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	filling_color = "#cca26a"

/obj/item/weapon/reagent_containers/food/snacks/superbiteburger/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 32)
	reagents.add_reagent("cheese", 4)
	reagents.add_reagent("protein", 16)
	reagents.add_reagent("vitamin", 5)
	bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/candiedapple
	name = "Candied Apple"
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"
	filling_color = "#f21873"

/obj/item/weapon/reagent_containers/food/snacks/candiedapple/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sugar", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/applepie
	name = "Apple Pie"
	desc = "A pie containing sweet sweet love... or apple."
	icon_state = "applepie"
	filling_color = "#e0edc5"

/obj/item/weapon/reagent_containers/food/snacks/applepie/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("vitamin", 2)
	bitesize = 3


/obj/item/weapon/reagent_containers/food/snacks/cherrypie
	name = "Cherry Pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	filling_color = "#ff525a"

/obj/item/weapon/reagent_containers/food/snacks/cherrypie/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("vitamin", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/twobread
	name = "Two Bread"
	desc = "It is very bitter and winy."
	icon_state = "twobread"
	filling_color = "#dbcc9a"

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
	filling_color = "#9e3a78"

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

/obj/item/weapon/reagent_containers/food/snacks/boiledslimecore/atom_init()
	. = ..()
	reagents.add_reagent("slimejelly", 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/mint
	name = "mint"
	desc = "it is only wafer thin."
	icon_state = "mint"
	filling_color = "#f2f2f2"

/obj/item/weapon/reagent_containers/food/snacks/mint/atom_init()
	. = ..()
	reagents.add_reagent("minttoxin", 1)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/mushroomsoup
	name = "chantrelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#e386bf"

/obj/item/weapon/reagent_containers/food/snacks/mushroomsoup/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 8)
	reagents.add_reagent("vitamin", 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"
	filling_color = "#cfb4c4"

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

/obj/item/weapon/reagent_containers/food/snacks/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#f0f2e4"

/obj/item/weapon/reagent_containers/food/snacks/chawanmushi/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/beetsoup
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#fac9ff"

/obj/item/weapon/reagent_containers/food/snacks/beetsoup/atom_init()
	. = ..()
	switch(rand(1,6))
		if(1)
			name = "borsch"
		if(2)
			name = "bortsch"
		if(3)
			name = "borstch"
		if(4)
			name = "borsh"
		if(5)
			name = "borshch"
		if(6)
			name = "borscht"
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("vitamin", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tossedsalad
	name = "tossed salad"
	desc = "A proper salad, basic and simple, with little bits of carrot, tomato and apple intermingled. Vegan!"
	icon_state = "herbsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76b87f"

/obj/item/weapon/reagent_containers/food/snacks/tossedsalad/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 8)
	reagents.add_reagent("vitamin", 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/validsalad
	name = "valid salad"
	desc = "It's just a salad of questionable 'herbs' with meatballs and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76b87f"

/obj/item/weapon/reagent_containers/food/snacks/validsalad/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 8)
	reagents.add_reagent("vitamin", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/olivyesalad
	name = "Olivye salad"
	desc = "It's a traditional salad dish in Russian cuisine."
	icon_state = "olivyesalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76b87f"

/obj/item/weapon/reagent_containers/food/snacks/olivyesalad/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 9)
	reagents.add_reagent("vitamin", 1)
	reagents.add_reagent("protein", 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	trash = /obj/item/trash/plate
	filling_color = "#ffff00"

/obj/item/weapon/reagent_containers/food/snacks/appletart/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 8)
	reagents.add_reagent("gold", 5)
	reagents.add_reagent("vitamin", 4)
	bitesize = 3

/////////////////////////////////////////////////Sliceable////////////////////////////////////////
// All the food items that can be sliced into smaller bits like Meatbread and Cheesewheels

// sliceable is just an organization type path, it doesn't have any additional code or variables tied to it.

/obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon_state = "meatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/meatbreadslice
	slices_num = 5
	filling_color = "#ff7575"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/meatbread/atom_init()
	. = ..()
	reagents.add_reagent("protein", 20)
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("vitamin", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatbreadslice
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon_state = "meatbreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#ff7575"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/xenomeatbread
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquent gentleman. Extra Heretical."
	icon_state = "xenomeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/xenomeatbreadslice
	slices_num = 5
	filling_color = "#8aff75"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/xenomeatbread/atom_init()
	. = ..()
	reagents.add_reagent("protein", 20)
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("vitamin", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/xenomeatbreadslice
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon_state = "xenobreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#8aff75"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/spidermeatbread
	name = "spider meat loaf"
	desc = "Reassuringly green meatloaf made from spider meat."
	icon_state = "spidermeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/spidermeatbreadslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/sliceable/spidermeatbread/atom_init()
	. = ..()
	reagents.add_reagent("protein", 20)
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("vitamin", 5)
	reagents.add_reagent("toxin", 15)

/obj/item/weapon/reagent_containers/food/snacks/spidermeatbreadslice
	name = "spider meat bread slice"
	desc = "A slice of meatloaf made from an animal that most likely still wants you dead."
	icon_state = "xenobreadslice"
	trash = /obj/item/trash/plate


/obj/item/weapon/reagent_containers/food/snacks/sliceable/bananabread
	name = "Banana-nut bread"
	desc = "A heavenly and filling treat."
	icon_state = "bananabread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/bananabreadslice
	slices_num = 5
	filling_color = "#ede5ad"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bananabread/atom_init()
	. = ..()
	reagents.add_reagent("banana", 20)
	reagents.add_reagent("nutriment", 20)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/bananabreadslice
	name = "Banana-nut bread slice"
	desc = "A slice of delicious banana bread."
	icon_state = "bananabreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#ede5ad"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/tofubread
	name = "Tofubread"
	icon_state = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon_state = "tofubread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/tofubreadslice
	slices_num = 5
	filling_color = "#f7ffe0"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/tofubread/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 20)
	reagents.add_reagent("vitamin", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofubreadslice
	name = "Tofubread slice"
	desc = "A slice of delicious tofubread."
	icon_state = "tofubreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#f7ffe0"
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/sliceable/carrotcake
	name = "Carrot Cake"
	desc = "A favorite desert of a certain wascally wabbit. Not a lie."
	icon_state = "carrotcake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/carrotcakeslice
	slices_num = 5
	filling_color = "#ffd675"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/carrotcake/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 20)
	reagents.add_reagent("imidazoline", 10)
	reagents.add_reagent("vitamin", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/carrotcakeslice
	name = "Carrot Cake slice"
	desc = "Carrotty slice of Carrot Cake, carrots are good for your eyes! Also not a lie."
	icon_state = "carrotcake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#ffd675"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/braincake
	name = "Brain Cake"
	desc = "A squishy cake-thing."
	icon_state = "braincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/braincakeslice
	slices_num = 5
	filling_color = "#e6aedb"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/braincake/atom_init()
	. = ..()
	reagents.add_reagent("protein", 10)
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("alkysine", 10)
	reagents.add_reagent("vitamin", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/braincakeslice
	name = "Brain Cake slice"
	desc = "Lemme tell you something about prions. THEY'RE DELICIOUS."
	icon_state = "braincakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#e6aedb"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesecake
	name = "Cheese Cake"
	desc = "DANGEROUSLY cheesy."
	icon_state = "cheesecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cheesecakeslice
	slices_num = 5
	filling_color = "#faf7af"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesecake/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 20)
	reagents.add_reagent("vitamin", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesecakeslice
	name = "Cheese Cake slice"
	desc = "Slice of pure cheestisfaction"
	icon_state = "cheesecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#faf7af"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/plaincake
	name = "Vanilla Cake"
	desc = "A plain cake, not a lie."
	icon_state = "plaincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/plaincakeslice
	slices_num = 5
	filling_color = "#f7edd5"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/plaincake/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 20)
	reagents.add_reagent("vitamin", 5)

/obj/item/weapon/reagent_containers/food/snacks/plaincakeslice
	name = "Vanilla Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "plaincake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#f7edd5"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/orangecake
	name = "Orange Cake"
	desc = "A cake with added orange."
	icon_state = "orangecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/orangecakeslice
	slices_num = 5
	filling_color = "#fada8e"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/orangecake/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 20)
	reagents.add_reagent("vitamin", 5)

/obj/item/weapon/reagent_containers/food/snacks/orangecakeslice
	name = "Orange Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "orangecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#fada8e"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/limecake
	name = "Lime Cake"
	desc = "A cake with added lime."
	icon_state = "limecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/limecakeslice
	slices_num = 5
	filling_color = "#cbfa8e"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/limecake/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 20)
	reagents.add_reagent("vitamin", 5)

/obj/item/weapon/reagent_containers/food/snacks/limecakeslice
	name = "Lime Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "limecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#cbfa8e"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/lemoncake
	name = "Lemon Cake"
	desc = "A cake with added lemon."
	icon_state = "lemoncake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/lemoncakeslice
	slices_num = 5
	filling_color = "#fafa8e"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/lemoncake/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 20)
	reagents.add_reagent("vitamin", 5)

/obj/item/weapon/reagent_containers/food/snacks/lemoncakeslice
	name = "Lemon Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "lemoncake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#fafa8e"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/chocolatecake
	name = "Chocolate Cake"
	desc = "A cake with added chocolate"
	icon_state = "chocolatecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/chocolatecakeslice
	slices_num = 5
	filling_color = "#805930"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/chocolatecake/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 20)
	reagents.add_reagent("vitamin", 5)

/obj/item/weapon/reagent_containers/food/snacks/chocolatecakeslice
	name = "Chocolate Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "chocolatecake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#805930"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel
	name = "Cheese wheel"
	desc = "A big wheel of delcious Cheddar."
	icon_state = "cheesewheel"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	slices_num = 5
	filling_color = "#fff700"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 15)
	reagents.add_reagent("vitamin", 5)
	reagents.add_reagent("cheese", 20)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	name = "Cheese wedge"
	desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewedge"
	filling_color = "#fff700"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake
	name = "Birthday Cake"
	desc = "Happy Birthday..."
	icon_state = "birthdaycake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/birthdaycakeslice
	slices_num = 5
	filling_color = "#ffd6d6"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 20)
	reagents.add_reagent("sprinkles", 10)
	reagents.add_reagent("vitamin", 5)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/birthdaycakeslice
	name = "Birthday Cake slice"
	desc = "A slice of your birthday"
	icon_state = "birthdaycakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#ffd6d6"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread
	name = "Bread"
	icon_state = "Some plain old Earthen bread."
	icon_state = "bread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice
	slices_num = 5
	filling_color = "#ffe396"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("bread", 10)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/breadslice
	name = "Bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	filling_color = "#d27332"
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/sliceable/creamcheesebread
	name = "Cream Cheese Bread"
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/creamcheesebreadslice
	slices_num = 5
	filling_color = "#fff896"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/creamcheesebread/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 20)
	reagents.add_reagent("vitamin", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/creamcheesebreadslice
	name = "Cream Cheese Bread slice"
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	trash = /obj/item/trash/plate
	filling_color = "#fff896"
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/watermelonslice
	name = "Watermelon Slice"
	desc = "A slice of watery goodness."
	icon_state = "watermelonslice"
	filling_color = "#ff3867"
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/sliceable/applecake
	name = "Apple Cake"
	desc = "A cake centred with Apple"
	icon_state = "applecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/applecakeslice
	slices_num = 5
	filling_color = "#ebf5b8"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/applecake/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 20)
	reagents.add_reagent("vitamin", 5)

/obj/item/weapon/reagent_containers/food/snacks/applecakeslice
	name = "Apple Cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "applecakeslice"
	trash = /obj/item/trash/plate
	filling_color = "#ebf5b8"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinpie
	name = "Pumpkin Pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	slices_num = 5
	filling_color = "#f5b951"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pumpkinpie/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 20)
	reagents.add_reagent("vitamin", 5)

/obj/item/weapon/reagent_containers/food/snacks/pumpkinpieslice
	name = "Pumpkin Pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon_state = "pumpkinpieslice"
	trash = /obj/item/trash/plate
	filling_color = "#f5b951"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cracker
	name = "Cracker"
	desc = "It's a salted cracker."
	icon_state = "cracker"
	filling_color = "#f5deb8"

/obj/item/weapon/reagent_containers/food/snacks/cracker/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)



/////////////////////////////////////////////////PIZZA////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza
	slices_num = 6
	filling_color = "#baa14c"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita
	name = "Margherita"
	desc = "The golden standard of pizzas."
	icon_state = "pizzamargherita"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/margheritaslice
	slices_num = 6

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 30)
	reagents.add_reagent("tomatojuice", 6)
	reagents.add_reagent("vitamin", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/margheritaslice
	name = "Margherita slice"
	desc = "A slice of the classic pizza."
	icon_state = "pizzamargheritaslice"
	filling_color = "#baa14c"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza
	name = "Meatpizza"
	desc = "A pizza with meat topping."
	icon_state = "meatpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/meatpizzaslice
	slices_num = 6

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza/atom_init()
	. = ..()
	reagents.add_reagent("protein", 30)
	reagents.add_reagent("tomatojuice", 6)
	reagents.add_reagent("vitamin", 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatpizzaslice
	name = "Meatpizza slice"
	desc = "A slice of a meaty pizza."
	icon_state = "meatpizzaslice"
	filling_color = "#baa14c"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza
	name = "Mushroompizza"
	desc = "Very special pizza"
	icon_state = "mushroompizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/mushroompizzaslice
	slices_num = 6

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 30)
	reagents.add_reagent("vitamin", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/mushroompizzaslice
	name = "Mushroompizza slice"
	desc = "Maybe it is the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"
	filling_color = "#baa14c"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza
	name = "Vegetable pizza"
	desc = "No one of Tomato Sapiens were harmed during making this pizza"
	icon_state = "vegetablepizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/vegetablepizzaslice
	slices_num = 6

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 25)
	reagents.add_reagent("tomatojuice", 6)
	reagents.add_reagent("imidazoline", 12)
	reagents.add_reagent("vitamin", 5)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/vegetablepizzaslice
	name = "Vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients "
	icon_state = "vegetablepizzaslice"
	filling_color = "#baa14c"
	bitesize = 2

/obj/item/pizzabox
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food.dmi'
	icon_state = "pizzabox1"
	item_state = "pizzabox"
	var/open = 0 // Is the box open?
	var/ismessy = 0 // Fancy mess on the lid
	var/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/pizza // Content pizza
	var/list/boxes = list() // If the boxes are stacked, they come here
	var/boxtag = ""

/obj/item/pizzabox/update_icon()

	cut_overlays()

	// Set appropriate description
	if( open && pizza )
		desc = "A box suited for pizzas. It appears to have a [pizza.name] inside."
	else if( boxes.len > 0 )
		desc = "A pile of boxes suited for pizzas. There appears to be [boxes.len + 1] boxes in the pile."

		var/obj/item/pizzabox/topbox = boxes[boxes.len]
		var/toptag = topbox.boxtag
		if( toptag != "" )
			desc = "[desc] The box on top has a tag, it reads: '[toptag]'."
	else
		desc = "A box suited for pizzas."

		if( boxtag != "" )
			desc = "[desc] The box has a tag, it reads: '[boxtag]'."

	// Icon states and overlays
	if( open )
		if( ismessy )
			icon_state = "pizzabox_messy"
		else
			icon_state = "pizzabox_open"

		if( pizza )
			var/image/pizzaimg = image("food.dmi", icon_state = pizza.icon_state)
			pizzaimg.pixel_y = -3
			add_overlay(pizzaimg)

		return
	else
		// Stupid code because byondcode sucks
		var/doimgtag = 0
		if( boxes.len > 0 )
			var/obj/item/pizzabox/topbox = boxes[boxes.len]
			if( topbox.boxtag != "" )
				doimgtag = 1
		else
			if( boxtag != "" )
				doimgtag = 1

		if( doimgtag )
			var/image/tagimg = image("food.dmi", icon_state = "pizzabox_tag")
			tagimg.pixel_y = boxes.len * 3
			add_overlay(tagimg)

	icon_state = "pizzabox[boxes.len+1]"

/obj/item/pizzabox/attack_hand( mob/user )

	if( open && pizza )
		user.put_in_hands( pizza )

		to_chat(user, "<span class='notice'>You take the [src.pizza] out of the [src].</span>")
		src.pizza = null
		update_icon()
		return

	if( boxes.len > 0 )
		if( user.get_inactive_hand() != src )
			..()
			return

		var/obj/item/pizzabox/box = boxes[boxes.len]
		boxes -= box

		user.put_in_hands( box )
		to_chat(user, "<span class='notice'>You remove the topmost [src] from your hand.</span>")
		box.update_icon()
		update_icon()
		return
	..()

/obj/item/pizzabox/attack_self( mob/user )

	if( boxes.len > 0 )
		return

	open = !open

	if( open && pizza )
		ismessy = 1

	update_icon()

/obj/item/pizzabox/attackby( obj/item/I, mob/user )
	if( istype(I, /obj/item/pizzabox) )
		var/obj/item/pizzabox/box = I

		if( !box.open && !src.open )
			// Make a list of all boxes to be added
			var/list/boxestoadd = list()
			boxestoadd += box
			for(var/obj/item/pizzabox/i in box.boxes)
				boxestoadd += i

			if( (boxes.len+1) + boxestoadd.len <= 5 )
				user.drop_item()

				box.loc = src
				box.boxes = list() // Clear the box boxes so we don't have boxes inside boxes. - Xzibit
				src.boxes.Add( boxestoadd )

				box.update_icon()
				update_icon()

				to_chat(user, "<span class='notice'>You put the [box] ontop of the [src]!</span>")
			else
				to_chat(user, "<span class='rose'>The stack is too high!</span>")
		else
			to_chat(user, "<span class='rose'>Close the [box] first!</span>")

		return

	if( istype(I, /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza) ) // Long ass fucking object name

		if( src.open )
			user.drop_item()
			I.loc = src
			src.pizza = I

			update_icon()

			to_chat(user, "<span class='notice'>You put the [I] in the [src]!</span>")
		else
			to_chat(user, "<span class='rose'>You try to push the [I] through the lid but it doesn't work!</span>")
		return

	if( istype(I, /obj/item/weapon/pen) )

		if( src.open )
			return

		var/t = sanitize_safe(input("Enter what you want to add to the tag:", "Write", null, null) as text, MAX_LNAME_LEN)

		var/obj/item/pizzabox/boxtotagto = src
		if( boxes.len > 0 )
			boxtotagto = boxes[boxes.len]

		boxtotagto.boxtag = copytext("[boxtotagto.boxtag][t]", 1, 30)

		update_icon()
		return
	..()

/obj/item/pizzabox/margherita/atom_init()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita(src)
	boxtag = "Margherita Deluxe"

/obj/item/pizzabox/vegetable/atom_init()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza(src)
	boxtag = "Gourmet Vegatable"

/obj/item/pizzabox/mushroom/atom_init()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroompizza(src)
	boxtag = "Mushroom Special"

/obj/item/pizzabox/meat/atom_init()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meatpizza(src)
	boxtag = "Meatlover's Supreme"

/obj/item/weapon/reagent_containers/food/snacks/dionaroast
	name = "roast diona"
	desc = "It's like an enormous, leathery carrot. With an eye."
	icon_state = "dionaroast"
	trash = /obj/item/trash/plate
	filling_color = "#75754b"

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

///////////////////////////////////////////
// new old food stuff from bs12
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "dough"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/dough/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)

// Dough + rolling pin = flat dough
/obj/item/weapon/reagent_containers/food/snacks/dough/attackby(obj/item/weapon/W, mob/user)

	if (user.is_busy(src))
		return

	if(istype(W,/obj/item/weapon/kitchen/rollingpin))
		if (locate(/obj/structure/table) in src.loc)
			playsound(user, 'sound/items/rolling_pin.ogg', VOL_EFFECTS_MASTER, , FALSE)
			if (do_after(user, 35, target = src))
				new /obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough(src)
				to_chat(user, "<span class='notice'>You flatten the dough.</span>")
				qdel(src)
		else
			to_chat(user, "<span class='rose'>You cannot roll out the dough here! You need a table to do it.</span>")

// slicable into 3xdoughslices
/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough
	name = "flat dough"
	desc = "A flattened dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "flat dough"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/doughslice
	slices_num = 3

/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 6)

/obj/item/weapon/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "A building block of an impressive dish."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "doughslice"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/doughslice/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)

/obj/item/weapon/reagent_containers/food/snacks/bun
	name = "bun"
	desc = "A base for any self-respecting burger."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "bun"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/bun/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)

/obj/item/weapon/reagent_containers/food/snacks/bun/attackby(obj/item/weapon/W, mob/user)
	// Bun + meatball = burger
	if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/meatball))
		new /obj/item/weapon/reagent_containers/food/snacks/monkeyburger(src)
		to_chat(user, "<span class='notice'>You make a burger.</span>")
		qdel(W)
		qdel(src)

	// Bun + cutlet = hamburger
	else if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/cutlet))
		new /obj/item/weapon/reagent_containers/food/snacks/monkeyburger(src)
		to_chat(user, "<span class='notice'>You make a burger.</span>")
		qdel(W)
		qdel(src)

	// Bun + sausage = hotdog
	else if(istype(W,/obj/item/weapon/reagent_containers/food/snacks/sausage))
		new /obj/item/weapon/reagent_containers/food/snacks/hotdog(src)
		to_chat(user, "<span class='notice'>You make a hotdog.</span>")
		qdel(W)
		qdel(src)

// Burger + cheese wedge = cheeseburger
/obj/item/weapon/reagent_containers/food/snacks/monkeyburger/attackby(obj/item/weapon/reagent_containers/food/snacks/cheesewedge/W, mob/user)
	if(istype(W))// && !istype(src,/obj/item/weapon/reagent_containers/food/snacks/cheesewedge))
		new /obj/item/weapon/reagent_containers/food/snacks/cheeseburger(src)
		to_chat(user, "<span class='notice'>You make a cheeseburger.</span>")
		qdel(W)
		qdel(src)
		return
	else
		..()

// Human Burger + cheese wedge = cheeseburger
/obj/item/weapon/reagent_containers/food/snacks/human/burger/attackby(obj/item/weapon/reagent_containers/food/snacks/cheesewedge/W, mob/user)
	if(istype(W))
		new /obj/item/weapon/reagent_containers/food/snacks/cheeseburger(src)
		to_chat(user, "<span class='notice'>You make a cheeseburger.</span>")
		qdel(W)
		qdel(src)
		return
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/taco
	name = "taco"
	desc = "Take a bite!"
	icon_state = "taco"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/taco/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 7)
	reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet
	name = "raw cutlet"
	desc = "A thin piece of raw meat."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawcutlet"
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)

/obj/item/weapon/reagent_containers/food/snacks/cutlet
	name = "cutlet"
	desc = "A tasty meat slice."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "cutlet"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cutlet/atom_init()
	. = ..()
	reagents.add_reagent("protein", 1)

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/kitchenknife))
		new /obj/item/weapon/reagent_containers/food/snacks/raw_bacon(src)
		to_chat(user, "<span class='notice'>You make a bacon.</span>")
		qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/cutlet
	name = "cutlet"
	desc = "A tasty meat slice."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "cutlet"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cutlet/atom_init()
	. = ..()
	reagents.add_reagent("protein", 2)

/obj/item/weapon/reagent_containers/food/snacks/deepfryholder
	name = "Deep Fried Foods Holder Obj"
	desc = "If you can see this description the code for the deep fryer fucked up."
	icon_state = "deepfried_holder_icon"
	filling_color = "#ffad33"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/deepfryholder/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)

/obj/item/weapon/reagent_containers/food/snacks/rawmeatball
	name = "raw meatball"
	desc = "A raw meatball."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawmeatball"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/rawmeatball/atom_init()
	. = ..()
	reagents.add_reagent("protein", 2)

/obj/item/weapon/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Unrelated to dogs, maybe."
	icon_state = "hotdog"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/hotdog/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)

/obj/item/weapon/reagent_containers/food/snacks/flatbread
	name = "flatbread"
	desc = "Bland but filling."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "flatbread"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/flatbread/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 3)
	reagents.add_reagent("vitamin", 1)

// potato + knife = raw sticks
/obj/item/weapon/reagent_containers/food/snacks/grown/potato/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/kitchenknife))
		new /obj/item/weapon/reagent_containers/food/snacks/rawsticks(src)
		to_chat(user, "You cut the potato.")
		qdel(src)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/rawsticks
	name = "raw potato sticks"
	desc = "Raw fries, not very tasty."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawsticks"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/rawsticks/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 3)

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

/obj/item/weapon/reagent_containers/food/snacks/sliceable/turkey
	name = "Turkey"
	desc = "A traditional turkey served with stuffing."
	icon_state = "turkey"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/turkeyslice
	slices_num = 6
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/sliceable/turkey/atom_init()
	. = ..()
	reagents.add_reagent("protein", 24)
	reagents.add_reagent("nutriment", 18)
	reagents.add_reagent("vitamin", 5)

/obj/item/weapon/reagent_containers/food/snacks/turkeyslice
	name = "turkey serving"
	desc = "A serving of some tender and delicious turkey."
	icon_state = "turkeyslice"
	trash = /obj/item/trash/plate
	filling_color = "#b97a57"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/herbsalad
	name = "herb salad"
	desc = "A tasty salad with apples on top."
	icon_state = "herbsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76b87f"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/herbsalad/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 8)

/obj/item/weapon/reagent_containers/food/snacks/burrito
	name = "Burrito"
	desc = "Meat, beans, cheese, and rice wrapped up as an easy-to-hold meal."
	icon_state = "burrito"
	trash = /obj/item/trash/plate
	filling_color = "#a36a1f"
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/burrito/atom_init()
	. = ..()
	reagents.add_reagent("protein", 5)

/obj/item/weapon/reagent_containers/food/snacks/raw_bacon
	name = "raw bacon"
	desc = "It's fleshy and pink!"
	icon_state = "raw_bacon"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/raw_bacon/atom_init()
	. = ..()
	reagents.add_reagent("protein", 1)

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
	filling_color = "#7a3d11"
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/salmonsteak/atom_init()
	. = ..()
	reagents.add_reagent("protein", 4)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("blackpepper", 1)
	reagents.add_reagent("anti_toxin", 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge
	name = "Fudge"
	desc = "Chocolate fudge, a timeless classic treat."
	icon_state = "fudge"
	filling_color = "#7d5f46"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/atom_init()
	. = ..()
	reagents.add_reagent("cream", 2)
	reagents.add_reagent("nutriment",4)

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/cherry
	name = "Chocolate Cherry Fudge"
	desc = "Chocolate fudge surrounding sweet cherries. Good for tricking kids into eating some fruit."
	icon_state = "fudge_cherry"
	filling_color = "#7d5f46"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/cherry/atom_init()
	. = ..()
	reagents.add_reagent("cream", 3)
	reagents.add_reagent("nutriment", 6)

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/cookies_n_cream
	name = "Cookies 'n' Cream Fudge"
	desc = "An extra creamy fudge with bits of real chocolate cookie mixed in. Crunchy!"
	icon_state = "fudge_cookies_n_cream"
	filling_color = "#7d5f46"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/cookies_n_cream/atom_init()
	. = ..()
	reagents.add_reagent("cream", 5)
	reagents.add_reagent("nutriment", 4)

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/turtle
	name = "Turtle Fudge"
	desc = "Chocolate fudge with caramel and nuts. It doesn't contain real turtles, thankfully."
	icon_state = "fudge_turtle"
	filling_color = "#7d5f46"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/turtle/atom_init()
	. = ..()
	reagents.add_reagent("cream", 2)
	reagents.add_reagent("nutriment", 6)

/obj/item/weapon/reagent_containers/food/snacks/candy/toffee
	name = "Toffee"
	desc = "A hard, brittle candy with a distinctive taste."
	icon_state = "toffee"
	filling_color = "#7d5f46"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/toffee/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sugar", 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/caramel
	name = "Caramel"
	desc = "Chewy and dense, yet it practically melts in your mouth!"
	icon_state = "caramel"
	filling_color = "#db944d"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/caramel/atom_init()
	. = ..()
	reagents.add_reagent("cream", 2)
	reagents.add_reagent("sugar", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/candycane
	name = "candy cane"
	desc = "A festive mint candy cane."
	icon_state = "candycane"
	filling_color = "#f2f2f2"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/candycane/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/taffy
	name = "Saltwater Taffy"
	desc = "Old fashioned saltwater taffy. Chewy!"
	icon_state = "candy1"
	filling_color = "#7d5f46"
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/taffy/atom_init()
	. = ..()
	icon_state = pick("candy1", "candy2", "candy3", "candy4", "candy5")
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("sugar", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/nougat
	name = "Nougat"
	desc = "A soft, chewy candy commonly found in candybars."
	icon_state = "nougat"
	filling_color = "#7d5f46"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/nougat/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sugar", 3)

///////////////////////////////////////////
// COTTONS :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_plain"
	filling_color = "#ffffff"
	trash = /obj/item/weapon/c_tube
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 15)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/red
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_red"
	filling_color = "#801e28"
	trash = /obj/item/weapon/c_tube
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/red/atom_init()
	. = ..()
	reagents.add_reagent("cherryjelly", 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/blue
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_blue"
	filling_color = "#863333"
	trash = /obj/item/weapon/c_tube
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/blue/atom_init()
	. = ..()
	reagents.add_reagent("berryjuice", 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/green
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_green"
	filling_color = "#365e30"
	trash = /obj/item/weapon/c_tube
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/green/atom_init()
	. = ..()
	reagents.add_reagent("limejuice", 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/yellow
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_yellow"
	filling_color = "#863333"
	trash = /obj/item/weapon/c_tube
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/yellow/atom_init()
	. = ..()
	reagents.add_reagent("lemonjuice", 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/orange
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_orange"
	filling_color = "#e78108"
	trash = /obj/item/weapon/c_tube
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/orange/atom_init()
	. = ..()
	reagents.add_reagent("orangejuice", 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/purple
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_purple"
	filling_color = "#993399"
	trash = /obj/item/weapon/c_tube
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/purple/atom_init()
	. = ..()
	reagents.add_reagent("grapejuice", 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/pink
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_pink"
	filling_color = "#863333"
	trash = /obj/item/weapon/c_tube
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/pink/atom_init()
	. = ..()
	reagents.add_reagent("watermelonjuice", 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/rainbow
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_rainbow"
	filling_color = "#c8a5dc"
	trash = /obj/item/weapon/c_tube
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/rainbow/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 20)
	reagents.add_reagent("psilocybin", 1)

///////////////////////////////////////////
// GUM and SUCKERS :D :>
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear
	name = "gummy bear"
	desc = "A small edible bear. It's squishy and chewy!"
	icon_state = "gbear"
	filling_color = "#ffffff"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm
	name = "gummy worm"
	desc = "An edible worm, made from gelatin."
	icon_state = "gworm"
	filling_color = "#ffffff"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas."
	icon_state = "jbean"
	filling_color = "#ffffff"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/jawbreaker
	name = "jawbreaker"
	desc = "An unbelievably hard candy. The name is fitting."
	icon_state = "jawbreaker"
	filling_color = "#ed0758"
	bitesize = 0.1	//this is gonna take a while, you'll be working at this all shift.

/obj/item/weapon/reagent_containers/food/snacks/candy/jawbreaker/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/cash
	name = "candy cash"
	desc = "Not legal tender. Tasty though."
	icon_state = "candy_cash"
	filling_color = "#302000"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/candy/cash/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("hot_coco", 4)

/obj/item/weapon/reagent_containers/food/snacks/candy/coin
	name = "chocolate coin"
	desc = "Probably won't work in the vending machines."
	icon_state = "choc_coin"
	filling_color = "#302000"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/coin/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("hot_coco",4)

/obj/item/weapon/reagent_containers/food/snacks/candy/gum
	name = "bubblegum"
	desc = "Chewy!"
	icon_state = "bubblegum"
	filling_color = "#ff7495"
	bitesize = 0.2

/obj/item/weapon/reagent_containers/food/snacks/candy/gum/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker
	name = "sucker"
	desc = "For being such a good sport!"
	icon_state = "sucker"
	filling_color = "#ffffff"
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 10)

///////////////////////////////////////////
// BEAR GYMS :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/red
	name = "gummy bear"
	desc = "A small edible bear. It's red!"
	icon_state = "gbear_red"
	filling_color = "#801e28"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/red/atom_init()
	. = ..()
	reagents.add_reagent("cherryjelly", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/blue
	name = "gummy bear"
	desc = "A small edible bear. It's blue!"
	icon_state = "gbear_blue"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/blue/atom_init()
	. = ..()
	reagents.add_reagent("berryjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/green
	name = "gummy bear"
	desc = "A small edible bear. It's green!"
	icon_state = "gbear_green"
	filling_color = "#365e30"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/green/atom_init()
	. = ..()
	reagents.add_reagent("limejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/yellow
	name = "gummy bear"
	desc = "A small edible bear. It's yellow!"
	icon_state = "gbear_yellow"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/yellow/atom_init()
	. = ..()
	reagents.add_reagent("lemonjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/orange
	name = "gummy bear"
	desc = "A small edible bear. It's orange!"
	icon_state = "gbear_orange"
	filling_color = "#e78108"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/orange/atom_init()
	. = ..()
	reagents.add_reagent("orangejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/purple
	name = "gummy bear"
	desc = "A small edible bear. It's purple!"
	icon_state = "gbear_purple"
	filling_color = "#993399"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/purple/atom_init()
	. = ..()
	reagents.add_reagent("grapejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/wtf
	name = "gummy bear"
	desc = "A small bear. Wait... what?"
	icon_state = "gbear_wtf"
	filling_color = "#60a584"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/wtf/atom_init()
	. = ..()
	reagents.add_reagent("space_drugs", 2)

///////////////////////////////////////////
// WORM GYMS :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/red
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's red!"
	icon_state = "gworm_red"
	filling_color = "#801e28"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/red/atom_init()
	. = ..()
	reagents.add_reagent("cherryjelly", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/blue
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's blue!"
	icon_state = "gworm_blue"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/blue/atom_init()
	. = ..()
	reagents.add_reagent("berryjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/green
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's green!"
	icon_state = "gworm_green"
	filling_color = "#365e30"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/green/atom_init()
	. = ..()
	reagents.add_reagent("limejuice", 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/yellow
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's yellow!"
	icon_state = "gworm_yellow"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/yellow/atom_init()
	. = ..()
	reagents.add_reagent("lemonjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/orange
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's orange!"
	icon_state = "gworm_orange"
	filling_color = "#e78108"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/orange/atom_init()
	. = ..()
	reagents.add_reagent("orangejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/purple
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's purple!"
	icon_state = "gworm_purple"
	filling_color = "#993399"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/purple/atom_init()
	. = ..()
	reagents.add_reagent("grapejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/wtf
	name = "gummy worm"
	desc = "An edible worm. Did it just move?"
	icon_state = "gworm_wtf"
	filling_color = "#60a584"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/wtf/atom_init()
	. = ..()
	reagents.add_reagent("space_drugs", 2)

///////////////////////////////////////////
// JELLY BEANS :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/red
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's red!"
	icon_state = "jbean_red"
	filling_color = "#801e28"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/red/atom_init()
	. = ..()
	reagents.add_reagent("cherryjelly", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/blue
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's blue!"
	icon_state = "jbean_blue"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/blue/atom_init()
	. = ..()
	reagents.add_reagent("berryjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/green
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's green!"
	icon_state = "jbean_green"
	filling_color = "#365e30"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/green/atom_init()
	. = ..()
	reagents.add_reagent("limejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/yellow
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's yellow!"
	icon_state = "jbean_yellow"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/yellow/atom_init()
	. = ..()
	reagents.add_reagent("lemonjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/orange
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's orange!"
	icon_state = "jbean_orange"
	filling_color = "#e78108"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/orange/atom_init()
	. = ..()
	reagents.add_reagent("orangejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/purple
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's purple!"
	icon_state = "jbean_purple"
	filling_color = "#993399"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/purple/atom_init()
	. = ..()
	reagents.add_reagent("grapejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/chocolate
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's chocolate!"
	icon_state = "jbean_choc"
	filling_color = "#302000"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/chocolate/atom_init()
	. = ..()
	reagents.add_reagent("hot_coco",2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/popcorn
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's popcorn flavored!"
	icon_state = "jbean_popcorn"
	filling_color = "#664330"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/popcorn/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/cola
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's Cola flavored!"
	icon_state = "jbean_cola"
	filling_color = "#102000"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/cola/atom_init()
	. = ..()
	reagents.add_reagent("cola", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/drgibb
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's Dr. Gibb flavored!"
	icon_state = "jbean_cola"
	filling_color = "#102000"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/drgibb/atom_init()
	. = ..()
	reagents.add_reagent("dr_gibb", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/coffee
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's Coffee flavored!"
	icon_state = "jbean_choc"
	filling_color = "#482000"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/coffee/atom_init()
	. = ..()
	reagents.add_reagent("coffee", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/wtf
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. You aren't sure what color it is."
	icon_state = "jbean_wtf"
	filling_color = "#60a584"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/wtf/atom_init()
	. = ..()
	reagents.add_reagent("space_drugs", 2)

///////////////////////////////////////////
// CANDYBARS! :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/candybar
	name = "candy bar"
	desc = "Nougat, love it or hate it."
	icon_state = "candy"
	trash = /obj/item/trash/candy
	filling_color = "#7d5f46"

/obj/item/weapon/reagent_containers/food/snacks/candy/rice
	name = "Asteroid Crunch Bar"
	desc = "Crunchy rice deposits in delicious chocolate! A favorite of miners galaxy-wide."
	icon_state = "asteroidcrunch"
	trash = /obj/item/trash/candy
	filling_color = "#7d5f46"

/obj/item/weapon/reagent_containers/food/snacks/candy/yumbaton
	name = "Yum-baton Bar"
	desc = "Chocolate and toffee in the shape of a baton. Security sure knows how to pound these down!"
	icon_state = "yumbaton"
	filling_color = "#7d5f46"

/obj/item/weapon/reagent_containers/food/snacks/candy/malper
	name = "Malper Bar"
	desc = "A chocolate syringe filled with a caramel injection. Just what the doctor ordered!"
	icon_state = "malper"
	filling_color = "#7d5f46"

/obj/item/weapon/reagent_containers/food/snacks/candy/caramel_nougat
	name = "Toxins Test Bar"
	desc = "An explosive combination of chocolate, caramel, and nougat. Research has never been so tasty!"
	icon_state = "toxinstest"
	filling_color = "#7d5f46"

/obj/item/weapon/reagent_containers/food/snacks/candy/toolerone
	name = "Tool-erone Bar"
	desc = "Chocolate-covered nougat, shaped like a wrench. Great for an engineer on the go!"
	icon_state = "toolerone"
	filling_color = "#7d5f46"

///////////////////////////////////////////
// SUCKERS! :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/red
	name = "sucker"
	desc = "For being such a good sport! It's red!"
	icon_state = "sucker_red"
	filling_color = "#801e28"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/red/atom_init()
	. = ..()
	reagents.add_reagent("cherryjelly", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/blue
	name = "sucker"
	desc = "For being such a good sport! It's blue!"
	icon_state = "sucker_blue"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/blue/atom_init()
	. = ..()
	reagents.add_reagent("berryjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/green
	name = "sucker"
	desc = "For being such a good sport! It's green!"
	icon_state = "sucker_green"
	filling_color = "#365e30"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/green/atom_init()
	. = ..()
	reagents.add_reagent("limejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/yellow
	name = "sucker"
	desc = "For being such a good sport! It's yellow!"
	icon_state = "sucker_yellow"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/yellow/atom_init()
	. = ..()
	reagents.add_reagent("lemonjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/orange
	name = "sucker"
	desc = "For being such a good sport! It's orange!"
	icon_state = "sucker_orange"
	filling_color = "#e78108"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/orange/atom_init()
	. = ..()
	reagents.add_reagent("orangejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/purple
	name = "sucker"
	desc = "For being such a good sport! It's purple!"
	icon_state = "sucker_purple"
	filling_color = "#993399"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/purple/atom_init()
	. = ..()
	reagents.add_reagent("grapejuice", 2)

///////////////////////////////////////////
// WORM GYMS :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/red
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's red!"
	icon_state = "gworm_red"
	filling_color = "#801e28"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/red/atom_init()
	. = ..()
	reagents.add_reagent("cherryjelly", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/blue
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's blue!"
	icon_state = "gworm_blue"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/blue/atom_init()
	. = ..()
	reagents.add_reagent("berryjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/green
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's green!"
	icon_state = "gworm_green"
	filling_color = "#365e30"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/green/atom_init()
	. = ..()
	reagents.add_reagent("limejuice", 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/yellow
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's yellow!"
	icon_state = "gworm_yellow"
	filling_color = "#863333"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/yellow/atom_init()
	. = ..()
	reagents.add_reagent("lemonjuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/orange
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's orange!"
	icon_state = "gworm_orange"
	filling_color = "#e78108"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/orange/atom_init()
	. = ..()
	reagents.add_reagent("orangejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/purple
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's purple!"
	icon_state = "gworm_purple"
	filling_color = "#993399"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/purple/atom_init()
	. = ..()
	reagents.add_reagent("grapejuice", 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/wtf
	name = "gummy worm"
	desc = "An edible worm. Did it just move?"
	icon_state = "gworm_wtf"
	filling_color = "#60a584"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/wtf/atom_init()
	. = ..()
	reagents.add_reagent("space_drugs", 2)

///////////////////////////////////////////
// Ectoplasm o.O
///////////////////////////////////////////
/obj/item/weapon/reagent_containers/food/snacks/ectoplasm
	name = "ectoplasm"
	desc = "Spooky! Do not consume under any circumstances."
	gender = PLURAL
	icon = 'icons/obj/wizard.dmi'
	icon_state = "ectoplasm"

/obj/item/weapon/reagent_containers/food/snacks/ectoplasm/atom_init()
	. = ..()
	reagents.add_reagent("ectoplasm", 5)

/obj/item/weapon/reagent_containers/food/snacks/fries/cardboard
	icon_state = "fries_cardboard"
	trash = /obj/item/trash/fries

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries/cardboard
	icon_state = "cheesyfries_cardboard"
	trash = /obj/item/trash/fries
