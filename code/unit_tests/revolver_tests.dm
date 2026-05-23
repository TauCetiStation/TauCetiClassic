// ---- Russian Revolver / Spin Cylinder unit tests ----

/datum/unit_test/revolver_rus357_single_round
	name = "REVOLVER: rus357 cylinder loads exactly one live round"

/datum/unit_test/revolver_rus357_single_round/start_test()
	var/obj/item/ammo_box/magazine/internal/cylinder/rus357/mag = new
	var/live = mag.ammo_count(FALSE)
	var/total = mag.ammo_count(TRUE)
	qdel(mag)
	if(live != 1)
		fail("Expected 1 live round, got [live]")
		return TRUE
	if(total != 1)
		fail("Expected 1 total casing, got [total]")
		return TRUE
	pass("rus357 cylinder has exactly 1 live round")
	return TRUE

/datum/unit_test/revolver_spin_cylinder_empties_chamber
	name = "REVOLVER: spin_cylinder nulls chamber on empty gun"

/datum/unit_test/revolver_spin_cylinder_empties_chamber/start_test()
	var/obj/item/weapon/gun/projectile/revolver/R = new
	// Unload all rounds so gun is empty
	while(R.get_ammo() > 0)
		var/obj/item/ammo_box/magazine/M = R.magazine
		if(M)
			M.get_round(FALSE)
	R.chambered = null
	R.spin_cylinder(null)
	var/result = isnull(R.chambered)
	qdel(R)
	if(!result)
		fail("spin_cylinder on empty gun should not chamber a round")
		return TRUE
	pass("spin_cylinder on empty gun leaves chambered null")
	return TRUE

/datum/unit_test/revolver_spin_cylinder_probabilistic
	name = "REVOLVER: spin_cylinder with full cylinder never guarantees life or death"

/datum/unit_test/revolver_spin_cylinder_probabilistic/start_test()
	// With 1 live round in a 6-chamber cylinder, spin 100 times.
	// Expect at least one chambered and at least one empty result (probabilistic, not 100% either way).
	var/chambered_count = 0
	var/empty_count = 0
	var/iterations = 100
	for(var/i in 1 to iterations)
		var/obj/item/weapon/gun/projectile/revolver/russian/R = new
		R.spin_cylinder(null)
		if(R.chambered && R.chambered.BB)
			chambered_count++
		else
			empty_count++
		qdel(R)
	if(chambered_count == 0)
		fail("spin_cylinder never chambered a live round in [iterations] iterations (probability broken)")
		return TRUE
	if(empty_count == 0)
		fail("spin_cylinder always chambered a live round in [iterations] iterations (not random)")
		return TRUE
	pass("spin_cylinder is probabilistic: [chambered_count] chambered, [empty_count] empty over [iterations] spins")
	return TRUE

/datum/unit_test/revolver_has_cylinder_flag
	name = "REVOLVER: has_cylinder is TRUE for revolvers, FALSE for doublebarrel"

/datum/unit_test/revolver_has_cylinder_flag/start_test()
	var/obj/item/weapon/gun/projectile/revolver/R = new
	var/obj/item/weapon/gun/projectile/revolver/doublebarrel/DB = new
	var/rev_ok = R.has_cylinder == TRUE
	var/db_ok = DB.has_cylinder == FALSE
	qdel(R)
	qdel(DB)
	if(!rev_ok)
		fail("Base revolver has_cylinder should be TRUE")
		return TRUE
	if(!db_ok)
		fail("Doublebarrel has_cylinder should be FALSE")
		return TRUE
	pass("has_cylinder flags are correct")
	return TRUE
