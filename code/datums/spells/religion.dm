//God pick new desire for custom sect
/obj/effect/proc_holder/spell/targeted/pickdesire
	name = "Choose an item to desire"
	favor_cost = 10 //TODO
	charge_max = 120 //TODO
	clothes_req = 0
	invocation = "none"
	range = -1
	include_user = 1
	sound = 'sound/magic/Smoke.ogg' //TODO
	var/list/desire

/obj/effect/proc_holder/spell/targeted/pickdesire/atom_init()
	. = ..()
	desire = list("Cells" = /obj/item/weapon/stock_parts/cell,
				  "Resourses(Glass, minerals, metalls" = /obj/item/stack/sheet,
				  "Foods" = /obj/item/weapon/reagent_containers/food/snacks,
				  "Drinks" = /obj/item/weapon/reagent_containers/food/drinks,
				  "Energy guns" = /obj/item/weapon/gun/energy,
				  "Bullet guns" = /obj/item/weapon/gun/projectile,
				  "Melee weapons" = /obj/item/weapon/melee,
				  "Armor" = /obj/item/clothing/suit/armor)

/obj/effect/proc_holder/spell/targeted/pickdesire/cast()
	cast_with_favor()
	var/new_desire = input(usr, "Select a desire for you", "Select a desire", null) in desire

	var/type_selected = desire[new_desire]
	religious_sect.desired_items += new type_selected()
	religious_sect.desired_items_typecache = typecacheof(religious_sect.desired_items)

	desire -= new_desire

	to_chat(usr, "<span class ='warning'>You chose for your desire the [new_desire].</span>")

/obj/effect/proc_holder/spell/targeted/pickpreset
	name = "Choose spell preset"
	favor_cost = 10 //TODO
	charge_max = 120 //TODO
	clothes_req = 0
	invocation = "none"
	range = -1
	include_user = 1
	sound = 'sound/magic/Smoke.ogg' //TODO
	var/presets = list("Good", "Evil")

/obj/effect/proc_holder/spell/targeted/pickpreset/cast()
	cast_with_favor()
	for(var/obj/effect/proc_holder/spell/spell_to_remove in usr.spell_list)
		qdel(spell_to_remove)
		usr.spell_list -= spell_to_remove
		usr.mind.spell_list -= spell_to_remove

	var/chosed_presets = input(usr, "Select a preset for you", "Select a preset", null) in presets

	var/datum/religion_sect/custom/sect = religious_sect
	var/preset = sect.spell_preset[chosed_presets]
	sect.give_god_spells(preset)

	//DEBUG
	var/obj/effect/proc_holder/spell/S
	for(var/spell in preset)
		S = new spell()
		usr.AddSpell(S)

/obj/effect/proc_holder/spell/aoe_turf/conjure/spawn_bible
	name = "Create bible"
	desc = "Bible"

	school = "conjuration"
	charge_max = 120
	clothes_req = 0
	favor_cost = 10
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_amt = 0

	action_icon = 'icons/obj/storage.dmi'
	action_icon_state = "bible"

	summon_type = list(/obj/item/weapon/storage/bible)

/obj/effect/proc_holder/spell/targeted/heal
	name = "Heal"
	favor_cost = 10 //TODO
	charge_max = 120 //TODO
	clothes_req = 0
	invocation = "none"
	range = 6
	sound = 'sound/magic/heal.ogg' //TODO
	selection_type = "range"

	action_icon_state = "heal"

	var/hamt = -10

/obj/effect/proc_holder/spell/targeted/heal/cast(list/targets, mob/user = usr)
	if(!targets.len)
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return

	var/mob/living/carbon/target
	while(targets.len)
		target = targets[targets.len]
		targets -= target
		if(istype(target))
			break

	if(!ishuman(target))
		to_chat(user, "<span class='notice'>It'd be stupid to give [target] such a life improvement!</span>")
		return

	var/mob/living/carbon/human/H = target
	if(!(H in oview(range))) // If they are not in overview after selection.
		to_chat(user, "<span class='warning'>They are too far away!</span>")
		return

	H.apply_damages(hamt, hamt, hamt)
	cast_with_favor()

/obj/effect/proc_holder/spell/targeted/heal/damage
	name = "Damage"
	sound = 'sound/magic/Repulse.ogg'

	action_icon_state = "gib"

	hamt = 5
