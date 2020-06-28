// the power cell
// charge from 0 to 100%
// fits in APC to provide backup power
/obj/item/weapon/stock_parts/cell/atom_init()
	. = ..()
	charge = maxcharge
	addtimer(CALLBACK(src, .proc/updateicon), 5)

/obj/item/weapon/stock_parts/cell/proc/updateicon()
	cut_overlays()

	if(charge < 0.01)
		return
	else if(charge/maxcharge >=0.995)
		add_overlay(image('icons/obj/power.dmi', "cell-o2"))
	else
		add_overlay(image('icons/obj/power.dmi', "cell-o1"))

/obj/item/weapon/stock_parts/cell/proc/percent()		// return % charge of cell
	return 100.0*charge/maxcharge

// use power from a cell, returns the amount actually used
/obj/item/weapon/stock_parts/cell/use(amount)
	if(amount < 0)
		stack_trace("[src.type]/use() called with a negative parameter [amount]")
		return 0
	if(rigged && amount > 0)
		explode()
		return 0

	var/used = min(charge, amount)
	charge -= used
	return used

// recharge the cell
/obj/item/weapon/stock_parts/cell/proc/give(amount)
	if(amount < 0)
		stack_trace("[src.type]/give() called with a negative parameter [amount]")
		return 0
	if(rigged && amount > 0)
		explode()
		return 0

	if(maxcharge < amount)	return 0
	var/power_used = min(maxcharge-charge,amount)
	if(crit_fail)	return 0
	if(!prob(reliability))
		minor_fault++
		if(prob(minor_fault))
			crit_fail = 1
			return 0
	charge += power_used
	return power_used


/obj/item/weapon/stock_parts/cell/examine(mob/user)
	..()
	if(src in view(1, user))
		if(maxcharge <= 2500)
			to_chat(user, "[desc]\nThe manufacturer's label states this cell has a power rating of [maxcharge], and that you should not swallow it.\nThe charge meter reads [round(src.percent() )]%.")
		else
			to_chat(user, "This power cell has an exciting chrome finish, as it is an uber-capacity cell type! It has a power rating of [maxcharge]!\nThe charge meter reads [round(src.percent() )]%.")
		if(crit_fail)
			to_chat(user, "<span class='red'>This power cell seems to be faulty.</span>")

/obj/item/weapon/stock_parts/cell/attack_self(mob/user)
	src.add_fingerprint(user)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		var/obj/item/clothing/gloves/space_ninja/SNG = H.gloves
		if(istype(SNG) && SNG.candrain && !SNG.draining)
			SNG.drain(src, H.wear_suit)

		if(H.species.flags[IS_SYNTHETIC] && H.a_intent == INTENT_GRAB)
			if(user.is_busy())
				return
			var/obj/item/organ/internal/liver/IO = H.organs_by_name[O_LIVER]
			var/obj/item/weapon/stock_parts/cell/C = locate(/obj/item/weapon/stock_parts/cell) in IO
			user.SetNextMove(CLICK_CD_MELEE)
			if(C)
				if(charge <= 0)
					to_chat(user, "<span class='warning'>This cell is empty and of no use.</span>")
					return
				if(!(H.nutrition <= C.maxcharge*0.9))
					to_chat(user, "<span class='warning'>Procedure interrupted. Charge at maximum capacity.</span>")
					return

				if (do_after(user,30,target = src))
					var/drain = C.maxcharge-H.nutrition
					if(drain > src.charge)
						drain = src.charge
					H.nutrition += src.use(drain)
					updateicon()
					to_chat(user, "<span class='notice'>[round(100.0*drain/maxcharge, 1)]% of energy gained from the cell.</span>")
				else
					to_chat(user, "<span class='warning'>Procedure interrupted. Protocol terminated.</span>")
					return

/obj/item/weapon/stock_parts/cell/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = I
		user.SetNextMove(CLICK_CD_RAPID)

		to_chat(user, "You inject the solution into the power cell.")

		if(S.reagents.has_reagent("phoron", 5))
			rigged = 1

			log_admin("LOG: [user.name] ([user.ckey]) injected a power cell with phoron, rigging it to explode.")
			message_admins("LOG: [user.name] ([user.ckey]) injected a power cell with phoron, rigging it to explode. [ADMIN_JMP(user)]")

		S.reagents.clear_reagents()
		return
	return ..()

/obj/item/weapon/stock_parts/cell/proc/explode()
	var/turf/T = get_turf(src.loc)
/*
 * 1000-cell	explosion(T, -1, 0, 1, 1)
 * 2500-cell	explosion(T, -1, 0, 1, 1)
 * 10000-cell	explosion(T, -1, 1, 3, 3)
 * 15000-cell	explosion(T, -1, 2, 4, 4)
 * */
	if (charge==0)
		return
	var/devastation_range = -1 //round(charge/11000)
	var/heavy_impact_range = round(sqrt(charge)/58)
	var/light_impact_range = round(sqrt(charge)/27)
	var/flash_range = light_impact_range
	if (light_impact_range==0)
		rigged = 0
		corrupt()
		return
	//explosion(T, 0, 1, 2, 2)

	log_admin("LOG: Rigged power cell explosion, last touched by [fingerprintslast]")
	message_admins("LOG: Rigged power cell explosion, last touched by [fingerprintslast] [ADMIN_JMP(T)]")

	explosion(T, devastation_range, heavy_impact_range, light_impact_range, flash_range)

	crit_fail = 1
	charge = 0
	maxcharge = 1
	icon_state = "cell_explode"
	updateicon()


/obj/item/weapon/stock_parts/cell/proc/corrupt()
	charge /= 2
	maxcharge /= 2
	if (prob(10))
		rigged = 1 //broken batterys are dangerous

/obj/item/weapon/stock_parts/cell/emp_act(severity)
	charge -= 1000 / severity
	if (charge < 0)
		charge = 0
	if(reliability != 100 && prob(50/severity))
		reliability -= 10 / severity
	..()

/obj/item/weapon/stock_parts/cell/ex_act(severity)

	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
			if (prob(50))
				corrupt()
		if(3.0)
			if (prob(25))
				qdel(src)
				return
			if (prob(25))
				corrupt()
	return

/obj/item/weapon/stock_parts/cell/blob_act()
	if(prob(75))
		explode()

/obj/item/weapon/stock_parts/cell/proc/get_electrocute_damage()
	switch (charge)
/*		if (9000 to INFINITY)
			return min(rand(90,150),rand(90,150))
		if (2500 to 9000-1)
			return min(rand(70,145),rand(70,145))
		if (1750 to 2500-1)
			return min(rand(35,110),rand(35,110))
		if (1500 to 1750-1)
			return min(rand(30,100),rand(30,100))
		if (750 to 1500-1)
			return min(rand(25,90),rand(25,90))
		if (250 to 750-1)
			return min(rand(20,80),rand(20,80))
		if (100 to 250-1)
			return min(rand(20,65),rand(20,65))*/
		if (1000000 to INFINITY)
			return min(rand(50,160),rand(50,160))
		if (200000 to 1000000-1)
			return min(rand(25,80),rand(25,80))
		if (100000 to 200000-1)//Ave powernet
			return min(rand(20,60),rand(20,60))
		if (50000 to 100000-1)
			return min(rand(15,40),rand(15,40))
		if (1000 to 50000-1)
			return min(rand(10,20),rand(10,20))
		else
			return 0
