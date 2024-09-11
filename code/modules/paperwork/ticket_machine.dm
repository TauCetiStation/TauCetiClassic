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
	var/obj/item/weapon/folder/folder = new

	var/hatch_open = FALSE

/obj/machinery/ticket_machine/atom_init()
	. = ..()

	folder.name = "мастер-копии"

	for(var/form in global.predefined_forms_list[department]["content"])
		var/datum/form/F = new form
		var/obj/item/weapon/paper/paper = new(folder)
		var/form_content = paper.parsepencode(F.content, Pen)
		paper.name = F.name
		paper.info = form_content
		paper.updateinfolinks()
		paper.update_icon()

	folder.update_icon()
	update_forms()

/obj/machinery/ticket_machine/proc/update_forms()
	forms = list()
	for(var/obj/item/weapon/paper/paper in folder.contents)
		forms[paper] = image('icons/obj/bureaucracy.dmi', "paper_words")

/obj/machinery/ticket_machine/update_icon()
	if(hatch_open || !is_operational())
		icon_state = "ticket_machine_off"
	else
		icon_state = "ticket_machine"

/obj/machinery/ticket_machine/power_change()
	..()
	update_icon()

/obj/machinery/ticket_machine/attackby(obj/item/O, mob/user)
	if(hatch_open && istype(O, /obj/item/weapon/folder) && !folder)
		user.drop_from_inventory(O, src)
		folder = O
		update_forms()
	else if(isscrewing(O))
		if(O.use_tool(src, user, SKILL_TASK_VERY_EASY, volume = 50))
			hatch_open = !hatch_open
			update_icon()
			update_forms()
	else
		return ..()

/obj/machinery/ticket_machine/attack_hand(mob/user)
	if(hatch_open)
		if(!folder)
			return
		user.put_in_hands(folder)
		folder = null
		return

	if(!forms.len || !is_operational())
		return

	user.set_machine(src)
	var/datum/form/selection = show_radial_menu(user, src, forms, require_near = TRUE, tooltips = TRUE)

	if(!selection)
		return
	if(issilicon(user))
		return
	if(stat & (BROKEN|NOPOWER))
		return

	flick("ticket_machine_printing", src)
	playsound(src, 'sound/machines/ticket_printing.ogg', VOL_EFFECTS_MASTER, 100, FALSE)
	addtimer(CALLBACK(src, PROC_REF(print), selection, user), 1 SECOND)

/obj/machinery/ticket_machine/proc/print(obj/item/weapon/paper/paper, mob/user)
	var/obj/item/weapon/paper/printed = paper.create_self_copy()

	if(Adjacent(user))
		user.put_in_hands(printed)

	if(department == "HR")
		global.ticket_machine_number++
		var/obj/item/I = new /obj/item/weapon/card/ticket(loc, global.ticket_machine_number)
		if(Adjacent(user))
			user.put_in_hands(I)
