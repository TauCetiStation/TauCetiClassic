/obj/item/weapon/melee/cultblade
	name = "Cult Blade"
	desc = "An arcane weapon wielded by the followers of Nar-Sie."
	icon_state = "cultblade"
	item_state = "cultblade"
	w_class = 4
	force = 30
	throwforce = 10
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'


/obj/item/weapon/melee/cultblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(!iscultist(user))
		user.Paralyse(5)
		to_chat(user, "<span class='cult'>An unexplicable force powerfully repels the sword from [target]!</span>")
		var/organ = ((user.hand ? "l_":"r_") + "arm")
		var/datum/organ/external/affecting = user.get_organ(organ)
		affecting.take_damage(rand(force/2, force)) //random amount of damage between half of the blade's force and the full force of the blade.
		return
	return ..(target, user)

/obj/item/weapon/melee/cultblade/pickup(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='cult'> An overwhelming feeling of dread comes over you as you pick up the cultist's sword. It would be wise to be rid of this blade quickly.</span>")
		user.make_dizzy(120)

/obj/item/weapon/legcuffs/bola/cult
	name = "nar'sien bola"
	desc = "A strong bola, bound with dark magic. Throw it to trip and slow your victim."
	icon_state = "bola_cult"
	breakouttime = 45

/obj/item/weapon/legcuffs/bola/cult/throw_impact(atom/hit_atom)
	if(ismob(hit_atom))
		var/mob/M = hit_atom
		if(iscultist(M))
			return
	return ..(hit_atom)

/obj/item/clothing/head/culthood
	name = "cult hood"
	icon_state = "culthood"
	desc = "A hood worn by the followers of Nar-Sie."
	flags_inv = HIDEFACE
	flags = HEADCOVERSEYES
	body_parts_covered = HEAD|EYES
	armor = list(melee = 50, bullet = 45, laser = 40,energy = 5, bomb = 30, bio = 50, rad = 20)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0


/obj/item/clothing/head/culthood/alt
	icon_state = "cult_hoodalt"
	item_state = "cult_hoodalt"

/obj/item/clothing/suit/hooded/cultrobes/alt
	icon_state = "cultrobesalt"
	item_state = "cultrobesalt"
	hoodtype = /obj/item/clothing/head/culthood/alt

/obj/item/clothing/suit/hooded/cultrobes
	name = "cult robes"
	desc = "A set of armored robes worn by the followers of Nar-Sie."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS
	allowed = list(/obj/item/weapon/book/tome,/obj/item/weapon/melee/cultblade)
	armor = list(melee = 50, bullet = 50, laser = 45,energy = 5, bomb = 30, bio = 50, rad = 20)
	flags_inv = HIDEJUMPSUIT
	siemens_coefficient = 0
	hoodtype = /obj/item/clothing/head/culthood

/obj/item/clothing/suit/hooded/cultrobes/attack_hand(mob/living/user)
	if(!iscultist(user))
		to_chat(user,"<span class='cult'>\"Trying to use things you don't own is bad, you know.\"</span>",
		"<span class='cult'>The armor squeezes at your body!</span>")
		user.emote("scream")
		user.adjustBruteLoss(25)
		return
	return..()

/obj/item/clothing/suit/hooded/cultrobes/mob_can_equip(M, slot, disable_warning = 0)
	if(!..())
		return 0
	if(iscultist(M))
		return 1
	else
		return 0

/obj/item/clothing/suit/hooded/cultrobes/cult_shield
	name = "empowered cultist armor"
	desc = "Empowered garb which creates a powerful shield around the user."
	icon_state = "shielded_armor"
	item_state = "shielded_armor"
	w_class = 4
	armor = list(melee = 60, bullet = 60, laser = 60,energy = 30, bomb = 50, bio = 30, rad = 30)
	var/current_charges = 3
	var/image/shield
	hoodtype = /obj/item/clothing/head/culthood/crown

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/New()
	..()
	shield = image("icon"='icons/effects/effects.dmi', "icon_state"="shield-cult", "layer" = (LIGHTING_LAYER + 1))
	shield.plane = LIGHTING_PLANE + 1

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/equipped(mob/living/carbon/human/user)
	..()
	if(user.wear_suit == src && current_charges)
		user.overlays |= shield
	else
		user.overlays -= shield

/obj/item/clothing/suit/hooded/cultrobes/cult_shield/Get_shield_chance()
	if(current_charges)
		var/mob/living/carbon/human/H = loc
		current_charges--
		new /obj/effect/overlay/cult/sparks (get_turf(H))
		if(!current_charges)
			H.visible_message("<span class='danger'>The runed shield around [H] suddenly disappears!</span>")
			H.overlays -= shield
		return 120
	else
		return 0

/obj/item/clothing/head/culthood/crown
	name = "Burning Crown"
	icon_state = "shielded_hat"
	item_state = "shielded_hat"
	armor = list(melee = 60, bullet = 60, laser = 60,energy = 30, bomb = 50, bio = 30, rad = 30)
	flags = HEADCOVERSEYES | BLOCKHAIR | HEADCOVERSMOUTH

/obj/item/clothing/suit/hooded/cultrobes/berserker
	name = "flagellant's robes"
	desc = "Blood-soaked robes infused with dark magic; allows the user to move at inhuman speeds, but at the cost of increased damage."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	armor = list(melee = -50, bullet = -50, laser = -100,energy = -50, bomb = -50, bio = -50, rad = -50)
	slowdown = -1.5
	hoodtype = /obj/item/clothing/head/culthood/berserkerhood

/obj/item/clothing/head/culthood/berserkerhood
	name = "flagellant's robes"
	desc = "Blood-soaked garb infused with dark magic; allows the user to move at inhuman speeds, but at the cost of increased damage."
	icon_state = "culthood"
	armor = list(melee = -50, bullet = -50, laser = -50, energy = -50, bomb = -50, bio = -50, rad = -50)
	slowdown = -0.5

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
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/weapon/book/tome,/obj/item/weapon/melee/cultblade)
	armor = list(melee = 50, bullet = 15, laser = 25,energy = 20, bomb = 25, bio = 10, rad = 0)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	siemens_coefficient = 0

/obj/item/clothing/head/helmet/space/cult
	name = "cult helmet"
	desc = "A space worthy helmet used by the followers of Nar-Sie."
	icon_state = "cult_helmet"
	item_state = "cult_helmet"
	armor = list(melee = 60, bullet = 35, laser = 45,energy = 15, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0


/obj/item/clothing/suit/space/cult
	name = "cult armour"
	icon_state = "cult_armour"
	item_state = "cult_armour"
	desc = "A bulky suit of armour, bristling with spikes. It looks space proof."
	w_class = 3
	allowed = list(/obj/item/weapon/book/tome,/obj/item/weapon/melee/cultblade,/obj/item/weapon/tank/emergency_oxygen,/obj/item/device/suit_cooling_unit)
	slowdown = 1.5
	armor = list(melee = 60, bullet = 35, laser = 45,energy = 15, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS

/obj/item/clothing/glasses/cultblind
	desc = "May nar-sie guide you through the darkness and shield you from the light."
	name = "zealot's blindfold"
	icon_state = "blindfold"
	item_state = "blindfold"
	darkness_view = 8
	flash_protection = 1

/obj/item/clothing/glasses/cultblind/attack_hand(mob/user)
	if(!iscultist(user))
		to_chat(user,"<span class='userdanger'>\"You want to be blind, do you?\"</span>")
		user.make_dizzy(30)
		user.Weaken(5)
		user.eye_blurry += 30
		return
	return ..()

/obj/item/weapon/reagent_containers/food/drinks/bottle/unholywater
	name = "flask of unholy water"
	desc = "Toxic to nonbelievers; this water renews and reinvigorates the faithful of nar'sie."
	icon_state = "holyflask"
	color = "#333333"

/obj/item/weapon/reagent_containers/food/drinks/bottle/unholywater/New()
	..()
	reagents.add_reagent("unholywater", 100)

/obj/item/device/cult_shift
	name = "veil shifter"
	desc = "This relic teleports you forward a medium distance."
	icon_state ="shifter"
	var/uses = 4

/obj/item/device/cult_shift/examine(mob/user)
	..()
	if(uses)
		to_chat(user,"<span class='cult'>It has [uses] uses remaining.</span>")
	else
		to_chat(user,"<span class='cult'>It seems drained.</span>")

/obj/item/device/cult_shift/proc/handle_teleport_grab(turf/T, mob/living/user)
	if(istype(user.get_active_hand(),/obj/item/weapon/grab)).
		var/obj/item/weapon/grab/G = user.get_active_hand()
		G.affecting.forceMove(T)
	if(istype(user.get_inactive_hand(),/obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = user.get_inactive_hand()
		G.affecting.forceMove(T)
	return

/obj/item/device/cult_shift/attack_self(mob/user)
	if(!uses || !iscarbon(user))
		to_chat(user,"<span class='warning'>\The [src] is dull and unmoving in your hands.</span>")
		return
	if(!iscultist(user))
		user.unEquip(src, 1)
		step(src, pick(alldirs))
		to_chat(user,"<span class='warning'>\The [src] flickers out of your hands, your connection to this dimension is too strong!</span>")
		return

	var/mob/living/carbon/C = user
	var/turf/mobloc = get_turf(C)
	var/turf/destination = get_teleport_loc(mobloc,C,9,1,3,1,0,1)

	if(destination)
		uses--
		if(uses <= 0)
			icon_state ="shifter_drained"
		playsound(mobloc, "sparks", 50, 1)
		new /obj/effect/overlay/cult/phase/out(mobloc, C.dir)
		C.forceMove(destination)
		handle_teleport_grab(destination, C)

		new /obj/effect/overlay/cult/phase(destination, C.dir)
		playsound(destination, 'sound/effects/phasein.ogg', 25, 1)
		playsound(destination, "sparks", 50, 1)

	else
		to_chat(C,"<span class='danger'>The veil cannot be torn here!</span>")

/obj/item/device/flashlight/culttorch
	name = "void torch"
	desc = "Used by veteran cultists to instantly transport items to their needful bretheren."
	w_class = 2
	brightness_on = 4
	icon_state = "torch"
	item_state = "torch"
	color = "#ff0000"
	light_color = "#ff0000"
	slot_flags = null
	var/charges = 3

/obj/item/device/flashlight/culttorch/afterattack(atom/movable/A, mob/user, proximity)
	if(!proximity)
		return
	if(!iscultist(A))
		return

	if(istype(A, /obj/item))

		var/list/cultists = list()
		for(var/datum/mind/M in ticker.mode.cult)
			if(M.current != user && M.current.stat != DEAD && !isshade(M.current))
				cultists += M.current
		var/mob/living/cultist_to_receive = input(user, "Who do you wish to call to [src]?", "Followers of the Geometer") as null|anything in cultists
		if(!Adjacent(user) || user.incapacitated())
			return
		if(!cultist_to_receive)
			to_chat(user,"<span class='cult'>You require a destination!</span>")
			log_game("Void torch failed - no target")
			return
		if(cultist_to_receive.stat == DEAD)
			to_chat(user,"<span class='cult'>[cultist_to_receive] has died!</span>")
			log_game("Void torch failed  - target died")
			return
		if(!iscultist(cultist_to_receive))
			to_chat(user,"<span class='cult'>[cultist_to_receive] is not a follower of the Geometer!</span>")
			log_game("Void torch failed - target was deconverted")
			return
		to_chat(user,"<span class='cult'>You ignite [A] with \the [src], turning it to ash, but through the torch's flames you see that [A] has reached [cultist_to_receive]! \
		The [src] now has [charges] charge.")
		cultist_to_receive.put_in_hands(A)
		charges--
		if(charges == 0)
			qdel(src)

	else
		..()
		to_chat(user,"<span class='warning'>\The [src] can only transport items!</span>")
		return

/obj/item/device/shuttle_curse
	name = "cursed orb"
	desc = "You peer within this smokey orb and glimpse terrible fates befalling the escape shuttle."
	icon_state ="shuttlecurse"
	var/global/curselimit = 0
	var/cursetime = 180

/obj/item/device/shuttle_curse/attack_self(mob/user)
	if(!iscultist(user))
		user.unEquip(src, 1)
		user.Weaken(5)
		to_chat(user,"<span class='warning'>A powerful force shoves you away from [src]!</span>")
		return
	if(curselimit > 1)
		to_chat(user,"<span class='notice'>We have exhausted our ability to curse the shuttle.</span>")
		return
	SSshuttle.settimeleft(SSshuttle.timeleft() + cursetime)
	to_chat(user,"<span class='danger'>You shatter the orb! A dark essence spirals into the air, then disappears.</span>")
	playsound(user.loc, "sound/effects/Glassbr1.ogg", 50, 1)
	qdel(src)
	sleep(20)
	var/global/list/curses
	if(!curses)
		curses = list("A fuel technician just slit his own throat and begged for death. The shuttle will be delayed by three minutes.",
		"The shuttle's navigation programming was replaced by a file containing two words, IT COMES. The shuttle will be delayed by three minutes.",
		"The shuttle's custodian tore out his guts and began painting strange shapes on the floor. The shuttle will be delayed by three minutes.",
		"A shuttle engineer began screaming 'DEATH IS NOT THE END' and ripped out wires until an arc flash seared off her flesh. The shuttle will be delayed by three minutes.",
		"A shuttle inspector started laughing madly over the radio and then threw herself into an engine turbine. The shuttle will be delayed by three minutes.",
		"The shuttle dispatcher was found dead with bloody symbols carved into their flesh. The shuttle will be delayed by three minutes.")
	var/message = pick_n_take(curses)
	command_alert("System Failure","[message]")
	player_list << sound('sound/misc/notice1.ogg')
	curselimit++