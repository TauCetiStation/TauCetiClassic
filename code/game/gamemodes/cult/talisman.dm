/obj/item/weapon/paper/talisman
	icon_state = "scrap_bloodied"
	var/datum/cult/power

/obj/item/weapon/paper/talisman/attack_self(mob/living/user)
	if(!iscultist(user))
		user.examinate(src)
		return
	if(istype(power, /datum/cult/stun))
		to_chat(user, "<span class='userdanger'> To use this talisman, attack your target directly.</span>")
		return
	user.adjustBruteLoss(5)
	if(power)
		power.action(user)
/obj/item/weapon/paper/talisman/examine(mob/user)
	..()
	if(iscultist(user) && power)
		to_chat(user, "A spell circle drawn in blood. It reads: <i>[power.word1] [power.word2] [power.word3]</i>.")

/obj/item/weapon/paper/talisman/attack(mob/living/T, mob/living/user)
	if(iscultist(user))
		if(istype(power, /datum/cult/stun))
			user.adjustBruteLoss(5)
			power.talisman_reaction(user, T)
			return
		else if(istype(power, /datum/cult/armor) && ishuman(T) && iscultist(T))
			power.action(T)
	return ..()

/obj/item/weapon/paper/talisman/supply
	var/uses = 5

/obj/item/weapon/paper/talisman/supply/weak
	uses = 2

/obj/item/weapon/paper/talisman/supply/attack_self(mob/living/user)
	if(!iscultist(user))
		user.examinate(src)
		return
	if (!uses)
		qdel(src)
		return
	var/dat = "<B>There are [uses] bloody runes on the parchment.</B><BR>"
	dat += "Please choose the chant to be imbued into the fabric of reality.<BR>"
	dat += "<HR>"
	dat += "<A href='?src=\ref[src];rune=newtome'>N'ath reth sh'yro eth d'raggathnor!</A> - Allows you to summon a new arcane tome.<BR>"
	dat += "<A href='?src=\ref[src];rune=teleport'>Sas'so c'arta forbici!</A> - Allows you to move to a rune with the same last word.<BR>"
	dat += "<A href='?src=\ref[src];rune=emp'>Ta'gh fara'qha fel d'amar det!</A> - Allows you to destroy technology in a short range.<BR>"
	dat += "<A href='?src=\ref[src];rune=conceal'>Kla'atu barada nikt'o!</A> - Allows you to conceal the runes you placed on the floor.<BR>"
	dat += "<A href='?src=\ref[src];rune=communicate'>O bidai nabora se'sma!</A> - Allows you to coordinate with others of your cult.<BR>"
	dat += "<A href='?src=\ref[src];rune=runestun'>Fuu ma'jin</A> - Allows you to stun a person by attacking them with the talisman.<BR>"
	dat += "<A href='?src=\ref[src];rune=armor'>Sa tatha najin</A> - Allows you to summon armoured robes and an unholy blade<BR>"
	dat += "<A href='?src=\ref[src];rune=soulstone'>Kal om neth</A> - Summons a soul stone<BR>"
	dat += "<A href='?src=\ref[src];rune=construct'>Da A'ig Osk</A> - Summons a construct shell for use with captured souls. It is too large to carry on your person.<BR>"

	var/datum/browser/popup = new(user, "window=id_com", nwidth = 350, nheight = 200, ntheme = CSS_THEME_DARK)
	popup.set_content(dat)
	popup.open()

/obj/item/weapon/paper/talisman/supply/Topic(href, href_list)
	if (!src || usr.incapacitated() || !iscultist(usr) || !in_range(src, usr))
		return
	if(!uses)
		qdel(src)
		return
	if (href_list["rune"])
		switch(href_list["rune"])
			if("newtome")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.power = new /datum/cult/tome_summon(T)
			if("teleport")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.power = new /datum/cult/teleport(T)
				T.power.word3 = "[pick(cultwords)]"
			if("emp")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.power = new /datum/cult/emp(T)
			if("conceal")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.power = new /datum/cult/obscure(T)
			if("communicate")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.power = new /datum/cult/communicate(T)
			if("runestun")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.power = new /datum/cult/stun(T)
			if("armor")
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(get_turf(usr))
				T.power = new /datum/cult/armor(T)
			if("soulstone")
				new /obj/item/device/soulstone(get_turf(usr))
			if("construct")
				new /obj/structure/constructshell(get_turf(usr))
		uses--
		attack_self(usr)
	return