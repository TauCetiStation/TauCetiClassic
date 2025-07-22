#define STATE_BLANK "blank"
#define STATE_BLANK_REVEALED "empty"
#define STATE_FOSSIL "fossil"
#define STATE_FOSSIL_REVEALED "fossil_revealed"

/datum/minigame/excavation
	var/list/grid
	var/grid_x = 13
	var/grid_y = 9
	var/grid_fossils = 0
	var/grid_blanks = 0
	var/grid_pressed = 0
	var/list/one_tile_mask = list(
							  list(-1, 1),  list(0, 1),  list(1, 1),
							  list(-1, 0),               list(1, 0),
							  list(-1, -1), list(0, -1), list(1, -1)
							)
	var/list/two_tile_mask = list(
							         list(-1, 2),  list(0, 2),  list(1, 2),
								list(-2, 1),                        list(2, 1),
							    list(-2, 0),                        list(2, 0),
								list(-2, -1),                       list(2, -1),
							         list(-1, -2), list(0, -2), list(1, -2)
							)

/datum/minigame/excavation/proc/button_press(y, x)
	if(grid[y][x]["state"] == STATE_FOSSIL || grid[y][x]["state"] == STATE_FOSSIL_REVEALED)
		return FALSE //We lost
	press_button(x, y)
	return TRUE //We pressed a button

/datum/minigame/excavation/proc/setup_game()
	grid_fossils = rand(15,19)
	grid_blanks = 0
	grid_pressed = 0

	grid = new/list(grid_y, grid_x)

	for(var/i = 1 to grid_y)
		var/list/Line = grid[i]
		for(var/j = 1 to grid_x)
			Line[j] = list("state" = STATE_BLANK, "x" = j, "y" = i)
			grid_blanks++

	populate_fossils() // lets build our fossil

/datum/minigame/excavation/proc/populate_fossils()
	// lets place a first piece of our fossil in the center of the grid
	var/first_fossil_y = 5
	var/first_fossil_x = 7
	var/list/first_fossil = grid[first_fossil_y][first_fossil_x]
	first_fossil["state"] = STATE_FOSSIL
	grid_fossils-- // 1 less fossil to place
	grid_blanks--

	var/list/fossils = list()
	fossils[++fossils.len] = list("y" = first_fossil_y, "x" = first_fossil_x)
	for(var/i = 1 to grid_fossils)
		while(TRUE) // we will place all of the fossil pieces next to each other
			var/list/fossil_to_start = pick(fossils)
			var/direction_to_move_fossil = pick("vertical", "horizontal")
			var/y = fossil_to_start["y"]
			var/x = fossil_to_start["x"]
			if(direction_to_move_fossil == "vertical")
				if(y <= 2)
					y += 1
				else if(y >= grid_y - 1)
					y -= 1
				else
					y += pick(-1, 1)
			else
				if(x <= 2)
					x += 1
				else if(x >= grid_x - 1)
					x -= 1
				else
					x += pick(-1, 1)
			var/list/L = grid[y][x]
			if(L["state"] == STATE_FOSSIL)
				continue
			else
				L["state"] = STATE_FOSSIL
				fossils[++fossils.len] = list("y" = y, "x" = x)
				grid_blanks--
				break

/datum/minigame/excavation/proc/check_in_grid(x, y)
	return x >= 1 && x <= grid_x && y >= 1 && y <= grid_y

/datum/minigame/excavation/proc/press_button(x, y)
	reveal_button(x,y, FALSE)
	for(var/list/mask in one_tile_mask)
		reveal_button(x + mask[1], y + mask[2], FALSE)
	for(var/list/mask in two_tile_mask)
		reveal_button(x + mask[1], y + mask[2], TRUE)

/datum/minigame/excavation/proc/reveal_button(x, y, only_check_fossil)
	if(!check_in_grid(x, y) || grid[y][x]["state"] == STATE_BLANK_REVEALED)
		return
	if(grid[y][x]["state"] == STATE_FOSSIL)
		grid[y][x]["state"] = STATE_FOSSIL_REVEALED
	if(!only_check_fossil && grid[y][x]["state"] == STATE_BLANK)
		grid[y][x]["state"] = STATE_BLANK_REVEALED
		grid_pressed++

/datum/minigame/excavation/proc/check_complete()
	return grid_pressed == grid_blanks

#undef STATE_BLANK
#undef STATE_BLANK_REVEALED
#undef STATE_FOSSIL
#undef STATE_FOSSIL_REVEALED
