/mob/living/carbon/xenomorph/humanoid
	name = "alien"
	icon = 'icons/mob/xenomorph.dmi'
	icon_state = "alien_s"

	pass_flags = PASSTABLE
	w_class = SIZE_HUMAN
	var/obj/item/clothing/suit/wear_suit = null		//TODO: necessary? Are they even used? ~Carn
	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null
	var/caste = ""
	var/alt_icon = 'icons/mob/xenoleap.dmi' //used to switch between the two alien icon files.
	var/leap_on_click = 0
	heal_rate = 3
	var/pounce_cooldown = 0
	var/pounce_cooldown_time = 10 SECONDS

	var/neurotoxin_on_click = 0
	var/neurotoxin_delay = 60
	var/neurotoxin_next_shot = 0
	var/last_neurotoxin = 0

	var/last_screech = 0
	var/screech_delay = 900
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/xenomeat = 5)
	alien_spells = list(/obj/effect/proc_holder/spell/no_target/weeds,
						/obj/effect/proc_holder/spell/targeted/xeno_whisp,
						/obj/effect/proc_holder/spell/no_target/xenowinds,
						/obj/effect/proc_holder/spell/targeted/transfer_plasma)

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/xenomorph/humanoid/atom_init()
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_CLAW, 1, -2)
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien")
		name = text("alien ([rand(1, 1000)])")
	real_name = name
	. = ..()

/mob/living/carbon/xenomorph/humanoid/can_pickup(obj/O)
	return FALSE

/mob/living/carbon/xenomorph/humanoid/set_m_intent(intent)
	. = ..()
	if(.)
		update_icons()
