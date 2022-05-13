/obj/item/weapon/coin
	icon = 'icons/obj/economy.dmi'
	name = COIN_IRON
	icon_state = "coin__heads"
	flags = CONDUCT
	force = 0
	throwforce = 0
	w_class = SIZE_MINUSCULE
	price = 0
	var/cmineral = null
	var/reagent = null
	var/string_attached
	var/list/sideslist = list("head","tail")
	var/cooldown = 0
	var/coinflip

/obj/item/weapon/coin/atom_init()
	. = ..()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8
	if(reagent)
		create_reagents(4)
		reagents.add_reagent(reagent, 4)

/obj/item/weapon/coin/mercury
	name = COIN_MERCURY
	cmineral = "mercury"
	reagent = "mercury"
	icon_state = "coin_mercury_head"
	price = 1

/obj/item/weapon/coin/copper
	name = COIN_COPPER
	cmineral = "copper"
	reagent = "copper"
	icon_state = "coin_copper_head"
	price = 2

/obj/item/weapon/coin/plastic
	name = COIN_PLASTIC
	cmineral = "plastic"
	reagent = "carbon"
	icon_state = "coin_plastic_head"
	price = 3

/obj/item/weapon/coin/iron
	name = COIN_IRON
	cmineral = "iron"
	reagent = "iron"
	icon_state = "coin_iron_head"
	price = 5

/obj/item/weapon/coin/tin
	name = COIN_TIN
	cmineral = "tin"
	icon_state = "coin_tin_head"
	price = 10

/obj/item/weapon/coin/lead
	name = COIN_LEAD
	cmineral = "lead"
	icon_state = "coin_lead_head"
	price = 15

/obj/item/weapon/coin/uranium
	name = COIN_URANIUM
	cmineral = "uranium"
	reagent = "uranium"
	icon_state = "coin_uranium_head"
	price = 20

/obj/item/weapon/coin/platinum
	name = COIN_PLATINUM
	cmineral = "platinum"
	icon_state = "coin_platinum_head"
	price = 50

/obj/item/weapon/coin/phoron
	name = COIN_PHORON
	cmineral = "phoron"
	reagent = "phoron"
	icon_state = "coin_phoron_head"
	price = 100

/obj/item/weapon/coin/gold
	name = COIN_GOLD
	cmineral = "gold"
	reagent = "gold"
	icon_state = "coin_gold_head"
	price = 500

/obj/item/weapon/coin/bananium
	name = COIN_BANANIUM
	cmineral = "bananium"
	reagent = "banana"
	icon_state = "coin_bananium_head"
	price = 69

/obj/item/weapon/coin/attackby(obj/item/I, mob/user, params)
	if(iscoil(I))
		var/obj/item/stack/cable_coil/CC = I
		if(string_attached)
			to_chat(user, "<span class='warning'>There already is a string attached to this coin!</span>")
			return

		if(CC.use(1))
			add_overlay(image('icons/obj/items.dmi',"coin_string_overlay"))
			string_attached = 1
			to_chat(user, "<span class='notice'>You attach a string to the coin.</span>")
			return

		else
			to_chat(user, "<span class='warning'>You need one length of cable to attach a string to the coin!</span>")
			return

	else if(iswirecutter(I))
		if(!string_attached)
			return ..()

		new /obj/item/stack/cable_coil/red(user.loc, 1)
		cut_overlays()
		string_attached = null
		to_chat(user, "<span class='notice'>You detach the string from the coin.</span>")

	else
		return ..()

/obj/item/weapon/coin/attack_self(mob/user)
	if(cooldown < world.time)
		if(string_attached) //does the coin have a wire attached
			to_chat(user, "<span class='warning'>The coin won't flip very well with something attached!</span>" )
			return FALSE //do not flip the coin
		coinflip = pick(sideslist)
		cooldown = world.time + 15
		flick("coin_[cmineral]_flip", src)
		icon_state = "coin_[cmineral]_[coinflip]"
		playsound(user, 'sound/items/coinflip.ogg', VOL_EFFECTS_MASTER)
		var/oldloc = loc
		if(loc == oldloc && user && !user.incapacitated())
			user.visible_message("[user] has flipped [src]. It lands on [coinflip].",
 							 "<span class='notice'>You flip [src]. It lands on [coinflip].</span>",
							 "<span class='italics'>You hear the clattering of loose change.</span>")

/obj/item/weapon/coin/proc/flip_animate()

