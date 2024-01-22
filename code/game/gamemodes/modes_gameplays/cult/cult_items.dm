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
	body_parts_covered = HEAD|EYES|BLOCKHAIR
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
	flags = HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
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
