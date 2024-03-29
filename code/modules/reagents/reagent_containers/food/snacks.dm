//Food items that are eaten normally and don't leave anything behind.
/obj/item/weapon/reagent_containers/food/snacks
	var/eat_sound = 'sound/items/eatfood.ogg'
	name = "snack"
	desc = "Yummy!"
	icon = 'icons/obj/food.dmi'
	icon_state = null
	var/food_type = TASTY_FOOD
	var/food_moodlet = /datum/mood_event/tasty_food
	var/bitesize = 1
	var/bitecount = 0
	var/trash = null
	var/slice_path
	var/slices_num
	var/deepfried = 0

	//Placeholder for effect that trigger on eating that aren't tied to reagents.
/obj/item/weapon/reagent_containers/food/snacks/proc/On_Consume(mob/M, silent = FALSE)
	if(!usr)	return
	if(isliving(M))
		var/mob/living/L = M
		if(taste)
			L.taste_reagents(reagents)
	if(HAS_TRAIT(src, TRAIT_XENO_FUR))
		var/mob/living/carbon/human/H = M
		if(istype(H) && !H.species.flags[FUR])
			if(prob(50) && SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "nasty_throat_feel", /datum/mood_event/nasty_throat_feel))
				to_chat(H, "<span class='warning'>You feel like something enveloping in your throat...</span>")
	if(!reagents.total_volume)
		if(!silent)
			M.visible_message("<span class='notice'>[M] finishes eating \the [src].</span>", "<span class='notice'>You finish eating \the [src].</span>")
		if(food_type)
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "food_type", food_moodlet)
		SSStatistics.score.foodeaten++
		usr.drop_from_inventory(src)	//so icons update :[

		if(trash)
			if(ispath(trash,/obj/item))
				var/obj/item/TrashItem = new trash(usr)
				usr.put_in_hands(TrashItem)
			else if(isitem(trash))
				usr.put_in_hands(trash)
		qdel(src)
	return

/obj/item/weapon/reagent_containers/food/snacks/attack_self(mob/user)
	return

/obj/item/weapon/reagent_containers/food/snacks/attack(mob/living/M, mob/user, def_zone, silent = FALSE)
	if(!reagents || !reagents.total_volume)				//Shouldn't be needed but it checks to see if it has anything left in it.
		to_chat(user, "<span class='rose'>None of [src] left, oh no!</span>")
		M.drop_from_inventory(src)	//so icons update :[
		qdel(src)
		return FALSE

	if(!CanEat(user, M, src, "eat"))
		return	//tc code

	if(iscarbon(M))
		var/mob/living/carbon/C = M
		var/fullness = C.get_satiation()
		if(C == user) // If you're eating it yourself
			if(HAS_TRAIT(C, TRAIT_PICKY_EATER) && src.food_type != VERY_TASTY_FOOD)
				to_chat(C, "<span class='rose'>You can't eat this horrible, nasty and cheap food!</span>")
				return FALSE
			else if(fullness > (550 * (1 + M.overeatduration / 2000))) // The more you eat - the more you can eat
				to_chat(C, "<span class='rose'>You cannot force any more of [src] to go down your throat.</span>")
				return FALSE
			else if(fullness > 350)
				to_chat(C, "<span class='notice'>You unwillingly chew a bit of [src].</span>")
			else if(fullness > 150)
				to_chat(C, "<span class='notice'>You take a bite of [src].</span>")
			else if(fullness > 50)
				to_chat(C, "<span class='notice'>You hungrily begin to eat [src].</span>")
			else
				to_chat(C, "<span class='rose'>You hungrily chew out a piece of [src] and gobble it!</span>")

		else
			if(!isslime(M))		//If you're feeding it to someone else.

				if (fullness <= (550 * (1 + M.overeatduration / 1000)))
					M.visible_message("<span class='rose'>[user] attempts to feed [M] [src].</span>", \
						"<span class='warning'><B>[user]</B> attempts to feed you <B>[src]</B>.</span>")
				else
					user.visible_message("<span class='rose'>[user] cannot force anymore of [src] down [M]'s throat.</span>")
					return

				if(!do_mob(user, M)) return

				M.log_combat(user, "fed [name], reagents: [reagentlist(src)] (INTENT: [uppertext(user.a_intent)])")

				M.visible_message("<span class='rose'>[user] feeds [M] [src].</span>", \
						"<span class='warning'><B>[user]</B> feeds you <B>[src]</B>.</span>")

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
				On_Consume(M, silent)
			return TRUE

	return FALSE

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
		U.create_food_overlay(filling_color)

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
				else if(isitem(trash))
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

/obj/item/weapon/reagent_containers/food/snacks/proc/bite_food(mob/user)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	if(bitecount == 0 || prob(50))
		user.visible_message("<b>[user]</b> nibbles away at the [src]")
	bitecount++
	if(bitecount >= 5)
		var/sattisfaction_text = pick("burps from enjoyment", "yaps for more", "woofs twice", "looks at the area where the [src] was")
		user.visible_message("<b>[user]</b> [sattisfaction_text]")
		qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/attack_animal(mob/M)
	..()
	if(iscorgi(M))
		bite_food(M)
	else if(ismouse(M))
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
	cases = list("салат асов", "салата асов", "салату асов", "салата асов", "салатом асов", "салате асов")
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#468c00"
	bitesize = 3
	list_reagents = list("nutriment" = 8, "doctorsdelight" = 8, "vitamin" = 6)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food


/obj/item/weapon/reagent_containers/food/snacks/candy
	name = "candy"
	cases = list("конфета", "конфеты", "конфете", "конфету", "конфетой", "конфете")
	desc = "Nougat, love it or hate it."
	filling_color = "#7d5f46"
	bitesize = 2
	list_reagents = list("nutriment" = 1, "sugar" = 3)
	food_type = JUNK_FOOD
	food_moodlet = /datum/mood_event/junk_food

/obj/item/weapon/reagent_containers/food/snacks/candy/donor
	name = "Donor Candy"
	cases = list("гематоген", "гематогена", "гематогену", "гематоген", "гематогенои", "гематогене")
	desc = "A little treat for blood donors."
	trash = /obj/item/trash/candy
	bitesize = 5
	list_reagents = list("nutriment" = 10, "sugar" = 3)
	food_type = TASTY_FOOD
	food_moodlet = /datum/mood_event/tasty_food

/obj/item/weapon/reagent_containers/food/snacks/candy_corn
	name = "candy corn"
	cases = list("сладкая кукуруза", "сладкой кукурузы", сладкой кукурузе", "сладкую кукурузу", "сладкой кукурузой", "сладкой кукурузе")
	desc = "It's a handful of candy corn. Cannot be stored in a detective's hat, alas."
	icon_state = "candy_corn"
	filling_color = "#fffcb0"
	bitesize = 2
	list_reagents = list("nutriment" = 4, "sugar" = 2)

/obj/item/weapon/reagent_containers/food/snacks/chips
	name = "chips"
	cases = list("чипсы", "чипсов", "чипсам", "чипсы", "чипсами", "чипсах")
	desc = "Commander Riker's What-The-Crisps"
	eat_sound = 'sound/items/chips_bite.ogg'
	w_class = SIZE_MIDGET
	icon_state = "chips-1"
	filling_color = "#e8c31e"
	bitesize = 2
	list_reagents = list("nutriment"= 1, "sodiumchloride" = 1)
	food_type = JUNK_FOOD
	food_moodlet = /datum/mood_event/junk_food

/obj/item/weapon/reagent_containers/food/snacks/chips/atom_init()
	. = ..()
	icon_state = "chips-[pick("1", "2", "3", "4")]"

/obj/item/weapon/reagent_containers/food/snacks/cookie
	name = "cookie"
	cases = list("печенье", "печенья", "печенью", "печенье", "печеньем", "печенье")
	desc = "COOKIE!!!"
	icon_state = "COOKIE!!!"
	filling_color = "#dbc94f"
	bitesize = 1
	list_reagents = list("nutriment" = 3)
//Peacekeeper stuff
/obj/item/weapon/reagent_containers/food/snacks/cookie/toxin_cookie
	list_reagents = list("pacid" = 5)

/obj/item/weapon/reagent_containers/food/snacks/chocolatebar
	name = "Chocolate Bar"
	cases = list("шоколад", "шоколада", "шоколаду", "шоколад", "шоколадом", "шоколаде")
	desc = "Such sweet, fattening food."
	icon_state = "chocolatebar"
	filling_color = "#7d5f46"
	bitesize = 2
	list_reagents = list("nutriment" = 2, "sugar" = 2, "coco" = 2)

/obj/item/weapon/reagent_containers/food/snacks/chocolateegg
	name = "Chocolate Egg"
	cases = list("шоколадное яйцо", "шоколадного яйца", "шоколадному яйцу", "шоколадное яйцо", "шоколадным яйцом", "шоколадном яйце")
	desc = "Such sweet, fattening food."
	icon_state = "chocolateegg"
	filling_color = "#7d5f46"
	bitesize = 2
	list_reagents = list("nutriment" = 4, "sugar" = 2, "coco" = 2, "egg" = 5)

/obj/item/weapon/reagent_containers/food/snacks/donut
	name = "donut"
	cases = list("пончик", "пончика", "пончику", "пончик", "пончиком", "пончике")
	desc = "Goes great with Robust Coffee."
	icon_state = "donut"
	filling_color = "#d9c386"
	var/donut_sprite_type = "plain"
	bitesize = 3
	food_type = null

/obj/item/weapon/reagent_containers/food/snacks/donut/atom_init()
	. = ..()
	icon_state = "[initial(icon_state)]_[donut_sprite_type]"

/obj/item/weapon/reagent_containers/food/snacks/donut/normal
	donut_sprite_type = "plain"
	list_reagents = list("nutriment" = 3, "sugar" = 3)

/obj/item/weapon/reagent_containers/food/snacks/donut/classic
	donut_sprite_type = "classic"
	list_reagents = list("nutriment" = 3, "sprinkles" = 3)

/obj/item/weapon/reagent_containers/food/snacks/donut/syndie
	donut_sprite_type = "classic"
	list_reagents = list("nutriment" = 3, "syndicream" = 3)

/obj/item/weapon/reagent_containers/food/snacks/donut/choco
	desc = "With tasty chocolate icing."
	donut_sprite_type = "choco"
	list_reagents = list("nutriment" = 2, "coco" = 2, "sprinkles" = 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/banana
	desc = "Clown will love this. HONK!"
	donut_sprite_type = "banana"
	list_reagents = list("nutriment" = 2, "banana" = 2, "kelotane" = 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/berry
	desc = "I love it berry much!"
	donut_sprite_type = "berries"
	filling_color = "#ed1169"
	list_reagents = list("nutriment" = 2, "berryjuice" = 2, "bicaridine" = 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly
	desc = "You jelly?"
	donut_sprite_type = "jelly"
	filling_color = "#ed1169"
	list_reagents = list("nutriment" = 2, "sprinkles" = 2, "cherryjelly" = 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/slimejelly
	desc = "You jelly?"
	donut_sprite_type = "jelly"
	filling_color = "#ed1169"
	list_reagents = list("nutriment" = 2, "sprinkles" = 2, "slimejelly" = 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/ambrosia
	desc = "Smells like grass..."
	donut_sprite_type = "ambrosia"
	filling_color = "#ed1169"
	list_reagents = list("nutriment" = 1, "anti_toxin" = 3, "plantmatter" = 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/chaos
	desc = "Chaos undivided - in this very donut!"
	donut_sprite_type = "chaos"
	filling_color = "#ed1169"

/obj/item/weapon/reagent_containers/food/snacks/donut/chaos/atom_init()
	. = ..()
	reagents.add_reagent(pick(global.chemical_reagents_list), 5)

/obj/item/weapon/reagent_containers/food/snacks/egg
	name = "egg"
	cases = list("яйцо", "яйца", "яйцу", "яйцо", "яйцом", "яйце")
	desc = "An egg!"
	icon_state = "egg"
	filling_color = "#fdffd1"
	list_reagents = list("nutriment" = 1, "egg" = 5)

/obj/item/weapon/reagent_containers/food/snacks/egg/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())
		return
	new /obj/effect/decal/cleanable/egg_smudge(loc)
	if(prob(13))
		if(global.chicken_count < MAX_CHICKENS)
			new /mob/living/simple_animal/chick(loc)
	// Yeah, eggs splash too it turns out.
	reagents.standard_splash(hit_atom, user=throwingdatum.thrower)
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
	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/egg/blue
	icon_state = "egg-blue"

/obj/item/weapon/reagent_containers/food/snacks/egg/green
	icon_state = "egg-green"

/obj/item/weapon/reagent_containers/food/snacks/egg/mime
	icon_state = "egg-mime"

/obj/item/weapon/reagent_containers/food/snacks/egg/orange
	icon_state = "egg-orange"

/obj/item/weapon/reagent_containers/food/snacks/egg/purple
	icon_state = "egg-purple"

/obj/item/weapon/reagent_containers/food/snacks/egg/rainbow
	icon_state = "egg-rainbow"

/obj/item/weapon/reagent_containers/food/snacks/egg/red
	icon_state = "egg-red"

/obj/item/weapon/reagent_containers/food/snacks/egg/yellow
	icon_state = "egg-yellow"

/obj/item/weapon/reagent_containers/food/snacks/friedegg
	name = "Fried egg"
	cases = list("яичница", "яичницы", "яичнице", "яичницу", "яичницей", "яичнице")
	desc = "A fried egg, with a touch of salt and pepper."
	icon_state = "friedegg"
	filling_color = "#ffdf78"
	bitesize = 1
	list_reagents = list("nutriment" = 3, "sodiumchloride" = 1, "blackpepper" = 1, "egg" = 5)

/obj/item/weapon/reagent_containers/food/snacks/boiledegg
	name = "Boiled egg"
	cases = list("варёное яйцо", "варёного яйца", "варёному яйцу", "варёное яйцо", "варёным яйцом", "варёном яйце")
	desc = "A hard boiled egg."
	icon_state = "egg"
	filling_color = "#ffffff"
	list_reagents = list("nutriment" = 2, "vitamin" = 1, "egg" = 5)

/obj/item/weapon/reagent_containers/food/snacks/appendix
//yes, this is the same as meat. I might do something different in future
	name = "appendix"
	cases = list("аппендикс", "аппендикса", "аппендиксу", "аппендикс", "аппендиксом", "аппендиксе")
	desc = "An appendix which looks perfectly healthy."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "appendix"
	filling_color = "#e00d34"
	bitesize = 3
	list_reagents = list("protein" = 3, "vitamin" = 2)
	food_type = NATURAL_FOOD
	food_moodlet = /datum/mood_event/natural_food

/obj/item/weapon/reagent_containers/food/snacks/appendix/inflamed
	name = "inflamed appendix"
	cases = list("воспалённый аппендикс", "воспалённого аппендикса", "воспалённому аппендиксу", "воспалённый аппендикс", "воспалённым аппендиксом", "воспалённом аппендиксе")
	desc = "An appendix which appears to be inflamed."
	icon_state = "appendixinflamed"
	filling_color = "#e00d7a"
	food_type = JUNK_FOOD
	food_moodlet = /datum/mood_event/junk_food

/obj/item/weapon/reagent_containers/food/snacks/tofu
	name = "Tofu"
	cases = list("тофу", "тофу", "тофу", "тофу", "тофу", "тофу")
	icon_state = "tofu"
	desc = "We all love tofu."
	filling_color = "#fffee0"
	bitesize = 3
	list_reagents = list("plantmatter" = 3)
	food_type = null

/obj/item/weapon/reagent_containers/food/snacks/tofurkey
	name = "Tofurkey"
	cases = list("тофу индейка", "тофу индейки", "тофу индейку", "тофу индейку", "тофу индейкой", "тофу индейке")
	desc = "A fake turkey made from tofu."
	icon_state = "tofurkey"
	filling_color = "#fffee0"
	bitesize = 3
	list_reagents = list("nutriment" = 12, "stoxin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/stuffing
	name = "Stuffing"
	cases = list("начинка", "начинки", "начинке", "начинку", "начинкой", "начинке")
	desc = "Moist, peppery breadcrumbs for filling the body cavities of dead birds. Dig in!"
	icon_state = "stuffing"
	filling_color = "#c9ac83"
	bitesize = 1
	list_reagents = list("nutriment" = 3)

/obj/item/weapon/reagent_containers/food/snacks/carpmeat
	name = "carp fillet"
	cases = list("филе карпа", "филе карпа", "филе карпа", "филе карпа", "филе карпа", "филе карпа")
	desc = "A fillet of spess carp meat"
	icon_state = "fishfillet"
	filling_color = "#ffdefe"
	bitesize = 6
	list_reagents = list("protein" = 3, "carpotoxin" = 3)
	food_type = NATURAL_FOOD
	food_moodlet = /datum/mood_event/natural_food

/obj/item/weapon/reagent_containers/food/snacks/fishfingers
	name = "Fish Fingers"
	cases = list("рыбные палочки", "рыбных палочек", "рыбным палочкам", "рыбные палочки", "рыбными палочками", "рыбных палочках")
	desc = "A finger of fish."
	icon_state = "fishfingers"
	filling_color = "#ffdefe"
	bitesize = 3
	list_reagents = list("protein" = 4, "carpotoxin" = 3)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice
	name = "huge mushroom slice"
	cases = list("огромный грибной ломтик", "огромного грибного ломтика", "огромному грибному ломтику", "огромный грибной ломтик", "огромным грибным ломтиком", "огромном грибном ломтике")
	desc = "A slice from a huge mushroom."
	icon_state = "hugemushroomslice"
	filling_color = "#e0d7c5"
	bitesize = 6
	list_reagents = list("plantmatter" = 3, "vitamin" = 1)
	food_type = NATURAL_FOOD
	food_moodlet = /datum/mood_event/natural_food

/obj/item/weapon/reagent_containers/food/snacks/tomatomeat
	name = "tomato slice"
	cases = list("ломтик помидора", "ломтика помидора", "ломтику помидора", "ломтик помидора", "ломтиком помидора", "ломтике помидора")
	desc = "A slice from a huge tomato"
	icon_state = "tomatomeat"
	filling_color = "#db0000"
	bitesize = 6
	list_reagents = list("protein" = 2)
	food_type = NATURAL_FOOD
	food_moodlet = /datum/mood_event/natural_food

/obj/item/weapon/reagent_containers/food/snacks/bearmeat
	name = "bear meat"
	cases = list("медвежатина", "медвежатины", "медвежатине","медвежатину", "медвежатиной", "медвежатине")
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"
	filling_color = "#db0000"
	bitesize = 3
	list_reagents = list("protein" = 12, "vodka" = 5, "vitamin" = 2)
	food_type = NATURAL_FOOD
	food_moodlet = /datum/mood_event/natural_food

/obj/item/weapon/reagent_containers/food/snacks/xenomeat
	name = "meat"
	cases = list("мясо", "мяса", "мясу", "мясо", "мясом", "мясе")
	desc = "A slab of meat."
	icon_state = "xenomeat"
	filling_color = "#43de18"
	bitesize = 6
	list_reagents = list("protein" = 3, "vitamin" = 1, "xenojelly_un" = 5)
	food_type = NATURAL_FOOD
	food_moodlet = /datum/mood_event/natural_food

/obj/item/weapon/reagent_containers/food/snacks/spidermeat
	name = "spider meat"
	cases = list("паучье мясо", "паучьего мяса", "паучьему мясу", "паучье мясо", "паучьим мясом", "паучьем мясе")
	desc = "A slab of spider meat."
	icon_state = "spidermeat"
	bitesize = 3
	list_reagents = list("protein" = 3, "toxin" = 2, "vitamin" = 1)
	food_type = JUNK_FOOD
	food_moodlet = /datum/mood_event/junk_food

/obj/item/weapon/reagent_containers/food/snacks/spiderleg
	name = "spider leg"
	cases = list("паучья лапка", "паучьей лапки", "паучьей лапке", "паучью лапку", "паучьей лапкой", "паучьей лапке")
	desc = "A still twitching leg of a giant spider... you don't really want to eat this, do you?"
	icon_state = "spiderleg"
	list_reagents = list("protein" = 2, "toxin" = 2)
	food_type = JUNK_FOOD
	food_moodlet = /datum/mood_event/junk_food

/obj/item/weapon/reagent_containers/food/snacks/meatball
	name = "meatball"
	cases = list("фрикаделька", "фрикадельки", "фрикадельке", "фрикадельку", "фрикаделькой", "фрикадельке")
	desc = "A great meal all round."
	icon_state = "meatball"
	filling_color = "#db0000"
	bitesize = 2
	list_reagents = list("protein" = 4, "vitamin" = 1)
	food_type = NATURAL_FOOD
	food_moodlet = /datum/mood_event/natural_food

/obj/item/weapon/reagent_containers/food/snacks/sausage
	name = "Sausage"
	cases = list("колбаса", "колбасы", "колбасе", "колбасу", "колбасой", "колбасе")
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	filling_color = "#db0000"
	bitesize = 2
	list_reagents = list("protein" = 6, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	name = "Donk-pocket"
	cases = list("донк-пакет", "донк-пакета", "донк-пакету", "донк-пакет", "донк-пакетом", "донк-пакете")
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	filling_color = "#dedeab"
	var/warm = FALSE
	food_type = null
	list_reagents = list("nutriment" = 4)

/obj/item/weapon/reagent_containers/food/snacks/brainburger
	name = "brainburger"
	cases = list("мозговой бургер", "мозгового бургера", "мозговому бургеру", "мозговой бургер", "мозговым бургером", "мозговом бургере")
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	filling_color = "#f2b6ea"
	bitesize = 2
	list_reagents = list("nutriment" = 2, "protein" = 4, "alkysine" = 6)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/ghostburger
	name = "Ghost Burger"
	cases = list("призрачный бургер", "призрачного бургера", "призрачному бургеру", "призрачный бургер", "призрачным бургером", "призрачном бургере")
	desc = "Spooky! It doesn't look very filling."
	icon_state = "ghostburger"
	filling_color = "#fff2ff"
	bitesize = 2
	list_reagents = list("nutriment" = 6, "ectoplasm" = 1)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/human
	var/hname = ""
	var/job = null
	filling_color = "#d63c3c"

/obj/item/weapon/reagent_containers/food/snacks/human/burger
	name = "-burger"
	cases = list("бургер", "бургера", "бургеру", "бургер", "бургером", "бургере")
	desc = "A bloody burger."
	icon_state = "hburger"
	bitesize = 2
	list_reagents = list("nutriment" = 2, "protein" = 4, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/cheeseburger
	name = "cheeseburger"
	cases = list("чизбургер", "чизбургера", "чизбургеру", "чизбургер", "чизбургером", "чизбургере")
	desc = "The cheese adds a good flavor."
	icon_state = "cheeseburger"
	list_reagents = list("nutriment" = 8, "cheese" = 8, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/monkeyburger
	name = "burger"
	cases = list("бургер", "бургера", "бургеру", "бургер", "бургером", "бургере")
	desc = "The cornerstone of every nutritious breakfast."
	icon_state = "hburger"
	filling_color = "#d63c3c"
	bitesize = 2
	list_reagents = list("nutriment" = 4, "protein" = 8, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/fishburger
	name = "Fillet -o- Carp Sandwich"
	cases = list("рыбный бургер", "рыбного бургера", "рыбному бургеру", "рыбный бургер", "рыбным бургером", "рыбном бургере")
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon_state = "fishburger"
	filling_color = "#ffdefe"
	bitesize = 3
	list_reagents = list("protein" = 6, "carpotoxin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/tofuburger
	name = "Tofu Burger"
	cases = list("тофу бургер", "тофу бургера", "тофу бургеру", "тофу бургер", "тофубургером", "тофу бургере")
	desc = "What.. is that meat?"
	icon_state = "tofuburger"
	filling_color = "#fffee0"
	bitesize = 2
	list_reagents = list("plantmatter" = 6, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/roburger
	name = "roburger"
	cases = list("робобургер", "робобургера", "робобургеру", "робобургер", "робобургером", "робобургере")
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	filling_color = "#cccccc"
	bitesize = 2
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/xenoburger
	name = "xenoburger"
	cases = list("ксенобургер", "ксенобургера", "ксенобургеру", "ксенобургер", "ксенобургером", "ксенобургере")
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	filling_color = "#43de18"
	bitesize = 2
	list_reagents = list("protein" = 6, "vitamin" = 1, "xenojelly_un" = 5)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/clownburger
	name = "Clown Burger"
	cases = list("клоун-бургер", "клоун-бургера", "клоун-бургеру", "клоун-бургер", "клоун-бургером", "клоун-бургере")
	desc = "This tastes funny... And HONKS!"
	icon_state = "clownburger"
	filling_color = "#ff00ff"
	bitesize = 2
	var/cooldown = FALSE
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/clownburger/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = world.time + 8
		playsound(src, 'sound/items/bikehorn.ogg', VOL_EFFECTS_MISC)
		add_fingerprint(user)
	return

/obj/item/weapon/reagent_containers/food/snacks/mimeburger
	name = "Mime Burger"
	cases = list("мим-бургер", "мим-бургера", "мим-бургеру", "мим-бургер", "мим-бургером", "мим-бургере")
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	filling_color = "#ffffff"
	bitesize = 2
	list_reagents = list("nutriment" = 6)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/omelette
	name = "Omelette Du Fromage"
	cases = list("омлет дю фромаж", "омлета дю фромаж", "омлету дю фромаж", "омлет дю фромаж", "омлетом дю фромаж", "омлете дю фромаж")
	desc = "That's all you can say!"
	icon_state = "omelette"
	trash = /obj/item/trash/plate
	filling_color = "#fff9a8"
	bitesize = 1
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/muffin
	name = "Muffin"
	cases = list("маффин", "маффина", "маффину", "маффин", "маффином", "маффине")
	desc = "A delicious and spongy little cake"
	icon_state = "muffin"
	filling_color = "#e0cf9b"
	bitesize = 2
	list_reagents = list("nutriment" = 6)

/obj/item/weapon/reagent_containers/food/snacks/pie
	name = "Banana Cream Pie"
	cases = list("банановый пирог", "бананового пирога", "банановому пирогу", "банановый пирог", "банановым пирогом", "банановом пироге")
	desc = "Just like back home, on clown planet! HONK!"
	icon_state = "pie"
	trash = /obj/item/trash/plate
	filling_color = "#fbffb8"
	bitesize = 3
	list_reagents = list("plantmatter" = 6, "banana" = 5, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/pie/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())
		return
	new/obj/effect/decal/cleanable/pie_smudge(src.loc)
	visible_message("<span class='rose'>[src.name] splats.</span>","<span class='rose'>You hear a splat.</span>")
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/berryclafoutis
	name = "Berry Clafoutis"
	cases = list("ягодный клафути", "ягодного клафути", "ягодному клафути", "ягодный клафути", "ягодным клафути", "ягодном клафути")
	desc = "No black birds, this is a good sign."
	icon_state = "berryclafoutis"
	trash = /obj/item/trash/plate
	bitesize = 3
	list_reagents = list("plantmatter" = 10, "berryjuice" = 5)

/obj/item/weapon/reagent_containers/food/snacks/waffles
	name = "waffles"
	cases = list("вафли", "вафель", "вафлями", "вафли", "вафлями", "вафлях")
	desc = "Mmm, waffles."
	icon_state = "waffles"
	trash = /obj/item/trash/waffles
	filling_color = "#e6deb5"
	bitesize = 2
	list_reagents = list("nutriment" = 8, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/eggplantparm
	name = "Eggplant Parmigiana"
	cases = list("баклажан пармиджано", "баклажана пармиджано", "баклажану пармиджано", "баклажан пармиджано", "баклажаном пармиджано", "баклажане пармиджано")
	desc = "The only good recipe for eggplant."
	icon_state = "eggplantparm"
	trash = /obj/item/trash/plate
	filling_color = "#4d2f5e"
	bitesize = 2
	list_reagents = list("nutriment" = 6, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/soylentgreen
	name = "Soylent Green"
	cases = list("зелёный сойлент", "зелёного сойлент", "зелёному сойленту", "зелёного сойлента", "зелёным сойлентом", "зелёном сойленте")
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles
	filling_color = "#b8e6b5"
	bitesize = 2
	list_reagents = list("protein" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/soylenviridians
	name = "Soylent Virdians"
	cases = list("вирдиановый сойлент", "вирдианового сойлента", "вирдиановому сойленту", "вирдианового сойлента", "вирдиановым сойлентом", "вирдиановом сойленте")
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles
	filling_color = "#e6fa61"
	bitesize = 2
	list_reagents = list("plantmatter" = 10, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/meatpie
	name = "Meat-pie"
	cases = list("мясной пирог", "мясного пирога", "мясному пирогу", "мясной пирог", "мясным пирогом", "мясном пироге")
	icon_state = "meatpie"
	desc = "An old barber recipe, very delicious!"
	trash = /obj/item/trash/plate
	filling_color = "#948051"
	bitesize = 2
	list_reagents = list("protein" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/tofupie
	name = "Tofu-pie"
	cases = list("тофу пирог", "тофу пирога", "тофу пирогу", "тофу пирог", "тофу пирогом", "тофу пироге")
	icon_state = "meatpie"
	desc = "A delicious tofu pie."
	trash = /obj/item/trash/plate
	filling_color = "#fffee0"
	bitesize = 2
	list_reagents = list("plantmatter" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/amanita_pie
	name = "amanita pie"
	cases = list("мухоморный пирог", "мухоморного пирога", "мухоморному пирогу", "мухоморный пирог", "мухоморным пирогом", "мухоморном пироге")
	desc = "Sweet and tasty poison pie."
	icon_state = "amanita_pie"
	filling_color = "#ffcccc"
	bitesize = 3
	list_reagents = list("plantmatter" = 5, "amatoxin" = 3, "psilocybin" = 1, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/plump_pie
	name = "plump pie"
	cases = list("пирог из толстошлемника", "пирога из толстошлемника", "пирогу из толстошлемника", "пирог из толстошлемника", "пирогом из толстошлемника", "пироге из толстошлемника")
	desc = "I bet you love stuff made out of plump helmets!"
	icon_state = "plump_pie"
	filling_color = "#b8279b"
	bitesize = 2
	list_reagents = list("nutriment" = 8, "tricordrazine" = 5, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/xemeatpie
	name = "Xeno-pie"
	cases = list("ксенопирог", "ксенопирога", "ксенопирогу", "ксенопирог", "ксенопирогом", "ксенопироге")
	icon_state = "xenomeatpie"
	desc = "A delicious meatpie. Probably heretical."
	trash = /obj/item/trash/plate
	filling_color = "#43de18"
	bitesize = 2
	list_reagents = list("protein" = 10, "vitamin" = 2, "xenojelly_un" = 5)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/wingfangchu
	name = "Wing Fang Chu"
	cases = list("винг фан чу", "винга фан чу", "вингу фан чу", "винга фан чу", "вингом фан чу", " винге фан чу")
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#43de18"
	bitesize = 2
	list_reagents = list("protein" = 6, "vitamin" = 2, "xenojelly_un" = 5)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/human/kabob
	name = "kabob"
	cases = list("кебаб", "кебаба", "кебабу", "кебаб", "кебабом", "кебабе")
	icon_state = "kabob"
	desc = "A human meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#a85340"
	bitesize = 2
	list_reagents = list("protein" = 8)

/obj/item/weapon/reagent_containers/food/snacks/kabob
	name = "Meat-kabob"
	cases = list("мясной кебаб", "мясного кебаба", "мясному кебабу", "мясной кебаб", "мясным кебабом", "мясном кебабе")
	icon_state = "kabob"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#a85340"
	bitesize = 2
	list_reagents = list("protein" = 8)

/obj/item/weapon/reagent_containers/food/snacks/tofukabob
	name = "Tofu-kabob"
	cases = list("тофу кебаб", "тофу кебаба", "тофу кебабу", "тофу кебаб", "тофу кебабом", "тофу кебабе")
	icon_state = "kabob"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/rods
	filling_color = "#fffee0"
	bitesize = 2
	list_reagents = list("plantmatter" = 8)

/obj/item/weapon/reagent_containers/food/snacks/cubancarp
	name = "Cuban Carp"
	cases = list("кубинский карп", "кубинского карпа", "кубинскому карпу", "кубинского карпа", "кубинским карпом", "кубинском карпе")
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate
	filling_color = "#e9adff"
	bitesize = 3
	list_reagents = list("protein" = 6, "carpotoxin" = 3, "capsaicin" = 3)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/popcorn
	name = "Popcorn"
	cases = list("попкорн", "попкорна", "попкорну", "попкорн", "попкорном", "попкорне")
	desc = "Now let's find some cinema."
	icon_state = "popcorn"
	trash = /obj/item/trash/popcorn
	var/unpopped = 0
	filling_color = "#fffad4"
	bitesize = 0.1 //this snack is supposed to be eating during looooong time. And this it not dinner food! --rastaf0
	list_reagents = list("nutriment" = 2)

/obj/item/weapon/reagent_containers/food/snacks/cornflakesbox
	name = "cornflakes box"
	cases = list("коробка кукурузных хлопьев", "коробки кукурузных хлопьев", "коробке кукурузных хлопьев", "коробку кукурузных хлопьев", "коробкой кукурузных хлопьев", "коробке кукурузных хлопьев")
	desc = "Хрустящие кукурузные хлопья"
	icon_state = "cereal_box"
	filling_color = "#fcb954"
	bitesize = 2
	list_reagents = list("nutriment" = 2, "vitamin" = 2, "honey" = 2)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

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
	cases = list("вяленое мясо", "вяленого мяса", "вяленому мясу", "вяленое мясо", "вяленым мясом", "вяленом мясе")
	icon_state = "sosjerky"
	desc = "Beef jerky made from the finest space cows."
	filling_color = "#631212"
	w_class = SIZE_MIDGET
	bitesize = 2
	list_reagents = list("protein" = 1, "sugar" = 1)
	food_type = JUNK_FOOD
	food_moodlet = /datum/mood_event/junk_food


/obj/item/weapon/reagent_containers/food/snacks/sosjerky/atom_init()
	. = ..()
	icon_state = "sosjerky-[pick("1", "2")]"

/obj/item/weapon/reagent_containers/food/snacks/no_raisin
	name = "4no Raisins"
	cases = list("изюм про100так", "изюма про100так", "изюму про100так", "изюм про100так", "изюмом про100так", "изюме про100так")
	icon_state = "4no_raisins"
	desc = "Most nutritious raisins in the universe. Not sure why."
	filling_color = "#343834"
	w_class = SIZE_MIDGET
	bitesize = 6
	list_reagents = list("plantmatter" = 3, "sugar" = 3)
	food_type = JUNK_FOOD
	food_moodlet = /datum/mood_event/junk_food


/obj/item/weapon/reagent_containers/food/snacks/no_raisin/atom_init()
	. = ..()
	icon_state = "4no_raisins-[pick("1", "2")]"

/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie
	name = "Space Twinkie"
	cases = list("космо-твинки", "космо-твинки", "космо-твинки", "космо-твинки", "космо-твинки", "космо-твинки")
	icon_state = "space_twinkie"
	desc = "Guaranteed to survive longer then you will."
	filling_color = "#ffe591"
	bitesize = 2
	list_reagents = list("sugar" = 4)
	food_type = JUNK_FOOD
	food_moodlet = /datum/mood_event/junk_food


/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers
	name = "Cheesie Honkers"
	cases = list("сырный хонкерс", "сырного хонкерса", "сырному хонкерсу", "сырный хонкерс", "сырным хонкерсом", "сырном хонкерсе")
	icon_state = "cheesie_honkers-1"
	desc = "Bite sized cheesie snacks that will honk all over your mouth."
	eat_sound = 'sound/items/chips_bite.ogg'
	w_class = SIZE_MIDGET
	filling_color = "#ffa305"
	bitesize = 2
	list_reagents = list("nutriment" = 1, "sugar" = 1)
	food_type = JUNK_FOOD
	food_moodlet = /datum/mood_event/junk_food

/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers/atom_init()
	. = ..()
	icon_state = "cheesie_honkers-[pick("1", "2", "3", "4")]"

/obj/item/weapon/reagent_containers/food/snacks/chinese/chowmein
	name = "chow mein"
	cases = list("чау-мейн", "чау-мейна", "чай-мейну", "чау-майна", "чау-мейном", "чай-мейне")
	desc = "What is in this anyways?"
	icon_state = "chinese1"
	trash = /obj/item/trash/chinese1
	list_reagents = list("nutriment" = 1, "beans" = 3, "sugar" = 2)

/obj/item/weapon/reagent_containers/food/snacks/chinese/sweetsourchickenball
	name = "Sweet & Sour Chicken Balls"
	cases = list("кисло-сладкие куриные фрикадельки", "кисло-сладких куриных фрикадельков", "кисло-сладким куриным фрикаделькам", "кисло-сладких куриных фрикадельков", "кисло-сладкими куриными фрикадельками", "кисло-сладких куриных фрикадельках")
	desc = "Is this chicken cooked? The odds are better than wok paper scissors."
	icon_state = "chickenball"
	trash = /obj/item/trash/snack_bowl
	list_reagents = list("nutriment" = 2, "sugar" = 2)

/obj/item/weapon/reagent_containers/food/snacks/chinese/tao
	name = "Admiral Yamamoto carp"
	cases = list("карп адмирала Ямамото", "карпа адмирала Ямамото", "карпу адмирала Ямамото", "карпа адмирала Ямамото", "карпом адмирала Ямамото", "карпе адмирала Ямамото")
	desc = "Tastes like chicken."
	icon_state = "chinese2"
	trash = /obj/item/trash/chinese2
	list_reagents = list("nutriment" = 1, "protein" = 1, "sugar" = 4)

/obj/item/weapon/reagent_containers/food/snacks/chinese/newdles
	name = "chinese newdles"
	cases = list("китайская лапша", "китайской лапши", "китайской лапше", "китайскую лапшу", "китайской лапшой", "китайской лапше")
	desc = "Made fresh, weekly!"
	icon_state = "chinese3"
	trash = /obj/item/trash/chinese3
	list_reagents = list("nutriment" = 1, "sugar" = 3)

/obj/item/weapon/reagent_containers/food/snacks/chinese/rice
	name = "fried rice"
	cases = list("жареный рис", "жареного риса", "жареному рису", "жареный рис", "жареным рисом", "жареном рисе")
	desc = "A timeless classic."
	icon_state = "chinese4"
	trash = /obj/item/trash/chinese4
	list_reagents = list("nutriment" = 1, "sugar" = 2, "rice" = 3)

/obj/item/weapon/reagent_containers/food/snacks/syndicake
	name = "Syndi-Cake"
	cases = list("синди-тортик", "синди-тортика", "синди-тортику", "синди-тортик", "синди-тортиком", "синди-тортике")
	icon_state = "syndi_cakes"
	desc = "An extremely moist snack cake that tastes just as good after being nuked."
	filling_color = "#ff5d05"
	bitesize = 3
	list_reagents = list("nutriment" = 4, "syndicream" = 5)

/obj/item/weapon/reagent_containers/food/snacks/syndicake/atom_init()
	. = ..()
	icon_state = "syndi_cakes-[pick("1", "2")]"

/obj/item/weapon/reagent_containers/food/snacks/loadedbakedpotato
	name = "Loaded Baked Potato"
	cases = list("запечёный картофель", "запечёного картофеля", "запечёному картофелю", "запечёный картофель", "запечёным картофелем", "запечёном картофеле")
	desc = "Totally baked."
	icon_state = "loadedbakedpotato"
	filling_color = "#9c7a68"
	bitesize = 2
	list_reagents = list("nutriment" = 6)

/obj/item/weapon/reagent_containers/food/snacks/fries
	name = "Space Fries"
	cases = list("космо-фри", "космо-фри", "космо-фри", "космо-фри", "космо-фри", "космо-фри")
	desc = "AKA: French Fries, Freedom Fries, etc."
	icon_state = "fries"
	trash = /obj/item/trash/plate
	filling_color = "#eddd00"
	bitesize = 2
	list_reagents = list("nutriment" = 8)

/obj/item/weapon/reagent_containers/food/snacks/soydope
	name = "Soy Dope"
	cases = list("соевая паста", "соевой пасты", "соевой пасте", "соевую пасту", "соевой пастой", "соевой пастой")
	desc = "Dope from a soy."
	icon_state = "soydope"
	trash = /obj/item/trash/plate
	filling_color = "#c4bf76"
	bitesize = 2
	list_reagents = list("nutriment" = 2)

/obj/item/weapon/reagent_containers/food/snacks/spagetti
	name = "Spaghetti"
	cases = list("спагетти", "спагетти", "спагетти", "спагетти", "спагетти", "спагетти")
	desc = "A bundle of raw spaghetti."
	icon_state = "spagetti"
	filling_color = "#eddd00"
	bitesize = 1
	list_reagents = list("nutriment" = 1, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries
	name = "Cheesy Fries"
	cases = list("сырный картофель фри", "сырного картофеля фри", "сырному картофелю фри", "сырный картофель фри", "сырным картофелем фри", "сырном картофеле фри")
	desc = "Fries. Covered in cheese. Duh."
	icon_state = "cheesyfries"
	trash = /obj/item/trash/plate
	filling_color = "#eddd00"
	bitesize = 2
	list_reagents = list("nutriment" = 12)

/obj/item/weapon/reagent_containers/food/snacks/fortunecookie
	name = "Fortune cookie"
	cases = list("печенье с предсказанием", "печенья с предсказанием", "печенью с предсказанием", "печенье с предсказанием", "печеньем с предсказанием", "печенье с предсказанием")
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"
	filling_color = "#e8e79e"
	bitesize = 2
	list_reagents = list("nutriment" = 3)

/obj/item/weapon/reagent_containers/food/snacks/badrecipe
	name = "Burned mess"
	cases = list("cгоревшее месиво", "cгоревшего месива", "cгоревшее месиво", "cгоревшим месивом", "cгоревшим месивом", "cгоревшем месиве")
	desc = "Someone should be demoted from chef for this."
	icon_state = "badrecipe"
	filling_color = "#211f02"
	bitesize = 2
	list_reagents = list("toxin" = 1, "carbon" = 3)
	food_type = JUNK_FOOD
	food_moodlet = /datum/mood_event/junk_food

/obj/item/weapon/reagent_containers/food/snacks/meatsteak
	name = "Meat steak"
	cases = list("мясной стейк", "мясного стейка", "мясному стейку", "мясной стейк", "мясным стейком", "мясном стейке")
	desc = "A piece of hot spicy meat."
	icon_state = "meatstake"
	trash = /obj/item/trash/plate
	filling_color = "#7a3d11"
	bitesize = 3
	list_reagents = list("protein" = 6, "sodiumchloride" = 1, "blackpepper" = 1)

/obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff
	name = "Spacy Liberty Duff"
	cases = list("Спейси Либерти пудинг, "Спейси Либерти пудинга", "Спейси Либерти пудингу", "Спейси Либерти пудинг", "Спейси Либерти пудингом", "Спейси Либерти пудинге")
	desc = "Jello gelatin, from Alfred Hubbard's cookbook."
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#42b873"
	bitesize = 3
	list_reagents = list("plantmatter" = 6, "psilocybin" = 6)

/obj/item/weapon/reagent_containers/food/snacks/amanitajelly
	name = "Amanita Jelly"
	cases = list("мухоморное желе", "мухоморного желе", "мухоморному желе", "мухоморное желе", "мухоморным желе", "мухоморном желе")
	desc = "Looks curiously toxic."
	icon_state = "amanitajelly"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#ed0758"
	bitesize = 3
	list_reagents = list("plantmatter" = 6, "amatoxin" = 6, "psilocybin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel
	name = "Poppy pretzel"
	cases = list("маковый крендель", "макового кренделя", "маковому кренделю", "маковый крендель", "маковым кренделем", "маковом кренделе")
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
	cases = list("свекольный суп", "свекольного супа", "свекольному супу", "свекольный суп", "свекольным супом", "свекольном супе")
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
			cases = list("борщ", "борща", "борщу", "борщ", "борщом", "борще")
		if(2)
			name = "bortsch"
			cases = list("борщ", "борща", "борщу", "борщ", "борщом", "борще")
		if(3)
			name = "borstch"
			cases = list("борщ", "борща", "борщу", "борщ", "борщом", "борще")
		if(4)
			name = "borsh"
			cases = list("борщ", "борща", "борщу", "борщ", "борщом", "борще")
		if(5)
			name = "borshch"
			cases = list("борщ", "борща", "борщу", "борщ", "борщом", "борще")
		if(6)
			name = "borscht"
			cases = list("борщ", "борща", "борщу", "борщ", "борщом", "борще")

/obj/item/weapon/reagent_containers/food/snacks/soup/stew
	name = "Stew"
	cases = list("рагу", "рагу", "рагу", "рагу", "рагу", "рагу")
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	filling_color = "#9e673a"
	bitesize = 10
	list_reagents = list("nutriment" = 10, "tomatojuice" = 5, "imidazoline" = 5, "water" = 5, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/soup/mushroomsoup
	name = "chantrelle soup"
	cases = list("грибной суп", "грибного супа", "грибному супу", "грибной суп", "грибным супом", "грибном супе")
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#e386bf"
	bitesize = 3
	list_reagents = list("plantmatter" = 8, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/soup/milosoup
	name = "Milosoup"
	cases = list("суп майло", "супа майло", "супу майло", "суп майло", "супом майло", "супе майло")
	desc = "The universes best soup! Yum!!!"
	icon_state = "milosoup"
	trash = /obj/item/trash/snack_bowl
	bitesize = 4
	list_reagents = list("nutriment" = 8, "water" = 5, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/soup/meatballsoup
	name = "Meatball soup"
	cases = list("суп с фрикадельками", "супа с фрикадельками", "супу с фрикадельками", "суп с фрикадельками", "супом с фрикадельками", "супе с фрикадельками")
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#785210"
	bitesize = 5
	list_reagents = list("protein" = 8, "water" = 5, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/soup/slimesoup
	name = "slime soup"
	cases = list("слизистый суп", "слизистого супа", "слизистому супу", "слизистый суп", "слизистым супом", "слизистом супе")
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup"
	filling_color = "#c4dba0"
	bitesize = 5
	list_reagents = list("nutriment" = 4, "slimejelly" = 5, "water" = 10, "vitamin" = 4)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/soup/bloodsoup
	name = "Blood soup"
	cases = list("кровавый суп", "кровавого супа", "кровавому супу", "кровавый суп", "кровавым супом", "кровавом супе")
	desc = "Smells like copper."
	icon_state = "tomatosoup"
	filling_color = "#ff0000"
	bitesize = 5
	list_reagents = list("protein" = 2, "blood" = 10, "water" = 5, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/soup/tomatosoup
	name = "Tomato Soup"
	cases = list("томатный суп", "томатного супа", "томатному супу", "томатный суп", "томатным супом", "томатном супе")
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#d92929"
	bitesize = 3
	list_reagents = list("plantmatter" = 5, "tomatojuice" = 10, "vitamin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/soup/clownstears
	name = "Clown's Tears"
	cases = list("слёзы клоуна", "слёз клоуна", "слезам клоуна", "слёзы клоуна", "слезами клоуна", "слезах клоуна")
	desc = "Not very funny."
	icon_state = "clownstears"
	filling_color = "#c4fbff"
	bitesize = 5
	list_reagents = list("nutriment" = 4, "banana" = 5, "water" = 10, "vitamin" = 8)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/soup/vegetablesoup
	name = "Vegetable soup"
	cases = list("овощной суп", "овощного супа", "овощному супу", "овощной суп", "овощным супом", "овощном супе")
	desc = "A true vegan meal." //TODO
	icon_state = "vegetablesoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#afc4b5"
	bitesize = 5
	list_reagents = list("plantmatter" = 8, "water" = 5, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/soup/nettlesoup
	name = "Nettle soup"
	cases = list("крапивный суп", "крапивного супа", "крапивному супу", "крапивный суп", "крапивным супом", "крапивном супе")
	desc = "To think, the botanist would've beat you to death with one of these."
	icon_state = "nettlesoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#afc4b5"
	bitesize = 5
	list_reagents = list("plantmatter" = 8, "water" = 5, "tricordrazine" = 5, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/soup/mysterysoup
	name = "Mystery soup"
	cases = list("загадочный суп", "загадочного супа", "загадочному супу", "загадочный суп", "загадочным супом", "загадочном супе")
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
	cases = list("суп-самозванец", "супа-самозванца", "супу-самозванцу", "суп-самозванец", "супом-самозванцем", "супе-самозванце")
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#d1f4ff"
	bitesize = 5
	list_reagents = list("water" = 10)
	food_type = null


/obj/item/weapon/reagent_containers/food/snacks/soup/wishsoup/atom_init()
	. = ..()
	if(prob(25))
		src.desc = "A wish come true!"
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("vitamin", 1)

//END SOUPS

/obj/item/weapon/reagent_containers/food/snacks/hotchili
	name = "Hot Chili"
	cases = list("горячее рагу с перцем чили", "горячего рагу с перцем чили", "горячему рагу с перцем чили", "горячее рагу с перцем чили", "горячим рагу с перцем чили", "горячем рагу с перцем чили")
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#ff3c00"
	bitesize = 5
	list_reagents = list("plantmatter" = 6, "capsaicin" = 3, "tomatojuice" = 2, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/coldchili
	name = "Cold Chili"
	cases = list("холодное рагу с перцем чили", "холодного рагу с перцем чили", "холодному рагу с перцем чили", "холодное рагу с перцем чили", "холодным рагу с перцем чили", "холодном рагу с перцем чили")
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	filling_color = "#2b00ff"
	bitesize = 5
	trash = /obj/item/trash/snack_bowl
	list_reagents = list("plantmatter" = 6, "frostoil" = 3, "tomatojuice" = 2, "vitamin" = 2)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

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
		user.drop_from_inventory(src, get_turf(target))
		return Expand()
	..()

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/entered_water_turf()
	Expand()

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/On_Consume(mob/M)
	to_chat(M, "<span class = 'warning'>Something inside of you suddently expands!</span>")

	if (ishuman(M))
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
	cases = list("магический бургер", "магического бургера", "магическому бургеру", "магический бургер", "магическим бургером", "магическом бургере")
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"
	filling_color = "#d505ff"
	bitesize = 2
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/bigbiteburger
	name = "Big Bite Burger"
	cases = list("большой бургер", "большого бургера", "большому бургеру", "большой бургер", "большим бургером", "большом бургере")
	desc = "Forget the Big Mac. THIS is the future!"
	icon_state = "bigbiteburger"
	filling_color = "#e3d681"
	bitesize = 3
	list_reagents = list("nutriment" = 4, "protein" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/enchiladas
	name = "Enchiladas"
	cases = list("энчилада", "энчилады", "энчиладе", "энчиладу", "энчиладой", "энчиладе")
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"
	trash = /obj/item/trash/tray
	filling_color = "#a36a1f"
	bitesize = 4
	list_reagents = list("protein" = 8, "capsaicin" = 6)

/obj/item/weapon/reagent_containers/food/snacks/monkeysdelight
	name = "monkey's Delight"
	cases = list("обезьянье наслаждение", "обезьяньего наслаждения", "обезьяньему наслаждению", "обезьянье наслаждение", "обезьяньим наслаждением", "обезьяньем наслаждении")
	desc = "Eeee Eee!"
	icon_state = "monkeysdelight"
	trash = /obj/item/trash/tray
	filling_color = "#5c3c11"
	bitesize = 6
	food_type = VERY_TASTY_FOOD
	list_reagents = list("nutriment" = 10, "banana" = 5, "blackpepper" = 1, "sodiumchloride" = 1, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/baguette
	name = "Baguette"
	cases = list("багет", "багета", "багету", "багет", "багетом", "багете")
	desc = "Bon appetit!"
	icon_state = "baguette"
	filling_color = "#e3d796"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "blackpepper" = 1, "sodiumchloride" = 1, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/fishandchips
	name = "Fish and Chips"
	cases = list("рыба и чипсы", "рыбы и чипсы", "рыбе и чипсы", "рыбе и чипсы", "рыбой и чипсы", "рыбе и чипсы")
	desc = "I do say so myself chap."
	icon_state = "fishandchips"
	filling_color = "#e3d796"
	bitesize = 3
	list_reagents = list("protein" = 6, "carpotoxin" = 3, "vitamin" = 2)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/sashimi
	name = "Carp sashimi"
	cases = list("карповое сашими", "карпового сашими", "карповому сашими", "карповое сашими", "карповым сашими", "карповом сашими")
	desc = "Celebrate surviving attack from hostile alien lifeforms by hospitalising yourself."
	icon_state = "sashimi"
	bitesize = 3
	list_reagents = list("protein" = 6, "capsaicin" = 3, "vitamin" = 2)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/sandwich
	name = "Sandwich"
	cases = list("сэндвич", "сэндвича", "сэндвичу", "сэндвич", "сэндвичем", "сэндвиче")
	desc = "A grand creation of meat, cheese, bread, and several leaves of lettuce! Arthur Dent would be proud."
	icon_state = "sandwich"
	trash = /obj/item/trash/plate
	filling_color = "#d9be29"
	bitesize = 2
	list_reagents = list("nutriment" = 6, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/toastedsandwich
	name = "Toasted Sandwich"
	cases = list("жареный сэндвич", "жареного сэндвича", "жареному сэндвичу", "жареный сэндвич", "жареным сэндвичем", "жареном сэндвиче")
	desc = "Now if you only had a pepper bar."
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	filling_color = "#d9be29"
	bitesize = 2
	list_reagents = list("nutriment" = 6, "carbon" = 2)

/obj/item/weapon/reagent_containers/food/snacks/grilledcheese
	name = "Grilled Cheese Sandwich"
	cases = list("сэндвич с запечённым сыром", "сэндвича с запечённым сыром", "сэндвичу с запечённым сыром", "сэндвич с запечённым сыром", "сэндвичем с запечённым сыром", "сэндвиче с запечённым сыром")
	desc = "Goes great with Tomato soup!"
	icon_state = "toastedsandwich"
	trash = /obj/item/trash/plate
	filling_color = "#d9be29"
	bitesize = 2
	list_reagents = list("nutriment" = 7, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/rofflewaffles
	name = "Roffle Waffles"
	cases = list("вафли роффле", "вафель роффле", "вафлям роффле", "вафли роффле", "вафлями роффле", "вафлях роффле")
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles
	filling_color = "#ff00f7"
	bitesize = 4
	list_reagents = list("nutriment" = 8, "psilocybin" = 8, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/jelliedtoast
	name = "Jellied Toast"
	cases = list("тост с джемом", "тоста с джемом", "тосту с джемом", "тост с джемом", "тостом с джемом", "тосте")
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
	cases = list("желе бургер", "желе бургера", "желе бургеру", "желе бургер", "желе бургером", "желе бургере")
	desc = "Culinary delight..?"
	icon_state = "jellyburger"
	filling_color = "#b572ab"
	bitesize = 2
	list_reagents = list("nutriment" = 5)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/slime
	list_reagents = list("slimejelly" = 5)

/obj/item/weapon/reagent_containers/food/snacks/jellyburger/cherry
	list_reagents = list("cherryjelly" = 5)

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat
	name = "Stewed Soy Meat"
	cases = list("тушёное соевое мясо", "тушёного соевого мяса", "тушёному соевому мясу", "тушёное соевое мясо", "тушёным соевым мясом", "тушёном соевом мясе")
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/plate
	bitesize = 2
	list_reagents = list("plantmatter" = 8)

/obj/item/weapon/reagent_containers/food/snacks/boiledspagetti
	name = "Boiled Spaghetti"
	cases = list("отварные спагетти", "отварных спагетти", "отварным спагетти", "отварные спагетти", "отварными спагетти", "отварных спагетти")
	desc = "A plain dish of noodles, this sucks."
	icon_state = "spagettiboiled"
	trash = /obj/item/trash/plate
	filling_color = "#fcee81"
	bitesize = 2
	list_reagents = list("plantmatter" = 2, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/boiledrice
	name = "Boiled Rice"
	cases = list("отварной рис", "отварного риса", "отварному рису", "отварной рис", "отварным рисом", "отварном рисе")
	desc = "A boring dish of boring rice."
	icon_state = "boiledrice"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#fffbdb"
	bitesize = 2
	list_reagents = list("plantmatter" = 5, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/sushi
	name = "Sushi"
	cases = list("суши", "суши", "суши", "суши", "суши", "суши")
	desc = "This is the Japanese preparation and serving of specially prepared vinegared rice combined with varied ingredients such as chiefly seafood"
	icon_state = "sushi"
	filling_color = "#fffbdb"
	bitesize = 2
	list_reagents = list("nutriment" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/ricepudding
	name = "Rice Pudding"
	cases = list("рисовый пудинг", "рисового пудинга", "рисовому пудингу", "рисовый пудинг", "рисовым пудингом", "рисовом пудинге")
	desc = "Where's the Jam!"
	icon_state = "rpudding"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#fffbdb"
	bitesize = 2
	list_reagents = list("plantmatter" = 4, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/pastatomato
	name = "Spaghetti"
	cases = list("паста с томатом", "пасты с томатом", "пасте с томатом", "пасту с томатом", "пастой с томатом", "пастес томатом")
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	trash = /obj/item/trash/plate
	filling_color = "#de4545"
	bitesize = 4
	list_reagents = list("plantmatter" = 6, "tomatojuice" = 10, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/meatballspagetti
	name = "Spaghetti & Meatballs"
	cases = list("спагетти с фрикадельками", "спагетти с фрикадельками", "спагетти с фрикадельками", "спагетти с фрикадельками", "спагетти с фрикадельками", "спагетти с фрикадельками")
	desc = "Now thats a nic'e meatball!"
	icon_state = "meatballspagetti"
	trash = /obj/item/trash/plate
	filling_color = "#de4545"
	bitesize = 2
	list_reagents = list("protein" = 8, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/spesslaw
	name = "Spesslaw"
	cases = list("спагетти адвоката", "спагетти адвоката", "спагетти адвоката", "спагетти адвоката", "спагетти адвоката", "спагетти адвоката")
	desc = "A lawyers favourite"
	icon_state = "spesslaw"
	filling_color = "#de4545"
	bitesize = 2
	list_reagents = list("protein" = 8, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel
	name = "Poppy Pretzel"
	cases = list("крендель с маком", "кренделя с маком", "кренделю с маком", "крендель с маком", "кренделем с маком", "кренделе с маком")
	desc = "A large soft pretzel full of POP!"
	icon_state = "poppypretzel"
	filling_color = "#ab7d2e"
	bitesize = 2
	list_reagents = list("plantmatter" = 5)

/obj/item/weapon/reagent_containers/food/snacks/carrotfries
	name = "Carrot Fries"
	cases = list("марковка-фри", "марковка-фри", "марковка-фри", "марковка-фри", "марковка-фри", "марковка-фри")
	desc = "Tasty fries from fresh Carrots."
	icon_state = "carrotfries"
	trash = /obj/item/trash/plate
	filling_color = "#faa005"
	bitesize = 2
	list_reagents = list("plantmatter" = 3, "imidazoline" = 3, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/superbiteburger
	name = "Super Bite Burger"
	cases = list("супер большой бургер", "супер большого бургера", "супер большому бургеру", "супер большой бургер", "супер большим бургером", "супер большом бургере")
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	filling_color = "#cca26a"
	bitesize = 10
	list_reagents = list("nutriment" = 32, "cheese" = 4, "protein" = 16, "vitamin" = 5)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/candiedapple
	name = "Candied Apple"
	cases = list("глазированное яблоко", "глазированного яблока", "глазированному яблоку", "глазированное яблоко", "глазированным яблоком", "глазированном яблоке")
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"
	filling_color = "#f21873"
	bitesize = 3
	list_reagents = list("nutriment" = 3, "sugar" = 2)

/obj/item/weapon/reagent_containers/food/snacks/applepie
	name = "Apple Pie"
	cases = list("яблочный пирог", "яблочного пирога", "яблочному пирогу", "яблочный пирог", "яблочным пирогом", "яблочном пироге")
	desc = "A pie containing sweet sweet love... or apple."
	icon_state = "applepie"
	filling_color = "#e0edc5"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/cherrypie
	name = "Cherry Pie"
	cases = list("вишнёвый пирог", "вишнёвого пирога", "вишнёвому пирогу", "вишнёвый пирог", "вишнёвым пирогом", "вишнёвом пироге")
	desc = "Taste so good, make a grown man cry."
	icon_state = "cherrypie"
	filling_color = "#ff525a"
	bitesize = 3
	list_reagents = list("nutriment" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/twobread
	name = "Two Bread"
	cases = list("два хлеба", "двух хлебов", "двум хлебам", "два хлеба", "двумя хлебами", "двух хлебах")
	desc = "It is very bitter and winy."
	icon_state = "twobread"
	filling_color = "#dbcc9a"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich
	name = "Jelly Sandwich"
	cases = list("бутерброд с джемом", "бутерброда с джемом", "бутерброду с джемом", "бутерброд с джемом", "бутербродом с джемом", "бутерброде с джемом")
	desc = "You wish you had some peanut butter to go with this..."
	icon_state = "jellysandwich"
	trash = /obj/item/trash/plate
	filling_color = "#9e3a78"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "vitamin" = 2)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime
	list_reagents = list("slimejelly" = 5)

/obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry
	list_reagents = list("cherryjelly" = 5)

/obj/item/weapon/reagent_containers/food/snacks/boiledslimecore
	name = "Boiled slime Core"
	cases = list("отварной слаймовый экстракт", "отварного слаймового экстракта", "отварному слаймовому экстракту", "отварной слаймовый экстракт", "отварным слаймовым экстрактом", "отварном слаймовом экстракте")
	desc = "A boiled red thing."
	icon_state = "boiledslimecore"
	bitesize = 3
	list_reagents = list("slimejelly" = 5)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/mint
	name = "mint"
	cases = list("мята", "мяты", "мяте", "мяту", "мятой", "мяте")
	desc = "it is only wafer thin."
	icon_state = "mint"
	filling_color = "#f2f2f2"
	bitesize = 1
	list_reagents = list("minttoxin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	cases = list("пухлый шлем бисквита", "пухлого шлема бисквита", "пухлому шлему бисквита", "пухлый шлем бисквита", "пухлым шлемом бисквита", "пухлом шлеме бисквита")
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"
	filling_color = "#cfb4c4"
	bitesize = 2
	food_type = NATURAL_FOOD
	food_moodlet = /datum/mood_event/natural_food


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
	cases = list("тяван-муси", "тяван-муси", "тяван-муси", "тяван-муси", "тяван-муси", "тяван-муси")
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#f0f2e4"
	bitesize = 1
	food_type = VERY_TASTY_FOOD
	list_reagents = list("nutriment" = 5)

/obj/item/weapon/reagent_containers/food/snacks/tossedsalad
	name = "tossed salad"
	cases = list("брошенный салат", "брошенного салата", "брошенному салату", "брошенный салат", "брошенным салатом", "брошенном салате")
	desc = "A proper salad, basic and simple, with little bits of carrot, tomato and apple intermingled. Vegan!"
	icon_state = "herbsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76b87f"
	bitesize = 3
	list_reagents = list("plantmatter" = 8, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/validsalad
	name = "valid salad"
	cases = list("действительный салат", "действительного салата", "действительному салату", "действительный салат", "действительным салатом", "действительном салате")
	desc = "It's just a salad of questionable 'herbs' with meatballs and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76b87f"
	bitesize = 3
	list_reagents = list("plantmatter" = 8, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/olivyesalad
	name = "Olivye salad"
	cases = list("салат оливье", "салата оливье", "салату оливье", "салат оливье", "салатом оливье", "салате оливье")
	desc = "It's a traditional salad dish in Russian cuisine."
	icon_state = "olivyesalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76b87f"
	bitesize = 3
	list_reagents = list("plantmatter" = 9, "vitamin" = 1, "protein" = 5)

/obj/item/weapon/reagent_containers/food/snacks/appletart
	name = "golden apple streusel tart"
	cases = list("золотой яблочный штрейзель", "золотого яблочного штрейзеля", "золотому яблочному штрейзелю", "золотого яблочного штрейзеля", "золотым яблочным штрейзелем", "золотом яблочном штрейзеле")
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	trash = /obj/item/trash/plate
	filling_color = "#ffff00"
	bitesize = 3
	list_reagents = list("plantmatter" = 8, "gold" = 5, "vitamin" = 4)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/////////////////////////////////////////////////Sliceable////////////////////////////////////////
// All the food items that can be sliced into smaller bits like Meatbread and Cheesewheels

/obj/item/weapon/reagent_containers/food/snacks/sliceable
	w_class = SIZE_SMALL
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
	user.SetNextMove(CLICK_CD_ACTION)
	if((slices_num <= 0 || !slices_num) || !slice_path)
		return FALSE
	var/inaccurate = FALSE
	if(!iscutter(W))
		inaccurate = TRUE

	if ( \
			!isturf(src.loc) || \
			!(locate(/obj/structure/table) in src.loc) && \
			!(locate(/obj/machinery/optable) in src.loc) && \
			!(locate(/obj/item/weapon/storage/visuals/tray) in src.loc) \
		)
		to_chat(user, "<span class='rose'>You cannot slice [src] here! You need a table or at least a tray to do it.</span>")
		return FALSE
	var/slices_lost = 0
	if(W.sharp)
		if(inaccurate)
			slices_lost = rand(1, min(1, round(slices_num * 0.5)))
			if(istype(W, /obj/item/weapon/melee/energy/sword))
				playsound(user, 'sound/items/esword_cutting.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			else
				playsound(user, 'sound/items/shard_cutting.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		else
			playsound(src, pick(SOUNDIN_KNIFE_CUTTING), VOL_EFFECTS_MASTER, null, FALSE)
		if(do_after(user, 35, target = src, can_move = FALSE))
			if(!inaccurate)
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
	cases = list("хлеб", "хлеба", "хлебу", "хлеб", "хлебом", "хлебе")
	icon_state = "Some plain old Earthen bread."
	icon_state = "bread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice
	slices_num = 5
	filling_color = "#ffe396"
	bitesize = 2
	list_reagents = list("nutriment" = 10, "bread" = 10)



/obj/item/weapon/reagent_containers/food/snacks/breadslice
	name = "Bread slice"
	cases = list("ломтик хлеба", "ломтика хлеба", "ломтику хлеба", "ломтик хлеба", "ломтиком хлеба", "ломтике хлеба")
	desc = "A slice of home."
	icon_state = "breadslice"
	trash = /obj/item/trash/plate
	filling_color = "#d27332"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/cheese
	name = "Cream Cheese Bread"
	cases = list("хлеб со сливочным сыром", "хлеба со сливочным сыром", "хлебу со сливочным сыром", "хлеб со сливочным сыром", "хлебом со сливочным сыром", "хлебе со сливочным сыром")
	desc = "Yum yum yum!"
	icon_state = "creamcheesebread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/cheese
	filling_color = "#fff896"
	list_reagents = list("nutriment" = 20, "cheese" = 10)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/cheese
	name = "Cream Cheese Bread slice"
	cases = list("ломтик хлеба со сливочным сыром", "ломтика хлеба со сливочным сыром", "ломтику хлеба со сливочным сыром", "ломтик хлеба со сливочным сыром", "ломтиком хлеба со сливочным сыром", "ломтике хлеба со сливочным сыром")
	desc = "A slice of yum!"
	icon_state = "creamcheesebreadslice"
	filling_color = "#fff896"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/meat
	name = "meatbread loaf"
	cases = list("", "", "", "", "", "")
	desc = "The culinary base of every self-respecting eloquen/tg/entleman."
	icon_state = "meatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/meat
	filling_color = "#ff7575"
	list_reagents = list("protein" = 20, "nutriment" = 10, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/meat
	name = "meatbread slice"
	cases = list("мясной хлеб", "мясного хлеба", "мясному хлебу", "мясным хлебом", "мясным хлебом", "мясном хлебе")
	desc = "A slice of delicious meatbread."
	icon_state = "meatbreadslice"
	filling_color = "#ff7575"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/xeno
	name = "xenomeatbread loaf"
	cases = list("ксенохлеб", "ксенохлеба", "ксенохлебу", "ксенохлеб", "ксенохлебом", "ксенохлебе")
	desc = "The culinary base of every self-respecting eloquent gentleman. Extra Heretical."
	icon_state = "xenomeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/xeno
	filling_color = "#8aff75"
	list_reagents = list("protein" = 20, "nutriment" = 10, "vitamin" = 5, "xenojelly_un" = 5)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/breadslice/xeno
	name = "xenomeatbread slice"
	cases = list("ломтик ксенохлеба", "ломтика ксенохлеба", "ломтику ксенохлеба", "ломтик ксенохлеба", "ломтиком ксенохлеба", "ломтике ксенохлеба")
	desc = "A slice of delicious meatbread. Extra Heretical."
	icon_state = "xenobreadslice"
	filling_color = "#8aff75"
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/spider
	name = "spider meat loaf"
	cases = list("паучий хлеб", "паучьего хлеба", "паучьему хлебу", "паучий хлеб", "паучьем хлебе", "паучьем хлебе")
	desc = "Reassuringly green meatloaf made from spider meat."
	icon_state = "spidermeatbread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/spider
	list_reagents = list("protein" = 20, "nutriment" = 10, "vitamin" = 5, "toxin" = 15)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/breadslice/spider
	name = "spider meat bread slice"
	cases = list("ломтик паучьего хлеба", "ломтика паучьего хлеба", "ломтику паучьего хлеба", "ломтик паучьего хлеба", "ломтиком паучьего хлеба", "ломтике паучьего хлеба")
	desc = "A slice of meatloaf made from an animal that most likely still wants you dead."
	icon_state = "xenobreadslice"
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food


/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/banana
	name = "Banana-nut bread"
	cases = list("бананово-ореховый хлеб", "бананово-орехового хлеба", "бананово-ореховому хлебу", "бананово-ореховый хлеб", "бананово-ореховым хлебом", "бананово-ореховом хлебе")
	desc = "A heavenly and filling treat."
	icon_state = "bananabread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/banana
	filling_color = "#ede5ad"
	list_reagents = list("banana" = 20, "nutriment" = 20)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/banana
	name = "Banana-nut bread slice"
	cases = list("ломтик бананово-орехового хлеба", "ломтика бананово-орехового хлеба", "ломтику бананово-орехового хлеба", "ломтик бананово-орехового хлеба", "ломтиком бананово-орехового хлеба", "ломтике бананово-орехового хлеба")
	desc = "A slice of delicious banana bread."
	icon_state = "bananabreadslice"
	filling_color = "#ede5ad"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread/tofu
	name = "Tofubread"
	cases = list("тофу хлеб", "тофу хлеба", "тофу хлебу", "тофу хлеб", "тофу хлебом", "тофу хлебе")
	icon_state = "Like meatbread but for vegetarians. Not guaranteed to give superpowers."
	icon_state = "tofubread"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/breadslice/tofu
	filling_color = "#f7ffe0"
	list_reagents = list("plantmatter" = 20, "vitamin" = 10)

/obj/item/weapon/reagent_containers/food/snacks/breadslice/tofu
	name = "Tofubread slice"
	cases = list("ломтик тофу хлеба", "ломтика тофу хлеба", "ломтику тофу хлеба", "ломтик тофу хлеба", "ломтиком тофу хлеба", "ломтике тофу хлеба")
	desc = "A slice of delicious tofubread."
	icon_state = "tofubreadslice"
	filling_color = "#f7ffe0"

// === CAKE ===

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake
	name = "Vanilla Cake"
	cases = list("ванильный торт", "ванильного торта", "ванильному торту", "ванильный торт", "ванильным тортом", "ванильном торте")
	desc = "A plain cake, not a lie."
	icon_state = "plaincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice
	slices_num = 5
	filling_color = "#f7edd5"
	bitesize = 2
	list_reagents = list("nutriment" = 20, "sugar" = 5)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/cakeslice
	name = "Vanilla Cake slice"
	cases = list("кусочек ванильного торта", "кусочка ванильного торта", "кусочку ванильного торта", "кусочек ванильного торта", "кусочком ванильного торта", "кусочке ванильного торта")
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "plaincake_slice"
	trash = /obj/item/trash/plate
	filling_color = "#f7edd5"
	bitesize = 2
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/birthday
	name = "Birthday Cake"
	cases = list("именинный торт", "именинного торта", "именинному торту", "именинный торт", "именинным тортом", "именинном торте")
	desc = "Happy Birthday..."
	icon_state = "birthdaycake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/birthday
	filling_color = "#ffd6d6"
	list_reagents = list("nutriment" = 20, "sprinkles" = 10, "sugar" = 5)
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/birthday
	name = "Birthday Cake slice"
	cases = list("кусочек именинного торта", "кусочка именинного торта", "кусочку именинного торта", "кусочек именинного торта", "кусочком именинного торта", "кусочке именинного торта")
	desc = "A slice of your birthday"
	icon_state = "birthdaycakeslice"
	filling_color = "#ffd6d6"
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/apple
	name = "Apple Cake"
	cases = list("яблочный торт", "яблочного торта", "яблочному торту", "яблочный торт", "яблочным тортом", "яблочном торте")
	desc = "A cake centred with Apple"
	icon_state = "applecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/apple
	filling_color = "#ebf5b8"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/apple
	name = "Apple Cake slice"
	cases = list("кусочек яблочного торта", "кусочка яблочного торта", "кусочку яблочного торта", "кусочек яблочного торта", "кусочком яблочного торта", "кусочке яблочного торта")
	desc = "A slice of heavenly cake."
	icon_state = "applecakeslice"
	filling_color = "#ebf5b8"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/pumpkin
	name = "Pumpkin Pie"
	cases = list("тыквенный пирог", "тыквенного пирога", "тыквенному пирогу", "тыквенный пирог", "тыквенным пирогом", "тыквенном пироге")
	desc = "A delicious treat for the autumn months."
	icon_state = "pumpkinpie"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/pumpkin
	filling_color = "#f5b951"
	list_reagents = list("nutriment" = 5, "vitamin" = 5, "sugar" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/pumpkin
	name = "Pumpkin Pie slice"
	cases = list("кусочек тыквенного пирога", "кусочка тыквенного пирога", "кусочку тыквенного пирога", "кусочек тыквенного пирога", "кусочком тыквенного пирога", "кусочке тыквенного пирога")
	desc = "A slice of pumpkin pie, with whipped cream on top. Perfection."
	icon_state = "pumpkinpieslice"
	filling_color = "#f5b951"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/carrot
	name = "Carrot Cake"
	cases = list("морковный торт", "морковного торта", "морковному торту", "морковный торт", "морковным тортом", "морковном торте")
	desc = "A favorite desert of a certain wascally wabbit. Not a lie."
	icon_state = "carrotcake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/carrot
	filling_color = "#ffd675"
	list_reagents = list("nutriment" = 20, "imidazoline" = 10, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/carrot
	name = "Carrot Cake slice"
	cases = list("кусочек морковного торта", "кусочка морковного торта", "кусочку морковного торта", "кусочек морковного торта", "кусочком морковного торта", "кусочке морковного торта")
	desc = "Carrotty slice of Carrot Cake, carrots are good for your eyes! Also not a lie."
	icon_state = "carrotcake_slice"
	filling_color = "#ffd675"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/brain
	name = "Brain Cake"
	cases = list("мозговой торт", "мозгового торта", "мозговому торту", "мозговой торт", "мозговым тортом", "мозговом торте")
	desc = "A squishy cake-thing."
	icon_state = "braincake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/brain
	filling_color = "#e6aedb"
	list_reagents = list("protein" = 10, "nutriment" = 10, "alkysine" = 10, "vitamin" = 5)
	food_type = VERY_TASTY_FOOD

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/brain
	name = "Brain Cake slice"
	cases = list("кусочек мозгового торта", "кусочка мозгового торта", "кусочку мозгового торта", "кусочек мозгового торта", "кусочком мозгового торта", "кусочке мозгового торта")
	desc = "Lemme tell you something about prions. THEY'RE DELICIOUS."
	icon_state = "braincakeslice"
	filling_color = "#e6aedb"
	food_type = VERY_TASTY_FOOD

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/cheese
	name = "Cheese Cake"
	cases = list("сырный торт", "сырного торта", "сырному торту", "сырный торт", "сырным тортом", "сырном торте")
	desc = "DANGEROUSLY cheesy."
	icon_state = "cheesecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/cheese
	filling_color = "#faf7af"
	list_reagents = list("nutriment" = 20, "cheese" = 10)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/cheese
	name = "Cheese Cake slice"
	cases = list("кусочек сырного торта", "кусочка сырного торта", "кусочку сырного торта", "кусочек сырного торта", "кусочком сырного торта", "кусочке сырного торта")
	desc = "Slice of pure cheestisfaction"
	icon_state = "cheesecake_slice"
	filling_color = "#faf7af"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/orange
	name = "Orange Cake"
	cases = list("апельсиновый торт", "апельсинового торта", "апельсиновому торту", "апельсиновый торт", "апельсиновым тортом", "апельсиновом торте")
	desc = "A cake with added orange."
	icon_state = "orangecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/orange
	filling_color = "#fada8e"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/orange
	name = "Orange Cake slice"
	cases = list("кусочек апельсинового торта", "кусочка апельсинового торта", "кусочку апельсинового торта", "кусочек апельсинового торта", "кусочком апельсинового торта", "кусочке апельсинового торта")
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "orangecake_slice"
	filling_color = "#fada8e"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/lime
	name = "Lime Cake"
	cases = list("лаймовый торт", "лаймового торта", "лаймовому торту", "лаймовый торт", "лаймовым тортом", "лаймовом торте")
	desc = "A cake with added lime."
	icon_state = "limecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/lime
	filling_color = "#cbfa8e"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/lime
	name = "Lime Cake slice"
	cases = list("кусочек лаймового торта", "кусочка лаймового торта", "кусочку лаймового торта", "кусочек лаймового торта", "кусочком лаймового торта", "кусочке лаймового торта")
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "limecake_slice"
	filling_color = "#cbfa8e"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/lemon
	name = "Lemon Cake"
	cases = list("лимонный торт", "лимонного торта", "лимонному торту", "лимонный торт", "лимонном торте", "лимонном торте")
	desc = "A cake with added lemon."
	icon_state = "lemoncake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/lemon
	filling_color = "#fafa8e"
	list_reagents = list("nutriment" = 20, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/lemon
	name = "Lemon Cake slice"
	cases = list("кусочек лимонного торта", "кусочка лимонного торта", "кусочку лимонного торта", "кусочек лимонного торта", "кусочком лимонного торта", "кусочке лимонного торта")
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "lemoncake_slice"
	filling_color = "#fafa8e"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/cake/chocolate
	name = "Chocolate Cake"
	cases = list("шоколадный торт", "шоколадного торта", "шоколадному торту", "шоколадный торт", "шоколадным тортом", "шоколадном торте")
	desc = "A cake with added chocolate"
	icon_state = "chocolatecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/chocolate
	filling_color = "#805930"
	list_reagents = list("nutriment" = 20, "coco" = 5)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/chocolate
	name = "Chocolate Cake slice"
	cases = list("кусочек шоколадного торта", "кусочка шоколадного торта", "кусочку шоколадного торта", "кусочек шоколадного торта", "кусочком шоколадного торта", "кусочке шоколадного торта")
	desc = "Just a slice of cake, it is enough for everyone."
	icon_state = "chocolatecake_slice"
	filling_color = "#805930"

// === PIZZA ===

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza
	slices_num = 6
	filling_color = "#baa14c"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice
	filling_color = "#baa14c"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/margherita
	name = "Margherita"
	cases = list("Маргарита", "Маргариты", "Маргарите", "Маргариту", "Маргаритой", "Маргарите")
	desc = "The golden standard of pizzas."
	icon_state = "pizzamargherita"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/margherita
	list_reagents = list("plantmatter" = 30, "tomatojuice" = 6, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/margherita
	name = "Margherita slice"
	cases = list("кусочек Маргариты", "кусочка Маргариты", "кусочку Маргариты", "кусочек Маргариты", "кусочком Маргариты", "кусочке Маргариты")
	desc = "A slice of the classic pizza."
	icon_state = "pizzamargheritaslice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/meat
	name = "Meatpizza"
	cases = list("мясная пицца", "мясной пиццы", "мясной пицце", "мясную пиццу", "мясной пиццей", "мясной пицце")
	desc = "A pizza with meat topping."
	icon_state = "meatpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/meat
	list_reagents = list("protein" = 30, "tomatojuice" = 6, "vitamin" = 8)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/meat
	name = "Meatpizza slice"
	cases = list("кусочек мясной пиццы", "кусочка мясной пиццы", "кусочку мясной пиццы", "кусочек мясной пиццы", "кусочком мясной пиццы", "кусочке мясной пиццы")
	desc = "A slice of a meaty pizza."
	icon_state = "meatpizzaslice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/mushroom
	name = "Mushroompizza"
	cases = list("грибная пицца", "грибной пиццы", "грибной пицце", "грибную пиццу", "грибной пиццей", "грибной пицце")
	desc = "Very special pizza"
	icon_state = "mushroompizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/mushroom
	list_reagents = list("plantmatter" = 30, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/mushroom
	name = "Mushroompizza slice"
	cases = list("кусочек грибной пиццы", "кусочка грибной пиццы", "кусочку грибной пиццы", "кусочек грибной пиццы", "кусочком грибной пиццы", "кусочке грибной пиццы")
	desc = "Maybe it is the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/pizza/vegetable
	name = "Vegetable pizza"
	cases = list("овощная пицца", "овощной пиццы", "овощной пицце", "овощную пиццу", "овощной пиццей", "овощной пицце")
	desc = "No one of Tomato Sapiens were harmed during making this pizza"
	icon_state = "vegetablepizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/vegetable
	list_reagents = list("plantmatter" = 25, "tomatojuice" = 6, "imidazoline" = 12, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/vegetable
	name = "Vegetable pizza slice"
	cases = list("кусочек овощной пиццы", "кусочка овощной пиццы", "кусочку овощной пиццы", "кусочек овощной пиццы", "кусочком овощной пиццы", "кусочке овощной пиццы")
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients "
	icon_state = "vegetablepizzaslice"

// pizzabox code

/obj/item/pizzabox
	name = "pizza box"
	cases = list("коробка пиццы", "коробки пиццы", "коробке пиццы", "коробку пиццы", "коробкой пиццы", "коробке пиццы")
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
				user.drop_from_inventory(box, src)

				box.boxes = list() // Clear the box boxes so we don't have boxes inside boxes. - Xzibit
				boxes.Add( boxestoadd )

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
			user.drop_from_inventory(I, src)
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
	cases = list("головка сыра", "головки сыра", "головке сыра", "головку сыра", "головкой сыра", "головке сыра")
	desc = "A big wheel of delcious Cheddar."
	icon_state = "cheesewheel"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	slices_num = 5
	filling_color = "#fff700"
	list_reagents = list("nutriment" = 15, "vitamin" = 5, "cheese" = 20)
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	name = "Cheese wedge"
	cases = list("ломтик сыра", "ломтика сыра", "ломтику сыра", "ломтик сыра", "ломтиком сыра", "ломтике сыра")
	desc = "A wedge of delicious Cheddar. The cheese wheel it was cut from can't have gone far."
	icon_state = "cheesewedge"
	filling_color = "#fff700"
	bitesize = 2
	food_type = NATURAL_FOOD
	food_moodlet = /datum/mood_event/natural_food


/obj/item/weapon/reagent_containers/food/snacks/watermelonslice
	name = "Watermelon Slice"
	cases = list("кусочек арбуза", "кусочка арбуза", "кусочку арбуза", "кусочек арбуза", "кусочком арбуза", "кусочке арбуза")
	desc = "A slice of watery goodness."
	icon_state = "watermelonslice"
	filling_color = "#ff3867"
	bitesize = 2
	food_type = NATURAL_FOOD
	food_moodlet = /datum/mood_event/natural_food

/obj/item/weapon/reagent_containers/food/snacks/cracker
	name = "Cracker"
	cases = list("крекер", "крекера", "крекеру", "крекер", "крекером", "крекере")
	desc = "It's a salted cracker."
	icon_state = "cracker"
	filling_color = "#f5deb8"
	list_reagents = list("nutriment" = 1)

/obj/item/weapon/reagent_containers/food/snacks/dionaroast
	name = "roast diona"
	cases = list("жаркое из дионы", "жаркого из дионы", "жаркому из дионы", "жаркое из дионы", "жарким из дионы", "жарком из дионы")
	desc = "It's like an enormous, leathery carrot. With an eye."
	icon_state = "dionaroast"
	trash = /obj/item/trash/plate
	filling_color = "#75754b"
	bitesize = 2
	list_reagents = list("plantmatter" = 4, "nutriment" = 2, "radium" = 2, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg
	name = "boiled spider leg"
	cases = list("отварная паучья лапка", "отварной паучьей лапки", "отварной паучьей лапке", "отварную паучью лапку", "отварной паучьей лапкой", "отварной паучьей лапке")
	desc = "A giant spider's leg that's still twitching after being cooked. Gross!"
	icon_state = "spiderlegcooked"
	trash = /obj/item/trash/plate
	bitesize = 3
	list_reagents = list("nutriment" = 3, "capsaicin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/spidereggs
	name = "spider eggs"
	cases = list("паучьи яйца", "паучьих яиц", "паучьим яйцам", "паучьи яйца", "паучьими яйцами", "паучьих яйцах")
	desc = "A cluster of juicy spider eggs. A great side dish for when you care not for your health."
	icon_state = "spidereggs"
	food_type = VERY_TASTY_FOOD
	list_reagents = list("protein" = 2, "toxin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/spidereggsham
	name = "green eggs and ham"
	cases = list("имитация паучьего яйца с мясом", "имитации паучьего яйца с мясом", "имитации паучьего яйца с мясом", "имитацию паучьего яйца с мясом", "имитацией паучьего яйца с мясом", "имитации паучьего яйца с мясом")
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
	cases = list("тесто", "теста", "тесту", "тесто", "тестом", "тесте")
	desc = "A piece of dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "dough"
	bitesize = 2
	list_reagents = list("nutriment" = 6)
	food_type = JUNK_FOOD
	food_moodlet = /datum/mood_event/junk_food

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
	cases = list("раскатанное тесто", "раскатанного теста", "раскатанному тесту", "раскатанное тесто", "раскатанным тестом", "раскатанном тесте")
	desc = "A flattened dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "flat dough"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/doughslice
	slices_num = 3
	list_reagents = list("nutriment" = 6)
	food_type = JUNK_FOOD
	food_moodlet = /datum/mood_event/junk_food

/obj/item/weapon/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	cases = list("кусочек теста", "кусочка теста", "кусочку теста", "кусочек теста", "кусочком теста", "кусочке теста")
	desc = "A building block of an impressive dish."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "doughslice"
	bitesize = 2
	list_reagents = list("nutriment" = 1)
	food_type = JUNK_FOOD
	food_moodlet = /datum/mood_event/junk_food

/obj/item/weapon/reagent_containers/food/snacks/blin
	name = "blin"
	cases = list("блин", "блина", "блину", "блин", "блином", "блине")
	desc = "Первый - комом!"
	icon = 'icons/obj/food.dmi'
	icon_state = "blin"
	item_state_world = "blin_world"
	filling_color = "#fabc60"
	bitesize = 2
	list_reagents = list("nutriment" = 5)

/obj/item/weapon/reagent_containers/food/snacks/bun
	name = "bun"
	cases = list("булочка", "булочки", "булочке", "булочку", "булочкой", "булочке")
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
	cases = list("тако", "тако", "тако", "тако", "тако", "тако")
	desc = "Take a bite!"
	icon_state = "taco"
	bitesize = 3
	list_reagents = list("nutriment" = 7, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/rawcutlet
	name = "raw cutlet"
	cases = list("сырая котлета", "сырой котлеты", "сырой котлете", "сырую котлету", "сырой котлетой", "сырой котлете")
	desc = "A thin piece of raw meat."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawcutlet"
	bitesize = 1
	list_reagents = list("nutriment" = 1)
	food_type = JUNK_FOOD
	food_moodlet = /datum/mood_event/junk_food

/obj/item/weapon/reagent_containers/food/snacks/cutlet
	name = "cutlet"
	cases = list("котлета", "котлеты", "котлете", "котлету", "котлетой", "котлете")
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
	cases = list("сырой мясной шарик", "сырого мясного шарика", "сырому мясному шарику", "сырой мясной шарик", "сырым мясным шариком", "сыром мясном шарике")
	desc = "A raw meatball."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawmeatball"
	bitesize = 2
	list_reagents = list("protein" = 2)
	food_type = JUNK_FOOD
	food_moodlet = /datum/mood_event/junk_food

/obj/item/weapon/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	cases = list("хотдог", "хотдога", "хотдогу", "хотдог", "хотдогом", "хотдоге")
	desc = "Unrelated to dogs, maybe."
	icon_state = "hotdog"
	bitesize = 2
	list_reagents = list("protein" = 12)

/obj/item/weapon/reagent_containers/food/snacks/flatbread
	name = "flatbread"
	cases = list("лепёшка", "лепёшки", "лепёшке", "лепёшку", "лепёшкой", "лепёшке")
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
	cases = list("сырые картофельные палочки", "сырых картофельных палочек", "сырым картофельным палочкам", "сырые картофельные палочки", "сырыми картофельными палочками", "сырых картофельных палочках")
	desc = "Raw fries, not very tasty."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "rawsticks"
	bitesize = 2
	list_reagents = list("plantmatter" = 3)

////////////////////////////////FOOD ADDITIONS////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/beans
	name = "tin of beans"
	cases = list("банка с бобами", "банки с бобами", "банке с бобами", "банка с бобами", "банкой с бобами", "банке с бобами")
	desc = "Musical fruit in a slightly less musical container."
	icon_state = "beans"
	bitesize = 2
	list_reagents = list("nutriment" = 10, "vitamin" = 3, "beans" = 10)

/obj/item/weapon/reagent_containers/food/snacks/wrap
	name = "egg wrap"
	cases = list("рап с яйцом", "рапа с яйцом", "рапу с яйцом", "рап с яйцом", "рапом с яйцом", "рапе с яйцом")
	desc = "The precursor to Pigs in a Blanket."
	icon_state = "wrap"
	bitesize = 2
	list_reagents = list("nutriment" = 5)

/obj/item/weapon/reagent_containers/food/snacks/benedict
	name = "eggs benedict"
	cases = list("яйца бенедикт", "яиц бенедикт", "яйцам бенедикт", "яйца бенедикт", "яйцами бенедикт", "яйцах бенедикт")
	desc = "There is only one egg on this, how rude."
	icon_state = "benedict"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 4, "egg" = 3)

/obj/item/weapon/reagent_containers/food/snacks/meatbun
	name = "meat bun"
	cases = list("мясная булочка", "мясной булочки", "мясной булочке", "мясную булочку", "мясной булочкой", "мясной булочке")
	desc = "Has the potential to not be Dog."
	icon_state = "meatbun"
	bitesize = 2
	list_reagents = list("protein" = 6)

/obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich
	name = "icecream sandwich"
	cases = list("сэндвич с мороженым", "сэндвича с мороженым", "сэндвичу с мороженым", "сэндвич с мороженым", "сэндвичем с мороженым", "сэндвиче с мороженым")
	desc = "Portable Ice-cream in it's own packaging."
	icon_state = "icecreamsanwich"
	bitesize = 1
	list_reagents = list("nutriment" = 2, "ice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/notasandwich
	name = "not-a-sandwich"
	cases = list("не-сэндвич", "не-сэндвича", "не-сэндвичу", "не-сэндвич", "не-сэндвичем", "не-сэндвиче")
	desc = "Something seems to be wrong with this, you can't quite figure what. Maybe it's his moustache."
	icon_state = "notasandwich"
	bitesize = 2
	list_reagents = list("nutriment" = 6, "vitamin" = 6)

/obj/item/weapon/reagent_containers/food/snacks/sugarcookie
	name = "sugar cookie"
	cases = list("сахарное печенье", "сахарного печенья", "сахарному печенью", "сахарное печенье", "сахарным печеньем", "сахарном печенье")
	desc = "Just like your little sister used to make."
	icon_state = "sugarcookie"
	bitesize = 2
	list_reagents = list("nutriment" = 3, "sugar" = 3)

/obj/item/weapon/reagent_containers/food/snacks/friedbanana
	name = "Fried Banana"
	cases = list("жареный банан", "жареного банана", "жареному банану", "жареный банан", "жареным бананом", "жареном банане")
	desc = "Goreng Pisang, also known as fried bananas."
	icon_state = "friedbanana"
	bitesize = 4
	list_reagents = list("sugar" = 5, "nutriment" = 8, "cornoil" = 4)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/turkey
	name = "Turkey"
	cases = list("индейка", "индейки", "индейке", "индейку", "индейкой", "индейке")
	desc = "A traditional turkey served with stuffing."
	icon_state = "turkey"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/turkeyslice
	slices_num = 6
	bitesize = 3
	list_reagents = list("protein" = 24, "nutriment" = 18, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/turkeyslice
	name = "turkey serving"
	cases = list("порция индейки", "порции индейки", "порции индейки", "порцию индейки", "порцией индейки", "порции индейки")
	desc = "A serving of some tender and delicious turkey."
	icon_state = "turkeyslice"
	trash = /obj/item/trash/plate
	filling_color = "#b97a57"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/herbsalad
	name = "herb salad"
	cases = list("салат с травами", "салата с травами", "салату с травами", "салат с травами", "салатом с травами", "салате с травами")
	desc = "A tasty salad with apples on top."
	icon_state = "herbsalad"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#76b87f"
	bitesize = 3
	list_reagents = list("nutriment" = 8)

/obj/item/weapon/reagent_containers/food/snacks/burrito
	name = "Burrito"
	cases = list("буррито", "буррито", "буррито", "буррито", "буррито", "буррито")
	desc = "Meat, beans, cheese, and rice wrapped up as an easy-to-hold meal."
	icon_state = "burrito"
	trash = /obj/item/trash/plate
	filling_color = "#a36a1f"
	bitesize = 1
	list_reagents = list("protein" = 5)

/obj/item/weapon/reagent_containers/food/snacks/raw_bacon
	name = "raw bacon"
	cases = list("сырой бекон", "сырого бекона", "сырому бекону", "сырой бекон", "сырым беконом", "сыром беконе")
	desc = "It's fleshy and pink!"
	icon_state = "raw_bacon"
	bitesize = 3
	list_reagents = list("protein" = 1)

/obj/item/weapon/reagent_containers/food/snacks/bacon
	name = "bacon"
	cases = list("бекон", "бекона", "бекону", "бекон", "беконом", "беконе")
	desc = "It looks juicy and tastes amazing!"
	icon_state = "bacon"
	bitesize = 3
	list_reagents = list("protein" = 7)

/obj/item/weapon/reagent_containers/food/snacks/telebacon
	name = "Tele Bacon"
	cases = list("теле бекон", "теле бекона", "теле бекону", "теле бекон", "теле беконом", "теле беконе")
	desc = "It tastes a little odd but it is still delicious."
	icon_state = "bacon_tele"
	bitesize = 1
	list_reagents = list("protein" = 6)

/obj/item/weapon/reagent_containers/food/snacks/salmonsteak
	name = "Salmon steak"
	cases = list("стейк из лосося", "стейка из лосося", "стейку из лосося", "стейк из лосося", "стейком из лосося", "стейке из лосося")
	desc = "A piece of freshly-grilled salmon meat."
	icon_state = "salmonsteak"
	trash = /obj/item/trash/plate
	filling_color = "#7a3d11"
	bitesize = 4
	list_reagents = list("protein" = 4, "sodiumchloride" = 1, "blackpepper" = 1, "anti_toxin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge
	name = "Fudge"
	cases = list("помадка", "помадки", "помадке", "помадку", "помадкой", "помадке")
	desc = "Chocolate fudge, a timeless classic treat."
	icon_state = "fudge"
	filling_color = "#7d5f46"
	bitesize = 3
	list_reagents = list("cream" = 2, "nutriment" = 4)

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/cherry
	name = "Chocolate Cherry Fudge"
	cases = list("вишнёвая помадка", "вишнёвой помадки", "вишнёвой помадке", "вишнёвую помадку", "вишнёвой помадкой", "вишнёвой помадке")
	desc = "Chocolate fudge surrounding sweet cherries. Good for tricking kids into eating some fruit."
	icon_state = "fudge_cherry"
	filling_color = "#7d5f46"
	bitesize = 3
	list_reagents = list("cream" = 3, "nutriment" = 6)

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/cookies_n_cream
	name = "Cookies 'n' Cream Fudge"
	cases = list("сливочная помадка", "сливочной помадке", "сливочной помадке", "сливочную помадку", "сливочной помадкой", "сливочной помадке")
	desc = "An extra creamy fudge with bits of real chocolate cookie mixed in. Crunchy!"
	icon_state = "fudge_cookies_n_cream"
	filling_color = "#7d5f46"
	bitesize = 3
	list_reagents = list("cream" = 5, "nutriment" = 4)

/obj/item/weapon/reagent_containers/food/snacks/candy/fudge/turtle
	name = "Turtle Fudge"
	cases = list("черепашья помадка", "черепашьей помадки", "черепашьей помадке", "черепашью помадку", "черепашьей помадкой", "черепашьей помадке")
	desc = "Chocolate fudge with caramel and nuts. It doesn't contain real turtles, thankfully."
	icon_state = "fudge_turtle"
	filling_color = "#7d5f46"
	bitesize = 3
	list_reagents = list("cream" = 2, "nutriment" = 6)

/obj/item/weapon/reagent_containers/food/snacks/candy/toffee
	name = "Toffee"
	cases = list("тоффи", "тоффи", "тоффи", "тоффи", "тоффи", "тоффи")
	desc = "A hard, brittle candy with a distinctive taste."
	icon_state = "toffee"
	filling_color = "#7d5f46"
	bitesize = 2
	list_reagents = list("nutriment" = 3, "sugar" = 3)

/obj/item/weapon/reagent_containers/food/snacks/candy/caramel
	name = "Caramel"
	cases = list("карамель", "карамели", "карамели", "карамель", "карамелью", "карамели")
	desc = "Chewy and dense, yet it practically melts in your mouth!"
	icon_state = "caramel"
	filling_color = "#db944d"
	bitesize = 2
	list_reagents = list("cream" = 2, "sugar" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/candycane
	name = "candy cane"
	cases = list("леденец", "леденца", "леденцу", "леденец", "леденцом", "леденце")
	desc = "A festive mint candy cane."
	icon_state = "candycane"
	filling_color = "#f2f2f2"
	bitesize = 2
	list_reagents = list("sugar" = 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/taffy
	name = "Saltwater Taffy"
	cases = list("ириска", "", "ириске", "ириску", "ириской", "ириске")
	desc = "Old fashioned saltwater taffy. Chewy!"
	icon_state = "candy1"
	filling_color = "#7d5f46"
	bitesize = 4
	list_reagents = list("nutriment" = 2, "sugar" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/nougat
	name = "Nougat"
	cases = list("нуга", "нуги", "нуге", "нугу", "нугойю", "нуге")
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
	cases = list("сахарная вата", "сахарной ваты", "сахарной вате", "сахарную вату", "сахарной ватой", "сахарной вате")
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_plain"
	filling_color = "#ffffff"
	trash = /obj/item/weapon/c_tube
	bitesize = 3
	list_reagents = list("sugar" = 15)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/red
	name = "cotton candy"
	cases = list("сахарная вата", "сахарной ваты", "сахарной вате", "сахарную вату", "сахарной ватой", "сахарной вате")
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_red"
	filling_color = "#801e28"
	trash = /obj/item/weapon/c_tube
	bitesize = 4
	list_reagents = list("cherryjelly" = 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/blue
	name = "cotton candy"
	cases = list("красная сахарная вата", "красной сахарной ваты", "красной сахарной вате", "красную сахарную вату", "красной сахарной ватой", "красной сахарной вате")
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_blue"
	filling_color = "#863333"
	trash = /obj/item/weapon/c_tube
	bitesize = 4
	list_reagents = list("berryjuice" = 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/green
	name = "cotton candy"
	cases = list("зелёная сахарная вата", "зелёной сахарной ваты", "зелёной сахарной вате", "зелёную сахарную вату", "зелёной сахарной ватой", "зелёной сахарной вате")
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_green"
	filling_color = "#365e30"
	trash = /obj/item/weapon/c_tube
	bitesize = 4
	list_reagents = list("limejuice" = 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/yellow
	name = "cotton candy"
	cases = list("жёлтая сахарная вата", "жёлтой сахарной ваты", "жёлтой сахарной вате", "жёлтую сахарную вату", "жёлтой сахарной ватой", "жёлтой сахарной вате")
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_yellow"
	filling_color = "#863333"
	trash = /obj/item/weapon/c_tube
	bitesize = 4
	list_reagents = list("lemonjuice" = 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/orange
	name = "cotton candy"
	cases = list("оранжевая сахарная вата", "оранжевой сахарной ваты", "оранжевой сахарной вате", "оранжевую сахарную вату", "оранжевой сахарной ватой", "оранжевой сахарной вате")
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_orange"
	filling_color = "#e78108"
	trash = /obj/item/weapon/c_tube
	bitesize = 4
	list_reagents = list("orangejuice" = 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/purple
	name = "cotton candy"
	cases = list("фиолетовая сахарная вата", "фиолетовой сахарной ваты", "фиолетовой сахарной вате", "фиолетовую сахарную вату", "фиолетовой сахарной ватой", "фиолетовой сахарной вате")
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_purple"
	filling_color = "#993399"
	trash = /obj/item/weapon/c_tube
	bitesize = 4
	list_reagents = list("grapejuice" = 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/pink
	name = "cotton candy"
	cases = list("розовая сахарная вата", "розовой сахарной ваты", "розовой сахарной вате", "розовую сахарную вату", "розовой сахарной ватой", "розовой сахарной вате")
	desc = "Light and fluffy, it's like eating a cloud made from sugar!"
	icon_state = "cottoncandy_pink"
	filling_color = "#863333"
	trash = /obj/item/weapon/c_tube
	bitesize = 4
	list_reagents = list("watermelonjuice" = 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/cotton/rainbow
	name = "cotton candy"
	cases = list("радужная сахарная вата", "радужной сахарной ваты", "радужной сахарной вате", "радужную сахарную вату", "радужной сахарной ватой", "радужной сахарной вате")
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
	cases = list("мармеладный мишка", "мармеладного мишки", "мармеладному мишке", "мармеладного мишку", "мармеладным мишкой", "мармеладном мишке")
	desc = "A small edible bear. It's squishy and chewy!"
	icon_state = "gbear"
	filling_color = "#ffffff"
	bitesize = 3
	list_reagents = list("sugar" = 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm
	name = "gummy worm"
	cases = list("мармеладный червяк", "мармеладного червяка", "мармеладному червяку", "мармеладного червяка", "мармеладным червяком", "мармеладном червяке")
	desc = "An edible worm, made from gelatin."
	icon_state = "gworm"
	filling_color = "#ffffff"
	bitesize = 3
	list_reagents = list("sugar" = 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean
	name = "jelly bean"
	cases = list("желейный боб", "желейного боба", "желейному бобу", "желейный боб", "желейным бобом", "желейном бобе")
	desc = "A candy bean, guarenteed to not give you gas."
	icon_state = "jbean"
	filling_color = "#ffffff"
	bitesize = 3
	list_reagents = list("sugar" = 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/jawbreaker
	name = "jawbreaker"
	cases = list("леденец", "леденца", "леденцу", "леденец", "леденцом", "леденце")
	desc = "An unbelievably hard candy. The name is fitting."
	icon_state = "jawbreaker"
	filling_color = "#ed0758"
	bitesize = 0.1	//this is gonna take a while, you'll be working at this all shift.
	list_reagents = list("sugar" = 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/cash
	name = "candy cash"
	cases = list("шоколадная купюра", "шоколадной купюры", "шоколадной купюре", "шоколадную купюру", "шоколадной купюрой", "шоколадной купюре")
	desc = "Not legal tender. Tasty though."
	icon_state = "candy_cash"
	filling_color = "#302000"
	bitesize = 2
	list_reagents = list("nutriment" = 2, "hot_coco" = 4)

/obj/item/weapon/reagent_containers/food/snacks/candy/coin
	name = "chocolate coin"
	cases = list("шоколадная монета", "шоколадной монеты", "шоколадной монете", "шоколадную монету", "шоколадной монетой", "шоколадной монете")
	desc = "Probably won't work in the vending machines."
	icon_state = "choc_coin"
	filling_color = "#302000"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "hot_coco" = 4)


/obj/item/weapon/reagent_containers/food/snacks/candy/gum
	name = "bubblegum"
	cases = list("жвачка", "жвачки", "жвачке", "жвачку", "жвачкой", "жвачке")
	desc = "Chewy!"
	icon_state = "bubblegum"
	filling_color = "#ff7495"
	bitesize = 0.2
	list_reagents = list("sugar" = 5)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker
	name = "sucker"
	cases = list("чупа-чупс", "чупа-чупса", "чупа-чупсу", "чупа-чупс", "чупа-чупсом", "чупа-чупсе")
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
	cases = list("красный мармеладный мишка", "красного мармеладного мишки", "красному мармеладному мишке", "красного мармеладного мишку", "красным мармеладным мишкой", "красном мармеладном мишке")
	desc = "A small edible bear. It's red!"
	icon_state = "gbear_red"
	filling_color = "#801e28"
	bitesize = 3
	list_reagents = list("cherryjelly" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/blue
	name = "gummy bear"
	cases = list("синий мармеладный мишка", "синего мармеладного мишки", "синему мармеладному мишке", "синего мармеладного мишку", "синим мармеладным мишкой", "синем мармеладном мишке")
	desc = "A small edible bear. It's blue!"
	icon_state = "gbear_blue"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("berryjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/green
	name = "gummy bear"
	cases = list("зелёный мармеладный мишка", "зелёного мармеладного мишки", "зелёному мармеладному мишке", "зелёного мармеладного мишку", "зелёным мармеладным мишкой", "зелёном мармеладном мишке")
	desc = "A small edible bear. It's green!"
	icon_state = "gbear_green"
	filling_color = "#365e30"
	bitesize = 3
	list_reagents = list("limejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/yellow
	name = "gummy bear"
	cases = list("жёлтый мармеладный мишка", "жёлтого мармеладного мишки", "жёлтому мармеладному мишке", "жёлтого мармеладного мишку", "жёлтым мармеладным мишкой", "жёлтом мармеладном мишке")
	desc = "A small edible bear. It's yellow!"
	icon_state = "gbear_yellow"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("lemonjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/orange
	name = "gummy bear"
	cases = list("оранжевый мармеладный мишка", "оранжевого мармеладного мишки", "оранжевому мармеладному мишке", "оранжевого мармеладного мишку", "оранжевым мармеладным мишкой", "оранжевом мармеладном мишке")
	desc = "A small edible bear. It's orange!"
	icon_state = "gbear_orange"
	filling_color = "#e78108"
	bitesize = 3
	list_reagents = list("orangejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/purple
	name = "gummy bear"
	cases = list("фиолетовый мармеладный мишка", "фиолетового мармеладного мишки", "фиолетовому мармеладному мишке", "фиолетового мармеладного мишку", "фиолетовым мармеладным мишкой", "фиолетовом мармеладном мишке")
	desc = "A small edible bear. It's purple!"
	icon_state = "gbear_purple"
	filling_color = "#993399"
	bitesize = 3
	list_reagents = list("grapejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummybear/wtf
	name = "gummy bear"
	cases = list("wtf мармеладный мишка", "wtf мармеладного мишки", "wtf мармеладному мишке", "wtf мармеладного мишку", "wtf мармеладным мишкой", "wtf мармеладном мишке")
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
	cases = list("красный мармеладный червяк", "красного мармеладного червяка", "красному мармеладному червяку", "красного мармеладного червяка", "красным мармеладным червяком", "красном мармеладном червяке")
	desc = "An edible worm, made from gelatin. It's red!"
	icon_state = "gworm_red"
	filling_color = "#801e28"
	bitesize = 3
	list_reagents = list("cherryjelly" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/blue
	name = "gummy worm"
	cases = list("синий мармеладный червяк", "синего мармеладного червяка", "синему мармеладному червяку", "синего мармеладного червяка", "синим мармеладным червяком", "синем мармеладном червяке")
	desc = "An edible worm, made from gelatin. It's blue!"
	icon_state = "gworm_blue"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("berryjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/green
	name = "gummy worm"
	cases = list("зелёный мармеладный червяк", "зелёного мармеладного червяка", "зелёному мармеладному червяку", "зелёного мармеладного червяка", "зелёным мармеладным червяком", "зелёном мармеладном червяке")
	desc = "An edible worm, made from gelatin. It's green!"
	icon_state = "gworm_green"
	filling_color = "#365e30"
	bitesize = 3
	list_reagents = list("limejuice" = 10)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/yellow
	name = "gummy worm"
	cases = list("жёлтый мармеладный червяк", "жёлтого мармеладного червяка", "жёлтому мармеладному червяку", "жёлтого мармеладного червяка", "жёлтым мармеладным червяком", "жёлтом мармеладном червяке")
	desc = "An edible worm, made from gelatin. It's yellow!"
	icon_state = "gworm_yellow"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("lemonjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/orange
	name = "gummy worm"
	cases = list("оранжевый мармеладный червяк", "оранжевого мармеладного червяка", "оранжевому мармеладному червяку", "оранжевого мармеладного червяка", "оранжевым мармеладным червяком", "оранжевом мармеладном червяке")
	desc = "An edible worm, made from gelatin. It's orange!"
	icon_state = "gworm_orange"
	filling_color = "#e78108"
	bitesize = 3
	list_reagents = list("orangejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/purple
	name = "gummy worm"
	cases = list("фиолетовый мармеладный червяк", "мармеладного червяка", "фиолетовому мармеладному червяку", "фиолетового мармеладного червяка", "фиолетовым мармеладным червяком", "фиолетовом мармеладном червяке")
	desc = "An edible worm, made from gelatin. It's purple!"
	icon_state = "gworm_purple"
	filling_color = "#993399"
	bitesize = 3
	list_reagents = list("grapejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/pink
	name = "gummy worm"
	cases = list("розовый мармеладный червяк", "розового мармеладного червяка", "розовому мармеладному червяку", "розового мармеладного червяка", "розовом мармеладным червяком", "розовом мармеладном червяке")
	desc = "An edible worm, made from gelatin. It's pink!"
	icon_state = "gworm_pink"
	filling_color = "#fc73a7"
	bitesize = 3
	list_reagents = list("watermelonjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/wtf
	name = "gummy worm"
	cases = list("wtf мармеладный червяк", "wtf мармеладного червяка", "wtf мармеладному червяку", "wtf мармеладного червяка", "wtf мармеладным червяком", "wtf мармеладном червяке")
	desc = "An edible worm. Did it just move?"
	icon_state = "gworm_wtf"
	filling_color = "#60a584"
	bitesize = 3
	list_reagents = list("space_drugs" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/gummyworm/rainbow
	name = "gummy worm"
	cases = list("радужный мармеладный червяк", "радужного мармеладного червяка", "радужному мармеладному червяку", "радужного мармеладного червяка", "радужным мармеладным червяком", "радужном мармеладном червяке")
	desc = "An edible worm, made from gelatin. It's rainbow!"
	icon_state = "gworm_rainbow"
	filling_color = "#c8a5dc"
	bitesize = 4
	list_reagents = list("nutriment" = 20, "psilocybin" = 1)

///////////////////////////////////////////
// JELLY BEANS :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/red
	name = "jelly bean"
	cases = list("красный желейный боб", "красного желейного боба", "красному желейному бобу", "красный желейный боб", "красным желейным бобом", "красном желейном бобе")
	desc = "A candy bean, guarenteed to not give you gas. It's red!"
	icon_state = "jbean_red"
	filling_color = "#801e28"
	bitesize = 3
	list_reagents = list("cherryjelly" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/blue
	name = "jelly bean"
	cases = list("синий желейный боб", "синего желейного боба", "синему желейному бобу", "синий желейный боб", "синим желейным бобом", "синем желейном бобе")
	desc = "A candy bean, guarenteed to not give you gas. It's blue!"
	icon_state = "jbean_blue"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("berryjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/green
	name = "jelly bean"
	cases = list("зелёный желейный боб", "зелёного желейного боба", "зелёному желейному бобу", "зелёный желейный боб", "зелёным желейным бобом", "зелёном желейном бобе")
	desc = "A candy bean, guarenteed to not give you gas. It's green!"
	icon_state = "jbean_green"
	filling_color = "#365e30"
	bitesize = 3
	list_reagents = list("limejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/yellow
	name = "jelly bean"
	cases = list("жёлтый желейный боб", "жёлтого желейного боба", "жёлтому желейному бобу", "жёлтый желейный боб", "жёлтым желейным бобом", "жёлтом желейном бобе")
	desc = "A candy bean, guarenteed to not give you gas. It's yellow!"
	icon_state = "jbean_yellow"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("lemonjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/orange
	name = "jelly bean"
	cases = list("оранжевый желейный боб", "оранжевого желейного боба", "оранжевому желейному бобу", "оранжевый желейный боб", "оранжевым желейным бобом", "оранжевом желейном бобе")
	desc = "A candy bean, guarenteed to not give you gas. It's orange!"
	icon_state = "jbean_orange"
	filling_color = "#e78108"
	bitesize = 3
	list_reagents = list("orangejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/purple
	name = "jelly bean"
	cases = list("фиолетовый желейный боб", "фиолетового желейного боба", "фиолетовому желейному бобу", "фиолетовый желейный боб", "фиолетовым желейным бобом", "фиолетовом желейном бобе")
	desc = "A candy bean, guarenteed to not give you gas. It's purple!"
	icon_state = "jbean_purple"
	filling_color = "#993399"
	bitesize = 3
	list_reagents = list("grapejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/chocolate
	name = "jelly bean"
	cases = list("шоколадный желейный боб", "шоколадного желейного боба", "шоколадному желейному бобу", "шоколадный желейный боб", "шоколадным желейным бобом", "шоколадном желейном бобе")
	desc = "A candy bean, guarenteed to not give you gas. It's chocolate!"
	icon_state = "jbean_choc"
	filling_color = "#302000"
	bitesize = 3
	list_reagents = list("hot_coco" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/popcorn
	name = "jelly bean"
	cases = list("попкорновый желейный боб", "попкорнового желейного боба", "попкорновому желейному бобу", "попкорновый желейный боб", "попкорновым желейным бобом", "попкорновом желейном бобе")
	desc = "A candy bean, guarenteed to not give you gas. It's popcorn flavored!"
	icon_state = "jbean_popcorn"
	filling_color = "#664330"
	bitesize = 3
	list_reagents = list("nutriment" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/cola
	name = "jelly bean"
	cases = list("желейный боб с колой", "желейного боба с колой", "желейному бобу с колой", "желейный боб с колой", "желейным бобом с колой", "желейном бобе с колой")
	desc = "A candy bean, guarenteed to not give you gas. It's Cola flavored!"
	icon_state = "jbean_cola"
	filling_color = "#102000"
	bitesize = 3
	list_reagents = list("cola" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/drgibb
	name = "jelly bean"
	cases = list("желейный боб с доктор Гибб", "желейного боба с доктор Гибб", "желейному бобу с доктор Гиббом", "желейный боб с доктор Гиббом", "желейным бобом с доктор Гиббом", "желейном бобе с доктор Гиббом")
	desc = "A candy bean, guarenteed to not give you gas. It's Dr. Gibb flavored!"
	icon_state = "jbean_cola"
	filling_color = "#102000"
	bitesize = 3
	list_reagents = list("dr_gibb" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/coffee
	name = "jelly bean"
	cases = list("желейный боб с кофе", "желейного боба с кофе", "желейному бобу с кофе", "желейный боб с кофе", "желейным бобом с кофе", "желейном бобе с кофе")
	desc = "A candy bean, guarenteed to not give you gas. It's Coffee flavored!"
	icon_state = "jbean_choc"
	filling_color = "#482000"
	bitesize = 3
	list_reagents = list("coffee" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/jellybean/wtf
	name = "jelly bean"
	cases = list("wtf желейный боб", "wtf желейного боба", "wtf желейному бобу", "wtf желейный боб", "wtf желейным бобом", "wtf желейном бобе")
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
	cases = list("шоколадная плитка", "шоколадной плитки", "шоколадной плитке", "шоколадную плитку", "шоколадной плиткой", "шоколадной плитке")
	desc = "Nougat, love it or hate it."
	icon_state = "candy"
	trash = /obj/item/trash/candy
	filling_color = "#7d5f46"

/obj/item/weapon/reagent_containers/food/snacks/candy/rice
	name = "Asteroid Crunch Bar"
	cases = list("астероидный шоколад", "астероидного шоколада", "астероидному шоколаду", "астероидный шоколад", "астероидным шоколадом", "астероидном шоколаде")
	desc = "Crunchy rice deposits in delicious chocolate! A favorite of miners galaxy-wide."
	icon_state = "asteroidcrunch"
	trash = /obj/item/trash/candy
	filling_color = "#7d5f46"

/obj/item/weapon/reagent_containers/food/snacks/candy/yumbaton
	name = "Yum-baton Bar"
	cases = list("шоколадная дубинка", "шоколадной дубинки", "шоколадной дубинке", "шоколадную дубинку", "шоколадной дубинкой", "шоколадной дубинке")
	desc = "Chocolate and toffee in the shape of a baton. Security sure knows how to pound these down!"
	icon_state = "yumbaton"
	item_state = "baton"
	filling_color = "#7d5f46"

/obj/item/weapon/reagent_containers/food/snacks/candy/malper
	name = "Malper Bar"
	cases = list("шоколадный шприц", "шоколадного шприца", "шоколадному шприцу", "шоколадный шприц", "шоколадным шприцем", "шоколадном шприце")
	desc = "A chocolate syringe filled with a caramel injection. Just what the doctor ordered!"
	icon_state = "malper"
	filling_color = "#7d5f46"

/obj/item/weapon/reagent_containers/food/snacks/candy/caramel_nougat
	name = "Toxins Test Bar"
	cases = list("шоколадная бомба", "шоколадной бомбы", "шоколадной бомбе", "шоколадную бомбу", "шоколадной бомбой", "шоколадной бомбе")
	desc = "An explosive combination of chocolate, caramel, and nougat. Research has never been so tasty!"
	icon_state = "toxinstest"
	filling_color = "#7d5f46"

/obj/item/weapon/reagent_containers/food/snacks/candy/toolerone
	name = "Tool-erone Bar"
	cases = list("шоколадный гаечный ключ", "шоколадного гаечного ключа", "шоколадному гаечному ключу", "шоколадный гаечный ключ", "шоколадным гаечным ключом", "шоколадномгаечном ключе ")
	desc = "Chocolate-covered nougat, shaped like a wrench. Great for an engineer on the go!"
	icon_state = "toolerone"
	filling_color = "#7d5f46"

///////////////////////////////////////////
// SUCKERS! :3
///////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/red
	name = "sucker"
	cases = list("красный чупа-чупс", "красного чупа-чупса", "красному чупа-чупсу", "красный чупа-чупс", "красным чупа-чупсом", "красном чупа-чупсе")
	desc = "For being such a good sport! It's red!"
	icon_state = "sucker_red"
	filling_color = "#801e28"
	bitesize = 3
	list_reagents = list("cherryjelly" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/blue
	name = "sucker"
	cases = list("синий чупа-чупс", "синего чупа-чупса", "синему чупа-чупсу", "синий чупа-чупс", "синим чупа-чупсом", "синем чупа-чупсе")
	desc = "For being such a good sport! It's blue!"
	icon_state = "sucker_blue"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("berryjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/green
	name = "sucker"
	cases = list("зелёный чупа-чупс", "зелёного чупа-чупса", "зелёному чупа-чупсу", "зелёный чупа-чупс", "зелёным чупа-чупсом", "зелёном чупа-чупсе")
	desc = "For being such a good sport! It's green!"
	icon_state = "sucker_green"
	filling_color = "#365e30"
	bitesize = 3
	list_reagents = list("limejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/yellow
	name = "sucker"
	cases = list("жёлтый чупа-чупс", "жёлтого чупа-чупса", "жёлтому чупа-чупсу", "жёлтый чупа-чупс", "жёлтым чупа-чупсом", "жёлтом чупа-чупсе")
	desc = "For being such a good sport! It's yellow!"
	icon_state = "sucker_yellow"
	filling_color = "#863333"
	bitesize = 3
	list_reagents = list("lemonjuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/orange
	name = "sucker"
	cases = list("оранжевый чупа-чупс", "оранжевого чупа-чупса", "оранжевому чупа-чупсу", "оранжевый чупа-чупс", "оранжевым чупа-чупсом", "оранжевом чупа-чупсе")
	desc = "For being such a good sport! It's orange!"
	icon_state = "sucker_orange"
	filling_color = "#e78108"
	bitesize = 3
	list_reagents = list("orangejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/purple
	name = "sucker"
	cases = list("фиолетовый чупа-чупс", "фиолетового чупа-чупса", "фиолетовому чупа-чупсу", "фиолетовый чупа-чупс", "фиолетовым чупа-чупсом", "фиолетовом чупа-чупсе")
	desc = "For being such a good sport! It's purple!"
	icon_state = "sucker_purple"
	filling_color = "#993399"
	bitesize = 3
	list_reagents = list("grapejuice" = 2)

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/mystery
	name = "sucker?"
	cases = list("загадочный чупа-чупс", "загадочного чупа-чупса", "загадочному чупа-чупсу", "загадочный чупа-чупс", "загадочным чупа-чупсом", "загадочном чупа-чупсе")
	desc = "???"
	icon_state = "sucker_mystery"
	filling_color = "#ffffff"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/candy/sucker/mystery/atom_init()
	. = ..()
	reagents.add_reagent(pick(global.chemical_reagents_list), 5)

///////////////////////////////////////////
// Ectoplasm o.O
///////////////////////////////////////////
/obj/item/weapon/reagent_containers/food/snacks/ectoplasm
	name = "ectoplasm"
	cases = list("эктоплазма", "эктоплазмы", "эктоплазму", "эктоплазму", "эктоплазмой", "эктоплазме")
	desc = "Spooky! Do not consume under any circumstances."
	gender = PLURAL
	icon = 'icons/obj/wizard.dmi'
	icon_state = "ectoplasm"
	list_reagents = list("ectoplasm" = 5)
	food_type = JUNK_FOOD
	food_moodlet = /datum/mood_event/junk_food

/obj/item/weapon/reagent_containers/food/snacks/fries/cardboard
	icon_state = "fries_cardboard"
	trash = /obj/item/trash/fries

/obj/item/weapon/reagent_containers/food/snacks/cheesyfries/cardboard
	icon_state = "cheesyfries_cardboard"
	trash = /obj/item/trash/fries


/// candy heart
/obj/item/weapon/reagent_containers/food/snacks/candyheart
	name = "candy heart"
	cases = list("шоколадное сердце", "шоколадного сердца", "шоколадному сердцу", "шоколадное сердце", "шоколадным сердцем", "шоколадном сердце")
	icon = 'icons/obj/valentines.dmi'
	icon_state = "candyheart"
	desc = "A heart-shaped candy filled with love."
	bitesize = 3
	trash = /obj/item/weapon/paper/lovenote

/obj/item/weapon/reagent_containers/food/snacks/candyheart/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("sugar", 3)
	icon_state = pick("candyheart_pink", "candyheart_green", "candyheart_blue", "candyheart_yellow")

//Xeno species food

/obj/item/weapon/reagent_containers/food/snacks/el_ehum
	name = "El E'hum"
	cases = list("Эль-Э'хум", "Эля-Э'хума", "Элю-Э'хуму", "Эль-Э'хум", "Элем-Э'хумом", "Эле-Э'хуме")
	desc = "A thin pieces of bark from the elyu'a ail tree, smoked with seynyu'dra leaves. The finished dish tastes like ham. This meat is usually eaten with a portion of seinyu'dra bark, which can be carried around, making it indispensable for the Tajaran's treks."
	icon_state = "el_ehum"
	bitesize = 3
	list_reagents = list("nutriment" = 3, "blackpepper" = 3, "bicaridine" = 3)

/obj/item/weapon/reagent_containers/food/snacks/rraasi
	name = "Rraasi"
	cases = list("Ррааси", "Ррааси", "Ррааси", "Ррааси", "Ррааси", "Ррааси")
	desc = "A popular food is tajaran, named after the one-eyed fish used in cooking. Slightly spicy flavor with crushed sei'draa. The dish is served cold on a heated plate. Popularized by the Innad clan, this extraordinarily spicy dish has become a favorite of many tajarans around the world. Rraasi, as a rule, does not harm a person in acceptable norms, but with its sharp taste it can shock."
	icon_state = "rraasi"
	bitesize = 3
	trash = /obj/item/trash/plate
	list_reagents = list("protein" = 3, "carpotoxin" = 3, "blackpepper" = 3)

/obj/item/weapon/reagent_containers/food/snacks/sliceable/kaholket_alkeha
	name = "Kahol'Ket Al'Keha"
	cases = list("Кахол'Кет Ал'Кэха", "Кахол'Кета Ал'Кэхи", "Кахол'Кету Ал'Кэхе", "Кахол'Кета Ал'Кэху", "Кахол'Кетом Ал'Кэхой", "Кахол'Кете Ал'Кэхе")
	desc = "A simple pie made with Cha'ich nuts and berries and baked in Elyu'a Eil."
	icon_state = "kaholket_alkeha"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/kaholket_alkeha
	slices_num = 5
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 12, "berryjuice" = 3, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/kaholket_alkeha
	name = "Kahol'Ket Al'Keha"
	cases = list("Кахол'Кет Ал'Кэха", "Кахол'Кета Ал'Кэхи", "Кахол'Кету Ал'Кэхе", "Кахол'Кета Ал'Кэху", "Кахол'Кетом Ал'Кэхой", "Кахол'Кете Ал'Кэхе")
	desc = "A simple pie made with Cha'ich nuts and berries and baked in Elyu'a Eil."
	icon_state = "kaholket_alkeha_slice"

/obj/item/weapon/reagent_containers/food/snacks/jundarek
	name = "Jun'Darek"
	cases = list("Джун'Дарек", "Джун'Дарька", "Джун'Дарьку", "Джун'Дарька", "Джун'Дарьком", "Джун'Дарьке")
	desc = "A fish dipped in salted wine."
	icon_state = "jundarek"
	bitesize = 5
	trash = /obj/item/trash/snack_bowl
	list_reagents = list("protein" = 3, "carpotoxin" = 3, "sodiumchloride" = 1, "wine" = 13)

/obj/item/weapon/reagent_containers/food/snacks/soup/fushstvessina
	name = "Fushst'vessina"
	cases = list("Фушшст'вессина", "Фушшст'вессиной", "Фушшст'вессиной", "Фушшст'вессину", "Фушшст'вессиной", "Фушшст'вессине")
	desc = "Cooked syrup, which is given a decorative shape and sprinkled with chaich nut flakes."
	icon_state = "fushstvessina"
	bitesize = 5
	trash = /obj/item/trash/snack_bowl
	list_reagents = list("protein" = 8, "vitamin" = 4, "rice" = 3)

/obj/item/weapon/reagent_containers/food/snacks/adjurahma
	name = "Adjurah'Ma"
	cases = list("Ажурах'Ма", "Ажураха'Ма", "Ажураху'Ма", "Ажураха'Ма", "Ажурахом'Ма", "Ажурахе'Ма")
	desc = "Cooked syrup, which is given a decorative shape and sprinkled with chaich nut flakes."
	icon_state = "adjurahma"
	bitesize = 3
	list_reagents = list("nutriment" = 2, "water" = 7, "sugar" = 6)

/obj/item/weapon/reagent_containers/food/snacks/julma_tulkrash
	name = "Jul'Ma Tul'Krush"
	cases = list("Джюл'Ма Тюл'Краш", "Джюла'Ма Тюл'Краша", "Джюлу'Ма Тюл'Крашу", "Джюла'Ма Тюл'Краш", "Джюлом'Ма Тюл'Крашой", "Джюле'Ма Тюл'Краше")
	desc = "A very sweet broth made from fresh fat, meat and Jul'Ma"
	icon_state = "julma_tulkrash"
	bitesize = 5
	trash = /obj/item/trash/snack_bowl
	list_reagents = list("nutriment" = 2, "water" = 8, "protein" = 3, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/fasqhtongue
	name = "Fasqh'tongue"
	cases = list("Фаск'хтонг", "Фаска'хтонга", "Фаску'хтонгу", "Фаска'хтонга", "Фаском'хтонгом", "Фаске'хтонге")
	desc = "A dried and cured sissalika tongue cured in vinegar. Usually seasoned with something spicy. It is usually served straight in its entirety, occupying a good half a meter on the table."
	icon_state = "fasqhtongue"
	bitesize = 5
	list_reagents = list("protein" = 4, "plantmatter" = 6, "blackpepper" = 3, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/kefeogeo
	name = "Kefeogeo"
	cases = list("Кефеогео", "Кефеогео", "Кефеогео", "Кефеогео", "Кефеогео", "Кефеогео")
	desc = "A small meat tenderloins dried in the sun in hot spices. It turns out a kind of jerky chips, which are very fond of children as a treat. Traditionally served on a plate of edible fern leaf by one of the younger members of the family."
	icon_state = "kefeogeo"
	bitesize = 4
	food_type = NATURAL_FOOD
	list_reagents = list("protein" = 7, "plantmatter" = 3, "sodiumchloride" = 1, "blackpepper" = 1)
