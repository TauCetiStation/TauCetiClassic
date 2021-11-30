#define SOULSTONE_VICTIM    "victim"
#define SOULSTONE_CONSTRUCT "construct"
#define SOULSTONE_SHADE     "shade"

/obj/item/device/soulstone
	name = "Soul Stone Shard"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	item_state = "electronic"
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'. The shard still flickers with a fraction of the full artefacts power."
	w_class = SIZE_MINUSCULE
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = "bluespace=4;materials=4"
	var/imprinted

	var/static/class_images
	var/list/classes = list(
				"Juggernaut" = /mob/living/simple_animal/construct/armoured,
				"Wraith" = /mob/living/simple_animal/construct/wraith,
				"Artificer" = /mob/living/simple_animal/construct/builder,
				"Proteon" = /mob/living/simple_animal/construct/proteon,
				)

/obj/item/device/soulstone/proc/gen_images()
	class_images = list()

	for(var/name in classes)
		var/atom/A = classes[name]
		class_images[name] = image(icon = initial(A.icon), icon_state = initial(A.icon_state))

//////////////////////////////Capturing////////////////////////////////////////////////////////

/obj/item/device/soulstone/attack(mob/living/carbon/human/H, mob/user)
	if(!istype(H, /mob/living/carbon/human))//If target is not a human.
		return ..()

	if(H.has_brain_worms()) //Borer stuff - RR
		to_chat(user, "<span class='warning'>Разум этого существа сопротивляется силе камня.</span>")
		return ..()

	H.log_combat(user, "soul-captured via [name]")

	transfer_soul(SOULSTONE_VICTIM, H, user)
	return

///////////////////Options for using captured souls///////////////////////////////////////

/obj/item/device/soulstone/attack_self(mob/user)
	if(!Adjacent(user))
		return

	user.set_machine(src)
	var/dat = ""
	for(var/mob/living/simple_animal/shade/A in src)
		dat += "Захваченная душа: [A.name]<br>"
		dat += {"<A href='byond://?src=\ref[src];choice=Summon'>Призвать Тень</A>"}

	var/datum/browser/popup = new(user, "window=aicard", "Камень Душ", ntheme = CSS_THEME_LIGHT)
	popup.set_content(dat)
	popup.open()

/obj/item/device/soulstone/Topic(href, href_list)
	var/mob/user = usr
	if(!Adjacent(user) || user.machine != src)
		user << browse(null, "window=aicard")
		user.unset_machine()
		return

	add_fingerprint(user)
	user.set_machine(src)

	if(href_list["choice"] == "Summon")
		for(var/mob/living/simple_animal/shade/A in src)
			A.status_flags &= ~GODMODE
			A.canmove = 1
			to_chat(A, "<b>Вы были освобождены из своей тюрьмы, но вы остаётесь привязанным к [user.name] и его союзникам. Помогайте им добиться их целей любой ценой.</b>")
			A.loc = user.loc
			A.cancel_camera()
			src.icon_state = "soulstone"
	attack_self(user)

////////////////////////////Proc for moving soul in and out off stone//////////////////////////////////////

/obj/item/device/soulstone/proc/transfer_soul(choice, target, mob/user)
	switch(choice)
		if(SOULSTONE_VICTIM)
			capture_victim(target, user)
		if(SOULSTONE_SHADE)
			capture_shade(target, user)
		if(SOULSTONE_CONSTRUCT)
			if(!class_images)
				gen_images()
			create_construct(target, user)

/obj/item/device/soulstone/proc/capture_victim(target, mob/user)
	var/mob/living/carbon/human/H = target
	var/obj/item/device/soulstone/C = src
	if(target != user)
		if(C.imprinted)
			to_chat(user, "<span class='warning'><b>Захват не удался!</b>:</span> В камне душ уже запечатана душа [C.imprinted]!")
			return
		if(H.stat == CONSCIOUS)
			to_chat(user, "<span class='warning'><b>Захват не удался!</b>:</span> Сначала убейте или оглушите жертву!")
			return
		if(H.client == null)
			to_chat(user, "<span class='warning'><b>Захват не удался!</b>:</span> В этой оболочке нет души.")
			return
		if(C.contents.len)
			to_chat(user, "<span class='warning'><b>Захват не удался!</b>:</span> Камень душ полон! Используйте или освободите душу внутри камня.")
			return
		if(H.species.flags[IS_SYNTHETIC])
			to_chat(user, "<span class='warning'><b>Захват не удался!</b>:</span> Неподходящая цель.")
			return

	for(var/obj/item/W in H)
		H.drop_from_inventory(W)

	new /obj/effect/decal/remains/human(H.loc) //Spawns a skeleton
	H.invisibility = INVISIBILITY_ABSTRACT
	new /obj/effect/temp_visual/dust_animation(H.loc, "dust-h")

	var/mob/living/simple_animal/shade/S = new /mob/living/simple_animal/shade( H.loc )
	S.my_religion = H.my_religion
	S.forceMove(C)
	S.status_flags |= GODMODE //So they won't die inside the stone somehow
	S.canmove = FALSE //Can't move out of the soul stone
	S.name = "Shade of [H.real_name]"
	S.real_name = "Shade of [H.real_name]"
	if(H.client)
		H.client.mob = S
	S.cancel_camera()
	C.icon_state = "soulstone_glow_blink"
	C.name = "Soul Stone: [S.real_name]"
	to_chat(S, "Ваша душа была захвачена! Теперь вы привязаны к [user.name] и его союзникам. Помогайте им добиться их целей любой ценой..")
	to_chat(user, "<span class='notice'><b>Захват удался!</b>:</span> Душа [H.real_name] была вырвана из его тела и помещена в камень душ.")
	to_chat(user, "Камень душ запечатал разум [S.real_name], теперь вы не сможете захватить других душ.")
	C.imprinted = "[S.name]"
	H.gib()

/obj/item/device/soulstone/proc/capture_shade(target, mob/user)
	var/mob/living/simple_animal/shade/S = target
	var/obj/item/device/soulstone/stone = src
	if(S.stat == DEAD)
		to_chat(user, "<span class='warning'><b>Захват не удался!</b>:</span> Тень уже изгнана!")
		return
	if(stone.contents.len)
		to_chat(user, "<span class='warning'><b>Захват не удался!</b>:</span> Камень душ полон! Используйте или освободите душу внутри камня.")
		return
	if(S.name != stone.imprinted)
		to_chat(user, "<span class='warning'><b>Захват не удался!</b>:</span> В камне душ уже запечатана душа [stone.imprinted]!")
		return

	S.forceMove(stone) //put shade in stone
	S.status_flags |= GODMODE
	S.canmove = FALSE
	S.health = S.maxHealth
	stone.icon_state = "soulstone_glow_blink"
	to_chat(S, "Ваша душа была снова захвачена в камень душ, тайная энергия опять связывает твою эфирную форму.")
	to_chat(user, "<span class='notice'><b>Захват удался!</b>:</span> Душа [S.name] была снова захвачен в камень душ.")

/obj/item/device/soulstone/proc/create_construct(atom/target, mob/user)
	var/mob/living/simple_animal/shade/S = locate() in src
	if(!S)
		to_chat(user, "<span class='warning'><b>Создание не удалось!</b>:</span> Камень душ пуст! Самое время убить кого-нибудь.")
		return

	var/construct_class = show_radial_menu(user, target, class_images, require_near = TRUE, tooltips = TRUE)

	var/type = classes[construct_class]
	var/mob/living/simple_animal/construct/M = new type(get_turf(target))

	var/image/I = image(M.icon, M, "make_[M.icon_state]")
	flick_overlay_view(I, M, 10) // in fact, animation last 9.75
	playsound(M, 'sound/effects/constructform.ogg', VOL_EFFECTS_MASTER)

	M.key = S.key
	S.cancel_camera()

	if(isanyantag(user))
		for(var/role in user.mind.antag_roles)
			var/datum/role/R = user.mind.antag_roles[role]
			if(R.faction)
				add_faction_member(R.faction, M, TRUE)

	if(user.my_religion) // for cult and chaplain religion
		user.my_religion.add_member(M, CULT_ROLE_HIGHPRIEST)

	qdel(src)
	qdel(target)

	to_chat(M, "<span class='[user.my_religion ? user.my_religion.style_text : "cult"]'>Вы обязаны служить своему создателю и его союзникам, следовать их приказам и помогать им достичь своих целей любой ценой.</span>")

///////////////////////////Transferring to constructs/////////////////////////////////////////////////////
/obj/structure/constructshell
	name = "empty shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive."

/obj/structure/constructshell/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/device/soulstone))
		var/obj/item/device/soulstone/S = I
		S.transfer_soul(SOULSTONE_CONSTRUCT, src, user)
	return FALSE
