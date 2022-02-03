/obj/machinery/computer/crew
	name = "crew monitoring computer"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_state = "crew"
	light_color = "#315ab4"
	use_power = IDLE_POWER_USE
	idle_power_usage = 250
	active_power_usage = 500
	circuit = /obj/item/weapon/circuitboard/crew
	var/obj/nano_module/crew_monitor/crew_monitor
	required_skill = SKILL_MEDICAL
	required_skill_proficiency = SKILL_MEDICAL_NOVICE

/obj/machinery/computer/crew/atom_init()
	crew_monitor = new(src)
	. = ..()


/obj/machinery/computer/crew/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(!fumble_around(user))
		return
	crew_monitor.ui_interact(user, ui_key, ui, force_open)
