#define AUTODOC_COOLDOWN 30

/obj/machinery/autodoc
	name = "Autodoc"
	cases = list("автодок", "автодока", "автодоку", "автодок", "автодоком", "автодоке")
	desc = "Используется для оперирования пациентов."
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "autodoc_0"
	anchored = TRUE
	light_color = "#00ff00"
	required_skills = list(/datum/skill/medical = SKILL_LEVEL_NOVICE)

	var/list/datum/auto_surgery/surgeries_queue = list()
	var/list/datum/surgery_step/steps_queue = list()

	var/prev_step_time = 0
	var/locked

/obj/machinery/autodoc/power_change()
	..()
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(2)
	else
		set_light(0)

/obj/machinery/autodoc/relaymove(mob/user)
	if(!user.incapacitated())
		open_machine()

/obj/machinery/autodoc/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Autodoc"

	if (usr.incapacitated())
		return
	if(!do_skill_checks(usr))
		return
	open_machine()
	add_fingerprint(usr)
	return

/obj/machinery/autodoc/open_machine()
	surgeries_queue = list()
	steps_queue = list()
	return ..()

/obj/machinery/autodoc/verb/move_inside()
	set src in oview(1)
	set category = "Object"
	set name = "Enter Autodoc"

	if (usr.incapacitated())
		return
	if(!move_inside_checks(usr, usr))
		return
	close_machine(usr, usr)

/obj/machinery/autodoc/close_machine(mob/living/target = null)
	surgeries_queue = list()
	steps_queue = list()
	return ..()

/obj/machinery/autodoc/proc/move_inside_checks(mob/target, mob/user)
	if(occupant)
		to_chat(user, "<span class='userdanger'>[C_CASE(src, NOMINATIVE_CASE)] уже занят кем-то!</span>")
		return FALSE
	if(!ishuman(target))
		to_chat(user, "<span class='userdanger'>Это устройство может оперировать только гуманоидные формы жизни.</span>")
		return FALSE
	var/mob/living/carbon/human/H = target
	if(H.species.flags[NO_MED_HEALTH_SCAN])
		to_chat(user, "<span class='userdanger'>Это существо нельзя оперировать</span>")
		return FALSE
	if(get_insurance_type(H) == INSURANCE_NONE)
		to_chat(user, "<span class='userdanger'>У пациента отсутствует страховка.</span>")
		return FALSE
	if(target.abiotic())
		to_chat(user, "<span class='userdanger'>У пациента не должно быть чего-либо в руках.</span>")
		return FALSE
	if(!do_skill_checks(user))
		return
	return TRUE

/obj/machinery/autodoc/attackby(obj/item/weapon/grab/G, mob/user)
	if(!istype(G))
		return
	if(!move_inside_checks(G.affecting, user))
		return
	add_fingerprint(user)
	close_machine(G.affecting)
	playsound(src, 'sound/machines/analysis.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/machinery/autodoc/update_icon()
	icon_state = "autodoc_[occupant ? "1" : "0"]"

/obj/machinery/autodoc/MouseDrop_T(mob/target, mob/user)
	if(user.incapacitated())
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>Вы не можете понять, что с этим делать.</span>")
		return
	if(!move_inside_checks(target, user))
		return
	add_fingerprint(user)
	close_machine(target)
	playsound(src, 'sound/machines/analysis.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/machinery/autodoc/AltClick(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>Вы не можете понять, что с этим делать.</span>")
		return
	if(occupant)
		eject()
		return
	var/mob/living/carbon/target = locate() in loc
	if(!target)
		return
	if(!move_inside_checks(target, user))
		return
	add_fingerprint(user)
	close_machine(target)
	playsound(src, 'sound/machines/analysis.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/machinery/autodoc/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
		if(EXPLODE_LIGHT)
			if(prob(75))
				return
	for(var/atom/movable/A in src)
		A.forceMove(get_turf(src))
		A.ex_act(severity)
	qdel(src)

/obj/machinery/autodoc/deconstruct(disassembled)
	for(var/atom/movable/A in src)
		A.forceMove(get_turf(src))
	..()

/obj/machinery/autodoc/process()
	if(prev_step_time + AUTODOC_COOLDOWN > world.time)
		return

	if(steps_queue.len)
		process_step()
		return

	if(surgeries_queue.len)
		process_surgery()
		return

/obj/machinery/autodoc/proc/process_surgery()
	var/list/surgery_list = popleft(surgeries_queue)
	var/surgery_path = surgery_list["surgery_type"]
	var/datum/auto_surgery/surgery = new surgery_path()
	if(!surgery)
		return

	for(var/surgery_step in surgery.steps)
		var/list/step_list = list("target_zone" = surgery_list["target_zone"], "step" = surgery_step, "cost" = surgery.step_cost)
		steps_queue += list(step_list)

	playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
	qdel(surgery)

/obj/machinery/autodoc/proc/process_step()
	var/list/step_list = popleft(steps_queue)
	var/step_path = step_list["step"]
	var/datum/surgery_step/step = new step_path()
	if(!step.is_valid_mutantrace(occupant))
		qdel(step)
		if(!steps_queue.len && !surgeries_queue.len)
			open_machine()
		return
	var/target_zone = step_list["target_zone"]
	if(!try_take_money(step_list["cost"]))
		playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER)
		visible_message("<span class='danger'>Недостаточно средств, операция отменена!</span>")
		open_machine()
		return

	step.end_step_action(occupant, target_zone)

	playsound(src, 'sound/machines/ding.ogg', VOL_EFFECTS_MASTER)
	qdel(step)

	prev_step_time = world.time

	if(!steps_queue.len && !surgeries_queue.len)
		open_machine()

/obj/machinery/autodoc/proc/try_take_money(amount_needed = 0)
	if(!occupant || !ishuman(occupant))
		return FALSE

	var/mob/living/carbon/human/H = occupant
	var/datum/data/record/R = find_record("fingerprint", md5(H.dna.uni_identity), data_core.general)
	if(!R)
		return FALSE
	var/datum/money_account/MA = get_account(R.fields["acc_number"])
	if(!MA)
		return FALSE

	if(MA.money < amount_needed)
		return FALSE

	if(amount_needed > 0)
		charge_to_account(MA.account_number, global.department_accounts["Medical"].account_number, "Оплата за операцию в АвтоДоке", name, -amount_needed)
		charge_to_account(global.department_accounts["Medical"].account_number, MA.account_number, "Оплата за операцию в АвтоДоке", name, amount_needed)

	return TRUE

/obj/machinery/autodoc_console/power_change()
	if(stat & BROKEN)
		icon_state = "autodocconsole-p"
	else if(powered())
		icon_state = initial(icon_state)
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			src.icon_state = "autodocconsole-p"
			stat |= NOPOWER
			update_power_use()
	update_power_use()

/obj/machinery/autodoc_console
	var/obj/machinery/autodoc/connected
	name = "Autodoc Console"
	cases = list("консоль автодока", "консоли автодока", "консоли автодока", "консоль автодока", "консолью автодока", "консоли автодока")
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "autodocconsole"
	anchored = TRUE
	COOLDOWN_DECLARE(next_print)
	required_skills = list(/datum/skill/medical = SKILL_LEVEL_TRAINED)

/obj/machinery/autodoc_console/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/autodoc_console/atom_init_late()
	connected = locate(/obj/machinery/autodoc) in orange(1, src)

/obj/machinery/autodoc_console/ui_interact(mob/user)
	var/mob/living/carbon/human/occupant = connected.occupant
	var/dat = ""
	if(occupant && ishuman(occupant) && !(connected.surgeries_queue.len || connected.steps_queue.len))
		var/mob/living/carbon/human/H = occupant
		var/occupant_insurance = get_insurance_type(H)

		dat += "<form name='choosen_surgeries' action='?src=\ref[src]' method='get'>"
		dat += "<input type='hidden' name='src' value='\ref[src]'>"
		dat += "<input type='hidden' name='choice' value='choosen_surgeries'>"
		for(var/target_zone in global.auto_surgeries)
			var/obj/item/organ/external/bodypart = H.get_bodypart(target_zone)
			dat += "<b>[С_CASE(bodypart, NOMINATIVE_CASE)]</b><br>"
			var/list/surgeries_list = global.auto_surgeries[target_zone]
			if(surgeries_list.len)
				for(var/datum/auto_surgery/surgery in surgeries_list)
					if(is_ensurance_enough(occupant_insurance, surgery.insurance_needed))
						var/list/params_list = list("target_zone" = target_zone, "surgery_type" = surgery.type)
						dat += "<label>[surgery.name]<input type='checkbox' name='[list2params(params_list)]' value='1'></input><br>"
			dat += "<HR><br>"
		dat += "<input type='submit' value='Запустить'></form>"
	else if(connected.surgeries_queue.len || connected.steps_queue.len)
		dat += "В работе..."
	else
		dat += "Положите пациента."

	var/datum/browser/popup = new(user, "window=autodoc_console", (CASE(src, NOMINATIVE_CASE)))
	popup.set_content(dat)
	popup.open()

/obj/machinery/autodoc_console/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["choice"])
		for(var/thing in href_list - list("src", "choice"))
			var/list/thing_list = params2list(thing)
			if(!thing_list)
				continue

			if(!(thing_list["target_zone"] in TARGET_ZONE_ALL))
				continue

			var/surgery_path = text2path(thing_list["surgery_type"])
			if(!ispath(surgery_path))
				continue

			connected.surgeries_queue += list(list("target_zone" = thing_list["target_zone"], "surgery_type" = surgery_path))

	updateUsrDialog()
