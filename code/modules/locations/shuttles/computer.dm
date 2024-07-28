/obj/machinery/computer/research_shuttle/new_shuttle_white
	icon = 'icons/locations/shuttles/computer_shuttle_white.dmi'

/obj/machinery/computer/mining_shuttle/new_shuttle_mining
	icon = 'icons/locations/shuttles/computer_shuttle_mining.dmi'

/obj/machinery/computer/security/erokez
	name = "security camera monitor"
	cases = list("монитор камер видеонаблюдения", "монитора камер видеонаблюдения", "монитору камер видеонаблюдения", "монитор камер видеонаблюдения", "монитором камер видеонаблюдения", "мониторе камер видеонаблюдения")
	desc = "Используется для доступа к различным камерам на станции."
	icon = 'icons/obj/computer.dmi'
	icon_state = "erokez"
	light_color = "#ffffbb"
	network = list("SS13")

/obj/machinery/computer/security/erokez/update_icon()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"
	return

/obj/machinery/computer/crew/erokez
	name = "crew monitoring computer"
	cases = list("компьютер контроля за состоянием экипажа", "компьютера контроля за состоянием экипажа", "компьютеру контроля за состоянием экипажа", "компьютер контроля за состоянием экипажа", "компьютером контроля за состоянием экипажа", "компьютере контроля за состоянием экипажа")
	desc = "Используется для мониторинга активных датчиков состояния здоровья, встроенных в большую часть униформы экипажа."
	icon = 'icons/obj/computer.dmi'
	icon_state = "erokezz"
	light_color = "#315ab4"

/obj/machinery/computer/crew/erokez/update_icon()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"
	return
