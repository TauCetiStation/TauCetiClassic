/datum/role/zombie
	name = ZOMBIE
	id = ZOMBIE

	antag_hud_type = ANTAG_HUD_ZOMB
	antag_hud_name = "hudzombie"

	logo_state = "zombie-logo"

/datum/role/zombie/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "Вы оживший, безмозглый, разлагающийся труп с чувством голода. Избегайте растений. Благодаря вашему голоду, вы чуете живых людей. Найдите и съешьте их мозги.")
