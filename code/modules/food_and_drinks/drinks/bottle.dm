
///////////////////////////////////////////////Alchohol bottles! -Agouri /////////////////////////////////////////
//Functionally identical to regular drinks. The only difference is that the default bottle size is 100. - Darem	//
//Bottles now weaken and break when smashed on people's heads. - Giacom											//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle
	amount_per_transfer_from_this = 10
	volume = 100
	icon = 'icons/obj/food_and_drinks/drinks.dmi'
	item_state = "broken_beer" //Generic held-item sprite until unique ones are made.
	var/const/duration = 13 //Directly relates to the 'weaken' duration. Lowered by armor (i.e. helmets)
	var/is_glass = 1 //Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it
	var/is_transparent = 1 //Determines whether an overlay of liquid should be added to bottle when it fills

/obj/item/weapon/reagent_containers/food/drinks/bottle/proc/smash(mob/living/target, mob/living/user)

	//Creates a shattering noise and replaces the bottle with a broken_bottle
	user.drop_item()
	var/obj/item/weapon/broken_bottle/B = new /obj/item/weapon/broken_bottle(user.loc)
	user.put_in_active_hand(B)
	if(prob(33))
		new/obj/item/weapon/shard(target.loc) // Create a glass shard at the target's location!
	B.icon_state = src.icon_state

	var/icon/I = new('icons/obj/food_and_drinks/drinks.dmi', src.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I

	playsound(src, "shatter", 70, 1)
	user.put_in_active_hand(B)
	src.transfer_fingerprints_to(B)

	qdel(src)

/obj/item/weapon/reagent_containers/food/drinks/bottle/on_reagent_change()
	if(is_glass && is_transparent)
		update_icon()

/obj/item/weapon/reagent_containers/food/drinks/bottle/update_icon()
	show_filler_on_icon(3, 24, 0)

/obj/item/weapon/reagent_containers/food/drinks/bottle/attack(mob/living/target, mob/living/user, def_zone)

	if(!target)
		return

	if(user.a_intent != "hurt" || !is_glass)
		return ..()


	force = 15 //Smashing bottles over someoen's head hurts.

	var/armor_block = 0 //Get the target's armour values for normal attack damage.
	var/armor_duration = 0 //The more force the bottle has, the longer the duration.

	//Calculating duration and calculating damage.
	if(ishuman(target))

		var/mob/living/carbon/human/H = target
		var/headarmor = 0 // Target's head armour
		armor_block = H.run_armor_check(def_zone, "melee") // For normal attack damage

		//If they have a hat/helmet and the user is targeting their head.
		if(istype(H.head, /obj/item/clothing/head) && def_zone == BP_HEAD)

			// If their head has an armour value, assign headarmor to it, else give it 0.
			if(H.head.armor["melee"])
				headarmor = H.head.armor["melee"]
			else
				headarmor = 0
		else
			headarmor = 0

		//Calculate the weakening duration for the target.
		armor_duration = (duration - headarmor) + force

	else
		//Only humans can have armour, right?
		armor_block = target.run_armor_check(def_zone, "melee")
		if(def_zone == BP_HEAD)
			armor_duration = duration + force
	armor_duration /= 10

	//Apply the damage!
	target.apply_damage(force, BRUTE, def_zone, armor_block)

	// You are going to knock someone out for longer if they are not wearing a helmet.
	if(def_zone == BP_HEAD && iscarbon(target))

		//Display an attack message.
		for(var/mob/O in viewers(user, null))
			if(target != user) O.show_message(text("\red <B>[target] has been hit over the head with a bottle of [src.name], by [user]!</B>"), 1)
			else O.show_message(text("\red <B>[target] hit himself with a bottle of [src.name] on the head!</B>"), 1)
		//Weaken the target for the duration that we calculated and divide it by 5.
		if(armor_duration)
			target.apply_effect(min(armor_duration, 10) , WEAKEN) // Never weaken more than a flash!

	else
		//Default attack message and don't weaken the target.
		for(var/mob/O in viewers(user, null))
			if(target != user) O.show_message(text("\red <B>[target] has been attacked with a bottle of [src.name], by [user]!</B>"), 1)
			else O.show_message(text("\red <B>[target] has attacked himself with a bottle of [src.name]!</B>"), 1)

	//Attack logs
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has attacked [target.name] ([target.ckey]) with a bottle!</font>")
	target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been smashed with a bottle by [user.name] ([user.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) attacked [target.name] ([target.ckey]) with a bottle. (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	//The reagents in the bottle splash all over the target, thanks for the idea Nodrak
	if(src.reagents)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\blue <B>The contents of the [src] splashes all over [target]!</B>"), 1)
		src.reagents.reaction(target, TOUCH)

	//Finally, smash the bottle. This kills (del) the bottle.
	src.smash(target, user)

	return

/obj/item/weapon/broken_bottle

	name = "Broken Bottle"
	desc = "A bottle with a sharp broken bottom."
	icon = 'icons/obj/food_and_drinks/drinks.dmi'
	icon_state = "broken_bottle"
	force = 9.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	item_state = "beer"
	attack_verb = list("stabbed", "slashed", "attacked")
	sharp = 1
	edge = 0
	var/icon/broken_outline = icon('icons/obj/food_and_drinks/drinks.dmi', "broken")

/obj/item/weapon/broken_bottle/attack(mob/living/carbon/M, mob/living/carbon/user)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

////////////////////////////////////////////////////////////////
///////////////////LIST OF BOTTLED DRINKS///////////////////////
////////////Please keep it in alphabetical order////////////////
/////////////////////////*ALCOHOL*//////////////////////////////
////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe
	name = "Jailbreaker Verte"
	desc = "One sip of this and you just know you're gonna have a good time."
	icon_state = "absinthebottle"

/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe/atom_init()
	. = ..()
	reagents.add_reagent("absinthe", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/ale
	name = "Magm-Ale"
	desc = "A true dorf's drink of choice."
	icon_state = "alebottle"

/obj/item/weapon/reagent_containers/food/drinks/bottle/ale/atom_init()
	. = ..()
	reagents.add_reagent("ale", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/beer
	name = "Space Beer"
	desc = "Contains only water, malt and hops."
	icon_state = "beer"

/obj/item/weapon/reagent_containers/food/drinks/bottle/beer/atom_init()
	. = ..()
	reagents.add_reagent("beer", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/bluecuracao
	name = "Miss Blue Curacao"
	desc = "A fruity, exceptionally azure drink. Does not allow the imbiber to use the fifth magic."
	icon_state = "alco-blue" //Placeholder.

/obj/item/weapon/reagent_containers/food/drinks/bottle/bluecuracao/atom_init()
	. = ..()
	reagents.add_reagent("bluecuracao", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/champagne
	name = "Duc de Paris Brut"
	desc = "Boisson elegante. Servir froid."
	icon_state = "chambottle"

/obj/item/weapon/reagent_containers/food/drinks/bottle/champagne/atom_init()
	. = ..()
	reagents.add_reagent("champagne", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac
	name = "Chateau De Baton Premium Cognac"
	desc = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. You might as well not scream 'SHITCURITY' this time."
	icon_state = "cognacbottle"

/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac/atom_init()
	. = ..()
	reagents.add_reagent("cognac", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/gin
	name = "Griffeater Gin"
	desc = "A bottle of high quality gin, produced in the New London Space Station."
	icon_state = "ginbottle"

/obj/item/weapon/reagent_containers/food/drinks/bottle/gin/atom_init()
	. = ..()
	reagents.add_reagent("gin", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager
	name = "College Girl Goldschlager"
	desc = "Because they are the only ones who will drink 100 proof cinnamon schnapps."
	icon_state = "goldschlagerbottle"

/obj/item/weapon/reagent_containers/food/drinks/bottle/goldschlager/atom_init()
	. = ..()
	reagents.add_reagent("goldschlager", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/grenadine
	name = "Briar Rose Grenadine Syrup"
	desc = "Sweet and tangy, a bar syrup used to add color or flavor to drinks."
	icon_state = "grenadinebottle"

/obj/item/weapon/reagent_containers/food/drinks/bottle/grenadine/atom_init()
	. = ..()
	reagents.add_reagent("grenadine", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua
	name = "Robert Robust's Coffee Liqueur"
	desc = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936, HONK"
	icon_state = "kahluabottle"
	is_transparent = 0

/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua/atom_init()
	. = ..()
	reagents.add_reagent("kahlua", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/melonliquor
	name = "Emeraldine Melon Liquor"
	desc = "A bottle of 46 proof Emeraldine Melon Liquor. Sweet and light."
	icon_state = "alco-green" //Placeholder.

/obj/item/weapon/reagent_containers/food/drinks/bottle/melonliquor/atom_init()
	. = ..()
	reagents.add_reagent("melonliquor", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/patron
	name = "Wrapp Artiste Patron"
	desc = "Silver laced tequilla, served in space night clubs across the galaxy."
	icon_state = "patronbottle"

/obj/item/weapon/reagent_containers/food/drinks/bottle/patron/atom_init()
	. = ..()
	reagents.add_reagent("patron", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/pwine
	name = "Warlock's Velvet"
	desc = "What a delightful packaging for a surely high quality wine! The vintage must be amazing!"
	icon_state = "pwinebottle"
	is_transparent = 0

/obj/item/weapon/reagent_containers/food/drinks/bottle/pwine/atom_init()
	. = ..()
	reagents.add_reagent("pwine", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/rum
	name = "Captain Pete's Cuban Spiced Rum"
	desc = "This isn't just rum, oh no. It's practically GRIFF in a bottle."
	icon_state = "rumbottle"

/obj/item/weapon/reagent_containers/food/drinks/bottle/rum/atom_init()
	. = ..()
	reagents.add_reagent("rum", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/tequilla
	name = "Caccavo Guaranteed Quality Tequilla"
	desc = "Made from premium petroleum distillates, pure thalidomide and other fine quality ingredients!"
	icon_state = "tequillabottle"

/obj/item/weapon/reagent_containers/food/drinks/bottle/tequilla/atom_init()
	. = ..()
	reagents.add_reagent("tequilla", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth
	name = "Goldeneye Vermouth"
	desc = "Sweet, sweet dryness~"
	icon_state = "vermouthbottle"

/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth/atom_init()
	. = ..()
	reagents.add_reagent("vermouth", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka
	name = "Tunguska Triple Distilled"
	desc = "Aah, vodka. Prime choice of drink AND fuel by Russians worldwide."
	icon_state = "vodkabottle"

/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka/atom_init()
	. = ..()
	reagents.add_reagent("vodka", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/wine
	name = "Doublebeard Bearded Special Wine"
	desc = "A faint aura of unease and asspainery surrounds the bottle."
	icon_state = "winebottle"
	is_transparent = 0

/obj/item/weapon/reagent_containers/food/drinks/bottle/wine/atom_init()
	. = ..()
	reagents.add_reagent("wine", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey
	name = "Uncle Git's Special Reserve"
	desc = "A premium single-malt whiskey, gently matured inside the tunnels of a nuclear shelter. TUNNEL WHISKEY RULES."
	icon_state = "whiskeybottle"

/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey/atom_init()
	. = ..()
	reagents.add_reagent("whiskey", 100)

////////////////////////////////////////////////////////////////
////////////////////*JUICES AND OTHER STUFF*////////////////////
////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing
	name = "Bottle of Nothing"
	desc = "A bottle filled with nothing."
	icon_state = "bottleofnothing"

/obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing/atom_init()
	. = ..()
	reagents.add_reagent("nothing", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/cream
	name = "Milk Cream"
	desc = "It's cream. Made from milk. What else did you think you'd find in there?"
	icon_state = "cream"
	item_state = "carton"
	is_glass = 0

/obj/item/weapon/reagent_containers/food/drinks/bottle/cream/atom_init()
	. = ..()
	reagents.add_reagent("cream", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater
	name = "Flask of Holy Water"
	desc = "A flask of the chaplain's holy water."
	icon_state = "holyflask"

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater/atom_init()
	. = ..()
	reagents.add_reagent("holywater", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice
	name = "Lime Juice"
	desc = "Sweet-sour goodness."
	icon_state = "limejuice"
	item_state = "carton"
	is_glass = 0

/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice/atom_init()
	. = ..()
	reagents.add_reagent("limejuice", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/milk
	name = "Space Milk"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	item_state = "carton"
	isglass = 0

/obj/item/weapon/reagent_containers/food/drinks/milk/atom_init()
	. = ..()
	reagents.add_reagent("milk", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice
	name = "Orange Juice"
	desc = "Full of vitamins and deliciousness!"
	icon_state = "orangejuice"
	item_state = "carton"
	is_glass = 0

/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice/atom_init()
	. = ..()
	reagents.add_reagent("orangejuice", 100)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/soymilk
	name = "SoyMilk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon_state = "soymilk"
	item_state = "carton"

/obj/item/weapon/reagent_containers/food/drinks/soymilk/atom_init()
	. = ..()
	reagents.add_reagent("soymilk", 50)
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)

////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice
	name = "Tomato Juice"
	desc = "Well, at least it LOOKS like tomato juice. You can't tell with all that redness."
	icon_state = "tomatojuice"
	item_state = "carton"
	is_glass = 0

/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice/atom_init()
	. = ..()
	reagents.add_reagent("tomatojuice", 100)
