#define STATE_EMPTY "empty"
#define STATE_BLANK "blank"
#define STATE_MINE "mine"

/datum/minigame/minesweeper
	var/list/grid
	var/grid_x = 0
	var/grid_y = 0
	var/grid_mines = 0
	var/grid_blanks = 0
	var/grid_pressed = 0
	var/list/nearest_mask = list(
							  list(-1, -1), list(0, -1), list(1, -1),
							  list(-1, 0),               list(1, 0),
							  list(-1, 1),  list(0, 1),  list(1, 1)
							)

/datum/minigame/minesweeper/proc/button_press(y, x)
	if(grid[y][x]["flag"])
		return TRUE //We fake pressed a button with a flag
	if(grid[y][x]["state"] == STATE_MINE)
		return FALSE //We lost
	press_button(x, y)
	return TRUE //We pressed a button

/datum/minigame/minesweeper/proc/button_flag(y, x)
	var/list/L = grid[y][x]
	if(L["state"] != STATE_EMPTY)
		L["flag"] = !L["flag"]
		return TRUE //We put a flag

/datum/minigame/minesweeper/proc/setup_game()
	grid_x = rand(10,15)
	grid_y = rand(7,10)

	grid_mines = rand(7,17)

	grid = new/list(grid_y, grid_x)

	for(var/i = 1 to grid_y)
		var/list/Line = grid[i]
		for(var/j = 1 to grid_x)
			Line[j] = list("state" = STATE_BLANK, "x" = j, "y" = i, "nearest" = "", "flag" = FALSE)
			grid_blanks++

	for(var/i = 1 to grid_mines)
		while(TRUE)
			var/y = rand(1,grid_y)
			var/x = rand(1,grid_x)
			var/list/L = grid[y][x]
			if(L["state"] == STATE_MINE)
				continue
			else
				L["state"] = STATE_MINE
				grid_blanks--
				break

/datum/minigame/minesweeper/proc/check_in_grid(x, y)
	return x >= 1 && x <= grid_x && y >= 1 && y <= grid_y

/datum/minigame/minesweeper/proc/press_button(x, y)
	if(grid[y][x]["flag"])
		return
	reveal_button(x,y)

/datum/minigame/minesweeper/proc/reveal_button(x,y)
	if(!check_in_grid(x, y) || grid[y][x]["state"] == STATE_EMPTY || grid[y][x]["flag"])
		return
	grid[y][x]["state"] = STATE_EMPTY
	grid[y][x]["flag"] = FALSE
	grid_pressed++
	if(check_complete())
		return
	var/mi = check_mines(x,y)
	grid[y][x]["nearest"] = mi
	if(mi != " ")
		return

	for(var/list/mask in nearest_mask)
		reveal_button(x + mask[1], y + mask[2])

/datum/minigame/minesweeper/proc/check_mines(x,y)
	var/mins = 0

	for(var/list/mask in nearest_mask)
		if(check_in_grid(x + mask[1], y + mask[2]) && grid[y + mask[2]][x + mask[1]]["state"] == STATE_MINE)
			mins++

	return mins ? num2text(mins) : " "

/datum/minigame/minesweeper/proc/check_complete()
	return grid_pressed == grid_blanks

#undef STATE_EMPTY
#undef STATE_BLANK
#undef STATE_MINE
