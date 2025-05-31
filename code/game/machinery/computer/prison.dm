/obj/machinery/computer/prison
	name = "Prison Computer"
	density = TRUE
	anchored = TRUE
	icon_state = "computer_old"
	state_broken_preset = "computer_oldb"
	state_nopower_preset = "computer_old0"
	light_color = "#315ab4"

	var/datum/minigame/minesweeper/Game

/obj/machinery/computer/prison/atom_init()
	. = ..()

	Game = new()
	Game.setup_game()

/obj/machinery/computer/prison/attack_hand(mob/user)
	tgui_interact(user)

/obj/machinery/computer/prison/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Minesweeper")
		ui.open()

/obj/machinery/computer/prison/tgui_data(mob/user)
	var/list/data = list()

	data["grid"] = Game.grid
	data["width"] = Game.grid_x*30
	data["height"] = Game.grid_y*30
	data["mines"] = "Сапёр. [num2text(Game.grid_mines)] мин."

	return data

/obj/machinery/computer/prison/tgui_act(action, params)
	. = ..()
	if(.)
		return
	if(action == "button_press")
		if(Game.button_press(text2num(params["choice_y"]), text2num(params["choice_x"])))
			playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER, 100, TRUE)
		else
			lost()
			return TRUE

	if(action == "button_flag")
		if(Game.button_flag(text2num(params["choice_y"]), text2num(params["choice_x"])))
			playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER, 100, TRUE)


	if(Game.check_complete())
		won()

	return TRUE

/obj/machinery/computer/prison/proc/won()
	playsound(src, 'sound/machines/arcade/e_death.ogg', VOL_EFFECTS_MASTER, 80, FALSE, null, -6)
	Game.setup_game()
	SStgui.close_uis(src)

	if(emagged)
		empulse(loc, 10, 15, custom_effects = EMP_SEBB)
		emagged = FALSE

/obj/machinery/computer/prison/proc/lost()
	playsound(src, pick('sound/machines/arcade/gethit1.ogg', 'sound/machines/arcade/gethit2.ogg'), VOL_EFFECTS_MASTER, 80, FALSE, null, -6)
	Game.setup_game()
	SStgui.close_uis(src)

	if(emagged)
		explosion(loc, 0, 1, 7)
		emagged = FALSE

/obj/machinery/computer/prison/emag_act(mob/user)
	if(emagged)
		return FALSE

	playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 80, FALSE, null, -6)
	to_chat(user, "<span class='warning'>Новый уровень сложности разблокирован!</span>")
	emagged = TRUE
