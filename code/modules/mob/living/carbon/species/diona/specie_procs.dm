#define DIONA_SUBJECT_NONE 0 // Nobody selected.
#define DIONA_SUBJECT_ALL 1 // Any nymph who can hear.
#define DIONA_SUBJECT_BODY 2 // Any nymph that makes up our body.
#define DIONA_SUBJECT_GESTALT 4 // Any nymph that is in our gestalt-mind-network-thing.
#define DIONA_SUBJECT_MIND 8 // Any nymph that is sitting in us, as in, merged.

/mob/living/carbon/human/proc/order_nymph(mob/living/carbon/monkey/diona/D in (hearers(7, src)|gestalt_subordinates))
	set name = "Order Nymph"
	set desc = "Give an order to this specific nymph."
	set category = "Diona"

	if(stat != CONSCIOUS)
		return

	if(!istype(D))
		return

	var/list/choices = list()
	for(var/com_type in nymph_orders)
		var/datum/nymph_order/NO = nymph_orders[com_type]
		if(NO)
			choices[NO.desc] = NO.command

	if(choices.len)
		var/command_ = input("Choose an order.", "Give Orders") as null|anything in choices
		if(command_)
			var/datum/nymph_order/NO = nymph_orders[choices[command_]]
			var/selector_ = ""
			var/list/pos_selectors = list()
			for(var/selector in NO.allowed_selectors)
				if(selector == "pointer" && (!D.last_pointed || !is_type_in_list(D.last_pointed, NO.allowed_pointers)))
					continue
				pos_selectors[NO.allowed_selectors[selector]] = selector
			if(pos_selectors.len)
				selector_ = input("Choose a selector.", "Give Orders") as null|anything in pos_selectors
			var/language_key = ":q"
			var/turf/H_T = get_turf(src)
			if(istype(H_T, /turf/space))
				language_key = ":f"
			else
				var/datum/gas_mixture/environment = H_T.return_air()
				if(environment)
					var/pressure = environment.return_pressure()
					if(pressure < SOUND_MINIMUM_PRESSURE)
						language_key = ":f"
			var/additional = ""
			if(command_ == "say")
				additional = " " + input("What do you want the nymph to say?", "Say order.") as text
			queue_order("[language_key] [D.my_number] [choices[command_]] [pos_selectors[selector_]][additional]")

/mob/living/carbon/human/proc/give_orders(atom/A in view(7, src))
	set name = "Give Orders"
	set desc = "Select orders for this thing."
	set category = "Diona"

	if(stat != CONSCIOUS)
		return

	var/list/choices = list()
	for(var/com_type in nymph_orders)
		var/datum/nymph_order/target_action/TA = nymph_orders[com_type]
		if(istype(TA) && is_type_in_list(A, TA.allowed_pointers))
			choices[TA.desc] = TA.command

	if(choices.len)
		var/command_ = input("Choose an order.", "Give Orders") as null|anything in choices
		if(command_)
			var/datum/nymph_order/target_action/TA = nymph_orders[choices[command_]]
			var/list/subject_choices = list("Selected - all nymphs that are selected." = "Selected")
			if(TA.permissions_required & DIONA_SUBJECT_ALL)
				subject_choices["All - all nymphs that can hear you."] = "All"
			if(TA.permissions_required & DIONA_SUBJECT_BODY)
				subject_choices["Body - all nymphs that make up your body."] = "Body"
				for(var/obj/item/organ/O in bodyparts)
					if(O.dionified && istype(O.item_holder, /obj/item/nymph_morph_ball))
						var/mob/living/carbon/monkey/diona/D = locate() in O.item_holder
						subject_choices[D.name] = D.my_number
						D.last_pointed = A
			if(TA.permissions_required & DIONA_SUBJECT_GESTALT)
				subject_choices["Gestalt - all nymphs in your hive."] = "Gestalt"
			if(TA.permissions_required & DIONA_SUBJECT_MIND)
				subject_choices["Mind - all nymphs merged with you."] = "Mind"
				for(var/mob/living/carbon/monkey/diona/D in contents)
					subject_choices[D.name] = D.my_number
					D.last_pointed = A
			for(var/mob/living/carbon/monkey/diona/D in hearers(src))
				subject_choices[D.name] = D.my_number
				D.last_pointed = A
			for(var/obj/item/nymph_morph_ball/NM in hearers(src))
				var/mob/living/carbon/monkey/diona/D = locate() in NM
				subject_choices[D.name] = D.my_number
				D.last_pointed = A
			var/subject_ = input("Choose subject(s).", "Give Orders") as null|anything in subject_choices
			if(subject_)
				var/language_key = ":q"
				var/turf/H_T = get_turf(src)
				if(istype(H_T, /turf/space))
					language_key = ":f"
				else
					var/datum/gas_mixture/environment = H_T.return_air()
					if(environment)
						var/pressure = environment.return_pressure()
						if(pressure < SOUND_MINIMUM_PRESSURE)
							language_key = ":f"
				queue_order("[language_key] [subject_choices[subject_]] [choices[command_]] pointer")

/mob/living/carbon/human/proc/create_order()
	set name = "Create Order"
	set desc = "Auto-filling non-manual form of making an order for nymphs."
	set category = "Diona"

	if(stat != CONSCIOUS)
		return

	var/list/choices = list()
	for(var/com_type in nymph_orders)
		var/datum/nymph_order/NO = nymph_orders[com_type]
		if(NO)
			choices[NO.desc] = NO.command

	if(choices.len)
		var/command_ = input("Choose an order.", "Give Orders") as null|anything in choices
		if(command_)
			var/datum/nymph_order/NO = nymph_orders[choices[command_]]
			var/list/subject_choices = list("Selected - All nymphs that are selected." = "Selected")
			if(NO.permissions_required & DIONA_SUBJECT_ALL)
				subject_choices["All - All nymphs that can hear you."] = "All"
			if(NO.permissions_required & DIONA_SUBJECT_BODY)
				subject_choices["Body - All nymphs that make up your body."] = "Body"
				for(var/obj/item/organ/O in bodyparts)
					if(O.dionified && istype(O.item_holder, /obj/item/nymph_morph_ball))
						var/mob/living/carbon/monkey/diona/D = locate() in O.item_holder
						subject_choices[D.name] = D.my_number
			if(NO.permissions_required & DIONA_SUBJECT_GESTALT)
				subject_choices["Gestalt - All nymphs in your hive."] = "Gestalt"
			if(NO.permissions_required & DIONA_SUBJECT_MIND)
				subject_choices["Mind - All nymphs merged with you."] = "Mind"
				for(var/mob/living/carbon/monkey/diona/D in contents)
					subject_choices[D.name] = D.my_number
			for(var/mob/living/carbon/monkey/diona/D in hearers(src))
				subject_choices[D.name] = D.my_number
			for(var/obj/item/nymph_morph_ball/NM in hearers(src))
				var/mob/living/carbon/monkey/diona/D = locate() in NM
				subject_choices[D.name] = D.my_number
			var/subject_ = input("Choose subject(s).", "Give Orders") as null|anything in subject_choices
			if(subject_)
				var/selector_ = ""
				var/list/pos_selectors = list()
				for(var/selector in NO.allowed_selectors)
					pos_selectors[NO.allowed_selectors[selector]] = selector
				if(pos_selectors.len)
					selector_ = input("Choose a selector.", "Give Orders") as null|anything in pos_selectors
				var/language_key = ":q"
				var/turf/H_T = get_turf(src)
				if(istype(H_T, /turf/space))
					language_key = ":f"
				else
					var/datum/gas_mixture/environment = H_T.return_air()
					if(environment)
						var/pressure = environment.return_pressure()
						if(pressure < SOUND_MINIMUM_PRESSURE)
							language_key = ":f"
				var/additional = ""
				if(command_ == "say")
					additional = " " + input("What do you want the nymph to say?", "Say order.") as text
				queue_order("[language_key] [subject_choices[subject_]] [choices[command_]] [pos_selectors[selector_]][additional]")

#undef DIONA_SUBJECT_NONE
#undef DIONA_SUBJECT_BODY
#undef DIONA_SUBJECT_GESTALT
#undef DIONA_SUBJECT_ALL
#undef DIONA_SUBJECT_ME

/mob/living/carbon/human/proc/toggle_gestalt_direct_control()
	set name = "Toggle Control"
	set desc = "You toggle direct control of your selected nymphs."
	set category = "Diona"

	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr

	if(H.stat != CONSCIOUS)
		return

	gestalt_direct_control = !gestalt_direct_control
	to_chat(H, "<span class='notice'>You [H.gestalt_direct_control ? "assume" : "abandon"] direct control of your subordinates.</span>")
	if(!gestalt_direct_control)
		H.verbs -= /mob/living/carbon/human/proc/order_nymph
		H.verbs -= /mob/living/carbon/human/proc/give_orders
		H.verbs -= /mob/living/carbon/human/proc/create_order
		queued_orders = list() // Clearing orders we had to give.
	else
		H.verbs += /mob/living/carbon/human/proc/order_nymph
		H.verbs += /mob/living/carbon/human/proc/give_orders
		H.verbs += /mob/living/carbon/human/proc/create_order

/mob/living/carbon/human/proc/gestalt_sense()
	set name = "Gestalt sense"
	set desc = "Sense all your subordinates(WARNING: Spammy)."
	set category = "Diona"

	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr

	if(H.stat != CONSCIOUS)
		return

	for(var/mob/living/carbon/monkey/diona/D in H.gestalt_subordinates)
		if(D.client)
			continue
		var/span_ = "notice"
		var/dio_string = "[D.name] is in"
		if(D.incapacitated())
			dio_string = "[dio_string] an unknown location!"
			span_ = "warning"
		else if(istype(D.loc.loc, /obj/item/organ))
			var/obj/item/organ/O = D.loc.loc
			if(O in H.bodyparts)
				dio_string = "[dio_string] your [O.name]"
		else if(D.loc == H)
			dio_string = "[dio_string]side of you"
		else
			dio_string = "[dio_string] [get_area(D)]"
		to_chat(H, "<span class=[span_]>[dio_string].</span>")

/mob/living/carbon/human/proc/choose_hive_color()
	set name = "Choose Hive Color"
	set desc = "Choose a color for your hive hud."
	set category = "Diona"

	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr

	if(H.stat != CONSCIOUS)
		return

	var/color_ = input("Please select hive color.", "Gestalt Hive") as color|null
	if(color_)
		H.unique_diona_hive_color = color_

/mob/living/carbon/human/proc/toggle_diona_hud()
	set name = "Toggle Hive Hud"
	set desc = "Toggles the Diona Hive hud on or off."
	set category = "Diona"

	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr

	if(H.incapacitated())
		return

	H.display_diona_hud = !H.display_diona_hud
	if(!H.display_diona_hud) // reset the old cached images
		for(var/image/I in H.diona_hud_images)
			H.client.images -= I
		H.diona_hud_images = list()
	to_chat(H, "<span class='notice'>You turn [H.display_diona_hud ? "on" : "off"] display of hive differentiation.</span>")
