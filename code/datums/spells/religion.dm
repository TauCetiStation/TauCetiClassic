//God pick new desire for custom sect
/obj/effect/proc_holder/spell/targeted/pickdesire
	name = "Choose an item to desire"
	favor_cost = 10
	charge_max = 120
	clothes_req = 0
	invocation = "none"
	range = -1
	include_user = 1
	sound = 'sound/magic/Smoke.ogg'
	action_icon_state = "smoke"
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

/obj/effect/proc_holder/spell/targeted/pickdesire/cast_with_favor()
	..()
	var/new_desire = input(usr, "Select a desire for you", "Select a desire", null) in desire

	var/type_selected = desire[new_desire]
	religious_sect.desired_items += new type_selected()
	religious_sect.desired_items_typecache = typecacheof(religious_sect.desired_items)

	desire -= new_desire

	to_chat(usr, "<span class ='warning'>You chose for your desire the [new_desire].</span>")

/*
	remove spell, mb create prock
	for(var/obj/effect/proc_holder/spell/spell_to_remove in usr.spell_list)
		qdel(spell_to_remove)
		usr.spell_list -= spell_to_remove
		usr.mind.spell_list -= spell_to_remove
*/

/obj/effect/proc_holder/spell/targeted/pickpreset
	name = "Choose spell preset"
	favor_cost = 10
	charge_max = 120
	clothes_req = 0
	invocation = "none"
	range = -1
	include_user = 1
	sound = 'sound/magic/Smoke.ogg'
	action_icon_state = "smoke"
	var/presets = list("Heal", "Spawn", "Zlo", "Aoe effect", "Dobro", "Neutral")

/obj/effect/proc_holder/spell/targeted/pickpreset/cast_with_favor()
	..()
	var/chosed_presets = input(usr, "Select a preset for you", "Select a preset", null) in presets

	var/datum/religion_sect/custom/sect = religious_sect
	var/preset = sect.spell_preset[chosed_presets]
	sect.give_god_spells(preset)

	//DEBUG
	var/obj/effect/proc_holder/spell/S
	for(var/spell in preset)
		S = new spell()
		usr.AddSpell(S)
	
	for(var/obj/effect/proc_holder/spell/spell_to_remove in usr.spell_list)
		qdel(spell_to_remove)
		usr.spell_list -= spell_to_remove
		usr.mind.spell_list -= spell_to_remove
