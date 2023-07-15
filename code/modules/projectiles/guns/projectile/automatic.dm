/obj/item/weapon/gun/projectile/automatic //Hopefully someone will find a way to make these fire in bursts or something. --Superxpdude
	name = "submachine gun"
	desc = "A lightweight, fast firing gun. Uses 9mm rounds."
	icon_state = "saber"
	item_state = null
	w_class = SIZE_SMALL
	origin_tech = "combat=4;materials=2"
	initial_mag = /obj/item/ammo_box/magazine/smg
	can_be_holstered = FALSE
	var/alarmed = FALSE
	var/should_alarm_when_empty = FALSE
	var/can_be_silenced = FALSE

/obj/item/weapon/gun/projectile/automatic/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"
	if(!item_state)
		item_state = "[initial(icon_state)]"
	cut_overlays()
	if(magazine && magazine.overlay)
		var/image/magazine_icon = image('icons/obj/gun.dmi', "[magazine.overlay]")
		add_overlay(magazine_icon)
	if(silenced)
		var/image/silencer_icon = image('icons/obj/gun_40x32.dmi', "[initial(icon_state)]-silencer")
		add_overlay(silencer_icon)

/obj/item/weapon/gun/projectile/automatic/attackby(obj/item/I, mob/user, params)
	if(..() && chambered)
		alarmed = FALSE

/obj/item/weapon/gun/projectile/automatic/afterattack(atom/target, mob/user, proximity, params)
	..()
	if(!chambered && !get_ammo() && !alarmed && should_alarm_when_empty)
		playsound(user, 'sound/weapons/guns/empty_alarm.ogg', VOL_EFFECTS_MASTER, 40)
		update_icon()
		alarmed = TRUE

/obj/item/weapon/gun/projectile/automatic/attack_hand(mob/user)
	if(loc == user && silenced && can_be_silenced && remove_silencer(user))
		return
	..()

/obj/item/weapon/gun/projectile/automatic/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/silencer))
		return install_silencer(I, user, params)
	return ..()

/obj/item/weapon/gun/projectile/automatic/mini_uzi
	name = "Mac-10"
	desc = "A lightweight, fast firing gun, for when you want someone dead. Uses 9mm rounds."
	icon_state = "mac"
	item_state = "mac"
	w_class = SIZE_SMALL
	can_be_holstered = TRUE
	origin_tech = "combat=5;materials=2;syndicate=8"
	initial_mag = /obj/item/ammo_box/magazine/mac10
	can_be_silenced = TRUE

/obj/item/weapon/gun/projectile/automatic/c20r
	name = "C-20r SMG"
	desc = "A lightweight, compact bullpup SMG. Uses .45 ACP rounds in medium-capacity magazines and has a threaded barrel for silencers. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon_state = "c20r"
	item_state = "c20r"
	w_class = SIZE_SMALL
	origin_tech = "combat=5;materials=2;syndicate=8"
	initial_mag = /obj/item/ammo_box/magazine/c20r
	suitable_mags = list(/obj/item/ammo_box/magazine/c20r, /obj/item/ammo_box/magazine/c20r/hp, /obj/item/ammo_box/magazine/c20r/hv, /obj/item/ammo_box/magazine/c20r/imp)
	fire_sound = 'sound/weapons/guns/gunshot_light.ogg'
	should_alarm_when_empty = TRUE
	can_be_silenced = TRUE

/obj/item/weapon/gun/projectile/automatic/l6_saw
	name = "L6 SAW"
	desc = "A heavily modified light machine gun with a tactical plasteel frame resting on a rather traditionally-made ballistic weapon. Has 'Aussec Armoury - 2531' engraved on the reciever, as well as '7.62x51mm'."
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	w_class = SIZE_BIG
	origin_tech = "combat=5;materials=1;syndicate=2"
	initial_mag = /obj/item/ammo_box/magazine/saw
	fire_sound = 'sound/weapons/guns/Gunshot2.ogg'
	has_cover = TRUE
	two_hand_weapon = ONLY_TWOHAND

/obj/item/weapon/gun/projectile/automatic/l6_saw/update_icon()
	icon_state = "l6[cover_open ? "open" : "closed"][magazine ? CEIL(get_ammo(0) / 12.5) * 25 : "-empty"]"
	item_state = "l6[cover_open ? "open" : "closed"][magazine ? "mag" : "nomag"]"

/obj/item/weapon/gun/projectile/automatic/l6_saw/afterattack(atom/target, mob/user, proximity, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(cover_open)
		to_chat(user, "<span class='notice'>[src]'s cover is open! Close it before firing!</span>")
	else
		..()
		update_icon()

/obj/item/weapon/gun/projectile/automatic/l6_saw/attack_hand(mob/user)
	if(loc != user)
		return ..()//let them pick it up
	if(user.get_inactive_hand() != src)
		return ..()//let them take it from inventory
	if(!cover_open)
		cover_open = !cover_open
		to_chat(user, "<span class='notice'>You open [src]'s cover.</span>")
		update_icon()
	else if(cover_open && magazine)
		//drop the mag
		magazine.update_icon()
		magazine.loc = get_turf(src.loc)
		user.put_in_hands(magazine)
		magazine = null
		update_icon()
		playsound(src, 'sound/weapons/guns/reload_mag_out.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You remove the magazine from [src].</span>")
	else
		if(chambered)
			playsound(src, bolt_slide_sound, VOL_EFFECTS_MASTER)
			process_chamber()


/obj/item/weapon/gun/projectile/automatic/l6_saw/attackby(obj/item/I, mob/user, params)
	if(!cover_open)
		to_chat(user, "<span class='notice'>[src]'s cover is closed! You can't insert a new mag!</span>")
		return
	return ..()

/obj/item/weapon/gun/projectile/automatic/l13
	name = "security submachine gun"
	desc = "L13 personal defense weapon - for combat security operations. Uses .38 ammo."
	icon_state = "l13"
	item_state = "l13"
	w_class = SIZE_SMALL
	origin_tech = "combat=4;materials=2"
	initial_mag = /obj/item/ammo_box/magazine/l13
	suitable_mags = list(/obj/item/ammo_box/magazine/l13, /obj/item/ammo_box/magazine/l13/lethal)
	fire_sound = 'sound/weapons/guns/gunshot_l13.ogg'
	can_be_silenced = TRUE

/obj/item/weapon/gun/projectile/automatic/tommygun
	name = "tommy gun"
	desc = "A genuine Chicago Typewriter."
	icon_state = "tommygun"
	item_state = "tommygun"
	w_class = SIZE_BIG
	two_hand_weapon = DESIRABLE_TWOHAND
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=2"
	initial_mag = /obj/item/ammo_box/magazine/tommygun
	fire_sound = 'sound/weapons/guns/gunshot_light.ogg'
	can_be_silenced = TRUE

/obj/item/weapon/gun/projectile/automatic/bar
	name = "Browning M1918"
	desc = "Browning Automatic Rifle."
	icon_state = "bar"
	item_state = "bar"
	w_class = SIZE_BIG
	two_hand_weapon = DESIRABLE_TWOHAND
	origin_tech = "combat=5;materials=2"
	initial_mag = /obj/item/ammo_box/magazine/bar
	fire_sound = 'sound/weapons/guns/Gunshot2.ogg'

/obj/item/weapon/gun/projectile/automatic/borg
	name = "Robot SMG"
	icon_state = "borg_smg"
	initial_mag = /obj/item/ammo_box/magazine/borg45
	fire_sound = 'sound/weapons/guns/gunshot_medium.ogg'

/obj/item/weapon/gun/projectile/automatic/borg/update_icon()
	return

/obj/item/weapon/gun/projectile/automatic/borg/attack_self(mob/user)
	if (magazine)
		magazine.loc = get_turf(src.loc)
		magazine.update_icon()
		magazine = null
		playsound(src, 'sound/weapons/guns/reload_mag_out.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You pull the magazine out of \the [src]!</span>")
	else
		to_chat(user, "<span class='notice'>There's no magazine in \the [src].</span>")
	return

/obj/item/weapon/gun/projectile/automatic/bulldog
	name = "V15 Bulldog shotgun"
	desc = "A compact, mag-fed semi-automatic shotgun for combat in narrow corridors. Compatible only with specialized magazines."
	icon_state = "bulldog"
	item_state = "bulldog"
	w_class = SIZE_SMALL
	origin_tech = "combat=5;materials=4;syndicate=6"
	initial_mag = /obj/item/ammo_box/magazine/bulldog
	fire_sound = 'sound/weapons/guns/gunshot_shotgun.ogg'
	suitable_mags = list(/obj/item/ammo_box/magazine/bulldog, /obj/item/ammo_box/magazine/bulldog/stun, /obj/item/ammo_box/magazine/bulldog/incendiary)
	should_alarm_when_empty = TRUE

/obj/item/weapon/gun/projectile/automatic/a28
	name = "A28 assault rifle"
	desc = ""
	icon_state = "a28"
	item_state = "a28"
	w_class = SIZE_SMALL
	two_hand_weapon = DESIRABLE_TWOHAND
	origin_tech = "combat=5;materials=4;syndicate=6"
	initial_mag = /obj/item/ammo_box/magazine/a28
	suitable_mags = list(/obj/item/ammo_box/magazine/a28, /obj/item/ammo_box/magazine/a28/nonlethal, /obj/item/ammo_box/magazine/a28/incendiary)
	fire_sound = 'sound/weapons/guns/gunshot_medium.ogg'

/obj/item/weapon/gun/projectile/automatic/a74
	name = "A74 assault rifle"
	desc = "Stradi and Practican Maid Bai Spess soviets corporation, bazed he original design of 20 centuriyu fin about baars and vodka vile patrimonial it, saunds of balalaika place minvile, yuzes 7.74 caliber"
	initial_mag = /obj/item/ammo_box/magazine/a74
	suitable_mags = list(/obj/item/ammo_box/magazine/a74, /obj/item/ammo_box/magazine/a74/krinkov)
	w_class = SIZE_SMALL
	two_hand_weapon = DESIRABLE_TWOHAND
	icon_state = "a74"
	item_state = "a74"
	origin_tech = "combat=5;materials=4;syndicate=6"
	fire_sound = 'sound/weapons/guns/gunshot_ak74.ogg'

/obj/item/weapon/gun/projectile/automatic/a74/krinkov
	name = "Krinkov"
	desc = "Small and deadly, A74U is lighter than it's older brother, but nontheless packs a serious punch."
	initial_mag = /obj/item/ammo_box/magazine/a74/krinkov
	recoil = 1.5
	two_hand_weapon = FALSE
	icon_state = "krinkov"
	item_state = "krinkov"

/obj/item/weapon/gun/projectile/automatic/drozd
	name = "OTs-114 assault rifle"
	desc = "Also known as Drozd, this little son a of bitch comes equipped with a bloody grenade launcher! How cool is that?"
	icon_state = "drozd"
	item_state = "drozd"
	initial_mag = /obj/item/ammo_box/magazine/drozd
	w_class = SIZE_SMALL
	two_hand_weapon = DESIRABLE_TWOHAND
	fire_sound = 'sound/weapons/guns/gunshot_drozd.ogg'
	fire_delay = 7
	var/using_gl = FALSE
	var/obj/item/weapon/gun/projectile/grenade_launcher/underslung/gl
	item_action_types = list(/datum/action/item_action/hands_free/toggle_gl)

/datum/action/item_action/hands_free/toggle_gl
	name = "Toggle GL"

/datum/action/item_action/hands_free/toggle_gl/Activate()
	var/obj/item/weapon/gun/projectile/automatic/drozd/S = target
	S.toggle_gl(usr)

/obj/item/weapon/gun/projectile/automatic/drozd/examine(mob/user)
	. = ..()
	to_chat(user, "It's [gl.name] is [gl.get_ammo() ? "loaded" : "unloaded"].")

/obj/item/weapon/gun/projectile/automatic/drozd/proc/toggle_gl(mob/user)
	using_gl = !using_gl
	if(using_gl)
		user.visible_message("<span class='warning'>[user] flicks a little switch, activating their [gl]!</span>",\
		"<span class='warning'>You activate your [gl].</span>",\
		"You hear an ominous click.")
	else
		user.visible_message("<span class='notice'>[user] flicks a little switch, deciding to stop the bombings.</span>",\
		"<span class='notice'>You deactivate your [gl].</span>",\
		"You hear a click.")
	playsound(src, 'sound/weapons/guns/empty.ogg', VOL_EFFECTS_MASTER)
	update_icon()

/obj/item/weapon/gun/projectile/automatic/drozd/atom_init()
	. = ..()
	gl = new (src)

/obj/item/weapon/gun/projectile/automatic/drozd/update_icon()
	..()
	if(using_gl)
		var/image/gl = image('icons/obj/gun.dmi', "drozd-gl")
		add_overlay(gl)

/obj/item/weapon/gun/projectile/automatic/drozd/afterattack(atom/target, mob/user, proximity, params)
	if(!using_gl)
		return ..()
	gl.afterattack(target, user, proximity, params)

/obj/item/weapon/gun/projectile/automatic/drozd/attackby(obj/item/I, mob/user, params)
	if(!using_gl)
		return ..()
	gl.attackby(I, user)

/obj/item/weapon/gun/projectile/automatic/drozd/attack_self(mob/user)
	if(!using_gl)
		return ..()
	gl.attack_self(user)

