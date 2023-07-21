/datum/role/zombie
	name = ZOMBIE
	id = ZOMBIE

	antag_hud_type = ANTAG_HUD_ZOMB
	antag_hud_name = "hudzombie"

	logo_state = "zombie-logo"

/datum/role/zombie/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "Вы реанимированый, безмозглый, разлагающийся труп с чуством голода на человеческие мозги. Избегайте растений. Благодаря вашему голоду вы чуеете живые мозги")
