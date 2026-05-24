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

/datum/unit_test/revolver_spin_cylinder_full_always_chambers
	name = "REVOLVER: spin_cylinder with full cylinder always chambers"

/datum/unit_test/revolver_spin_cylinder_full_always_chambers/start_test()
	var/obj/item/weapon/gun/projectile/revolver/R = new
	for(var/i in 1 to 20)
		R.spin_cylinder(null)
		if(!R.chambered || !R.chambered.BB)
			qdel(R)
			fail("spin_cylinder failed to chamber on full cylinder (iteration [i])")
			return TRUE
	qdel(R)
	pass("spin_cylinder always chambers on full cylinder")
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
