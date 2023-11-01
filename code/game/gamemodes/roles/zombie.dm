/datum/role/zombie
	name = ZOMBIE
	id = ZOMBIE

	antag_hud_type = ANTAG_HUD_ZOMB
	antag_hud_name = "hudzombie"

	logo_state = "zombie-logo"

/datum/role/zombie/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "Вы — оживший, разлагающийся и вечно голодный мертвец. Голод столь силен, что позволяет вам учуять живых людей на любом расстоянии. Доберитесь до них и съешьте их мозги! И остерегайтесь растений.")
