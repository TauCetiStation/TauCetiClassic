// How long the window survives after the target left the initiator's view.
#define INTERACTION_PANEL_VIEW_GRACE (2 SECONDS)

/*
 * One panel per player, retargeted instead of reopened.
 * Lives on the initiator, keeps a weakref to the current target.
 */
/datum/interaction_panel
	var/mob/living/carbon/human/owner
	var/datum/weakref/target_ref
	var/left_view_at = 0

/datum/interaction_panel/New(mob/living/carbon/human/new_owner)
	owner = new_owner

/datum/interaction_panel/Destroy()
	owner = null
	target_ref = null
	return ..()

/datum/interaction_panel/proc/open_on(mob/living/target)
	target_ref = WEAKREF(target)
	left_view_at = 0

	tgui_interact(owner)

/datum/interaction_panel/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "InteractionPanel", "Интеракции", 340, 460)
		ui.open()

// The window lives as long as its target stays in the owner's view, which no shared state knows about.
/datum/interaction_panel/tgui_status(mob/user, datum/tgui_state/state)
	if(user != owner)
		return UI_CLOSE

	var/mob/living/target = target_ref?.resolve()
	if(QDELETED(target))
		return UI_CLOSE

	var/status = user.shared_ui_interaction(src)
	if(status <= UI_DISABLED)
		return status

	if(target in view(user))
		left_view_at = 0
		return status

	if(!left_view_at)
		left_view_at = world.time
	else if(world.time > left_view_at + INTERACTION_PANEL_VIEW_GRACE)
		return UI_CLOSE

	return UI_DISABLED

// Rebuilt on every push, and shipped as dynamic data: the owner's emote set can change
// mid-round, and tgui would never hand out a fresh copy of anything it cached as static.
/datum/interaction_panel/proc/get_interactions()
	var/list/interactions = list()
	for(var/key in owner.current_emotes)
		var/datum/emote/human/interaction/interaction = owner.current_emotes[key]
		if(!istype(interaction))
			continue
		interactions += interaction

	return interactions

/datum/interaction_panel/tgui_data(mob/user)
	var/list/data = list()
	var/mob/living/target = target_ref?.resolve()

	data["targetName"] = target ? "[target]" : null
	data["interactions"] = list()
	data["states"] = list()

	if(!target)
		return data

	for(var/datum/emote/human/interaction/interaction as anything in get_interactions())
		data["interactions"] += list(list(
			"key" = interaction.key,
			"name" = interaction.name,
			"desc" = interaction.description,
			"contact" = interaction.interaction_range <= 1,
		))

		var/reason = interaction.get_interaction_block_reason(owner, target, TRUE)
		data["states"][interaction.key] = list(
			"available" = isnull(reason),
			"reason" = reason,
		)

	return data

/datum/interaction_panel/tgui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("interact")
			var/mob/living/target = target_ref?.resolve()
			if(QDELETED(target))
				return TRUE

			var/datum/emote/human/interaction/interaction = owner.get_emote(params["key"])
			if(!istype(interaction))
				return TRUE

			interaction.try_interact(owner, target, TRUE)
			return TRUE

/mob/living/CtrlShiftClick(mob/user)
	. = ..()
	if(!ishuman(user) || user == src || !can_be_interacted_with())
		return

	var/mob/living/carbon/human/H = user
	if(!H.interaction_panel)
		H.interaction_panel = new(H)

	H.interaction_panel.open_on(src)

#undef INTERACTION_PANEL_VIEW_GRACE
