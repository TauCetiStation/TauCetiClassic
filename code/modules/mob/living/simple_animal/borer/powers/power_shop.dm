/obj/effect/proc_holder/borer/active/power_shop
	name = "- Borer Evolution -"
	desc = "Buy some upgrades."
	var/mob/living/simple_animal/borer/holder

/obj/effect/proc_holder/borer/active/power_shop/on_gain(mob/user)
	holder = user
	
/obj/effect/proc_holder/borer/active/power_shop/tgui_status(mob/user)
	return UI_INTERACTIVE

/obj/effect/proc_holder/borer/active/power_shop/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BorerPowerShop", null, 400, 500)
		ui.open()

/obj/effect/proc_holder/borer/active/power_shop/tgui_data(mob/user)
	var/list/data = list(
		"points" = holder.upgrade_points,
		"upgrades" = list()
	)
	for(var/obj/effect/proc_holder/borer/U in holder.all_upgrades)
		if(U.cost == COST_INNATE) 
			continue
		var/list/requirements = list()
		var/has_requirements = TRUE
		for(var/req_path in U.requires_t)
			var/obj/effect/proc_holder/borer/R = locate(req_path) in holder.all_upgrades
			if(!R)
				continue
			requirements += R.name
			if(!(R in holder.upgrades))
				has_requirements = FALSE
		var/list/upgrade = list(
			"name" = U.name,
			"desc" = U.desc,
			"cost" = U.cost,
			"bought" = (U in holder.upgrades),
			"requirements" = requirements,
			"has_requirements" = has_requirements,
		)
		var/obj/effect/proc_holder/borer/active/A = U
		if(istype(A))
			upgrade += list(
				"cooldown" = A.cooldown,
				"chemicals" = A.chemicals,
			)
		data["upgrades"] += list(upgrade)
		
	return data
	
/obj/effect/proc_holder/borer/active/power_shop/tgui_act(action, list/params)
	if(..())
		return
	if(action == "buy")
		var/to_buy = params["name"]
		for(var/obj/effect/proc_holder/borer/U in holder.all_upgrades)
			if(U.name == to_buy)
				buy_upgrade(U)
		return TRUE
	
/obj/effect/proc_holder/borer/active/power_shop/activate(mob/user)
	tgui_interact(user)

/obj/effect/proc_holder/borer/active/power_shop/proc/buy_upgrade(obj/effect/proc_holder/borer/U)
	if(holder.upgrade_points < U.cost)
		return FALSE
	for(var/req_path in U.requires_t)
		if(!locate(req_path) in holder.upgrades)
			return FALSE
	holder.upgrade_points -= U.cost
	holder.upgrades |= U
	U.on_gain(holder)
	return TRUE
