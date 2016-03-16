//TODO: rewrite and standardise all controller datums to the datum/controller type
//TODO: allow all controllers to be deleted for clean restarts (see WIP master controller stuff) - MC done - lighting done

/client/proc/show_distribution_map()
	set category = "Debug"
	set name = "Show Distribution Map"
	set desc = "Print the asteroid ore distribution map to the world."

	if(!holder)	return

	if(master_controller && master_controller.asteroid_ore_map)
		master_controller.asteroid_ore_map.print_distribution_map()

/client/proc/remake_distribution_map()
	set category = "Debug"
	set name = "Remake Distribution Map"
	set desc = "Rebuild the asteroid ore distribution map."

	if(!holder)	return

	if(master_controller && master_controller.asteroid_ore_map)
		master_controller.asteroid_ore_map = new /datum/ore_distribution()
		master_controller.asteroid_ore_map.populate_distribution_map()
