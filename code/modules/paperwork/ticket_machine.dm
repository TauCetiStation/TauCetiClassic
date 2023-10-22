var/global/ticket_machine_number = 0
/obj/machinery/ticket_machine
	name = "ticket machine"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "ticket_machine"
	anchored = TRUE
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 15
	active_power_usage = 30

	var/department = "HR"

	var/list/forms = list()

	var/obj/item/weapon/pen/blue/Pen = new

/obj/machinery/ticket_machine/atom_init()
	. = ..()

	for(var/form in global.predefined_forms_list[department]["content"])
		var/datum/form/F = new form
		forms[F] = image('icons/obj/bureaucracy.dmi', "paper_words")

/obj/machinery/ticket_machine/attack_hand(mob/user)
	user.set_machine(src)
	var/datum/form/selection = show_radial_menu(user, src, forms, require_near = TRUE, tooltips = TRUE)

	if(!selection)
		return

	if(issilicon(user))
		return
	if(stat & (BROKEN|NOPOWER))
		return

	flick("ticket_machine_printing", src)
	addtimer(CALLBACK(src, PROC_REF(print), selection), 1 SECOND)

/obj/machinery/ticket_machine/proc/print(datum/form/F)
	var/obj/item/weapon/paper/Paper = new(loc)

	var/form_content = Paper.parsepencode(F.content, Pen)

	Paper.info = form_content
	Paper.updateinfolinks()
	Paper.update_icon()

	global.ticket_machine_number++
	new /obj/item/weapon/card/ticket(loc, global.ticket_machine_number)
