/obj/structure/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"
	density = 1
	anchored = 0
	flags = OPENCONTAINER
	var/modded = FALSE
	var/transfer_from = TRUE
	var/obj/item/device/assembly_holder/rig
	var/amount_per_transfer_from_this = 10
	var/possible_transfer_amounts = list(10,25,50,100)

/obj/structure/reagent_dispensers/AltClick(mob/user)
	if(!Adjacent(user))
		return
	if(user.incapacitated())
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return
	transfer_from = !transfer_from
	to_chat(user, "<span class = 'notice'>You transfer [transfer_from ? "from" : "into"] [src]</span>")

/obj/structure/reagent_dispensers/atom_init()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src
	if (!possible_transfer_amounts)
		src.verbs -= /obj/structure/reagent_dispensers/verb/set_APTFT
	. = ..()

/obj/structure/reagent_dispensers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in view(1)
	var/N = input("Amount per transfer from this:","[src]") as null|anything in possible_transfer_amounts
	if (N)
		amount_per_transfer_from_this = N

/obj/structure/reagent_dispensers/proc/try_transfer(atom/t_from, atom/t_to, mob/user)
	var/transfer_amount = 0
	if(istype(t_from, /obj/item/weapon/reagent_containers/glass))
		var/obj/item/weapon/reagent_containers/glass/G = t_from
		transfer_amount = G.amount_per_transfer_from_this
	else if(istype(t_from, /obj/structure/reagent_dispensers))
		var/obj/structure/reagent_dispensers/RD = t_from
		transfer_amount = RD.amount_per_transfer_from_this

	if(transfer_amount == 0)
		return
	if(t_to.reagents.total_volume >= t_to.reagents.maximum_volume)
		to_chat(user, "<span class = 'rose'>[t_to] is full.</span>")
		return
	if(!t_from.reagents.total_volume && t_from.reagents)
		to_chat(user, "<span class = 'rose'>[t_from] is empty.</span>")
		return
	var/trans = t_from.reagents.trans_to(t_to, transfer_amount)
	to_chat(user, "<span class = 'notice'>You fill [t_to] with [trans] units of the contents of [t_from]. </span>")

/obj/structure/reagent_dispensers/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				new /obj/effect/effect/water(src.loc)
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				new /obj/effect/effect/water(src.loc)
				qdel(src)
				return
		else
	return

/obj/structure/reagent_dispensers/blob_act()
	if(prob(50))
		new /obj/effect/effect/water(src.loc)
		qdel(src)

/obj/structure/reagent_dispensers/proc/leak(amount)
	if(reagents.total_volume == 0)
		return
	var/obj/effect/decal/chempuff/D = reagents.create_chempuff(amount)
	D.reagents.reaction(get_turf(D))
	for(var/atom/A in get_turf(D))
		D.reagents.reaction(A)
	QDEL_IN(D, 1 SECOND)

/obj/structure/reagent_dispensers/process()
	if(!src) return
	if(modded)
		leak(amount_per_transfer_from_this * 0.1)
	else
		STOP_PROCESSING(SSobj, src)

/obj/structure/reagent_dispensers/examine(mob/user)
	..()
	if(src in oview(2, user))
		if (modded)
			to_chat(user, "<span class='red'>Faucet is wrenched open, leaking the contents of [src]!</span>")
		if(rig)
			to_chat(user, "<span class='notice'>There is some kind of device rigged to the tank.</span>")

/obj/structure/reagent_dispensers/attack_hand(mob/user)
	if (rig && !user.is_busy())
		user.visible_message("[user] begins to detach [rig] from \the [src].", "You begin to detach [rig] from \the [src]")
		if(do_after(user, 20, target = src))
			user.visible_message("<span class='notice'>[user] detaches [rig] from \the [src].</span>", "<span class='notice'>You detach [rig] from \the [src]</span>")
			rig.loc = get_turf(usr)
			rig = null
			cut_overlays()

/obj/structure/reagent_dispensers/attackby(obj/item/weapon/W, mob/user)
	if (iswrench(W))
		user.SetNextMove(CLICK_CD_RAPID)
		user.visible_message("[user] wrenches [src]'s faucet [modded ? "closed" : "open"].", \
			"You wrench [src]'s faucet [modded ? "closed" : "open"]")
		message_admins("[key_name_admin(user)] set [src] faucet [modded ? "closed" : "open"] @ location [src.x], [src.y], [src.z] [ADMIN_JMP(src)]")
		modded = !modded
		if (modded)
			START_PROCESSING(SSobj, src)
			leak(amount_per_transfer_from_this)

		return
	else if (istype(W,/obj/item/device/assembly_holder))
		if (rig)
			to_chat(user, "<span class='warning'>There is another device in the way.</span>")
			return
		if(user.is_busy()) return
		user.visible_message("[user] begins rigging [W] to \the [src].", "You begin rigging [W] to \the [src]")
		if(W.use_tool(src, user, 20))
			user.visible_message("<span class='notice'>[user] rigs [W] to \the [src].</span>", "<span class='notice'>You rig [W] to \the [src]</span>")

			var/obj/item/device/assembly_holder/H = W
			if (istype(H.a_left,/obj/item/device/assembly/igniter) || istype(H.a_right,/obj/item/device/assembly/igniter))
				message_admins("[key_name_admin(user)] rigged [src] at ([loc.x],[loc.y],[loc.z]) for explosion. [ADMIN_JMP(user)]")
				log_game("[key_name(user)] rigged [src] at ([loc.x],[loc.y],[loc.z]) for explosion.")

			rig = W
			user.drop_item()
			W.loc = src

			var/icon/test = getFlatIcon(W)
			test.Shift(NORTH,1)
			test.Shift(EAST,6)
			add_overlay(test)

	add_fingerprint(usr)
	return

/obj/structure/reagent_dispensers/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
		if(!istype(Proj ,/obj/item/projectile/beam/lasertag) && !istype(Proj ,/obj/item/projectile/beam/practice) )
			explode()

/obj/structure/reagent_dispensers/blob_act()
	explode()

/obj/structure/reagent_dispensers/ex_act()
	explode()

/obj/structure/reagent_dispensers/proc/explode(mob/user)
	var/fuel_am = reagents.get_reagent_amount("fuel") + reagents.get_reagent_amount("phoron") * 5
	if(fuel_am > 0)
		if (fuel_am > 500)
			explosion(loc, 1, 2, 4)
		else if (fuel_am > 100)
			explosion(loc, 0, 1, 3)
		else
			explosion(loc, -1, 1, 2)
		if(src)
			qdel(src)
		return TRUE
	return FALSE

/obj/structure/reagent_dispensers/fire_act(datum/gas_mixture/air, temperature, volume)
	if(temperature > T0C+500)
		explode()
	return ..()

/obj/structure/reagent_dispensers/tesla_act()
	..() //extend the zap
	explode()

/obj/structure/reagent_dispensers/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if (. && modded)
		leak(amount_per_transfer_from_this * 0.1)


// "Tanks".
/obj/structure/reagent_dispensers/watertank
	name = "watertank"
	desc = "A watertank."
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"

/obj/structure/reagent_dispensers/watertank/atom_init()
	. = ..()
	reagents.add_reagent("water", 1000)

/obj/structure/reagent_dispensers/aqueous_foam_tank
	name = "AFFF tank"
	desc = "A tank containing Aqueous Film Forming Foam(AFFF)."
	icon_state = "affftank"

/obj/structure/reagent_dispensers/aqueous_foam_tank/atom_init()
	. = ..()
	reagents.add_reagent("aqueous_foam", 1000)


/obj/structure/reagent_dispensers/fueltank
	name = "fueltank"
	desc = "A fueltank."
	icon = 'icons/obj/objects.dmi'
	icon_state = "weldtank"

/obj/structure/reagent_dispensers/fueltank/atom_init()
	. = ..()
	reagents.add_reagent("fuel",300)

/obj/structure/reagent_dispensers/peppertank
	name = "Pepper Spray Refiller"
	desc = "Refill pepper spray canisters."
	icon = 'icons/obj/objects.dmi'
	icon_state = "peppertank"
	anchored = 1
	density = 0
	amount_per_transfer_from_this = 45

/obj/structure/reagent_dispensers/peppertank/atom_init()
	. = ..()
	reagents.add_reagent("condensedcapsaicin",1000)



/obj/structure/reagent_dispensers/water_cooler
	name = "Water-Cooler"
	desc = "A machine that dispenses water to drink."
	amount_per_transfer_from_this = 5
	icon = 'icons/obj/vending.dmi'
	icon_state = "water_cooler"
	possible_transfer_amounts = null
	anchored = 1

/obj/structure/reagent_dispensers/water_cooler/atom_init()
	. = ..()
	reagents.add_reagent("water",500)


/obj/structure/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "A beer keg."
	icon = 'icons/obj/objects.dmi'
	icon_state = "beertankTEMP"

/obj/structure/reagent_dispensers/beerkeg/atom_init()
	. = ..()
	reagents.add_reagent("beer",1000)

/obj/structure/reagent_dispensers/beerkeg/blob_act()
	explosion(src.loc,0,3,5,7,10)
	qdel(src)

/obj/structure/reagent_dispensers/virusfood
	name = "Virus Food Dispenser"
	desc = "A dispenser of virus food."
	icon = 'icons/obj/objects.dmi'
	icon_state = "virusfoodtank"
	anchored = 1

/obj/structure/reagent_dispensers/virusfood/atom_init()
	. = ..()
	reagents.add_reagent("virusfood", 1000)

/obj/structure/reagent_dispensers/acid
	name = "Sulphuric Acid Dispenser"
	desc = "A dispenser of acid for industrial processes."
	icon = 'icons/obj/objects.dmi'
	icon_state = "acidtank"
	anchored = 1

/obj/structure/reagent_dispensers/acid/atom_init()
	. = ..()
	reagents.add_reagent("sacid", 1000)

/obj/structure/reagent_dispensers/kvasstank
	name = "KBAC"
	desc = "A cool refreshing drink with a taste of socialism."
	icon = 'icons/obj/objects.dmi'
	icon_state = "kvasstank"
	possible_transfer_amounts = list(25,60,100)
	amount_per_transfer_from_this = 25

/obj/structure/reagent_dispensers/kvasstank/atom_init()
	. = ..()
	reagents.add_reagent("kvass",1000)

/obj/structure/reagent_dispensers/cleaner
	name = "Space Cleaner Dispenser"
	desc = "A dispenser of cleaner."
	icon = 'icons/obj/objects.dmi'
	icon_state = "cleanertank"
	anchored = 1
	density = 0

/obj/structure/reagent_dispensers/cleaner/atom_init()
	. = ..()
	reagents.add_reagent("cleaner", 1000)
