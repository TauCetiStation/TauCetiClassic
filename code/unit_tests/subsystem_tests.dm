/datum/unit_test/atoms_atom_init_pass
	name = "SUBSYSTEM - ATOMS - atom_init(): there must be no bad init calls."

/datum/unit_test/atoms_atom_init_pass/start_test()
	if(SSatoms.BadInitializeCalls.len) // .len, throws error if not a list.
		fail("\n[SSatoms.InitLog()]")
	else
		pass("All atoms were properly initialized.")

	return TRUE
