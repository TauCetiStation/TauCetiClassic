/obj/effect/proc_holder/spell/targeted/charge
	name = "Charge"
	desc = "This spell can be used to recharge a variety of things in your hands, \
	 from magical artifacts to electrical components. A creative wizard can even use it to grant magical power to a fellow magic user."
	school = "transmutation"
	charge_max = 600
	clothes_req = 0
	invocation = "DIRI CEL"
	invocation_type = "whisper"
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/charge/cast(list/targets,mob/user = usr)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/C = user
	var/bad_charge = (user.a_intent == INTENT_HARM)
	var/list/hand_items = list(C.get_active_hand(), C.get_inactive_hand())
	var/charged_item = null
	if(C.pulling && isliving(C.pulling))
		var/mob/living/M = C.pulling
		if(isrobot(M))
			var/mob/living/silicon/robot/R = M
			if(R.cell)
				cell_charge(R.cell, bad_charge)
		else if(M.spell_list.len != 0)
			for(var/obj/effect/proc_holder/spell/S in M.spell_list)
				charged_item = S.name
				if(bad_charge)
					if(S.charge_counter == charge_max)
						S.charge_counter = 0
						INVOKE_ASYNC(S, .obj/effect/proc_holder/spell/proc/start_recharge)
					else
						S.charge_counter = 0
				else
					S.charge_counter = S.charge_max
				break
			to_chat(M, "<span class='notice'>You feel raw magic flowing through you. It feels [bad_charge ? "bad" : "good"]!</span>")
		else
			to_chat(M, "<span class='notice'>you feel very strange for a moment, but then it passes.</span>")
	if(!charged_item)
		for(var/obj/item in hand_items)
			if(istype(item, /obj/item/weapon/spellbook))
				to_chat(C, "<span class='notice'>Glowing red letters appear on the front cover...</span>.\
				<span class='warning'>[pick("NICE TRY BUT NO!","CLEVER BUT NOT CLEVER ENOUGH!", "SUCH FLAGRANT CHEESING IS WHY WE ACCEPTED YOUR APPLICATION!", "CUTE!", "YOU DIDN'T THINK IT'D BE THAT EASY, DID YOU?")]</span>")
			else if(istype(item, /obj/item/weapon/gun/magic))
				var/obj/item/weapon/gun/magic/I = item
				if(prob(50) && !I.can_charge)
					I.max_charges = max(0, I.max_charges - 1)
				I.charges = I.max_charges
				charged_item = I.name
				break
			else if(istype(item, /obj/item/weapon/stock_parts/cell))
				cell_charge(item, bad_charge)
				charged_item = item.name
				break
			else if(istype(item, /obj/item/weapon/melee/baton))
				var/obj/item/weapon/melee/baton/B = item
				if(bad_charge)
					B.charges = 0
					B.status = 0
				else
					B.charges = initial(B.charges)
					B.status = 1
				B.update_icon()
				charged_item = B.name
				break
			else
				for(var/obj/item/weapon/stock_parts/cell/Cell in item.contents)
					cell_charge(Cell, bad_charge)
					charged_item = item.name
					break
	if(!charged_item)
		for(var/obj/machinery/MACH in range(1,C))
			if(istype(MACH, /obj/machinery/power/smes))
				var/obj/machinery/power/smes/SMES = MACH
				SMES.charge = bad_charge ? 0 : SMES.capacity
				charged_item = SMES.name
				break
			var/passed = 0
			for(var/obj/item/weapon/stock_parts/cell/Cell in MACH)
				cell_charge(Cell, bad_charge)
				charged_item = MACH.name
				passed = 1
				break
			if(passed)
				break

	if(!charged_item)
		to_chat(C, "<span class='notice'>You feel magical power surging through your hands, but the feeling rapidly fades...</span>")
	else
		playsound(user, 'sound/magic/Charge.ogg', VOL_EFFECTS_MASTER)
		to_chat(C, "<span class='notice'>[charged_item] suddenly feels very [bad_charge ? "cold" : "warm"]!</span>")

/obj/effect/proc_holder/spell/targeted/charge/proc/cell_charge(obj/item/weapon/stock_parts/cell/Cell, bad_charge)
	if(prob(50))
		Cell.maxcharge = max(0, Cell.maxcharge - 200)
	Cell.charge = bad_charge ? 0 : Cell.maxcharge
	Cell.updateicon()
