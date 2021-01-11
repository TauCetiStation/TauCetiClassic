/obj/item/device/soulstone
	name = "Soul Stone Shard"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	item_state = "electronic"
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'. The shard still flickers with a fraction of the full artefacts power."
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = "bluespace=4;materials=4"
	var/imprinted = "empty"

	var/static/class_images
	var/list/classes = list(
				"Juggernaut" = /mob/living/simple_animal/construct/armoured,
				"Wraith" = /mob/living/simple_animal/construct/wraith,
				"Artificer" = /mob/living/simple_animal/construct/builder,
				)

/obj/item/device/soulstone/proc/gen_images()
	class_images = list()

	for(var/name in classes)
		var/atom/A = classes[name]
		class_images[name] = image(icon = initial(A.icon), icon_state = initial(A.icon_state))

//////////////////////////////Capturing////////////////////////////////////////////////////////

/obj/item/device/soulstone/attack(mob/living/carbon/human/M, mob/user)
	if(!istype(M, /mob/living/carbon/human))//If target is not a human.
		return ..()
	if(istype(M, /mob/living/carbon/human/dummy))
		return..()

	if(M.has_brain_worms()) //Borer stuff - RR
		to_chat(user, "<span class='warning'>This being is corrupted by an alien intelligence and cannot be soul trapped.</span>")
		return..()

	M.log_combat(user, "soul-captured via [name]")

	transfer_soul("VICTIM", M, user)
	return

///////////////////Options for using captured souls///////////////////////////////////////

/obj/item/device/soulstone/attack_self(mob/user)
	if (!in_range(src, user))
		return
	user.set_machine(src)
	var/dat = ""
	for(var/mob/living/simple_animal/shade/A in src)
		dat += "Captured Soul: [A.name]<br>"
		dat += {"<A href='byond://?src=\ref[src];choice=Summon'>Summon Shade</A>"}

	var/datum/browser/popup = new(user, "window=aicard", "Soul Stone", ntheme = CSS_THEME_LIGHT)
	popup.set_content(dat)
	popup.open()

/obj/item/device/soulstone/Topic(href, href_list)
	var/mob/user = usr
	if (!in_range(src, user)||user.machine!=src)
		user << browse(null, "window=aicard")
		user.unset_machine()
		return

	add_fingerprint(user)
	user.set_machine(src)

	if(href_list["choice"] == "Summon")
		for(var/mob/living/simple_animal/shade/A in src)
			A.status_flags &= ~GODMODE
			A.canmove = 1
			to_chat(A, "<b>You have been released from your prison, but you are still bound to [user.name]'s and his allies will. Help them suceed in their goals at all costs.</b>")
			A.loc = user.loc
			A.cancel_camera()
			src.icon_state = "soulstone"
	attack_self(user)

////////////////////////////Proc for moving soul in and out off stone//////////////////////////////////////

/obj/item/device/soulstone/proc/transfer_soul(choice, target, mob/user)
	switch(choice)
		if("VICTIM")
			capture_victim(target, user)
		if("SHADE")
			capture_shade(target, user)
		if("CONSTRUCT")
			if(!class_images)
				gen_images()
			create_construct(target, user)

/obj/item/device/soulstone/proc/capture_victim(target, mob/user)
	var/mob/living/carbon/human/T = target
	var/obj/item/device/soulstone/C = src
	if(target != user)
		if(C.imprinted != "empty")
			to_chat(user, "<span class='warning'><b>Capture failed!</b>:</span> The soul stone has already been imprinted with [C.imprinted]'s mind!")
			return
		if(T.stat == CONSCIOUS)
			to_chat(user, "<span class='warning'><b>Capture failed!</b>:</span> Kill or maim the victim first!")
			return
		if(T.client == null)
			to_chat(user, "<span class='warning'><b>Capture failed!</b>:</span> The soul has already fled it's mortal frame.")
			return
		if(C.contents.len)
			to_chat(user, "<span class='warning'><b>Capture failed!</b>:</span> The soul stone is full! Use or free an existing soul to make room.")
			return

	for(var/obj/item/W in T)
		T.drop_from_inventory(W)

	new /obj/effect/decal/remains/human(T.loc) //Spawns a skeleton
	T.invisibility = 101
	var/atom/movable/overlay/animation = new /atom/movable/overlay( T.loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = T
	flick("dust-h", animation)
	qdel(animation)
	var/mob/living/simple_animal/shade/S = new /mob/living/simple_animal/shade( T.loc )
	S.my_religion = T.my_religion
	S.loc = C //put shade in stone
	S.status_flags |= GODMODE //So they won't die inside the stone somehow
	S.canmove = 0//Can't move out of the soul stone
	S.name = "Shade of [T.real_name]"
	S.real_name = "Shade of [T.real_name]"
	if (T.client)
		T.client.mob = S
	S.cancel_camera()
	C.icon_state = "soulstone_glow_blink"
	C.name = "Soul Stone: [S.real_name]"
	to_chat(S, "Your soul has been captured! You are now bound to [user.name]'s and his allies will, help them suceed in their goals at all costs.")
	to_chat(user, "<span class='notice'><b>Capture successful!</b>:</span> [T.real_name]'s soul has been ripped from their body and stored within the soul stone.")
	to_chat(user, "The soulstone has been imprinted with [S.real_name]'s mind, it will no longer react to other souls.")
	C.imprinted = "[S.name]"
	qdel(T)

/obj/item/device/soulstone/proc/capture_shade(target, mob/user)
	var/mob/living/simple_animal/shade/T = target
	var/obj/item/device/soulstone/C = src
	if(T.stat == DEAD)
		to_chat(user, "<span class='warning'><b>Capture failed!</b>:</span> The shade has already been banished!")
		return
	if(C.contents.len)
		to_chat(user, "<span class='warning'><b>Capture failed!</b>:</span> The soul stone is full! Use or free an existing soul to make room.")
		return
	if(T.name != C.imprinted)
		to_chat(user, "<span class='warning'><b>Capture failed!</b>:</span> The soul stone has already been imprinted with [C.imprinted]'s mind!")
		return

	T.loc = C //put shade in stone
	T.status_flags |= GODMODE
	T.canmove = 0
	T.health = T.maxHealth
	C.icon_state = "soulstone_glow_blink"
	to_chat(T, "Your soul has been recaptured by the soul stone, its arcane energies are reknitting your ethereal form")
	to_chat(user, "<span class='notice'><b>Capture successful!</b>:</span> [T.name]'s has been recaptured and stored within the soul stone.")

/obj/item/device/soulstone/proc/create_construct(atom/target, mob/user)
	var/mob/living/simple_animal/shade/A = locate() in src
	if(!A)
		to_chat(user, "<span class='warning'><b>Creation failed!</b>:</span> The soul stone is empty! Go kill someone!")
		return

	var/construct_class = show_radial_menu(user, target, class_images, require_near = TRUE, tooltips = TRUE)

	var/type = classes[construct_class]
	var/mob/M = new type(get_turf(target.loc))
	M.key = A.key
	A.cancel_camera()

	if(iscultist(user))
		SSticker.mode.add_cultist(M.mind)

	qdel(src)
	qdel(target)

	to_chat(M, "<span class='[user.my_religion ? user.my_religion.style_text : "cult"]'>Вы обязаны служить своему создателю и его союзникам, следовать их приказам и помогать им достичь своих целей любой ценой.</span>")

///////////////////////////Transferring to constructs/////////////////////////////////////////////////////
/obj/structure/constructshell
	name = "empty shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive."

/obj/structure/constructshell/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/device/soulstone))
		var/obj/item/device/soulstone/S = O
		S.transfer_soul("CONSTRUCT",src,user)
