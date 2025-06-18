/* Stack type objects!
 * Contains:
 * 		Stacks
 * 		Recipe datum
 * 		Recipe list datum
 */

/*
 * Stacks
 */
/obj/item/stack
	gender = PLURAL
	origin_tech = "materials=1"
	usesound = 'sound/items/Deconstruct.ogg'

	var/list/datum/stack_recipe/recipes
	var/singular_name
	var/amount = 1
	var/max_amount = 50                 // also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount
	var/merge_type = null               // This path and its children should merge with this stack, defaults to src.type
	var/full_w_class = SIZE_SMALL // The weight class the stack should have at amount > 2/3rds max_amount
	var/is_fusion_fuel

/obj/item/stack/atom_init(mapload, new_amount = null, merge = FALSE)
	. = ..()

	if(new_amount)
		amount = new_amount
	if(!merge_type)
		merge_type = type
	if(merge)
		for(var/obj/item/stack/S in loc)
			if(S.merge_type == merge_type)
				merge(S)

	update_weight()
	update_icon()

/obj/item/stack/Destroy()
	amount = 0 // lets say anything that wants to use us, that we are empty.

	if (usr && usr.machine == src)
		usr << browse(null, "window=stack")
	if(recipes)
		recipes = null

	return ..()

/obj/item/stack/proc/update_weight()
	if(amount <= (max_amount * (1 / 3)))
		w_class = clamp(full_w_class - 2, SIZE_MINUSCULE, full_w_class)
	else if (amount <= (max_amount * (2 / 3)))
		w_class = clamp(full_w_class - 1, SIZE_MINUSCULE, full_w_class)
	else
		w_class = full_w_class

/obj/item/stack/examine(mob/user)
	..()
	if(src in view(1, user))
		if(get_amount() > 1)
			to_chat(user, "There are [get_amount()] [get_stack_name()] in the stack.")
		else
			to_chat(user, "There is [get_amount()] [get_stack_name()] in the stack.")

/obj/item/stack/proc/get_stack_name()
	if(singular_name)
		if(get_amount() > 1)
			return "[singular_name]\s"
		else
			return "[singular_name]"
	else
		return ""

/obj/item/stack/attack_self(mob/user)
	tgui_interact(user)

/obj/item/stack/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Stack", name)
		ui.open()

/obj/item/stack/tgui_data(mob/user, datum/tgui/ui, datum/tgui_state/state)
	var/list/data = list()

	data["amount"] = get_amount()

	return data

/obj/item/stack/tgui_static_data(mob/user, datum/tgui/ui, datum/tgui_state/state)
	var/list/data = list()

	data["recipes"] = recursively_build_recipes(recipes)

	return data

/obj/item/stack/proc/recursively_build_recipes(list/recipe_to_iterate)
	var/list/L = list()
	for(var/recipe in recipe_to_iterate)
		if(istype(recipe, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/R = recipe
			L["[R.title]"] = recursively_build_recipes(R.recipes)
		if(istype(recipe, /datum/stack_recipe))
			var/datum/stack_recipe/R = recipe
			L["[R.title]"] = build_recipe(R)

	return L

/obj/item/stack/proc/build_recipe(datum/stack_recipe/R)
	return list(
		"res_amount" = R.res_amount,
		"max_res_amount" = R.max_res_amount,
		"req_amount" = R.req_amount,
		"ref" = "\ref[R]",
	)

/obj/item/stack/tgui_state(mob/user)
	return global.interactive_reach_state

/obj/item/stack/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("make")
			if(get_amount() < 1)
				qdel(src)
				return

			var/datum/stack_recipe/R = locate(params["ref"])
			if(!is_valid_recipe(R, recipes)) //href exploit protection
				return FALSE
			var/multiplier = text2num(params["multiplier"])
			if(!multiplier || (multiplier <= 0)) //href exploit protection
				return
			produce_recipe(R, multiplier, usr)
			return TRUE

/obj/item/stack/proc/produce_recipe(datum/stack_recipe/recipe, quantity, mob/living/user)
	var/datum/stack_recipe/R = recipe
	var/multiplier = quantity
	if (!multiplier) multiplier = 1
	 // don't forget to copypaste checks to /datum/craft_or_build/proc/can_build
	if(src.amount < (R.req_amount*multiplier))
		if (R.req_amount*multiplier>1)
			to_chat(usr, "<span class='warning'>You haven't got enough [src] to build \the [R.req_amount*multiplier] [R.title]\s!</span>")
		else
			to_chat(usr, "<span class='warning'>You haven't got enough [src] to build \the [R.title]!</span>")
		return
	if (R.build_outline)
		usr.client.cob.turn_on_build_overlay(usr.client, R, src)
		return
	if (R.max_per_turf)
		if(R.max_per_turf == 1 && (locate(R.result_type) in usr.loc))
			to_chat(usr, "<span class='warning'>There is another [R.title] here!</span>")
			return
		else
			var/already_have = 0
			for(var/type in usr.loc)
				if(istype(type, R.result_type))
					already_have++
			if(already_have >= R.max_per_turf)
				to_chat(usr, "<span class='warning'>You can't build another [R.title] here!</span>")
				return
	if (R.time)
		if(usr.is_busy())
			return
		to_chat(usr, "<span class='notice'>Building [R.title] ...</span>")
		if (!do_skilled(usr, usr, R.time, R.required_skills, -0.2))
			return
	var/atom/build_loc = loc
	if(!use(R.req_amount*multiplier))
		return
	var/atom/movable/O = new R.result_type(build_loc)
	user.try_take(O, build_loc)
	O.set_dir(usr.dir)
	if (R.max_res_amount>1)
		var/obj/item/stack/new_item = O
		new_item.amount = R.res_amount*multiplier
	O.add_fingerprint(usr)
	//BubbleWrap - so newly formed boxes are empty
	if ( istype(O, /obj/item/weapon/storage) )
		for (var/obj/item/I in O)
			qdel(I)
	//BubbleWrap END

/obj/item/stack/proc/is_valid_recipe(datum/stack_recipe/R, list/recipe_list)
	for(var/S in recipe_list)
		if(S == R)
			return TRUE
		if(istype(S, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/L = S
			if(is_valid_recipe(R, L.recipes))
				return TRUE

	return FALSE

/obj/item/stack/proc/get_amount()
	. = (amount)

/obj/item/stack/proc/is_cyborg()
	return istype(loc, /obj/item/weapon/robot_module) || issilicon(loc)

/obj/item/stack/use(used, transfer = FALSE)
	if(used < 0)
		stack_trace("[src.type]/use() called with a negative parameter")
		return FALSE
	if(zero_amount())
		return FALSE
	if(amount < used)
		return FALSE

	amount -= used

	if(!zero_amount())
		update_weight()
		update_icon()

	return TRUE

/obj/item/stack/tool_use_check(mob/living/user, amount)
	if(get_amount() < amount)
		if(singular_name)
			if(amount > 1)
				to_chat(user, "<span class='warning'>You need at least [amount] [singular_name]\s to do this!</span>")
			else
				to_chat(user, "<span class='warning'>You need at least [amount] [singular_name] to do this!</span>")
		else
			to_chat(user, "<span class='warning'>You need at least [amount] to do this!</span>")

		return FALSE

	return TRUE

/obj/item/proc/use_multi(mob/user, list/res_list)
	. = TRUE
	for(var/x in res_list)
		var/obj/item/stack/S = x
		if(S.amount < res_list[x])
			. = FALSE
			to_chat(user, "<span class='notice'>There is not enough [S.name]. You need [res_list[x]].</span>")
			break
	if(.)
		for(var/x in res_list)
			var/obj/item/stack/S = x
			S.use(res_list[x])

/obj/item/stack/proc/zero_amount()
	if(amount < 1)
		if(!is_cyborg())
			qdel(src)
		return TRUE
	return FALSE

/obj/item/stack/proc/add(_amount)
	if(_amount < 0)
		stack_trace("[src.type]/add() called with a negative parameter")
		return
	amount += _amount
	update_icon()
	update_weight()

/obj/item/stack/proc/set_amount(_amount)
	amount = _amount
	if(!zero_amount())
		update_icon()
		update_weight()

/obj/item/stack/proc/merge(obj/item/stack/S) //Merge src into S, as much as possible
	if(QDELETED(S) || QDELETED(src) || S == src) //amusingly this can cause a stack to consume itself, let's not allow that.
		return
	var/transfer = get_amount()
	var/old_loc = loc
	transfer = min(transfer, S.max_amount - S.amount)
	if(pulledby)
		pulledby.start_pulling(S)
	S.copy_evidences(src)
	use(transfer, TRUE)
	if (istype(old_loc, /obj/item/weapon/storage) && amount < 1 && !is_cyborg())
		var/obj/item/weapon/storage/s = old_loc
		s.update_ui_after_item_removal()
	S.add(transfer)

/obj/item/stack/Move(NewLoc, Dir, step_x, step_y)
	. = ..()
	if(!.)
		return .
	if(!isturf(NewLoc, loc))
		return .
	var/turf/T = NewLoc
	for(var/obj/item/stack/AM in T.contents)
		if(throwing || AM.throwing)
			continue
		if(istype(AM, merge_type))
			var/obj/item/stack/S = AM
			S.merge(src)

/obj/item/stack/attack_hand(mob/user)
	if (user.get_inactive_hand() == src)
		if(zero_amount())
			return
		change_stack(user, 1)
		if(!QDELETED(src) && usr.machine == src)
			INVOKE_ASYNC(src, PROC_REF(interact), usr)
	else
		..()

/obj/item/stack/AltClick(mob/living/user)
	if(!istype(user) || !CanUseTopic(user))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!Adjacent(user))
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return
	if(is_cyborg())
		return
	else
		if(zero_amount())
			return
		//get amount from user
		var/min = 0
		var/max = get_amount()
		var/stackmaterial = round(input(user,"How many sheets do you wish to take out of this stack? (Maximum  [max])") as num)
		if(stackmaterial == null || stackmaterial <= min || stackmaterial >= get_amount() || !CanUseTopic(user))
			return
		else
			change_stack(user, stackmaterial)
			to_chat(user, "<span class='notice'>You take [stackmaterial] sheets out of the stack</span>")

/obj/item/stack/proc/change_stack(mob/living/user, amount)
	var/obj/item/stack/F = new type(loc, amount, FALSE)
	user.try_take(F, loc)
	. = F
	F.copy_evidences(src)
	add_fingerprint(user)
	F.add_fingerprint(user)
	use(amount, TRUE)

/obj/item/stack/attackby(obj/item/I, mob/user, params)
	if(istype(I, merge_type))
		var/obj/item/stack/S = I
		merge(S)
		to_chat(user, "<span class='notice'>Your [S.name] stack now contains [S.get_amount()] [S.singular_name]\s.</span>")
		if(!QDELETED(S) && usr.machine == S)
			INVOKE_ASYNC(S, TYPE_PROC_REF(/obj/item/stack, interact), usr)
		if(!QDELETED(src) && usr.machine == src)
			INVOKE_ASYNC(src, PROC_REF(interact), usr)
	else
		return ..()

/obj/item/stack/proc/copy_evidences(obj/item/stack/from)
	src.blood_DNA = from.blood_DNA
	src.fingerprints  = from.fingerprints
	src.fingerprintshidden  = from.fingerprintshidden
	src.fingerprintslast  = from.fingerprintslast
	//TODO bloody overlay

/*
 * Recipe datum
 */
/datum/stack_recipe
	/// The title of the recipe
	var/title = "ERROR"
	/// What atom the recipe makes, typepath
	var/atom/result_type
	/// Amount of stack required to make
	var/req_amount = 1
	/// Amount of resulting atoms made
	var/res_amount = 1
	/// Max amount of resulting atoms made
	var/max_res_amount = 1
	/// How long it takes to make, base value. Can vary based on required_skills
	var/time = 0
	/// Number of the resulting atoms is allowed per turf, 0 to disable limit
	var/max_per_turf = 0
	/// Enable or disable preview overlay
	var/build_outline = FALSE
	/// Restrict building only for these floor types
	var/list/turf/floor_path
	/// Skills to check for building time
	var/list/required_skills

/datum/stack_recipe/New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1, time = 0, max_per_turf = 0, build_outline = FALSE, required_skills = null, floor_path = list(/turf/simulated/floor))
	src.title = title
	src.result_type = result_type
	src.req_amount = req_amount
	src.res_amount = res_amount
	src.max_res_amount = max_res_amount
	src.time = time
	src.max_per_turf = max_per_turf
	src.build_outline = build_outline
	src.required_skills = required_skills
	src.floor_path = floor_path

/*
 * Recipe list datum
 */
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes = null
	var/req_amount = 1

/datum/stack_recipe_list/New(title, recipes, req_amount = 1)
	src.title = title
	src.recipes = recipes
	src.req_amount = req_amount
