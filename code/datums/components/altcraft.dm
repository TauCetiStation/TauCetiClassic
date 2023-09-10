/datum/component/altcraft/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_CLICK_CTRL_SHIFT, PROC_REF(show_radial_recipes))

/datum/component/altcraft/proc/check_menu()
	var/mob/living/carbon/human/H = parent
	if(H.incapacitated() || !H.Adjacent(parent))
		return FALSE
	return TRUE

/datum/component/altcraft/proc/show_radial_recipes(datum/source, atom/A)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = parent
	var/obj/item/X = A
	var/datum/personal_crafting/crafting_menu = H.handcrafting
	if(!crafting_menu)
		return
	var/list/available_recipes = list()
	var/list/surroundings = crafting_menu.get_surroundings(H)
	var/list/recipes_radial = list()
	var/list/recipes_craft = list()
	for(var/recipe in global.crafting_recipes)
		var/datum/crafting_recipe/potential_recipe = recipe
		for(var/c in potential_recipe.reqs)
			if(istype(X, c))
				// dont show recipes that don't involve this item
				if(crafting_menu.check_contents(potential_recipe, surroundings)) // don't show recipes we can't actually make
					available_recipes.Add(potential_recipe)
	for(var/available_recipe in available_recipes)
		var/datum/crafting_recipe/available_recipe_datum = available_recipe
		var/atom/craftable_atom = available_recipe_datum.result
		recipes_radial.Add(list(initial(craftable_atom.name) = image(icon = initial(craftable_atom.icon), icon_state = initial(craftable_atom.icon_state))))
		recipes_craft.Add(list(initial(craftable_atom.name) = available_recipe_datum))
	INVOKE_ASYNC(src, PROC_REF(radial_menu_enable), recipes_radial, recipes_craft, H, crafting_menu)

/datum/component/altcraft/proc/radial_menu_enable(list/recipes_radial, list/recipes_craft, mob/H, datum/personal_crafting/crafting_menu)
	var/recipe_chosen = show_radial_menu(H, H, recipes_radial, custom_check = CALLBACK(src, PROC_REF(check_menu), H), require_near = TRUE, tooltips = TRUE)
	if(!recipe_chosen)
		return
	var/datum/crafting_recipe/chosen_recipe = recipes_craft[recipe_chosen]
	to_chat(H, "crafting [chosen_recipe.name]")
	crafting_menu.craft_until_cant(chosen_recipe, H, get_turf(parent))

/datum/component/altcraft/Destroy()
	UnregisterSignal(parent, COMSIG_CLICK_CTRL_SHIFT)
	return ..()
