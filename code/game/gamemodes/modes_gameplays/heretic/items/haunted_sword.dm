/obj/item/weapon/cultblade
	name = "eldritch longsword"
	desc = "A sword humming with unholy energy. It glows with a dim red light."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "cultblade"
	inhand_icon_state = "cultblade"
	worn_icon_state = "cultblade"
	icon_angle = -45
	lefthand_file = 'icons/heretic/inhands/blades_lefthand.dmi'
	righthand_file = 'icons/heretic/inhands/blades_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	obj_flags = CONDUCTS_ELECTRICITY
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_BULKY
	force = 30 // whoever balanced this got beat in the head by a bible too many times good lord
	throwforce = 10
	block_chance = 50 // now it's officially a cult esword
	wound_bonus = -50
	bare_wound_bonus = 20
	hitsound = 'sound/weapons/bladeslice.ogg'
	block_sound = 'sound/weapons/parry.ogg'
	attack_verb = list("attack", "slash", "slice", "tear", "lacerate", "rip", "dice", "rend")
	/// If TRUE, it can be used at will by anyone, non-cultists included
	var/free_use = FALSE
	var/list/alt_continuous = list("stabs", "pierces", "impales")
	var/list/alt_simple = list("stab", "pierce", "impale")

/obj/item/weapon/cultblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
	speed = 4 SECONDS, \
	effectiveness = 100, \
	)
	alt_continuous = string_list(alt_continuous)
	alt_simple = string_list(alt_simple)
	AddComponent(/datum/component/alternative_sharpness, SHARP_POINTY, alt_continuous, alt_simple, -5)
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/weapon/cultblade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(iscultist(owner) && prob(final_block_chance))
		new /obj/effect/temp_visual/cult/sparks(get_turf(owner))
		owner.visible_message(span_danger("[owner] parries [attack_text] with [src]!"))
		return TRUE
	else
		return FALSE

/obj/item/weapon/cultblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(!iscultist(user) && !free_use)
		user.Paralyze(100)
		user.dropItemToGround(src, TRUE)
		user.visible_message(span_warning("A powerful force shoves [user] away from [target]!"), \
				span_cult_large("\"You shouldn't play with sharp things. You'll poke someone's eye out.\""))
		if(ishuman(user))
			var/mob/living/carbon/human/miscreant = user
			miscreant.apply_damage(rand(force/2, force), BRUTE, pick(GLOB.arm_zones))
		else
			user.adjustBruteLoss(rand(force/2,force))
		return
	..()

#define WIELDER_SPELLS "wielder_spell"
#define SWORD_SPELLS "sword_spell"
#define SWORD_PREFIX "sword_prefix"

/obj/item/weapon/cultblade/haunted
	name = "haunted longsword"
	desc = "An eerie sword with a blade that is less 'black' than it is 'absolute nothingness'. It glows with furious, restrained green energy."
	icon_state = "hauntedblade"
	inhand_icon_state = "hauntedblade"
	worn_icon_state = "hauntedblade"
	force = 30
	throwforce = 25
	block_chance = 55
	wound_bonus = -25
	bare_wound_bonus = 30
	free_use = TRUE
	light_color = COLOR_HERETIC_GREEN
	light_range = 3
	demolition_mod = 1.5
	/// holder for the actual action when created.
	var/list/obj/effect/proc_holder/spell/path_sword_actions
	/// holder for the actual action when created.
	var/list/obj/effect/proc_holder/spell/path_wielder_actions
	var/mob/living/trapped_entity
	/// The heretic path that the variable below uses to index abilities. Assigned when the heretic is ensouled.
	var/heretic_path
	/// If the blade is bound, it cannot utilize its abilities, but neither can its wielder. They must unbind it to use it to its full potential.
	var/bound = TRUE
	/// Nested static list used to index abilities and names.
	var/static/list/heretic_paths_to_haunted_sword_abilities = list(
		// Ash
		PATH_ASH = list(
			WIELDER_SPELLS = list(/obj/effect/proc_holder/spell/jaunt/ethereal_jaunt/ash),
			SWORD_SPELLS = list(/obj/effect/proc_holder/spell/pointed/ash_beams),
			SWORD_PREFIX = "ashen",
		),
		// Flesh
		PATH_FLESH = list(
			WIELDER_SPELLS = list(/obj/effect/proc_holder/spell/pointed/blood_siphon),
			SWORD_SPELLS = list(/obj/effect/proc_holder/spell/pointed/cleave),
			SWORD_PREFIX = "sanguine",
		),
		// Void
		PATH_VOID = list(
			WIELDER_SPELLS = list(/obj/effect/proc_holder/spell/pointed/void_phase),
			SWORD_SPELLS = list(/obj/effect/proc_holder/spell/pointed/void_prison),
			SWORD_PREFIX = "tenebrous",
		),
		// Blade
		PATH_BLADE = list(
			WIELDER_SPELLS = list(/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/haunted),
			SWORD_SPELLS = list(/obj/effect/proc_holder/spell/pointed/projectile/furious_steel/solo),
			SWORD_PREFIX = "keen",
		),
		// Rust
		PATH_RUST = list(
			WIELDER_SPELLS = list(/obj/effect/proc_holder/spell/cone/staggered/entropic_plume),
			SWORD_SPELLS = list(/obj/effect/proc_holder/spell/aoe/rust_conversion, /obj/effect/proc_holder/spell/pointed/rust_construction),
			SWORD_PREFIX = "rusted",
		),
		// Cosmic
		PATH_COSMIC = list(
			WIELDER_SPELLS = list(/obj/effect/proc_holder/spell/conjure/cosmic_expansion),
			SWORD_SPELLS = list(/obj/effect/proc_holder/spell/pointed/projectile/star_blast),
			SWORD_PREFIX = "astral",
		),
		// Lock
		PATH_LOCK = list(
			WIELDER_SPELLS = list(/obj/effect/proc_holder/spell/pointed/burglar_finesse),
			SWORD_SPELLS = list(/obj/effect/proc_holder/spell/pointed/apetra_vulnera),
			SWORD_PREFIX = "incisive",
		),
		// Moon
		PATH_MOON = list(
			WIELDER_SPELLS = list(/obj/effect/proc_holder/spell/pointed/projectile/moon_parade),
			SWORD_SPELLS = list(/obj/effect/proc_holder/spell/pointed/moon_smile),
			SWORD_PREFIX = "shimmering",
		),
		// Starter
		PATH_START = list(
			WIELDER_SPELLS = null,
			SWORD_SPELLS = null,
			SWORD_PREFIX = "stillborn", // lol loser
		) ,
	)
	actions_types = list(/datum/action/item_action/haunted_blade)

/obj/item/weapon/cultblade/haunted/examine(mob/user)
	. = ..()

	var/examine_text = ""
	if(bound)
		examine_text = "[src] shines a dull, sickly green, the power emanating from it clearly bound by the runes on its blade. You could unbind it, and wield its fearsome power. But is it worth loosening the bindings of the spirit inside?"
	else
		examine_text = "[src] flares a bright and malicious pale lime shade. Someone has unbound the spirit within, and power now clearly resonates from inside the blade, barely restrained and brimming with fury. You may attempt to bind it once more, sealing the horror, or try to harness its strength as a blade."

	. += span_cult(examine_text)

/datum/action/item_action/haunted_blade
	name = "Unseal Spirit" // img is of a chained shade
	icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "spirit_sealed"

/datum/action/item_action/haunted_blade/apply_button_icon(atom/movable/screen/movable/action_button/button, force)
	var/obj/item/weapon/cultblade/haunted/blade = target
	if(istype(blade))
		button_icon_state = "spirit_[blade.bound ? "sealed" : "unsealed"]"
		name = "[blade.bound ? "Unseal" : "Seal"] Spirit"

	return ..()

/obj/item/weapon/cultblade/haunted/ui_action_click(mob/living/user, actiontype)
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return // gtfo
	if(bound)
		unbind_blade(user)
		return
	if(user.mind?.holy_role)
		on_priest_handle(user)
	else if(iscultistorcultistmob(user))
		on_cultist_handle(user)
	else if(ishereticormonster(user) || islunatic(user))
		on_heresy_handle(user)
	else if(iswizard(user))
		on_wizard_handle(user)
	else
		on_normie_handle(user)
	return

/obj/item/weapon/cultblade/haunted/proc/on_priest_handle(mob/living/user, actiontype)
	user.visible_message(span_cult_bold("You begin chanting the holy hymns of [GLOB.deity]..."),\
		span_cult_bold("[user] begins chanting while holding [src] aloft..."))
	if(!do_after(user, 6 SECONDS, src))
		to_chat(user, span_notice("You were interrupted!"))
		return
	playsound(user, 'sound/effects/pray_chaplain.ogg',60,TRUE)
	return TRUE

/obj/item/weapon/cultblade/haunted/proc/on_cultist_handle(mob/living/user, actiontype)
	var/binding_implements = list(/obj/item/weapon/cultblade/dagger, /obj/item/weapon/sickly_blade/cursed)
	if(!user.is_holding_item_of_types(binding_implements))
		to_chat(user, span_notice("You need to hold a ritual dagger to bind [src]!"))
		return

	user.visible_message(span_cult_bold("You begin slicing open your palm on top of [src]..."),\
		span_cult_bold("[user] begins slicing open [user.p_their()] palm on top of [src]..."))
	if(!do_after(user, 6 SECONDS, src))
		to_chat(user, span_notice("You were interrupted!"))
		return
	playsound(user, 'sound/weapons/slice.ogg', 30, TRUE)
	return TRUE

/obj/item/weapon/cultblade/haunted/proc/on_heresy_handle(mob/living/user, actiontype)
	// todo make the former a subtype of latter
	var/binding_implements = list(/obj/item/clothing/neck/eldritch_amulet, /obj/item/clothing/neck/heretic_focus)
	if(!user.is_holding_item_of_types(binding_implements))
		to_chat(user, span_notice("You need to hold a focus to bind [src]!"))
		return

	user.visible_message(span_cult_bold("You channel the Mansus through your focus, empowering the sealing runes..."), span_cult_bold("[user] holds up their eldritch focus on top of [src] and begins concentrating..."))
	if(!do_after(user, 6 SECONDS, src))
		to_chat(user, span_notice("You were interrupted!"))
		return
	return TRUE

/obj/item/weapon/cultblade/haunted/proc/on_wizard_handle(mob/living/user, actiontype)
	user.visible_message(span_cult_bold("You begin quickly and nimbly casting the sealing runes."), span_cult_bold("[user] begins tracing anti-light runes on [src]..."))
	if(!do_after(user, 3 SECONDS, src))
		to_chat(user, span_notice("You were interrupted!"))
		return
	return TRUE

/obj/item/weapon/cultblade/haunted/proc/on_normie_handle(mob/living/user, actiontype)
	// todo make the former a subtype of latter
	var/binding_implements = list(/obj/item/weapon/storage/bible)
	if(!user.is_holding_item_of_types(binding_implements))
		to_chat(user, span_notice("You need to wield a bible to bind [src]!"))
		return

	var/passage = "[pick(GLOB.first_names_male)] [rand(1,9)]:[rand(1,25)]" // Space Bibles will have Alejandro 9:21 passages, as part of the Very New Testament.
	user.visible_message(span_cult_bold("You start reading aloud the passage in [passage]..."), span_cult_bold("[user] starts reading aloud the passage in [passage]..."))
	if(!do_after(user, 12 SECONDS, src))
		to_chat(user, span_notice("You were interrupted!"))
		return

	rebind_blade(user)

/obj/item/weapon/cultblade/haunted/proc/unbind_blade(mob/user)
	var/holup = tgui_alert(user, "Are you sure you wish to unseal the spirit within?", "Sealed Evil In A Jar", list("I need the power!", "Maybe not..."))
	if(holup != "I need the power!")
		return
	to_chat(user, span_cult_bold("You start focusing on the power of the blade, letting it guide your fingers along the inscribed runes..."))
	if(!do_after(user, 5 SECONDS, src))
		to_chat(user, span_notice("You were interrupted!"))
		return
	visible_message(span_danger("[user] has unbound [src]!"))
	bound = FALSE
	for(var/obj/effect/proc_holder/spell/sword_spell as anything in path_sword_actions)
		sword_spell.Grant(trapped_entity)
	for(var/obj/effect/proc_holder/spell/wielder_spell as anything in path_wielder_actions)
		wielder_spell.Grant(user)
	free_use = TRUE
	force += 5
	armour_penetration += 10
	light_range += 3
	trapped_entity.update_mob_action_buttons()

	playsound(src ,'sound/misc/insane_low_laugh.ogg', 200, TRUE) //quiet
	binding_filters_update()

/obj/item/weapon/cultblade/haunted/proc/rebind_blade(mob/user)
	visible_message(span_danger("[user] has bound [src]!"))
	bound = TRUE
	force -= 5
	armour_penetration -= 10
	free_use = FALSE // it's a cult blade and you sealed away the other power.
	light_range -= 3
	for(var/obj/effect/proc_holder/spell/sword_spell as anything in path_sword_actions)
		sword_spell.Remove(trapped_entity)
	for(var/obj/effect/proc_holder/spell/wielder_spell as anything in path_wielder_actions)
		wielder_spell.Remove(user)
	trapped_entity.update_mob_action_buttons()

	playsound(src ,'sound/effects/hallucinations/wail.ogg', 20, TRUE)	// add BOUND alert and UNBOUND
	binding_filters_update()

/obj/item/weapon/cultblade/haunted/Initialize(mapload, mob/soul_to_bind, mob/awakener, do_bind = TRUE)
	. = ..()

	AddElement(/datum/element/heretic_focus)
	add_traits(list(TRAIT_CASTABLE_LOC, TRAIT_SPELLS_TRANSFER_TO_LOC), INNATE_TRAIT)
	if(do_bind && !mapload)
		bind_soul(soul_to_bind, awakener)
	binding_filters_update()
	addtimer(CALLBACK(src, PROC_REF(start_glow_loop)), rand(0.1 SECONDS, 1.9 SECONDS))

/obj/item/weapon/cultblade/haunted/proc/bind_soul(mob/soul_to_bind, mob/awakener)

	var/datum/mind/trapped_mind = soul_to_bind?.mind

	if(!trapped_mind)
		return // Can't do anything further down the list

	if(trapped_mind)
		AddComponent(/datum/component/spirit_holding,\
			soul_to_bind = trapped_mind,\
			awakener = awakener,\
			allow_renaming = FALSE,\
			allow_channeling = FALSE,\
			allow_exorcism = FALSE,\
		)

	// Get the heretic's new body and antag datum.
	trapped_entity = trapped_mind?.current
	trapped_entity.key = trapped_mind?.key
	var/datum/role/heretic/heretic_holder = GET_HERETIC(trapped_entity)
	if(!heretic_holder)
		stack_trace("[soul_to_bind] in but not a heretic on the heretic soul blade.")

	// Give the spirit a spell that lets them try to fly around.
	var/obj/effect/proc_holder/spell/pointed/sword_fling/fling_act = \
	new /obj/effect/proc_holder/spell/pointed/sword_fling(trapped_mind, to_fling = src)
	fling_act.Grant(trapped_entity)

	// Set the sword's path for spell selection.
	heretic_path = heretic_holder.heretic_path

	// Copy the objectives to keep for roundend, remove the datum as neither us nor the heretic need it anymore
	var/list/copied_objectives = heretic_holder.objectives.Copy()
	trapped_entity.mind.remove_antag_datum(/datum/role/heretic)

	// Add the fallen antag datum, give them a heads-up of what's happening.
	var/datum/role/soultrapped_heretic/bozo = new()
	bozo.objectives |= copied_objectives
	trapped_entity.mind.add_antag_datum(bozo)

	// Assigning the spells to give to the wielder and spirit.
	// Let them cast the given spell.
	ADD_TRAIT(trapped_entity, TRAIT_ALLOW_HERETIC_CASTING, INNATE_TRAIT)

	var/list/path_spells = heretic_paths_to_haunted_sword_abilities[heretic_path]

	var/list/wielder_spells = path_spells[WIELDER_SPELLS]
	var/list/sword_spells = path_spells[SWORD_SPELLS]

	name = "[path_spells[SWORD_PREFIX]] [name]"


	// Creating the path spells.
	// The sword is created bound - so we do not grant it the spells just yet, but we still create and store them.

	if(sword_spells)
		for(var/obj/effect/proc_holder/spell/sword_spell as anything in sword_spells)
			var/obj/effect/proc_holder/spell/instanced_spell = new sword_spell(trapped_entity)
			LAZYADD(path_sword_actions, instanced_spell)
			instanced_spell.overlay_icon_state = "bg_cult_border" // for flavor, and also helps distinguish

	if(wielder_spells)
		for(var/obj/effect/proc_holder/spell/wielder_spell as anything in wielder_spells)
			var/obj/effect/proc_holder/spell/instanced_spell = new wielder_spell(trapped_entity)
			LAZYADD(path_wielder_actions, instanced_spell)
			instanced_spell.overlay_icon_state = "bg_cult_border"

	binding_filters_update()

/obj/item/weapon/cultblade/haunted/equipped(mob/user, slot, initial)
	. = ..()
	if((!(slot & ITEM_SLOT_HANDS)) || bound)
		return
	for(var/obj/effect/proc_holder/spell/wielder_spell in path_wielder_actions)
		wielder_spell.Grant(user)
	binding_filters_update()

/obj/item/weapon/cultblade/haunted/dropped(mob/user, silent)
	. = ..()
	for(var/obj/effect/proc_holder/spell/wielder_spell in path_wielder_actions)
		wielder_spell.Remove(user)
	binding_filters_update()

/obj/item/weapon/cultblade/haunted/proc/binding_filters_update(mob/user)

	var/h_color = heretic_path ? GLOB.heretic_path_to_color[heretic_path] : "#FF00FF"

	// on bound
	if(bound)
		add_filter("bind_glow", 2, list("type" = "outline", "color" = h_color, "size" = 0.1))
		remove_filter("unbound_ray")
		update_filters()
	// on unbound
	else
		// we re-add this every time it's picked up or dropped
		remove_filter("unbound_ray")
		add_filter(name = "unbound_ray", priority = 1, params = list(
			type = "rays",
			size = 16,
			color = COLOR_HERETIC_GREEN, // the sickly green of the heretic leaking through
			density = 16,
		))
		// because otherwise the animations stack and it looks ridiculous
		var/ray_filter = get_filter("unbound_ray")
		animate(ray_filter, offset = 100, time = 2 MINUTES, loop = -1, flags = ANIMATION_PARALLEL) // Absurdly long animate so nobody notices it hitching when it loops
		animate(offset = 0, time = 2 MINUTES) // I sure hope duration of animate doesnt have any performance effect

	update_filters()

/obj/item/weapon/cultblade/haunted/proc/start_glow_loop()
	var/filter = get_filter("bind_glow")
	if (!filter)
		return

	animate(filter, alpha = 110, time = 1.5 SECONDS, loop = -1)
	animate(alpha = 40, time = 2.5 SECONDS)

#undef WIELDER_SPELLS
#undef SWORD_SPELLS
#undef SWORD_PREFIX

/obj/item/weapon/cultblade/ghost
	name = "eldritch sword"
	force = 19 //can't break normal airlocks
	item_flags = NEEDS_PERMIT | DROPDEL
	flags_1 = NONE
	block_chance = 25 //these dweebs don't get full block chance, because they're free cultists
	block_sound = 'sound/weapons/parry.ogg'

/obj/item/weapon/cultblade/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/weapon/cultblade/pickup(mob/living/user)
	..()
	if(!iscultist(user) && !free_use)
		to_chat(user, span_cult_large("\"I wouldn't advise that.\""))
