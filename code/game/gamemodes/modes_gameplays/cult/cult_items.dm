/obj/item/weapon/melee/cultblade
	name = "Cult Blade"
	desc = "An arcane weapon wielded by the followers of Nar-Sie."
	icon_state = "cultblade"
	item_state = "cultblade"
	hitsound = list('sound/weapons/bladeslice.ogg')
	w_class = SIZE_NORMAL
	force = 30
	throwforce = 10
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/melee/cultblade/proc/only_cultists(datum/source, mob/M)
	return iscultist(M)
/obj/item/weapon/melee/cultblade/examine(mob/user)
	. = ..()
	if(iscultist(user))
		var/datum/religion/cult/C = user.my_religion
		if(C.get_tech(RTECH_MIRROR_SHIELD))
			to_chat(user, "С помощью меча можно призвать щит-зеркало на защиту!")

/obj/item/weapon/melee/cultblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(iscultist(user))
		return ..()
	user.Paralyse(5)
	to_chat(user, "<span class='warning'>An unexplicable force powerfully repels the sword from [target]!</span>")
	var/obj/item/organ/external/BP = user.bodyparts_by_name[user.hand ? BP_L_ARM : BP_R_ARM]
	BP.take_damage(rand(force / 2, force)) //random amount of damage between half of the blade's force and the full force of the blade.

/obj/item/weapon/melee/cultblade/pickup(mob/living/user)
	. = ..()
	if(iscultist(user))
		var/datum/religion/cult/C = user.my_religion
		if(!GetComponent(/datum/component/self_effect) && C.get_tech(RTECH_MIRROR_SHIELD))
			var/shield_type = /obj/item/weapon/shield/riot/mirror
			AddComponent(/datum/component/self_effect, shield_type, "#51106bff", CALLBACK(src, PROC_REF(only_cultists)), 2 MINUTE, 30 SECONDS, 2 MINUTE)
	else
		to_chat(user, "<span class='warning'>Ошеломляющее чувство страха охватывает тебя при поднятии красного меча, было бы разумно поскорее избавиться от него.</span>")
		user.make_dizzy(120)

/obj/item/weapon/shield/riot/mirror
	name = "mirror shield"
	desc = "An infamous shield used by eldritch sects to confuse and disorient their enemies."
	icon = 'icons/obj/cult.dmi'
	icon_state = "mirror_shield"
	flags = DROPDEL
	slot_flags = FALSE
	var/reflect_chance = 70

/obj/item/weapon/shield/riot/mirror/pickup(mob/living/user)
	. = ..()
	if(!iscultist(user))
		user.make_dizzy(70)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			to_chat(user, "<span class='warning'>Тебя вдруг охватил страх, и ты схватил зеркало за острую кромку, порезавшись!</span>")
			var/obj/item/organ/external/BP = H.bodyparts_by_name[H.hand ? BP_L_ARM : BP_R_ARM]
			BP.take_damage(5)
		return FALSE

/obj/item/weapon/shield/riot/mirror/IsReflect(def_zone, hol_dir, hit_dir)
	if(prob(reflect_chance) && is_the_opposite_dir(hol_dir, hit_dir))
		return TRUE
	return FALSE

/obj/item/weapon/shield/riot/mirror/toggle_wallshield(mob/living/user)
	to_chat(user, "<span class='warning'>You are fucking INVINCIBLE!</span>")

/obj/item/clothing/glasses/cult_blindfold
	name = "blindfold"
	desc = "Covers the eyes, preventing sight. Altough, something wrong with this one..."
	icon_state = "blindfold"
	item_state = "blindfold"
	item_state_world = "blindfold"
	vision_flags = SEE_TURFS
	darkness_view = 7
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protection = FLASHES_FULL_PROTECTION
	flash_protection_slots = list(SLOT_GLASSES)

/obj/item/clothing/glasses/cult_blindfold/mob_can_equip(M, slot)
	if(!isliving(M))
		return FALSE
	var/mob/living/L = M
	if(!iscultist(L) && slot == SLOT_GLASSES)
		to_chat(L, "<span class='cult'>Глаза не нужны?!</span>")
		L.make_dizzy(30)
		L.apply_effects(eyeblur=45)
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			var/obj/item/organ/internal/eyes/E = H.organs_by_name[O_EYES]
			E.damage += rand(4, 8)
		L.flash_eyes()
		L.drop_item()
		return FALSE
	return ..()

/obj/item/clothing/head/culthood
	name = "cult hood"
	icon_state = "cult_hoodalt"
	item_state = "cult_hoodalt"
	desc = "A hood worn by the followers of Nar-Sie."
	flags_inv = HIDEFACE
	flags = HEADCOVERSEYES
	body_parts_covered = HEAD|EYES
	render_flags = parent_type::render_flags | HIDE_ALL_HAIR
	armor = list(melee = 30, bullet = 20, laser = 30,energy = 25, bomb = 0, bio = 0, rad = 0)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0

/obj/item/clothing/suit/hooded/cultrobes
	name = "cult robes"
	desc = "A set of armored robes worn by the followers of Nar-Sie."
	icon_state = "cultrobesalt"
	item_state = "cultrobesalt"
	hoodtype = /obj/item/clothing/head/culthood
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/weapon/storage/bible/tome,/obj/item/weapon/melee/cultblade)
	armor = list(melee = 40, bullet = 25, laser = 45,energy = 40, bomb = 25, bio = 10, rad = 0)
	flags_inv = HIDEJUMPSUIT
	siemens_coefficient = 0

/obj/item/clothing/head/magus
	name = "magus helm"
	icon_state = "magus"
	item_state = "magus"
	desc = "A helm worn by the followers of Nar-Sie."
	flags_inv = HIDEFACE
	flags = HEADCOVERSEYES|HEADCOVERSMOUTH
	render_flags = parent_type::render_flags | HIDE_ALL_HAIR
	armor = list(melee = 30, bullet = 15, laser = 15,energy = 20, bomb = 0, bio = 0, rad = 0)
	body_parts_covered = HEAD|FACE|EYES
	siemens_coefficient = 0

/obj/item/clothing/suit/magusred
	name = "magus robes"
	desc = "A set of armored robes worn by the followers of Nar-Sie."
	icon_state = "magusred"
	item_state = "magusred"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/weapon/storage/bible/tome,/obj/item/weapon/melee/cultblade)
	armor = list(melee = 50, bullet = 15, laser = 25,energy = 20, bomb = 25, bio = 10, rad = 0)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	siemens_coefficient = 0

/obj/item/clothing/head/helmet/space/cult
	name = "cult helmet"
	desc = "A space worthy helmet used by the followers of Nar-Sie."
	icon_state = "cult_helmet"
	item_state = "cult_helmet"
	armor = list(melee = 50, bullet = 45, laser = 60,energy = 45, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0

/obj/item/clothing/suit/space/cult
	name = "cult armour"
	icon_state = "cult_armour"
	item_state = "cult_armour"
	desc = "A bulky suit of armour, bristling with spikes. It looks space proof."
	w_class = SIZE_SMALL
	allowed = list(/obj/item/weapon/storage/bible/tome,/obj/item/weapon/melee/cultblade,/obj/item/weapon/tank/emergency_oxygen,/obj/item/device/suit_cooling_unit)
	slowdown = 0.5
	armor = list(melee = 50, bullet = 45, laser = 60,energy = 45, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/weapon/storage/backpack/cultpack
	name = "trophy rack"
	desc = "It's useful for both carrying extra gear and proudly declaring your insanity."
	icon_state = "cultpack"

/obj/item/weapon/storage/backpack/cultpack/armor

/obj/item/weapon/storage/backpack/cultpack/armor/atom_init()
	. = ..()
	new /obj/item/clothing/suit/hooded/cultrobes(src)
	new /obj/item/clothing/shoes/boots/cult(src)

/obj/item/weapon/storage/backpack/cultpack/space_armor

/obj/item/weapon/storage/backpack/cultpack/space_armor/atom_init()
	. = ..()
	new /obj/item/clothing/suit/space/cult(src)
	new /obj/item/clothing/head/helmet/space/cult(src)

#define HEAVEN 0
#define CAPTURE 1
/obj/item/device/cult_camera
	name = "stone"
	desc = "The stone is made of a complex material, if you look closely, the surface structure is fractal."
	icon = 'icons/obj/cult.dmi'
	icon_state = "cultstone"
	w_class = SIZE_TINY
	var/toggle = FALSE
	var/mode = HEAVEN
	var/mob/living/carbon/human/current_user
	var/obj/structure/cult/statue/camera/camera

/obj/item/device/cult_camera/Destroy()
	off()
	return ..()

/obj/item/device/cult_camera/verb/change_mode()
	set name = "Change mode"
	set category = "Object"
	set src in usr

	var/mob/user = usr
	if(!user.my_religion || !user.mind.holy_role)
		to_chat(current_user, "<span class='warning'>Вы не знаете как это сделать.</span>")
		return
	if(mode)
		mode = HEAVEN
		to_chat(user, "<span class='notice'>Выбраны обычные статуи.</span>")
	else
		mode = CAPTURE
		to_chat(user, "<span class='notice'>Выбраны статуи захвата.</span>")

/obj/item/device/cult_camera/proc/feel_pain()
	to_chat(current_user, "<span class='userdanger'>После взрыва статую вы почувствовали её боль.</span>")
	current_user.adjustBrainLoss(10)
	current_user.take_overall_damage(10)
	off()

/obj/item/device/cult_camera/proc/off()
	if(toggle)
		UnregisterSignal(camera, list(COMSIG_PARENT_QDELETING))
		current_user.reset_view()
		current_user.force_remote_viewing = FALSE
		camera.icon_state = initial(camera.icon_state)
		toggle = !toggle
		camera = null
		current_user = null

/obj/item/device/cult_camera/attack_self(mob/living/carbon/human/user)
	. = ..()
	if(!iscultist(user))
		return

	if(toggle)
		off()
		return

	switch(mode)
		if(HEAVEN)
			if(!camera_statues_list.len)
				to_chat(user, "<span class='warning'>Подходящих статуй не обнаружено.</span>")
				return
			camera = pick(camera_statues_list)

		if(CAPTURE)
			if(!capture_statues_list.len)
				to_chat(user, "<span class='warning'>Подходящих статуй не обнаружено.</span>")
				return
			camera = pick(capture_statues_list)

	current_user = user
	if(camera.icon_state != "jew") // cant be glow
		camera.icon_state = "[camera.icon_state]_glow"
	current_user.force_remote_viewing = TRUE
	current_user.reset_view(camera)
	toggle = !toggle

	RegisterSignal(camera, list(COMSIG_PARENT_QDELETING), PROC_REF(feel_pain))

/obj/item/device/cult_camera/dropped(mob/living/carbon/human/user)
	. = ..()
	off()

/obj/item/device/cult_camera/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	off()

#undef HEAVEN
#undef CAPTURE

/obj/item/blood_gem
	name = "red gem"
	desc = "Small red gem with strange aura"
	icon = 'icons/obj/cult.dmi'
	icon_state = "gem"

/obj/item/blood_gem/examine(mob/user)
	. = ..()
	if(iscultist(user) || isobserver(user))
		to_chat(user, "<span class='notice'>Камень крови. Можно применить на любом живом, что мгновенно его подлечит. Может [istype(src, /obj/item/blood_gem/big) ? "быть объединён, что бы " : ""]излечивать увечья</span>")

/obj/item/blood_gem/attack_self(mob/user)
	. = ..()
	if(iscultist(user) && isliving(user))
		gem_heal(user)

/obj/item/blood_gem/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(iscultist(user) && istype(I, /obj/item/blood_gem) && !istype(I, /obj/item/blood_gem/big))
		qdel(I)
		user.drop_from_inventory(I, get_turf(I))
		user.put_in_any_hand_if_possible(new /obj/item/blood_gem/big (get_turf(I)))
		to_chat(user, "<span class='notice'>Два камня в ваших руках сплавляются между собой в один!</span>")
		qdel(src)
		qdel(I)

/obj/item/blood_gem/proc/gem_heal(mob/living/L)
	// shut down various types of badness
	L.adjustToxLoss(-30)
	L.adjustOxyLoss(-30)
	L.adjustCloneLoss(-30)
	L.adjustBrainLoss(-30)
	L.adjustHalLoss(-30)
	L.adjustDrugginess(-30)
	L.heal_overall_damage(20, 20)

/obj/item/blood_gem/big
	name = "blood-red gem"
	desc = "Blood colored gem with strange aura"
	icon_state = "big_gem"

/obj/item/blood_gem/big/gem_heal(mob/living/L)
	. = ..()
	// shut down ongoing problems
	L.radiation = 0
	L.nutrition = NUTRITION_LEVEL_NORMAL
	L.bodytemperature = T20C
	L.sdisabilities = 0
	L.disabilities = 0
	L.ExtinguishMob()
	L.fire_stacks = 0

	L.paralysis -= 30
	L.stunned -= 30
	L.weakened -= 30

	// fix blindness and deafness
	L.blinded = 0
	L.eye_blind = 0
	L.setBlurriness(0)
	L.ear_deaf = 0
	L.ear_damage = 0

	L.SetDrunkenness(0)

	if(ishuman(L))
		var/mob/living/carbon/human/H = src
		H.restore_blood()
		H.full_prosthetic = null
		var/obj/item/organ/internal/heart/Heart = H.organs_by_name[O_HEART]
		Heart?.heart_normalize()

	L.restore_all_bodyparts()
	L.restore_all_organs()
	L.cure_all_viruses()

	// restore us to conciousness
	if(L.stat != DEAD)
		L.stat = CONSCIOUS

	if(L.reagents)
		L.reagents.clear_reagents()

	// make the icons look correct
	REMOVE_TRAIT(L, TRAIT_HUSK, GENERIC_TRAIT)
	REMOVE_TRAIT(L, TRAIT_BURNT, GENERIC_TRAIT)

	L.regenerate_icons()

	L.med_hud_set_health()
	L.med_hud_set_status()


///Used on torture table to turn it in autodoc. Can be summoned through cult rite
/obj/item/surgery_gem
	name = "stone ring"
	desc = "Stone ring with shiny shard in the center"
	icon = 'icons/obj/cult.dmi'
	icon_state = "gem"



///ENVY/// This little uncatchable *****
/obj/item/clothing/neck/envy
	name = "eye necklace"
	desc = "Necklace consisting of blood-red stone mixed with black flecks. It...Blinked!"
	icon = 'icons/obj/cult.dmi'
	icon_state = "envy"
	can_be_pulled = FALSE //Risk it
	unacidable = TRUE
	resistance_flags = FULL_INDESTRUCTIBLE
	item_action_types = list(/datum/action/item_action/summon_illusions)
	body_parts_covered = HEAD
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 10, bomb = 0, bio = 0, rad = 0)
	var/stoneshards = 0
	var/soulshards = 0
	COOLDOWN_DECLARE(illusions)

/obj/item/clothing/neck/envy/atom_init()
	. = ..()
	poi_list += src

/datum/action/item_action/summon_illusions
	name = "Summon illusions"

/obj/item/clothing/neck/envy/examine(mob/user)
	. = ..()
	if(iscultist(user) || isobserver(user))
		to_chat(user, "<span class='cult'>Бледная тень Ожерелья греха Зависти, однако даже этой крупицы мощи хватит для всей системы. И только безумцы могут носить это ожерелье без риска заточения души в артефакт (или же появления каких-то голосов в голове)!</span>")
		to_chat(user, "<span class='cult'>Вы можете активировать ожерелье сами или же оно активируется само при нападении на вас. С каждым добавленным кровавого камня добавляет сломленную (убегающую) тень при активации, а каждый заполненный камень душ - злую (нападающую) тень, однако они делят одну жизнь.</span>")
		to_chat(user, "<span class='cult'>В данный момент имеет <span class='red'>[stoneshards]</span> [pluralize_russian(stoneshards, "камень", "камня", "камней")] крови, а также <span class='red'>[soulshards]</span> [pluralize_russian(soulshards, "дух", "духа", "духов")], заточенных внутри.</span>")
	else if(ishuman(user))
		to_chat(user, "<span class='cult'>Руки сами тянутся к этому великолепию!</span>")
		if(Adjacent(user)) //Dont forget about the chance to equip it immideatly
			user.put_in_hands(src)

/obj/item/clothing/neck/envy/equipped(mob/user, slot)
	. = ..()
	if(!iscultist(user) && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(prob(4))
			if(H.neck)
				if(prob(50))
					to_chat(user, "<span class='userdanger'>В какой-то момент вам захотелось освободить свою шею от лишнего, но в последний момент вы всем естеством поняли - этого делать не стоит</span>")
					return
				if(!H.unEquip(H.gloves))
					for(var/obj/item/I in H.get_equipped_items() - list(H.l_hand, H.r_hand))
						if(I.flags_inv == HIDEGLOVES && prob(50)) //Imagine taking off a rig in space
							H.unEquip(I, TRUE) //Its just a fate to loose bet with 1 percent
			if(user.equip_to_slot_if_possible(src, SLOT_NECK))
				to_chat(user, "<span class='cult'>Вы и сами не замечаете, как одеваете ожерелье на свою шею!</span>")
	if(slot == SLOT_NECK)
		if(!iscultist(user))
			soulshards++
			death_illusuion(user)
			to_chat(user, "<span class='cult big'>Ваша душа была пожрана в то же мгновенье, как ожерелье коснулось вашей шеи!</span>")
			return
		RegisterSignal(user, list(COMSIG_LIVING_CHECK_SHIELDS), PROC_REF(illusion))
	else UnregisterSignal(user, list(COMSIG_LIVING_CHECK_SHIELDS))

/obj/item/clothing/neck/envy/proc/death_illusuion(mob/living/user)
	var/mob/living/simple_animal/hostile/illusion/escape/E = new (user.loc)
	E.Copy_Parent(user, 5 MINUTES, 10 * stoneshards * soulshards)
	E.GiveTarget(user)
	E.melee_damage = 15
	user.dust()

/obj/item/clothing/neck/envy/suicide_act(mob/user)
	if(!ishuman(user))
		soulshards++
		death_illusuion(user)
		return (FIRELOSS) //Boring one
	var/mob/living/carbon/human/H = user
	if(H.neck)
		H.drop_from_inventory(H.neck)
	if(!user.equip_to_slot_if_possible(src, SLOT_NECK))
		to_chat(user, "<span class='cult'>Ожерелье отказалось от столь грязного подарка!</span>") //Just burn damage
	return (FIRELOSS) //Just to prevent a message

/obj/item/clothing/neck/envy/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, list(COMSIG_LIVING_CHECK_SHIELDS))

/obj/item/clothing/neck/envy/proc/illusion()
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, illusions))
		return
	if(!isliving(loc))
		return
	var/mob/living/owner = loc
	if(!iscultist(owner) && prob(10)) //Yep, non-cultie can use it, but dont forget bout hostile illusions
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(H.neck)
				if(prob(50))
					to_chat(owner, "<span class='userdanger'>В какой-то момент вам захотелось освободить свою шею от лишнего, но в последний момент вы всем естеством поняли - этого делать не стоит</span>")
				else
					for(var/obj/item/I in H.get_equipped_items() - list(H.l_hand, H.r_hand))
						if(I.flags_inv == HIDEGLOVES && prob(50))
							H.unEquip(I, TRUE) //Its just a fate to loose bet with 1 percent
			if(owner.equip_to_slot_if_possible(src, SLOT_NECK))
				to_chat(owner, "<span class='cult'>Вы и сами не замечаете, как одеваете ожерелье на свою шею!</span>")
		else //Did monke thought it is safe?
			owner.dust()
			to_chat(owner, "<span class='cult big'>Грех Зависти смотрит на вас в ответ!</span>")
	var/mob/living/simple_animal/hostile/illusion/E
	var/addbystones = stoneshards * 10
	for(var/i in 1 to max(1, stoneshards))
		E = new /mob/living/simple_animal/hostile/illusion/escape(owner.loc)
		E.Copy_Parent(owner, rand(20 + addbystones, 70 + addbystones), 10 + addbystones)
		E.GiveTarget(owner)
		E.Goto(owner, 0, E.minimum_distance)
	for(var/i in 1 to soulshards)
		E = new(get_turf(owner))
		E.Copy_Parent(owner, rand(20 + soulshards, 70 + soulshards), (100 + x * 5) / soulshards, 5 + soulshards)
		E.faction = "cult"
		E.handle_combat_ai()
	COOLDOWN_START(src, illusions, 7 SECONDS)
	return COMPONENT_ATTACK_SHIELDED

/obj/item/clothing/neck/envy/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!iscultist(user))
		return

	if(istype(I, /obj/item/blood_gem))
		stoneshards++ //Yes, big gems means just one
		qdel(I)
		to_chat(user, "<span class='cult'>Камень расплавился и впитался в поверхность артефакта, как только коснулся его!</span>")

		add_filter("gem_outline", 2, outline_filter(1, COLOR_CRIMSON_RED))
		animate(filters[filters.len], color = COLOR_RED_GRAY, time = 2 SECONDS)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, remove_filter), "gem_outline"), 2 SECONDS)

	if(istype(I, /obj/item/device/soulstone) && locate(/mob/living/simple_animal/shade) in I)
		soulshards++
		qdel(I)
		to_chat(user, "<span class='cult'>Осколок камня душ рассыпался, а вместе с тем ещё одна душа нашла свой пьедестал</span>")

		add_filter("gem_outline", 2, outline_filter(1, COLOR_CRIMSON_RED))
		animate(filters[filters.len], color = COLOR_RED_GRAY, time = 2 SECONDS)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, remove_filter), "gem_outline"), 2 SECONDS)

/obj/item/clothing/neck/envy/attack_self(mob/user)
	. = ..()
	illusion()

/obj/item/clothing/neck/envy/Destroy() //Unique item
	SHOULD_CALL_PARENT(FALSE)
	var/turf/targetturf = pick_landmarked_location("blobstart", least_used = FALSE)
	forceMove(targetturf)
	update_world_icon()
	return QDEL_HINT_LETMELIVE






///RAGE Super monk
/obj/item/clothing/gloves/rage //Boxing gloves on max level
	name = "living gloves"
	desc = "Gloves made of some sort of leather with red veins along the wrist"
	icon_state = "rage"
	can_be_pulled = FALSE //Risk it
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = ARMS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = null //Every specie can equip it
	unacidable = TRUE
	resistance_flags = FULL_INDESTRUCTIBLE
	equip_time = 2 SECONDS
	armor = list(melee = 40, bullet = 40, laser = 40, energy = 10, bomb = 100, bio = 100, rad = 100)
	var/stoneshards = 0

/obj/item/clothing/gloves/rage/atom_init()
	. = ..()
	poi_list += src

/obj/item/clothing/gloves/rage/Destroy() //Unique item
	SHOULD_CALL_PARENT(FALSE)
	var/turf/targetturf = pick_landmarked_location("blobstart", least_used = FALSE)
	forceMove(targetturf)
	update_world_icon()
	return QDEL_HINT_LETMELIVE

/obj/item/clothing/gloves/rage/examine(mob/user)
	. = ..()
	if(iscultist(user) || isobserver(user))
		to_chat(user, "<span class='cult'>Тень Наручей греха Гнева. Позволяет истинному воину сражаться на новой ступене мастерства, но даже темные духи замечают, что криворукий воин даже с этими наручами криворуким и останется...</span>")
		to_chat(user, "<span class='cult'>Позволяет носящему не обращать внимание на дальнобойное оружие, но артефакт также не позволяет и носящему его использовать. С каждым добавлением камня крови увеличивает пробитие брони и выполнения приёмов!</span>")
		to_chat(user, "<span class='cult'>В данный момент имеет <span class='red'>[stoneshards]</span> [pluralize_russian(stoneshards, "камень", "камня", "камней")] крови.</span>")
	else if(ishuman(user))
		to_chat(user, "<span class='cult'>Запястья невольно вздрагивают</span>")
		user.make_dizzy(stoneshards)

/obj/item/clothing/gloves/rage/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	ADD_TRAIT(user, TRAIT_NOGUNS, src) //We dont want people to take off gloves and just shoot
	var/mob/living/carbon/human/H = user
	if(!iscultist(H) && prob(4))
		if(H.gloves)
			if(prob(50)) //If this happens - you r dead
				to_chat(user, "<span class='userdanger'>В какой-то момент вас начали раздражать перчатки, вам захотелось их снять, но вдруг поняли - этого делать не стоит</span>")
				return
			if(!H.unEquip(H.gloves))
				for(var/obj/item/I in H.get_equipped_items() - list(H.l_hand, H.r_hand))
					if(I.flags_inv == HIDEGLOVES && prob(50)) //Imagine taking off a rig in space
						H.unEquip(I, TRUE) //Its just a fate to loose bet with 1 percent
		if(user.equip_to_slot_if_possible(src, SLOT_GLOVES))
			to_chat(user, "<span class='cult'>Вы и сами не замечаете, как одеваете перчатки!</span>")
	if(slot == SLOT_GLOVES)
		if(!iscultist(user))
			var/obj/item/organ/external/head/head = H.bodyparts_by_name[BP_HEAD]
			head.brainmob.gib()
			for(var/obj/item/organ/external/BP in H.bodyparts)
				BP.droplimb()
			to_chat(user, "<span class='cult big'>Ваше тело было разделено на дольки, словно вкусное спелое яблоко, как только перчатки были одеты!</span>")
		add_powers(user)
	else remove_powers(user)

/obj/item/clothing/gloves/rage/dropped(mob/user)
	. = ..()
	if(isliving(user))
		remove_powers(user)
	REMOVE_TRAIT(user, TRAIT_NOGUNS, src)

/obj/item/clothing/gloves/rage/proc/add_powers(mob/living/user)
	RegisterSignal(user, list(COMSIG_ATOM_BULLET_ACT), PROC_REF(projectile_act))
	user.verbs += /mob/living/proc/read_possible_combos
	for(var/datum/combo_handler/CS in user.combos_saved)
		CS.show_combo_hud()

/obj/item/clothing/gloves/rage/proc/remove_powers(mob/living/user)
	UnregisterSignal(user, list(COMSIG_ATOM_BULLET_ACT))
	user.verbs -= /mob/living/proc/read_possible_combos
	for(var/datum/combo_handler/CS in user.combos_saved)
		CS.hide_combo_hud()

/obj/item/clothing/gloves/rage/proc/projectile_act(obj/item/projectile/hitting_projectile)
	SIGNAL_HANDLER

	if(!isliving(loc))
		return FALSE
	var/mob/living/L = loc
	if(L.incapacitated()) //NO STUN
		return FALSE
	if(HULK in L.mutations) //NO HULK
		return FALSE
//	if(!isturf(L.loc)) //NO MOTHERFLIPPIN MECHS!
	//	return FALSE

	L.visible_message(
		"<span class='danger'>[L] effortlessly swats [hitting_projectile] aside!</span>",
		"<span class='notice'>You deflect [hitting_projectile]!</span>",
	)
	playsound(L, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), VOL_EFFECTS_MASTER, 60)
	return PROJECTILE_FORCE_MISS

/obj/item/clothing/gloves/rage/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/blood_gem) && iscultist(user))
		stoneshards++ //Yes, big gems means just one
		qdel(I)
		to_chat(user, "<span class='cult'>Камень расплавился и впитался в поверхность артефакта, как только коснулся его!</span>")

		add_filter("gem_outline", 2, outline_filter(1, COLOR_CRIMSON_RED))
		animate(filters[filters.len], color = COLOR_RED_GRAY, time = 2 SECONDS)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, remove_filter), "gem_outline"), 2 SECONDS)

/obj/item/clothing/gloves/rage/Touch(mob/living/carbon/human/attacker, atom/A, proximity)
	. = ..()
	if(!. && ishuman(A)) //Stolen from boxing gloves with a few changes
		var/mob/living/carbon/human/H = A
		var/attack_obj = attacker.get_unarmed_attack()
		var/damage = attack_obj["damage"] * (1.5 + 0.1 * stoneshards)
		if(!damage)
			playsound(src, 'sound/effects/mob/hits/miss_1.ogg', VOL_EFFECTS_MASTER)
			visible_message("<span class='warning'><B>[attacker] has attempted to punch [H]!</B></span>")
			return TRUE

		if(attacker.engage_combat(H, attacker.a_intent, damage)) // We did a combo-wombo of some sort.
			return TRUE

		playsound(H, pick(SOUNDIN_PUNCH_MEDIUM), VOL_EFFECTS_MASTER)

		H.visible_message("<span class='warning'><B>[attacker] has punched [H]!</B></span>")

		var/obj/item/organ/external/BP = H.get_bodypart(ran_zone(attacker.get_targetzone()))
		var/armor_block = H.run_armor_check(BP, MELEE)

		H.apply_damage(damage, BRUTE, BP, armor_block / max(1, sqrt(stoneshards / 7) * 2), src) //With 7 shards it ignores 50% of armor, 15 shards - ignore 66%, 40 - 80%.
		return TRUE






//GLUTTONY. Walking medkit or lazy CMO
/obj/item/weapon/storage/belt/gluttony
	name = "leather belt"
	desc = "A wacky belt with teeth and strips of flesh across it"
	icon_state = "gluttony"
	can_be_pulled = FALSE
	unacidable = TRUE
	resistance_flags = FULL_INDESTRUCTIBLE
	body_parts_covered = LOWER_TORSO
	armor = list(melee = 20, bullet = 20, laser = 20, energy = 20, bomb = 0, bio = 100, rad = 0) //Groin defence!

	var/list/corpses = list()
	var/datum/component/aura_healing/deadly_aura
	var/datum/component/aura_healing/healing_aura

	item_action_types = list(/datum/action/item_action/hands_free/gluttony)
	item_actions_special = TRUE

/datum/action/item_action/hands_free/gluttony
	name = "Gluttony"

/datum/action/item_action/hands_free/gluttony/Activate()
	RegisterSignal(owner, list(COMSIG_MOB_CLICK), TYPE_PROC_REF(/obj/item/weapon/storage/belt/gluttony, gluttony))
	var/obj/item/I = target
	I.update_item_actions()
	to_chat(owner, "<span class='cult'>Вылечи безумца или сожри еду, прикоснувшись к ней!</span>")

/datum/action/item_action/hands_free/gluttony/Deactivate()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_MOB_CLICK))
	to_chat(owner, "<span class='cult'>Сила покинула твою руку</span>")

/datum/action/item_action/hands_free/gluttony/IsAvailable()
	. = ..()
	var/obj/item/weapon/storage/belt/gluttony/I = target
	if(!length(I.corpses) || !iscultist(owner))
		return FALSE

/obj/item/weapon/storage/belt/gluttony/atom_init()
	. = ..()
	poi_list += src
	healing_aura = AddComponent(/datum/component/aura_healing, 5, TRUE, 1.4, 1.4, 0.3, 3, 3, 0.3, 1, null, 3.2, "#960000")
	deadly_aura = AddComponent(/datum/component/aura_healing/deadly, 5, TRUE, -0.8, -0.8, -0.3, -1, -1, -0.3, -0.8, null, -1.2, COLOR_BLACK)
	STOP_PROCESSING(SSaura_healing, healing_aura)
	STOP_PROCESSING(SSaura_healing, deadly_aura)

/obj/item/weapon/storage/belt/gluttony/proc/gluttony(atom/A, params)
	SIGNAL_HANDLER
	if(!isliving(A) || !isliving(loc))
		UnregisterSignal(loc, list(COMSIG_MOB_CLICK))
		to_chat(loc, "<span class='cult'>Это не еда! Нужно утолить голод!</span>")
		return
	var/mob/living/L = A
	if(iscultist(A))
		if(!length(corpses))
			to_chat(loc, "<span class='cult'>Нечего предложить греху Отчаяния! Нужно больше трупов!</span>") //Deep lore on its way
			return
		to_chat(loc, "<span class='cult'>Невкусный психопат. Пускай лучше охотится на дичь.</span>")
		L.adjustToxLoss(-30)
		L.adjustOxyLoss(-30)
		L.adjustCloneLoss(-30)
		L.adjustBrainLoss(-30)
		L.adjustHalLoss(-30)
		L.adjustDrugginess(-30)
		L.heal_overall_damage(20, 20)
		L.radiation = 0
		L.nutrition = NUTRITION_LEVEL_NORMAL
		L.bodytemperature = T20C
		L.sdisabilities = 0
		L.disabilities = 0
		L.ExtinguishMob()
		L.fire_stacks = 0
		L.paralysis -= 30
		L.stunned -= 30
		L.weakened -= 30
		L.blinded = 0
		L.eye_blind = 0
		L.setBlurriness(0)
		L.ear_deaf = 0
		L.ear_damage = 0
		L.SetDrunkenness(0)
		if(ishuman(L))
			var/mob/living/carbon/human/H = src
			H.restore_blood()
			H.full_prosthetic = null
			var/obj/item/organ/internal/heart/Heart = H.organs_by_name[O_HEART]
			Heart?.heart_normalize()
		L.restore_all_bodyparts()
		L.restore_all_organs()
		L.cure_all_viruses()
		L.stat = CONSCIOUS
		if(L.reagents)
			L.reagents.clear_reagents()
		REMOVE_TRAIT(L, TRAIT_HUSK, GENERIC_TRAIT)
		REMOVE_TRAIT(L, TRAIT_BURNT, GENERIC_TRAIT)
		L.regenerate_icons()
		L.med_hud_set_health()
		L.med_hud_set_status()
		if(L.stat == DEAD)
			dead_mob_list -= src
			alive_mob_list += src
			L.tod = null
			L.timeofdeath = 0

		var/mob/living/sacr = pick(length(corpses))
		sacr.gib()
	else
		INVOKE_ASYNC(src, PROC_REF(consume_process), L)
	return COMPONENT_CANCEL_CLICK

/obj/item/weapon/storage/belt/gluttony/proc/consume_process(mob/living/L)
	if(!L.mind)
		to_chat(loc, "<span class='cult'>Пустышка! Такое не подойдёт!'</span>")
		return COMPONENT_CANCEL_CLICK
	if(do_after(loc, L.stat == DEAD ? 5 SECONDS : 10 SECONDS, TRUE, L, FALSE))
		if(isliving(loc)) //Just in case
			consume(L)

/obj/item/weapon/storage/belt/gluttony/proc/consume(mob/living/L)
	if(L.stat != DEAD)
		L.death()
	L.forceMove(src)
	corpses += src
	for(var/obj/item/I in L.contents)
		if(I in global.poi_list)
			L.drop_from_contents(I)
	update_item_actions()
	if(isliving(loc))
		var/mob/living/user = loc
		user.nutrition = NUTRITION_LEVEL_WELL_FED

	add_filter("gem_outline", 2, outline_filter(1, COLOR_CRIMSON_RED))
	animate(filters[filters.len], color = COLOR_RED_GRAY, time = 2 SECONDS)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, remove_filter), "gem_outline"), 2 SECONDS)

/obj/item/weapon/storage/belt/gluttony/Destroy() //Unique item
	SHOULD_CALL_PARENT(FALSE)

	for(var/atom/movable/A as anything in corpses) //Dump corpses out
		A.forceMove(loc)
		if(prob(90))
			step(A, pick(global.alldirs))

	var/turf/targetturf = pick_landmarked_location("blobstart", least_used = FALSE)
	forceMove(targetturf)
	update_world_icon()
	return QDEL_HINT_LETMELIVE

/obj/item/weapon/storage/belt/gluttony/examine(mob/user)
	. = ..()
	if(iscultist(user) || isobserver(user))
		to_chat(user, "<span class='cult'>Тень Пояса греха Чревоугодия. Позволяет позаботиться о всех, что бы никто не был одинок...Внутри вас. Не позволит съесть плохое.")
		to_chat(user, "<span class='cult'>Помогает ослаблять бегающую еду, в радиусе, но не трогает безумцев, непригодных даже к употреблению. Позволяет вырвать безумца из лап греха Уныния, обменяв на душу еды внутри вас.")
		to_chat(user, "<span class='cult'>Даёт ауру лечения для культистов вокруг вас и ауру гибели против не-культистов. С помощью способности поглощайте трупы, а затем воскрешайте союзников.")
		to_chat(user, "<span class='cult'>В данный момент имеет <span class='red'>[corpses]</span> [pluralize_russian(corpses, "узника", "узника", "узников")].")
	else if(ishuman(user))
		to_chat(user, "<span class='cult'>Живот нехорошо урчит и скручивает!</span>")
		user.make_dizzy(length(corpses))

/obj/item/weapon/storage/belt/gluttony/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(!iscultist(user) && prob(4))
		var/mob/living/carbon/human/H = user
		if(H.belt)
			if(istype(H.belt, /obj/item))
				var/obj/item/I = H.belt
				if(I.w_class > SIZE_TINY && prob(50)) //If this happens - you r dead
					to_chat(user, "<span class='userdanger'>В какой-то момент вы почувствовали боль в области живота и начали снимать пояс, но вдруг поняли - этого делать не стоит")
					return
			H.drop_from_inventory(H.belt, get_turf(src))
		if(user.equip_to_slot_if_possible(src, SLOT_BELT))
			to_chat(user, "<span class='cult'>Вы и сами не замечаете, как одеваете перчатки!")
	if(slot == SLOT_BELT)
		if(!iscultist(user))
			consume(user)
			to_chat(user, "<span class='cult big'>Вы обрели себе компанию среди других поглощенных грехом Чревоугодия!</span>")
			return
		add_powers(user)
	else remove_powers(user)

/obj/item/weapon/storage/belt/gluttony/dropped(mob/user)
	. = ..()
	if(isliving(user))
		remove_powers(user)

/obj/item/weapon/storage/belt/gluttony/proc/add_powers(mob/living/user)
	START_PROCESSING(SSaura_healing, healing_aura)
	START_PROCESSING(SSaura_healing, deadly_aura)
	add_item_actions(user)
	RegisterSignal(user, list(COMSIG_MOB_DIED), TYPE_PROC_REF(/obj/item/weapon/storage/belt/gluttony, remove_powers), user) //We die - no auras
	user.mob_metabolism_mod.ModAdditive(1.5, src) // +150%

/obj/item/weapon/storage/belt/gluttony/proc/remove_powers(mob/living/user)
	SIGNAL_HANDLER
	STOP_PROCESSING(SSaura_healing, healing_aura)
	STOP_PROCESSING(SSaura_healing, deadly_aura)
	remove_item_actions(user)
	UnregisterSignal(user, list(COMSIG_MOB_CLICK))
	user.mob_metabolism_mod.RemoveMods(src)








//GLUTTONY. Just a turtle
/obj/item/clothing/suit/space/pride
	name = "strange cuirass"
	desc = "A bulky robe that just emits a waves of arrogance, you cant comprehend of which material it is nor its texture."
	can_be_pulled = FALSE
	species_restricted = null
	unacidable = TRUE
	resistance_flags = FULL_INDESTRUCTIBLE
	icon_state = "pride"
	item_state = "pride"
	w_class = SIZE_NORMAL
	allowed = list(/obj/item/weapon/tank/emergency_oxygen, /obj/item/device/flashlight,/obj/item/weapon/gun/energy, /obj/item/weapon/gun/projectile, /obj/item/ammo_box/magazine, /obj/item/ammo_casing, /obj/item/weapon/melee/baton, /obj/item/weapon/handcuffs, /obj/item/weapon/tank/jetpack, /obj/item/weapon/storage/bible/tome,/obj/item/weapon/melee/cultblade,/obj/item/device/suit_cooling_unit)
	slowdown = 0.3
	render_flags = parent_type::render_flags | HIDE_TAIL
	throw_range = 2
	equip_time = 30
	siemens_coefficient = 0.5
	gas_transfer_coefficient = 1
	permeability_coefficient = 1
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	pierce_protection = UPPER_TORSO|LOWER_TORSO
	flags_inv = HIDEJUMPSUIT
	cold_protection = UPPER_TORSO | LOWER_TORSO
	min_cold_protection_temperature = null
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	var/stoneshards = 0
	///Status flags that we removed on item gain. Used in remove_powers(), so we dont get a golem that can be stunned
	var/removed_status_flags

/obj/item/clothing/suit/space/pride/atom_init()
	. = ..()
	poi_list += src

/obj/item/clothing/suit/space/pride/Destroy() //Unique item
	SHOULD_CALL_PARENT(FALSE)
	var/turf/targetturf = pick_landmarked_location("blobstart", least_used = FALSE)
	forceMove(targetturf)
	update_world_icon()
	return QDEL_HINT_LETMELIVE

/obj/item/clothing/suit/space/pride/examine(mob/user)
	. = ..()
	if(iscultist(user) || isobserver(user))
		to_chat(user, "<span class='cult'>Тень одеяния греха Гордыни. Носящий начинает все меньше обращать внимание на окружающее вокруг него, и всё больше наслаждаться собой.")
		to_chat(user, "<span class='cult'>Каждый камень крови уменьшает количество вещей, которые могут вас побеспокоить. Требует камни крови, иначе бесполезен.")
		to_chat(user, "<span class='cult'>В данный момент имеет <span class='red'>[stoneshards]</span> [pluralize_russian(stoneshards, "камень", "камня", "камней")].")
	else if(ishuman(user))
		to_chat(user, "<span class='cult'>Живот нехорошо урчит и скручивает!</span>")
		user.make_dizzy(stoneshards)

/obj/item/clothing/suit/space/pride/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/blood_gem))
		stoneshards++ //Yes, big gems means just one
		qdel(I)
		add_filter("gem_outline", 2, outline_filter(1, COLOR_CRIMSON_RED))
		animate(filters[filters.len], color = COLOR_RED_GRAY, time = 2 SECONDS)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, remove_filter), "gem_outline"), 2 SECONDS)

	switch(stoneshards)
		if(8) //Great armor, pretty powerful
			armor = list(melee = 60, bullet = 60, laser = 60, energy = 60, bomb = 100, bio = 100, rad = 100)
			to_chat(user, "<span class='cult'>Броня стала ещё лучше")
			slowdown = 0.8
		if(7) //Against high temp
			max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
			armor = list(melee = 50, bullet = 50, laser = 50, energy = 45, bomb = 80, bio = 100, rad = 100) //Good armor
			flags = PHORONGUARD
			to_chat(user, "<span class='cult'>Высокие температуры более не страшны, а броня стала лучше")
			slowdown = 0.7
		if(6) //Broken bones are no longer a threat
			flash_protection = FLASHES_FULL_PROTECTION
			supporting_limbs = list()
			check_limb_support()
			to_chat(user, "<span class='cult'>Сломанные кости не будут отвлекать, а свалить с ног уже не выйдет")
			slowdown = 0.6
		if(5)
			can_get_wet = FALSE
			pierce_protection = FULL_BODY
			armor = list(melee = 40, bullet = 40, laser = 40, energy = 25, bomb = 60, bio = 100, rad = 100) //sec rig
			siemens_coefficient = 0
			slowdown = 0.5
			to_chat(user, "<span class='cult'>Броня стала лучше держать большинство видов ударов и электричество")
		if(4)
			min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
			max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
			cold_protection = FULL_BODY
			heat_protection = FULL_BODY
			armor = list(melee = 20, bullet = 20, laser = 20, energy = 25, bomb = 40, bio = 100, rad = 100) //Not bad, not good, but full space protection
			slowdown = 0.4
			flags_pressure = STOPS_PRESSUREDMAGE
			to_chat(user, "<span class='cult'>Космос более не препятствие, а оглушения более нет. Электроника не уследит.")
		if(3)
			gas_transfer_coefficient = 0.01
			permeability_coefficient = 0.02
			siemens_coefficient = 0.1
			armor = list(melee = 10, bullet = 10, laser = 10, energy = 5, bomb = 40, bio = 100, rad = 30) //bio
			slowdown = 0.5
			to_chat(user, "<span class='cult'>Большинство газов, микроорганизмов и газов более не помешают.")
		if(2)
			flags_pressure = STOPS_LOWPRESSUREDMAGE
			body_parts_covered = FULL_BODY
			flags_inv = HIDEJUMPSUIT
			slowdown = 0.7
			to_chat(user, "<span class='cult'>Низкое давление более не страшно, паралич не страшен, а замедление уменьшено ещё сильнее.")
		if(1)
			canremove = FALSE
			armor = list(melee = 10, bullet = 10, laser = 10, energy = 5, bomb = 40, bio = 30, rad = 10) //Just a little protection
			slowdown = 1
			to_chat(user, "<span class='cult'>Грех начинает вступать в свои права. Замедление уменьшено.")

	remove_powers(user) //Reset status flags
	add_powers(user)

//звук при вставке камня, айсию при создании, при неудачной или удачной попытке прикола

/obj/item/clothing/suit/space/pride/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(!iscultist(user))
		var/mob/living/carbon/human/H = user
		if(prob(4))
			if(H.wear_suit)
				if(prob(50)) //If this happens - you r dead
					to_chat(user, "<span class='userdanger'>В какой-то момент вас начали раздражать ваши перчатки, вам захотелось их снять, но вы вдруг поняли - этого делать не стоит")
					return
				H.drop_from_inventory(H.wear_suit, get_turf(src))
			if(user.equip_to_slot_if_possible(src, SLOT_WEAR_SUIT))
				to_chat(user, "<span class='cult'>Вы и сами не замечаете, как одеваете перчатки!")
	if(slot == SLOT_WEAR_SUIT)
		if(!iscultist(user))
			user.ghostize(FALSE)
			to_chat(user, "<span class='cult big'>Вы обрели себе компанию среди других поглощенных грехом Чревоугодия!</span>")
		add_powers(user)
	else remove_powers(user)

/obj/item/clothing/suit/space/pride/dropped(mob/user)
	. = ..()
	if(isliving(user))
		remove_powers(user)

/obj/item/clothing/suit/space/pride/proc/add_powers(mob/living/user)
	ADD_TRAIT(user, TRAIT_NO_CRAWL, src)
	removed_status_flags = (CANSTUN|CANPARALYSE|CANWEAKEN|CANPUSH)
	removed_status_flags &= ~user.status_flags
	if(stoneshards > 6)
		user.remove_status_flags(CANSTUN|CANWEAKEN|CANPARALYSE|CANPUSH)
		ADD_TRAIT(user, TRAIT_NO_EMBED, src)
		ADD_TRAIT(user, TRAIT_NO_MINORCUTS, src)
		ADD_TRAIT(user, TRAIT_NO_PAIN, src)
	else if(stoneshards > 4)
		user.remove_status_flags(CANWEAKEN|CANPARALYSE|CANPUSH)
		ADD_TRAIT(user, TRAIT_NO_BREATHE, src)
		ADD_TRAIT(user, TRAIT_VIRUS_IMMUNE, src)
		ADD_TRAIT(user, TRAIT_MORPH_IMMUNE, src)
		RegisterSignal(user, COMSIG_ATOM_START_PULL, PROC_REF(can_be_pulled)) //Buff and debuff in one thingie
	else if(stoneshards > 2)
		user.remove_status_flags(CANPARALYSE|CANPUSH)
		ADD_TRAIT(user, TRAIT_STRONGMIND, src)
		ADD_TRAIT(user, TRAIT_LIGHT_STEP, src)
		ADD_TRAIT(user, TRAIT_HEMOCOAGULATION, src)
	else if(stoneshards > 0)
		user.remove_status_flags(CANPUSH)
		ADD_TRAIT(user, TRAIT_SOULSTONE_IMMUNE, src)
		ADD_TRAIT(user, TRAIT_NO_CLONE, src)
		ADD_TRAIT(user, TRAIT_EMOTIONLESS, src)
		ADD_TRAIT(user, TRAIT_NEVER_FAT, src)
	if(stoneshards > 5)
		RegisterSignal(user, COMSIG_LIVING_CAN_TRACK, PROC_REF(can_track))

/obj/item/clothing/suit/space/pride/proc/can_be_pulled()
	SIGNAL_HANDLER
	return COMPONENT_PREVENT_PULL

/obj/item/clothing/suit/space/pride/proc/can_track(datum/source)
	SIGNAL_HANDLER
	return COMPONENT_CANT_TRACK

/obj/item/clothing/suit/space/pride/proc/remove_powers(mob/living/user)
	REMOVE_TRAIT(user, TRAIT_NO_CRAWL, src)
	user.add_status_flags(removed_status_flags)
	UnregisterSignal(user, COMSIG_LIVING_CAN_TRACK)
	UnregisterSignal(user, COMSIG_ATOM_START_PULL)
	//REMOVE_TRAITS_IN(user, src)
	REMOVE_TRAIT(user, TRAIT_STRONGMIND, src)
	REMOVE_TRAIT(user, TRAIT_LIGHT_STEP, src)
	REMOVE_TRAIT(user, TRAIT_SOULSTONE_IMMUNE, src)
	REMOVE_TRAIT(user, TRAIT_HEMOCOAGULATION, src)
	REMOVE_TRAIT(user, TRAIT_NO_BREATHE, src)
	REMOVE_TRAIT(user, TRAIT_NO_CLONE, src)
	REMOVE_TRAIT(user, TRAIT_NO_PAIN, src)
	REMOVE_TRAIT(user, TRAIT_VIRUS_IMMUNE, src)
	REMOVE_TRAIT(user, TRAIT_MORPH_IMMUNE, src)
	REMOVE_TRAIT(user, TRAIT_EMOTIONLESS, src)
	REMOVE_TRAIT(user, TRAIT_NO_EMBED, src)
	REMOVE_TRAIT(user, TRAIT_NO_MINORCUTS, src)

/obj/item/clothing/suit/space/pride/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/blood_gem) && iscultist(user))
		stoneshards++ //Yes, big gems means just one
		qdel(I)
		to_chat(user, "<span class='cult'>Камень расплавился и впитался в поверхность артефакта, как только коснулся его!</span>")

		add_filter("gem_outline", 2, outline_filter(1, COLOR_CRIMSON_RED))
		animate(filters[filters.len], color = COLOR_RED_GRAY, time = 2 SECONDS)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, remove_filter), "gem_outline"), 2 SECONDS)






/obj/item/clothing/head/helmet/greed
	name = "skull"
	desc = "It`s a realitic mask-helmet and you really hope that this is made of something, not someone."
	icon_state = "greed"
	can_be_pulled = FALSE //Risk it
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = null //Every specie can equip it
	unacidable = TRUE
	resistance_flags = FULL_INDESTRUCTIBLE
	equip_time = 2 SECONDS
	armor = list(melee = 50, bullet = 50, laser = 20, energy = 0, bomb = 100, bio = 50, rad = 30)
	var/stoneshards = 0
	var/datum/action/innate/seek_prey/greed/seek
	var/datum/action/innate/absorb_life_essense/absorb_life
	var/list/absorbed_dna = list()

/obj/item/clothing/head/helmet/greed/atom_init()
	. = ..()
	poi_list += src
	seek = new(src)
	absorb_life = new(src)

/obj/item/clothing/head/helmet/greed/Destroy() //Unique item
	SHOULD_CALL_PARENT(FALSE)
	var/turf/targetturf = pick_landmarked_location("blobstart", least_used = FALSE)
	forceMove(targetturf)
	update_world_icon()
	if(ismob(loc))
		seek.Remove(loc)
	qdel(seek)
	return QDEL_HINT_LETMELIVE

/obj/item/clothing/head/helmet/greed/examine(mob/user)
	. = ..()
	if(iscultist(user) || isobserver(user))
		to_chat(user, "<span class='cult'>Тень Маски греха Жадности. В какой-то момент безумец решил обезглавить гиганта, с чем успешно справился. А затем надел ЭТО на голову. Маска. Но шлем.</span>")
		to_chat(user, "<span class='cult'>Приводит носителя к интересностям: людям, вещам, душам. Владелец способен красть жизненные силы существа и укреплять ими тело.</span>")
		to_chat(user, "<span class='cult'>В данный момент имеет <span class='red'>[stoneshards]</span> [pluralize_russian(stoneshards, "камень", "камня", "камней")] крови.</span>")
	else if(ishuman(user))
		to_chat(user, "<span class='cult'>Что-то нижние конечности не очень относятся к идее одеть это...</span>")
		user.make_dizzy(stoneshards)

/obj/item/clothing/head/helmet/greed/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(!iscultist(H) && prob(4))
		if(H.head)
			if(prob(50)) //If this happens - you r dead
				to_chat(user, "<span class='userdanger'>Хочется снять головной убор...</span>")
				return
			H.drop_from_inventory(H.wear_suit, get_turf(src))
		if(user.equip_to_slot_if_possible(src, SLOT_HEAD))
			to_chat(user, "<span class='cult'>Вы и сами не замечаете, как одеваете череп!</span>")
	if(slot == SLOT_HEAD)
		if(!iscultist(user))
			to_chat(user, "<span class='cult big'>Ваше тело ссыхается, оставляя одни кости!</span>")
			H.makeSkeleton()
			user.ghostize(FALSE)
		add_powers(user)
	else remove_powers(user)

/obj/item/clothing/head/helmet/greed/pickup(mob/user)
	. = ..()

/obj/item/clothing/head/helmet/greed/dropped(mob/user)
	. = ..()
	if(isliving(user))
		remove_powers(user)

/obj/item/clothing/head/helmet/greed/proc/add_powers(mob/living/user)
	seek.Grant(src)
	absorb_life.Grant(src)

/obj/item/clothing/head/helmet/greed/proc/remove_powers(mob/living/user)
	if(ismob(user))
		seek.Remove(loc)
		absorb_life.Remove(user)

/obj/item/clothing/head/helmet/greed/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/blood_gem) && iscultist(user))
		stoneshards++ //Yes, big gems means just one
		qdel(I)
		to_chat(user, "<span class='cult'>Камень расплавился и впитался в поверхность артефакта, как только коснулся его!</span>")

		add_filter("gem_outline", 2, outline_filter(1, COLOR_CRIMSON_RED))
		animate(filters[filters.len], color = COLOR_RED_GRAY, time = 2 SECONDS)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, remove_filter), "gem_outline"), 2 SECONDS)

/datum/action/innate/absorb_life_essense
	name = "Absorb life essense"

/datum/action/innate/absorb_life_essense/Activate()
	//RegisterSignal(owner, list(COMSIG_MOB_CLICK), TYPE_PROC_REF(/obj/item/weapon/storage/belt/gluttony, gluttony))
	var/mob/living/user = owner
	var/obj/item/weapon/grab/G = user.get_active_hand()
	if(!istype(G))
		to_chat(user, "<span class='warning'>We must be grabbing a creature in our active hand to absorb them.</span>")
		return FALSE
	if(G.state <= GRAB_NECK)
		to_chat(user, "<span class='warning'>We must have a tighter grip to absorb this creature.</span>")
		return FALSE
	if(!G.affecting)
		to_chat(user, "<span class='warning'>You needd a human to absorb life force!</span>")
		return FALSE
	if(!ishuman(G.affecting))
		to_chat(user, "<span class='warning'>[G.affecting] is too simple for absorption.</span>")
		return FALSE

	var/mob/living/carbon/human/T = G.affecting

	if(T.species.flags[IS_SYNTHETIC] || T.species.flags[IS_PLANT])
		to_chat(user, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return FALSE

	if(HAS_TRAIT(T, TRAIT_NO_BLOOD))
		to_chat(src, "<span class='warning'>This creature has no life essense to absorb</span>")
		return FALSE
	var/obj/item/clothing/head/helmet/greed/helm = target
	for(var/datum/dna/D in helm.absorbed_dna)
		if(T.dna.uni_identity == D.uni_identity)
			if(T.dna.struc_enzymes == D.struc_enzymes)
				if(T.dna.original_character_name == D.original_character_name)
					to_chat(user, "<span class='warning'>We already have that life in our veins.</span>")
					return FALSE

	if(!ishuman(owner))
		to_chat(user, "<span class='warning'>Only human can drain life from a human!</span>")
		return FALSE
	var/mob/living/carbon/human/H = owner

	if(!do_after(owner, 10 SECONDS, TRUE, T, FALSE))
		to_chat(user, "<span class='warning'>You are interrupted!</span>")
		return FALSE
	var/modifier = rand(0.8, 0.9)
	var/num
	for(var/obj/item/organ/external/BP in T.bodyparts)
		num += BP.min_broken_damage - (BP.min_broken_damage * modifier)
		BP.min_broken_damage *= modifier
	num /= H.bodyparts
	for(var/obj/item/organ/external/BP in H.bodyparts)
		BP.min_broken_damage += num

	num = T.health - (H.health * modifier)
	T.maxHealth *= modifier
	if(T.health > T.maxHealth)
		T.take_overall_damage(T.health - T.maxHealth)
	H.maxHealth += num
	to_chat(user, "<span class='warning'>You drained [T.real_name]! Your bones and lifeforce hardens!</span>")












//Уныние. Позволяют возраждаться, проходить сквозь стены, возможно дать абилку лезть из крови аля кровавому демону с тг?
/obj/item/clothing/shoes/sadness
	name = "curved leggins"
	desc = "half trunsluscent leggins "
	icon_state = "greed"
	can_be_pulled = FALSE //Risk it
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	cold_protection = ARMS
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = ARMS
	max_heat_protection_temperature = SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = null //Every specie can equip it
	unacidable = TRUE
	resistance_flags = FULL_INDESTRUCTIBLE
	equip_time = 2 SECONDS
	armor = list(melee = 50, bullet = 50, laser = 20, energy = 0, bomb = 100, bio = 50, rad = 30)
	var/stoneshards = 0

/obj/item/clothing/shoes/sadness/atom_init()
	. = ..()
	poi_list += src

/obj/item/clothing/shoes/sadness/Destroy() //Unique item
	SHOULD_CALL_PARENT(FALSE)
	var/turf/targetturf = pick_landmarked_location("blobstart", least_used = FALSE)
	forceMove(targetturf)
	update_world_icon()
	return QDEL_HINT_LETMELIVE

/obj/item/clothing/shoes/sadness/examine(mob/user)
	. = ..()
	if(iscultist(user) || isobserver(user))
		to_chat(user, "<span class='cult'>Тень Понож греха Уныния. Позволяет своему владельцу мастерски сбегать от неприятеля, а при необходимости и от смерти. Кто вообще додумался сделать артефактом обувь? </span>")
		to_chat(user, "<span class='cult'>Позволяет буквально проходить сквозь стены, а при смерти и вытаскивает из ёё объятий</span>")
		to_chat(user, "<span class='cult'>В данный момент имеет <span class='red'>[stoneshards]</span> [pluralize_russian(stoneshards, "камень", "камня", "камней")] крови.</span>")
		if(prob(5))
			to_chat(user, "<span class='cult'>На миг руны образовали фразу: \"быстрые ноги п...\", далее нечитаемо</span>")
	else if(ishuman(user))
		to_chat(user, "<span class='cult'>Что-то кости разнылись...</span>")
		user.make_dizzy(stoneshards)

/obj/item/clothing/shoes/sadness/pickup(mob/living/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_ARTEFACT_USER))
		to_chat(user, "<span class='cult'>Силы двух артефактов не позволяют соприкоснуться!</span>")
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.take_certain_bodypart_damage(list(pick(BP_L_ARM, BP_R_ARM)), rand(5, 10))
		else
			user.take_overall_damage()
		return FALSE

/obj/item/clothing/shoes/sadness/equipped(mob/user, slot)
	. = ..()
	var/mob/living/carbon/human/H = user
	if(HAS_TRAIT(user, TRAIT_ARTEFACT_USER))
		to_chat(user, "<span class='cult'>Силы двух артефактов не позволяют соприкоснуться!</span>")
		H.take_certain_bodypart_damage(list(pick(BP_L_ARM, BP_R_ARM)), rand(5, 10))
		H.drop_from_contents()
		return FALSE
	else
		ADD_TRAIT(user, TRAIT_ARTEFACT_USER, src) //Now, we can add a trait
	if(!ishuman(user))
		return

	if(!iscultist(H) && prob(4))
		if(H.gloves)
			if(prob(50)) //If this happens - you r dead
				to_chat(user, "<span class='userdanger'>В какой-то момент вас начали раздражать перчатки, вам захотелось их снять, но вдруг поняли - этого делать не стоит</span>")
				return
			if(!H.unEquip(H.gloves))
				for(var/obj/item/I in H.get_equipped_items() - list(H.l_hand, H.r_hand))
					if(I.flags_inv == HIDEGLOVES && prob(50))
						H.unEquip(I, TRUE)
		if(user.equip_to_slot_if_possible(src, SLOT_GLOVES))
			to_chat(user, "<span class='cult'>Вы и сами не замечаете, как одеваете поножи!</span>")
	if(slot == SLOT_GLOVES)
		if(!iscultist(user))
			var/obj/item/organ/external/head/head = H.bodyparts_by_name[BP_HEAD]
			head.brainmob.gib()
			for(var/obj/item/organ/external/BP in H.bodyparts)
				BP.droplimb()
			to_chat(user, "<span class='cult big'>Ваше тело было разделено на дольки, словно вкусное спелое яблоко, как только перчатки были одеты! Вы откинули коньки!</span>")
		add_powers(user)
	else remove_powers(user)

/obj/item/clothing/shoes/sadness/dropped(mob/user)
	. = ..()
	if(isliving(user))
		remove_powers(user)

/obj/item/clothing/shoes/sadness/proc/add_powers(mob/living/user)
	AddElement(/datum/element/wall_walker, /turf/simulated/wall)
	RegisterSignal(user, list(COMSIG_MOB_DIED), TYPE_PROC_REF(/obj/item/clothing/shoes/sadness, user_death))

/obj/item/clothing/shoes/sadness/proc/remove_powers(mob/living/user)
	RemoveElement(/datum/element/wall_walker)
	UnregisterSignal(user, list(COMSIG_MOB_DIED))

/obj/item/clothing/shoes/sadness/proc/user_death()
	if(ishuman(loc))
		if(stoneshards < 2)
			return
		var/mob/living/carbon/human/H = loc
		to_chat(H, "<span class='cult big'>Вас коснлуся перст Смерти, но Уныние вырвало вас из её объятий. Однако, всему есть своя цена...</span>")
		stoneshards -= 2
		H.forceMove(pick_landmarked_location("blobstart"))
		H.rejuvenate()
		for(var/obj/item/organ/external/BP in H.bodyparts)
			BP.min_broken_damage *= rand(0.8, 0.9)
		H.health *= rand(0.8, 0.9)
		H.maxHealth *= 0.8

/obj/item/clothing/shoes/sadness/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/blood_gem) && iscultist(user))
		stoneshards++ //Yes, big gems means just one
		qdel(I)
		to_chat(user, "<span class='cult'>Камень расплавился и впитался в поверхность артефакта, как только коснулся его!</span>")

		add_filter("gem_outline", 2, outline_filter(1, COLOR_CRIMSON_RED))
		animate(filters[filters.len], color = COLOR_RED_GRAY, time = 2 SECONDS)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, remove_filter), "gem_outline"), 2 SECONDS)




/*todo звуки напихать везде и всюду,
напиздить вещей с тг типа талисмана, термалов и т.п. сделать ослабленные версии артефакта
сделать что бы печка могла выдавать особые предметы взамен гемов
гемы можно собирать и в аномальках
придумать как экипаж можно награждать за штурм рая, может какие-то аномальки на той стороне?
руну апокалипсиса с последовательным вызовом ВСЕХ ивентов с ТГ
*/

//Lust. ERP the server. Adminabuse weapon. Cant be used without admin's permission.
/obj/item/weapon/banhammer/lust
	can_be_pulled = FALSE
	unacidable = TRUE
	resistance_flags = FULL_INDESTRUCTIBLE
	slowdown = -0.3
	canremove = FALSE
	flash_protection = FLASHES_FULL_PROTECTION

	w_class = SIZE_BIG_HUMAN //Admin must confirm their actions to use it
	anchored = TRUE
	var/usage_allowed = FALSE
	var/removed_status_flags

/obj/item/weapon/banhammer/lust/atom_init()
	. = ..()
	poi_list += src
	message_admins("<span class='notice'>[ADMIN_FLW(src)][src] was spawned! Be aware, this is admin's weapon! <a href='byond://?src=\ref[src];allow_usage=1'>Allow usage</a>")

/obj/item/weapon/banhammer/lust/Destroy() //Unique item
	. = ..()
	message_admins("<span class='notice'>[src] was destroyed!</span>")
	poi_list -= src

/obj/item/weapon/banhammer/lust/examine(mob/user)
	. = ..()
	if(user.client.holder)
		to_chat(user, "<a href='byond://?src=\ref[src];allow_usage=1'>Allow usage</a>")

/obj/item/weapon/banhammer/lust/Topic(href, href_list)
	..()
	if(href_list["allow_usage"])
		if(!check_rights(R_ADMIN))
			return
		w_class = SIZE_SMALL //Now we can use it
		anchored = FALSE
		usage_allowed = TRUE
		message_admins("<span class='notice'>[ADMIN_FLW(src)][key_name_admin(usr)] allowed usage of [src]! Banhammerfest must go on!")

/obj/item/weapon/banhammer/lust/Get_shield_chance()
	return 80

/obj/item/weapon/banhammer/lust/attack(mob/living/carbon/M, mob/living/carbon/user)
	. = ..()
	if(ismob(M))
		if(!M.client || !usage_allowed)
			return
		if(!check4admin(M, user))
			to_chat(M, "<span class='warning'>Их дух слишком силен! Он под защитой!</span>") //Precaution
			return
		to_chat(M, "<span class='alert reallybig bold'>You have been ERPed from the server</span>")
		message_admins("<span class='notice'>[key_name_admin(M)] booted by adminabuse means ([src]) by [key_name_admin(user)].</span>")
		QDEL_IN(M.client, 2 SECONDS)

/obj/item/weapon/banhammer/lust/proc/check4admin(mob/living/carbon/M, mob/living/carbon/user)
	if(M.client.holder && !user.client.holder) //Non-admin tries to kick admin
		return FALSE
	if(user.client.holder.rights != M.client.holder.rights) //Both admins
		if((user.client.holder.rights & M.client.holder.rights) == M.client.holder.rights)
			return TRUE	//we have all the rights they have and more
		return FALSE
	return TRUE

/obj/item/weapon/banhammer/lust/equipped(mob/user, slot)
	. = ..()
	if(isliving(user))
		var/mob/living/L = user
		L.mob_general_damage_mod.ModMultiplicative(0.5, src)
	removed_status_flags = (CANSTUN|CANPARALYSE|CANWEAKEN|CANPUSH)
	removed_status_flags &= ~user.status_flags
	ADD_TRAIT(user, TRAIT_NO_EMBED, src)
	ADD_TRAIT(user, TRAIT_NO_MINORCUTS, src)
	ADD_TRAIT(user, TRAIT_NO_PAIN, src)
	ADD_TRAIT(user, TRAIT_NO_BREATHE, src)
	ADD_TRAIT(user, TRAIT_VIRUS_IMMUNE, src)
	ADD_TRAIT(user, TRAIT_MORPH_IMMUNE, src)
	RegisterSignal(user, COMSIG_ATOM_START_PULL, PROC_REF(can_be_pulled))
	ADD_TRAIT(user, TRAIT_STRONGMIND, src)
	ADD_TRAIT(user, TRAIT_LIGHT_STEP, src)
	ADD_TRAIT(user, TRAIT_HEMOCOAGULATION, src)
	ADD_TRAIT(user, TRAIT_SOULSTONE_IMMUNE, src)
	ADD_TRAIT(user, TRAIT_NEVER_FAT, src)
	RegisterSignal(user, COMSIG_LIVING_CAN_TRACK, PROC_REF(can_track))

/obj/item/weapon/banhammer/lust/proc/can_be_pulled()
	SIGNAL_HANDLER
	return COMPONENT_PREVENT_PULL

/obj/item/weapon/banhammer/lust/proc/can_track(datum/source)
	SIGNAL_HANDLER
	return COMPONENT_CANT_TRACK

/obj/item/weapon/banhammer/lust/dropped(mob/user)
	. = ..()
	if(isliving(user))
		var/mob/living/L = user
		L.mob_general_damage_mod.RemoveMods(src)
	user.add_status_flags(removed_status_flags)
	UnregisterSignal(user, COMSIG_LIVING_CAN_TRACK)
	UnregisterSignal(user, COMSIG_ATOM_START_PULL)
	REMOVE_TRAIT(user, TRAIT_STRONGMIND, src)
	REMOVE_TRAIT(user, TRAIT_LIGHT_STEP, src)
	REMOVE_TRAIT(user, TRAIT_SOULSTONE_IMMUNE, src)
	REMOVE_TRAIT(user, TRAIT_HEMOCOAGULATION, src)
	REMOVE_TRAIT(user, TRAIT_NO_BREATHE, src)
	REMOVE_TRAIT(user, TRAIT_NO_PAIN, src)
	REMOVE_TRAIT(user, TRAIT_VIRUS_IMMUNE, src)
	REMOVE_TRAIT(user, TRAIT_MORPH_IMMUNE, src)
	REMOVE_TRAIT(user, TRAIT_NO_EMBED, src)
	REMOVE_TRAIT(user, TRAIT_NO_MINORCUTS, src)
//RegisterSignal(carry_obj, list(COMSIG_ATOM_CANPASS), PROC_REF(check_canpass))
/**7 предметов экипировки, из которых можно получить 6 - через коррапт вещей глав. По грехам:
гнев - гсб - плащ - перчатки, дающие огромное количество комбо поинтов, уклонение от выстрелов
зависть - рд - броня - ожерелье спавнящее иллюзии при попадении, которые блокируют урон, некоторые убегают, некоторые нападают
чревоугодие - смо - гипоспрей - пояс - лечение аурой культистов вокруг, урон остальным
гордость - се - риг - роба, дающий невосприимчиовсть к космосу, радиации, огню, холоду, электричеству, слежению, емп, потоку воздуха, возможность бегать по космосу, невосприимчивость к станам, разливание воды повсюду
уныние - хоп - форма - воскрешение
алчность - капитан - лазер - том, не имеющий кд на разрушение, может поглощать трупы, давая случайный аспект культу, увеличивает хп, прочность костей, органов
похоть - только админ - кикает при ударе с сервера и в ближайшую стену

/obj/item/clothing/gloves/rage
/obj/item/clothing/neck/envy
/obj/item/weapon/storage/belt/gluttony
/obj/item/clothing/suit/space/pride
/obj/item/clothing/head/greed
/obj/item/clothing/under/sadness
/obj/item/weapon/banhammer/lust
**/

// Void cloak. Turns invisible with the hood up, lets you hide stuff. Hides from AI
/obj/item/clothing/head/culthood/void
	name = "void hood"
	//icon = 'icons/obj/clothing/head/helmet.dmi'
	desc = "Black like tar, reflecting no light. Runic symbols line the outside. \
		With each flash you lose comprehension of what you are seeing."
	icon_state = "void_cloak"
	item_state = "" //you shouldnt see hood
	flags_inv = NONE
	render_flags = NONE

	armor = list(melee = 30, bullet = 25, laser = 45, energy = 40, bomb = 25, bio = 10, rad = 0)

/obj/item/clothing/head/culthood/void/atom_init()
	. = ..()
	ADD_TRAIT(src, TRAIT_EXAMINE_SKIP, src)

/obj/item/clothing/suit/hooded/cultrobes/void
	name = "void cloak"
	desc = "Black like tar, reflecting no light. Runic symbols line the outside. \
		With each flash you lose comprehension of what you are seeing."
	icon_state = "void_cloak"
	item_state = "void_cloak"
	allowed = list(/obj/item/weapon/storage/bible/tome,/obj/item/weapon/melee/cultblade)
	hoodtype = /obj/item/clothing/head/culthood/void
	flags_inv = NONE
	// slightly worse than normal cult robes
	armor = list(melee = 30, bullet = 25, laser = 45, energy = 40, bomb = 25, bio = 10, rad = 0)

/obj/item/clothing/suit/hooded/cultrobes/void/examine(mob/user)
	. = ..()
	if(!iscultist(user) || isobserver(user))
		return

	// Let examiners know this works as a focus only if the hood is down
	to_chat(user, "<span class='notice'>Защищает от слежки, а также невидим и неощутим при опущенном копюшоне. Скрывает хранимый предмет.</span>")

/obj/item/clothing/suit/hooded/cultrobes/void/dropped()
	. = ..()
	RemoveElement(/datum/element/digitalcamo)

/obj/item/clothing/suit/hooded/cultrobes/void/ToggleHood()
	if(!isliving(loc))
		CRASH("[src] attempted to make a hood on a non-living thing: [loc]")
	var/mob/living/wearer = loc
	if(!iscultist(wearer))
		loc.balloon_alert(loc, "can't get the hood up!")
		return

	. = ..()

	if(hooded)
		ADD_TRAIT(src, TRAIT_EXAMINE_SKIP, src)
		if(isliving(loc))
			loc.AddElement(/datum/element/digitalcamo)
			loc.balloon_alert(loc, "cloak revealed")
			loc.visible_message("<span class='notice'>A kaleidoscope of colours collapses around [loc], a cloak appearing suddenly around their person!</span>")
	//RemoveHood() called in parent if needed

/// Makes our cloak "invisible". Not the wearer, the cloak itself.
/obj/item/clothing/suit/hooded/cultrobes/void/RemoveHood()
	. = ..()
	REMOVE_TRAIT(src, TRAIT_EXAMINE_SKIP, src)

	if(isliving(loc))
		loc.RemoveElement(/datum/element/digitalcamo)
		loc.balloon_alert(loc, "cloak hidden")
		loc.visible_message("<span class='notice'>Light shifts around [loc], making the cloak around them invisible!</span>")

/datum/action/item_action/stealth_mode
	name = "Toggle Stealth"
	desc = "Makes you invisible to the naked eye."
	//button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "shadow"
	/// Whether stealth is active or not
	var/stealth_engaged = FALSE
	/// The amount of time the stealth mode can be active for, drains to 0 when active
	var/charge = 30 SECONDS
	/// The maximum amount of time the stealth mode can be active for
	var/max_charge = 30 SECONDS
	/// The minimum alpha value for the stealth mode
	var/min_alpha = 0
	/// Whether the stealth mode recharges while active
	/// if TRUE standing in darkness will recharge even while active
	/// if FALSE it will not uncharge, but not recharge while in darkness
	var/recharge_while_active = TRUE

/datum/action/item_action/stealth_mode/IsAvailable()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		return H.belt == target

//datum/action/item_action/stealth_mode/is_action_active(atom/movable/screen/movable/action_button/current_button)
//	return stealth_engaged

/datum/action/item_action/stealth_mode/Grant(mob/grant_to)
	. = ..()
	START_PROCESSING(SSobj, src)
	var/obj/item/I = target
	I.update_item_actions()

/datum/action/item_action/stealth_mode/Remove(mob/remove_from)
	if(!isnull(owner) && stealth_engaged)
		stealth_off()
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/action/item_action/stealth_mode/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	if(stealth_engaged)
		stealth_off()
	else
		stealth_on()

/datum/action/item_action/stealth_mode/proc/stealth_on()
	animate(owner, alpha = get_alpha(), time = 0.5 SECONDS)
	apply_wibbly_filters(owner)
	stealth_engaged = TRUE
	var/obj/item/I = target
	I.update_item_actions()
	owner.balloon_alert(owner, "stealth mode engaged")

/datum/action/item_action/stealth_mode/proc/stealth_off()
	owner.alpha = initial(owner.alpha)
	remove_wibbly_filters(owner)
	stealth_engaged = FALSE
	var/obj/item/I = target
	I.update_item_actions()
	StartCooldown()
	owner.balloon_alert(owner, "stealth mode disengaged")

/datum/action/item_action/stealth_mode/proc/get_alpha()
	return clamp(255 - (255 * charge / max_charge), min_alpha, 255)

/datum/action/item_action/stealth_mode/process(seconds_per_tick)
	if(!stealth_engaged)
		// Recharge over time
		charge = min(max_charge, charge + (max_charge * 0.04) * seconds_per_tick)
		var/obj/item/I = target
		I.update_item_actions()
		return

	if(charge <= 0)
		stealth_off()
		return

	var/turf/our_turf = get_turf(owner)
	var/lumcount = our_turf?.get_lumcount() || 0
	if(lumcount > 0.3)
		// Decay charge while invisible+ in the light
		charge = max(0, charge - (max_charge * 0.05) * seconds_per_tick)
		var/obj/item/I = target
		I.update_item_actions()

	else if(recharge_while_active)
		// Return charage while invisible + in the darkness + recharge_while_active
		charge = min(max_charge, charge + (max_charge * 0.1) * seconds_per_tick)
		var/obj/item/I = target
		I.update_item_actions()

	animate(owner, alpha = get_alpha(), time = 1 SECONDS, flags = ANIMATION_PARALLEL)

/datum/action/item_action/stealth_mode/UpdateButtonIcon(status_only, force)
	. = ..()
	button.maptext_x = 9
	button.maptext = MAPTEXT_TINY_UNICODE("[round(charge / max_charge * 100, 0.01)]%")

//It works only in darkness, 3 seconds just to hide
/datum/action/item_action/stealth_mode/weaker
	charge = 3 SECONDS
	max_charge = 3 SECONDS
	min_alpha = 20
	recharge_while_active = FALSE

/obj/item/shadowcloak
	name = "cloaker belt"
	desc = "Makes you invisible for short periods of time. Recharges in darkness, even while active."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utility"
	item_state = "utility"
	//inhand_icon_state = "utility"
	//lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	//righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	//worn_icon_state = "utility"
	slot_flags = SLOT_BELT
	//attack_verb_continuous = list("whips", "lashes", "disciplines")
	//attack_verb_simple = list("whip", "lash", "discipline")
	item_action_types = list(/datum/action/item_action/stealth_mode)

//obj/item/shadowcloak/
//	return slot & slot_flags

/obj/item/shadowcloak/weaker
	name = "stealth belt"
	desc = "Makes you nigh-invisible to the naked eye for a short period of time. \
		Lasts indefinitely in darkness, but will not recharge unless inactive."
	item_action_types = list(/datum/action/item_action/stealth_mode/weaker)
/*
// The rune carver, a heretic knife that can draw rune traps.
/obj/item/melee/rune_carver
	name = "carving knife"
	desc = "A small knife made of cold steel, pure and perfect. Its sharpness can carve into titanium itself - \
		but only few can evoke the dangers that lurk beneath reality."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "rune_carver"
	icon_angle = -45
	obj_flags = CONDUCTS_ELECTRICITY
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_SMALL
	wound_bonus = 20
	force = 10
	throwforce = 20
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "slice", "tear", "lacerate", "rip", "dice", "rend")
	actions_types = list(/datum/action/item_action/rune_shatter)
	embed_type = /datum/embedding/rune_carver

	/// Whether we're currently drawing a rune
	var/drawing = FALSE
	/// Max amount of runes that can be drawn
	var/max_rune_amt = 3
	/// A list of weakrefs to all of ourc urrent runes
	var/list/datum/weakref/current_runes = list()
	/// Turfs that you cannot draw carvings on
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/open/space, /turf/open/openspace, /turf/open/lava))
	var/list/alt_continuous = list("stabs", "pierces", "impales")
	var/list/alt_simple = list("stab", "pierce", "impale")

/obj/item/melee/rune_carver/Initialize(mapload)
	. = ..()
	alt_continuous = string_list(alt_continuous)
	alt_simple = string_list(alt_simple)
	AddComponent(/datum/component/alternative_sharpness, SHARP_POINTY, alt_continuous, alt_simple)

/datum/embedding/rune_carver
	ignore_throwspeed_threshold = TRUE
	embed_chance = 75
	jostle_chance = 2
	jostle_pain_mult = 5
	pain_stam_pct = 0.4
	pain_mult = 3
	rip_time = 15

/obj/item/melee/rune_carver/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user) && !isobserver(user))
		return

	. += span_notice("<b>[length(current_runes)] / [max_rune_amt]</b> total carvings have been drawn.")
	. += span_info("The following runes can be carved:")
	for(var/obj/structure/trap/eldritch/trap as anything in subtypesof(/obj/structure/trap/eldritch))
		var/potion_string = span_info("\tThe " + initial(trap.name) + " - " + initial(trap.carver_tip))
		. += potion_string

/obj/item/melee/rune_carver/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!IS_HERETIC_OR_MONSTER(user))
		return NONE
	if(!isopenturf(interacting_with) || is_type_in_typecache(interacting_with, blacklisted_turfs))
		return NONE

	INVOKE_ASYNC(src, PROC_REF(try_carve_rune), interacting_with, user)
	return ITEM_INTERACT_SUCCESS

/*
 * Begin trying to carve a rune. Go through a few checks, then call do_carve_rune if successful.
 */
/obj/item/melee/rune_carver/proc/try_carve_rune(turf/open/target_turf, mob/user)
	if(drawing)
		target_turf.balloon_alert(user, "already carving!")
		return

	if(locate(/obj/structure/trap/eldritch) in range(1, target_turf))
		target_turf.balloon_alert(user, "to close to another carving!")
		return

	for(var/datum/weakref/rune_ref as anything in current_runes)
		if(!rune_ref?.resolve())
			current_runes -= rune_ref

	if(length(current_runes) >= max_rune_amt)
		target_turf.balloon_alert(user, "too many carvings!")
		return

	drawing = TRUE
	do_carve_rune(target_turf, user)
	drawing = FALSE

/*
 * The actual proc that handles selecting the rune to draw and creating it.
 */
/obj/item/melee/rune_carver/proc/do_carve_rune(turf/open/target_turf, mob/user)
	// Assoc list of [name] to [image] for the radial (to show tooltips)
	var/static/list/choices = list()
	// Assoc list of [name] to [path] for after the radial
	var/static/list/names_to_path = list()
	if(!choices.len || !names_to_path.len)
		for(var/obj/structure/trap/eldritch/trap as anything in subtypesof(/obj/structure/trap/eldritch))
			names_to_path[initial(trap.name)] = trap
			choices[initial(trap.name)] = image(icon = initial(trap.icon), icon_state = initial(trap.icon_state))

	var/picked_choice = show_radial_menu(
		user,
		target_turf,
		choices,
		require_near = TRUE,
		tooltips = TRUE,
		)

	if(isnull(picked_choice))
		return

	var/to_make = names_to_path[picked_choice]
	if(!ispath(to_make, /obj/structure/trap/eldritch))
		CRASH("[type] attempted to create a rune of incorrect type! (got: [to_make])")

	target_turf.balloon_alert(user, "carving [picked_choice]...")
	user.playsound_local(target_turf, 'sound/items/sheath.ogg', 50, TRUE)
	if(!do_after(user, 5 SECONDS, target = target_turf))
		target_turf.balloon_alert(user, "interrupted!")
		return

	target_turf.balloon_alert(user, "[picked_choice] carved")
	var/obj/structure/trap/eldritch/new_rune = new to_make(target_turf, user)
	current_runes += WEAKREF(new_rune)

/datum/action/item_action/rune_shatter
	name = "Rune Break"
	desc = "Destroys all runes carved by this blade."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon_state = "rune_break"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'

/datum/action/item_action/rune_shatter/New(Target)
	. = ..()
	if(!istype(Target, /obj/item/melee/rune_carver))
		qdel(src)
		return

/datum/action/item_action/rune_shatter/Grant(mob/granted)
	if(!IS_HERETIC_OR_MONSTER(granted))
		return

	return ..()

/datum/action/item_action/rune_shatter/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	if(!IS_HERETIC_OR_MONSTER(owner))
		return FALSE
	var/obj/item/melee/rune_carver/target_sword = target
	if(!length(target_sword.current_runes))
		return FALSE

/datum/action/item_action/rune_shatter/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	owner.playsound_local(get_turf(owner), 'sound/effects/magic/blind.ogg', 50, TRUE)
	var/obj/item/melee/rune_carver/target_sword = target
	QDEL_LIST(target_sword.current_runes)
	target_sword.SpinAnimation(5, 1)
	return TRUE

// The actual rune traps the knife draws.
/obj/structure/trap/eldritch
	name = "elder carving"
	desc = "Collection of unknown symbols, they remind you of days long gone..."
	icon = 'icons/obj/service/hand_of_god_structures.dmi'
	max_integrity = 60
	/// A tip displayed to heretics who examine the rune carver. Explains what the rune does.
	var/carver_tip
	/// Reference to trap owner mob
	var/datum/weakref/owner

/obj/structure/trap/eldritch/Initialize(mapload, new_owner)
	. = ..()
	if(new_owner)
		owner = WEAKREF(new_owner)

/obj/structure/trap/eldritch/on_entered(datum/source, atom/movable/entering_atom)
	if(!isliving(entering_atom))
		return
	var/mob/living/living_mob = entering_atom
	if(WEAKREF(living_mob) == owner)
		return
	if(IS_HERETIC_OR_MONSTER(living_mob))
		return
	return ..()

/obj/structure/trap/eldritch/attacked_by(obj/item/weapon, mob/living/user)
	if(istype(weapon, /obj/item/melee/rune_carver) || istype(weapon, /obj/item/nullrod))
		loc.balloon_alert(user, "carving dispelled")
		playsound(src, 'sound/items/sheath.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, ignore_walls = FALSE)
		qdel(src)

	return ..()

/obj/structure/trap/eldritch/alert
	name = "alert carving"
	icon_state = "alert_rune"
	alpha = 10
	time_between_triggers = 5 SECONDS
	sparks = FALSE
	carver_tip = "A nearly invisible rune that, when stepped on, alerts the carver who triggered it and where."

/obj/structure/trap/eldritch/alert/trap_effect(mob/living/victim)
	var/mob/living/real_owner = owner?.resolve()
	if(real_owner)
		to_chat(real_owner, span_userdanger("[victim.real_name] has stepped foot on the alert rune in [get_area(src)]!"))
		real_owner.playsound_local(get_turf(real_owner), 'sound/effects/magic/curse.ogg', 50, TRUE)

/obj/structure/trap/eldritch/tentacle
	name = "grasping carving"
	icon_state = "tentacle_rune"
	time_between_triggers = 45 SECONDS
	charges = 1
	carver_tip = "When stepped on, causes heavy damage leg damage and stuns the victim for 5 seconds. Has 1 charge."

/obj/structure/trap/eldritch/tentacle/trap_effect(mob/living/victim)
	if(!iscarbon(victim))
		return
	var/mob/living/carbon/carbon_victim = victim
	carbon_victim.Paralyze(5 SECONDS)
	carbon_victim.apply_damage(20, BRUTE, BODY_ZONE_R_LEG)
	carbon_victim.apply_damage(20, BRUTE, BODY_ZONE_L_LEG)
	playsound(src, 'sound/effects/magic/demon_attack1.ogg', 75, TRUE)

/obj/structure/trap/eldritch/mad
	name = "mad carving"
	icon_state = "madness_rune"
	time_between_triggers = 20 SECONDS
	charges = 2
	carver_tip = "When stepped on, causes heavy stamina damage, blindness, and a variety of ailments to the victim. Has 2 charges."

/obj/structure/trap/eldritch/mad/trap_effect(mob/living/victim)
	if(!iscarbon(victim))
		return
	var/mob/living/carbon/carbon_victim = victim
	carbon_victim.adjustStaminaLoss(80)
	carbon_victim.adjust_silence(20 SECONDS)
	carbon_victim.adjust_stutter(1 MINUTES)
	carbon_victim.adjust_confusion(5 SECONDS)
	carbon_victim.set_jitter_if_lower(20 SECONDS)
	carbon_victim.set_dizzy_if_lower(40 SECONDS)
	carbon_victim.adjust_temp_blindness(4 SECONDS)
	carbon_victim.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)
	playsound(src, 'sound/effects/magic/blind.ogg', 75, TRUE)*/

/obj/item/clothing/mask/madness_mask
	name = "abyssal mask"
	desc = "A mask created from suffering. When you look into its eyes, it looks back."
	icon_state = "mad_mask"
	item_state = "null"
	w_class = SIZE_SMALL
	//flags_cover = EYES_COVERAGE
	//resistance_flags = FLAMMABLE
	flags_inv = HIDEFACE|HIDEEYES
	///Who is wearing this
	var/mob/living/carbon/human/local_user

/obj/item/clothing/mask/madness_mask/Destroy()
	local_user = null
	return ..()

/obj/item/clothing/mask/madness_mask/examine(mob/user)
	. = ..()
	if(iscultist(user) && isobserver(user))
		to_chat(user, "<span class='notice'>Actively drains the sanity and stamina of nearby heretics when worn!</span>")
		to_chat(user, "<span class='notice'>If forced onto the face of a heretic, they will be unable to remove it willingly.</span>")
	else
		to_chat(user, "<span class='danger'>If forced onto the face of a heretic, they will be unable to remove it willingly.</span>")

/obj/item/clothing/mask/madness_mask/equipped(mob/user, slot)
	. = ..()
	if(!(slot & SLOT_WEAR_MASK))
		return
	if(!ishuman(user) || !user.mind)
		return

	local_user = user
	START_PROCESSING(SSobj, src)

	if(iscultist(user) && isobserver(user))
		return

	canremove = FALSE
	to_chat(user, "<span class='userdanger'>[src] clamps tightly to your face as you feel your soul draining away!</span>")

/obj/item/clothing/mask/madness_mask/dropped(mob/M)
	local_user = null
	STOP_PROCESSING(SSobj, src)
	canremove = TRUE
	return ..()

/obj/item/clothing/mask/madness_mask/process(seconds_per_tick)
	if(!local_user)
		return PROCESS_KILL

	if(iscultist(local_user) && !canremove)
		canremove = TRUE

	for(var/mob/living/carbon/human/human_in_range in view(local_user))
		if(iscultist(human_in_range) || human_in_range.blinded)
			continue

		if(human_in_range.mind.holy_role)
			continue
		var/datum/component/mood/mood = human_in_range.GetComponent(/datum/component/mood)
		if(mood)
			mood.direct_spirit_drain(rand(-2, -20) * seconds_per_tick)

		if(SPT_PROB(60, seconds_per_tick))
			human_in_range.hallucination = min(human_in_range.hallucination + 10 SECONDS, 240 SECONDS)

		if(SPT_PROB(40, seconds_per_tick))
			human_in_range.make_jittery(min(human_in_range.jitteriness + 10 SECONDS, 30 SECONDS))

		if(human_in_range.getHalLoss() <= 85 && SPT_PROB(30, seconds_per_tick))
			human_in_range.emote(pick("giggle", "laugh"))
			human_in_range.adjustHalLoss(10)

		if(SPT_PROB(25, seconds_per_tick))
			human_in_range.make_dizzy(min(human_in_range.dizziness + 10 SECONDS, 10 SECONDS))

/*
1) 7 предметов греха
2) Плащ пустоты
3) Пояс тени и плащ тьмы
4) Твики камней душ
5) Борги-культисты
6) Исследование "Руны Возвышенного"
7) Исследование "Оковы тома"
8) Балун алерты
9) Разломы: временные и постоянные
10) Автодок-по-культовски
11) Более красивое отображение иконок в изучении, добавление иконок
12) Скелеты более не теряют гроин
13) При жертвах даётся постоянная генерация, а не временная
14) Руна изганания еретиков из рая
15) Исправление безномерного телепорта
16) Капканы. Исправлены баги, изменена логика, добавлен урон, добавлены баги.
17) Шивы аля заточки айтем стейты добавлены
18) ЕРТ-реверы получили защиту от флешбенгов, имеют тем больший шанс быть вызванными, чем больше глав живо
19) Остовые аварийных створок теперь разрушаемы
20) Значительно переработана логика голокарт. Новые баги!
21) Святая вода действует аналогично проклятой, но на культистов. Может деконвертнуть культиста, даже если есть защита, но гораздо дольше
22) Опции исследования чуть красивее
23) Маска безумия

16) Продвинутая логика у сакрифисов
17) Голомапу культям
18) Абилки лидеру культа
19) Культ меню
20) Коррапт алтаря
21) Спавнер гомункулов
22) Рун карвер
23) Инквизиторы. Космоморпех, инквизиторский риг, пояс медика-инквизитора, генератор поля, святые гранаты, а также...ОГНЕМЁТЫ
*/
