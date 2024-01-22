/obj/item/weapon/coin
	icon = 'icons/obj/economy.dmi'
	name = COIN_IRON
	icon_state = "coin__heads"
	flags = CONDUCT
	force = 0
	throwforce = 0
	w_class = SIZE_MINUSCULE
	var/cmineral = null
	var/reagent = null
	var/string_attached
	var/list/sideslist = list("heads","tails")
	var/cooldown = 0
	var/coinflip = "heads"

/obj/item/weapon/coin/atom_init()
	. = ..()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8
	if(reagent)
		create_reagents(4)
		reagents.add_reagent(reagent, 4)

/obj/item/weapon/coin/gold
	name = COIN_GOLD
	cmineral = "gold"
	reagent = "gold"
	icon_state = "coin_gold_heads"
	item_state_world = "coin_gold_heads_world"


/obj/item/weapon/coin/silver
	name = COIN_SILVER
	cmineral = "silver"
	reagent = "silver"
	icon_state = "coin_silver_heads"
	item_state_world = "coin_silver_heads_world"

/obj/item/weapon/coin/diamond
	name = COIN_DIAMOND
	cmineral = "diamond"
	reagent = "carbon"
	icon_state = "coin_diamond_heads"
	item_state_world = "coin_diamond_heads_world"

/obj/item/weapon/coin/iron
	name = COIN_IRON
	cmineral = "iron"
	reagent = "iron"
	icon_state = "coin_iron_heads"
	item_state_world = "coin_iron_heads_world"

/obj/item/weapon/coin/phoron
	name = COIN_PHORON
	cmineral = "phoron"
	reagent = "phoron"
	icon_state = "coin_phoron_heads"
	item_state_world = "coin_phoron_heads_world"

/obj/item/weapon/coin/uranium
	name = COIN_URANIUM
	cmineral = "uranium"
	reagent = "uranium"
	icon_state = "coin_uranium_heads"
	item_state_world = "coin_uranium_heads_world"

/obj/item/weapon/coin/bananium
	name = COIN_BANANIUM
	cmineral = "bananium"
	reagent = "banana"
	icon_state = "coin_bananium_heads"
	item_state_world = "coin_bananium_heads_world"

/obj/item/weapon/coin/platinum
	name = COIN_PLATINUM
	cmineral = "platinum"
	icon_state = "coin_platinum_heads"
	item_state_world = "coin_platinum_heads_world"

/obj/item/weapon/coin/mythril
	name = COIN_MYTHRIL
	cmineral = "mythril"
	icon_state = "coin_mythril_heads"
	item_state_world = "coin_mythril_heads_world"

/obj/item/weapon/coin/twoheaded
	cmineral = "silver"
	reagent = "silver"
	icon_state = "coin_silver_heads"
	item_state_world = "coin_silver_heads_world"
	desc = "Hey, this coin's the same on both sides!"
	sideslist = list("heads")
	coinflip = "heads"

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

	else if(iscutter(I))
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
		update_icon()
		playsound(user, 'sound/items/coinflip.ogg', VOL_EFFECTS_MASTER)
		var/oldloc = loc
		if(loc == oldloc && user && !user.incapacitated())
			user.visible_message("[user] has flipped [src]. It lands on [coinflip].",
 							 "<span class='notice'>You flip [src]. It lands on [coinflip].</span>",
							 "<span class='italics'>You hear the clattering of loose change.</span>")

/obj/item/weapon/coin/update_world_icon()
	update_icon()

/obj/item/weapon/coin/update_icon()
	if(item_state_world && (flags_2 & IN_INVENTORY || flags_2 & IN_STORAGE)) // big inventory icon, if we have it
		icon_state = "coin_[cmineral]_[coinflip]"
	else // default or small icon
		icon_state = "coin_[cmineral]_[coinflip]_world"
