//Food items that are eaten normally and don't leave anything behind.
/obj/item/weapon/reagent_containers/food/snacks
	var/eat_sound = 'sound/items/eatfood.ogg'
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

/obj/item/weapon/reagent_containers/food/snacks/attack(mob/living/M, mob/user, def_zone)
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

				M.log_combat(user, "fed [name], reagents: [reagentlist(src)] (INTENT: [uppertext(user.a_intent)])")

				user.visible_message("<span class='rose'>[user] feeds [M] [src].</span>")

			else
				to_chat(user, "This creature does not seem to have a mouth!</span>")
				return


		if(reagents)								//Handle ingestion of the reagent.
			playsound(M, eat_sound, VOL_EFFECTS_MASTER, rand(20, 50))
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

/obj/item/weapon/reagent_containers/food/snacks/afterattack(atom/target, mob/user, proximity, params)
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

/obj/item/weapon/reagent_containers/food/snacks/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/storage))
		return ..() // -> item/attackby()

	add_fingerprint(user)
	if(istype(I, /obj/item/weapon/kitchen/utensil))
		var/obj/item/weapon/kitchen/utensil/U = I

		if(U.contents.len >= U.max_contents)
			to_chat(user, "<span class='warning'>You cannot fit anything else on your [U].")
			return

		user.visible_message( \
			"[user] scoops up some [src] with \the [U]!", \
			"<span class='notice'>You scoop up some [src] with \the [U]!</span>" \
		)

		bitecount++
		U.cut_overlays()
		var/image/IM = new(U.icon, "loadedfood")
		IM.color = filling_color
		U.add_overlay(IM)

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
		return

	try_slice(I, user)

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
		if(M.layer == MOB_LAYER)
			N.visible_message("<span class ='notice'><b>[N]</b> nibbles away at [src].</span>", "<span class='notice'>You nibble away at [src].</span>")
			N.health = min(N.health + 1, N.maxHealth)
			reagents.remove_any(0.5 * bitesize)
			if(reagents.total_volume <= 0)
				N.visible_message("<span class='notice'><b>[N]</b> just ate \the [src]!</span>", "<span class='notice'>You just ate \the [src], [pick("delicious", "wonderful", "smooth", "disgusting")]!</span>")
				qdel(src)
		else
			to_chat(N, text("<span class='notice'>You are unable to nibble away at \the [src] while being hidden.</span>"))



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
	list_reagents = list("nutriment" = 8, "doctorsdelight" = 8, "vitamin" = 6)

/obj/item/weapon/reagent_containers/food/snacks/candy
	name = "candy"
	desc = "Nougat, love it or hate it."
	filling_color = "#7d5f46"
	bitesize = 2
	list_reagents = list("nutriment" = 1, "sugar" = 3)

/obj/item/weapon/reagent_containers/food/snacks/candy/donor
	name = "Donor Candy"
	desc = "A little treat for blood donors."
	trash = /obj/item/trash/candy
	bitesize = 5
	list_reagents = list("nutriment" = 10, "sugar" = 3)

/obj/item/weapon/reagent_containers/food/snacks/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Cannot be stored in a detective's hat, alas."
	icon_state = "candy_corn"
	filling_color = "#fffcb0"
	bitesize = 2
	list_reagents = list("nutriment" = 4, "sugar" = 2)

/obj/item/weapon/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips"
	trash = /obj/item/trash/chips
	filling_color = "#e8c31e"
	bitesize = 1
	list_reagents = list("nutriment"= 3, "sodiumchloride" = 1, "sugar" = 1)

/obj/item/weapon/reagent_containers/food/snacks/cookie
	name = "cookie"
	desc = "COOKIE!!!"
	icon_state = "COOKIE!!!"
	filling_color = "#dbc94f"
	bitesize = 1
	list_reagents = list("nutriment" = 3)

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
	name = "Chocolate Bar"
	desc = "Such sweet, fattening food."
	icon_state = "chocolatebar"
	filling_color = "#7d5f46"
	bitesize = 2
	list_reagents = list("nutriment" = 2, "sugar" = 2, "coco" = 2)

/obj/item/weapon/reagent_containers/food/snacks/chocolateegg
	name = "Chocolate Egg"
	desc = "Such sweet, fattening food."
	icon_state = "chocolateegg"
	filling_color = "#7d5f46"
	bitesize = 2
	list_reagents = list("nutriment" = 4, "sugar" = 2, "coco" = 2, "egg" = 5)

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
	list_reagents = list("nutriment" = 3, "sprinkles" = 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/normal/atom_init()
	. = ..()
	if(prob(30))
		icon_state = "donut2"
		name = "frosted donut"

/obj/item/weapon/reagent_containers/food/snacks/donut/chaos
	name = "Chaos Donut"
	desc = "Like life, it never quite tastes the same."
	icon_state = "donut1"
	filling_color = "#ed11e6"
	bitesize = 10
	list_reagents = list("nutriment" = 2, "sprinkles" = 1)

/obj/item/weapon/reagent_containers/food/snacks/donut/chaos/atom_init()
	. = ..()
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

/obj/item/weapon/reagent_containers/food/snacks/donut/jelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ed1169"
	bitesize = 5
	list_reagents = list("nutriment" = 3, "sprinkles" = 3, "berryjuice" = 5)

/obj/item/weapon/reagent_containers/food/snacks/donut/jelly/atom_init()
	. = ..()
	if(prob(30))
		src.icon_state = "jdonut2"
		src.name = "Frosted Jelly Donut"

/obj/item/weapon/reagent_containers/food/snacks/donut/slimejelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ed1169"
	bitesize = 5
	list_reagents = list("nutriment" = 3, "sprinkles" = 3, "slimejelly" = 5)

/obj/item/weapon/reagent_containers/food/snacks/donut/slimejelly/atom_init()
	. = ..()
	if(prob(30))
		src.icon_state = "jdonut2"
		src.name = "Frosted Jelly Donut"

/obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	filling_color = "#ed1169"
	bitesize = 5
	list_reagents = list("nutriment" = 3, "sprinkles" = 3, "cherryjelly" = 5)

/obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly/atom_init()
	. = ..()
	if(prob(30))
		src.icon_state = "jdonut2"
		src.name = "Frosted Jelly Donut"

/obj/item/weapon/reagent_containers/food/snacks/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"
	filling_color = "#fdffd1"
	list_reagents = list("nutriment" = 1, "egg" = 5)

/obj/item/weapon/reagent_containers/food/snacks/egg/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	new /obj/effect/decal/cleanable/egg_smudge(loc)
	if(prob(13))
		if(global.chicken_count < MAX_CHICKENS)
			new /mob/living/simple_animal/chick(loc)
	reagents.reaction(hit_atom, TOUCH)
	visible_message("<span class='rose'>\The [src.name] has been squashed.</span>", "<span class='rose'>You hear a smack.</span>")
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/egg/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = I
		var/clr = C.colourName

		if(!(clr in list("blue","green","mime","orange","purple","rainbow","red","yellow")))
			to_chat(usr, "<span class='info'>The egg refuses to take on this color!</span>")
			return

		to_chat(usr, "<span class='notice'>You color \the [src] [clr].</span>")
		icon_state = "egg-[clr]"
		item_color = clr
	else
		return ..()

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
	list_reagents = list("nutriment" = 3, "sodiumchloride" = 1, "blackpepper" = 1, "egg" = 5)

/obj/item/weapon/reagent_containers/food/snacks/boiledegg
	name = "Boiled egg"
	desc = "A hard boiled egg."
	icon_state = "egg"
	filling_color = "#ffffff"
	list_reagents = list("nutriment" = 2, "vitamin" = 1, "egg" = 5)

/obj/item/weapon/reagent_containers/food/snacks/appendix
//yes, this is the same as meat. I might do something different in future
	name = "appendix"
	desc = "An appendix which looks perfectly healthy."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "appendix"
	filling_color = "#e00d34"
	bitesize = 3
	list_reagents = list("protein" = 3, "vitamin" = 2)

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
	list_reagents = list("plantmatter" = 3)

/obj/item/weapon/reagent_containers/food/snacks/tofurkey
	name = "Tofurkey"
	desc = "A fake turkey made from tofu."
	icon_state = "tofurkey"
	filling_color = "#fffee0"
	bitesize = 3
	list_reagents = list("nutriment" = 12, "stoxin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/stuffing
	name = "Stuffing"
	desc = "Moist, peppery breadcrumbs for filling the body cavities of dead birds. Dig in!"
	icon_state = "stuffing"
	filling_color = "#c9ac83"
	bitesize = 1
	list_reagents = list("nutriment" = 3)

/obj/item/weapon/reagent_containers/food/snacks/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat"
	icon_state = "fishfillet"
	filling_color = "#ffdefe"
	bitesize = 6
	list_reagents = list("protein" = 3, "carpotoxin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/fishfingers
	name = "Fish Fingers"
	desc = "A finger of fish."
	icon_state = "fishfingers"
	filling_color = "#ffdefe"
	bitesize = 3
	list_reagents = list("protein" = 4, "carpotoxin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice
	name = "huge mushroom slice"
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"
	filling_color = "#e0d7c5"
	bitesize = 6
	list_reagents = list("plantmatter" = 3, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato"
	icon_state = "tomatomeat"
	filling_color = "#db0000"
	bitesize = 6
	list_reagents = list("protein" = 2)

/obj/item/weapon/reagent_containers/food/snacks/bearmeat
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	filling_color = "#db0000"
	bitesize = 3
	list_reagents = list("protein" = 12, "hyperzine" = 5, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/xenomeat
	name = "meat"
	desc = "A slab of meat."
	icon_state = "xenomeat"
	filling_color = "#43de18"
	bitesize = 6
	list_reagents = list("protein" = 3, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/spidermeat
	name = "spider meat"
	desc = "A slab of spider meat."
	icon_state = "spidermeat"
	bitesize = 3
	list_reagents = list("protein" = 3, "toxin" = 2, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/spiderleg
	name = "spider leg"
	desc = "A still twitching leg of a giant spider... you don't really want to eat this, do you?"
	icon_state = "spiderleg"
	list_reagents = list("protein" = 2, "toxin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/meatball
	name = "meatball"
	desc = "A great meal all round."
	icon_state = "meatball"
	filling_color = "#db0000"
	bitesize = 2
	list_reagents = list("protein" = 4, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/sausage
	name = "Sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	filling_color = "#db0000"
	bitesize = 2
	list_reagents = list("protein" = 6, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	name = "Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	filling_color = "#dedeab"
	var/warm = 0
	list_reagents = list("nutriment" = 4)

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
	list_reagents = list("nutriment" = 2, "protein" = 4, "alkysine" = 6)

/obj/item/weapon/reagent_containers/food/snacks/ghostburger
	name = "Ghost Burger"
	desc = "Spooky! It doesn't look very filling."
	icon_state = "ghostburger"
	filling_color = "#fff2ff"
	bitesize = 2
	list_reagents = list("nutriment" = 6, "ectoplasm" = 1)

/obj/item/weapon/reagent_containers/food/snacks/human
	var/hname = ""
	var/job = null
	filling_color = "#d63c3c"

/obj/item/weapon/reagent_containers/food/snacks/human/burger
	name = "-burger"
	desc = "A bloody burger."
	icon_state = "hburger"
	bitesize = 2
	list_reagents = list("nutriment" = 2, "protein" = 4, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/cheeseburger
	name = "cheeseburger"
	desc = "The cheese adds a good flavor."
	icon_state = "cheeseburger"
	list_reagents = list("nutriment" = 4, "cheese" = 4, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/monkeyburger
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	filling_color = "#d63c3c"
	bitesize = 2
	list_reagents = list("nutriment" = 2, "protein" = 4, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/fishburger
	name = "Fillet -o- Carp Sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon_state = "fishburger"
	filling_color = "#ffdefe"
	bitesize = 3
	list_reagents = list("protein" = 6, "carpotoxin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/tofuburger
	name = "Tofu Burger"
	desc = "What.. is that meat?"
	icon_state = "tofuburger"
	filling_color = "#fffee0"
	bitesize = 2
	list_reagents = list("plantmatter" = 6, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	filling_color = "#cccccc"
	bitesize = 2
	list_reagents = list("nutriment" = 6)

/obj/item/weapon/reagent_containers/food/snacks/roburger/atom_init()
	. = ..()
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
	list_reagents = list("nanites" = 100, "nutriment" = 6, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/xenoburger
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	filling_color = "#43de18"
	bitesize = 2
	list_reagents = list("protein" = 6, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/clownburger
	name = "Clown Burger"
	desc = "This tastes funny... And HONKS!"
	icon_state = "clownburger"
	filling_color = "#ff00ff"
	bitesize = 2
	var/cooldown = FALSE
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

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
	list_reagents = list("nutriment" = 6)

/obj/item/weapon/reagent_containers/food/snacks/omelette
	name = "Omelette Du Fromage"
	desc = "That's all you can say!"
	icon_state = "omelette"
	trash = /obj/item/trash/plate
	filling_color = "#fff9a8"
	bitesize = 1
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/muffin
	name = "Muffin"
	desc = "A delicious and spongy little cake"
	icon_state = "muffin"
	filling_color = "#e0cf9b"
	bitesize = 2
	list_reagents = list("nutriment" = 6)

/obj/item/weapon/reagent_containers/food/snacks/pie
	name = "Banana Cream Pie"
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/plate
	filling_color = "#fbffb8"
	bitesize = 3
	list_reagents = list("plantmatter" = 6, "banana" = 5, "vitamin" = 2)

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
	list_reagents = list("plantmatter" = 10, "berryjuice" = 5)

/obj/item/weapon/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles."
	icon_state = "waffles"
	trash = /obj/item/trash/waffles
	filling_color = "#e6deb5"
	bitesize = 2
	list_reagents = list("nutriment" = 8, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/eggplantparm
	name = "Eggplant Parmigiana"
	desc = "The only good recipe for eggplant."
	icon_state = "eggplantparm"
	trash = /obj/item/trash/plate
	filling_color = "#4d2f5e"
	bitesize = 2
	list_reagents = list("nutriment" = 6, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/soylentgreen
	name = "Soylent Green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles
	filling_color = "#b8e6b5"
	bitesize = 2
	list_reagents = list("protein" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/soylenviridians
	name = "Soylen Virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles
	filling_color = "#e6fa61"
	bitesize = 2
	list_reagents = list("plantmatter" = 10, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/meatpie
	name = "Meat-pie"
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	trash = /obj/item/trash/plate
	filling_color = "#948051"
	bitesize = 2
	list_reagents = list("protein" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/tofupie
	name = "Tofu-pie"
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	trash = /obj/item/trash/plate
	filling_color = "#fffee0"
	bitesize = 2
	list_reagents = list("plantmatter" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/amanita_pie
	name = "amanita pie"
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	filling_color = "#ffcccc"
	bitesize = 3
	list_reagents = list("plantmatter" = 5, "amatoxin" = 3, "psilocybin" = 1, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/plump_pie
	name = "plump pie"
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	filling_color = "#b8279b"
	bitesize = 2
	list_reagents = list("nutriment" = 8, "tricordrazine" = 5, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/xemeatpie
	name = "Xeno-pie"
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	trash = /obj/item/trash/plate
	filling_color = "#43de18"
	bitesize = 2
	list_reagents = list("protein" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/wingfangchu
	name = "Wing Fang Chu"
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#43de18"
	bitesize = 2
	list_reagents = list("protein" = 6, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/human/kabob
	name = "-kabob"
	icon_state = "kabob"
	desc = "A human meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#a85340"
	bitesize = 2
	list_reagents = list("protein" = 8)

/obj/item/weapon/reagent_containers/food/snacks/kabob
	name = "Meat-kabob"
	icon_state = "kabob"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#a85340"
	bitesize = 2
	list_reagents = list("protein" = 8)

/obj/item/weapon/reagent_containers/food/snacks/tofukabob
	name = "Tofu-kabob"
	icon_state = "kabob"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#fffee0"
	bitesize = 2
	list_reagents = list("plantmatter" = 8)

/obj/item/weapon/reagent_containers/food/snacks/cubancarp
	name = "Cuban Carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate
	filling_color = "#e9adff"
	bitesize = 3
	list_reagents = list("protein" = 6, "carpotoxin" = 3, "capsaicin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/popcorn
	name = "Popcorn"
	desc = "Now let's find some cinema."
	icon_state = "popcorn"
	trash = /obj/item/trash/popcorn
	var/unpopped = 0
	filling_color = "#fffad4"
	bitesize = 0.1 //this snack is supposed to be eating during looooong time. And this it not dinner food! --rastaf0
	list_reagents = list("nutriment" = 2)

/obj/item/weapon/reagent_containers/food/snacks/popcorn/atom_init()
	. = ..()
	unpopped = rand(1,10)

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
	list_reagents = list("protein" = 3, "sugar" = 1)

/obj/item/weapon/reagent_containers/food/snacks/no_raisin
	name = "4no Raisins"
	icon_state = "4no_raisins"
	desc = "Best raisins in the universe. Not sure why."
	trash = /obj/item/trash/raisins
	filling_color = "#343834"
	list_reagents = list("plantmatter" = 2, "sugar" = 4)

/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie
	name = "Space Twinkie"
	icon_state = "space_twinkie"
	desc = "Guaranteed to survive longer then you will."
	filling_color = "#ffe591"
	bitesize = 2
	list_reagents = list("sugar" = 4)

/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers
	name = "Cheesie Honkers"
	icon_state = "cheesie_honkers"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	trash = /obj/item/trash/cheesie
	filling_color = "#ffa305"
	bitesize = 2
	list_reagents = list("nutriment" = 1, "sugar" = 3)

/obj/item/weapon/reagent_containers/food/snacks/chinese/chowmein
	name = "chow mein"
	desc = "What is in this anyways?"
	icon_state = "chinese1"
	trash = /obj/item/trash/chinese1
	list_reagents = list("nutriment" = 1, "beans" = 3, "sugar" = 2)

/obj/item/weapon/reagent_containers/food/snacks/chinese/sweetsourchickenball
	name = "Sweet & Sour Chicken Balls"
	desc = "Is this chicken cooked? The odds are better than wok paper scissors."
	icon_state = "chickenball"
	trash = /obj/item/trash/snack_bowl
	list_reagents = list("nutriment" = 2, "sugar" = 2)

/obj/item/weapon/reagent_containers/food/snacks/chinese/tao
	name = "Admiral Yamamoto carp"
	desc = "Tastes like chicken."
	icon_state = "chinese2"
	trash = /obj/item/trash/chinese2
	list_reagents = list("nutriment" = 1, "protein" = 1, "sugar" = 4)

/obj/item/weapon/reagent_containers/food/snacks/chinese/newdles
	name = "chinese newdles"
	desc = "Made fresh, weekly!"
	icon_state = "chinese3"
	trash = /obj/item/trash/chinese3
	list_reagents = list("nutriment" = 1, "sugar" = 3)

/obj/item/weapon/reagent_containers/food/snacks/chinese/rice
	name = "fried rice"
	desc = "A timeless classic."
	icon_state = "chinese4"
	trash = /obj/item/trash/chinese4
	list_reagents = list("nutriment" = 1, "sugar" = 2, "rice" = 3)

/obj/item/weapon/reagent_containers/food/snacks/syndicake
	name = "Syndi-Cakes"
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	filling_color = "#ff5d05"
	bitesize = 3
	trash = /obj/item/trash/syndi_cakes
	list_reagents = list("nutriment" = 4, "syndicream" = 5)

/obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato
	name = "Loaded Baked Potato"
	desc = "Totally baked."
	icon_state = "loadedbakedpotato"
	filling_color = "#9c7a68"
	bitesize = 2
	list_reagents = list("nutriment" = 6)

/obj/item/weapon/reagent_containers/food/snacks/fries
	name = "Space Fries"
	desc = "AKA: French Fries, Freedom Fries, etc."
	icon_state = "fries"
	trash = /obj/item/trash/plate
	filling_color = "#eddd00"
	bitesize = 2
	list_reagents = list("nutriment" = 4)

/obj/item/weapon/reagent_containers/food/snacks/soydope
	name = "Soy Dope"
	desc = "Dope from a soy."
	icon_state = "soydope"
	trash = /obj/item/trash/plate
	filling_color = "#c4bf76"
	bitesize = 2
	list_reagents = list("nutriment" = 2)

/obj/item/weapon/reagent_containers/food/snacks/spagetti
	name = "Spaghetti"
	desc = "A bundle of raw spaghetti."
	icon_state = "spagetti"
	filling_color = "#eddd00"
	bitesize = 1
	list_reagents = list("nutriment" = 1, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries
	name = "Cheesy Fries"
	desc = "Fries. Covered in cheese. Duh."
	icon_state = "cheesyfries"
	trash = /obj/item/trash/plate
	filling_color = "#eddd00"
	bitesize = 2
	list_reagents = list("nutriment" = 6)

/obj/item/weapon/reagent_containers/food/snacks/fortunecookie
	name = "Fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"
	filling_color = "#e8e79e"
	bitesize = 2
	list_reagents = list("nutriment" = 3)

/obj/item/weapon/reagent_containers/food/snacks/badrecipe
	name = "Burned mess"
	desc = "Someone should be demoted from chef for this."
	icon_state = "badrecipe"
	filling_color = "#211f02"
	bitesize = 2
	list_reagents = list("toxin" = 1, "carbon" = 3)

/obj/item/weapon/reagent_containers/food/snacks/meatsteak
	name = "Meat steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatstake"
	trash = /obj/item/trash/plate
	filling_color = "#7a3d11"
	bitesize = 3
	list_reagents = list("protein" = 6, "sodiumchloride" = 1, "blackpepper" = 1)

/obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff
	name = "Spacy Liberty Duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook."
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#42b873"
	bitesize = 3
	list_reagents = list("plantmatter" = 6, "psilocybin" = 6)

/obj/item/weapon/reagent_containers/food/snacks/amanitajelly
	name = "Amanita Jelly"
	desc = "Looks curiously toxic."
	icon_state = "amanitajelly"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#ed0758"
	bitesize = 3
	list_reagents = list("plantmatter" = 6, "amatoxin" = 6, "psilocybin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel
	name = "Poppy pretzel"
	desc = "It's all twisted up!"
	icon_state = "poppypretzel"
	bitesize = 2
	filling_color = "#916e36"
	bitesize = 2
	list_reagents = list("nutriment" = 5)

//SOUPS

/obj/item/weapon/reagent_containers/food/snacks/soup
	eat_sound = 'sound/items/drink.ogg'

/obj/item/weapon/reagent_containers/food/snacks/soup/beetsoup
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#fac9ff"
	bitesize = 2
	list_reagents = list("nutriment" = 8, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/soup/beetsoup/atom_init()
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

/obj/item/weapon/reagent_containers/food/snacks/soup/stew
	name = "Stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	filling_color = "#9e673a"
	bitesize = 10
	list_reagents = list("nutriment" = 10, "tomatojuice" = 5, "imidazoline" = 5, "water" = 5, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/soup/mushroomsoup
	name = "chantrelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#e386bf"
	bitesize = 3
	list_reagents = list("plantmatter" = 8, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/soup/milosoup
	name = "Milosoup"
	desc = "The universes best soup! Yum!!!"
	icon_state = "milosoup"
	trash = /obj/item/trash/snack_bowl
	bitesize = 4
	list_reagents = list("nutriment" = 8, "water" = 5, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/soup/meatballsoup
	name = "Meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#785210"
	bitesize = 5
	list_reagents = list("protein" = 8, "water" = 5, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/soup/slimesoup
	name = "slime soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup"
	filling_color = "#c4dba0"
	bitesize = 5
	list_reagents = list("nutriment" = 4, "slimejelly" = 5, "water" = 10, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/soup/bloodsoup
	name = "Tomato soup"
	desc = "Smells like copper."
	icon_state = "tomatosoup"
	filling_color = "#ff0000"
	bitesize = 5
	list_reagents = list("protein" = 2, "blood" = 10, "water" = 5, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/soup/tomatosoup
	name = "Tomato Soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#d92929"
	bitesize = 3
	list_reagents = list("plantmatter" = 5, "tomatojuice" = 10, "vitamin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/soup/clownstears
	name = "Clown's Tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	filling_color = "#c4fbff"
	bitesize = 5
	list_reagents = list("nutriment" = 4, "banana" = 5, "water" = 10, "vitamin" = 8)

/obj/item/weapon/reagent_containers/food/snacks/soup/vegetablesoup
	name = "Vegetable soup"
	desc = "A true vegan meal." //TODO
	icon_state = "vegetablesoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#afc4b5"
	bitesize = 5
	list_reagents = list("plantmatter" = 8, "water" = 5, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/soup/nettlesoup
	name = "Nettle soup"
	desc = "To think, the botanist would've beat you to death with one of these."
	icon_state = "nettlesoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#afc4b5"
	bitesize = 5
	list_reagents = list("plantmatter" = 8, "water" = 5, "tricordrazine" = 5, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/soup/mysterysoup
	name = "Mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#f082ff"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/soup/mysterysoup/atom_init()
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

/obj/item/weapon/reagent_containers/food/snacks/soup/wishsoup
	name = "Wish Soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#d1f4ff"
	bitesize = 5
	list_reagents = list("water" = 10)

/obj/item/weapon/reagent_containers/food/snacks/soup/wishsoup/atom_init()
	. = ..()
	if(prob(25))
		src.desc = "A wish come true!"
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("vitamin", 1)

//END SOUPS

/obj/item/weapon/reagent_containers/food/snacks/hotchili
	name = "Hot Chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#ff3c00"
	bitesize = 5
	list_reagents = list("plantmatter" = 6, "capsaicin" = 3, "tomatojuice" = 2, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/coldchili
	name = "Cold Chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	filling_color = "#2b00ff"
	bitesize = 5
	trash = /obj/item/trash/snack_bowl
	list_reagents = list("plantmatter" = 6, "frostoil" = 3, "tomatojuice" = 2, "vitamin" = 2)

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
	list_reagents = list("nutriment" = 10)

	var/wrapped = 0
	var/monkey_type = /mob/living/carbon/monkey

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(istype(target,/obj/structure/sink) && !wrapped)
		to_chat(user, "<span class='notice'>You place \the [name] under a stream of water...</span>")
		user.drop_item()
		loc = get_turf(target)
		return Expand()
	..()

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/entered_water_turf()
	Expand()

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
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/bigbiteburger
	name = "Big Bite Burger"
	desc = "Forget the Big Mac. THIS is the future!"
	icon_state = "bigbiteburger"
	filling_color = "#e3d681"
	bitesize = 3
	list_reagents = list("nutriment" = 4, "protein" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/enchiladas
	name = "Enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"
	trash = /obj/item/trash/tray
	filling_color = "#a36a1f"
	bitesize = 4
	list_reagents = list("protein" = 8, "capsaicin" = 6)

/obj/item/weapon/reagent_containers/food/snacks/monkeysdelight
	name = "monkey's Delight"
	desc = "Eeee Eee!"
	icon_state = "monkeysdelight"
	trash = /obj/item/trash/tray
	filling_color = "#5c3c11"
	bitesize = 6
	list_reagents = list("nutriment" = 10, "banana" = 5, "blackpepper" = 1, "sodiumchloride" = 1, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/baguette
	name = "Baguette"
	desc = "Bon appetit!"
	icon_state = "baguette"
	filling_color = "#e3d796"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "blackpepper" = 1, "sodiumchloride" = 1, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/fishandchips
	name = "Fish and Chips"
	desc = "I do say so myself chap."
	icon_state = "fishandchips"
	filling_color = "#e3d796"
	bitesize = 3
	list_reagents = list("protein" = 6, "carpotoxin" = 3, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/sashimi
	name = "Carp sashimi"
	desc = "Celebrate surviving attack from hostile alien lifeforms by hospitalising yourself."
	icon_state = "sashimi"
	bitesize = 3
	list_reagents = list("protein" = 6, "capsaicin" = 3, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/sandwich
	name = "Sandwich"
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon_state = "sandwich"
	trash = /obj/item/trash/plate
	filling_color = "#d9be29"
	bitesize = 2
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/toastedsandwich
	name = "Toasted Sandwich"
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	filling_color = "#d9be29"
	bitesize = 2
	list_reagents = list("nutriment" = 6, "carbon" = 2)

/obj/item/weapon/reagent_containers/food/snacks/grilledcheese
	name = "Grilled Cheese Sandwich"
	desc = "Goes great with Tomato soup!"
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	filling_color = "#d9be29"
	bitesize = 2
	list_reagents = list("nutriment" = 7, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/rofflewaffles
	name = "Roffle Waffles"
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	filling_color = "#ff00f7"
	bitesize = 4
	list_reagents = list("nutriment" = 8, "psilocybin" = 8, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast
	name = "Jellied Toast"
	desc = "A slice of bread covered with delicious jam."
	icon_state = "jellytoast"
	trash = /obj/item/trash/plate
	filling_color = "#b572ab"
	bitesize = 3
	list_reagents = list("nutriment" = 1, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/cherry
	list_reagents = list("cherryjelly" = 5)

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/slime
	list_reagents = list("slimejelly" = 5)

/obj/item/weapon/reagent_containers/food/snacks/jellyburger
	name = "Jelly Burger"
	desc = "Culinary delight..?"
	icon_state = "jellyburger"
	filling_color = "#b572ab"
	bitesize = 2
	list_reagents = list("nutriment" = 5)

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/slime
	list_reagents = list("slimejelly" = 5)

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/cherry
	list_reagents = list("cherryjelly" = 5)

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat
	name = "Stewed Soy Meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/plate
	bitesize = 2
	list_reagents = list("plantmatter" = 8)

/obj/item/weapon/reagent_containers/food/snacks/boiledspagetti
	name = "Boiled Spaghetti"
	desc = "A plain dish of noodles, this sucks."
	icon_state = "spagettiboiled"
	trash = /obj/item/trash/plate
	filling_color = "#fcee81"
	bitesize = 2
	list_reagents = list("plantmatter" = 2, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/boiledrice
	name = "Boiled Rice"
	desc = "A boring dish of boring rice."
	icon_state = "boiledrice"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#fffbdb"
	bitesize = 2
	list_reagents = list("plantmatter" = 5, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/sushi
	name = "Sushi"
	desc = "This is the Japanese preparation and serving of specially prepared vinegared rice combined with varied ingredients such as chiefly seafood"
	icon_state = "sushi"
	filling_color = "#fffbdb"
	bitesize = 2
	list_reagents = list("nutriment" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/ricepudding
	name = "Rice Pudding"
	desc = "Where's the Jam!"
	icon_state = "rpudding"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#fffbdb"
	bitesize = 2
	list_reagents = list("plantmatter" = 4, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/pastatomato
	name = "Spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	trash = /obj/item/trash/plate
	filling_color = "#de4545"
	bitesize = 4
	list_reagents = list("plantmatter" = 6, "tomatojuice" = 10, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/meatballspagetti
	name = "Spaghetti & Meatballs"
	desc = "Now thats a nic'e meatball!"
	icon_state = "meatballspagetti"
	trash = /obj/item/trash/plate
	filling_color = "#de4545"
	bitesize = 2
	list_reagents = list("protein" = 8, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/spesslaw
	name = "Spesslaw"
	desc = "A lawyers favourite"
	icon_state = "spesslaw"
	filling_color = "#de4545"
	bitesize = 2
	list_reagents = list("protein" = 8, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel
	name = "Poppy Pretzel"
	desc = "A large soft pretzel full of POP!"
	icon_state = "poppypretzel"
	filling_color = "#ab7d2e"
	bitesize = 2
	list_reagents = list("plantmatter" = 5)

/obj/item/weapon/reagent_containers/food/snacks/carrotfries
	name = "Carrot Fries"
	desc = "Tasty fries from fresh Carrots."
	icon_state = "carrotfries"
	trash = /obj/item/trash/plate
	filling_color = "#faa005"
	bitesize = 2
	list_reagents = list("plantmatter" = 3, "imidazoline" = 3, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/superbiteburger
	name = "Super Bite Burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	filling_color = "#cca26a"
	bitesize = 10
	list_reagents = list("nutriment" = 32, "cheese" = 4, "protein" = 16, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/candiedapple
	name = "Candied Apple"
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"
	filling_color = "#f21873"
	bitesize = 3
	list_reagents = list("nutriment" = 3, "sugar" = 2)

/obj/item/weapon/reagent_containers/food/snacks/applepie
	name = "Apple Pie"
	desc = "A pie containing sweet sweet love... or apple."
	icon_state = "applepie"
	filling_color = "#e0edc5"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/cherrypie
	name = "Cherry Pie"
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	filling_color = "#ff525a"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/twobread
	name = "Two Bread"
	desc = "It is very bitter and winy."
	icon_state = "twobread"
	filling_color = "#dbcc9a"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich
	name = "Jelly Sandwich"
	desc = "You wish you had some peanut butter to go with this..."
	icon_state = "jellysandwich"
	trash = /obj/item/trash/plate
	filling_color = "#9e3a78"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime
	list_reagents = list("slimejelly" = 5)

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry
	list_reagents = list("cherryjelly" = 5)

/obj/item/weapon/reagent_containers/food/snacks/boiledslimecore
	name = "Boiled slime Core"
	desc = "A boiled red thing."
	icon_state = "boiledslimecore"
	bitesize = 3
	list_reagents = list("slimejelly" = 5)

/obj/item/weapon/reagent_containers/food/snacks/mint
	name = "mint"
	desc = "it is only wafer thin."
	icon_state = "mint"
	filling_color = "#f2f2f2"
	bitesize = 1
	list_reagents = list("minttoxin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"
	filling_color = "#cfb4c4"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit/atom_init()
	. = ..()
	if(prob(10))
		name = "exceptional plump helmet biscuit"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump helmet biscuit!"
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("tricordrazine", 5)
	else
		reagents.add_reagent("nutriment", 5)

/obj/item/weapon/reagent_containers/food/snacks/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#f0f2e4"
	bitesize = 1
	list_reagents = list("nutriment" = 5)

/obj/item/weapon/reagent_containers/food/snacks/tossedsalad
	name = "tossed salad"
	desc = "A proper salad, basic and simple, with little bits of carrot, tomato and apple intermingled. Vegan!"
	icon_state = "herbsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76b87f"
	bitesize = 3
	list_reagents = list("plantmatter" = 8, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/validsalad
	name = "valid salad"
	desc = "It's just a salad of questionable 'herbs' with meatballs and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76b87f"
	bitesize = 3
	list_reagents = list("plantmatter" = 8, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/olivyesalad
	name = "Olivye salad"
	desc = "It's a traditional salad dish in Russian cuisine."
	icon_state = "olivyesalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76b87f"
	bitesize = 3
	list_reagents = list("plantmatter" = 9, "vitamin" = 1, "protein" = 5)

/obj/item/weapon/reagent_containers/food/snacks/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	trash = /obj/item/trash/plate
	filling_color = "#ffff00"
	bitesize = 3
	list_reagents = list("plantmatter" = 8, "gold" = 5, "vitamin" = 4)

/////////////////////////////////////////////////Sliceable////////////////////////////////////////
// All the food items that can be sliced into smaller bits like Meatbread and Cheesewheels

/obj/item/weapon/reagent_containers/food/snacks/sliceable
	w_class = ITEM_SIZE_NORMAL
	var/obj/item/weapon/storage/internal/sliceable/storage

/obj/item/weapon/storage/internal/sliceable
	name = "sliceable inventory"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/atom_init()
	. = ..()
	storage = new /obj/item/weapon/storage/internal/sliceable(src)
	storage.set_slots(5, w_class - 1)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/MouseDrop(obj/over_object)
	if (!storage.handle_mousedrop(usr, over_object))
		..()

/obj/item/weapon/reagent_containers/food/snacks/proc/try_slice(obj/item/weapon/W, mob/user)
	if((slices_num <= 0 || !slices_num) || !slice_path)
		return FALSE
	var/inaccurate = 0
	if( \
			istype(W, /obj/item/weapon/kitchenknife) || \
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
	else
		return FALSE
	if ( \
			!isturf(src.loc) || \
			!(locate(/obj/structure/table) in src.loc) && \
			!(locate(/obj/machinery/optable) in src.loc) && \
			!(locate(/obj/item/weapon/tray) in src.loc) \
		)
		to_chat(user, "<span class='rose'>You cannot slice [src] here! You need a table or at least a tray to do it.</span>")
		return FALSE
	var/slices_lost = 0
	if (inaccurate)
		slices_lost = rand(1, min(1, round(slices_num * 0.5)))
		if (istype(W, /obj/item/weapon/melee/energy/sword))
			playsound(user, 'sound/items/esword_cutting.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		else
			playsound(user, 'sound/items/shard_cutting.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	else
		playsound(src, pick(SOUNDIN_KNIFE_CUTTING), VOL_EFFECTS_MASTER, null, FALSE)
	if (do_after(user, 35, target = src, can_move = FALSE))
		if (!inaccurate)
			user.visible_message("<span class='info'>[user] slices \the [src]!</span>", "<span class='notice'>You slice \the [src]!</span>")
		else
			user.visible_message("<span class='info'>[user] inaccurately slices \the [src] with [W]!</span>", "<span class='notice'>You inaccurately slice \the [src] with your [W]!</span>")
		var/reagents_per_slice = reagents.total_volume/slices_num
		for(var/i=1 to (slices_num-slices_lost))
			var/obj/slice = new slice_path (src.loc)
			reagents.trans_to(slice,reagents_per_slice)
		qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	var/holding = user.get_active_hand()
	if(!holding)
		return
	if(storage.can_be_inserted(holding))
		storage.handle_item_insertion(holding)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/Destroy()
	storage.close_all()
	for(var/obj/item/I in storage)
		storage.remove_from_storage(I, get_turf(src))
	QDEL_NULL(storage)
	return ..()

// === BREAD ===

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread
	name = "Bread"
	icon_state = "Some plain old Earthen bread."
	icon_state = "bread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice
	slices_num = 5
	filling_color = "#ffe396"
	bitesize = 2
	list_reagents = list("nutriment" = 10, "bread" = 10)



/obj/item/weapon/reagent_containers/food/snacks/breadslice
	name = "Bread slice"
	desc = "A slice of home."
	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	filling_color = "#d27332"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/cheese
	name = "Cream Cheese Bread"
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/cheese
	filling_color = "#fff896"
	list_reagents = list("nutriment" = 20, "cheese" = 10)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/cheese
	name = "Cream Cheese Bread slice"
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	filling_color = "#fff896"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/meat
	name = "meatbread loaf"
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon_state = "meatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/meat
	filling_color = "#ff7575"
	list_reagents = list("protein" = 20, "nutriment" = 10, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/meat
	name = "meatbread slice"
	desc = "A slice of delicious meatbread."
	icon_state = "meatbreadslice"
	filling_color = "#ff7575"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/xeno
	name = "xenomeatbread loaf"
	desc = "The culinary base of every self-respecting eloquent gentleman. Extra Heretical."
	icon_state = "xenomeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/xeno
	filling_color = "#8aff75"
	list_reagents = list("protein" = 20, "nutriment" = 10, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/xeno
	name = "xenomeatbread slice"
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon_state = "xenobreadslice"
	filling_color = "#8aff75"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/spider
	name = "spider meat loaf"
	desc = "Reassuringly green meatloaf made from spider meat."
	icon_state = "spidermeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/spider
	list_reagents = list("protein" = 20, "nutriment" = 10, "vitamin" = 5, "toxin" = 15)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/spider
	name = "spider meat bread slice"
	desc = "A slice of meatloaf made from an animal that most likely still wants you dead."
	icon_state = "xenobreadslice"


/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/banana
	name = "Banana-nut bread"
	desc = "A heavenly and filling treat."
	icon_state = "bananabread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/banana
	filling_color = "#ede5ad"
	list_reagents = list("banana" = 20, "nutriment" = 20)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/banana
	name = "Banana-nut bread slice"
	desc = "A slice of delicious banana bread."
	icon_state = "bananabreadslice"
	filling_color = "#ede5ad"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/tofu
	name = "Tofubread"
	icon_state = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon_state = "tofubread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/tofu
	filling_color = "#f7ffe0"
	list_reagents = list("plantmatter" = 20, "vitamin" = 10)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/tofu
	name = "Tofubread slice"
	desc = "A slice of delicious tofubread."
	icon_state = "tofubreadslice"
	filling_color = "#f7ffe0"

// === CAKE ===

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake
	name = "Vanilla Cake"
	desc = "A plain cake, not a lie."
	icon_state = "plaincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice
	slices_num = 5
	filling_color = "#f7edd5"
	bitesize = 2
	list_reagents = list("nutriment" = 20, "sugar" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice
	name = "Vanilla Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "plaincake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#f7edd5"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/birthday
	name = "Birthday Cake"
	desc = "Happy Birthday..."
	icon_state = "birthdaycake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/birthday
	filling_color = "#ffd6d6"
	list_reagents = list("nutriment" = 20, "sprinkles" = 10, "sugar" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/birthday
	name = "Birthday Cake slice"
	desc = "A slice of your birthday"
	icon_state = "birthdaycakeslice"
	filling_color = "#ffd6d6"
/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/apple
	name = "Apple Cake"
	desc = "A cake centred with Apple"
	icon_state = "applecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/apple
	filling_color = "#ebf5b8"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/apple
	name = "Apple Cake slice"
	desc = "A slice of heavenly cake."
	icon_state = "applecakeslice"
	filling_color = "#ebf5b8"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/pumpkin
	name = "Pumpkin Pie"
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/pumpkin
	filling_color = "#f5b951"
	list_reagents = list("nutriment" = 5, "vitamin" = 5, "sugar" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/pumpkin
	name = "Pumpkin Pie slice"
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon_state = "pumpkinpieslice"
	filling_color = "#f5b951"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/carrot
	name = "Carrot Cake"
	desc = "A favorite desert of a certain wascally wabbit. Not a lie."
	icon_state = "carrotcake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/carrot
	filling_color = "#ffd675"
	list_reagents = list("nutriment" = 20, "imidazoline" = 10, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/carrot
	name = "Carrot Cake slice"
	desc = "Carrotty slice of Carrot Cake, carrots are good for your eyes! Also not a lie."
	icon_state = "carrotcake_slice"
	filling_color = "#ffd675"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/brain
	name = "Brain Cake"
	desc = "A squishy cake-thing."
	icon_state = "braincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/brain
	filling_color = "#e6aedb"
	list_reagents = list("protein" = 10, "nutriment" = 10, "alkysine" = 10, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/brain
	name = "Brain Cake slice"
	desc = "Lemme tell you something about prions. THEY'RE DELICIOUS."
	icon_state = "braincakeslice"
	filling_color = "#e6aedb"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/cheese
	name = "Cheese Cake"
	desc = "DANGEROUSLY cheesy."
	icon_state = "cheesecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/cheese
	filling_color = "#faf7af"
	list_reagents = list("nutriment" = 20, "cheese" = 10)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/cheese
	name = "Cheese Cake slice"
	desc = "Slice of pure cheestisfaction"
	icon_state = "cheesecake_slice"
	filling_color = "#faf7af"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/orange
	name = "Orange Cake"
	desc = "A cake with added orange."
	icon_state = "orangecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/orange
	filling_color = "#fada8e"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/orange
	name = "Orange Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "orangecake_slice"
	filling_color = "#fada8e"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/lime
	name = "Lime Cake"
	desc = "A cake with added lime."
	icon_state = "limecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/lime
	filling_color = "#cbfa8e"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/lime
	name = "Lime Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "limecake_slice"
	filling_color = "#cbfa8e"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/lemon
	name = "Lemon Cake"
	desc = "A cake with added lemon."
	icon_state = "lemoncake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/lemon
	filling_color = "#fafa8e"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/lemon
	name = "Lemon Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "lemoncake_slice"
	filling_color = "#fafa8e"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/chocolate
	name = "Chocolate Cake"
	desc = "A cake with added chocolate"
	icon_state = "chocolatecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/chocolate
	filling_color = "#805930"
	list_reagents = list("nutriment" = 20, "coco" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/chocolate
	name = "Chocolate Cake slice"
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "chocolatecake_slice"
	filling_color = "#805930"

// === PIZZA ===

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza
	slices_num = 6
	filling_color = "#baa14c"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/
	filling_color = "#baa14c"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita
	name = "Margherita"
	desc = "The golden standard of pizzas."
	icon_state = "pizzamargherita"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/margherita
	list_reagents = list("plantmatter" = 30, "tomatojuice" = 6, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/margherita
	name = "Margherita slice"
	desc = "A slice of the classic pizza."
	icon_state = "pizzamargheritaslice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meat
	name = "Meatpizza"
	desc = "A pizza with meat topping."
	icon_state = "meatpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/meat
	list_reagents = list("protein" = 30, "tomatojuice" = 6, "vitamin" = 8)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/meat
	name = "Meatpizza slice"
	desc = "A slice of a meaty pizza."
	icon_state = "meatpizzaslice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroom
	name = "Mushroompizza"
	desc = "Very special pizza"
	icon_state = "mushroompizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/mushroom
	list_reagents = list("plantmatter" = 30, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/mushroom
	name = "Mushroompizza slice"
	desc = "Maybe it is the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetable
	name = "Vegetable pizza"
	desc = "No one of Tomato Sapiens were harmed during making this pizza"
	icon_state = "vegetablepizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/vegetable
	list_reagents = list("plantmatter" = 25, "tomatojuice" = 6, "imidazoline" = 12, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/vegetable
	name = "Vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients "
	icon_state = "vegetablepizzaslice"

// pizzabox code

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

/obj/item/pizzabox/attackby(obj/item/I, mob/user, params)
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

		boxtotagto.boxtag = copytext_char("[boxtotagto.boxtag][t]", 1, 30)

		update_icon()
		return
	return ..()

/obj/item/pizzabox/margherita/atom_init()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita(src)
	boxtag = "Margherita Deluxe"

/obj/item/pizzabox/vegetable/atom_init()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetable(src)
	boxtag = "Gourmet Vegatable"

/obj/item/pizzabox/mushroom/atom_init()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroom(src)
	boxtag = "Mushroom Special"

/obj/item/pizzabox/meat/atom_init()
	. = ..()
	pizza = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meat(src)
	boxtag = "Meatlover's Supreme"

// === OTHER ===

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel
	name = "Cheese wheel"
	desc = "A big wheel of delcious Cheddar."
	icon_state = "cheesewheel"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	slices_num = 5
	filling_color = "#fff700"
	list_reagents = list("nutriment" = 15, "vitamin" = 5, "cheese" = 20)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	name = "Cheese wedge"
	desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewedge"
	filling_color = "#fff700"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/watermelonslice
	name = "Watermelon Slice"
	desc = "A slice of watery goodness."
	icon_state = "watermelonslice"
	filling_color = "#ff3867"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cracker
	name = "Cracker"
	desc = "It's a salted cracker."
	icon_state = "cracker"
	filling_color = "#f5deb8"
	list_reagents = list("nutriment" = 1)

/obj/item/weapon/reagent_containers/food/snacks/dionaroast
	name = "roast diona"
	desc = "It's like an enormous, leathery carrot. With an eye."
	icon_state = "dionaroast"
	trash = /obj/item/trash/plate
	filling_color = "#75754b"
	bitesize = 2
	list_reagents = list("plantmatter" = 4, "nutriment" = 2, "radium" = 2, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg
	name = "boiled spider leg"
	desc = "A giant spider's leg that's still twitching after being cooked. Gross!"
	icon_state = "spiderlegcooked"
	trash = /obj/item/trash/plate
	bitesize = 3
	list_reagents = list("nutriment" = 3, "capsaicin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/spidereggs
	name = "spider eggs"
	desc = "A cluster of juicy spider eggs. A great side dish for when you care not for your health."
	icon_state = "spidereggs"
	list_reagents = list("protein" = 2, "toxin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/spidereggsham
	name = "green eggs and ham"
	desc = "Would you eat them on a train? Would you eat them on a plane? Would you eat them on a state of the art corporate deathtrap floating through space?"
	icon_state = "spidereggsham"
	trash = /obj/item/trash/plate
	bitesize = 4
	list_reagents = list("nutriment" = 6)

///////////////////////////////////////////
// new old food stuff from bs12
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "dough"
	bitesize = 2
	list_reagents = list("nutriment" = 6)

// Dough + rolling pin = flat dough
/obj/item/weapon/reagent_containers/food/snacks/dough/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/kitchen/rollingpin))
		if(locate(/obj/structure/table) in loc)
			playsound(user, 'sound/items/rolling_pin.ogg', VOL_EFFECTS_MASTER, , FALSE)
			if(!user.is_busy(src) && do_after(user, 35, target = src))
				new /obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough(src)
				to_chat(user, "<span class='notice'>You flatten the dough.</span>")
				qdel(src)
		else
			to_chat(user, "<span class='rose'>You cannot roll out the dough here! You need a table to do it.</span>")

	else
		return ..()

// slicable into 3xdoughslices
/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough
	name = "flat dough"
	desc = "A flattened dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "flat dough"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/doughslice
	slices_num = 3
	list_reagents = list("nutriment" = 6)

/obj/item/weapon/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "A building block of an impressive dish."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "doughslice"
	bitesize = 2
	list_reagents = list("nutriment" = 1)

/obj/item/weapon/reagent_containers/food/snacks/bun
	name = "bun"
	desc = "A base for any self-respecting burger."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "bun"
	bitesize = 2
	list_reagents = list("nutriment" = 1)

/obj/item/weapon/reagent_containers/food/snacks/bun/attackby(obj/item/I, mob/user, params)
	// Bun + cutlet = hamburger
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/cutlet))
		new /obj/item/weapon/reagent_containers/food/snacks/monkeyburger(src)
		to_chat(user, "<span class='notice'>You make a burger.</span>")
		qdel(I)
		qdel(src)

	// Bun + sausage = hotdog
	else if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/sausage))
		new /obj/item/weapon/reagent_containers/food/snacks/hotdog(src)
		to_chat(user, "<span class='notice'>You make a hotdog.</span>")
		qdel(I)
		qdel(src)

	else
		return ..()

// Burger + cheese wedge = cheeseburger
/obj/item/weapon/reagent_containers/food/snacks/monkeyburger/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/cheesewedge))
		new /obj/item/weapon/reagent_containers/food/snacks/cheeseburger(src)
		to_chat(user, "<span class='notice'>You make a cheeseburger.</span>")
		qdel(I)
		qdel(src)

	else
		return ..()

// Human Burger + cheese wedge = cheeseburger
/obj/item/weapon/reagent_containers/food/snacks/human/burger/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/cheesewedge))
		var/obj/item/weapon/reagent_containers/food/snacks/cheeseburger/C = new (src)
		C.name = name
		to_chat(user, "<span class='notice'>You make a cheeseburger.</span>")
		qdel(I)
		qdel(src)
		return
	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/taco
	name = "taco"
	desc = "Take a bite!"
	icon_state = "taco"
	bitesize = 3
	list_reagents = list("nutriment" = 7, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet
	name = "raw cutlet"
	desc = "A thin piece of raw meat."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawcutlet"
	bitesize = 1
	list_reagents = list("nutriment" = 1)

/obj/item/weapon/reagent_containers/food/snacks/cutlet
	name = "cutlet"
	desc = "A tasty meat slice."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "cutlet"
	bitesize = 2
	list_reagents = list("protein" = 2)

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/kitchenknife))
		new /obj/item/weapon/reagent_containers/food/snacks/raw_bacon(src)
		to_chat(user, "<span class='notice'>You make a bacon.</span>")
		qdel(src)
		return
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/deepfryholder
	name = "Deep Fried Foods Holder Obj"
	desc = "If you can see this description the code for the deep fryer fucked up."
	icon_state = "deepfried_holder_icon"
	filling_color = "#ffad33"
	bitesize = 2
	list_reagents = list("nutriment" = 3)

/obj/item/weapon/reagent_containers/food/snacks/rawmeatball
	name = "raw meatball"
	desc = "A raw meatball."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawmeatball"
	bitesize = 2
	list_reagents = list("protein" = 2)

/obj/item/weapon/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Unrelated to dogs, maybe."
	icon_state = "hotdog"
	bitesize = 2
	list_reagents = list("protein" = 6)

/obj/item/weapon/reagent_containers/food/snacks/flatbread
	name = "flatbread"
	desc = "Bland but filling."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "flatbread"
	bitesize = 2
	list_reagents = list("plantmatter" = 3, "vitamin" = 1)

// potato + knife = raw sticks
/obj/item/weapon/reagent_containers/food/snacks/grown/potato/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/kitchenknife))
		new /obj/item/weapon/reagent_containers/food/snacks/rawsticks(src)
		to_chat(user, "You cut the potato.")
		qdel(src)
	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/rawsticks
	name = "raw potato sticks"
	desc = "Raw fries, not very tasty."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawsticks"
	bitesize = 2
	list_reagents = list("plantmatter" = 3)

////////////////////////////////FOOD ADDITIONS////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/beans
	name = "tin of beans"
	desc = "Musical fruit in a slightly less musical container."
	icon_state = "beans"
	bitesize = 2
	list_reagents = list("nutriment" = 10, "vitamin" = 3, "beans" = 10)

/obj/item/weapon/reagent_containers/food/snacks/wrap
	name = "egg wrap"
	desc = "The precursor to Pigs in a Blanket."
	icon_state = "wrap"
	bitesize = 2
	list_reagents = list("nutriment" = 5)

/obj/item/weapon/reagent_containers/food/snacks/benedict
	name = "eggs benedict"
	desc = "There is only one egg on this, how rude."
	icon_state = "benedict"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 4, "egg" = 3)

/obj/item/weapon/reagent_containers/food/snacks/meatbun
	name = "meat bun"
	desc = "Has the potential to not be Dog."
	icon_state = "meatbun"
	bitesize = 2
	list_reagents = list("protein" = 6)

/obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich
	name = "icecream sandwich"
	desc = "Portable Ice-cream in it's own packaging."
	icon_state = "icecreamsanwich"
	bitesize = 1
	list_reagents = list("nutriment" = 2, "ice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/notasandwich
	name = "not-a-sandwich"
	desc = "Something seems to be wrong with this, you can't quite figure what. Maybe it's his moustache."
	icon_state = "notasandwich"
	bitesize = 2
	list_reagents = list("nutriment" = 6, "vitamin" = 6)

/obj/item/weapon/reagent_containers/food/snacks/sugarcookie
	name = "sugar cookie"
	desc = "Just like your little sister used to make."
	icon_state = "sugarcookie"
	bitesize = 2
	list_reagents = list("nutriment" = 3, "sugar" = 3)

/obj/item/weapon/reagent_containers/food/snacks/friedbanana
	name = "Fried Banana"
	desc = "Goreng Pisang, also known as fried bananas."
	icon_state = "friedbanana"
	bitesize = 4
	list_reagents = list("sugar" = 5, "nutriment" = 8, "cornoil" = 4)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/turkey
	name = "Turkey"
	desc = "A traditional turkey served with stuffing."
	icon_state = "turkey"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/turkeyslice
	slices_num = 6
	bitesize = 3
	list_reagents = list("protein" = 24, "nutriment" = 18, "vitamin" = 5)

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
	list_reagents = list("nutriment" = 8)

/obj/item/weapon/reagent_containers/food/snacks/burrito
	name = "Burrito"
	desc = "Meat, beans, cheese, and rice wrapped up as an easy-to-hold meal."
	icon_state = "burrito"
	trash = /obj/item/trash/plate
	filling_color = "#a36a1f"
	bitesize = 1
	list_reagents = list("protein" = 5)

/obj/item/weapon/reagent_containers/food/snacks/raw_bacon
	name = "raw bacon"
	desc = "It's fleshy and pink!"
	icon_state = "raw_bacon"
	bitesize = 3
	list_reagents = list("protein" = 1)

/obj/item/weapon/reagent_containers/food/snacks/bacon
	name = "bacon"
	desc = "It looks juicy and tastes amazing!"
	icon_state = "bacon"
	bitesize = 3
	list_reagents = list("protein" = 7)

/obj/item/weapon/reagent_containers/food/snacks/telebacon
	name = "Tele Bacon"
	desc = "It tastes a little odd but it is still delicious."
	icon_state = "bacon_tele"
	bitesize = 1
	list_reagents = list("protein" = 6)

/obj/item/weapon/reagent_containers/food/snacks/salmonsteak
	name = "Salmon steak"
	desc = "A piece of freshly-grilled salmon meat."
	icon_state = "salmonsteak"
	trash = /obj/item/trash/plate
	filling_color = "#7a3d11"
	bitesize = 4
	list_reagents = list("protein" = 4, "sodiumchloride" = 1, "blackpepper" = 1, "anti_toxin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge
	name = "Fudge"
	desc = "Chocolate fudge, a timeless classic treat."
	icon_state = "fudge"
	filling_color = "#7d5f46"
	bitesize = 3
	list_reagents = list("cream" = 2, "nutriment" = 4)

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/cherry
	name = "Chocolate Cherry Fudge"
	desc = "Chocolate fudge surrounding sweet cherries. Good for tricking kids into eating some fruit."
	icon_state = "fudge_cherry"
	filling_color = "#7d5f46"
	bitesize = 3
	list_reagents = list("cream" = 3, "nutriment" = 6)

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/cookies_n_cream
	name = "Cookies 'n' Cream Fudge"
	desc = "An extra creamy fudge with bits of real chocolate cookie mixed in. Crunchy!"
	icon_state = "fudge_cookies_n_cream"
	filling_color = "#7d5f46"
	bitesize = 3
	list_reagents = list("cream" = 5, "nutriment" = 4)

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/turtle
	name = "Turtle Fudge"
	desc = "Chocolate fudge with caramel and nuts. It doesn't contain real turtles, thankfully."
	icon_state = "fudge_turtle"
	filling_color = "#7d5f46"
	bitesize = 3
	list_reagents = list("cream" = 2, "nutriment" = 6)

/obj/item/weapon/reagent_containers/food/snacks/candy/toffee
	name = "Toffee"
	desc = "A hard, brittle candy with a distinctive taste."
	icon_state = "toffee"
	filling_color = "#7d5f46"
	bitesize = 2
	list_reagents = list("nutriment" = 3, "sugar" = 3)

/obj/item/weapon/reagent_containers/food/snacks/candy/caramel
	name = "Caramel"
	desc = "Chewy and dense, yet it practically melts in your mouth!"
	icon_state = "caramel"
	filling_color = "#db944d"
	bitesize = 2
	list_reagents = list("cream" = 2, "sugar" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/candycane
	name = "candy cane"
	desc = "A festive mint candy cane."
	icon_state = "candycane"
	filling_color = "#f2f2f2"
	bitesize = 2
	list_reagents = list("sugar" = 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/taffy
	name = "Saltwater Taffy"
	desc = "Old fashioned saltwater taffy. Chewy!"
	icon_state = "candy1"
	filling_color = "#7d5f46"
	bitesize = 4
	list_reagents = list("nutriment" = 2, "sugar" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/nougat
	name = "Nougat"
	desc = "A soft, chewy candy commonly found in candybars."
	icon_state = "nougat"
	filling_color = "#7d5f46"
	bitesize = 2
	list_reagents = list("nutriment" = 3, "sugar" = 3)

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
	list_reagents = list("sugar" = 15)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/red
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_red"
	filling_color = "#801e28"
	trash = /obj/item/weapon/c_tube
	bitesize = 4
	list_reagents = list("cherryjelly" = 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/blue
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_blue"
	filling_color = "#863333"
	trash = /obj/item/weapon/c_tube
	bitesize = 4
	list_reagents = list("berryjuice" = 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/green
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_green"
	filling_color = "#365e30"
	trash = /obj/item/weapon/c_tube
	bitesize = 4
	list_reagents = list("limejuice" = 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/yellow
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_yellow"
	filling_color = "#863333"
	trash = /obj/item/weapon/c_tube
	bitesize = 4
	list_reagents = list("lemonjuice" = 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/orange
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_orange"
	filling_color = "#e78108"
	trash = /obj/item/weapon/c_tube
	bitesize = 4
	list_reagents = list("orangejuice" = 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/purple
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_purple"
	filling_color = "#993399"
	trash = /obj/item/weapon/c_tube
	bitesize = 4
	list_reagents = list("grapejuice" = 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/pink
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_pink"
	filling_color = "#863333"
	trash = /obj/item/weapon/c_tube
	bitesize = 4
	list_reagents = list("watermelonjuice" = 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/rainbow
	name = "cotton candy"
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_rainbow"
	filling_color = "#c8a5dc"
	trash = /obj/item/weapon/c_tube
	bitesize = 4
	list_reagents = list("nutriment" = 20, "psilocybin" = 1)

///////////////////////////////////////////
// GUM and SUCKERS :D :>
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear
	name = "gummy bear"
	desc = "A small edible bear. It's squishy and chewy!"
	icon_state = "gbear"
	filling_color = "#ffffff"
	bitesize = 3
	list_reagents = list("sugar" = 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm
	name = "gummy worm"
	desc = "An edible worm, made from gelatin."
	icon_state = "gworm"
	filling_color = "#ffffff"
	bitesize = 3
	list_reagents = list("sugar" = 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas."
	icon_state = "jbean"
	filling_color = "#ffffff"
	bitesize = 3
	list_reagents = list("sugar" = 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/jawbreaker
	name = "jawbreaker"
	desc = "An unbelievably hard candy. The name is fitting."
	icon_state = "jawbreaker"
	filling_color = "#ed0758"
	bitesize = 0.1	//this is gonna take a while, you'll be working at this all shift.
	list_reagents = list("sugar" = 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/cash
	name = "candy cash"
	desc = "Not legal tender. Tasty though."
	icon_state = "candy_cash"
	filling_color = "#302000"
	bitesize = 2
	list_reagents = list("nutriment" = 2, "hot_coco" = 4)

/obj/item/weapon/reagent_containers/food/snacks/candy/coin
	name = "chocolate coin"
	desc = "Probably won't work in the vending machines."
	icon_state = "choc_coin"
	filling_color = "#302000"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "hot_coco" = 4)


/obj/item/weapon/reagent_containers/food/snacks/candy/gum
	name = "bubblegum"
	desc = "Chewy!"
	icon_state = "bubblegum"
	filling_color = "#ff7495"
	bitesize = 0.2
	list_reagents = list("sugar" = 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker
	name = "sucker"
	desc = "For being such a good sport!"
	icon_state = "sucker"
	filling_color = "#ffffff"
	bitesize = 1
	list_reagents = list("sugar" = 10)

///////////////////////////////////////////
// BEAR GYMS :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/red
	name = "gummy bear"
	desc = "A small edible bear. It's red!"
	icon_state = "gbear_red"
	filling_color = "#801e28"
	bitesize = 3
	list_reagents = list("cherryjelly" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/blue
	name = "gummy bear"
	desc = "A small edible bear. It's blue!"
	icon_state = "gbear_blue"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("berryjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/green
	name = "gummy bear"
	desc = "A small edible bear. It's green!"
	icon_state = "gbear_green"
	filling_color = "#365e30"
	bitesize = 3
	list_reagents = list("limejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/yellow
	name = "gummy bear"
	desc = "A small edible bear. It's yellow!"
	icon_state = "gbear_yellow"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("lemonjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/orange
	name = "gummy bear"
	desc = "A small edible bear. It's orange!"
	icon_state = "gbear_orange"
	filling_color = "#e78108"
	bitesize = 3
	list_reagents = list("orangejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/purple
	name = "gummy bear"
	desc = "A small edible bear. It's purple!"
	icon_state = "gbear_purple"
	filling_color = "#993399"
	bitesize = 3
	list_reagents = list("grapejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/wtf
	name = "gummy bear"
	desc = "A small bear. Wait... what?"
	icon_state = "gbear_wtf"
	filling_color = "#60a584"
	bitesize = 3
	list_reagents = list("space_drugs" = 2)

///////////////////////////////////////////
// WORM GYMS :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/red
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's red!"
	icon_state = "gworm_red"
	filling_color = "#801e28"
	bitesize = 3
	list_reagents = list("cherryjelly" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/blue
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's blue!"
	icon_state = "gworm_blue"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("berryjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/green
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's green!"
	icon_state = "gworm_green"
	filling_color = "#365e30"
	bitesize = 3
	list_reagents = list("limejuice" = 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/yellow
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's yellow!"
	icon_state = "gworm_yellow"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("lemonjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/orange
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's orange!"
	icon_state = "gworm_orange"
	filling_color = "#e78108"
	bitesize = 3
	list_reagents = list("orangejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/purple
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's purple!"
	icon_state = "gworm_purple"
	filling_color = "#993399"
	bitesize = 3
	list_reagents = list("grapejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/wtf
	name = "gummy worm"
	desc = "An edible worm. Did it just move?"
	icon_state = "gworm_wtf"
	filling_color = "#60a584"
	bitesize = 3
	list_reagents = list("space_drugs" = 2)

///////////////////////////////////////////
// JELLY BEANS :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/red
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's red!"
	icon_state = "jbean_red"
	filling_color = "#801e28"
	bitesize = 3
	list_reagents = list("cherryjelly" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/blue
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's blue!"
	icon_state = "jbean_blue"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("berryjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/green
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's green!"
	icon_state = "jbean_green"
	filling_color = "#365e30"
	bitesize = 3
	list_reagents = list("limejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/yellow
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's yellow!"
	icon_state = "jbean_yellow"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("lemonjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/orange
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's orange!"
	icon_state = "jbean_orange"
	filling_color = "#e78108"
	bitesize = 3
	list_reagents = list("orangejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/purple
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's purple!"
	icon_state = "jbean_purple"
	filling_color = "#993399"
	bitesize = 3
	list_reagents = list("grapejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/chocolate
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's chocolate!"
	icon_state = "jbean_choc"
	filling_color = "#302000"
	bitesize = 3
	list_reagents = list("hot_coco" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/popcorn
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's popcorn flavored!"
	icon_state = "jbean_popcorn"
	filling_color = "#664330"
	bitesize = 3
	list_reagents = list("nutriment" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/cola
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's Cola flavored!"
	icon_state = "jbean_cola"
	filling_color = "#102000"
	bitesize = 3
	list_reagents = list("cola" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/drgibb
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's Dr. Gibb flavored!"
	icon_state = "jbean_cola"
	filling_color = "#102000"
	bitesize = 3
	list_reagents = list("dr_gibb" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/coffee
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. It's Coffee flavored!"
	icon_state = "jbean_choc"
	filling_color = "#482000"
	bitesize = 3
	list_reagents = list("coffee" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/wtf
	name = "jelly bean"
	desc = "A candy bean, guarenteed to not give you gas. You aren't sure what color it is."
	icon_state = "jbean_wtf"
	filling_color = "#60a584"
	bitesize = 3
	list_reagents = list("space_drugs" = 2)

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
	list_reagents = list("cherryjelly" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/blue
	name = "sucker"
	desc = "For being such a good sport! It's blue!"
	icon_state = "sucker_blue"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("berryjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/green
	name = "sucker"
	desc = "For being such a good sport! It's green!"
	icon_state = "sucker_green"
	filling_color = "#365e30"
	bitesize = 3
	list_reagents = list("limejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/yellow
	name = "sucker"
	desc = "For being such a good sport! It's yellow!"
	icon_state = "sucker_yellow"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("lemonjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/orange
	name = "sucker"
	desc = "For being such a good sport! It's orange!"
	icon_state = "sucker_orange"
	filling_color = "#e78108"
	bitesize = 3
	list_reagents = list("orangejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/purple
	name = "sucker"
	desc = "For being such a good sport! It's purple!"
	icon_state = "sucker_purple"
	filling_color = "#993399"
	bitesize = 3
	list_reagents = list("grapejuice" = 2)

///////////////////////////////////////////
// WORM GYMS :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/red
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's red!"
	icon_state = "gworm_red"
	filling_color = "#801e28"
	bitesize = 3
	list_reagents = list("cherryjelly" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/blue
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's blue!"
	icon_state = "gworm_blue"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("berryjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/green
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's green!"
	icon_state = "gworm_green"
	filling_color = "#365e30"
	bitesize = 3
	list_reagents = list("limejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/yellow
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's yellow!"
	icon_state = "gworm_yellow"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("lemonjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/orange
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's orange!"
	icon_state = "gworm_orange"
	filling_color = "#e78108"
	bitesize = 3
	list_reagents = list("orangejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/purple
	name = "gummy worm"
	desc = "An edible worm, made from gelatin. It's purple!"
	icon_state = "gworm_purple"
	filling_color = "#993399"
	bitesize = 3
	list_reagents = list("grapejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/wtf
	name = "gummy worm"
	desc = "An edible worm. Did it just move?"
	icon_state = "gworm_wtf"
	filling_color = "#60a584"
	bitesize = 3
	list_reagents = list("space_drugs" = 2)

///////////////////////////////////////////
// Ectoplasm o.O
///////////////////////////////////////////
/obj/item/weapon/reagent_containers/food/snacks/ectoplasm
	name = "ectoplasm"
	desc = "Spooky! Do not consume under any circumstances."
	gender = PLURAL
	icon = 'icons/obj/wizard.dmi'
	icon_state = "ectoplasm"
	list_reagents = list("ectoplasm" = 5)

/obj/item/weapon/reagent_containers/food/snacks/fries/cardboard
	icon_state = "fries_cardboard"
	trash = /obj/item/trash/fries

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries/cardboard
	icon_state = "cheesyfries_cardboard"
	trash = /obj/item/trash/fries
