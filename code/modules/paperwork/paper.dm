/*
 * Paper
 * also scraps of paper
 */

/obj/item/weapon/paper
	name = "paper"
	gender = PLURAL
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	throwforce = 0
	w_class = SIZE_MINUSCULE
	throw_range = 1
	throw_speed = 1
	layer = 3.9
	slot_flags = SLOT_FLAGS_HEAD
	body_parts_covered = HEAD
	attack_verb = list("bapped")

	var/info		//What's actually written on the paper.
	var/info_links	//A different version of the paper which includes html links at fields and EOF
	var/stamp_text		//The (text for the) stamp_text on the paper.
	var/fields		//Amount of user created fields
	var/sfields
	var/free_space = MAX_PAPER_MESSAGE_LEN
	var/list/stamped
	var/list/ico      //Icons and
	var/list/offset_x //offsets stored for later
	var/list/offset_y //usage by the photocopier
	var/rigged = 0
	var/spam_flag = FALSE
	var/crumpled = FALSE

	var/const/deffont = "Verdana"
	var/const/signfont = "Times New Roman"
	var/const/crayonfont = "Comic Sans MS"

	///"Cache" of maximum of 100 signatures on this paper
	var/list/signed_by
	///"Cache" of maximum of 100 stamp messages on this paper
	var/list/stamped_by
	///Last world.time tick the name of this paper was changed.
	var/last_name_change = 0
	///Last world.time tick the contents of this paper was changed.
	var/last_info_change = 0

//lipstick wiping is in code/game/objects/items/weapons/cosmetics.dm!

/obj/item/weapon/paper/atom_init()
	. = ..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
	stamp_text = ""

	update_icon()
	update_space(info)
	updateinfolinks()

/obj/item/weapon/paper/update_icon()
	if(info)
		icon_state = "paper_words"
		return
	icon_state = "paper"

/obj/item/weapon/paper/proc/update_space(new_text)
	if(!new_text)
		return

	free_space -= length(new_text)

/obj/item/weapon/paper/examine(mob/user)
	..()
	if(in_range(user, src) || isobserver(user))
		if(crumpled)
			to_chat(user, "<span class='notice'>You can't read anything until it crumpled.</span>")
			return
		show_content(user)
	else
		to_chat(user, "<span class='notice'>It is too far away to see anything.</span>")

/obj/item/weapon/paper/proc/show_content(mob/user, forceshow = FALSE, forcestars = FALSE, infolinks = FALSE, view = TRUE)
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/paper)
	assets.send(user)

	name = sanitize(name)
	var/data

	if((!(ishuman(user) || isobserver(user) || issilicon(user)) && !forceshow) || forcestars)
		data = "[stars(info)][stamp_text]"
	else
		data = "[infolinks ? info_links : info][stamp_text]"

	if(view)
		var/datum/browser/popup = new(user, "window=[name]", "[name]", 425, 600, ntheme = CSS_THEME_LIGHT)
		popup.set_content(data)
		popup.open()

	return data

/obj/item/weapon/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr


	if(usr.ClumsyProbabilityCheck(50))
		var/mob/living/carbon/human/H = usr
		if(istype(H) && !H.species.flags[NO_MINORCUTS])
			to_chat(usr, "<span class='warning'>You cut yourself on the paper.</span>")
		return
	var/n_name = sanitize_safe(input(usr, "What would you like to label the paper?", "Paper Labelling", null) as text, MAX_NAME_LEN)
	if((loc == usr && usr.stat == CONSCIOUS))
		name = "[(n_name ? text("[n_name]") : "paper")]"
	add_fingerprint(usr)

/obj/item/weapon/paper/verb/crumple()
	set name = "Crump paper"
	set category = "Object"
	set src in usr

	if(usr.ClumsyProbabilityCheck(50))
		var/mob/living/carbon/human/H = usr
		if(istype(H) && !H.species.flags[NO_MINORCUTS])
			to_chat(usr, "<span class='warning'>You cut yourself on the paper.</span>")
		return
	if(!crumpled)
		crumpled = TRUE
		icon_state = "crumpled"
		throw_range = 5
		cut_overlays()
	else
		icon_state = "scrap"
		throw_range = 1

	playsound(src, 'sound/items/crumple.ogg', VOL_EFFECTS_MASTER, 15)
	add_fingerprint(usr)

/obj/item/weapon/paper/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(istype(src, /obj/item/weapon/paper/talisman)) return
	if(istype(src, /obj/item/weapon/paper/crumpled/bloody)) return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(istype(target,/obj/effect/decal/cleanable/blood))
		qdel(src)
		var/obj/item/weapon/paper/CB = new /obj/item/weapon/paper/crumpled/bloody()
		user.put_in_hands(CB)

		if(!CB.blood_DNA)
			CB.blood_DNA = list()
		CB.blood_DNA |= target.blood_DNA.Copy()

	return

/obj/item/weapon/paper/attack_self(mob/living/user)
	examine(user)
	if(rigged && SSholiday.holidays[APRIL_FOOLS])
		if(!spam_flag)
			spam_flag = TRUE
			playsound(src, 'sound/items/bikehorn.ogg', VOL_EFFECTS_MASTER)
			VARSET_IN(src, spam_flag, FALSE, 20)

/obj/item/weapon/paper/attack_ai(mob/living/silicon/ai/user)
	var/dist
	if(istype(user) && user.camera) //is AI
		dist = get_dist(src, user.camera)
	else //cyborg or AI not seeing through a camera
		dist = get_dist(src, user)
	if(crumpled)
		return
	if(dist < 2)
		show_content(user, forceshow = TRUE)
	else
		show_content(user, forcestars = TRUE)
	return

/obj/item/weapon/paper/attack(mob/living/carbon/M, mob/living/carbon/user, def_zone)
	user.SetNextMove(CLICK_CD_MELEE)
	if(def_zone == O_EYES)
		user.visible_message("<span class='notice'> [user] holds up a paper and shows it to [M]. </span>", \
			"<span class='notice'>You show the paper to [M]. </span>")
		if(crumpled)
			to_chat(M, "<span class='notice'>You can't read anything until it crumpled.</span>")
			return
		show_content(M)
	else if(def_zone == O_MOUTH) // lipstick wiping
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H == user)
				to_chat(user, "<span class='notice'>You wipe off the lipstick with [src].</span>")
				H.lip_style = null
				H.update_body()
			else if(!user.is_busy())
				user.visible_message("<span class='warning'>[user] begins to wipe [H]'s lipstick off with \the [src].</span>", \
								 	 "<span class='notice'>You begin to wipe off [H]'s lipstick.</span>")
				if(do_after(user, 10, target = H))	//user needs to keep their active hand, H does not.
					user.visible_message("<span class='notice'>[user] wipes [H]'s lipstick off with \the [src].</span>", \
										 "<span class='notice'>You wipe off [H]'s lipstick.</span>")
					H.lip_style = null
					H.update_body()

/obj/item/weapon/paper/proc/addtofield(id, text, links = 0, type = "paper")
	var/locid = 0
	var/laststart = 1
	var/textindex = 1
	while(1) // I know this can cause infinite loops and fuck up the whole server, but the if(istart==0) should be safe as fuck
		var/istart = 0
		if(links)
			istart = findtext(info_links, "<span class=\"[type]_field\">", laststart)
		else
			istart = findtext(info, "<span class=\"[type]_field\">", laststart)

		if(istart==0)
			return // No field found with matching id

		laststart = istart+1
		locid++
		if(locid == id)
			var/iend = 1
			if(links)
				iend = findtext(info_links, "</span>", istart)
			else
				iend = findtext(info, "</span>", istart)

			//textindex = istart+26
			textindex = iend
			break

	if(links)
		var/before = copytext(info_links, 1, textindex)
		var/after = copytext(info_links, textindex)
		info_links = before + text + after
	else
		var/before = copytext(info, 1, textindex)
		var/after = copytext(info, textindex)
		info = before + text + after
		last_info_change = world.time
		updateinfolinks()

/obj/item/weapon/paper/proc/updateinfolinks()
	info_links = info
	var/i = 0
	for(i = 1, i <= fields, i++)
		addtofield(i, " <font face=\"[deffont]\"><A href='?src=\ref[src];write=[i]'>write</A></font>", 1)
	for(i = 1, i <= sfields, i++)
		addtofield(i, " <font face=\"[deffont]\"><A href='?src=\ref[src];write=[i];sign=1'>sign</A></font>", 1, "sign")
	info_links = info_links + " <font face=\"[deffont]\"><A href='?src=\ref[src];write=end'>write</A></font>"


/obj/item/weapon/paper/proc/clearpaper()
	info = null
	last_info_change = world.time
	stamp_text = null
	free_space = MAX_PAPER_MESSAGE_LEN
	LAZYCLEARLIST(stamped)
	LAZYCLEARLIST(ico)
	LAZYCLEARLIST(offset_x)
	LAZYCLEARLIST(offset_y)
	cut_overlays()
	updateinfolinks()
	update_icon()

/obj/item/weapon/paper/proc/create_self_copy()
	var/obj/item/weapon/paper/P = new

	P.name       = name
	P.info       = info
	P.info_links = info_links
	P.stamp_text = stamp_text
	P.fields     = fields
	P.sfields    = sfields
	P.stamped    = LAZYCOPY(stamped)
	P.ico        = LAZYCOPY(ico)
	P.offset_x   = LAZYCOPY(offset_x)
	P.offset_y   = LAZYCOPY(offset_y)
	P.copy_overlays(src, TRUE)

	P.updateinfolinks()
	P.update_icon()

	return P

/obj/item/weapon/paper/proc/get_signature(obj/item/weapon/pen/P, mob/user)
	if(P && istype(P, /obj/item/weapon/pen))
		return P.get_signature(user)
	return (user && user.real_name) ? user.real_name : "Anonymous"

/obj/item/weapon/paper/proc/add_signature(signature)
	LAZYSET(signed_by, signature, world.time)
	if(signed_by.len > 100)
		signed_by.Cut(1, 2)

/obj/item/weapon/paper/proc/add_stamp(stamp)
	LAZYSET(stamped_by, stamp, world.time)
	if(stamped_by.len > 100)
		stamped_by.Cut(1, 2)

/obj/item/weapon/paper/proc/parsepencode(t, obj/item/weapon/pen/P, mob/user, iscrayon = 0)
	if(length(t) == 0)
		return ""

	if(findtext(t, "\[sign\]"))
		var/signature = get_signature(P, user)
		t = replacetext(t, "\[sign\]", "<font face=\"[signfont]\"><i>[signature]</i></font>")
		add_signature(signature)

	var/font = deffont
	if(iscrayon) // If it is a crayon, and he still tries to use these, make them empty!
		t = replacetext(t, "\[*\]", "")
		t = replacetext(t, "\[hr\]", "")
		t = replacetext(t, "\[small\]", "")
		t = replacetext(t, "\[/small\]", "")
		t = replacetext(t, "\[list\]", "")
		t = replacetext(t, "\[/list\]", "")
		t = "<b>[t]</b>"
		font = crayonfont

	t = parsebbcode(t, P.colour)
	t = replacetext(t, "\[field\]", "<span class=\"paper_field\"></span>")
	t = replacetext(t, "\[sfield\]", "<span class=\"sign_field\"></span>")
	t = "<font face=\"[font]\" color=\"[P.colour]\">[t]</font>"
	t = replacetext(t, "\[sname\]", station_name_ru())
//	t = replacetext(t, "#", "") // Junk converted to nothing!

//Count the fields
	var/laststart = 1
	while(1)
		var/i = findtext(t, "<span class=\"paper_field\">", laststart) //</span>
		if(i==0)
			break
		laststart = i+1
		fields++

	laststart = 1
	while(1)
		var/i = findtext(t, "<span class=\"sign_field\">", laststart) //</span>
		if(i==0)
			break
		laststart = i+1
		sfields++

	return t


/obj/item/weapon/paper/proc/openhelp(mob/user)
	var/dat = {"
		<b><center>Crayon&Pen commands</center></b><br>
		<br>
		\[br\] : Creates a linebreak.<br>
		\[center\] - \[/center\] : Centers the text.<br>
		\[b\] - \[/b\] : Makes the text <b>bold</b>.<br>
		\[i\] - \[/i\] : Makes the text <i>italic</i>.<br>
		\[u\] - \[/u\] : Makes the text <u>underlined</u>.<br>
		\[large\] - \[/large\] : Increases the <font size = \"4\">size</font> of the text.<br>
		\[sign\] : Inserts a signature of your name in a foolproof way.<br>
		\[sname\] : Inserts the current station name. <br>
		\[field\] : Inserts an invisible field which lets you start type from there. Useful for forms.<br>
		<br>
		<b><center>Pen exclusive commands</center></b><br>
		\[small\] - \[/small\] : Decreases the <font size = \"1\">size</font> of the text.<br>
		\[list\] - \[/list\] : A list.<br>
		\[*\] : A dot used for lists.<br>
		\[hr\] : Adds a horizontal rule.
		"}

	var/datum/browser/popup = new(user, "paper_help", "Pen Help")
	popup.set_content(dat)
	popup.open()
/obj/item/weapon/paper/proc/select_form(mob/user)
	var/dat

	for(var/department in predefined_forms_list)
		var/color = predefined_forms_list[department]["color"]
		var/dep_name = predefined_forms_list[department]["name"]
		dat += "<h2>[dep_name]</h2>"
		dat += "<table><tbody><tr>"
		dat += "<th style='background:[color]; width:6em'>Номер</th>"
		dat += "<th style='background:[color];'>Название</th></tr>"

		for(var/premade_form in predefined_forms_list[department]["content"])
			var/datum/form/form = new premade_form
			dat += "<tr><th style='background-color:[color];'><A href='?src=\ref[src];write=end;form=[form.index]'>Форма [form.index]</A></th>"
			dat += "<th> [form.name]</th></tr>"
		dat +="</tbody></table>"

	var/datum/browser/popup = new(user, "window=[name]", "Список форм", 700, 500, ntheme = CSS_THEME_LIGHT)
	popup.set_content(dat)
	popup.open()

/obj/item/weapon/proc/burnpaper(obj/item/weapon/lighter/P, mob/user) //weapon, to use this in paper_bundle and photo
	var/list/burnable = list(/obj/item/weapon/paper,
                          /obj/item/weapon/paper_bundle,
                          /obj/item/weapon/photo)

	if(!is_type_in_list(src, burnable))
		return

	if(P.lit && !user.restrained() && !user.is_busy())
		var/class = "red"
		if(istype(P, /obj/item/weapon/lighter/zippo))
			class = "rose"

		user.visible_message("<span class='[class]'>[user] holds \the [P] up to \the [src], it looks like \he's trying to burn it!</span>", \
		"<span class='[class]'>You hold \the [P] up to \the [src], burning it slowly.</span>")

		icon_state = "paper_onfire"
		if(P.use_tool(P, user, 20, volume = 50))
			if((get_dist(src, user) > 1) || !P.lit)
				update_icon()
				return
			user.visible_message("<span class='[class]'>[user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>", \
			"<span class='[class]'>You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>")

			if(user.get_inactive_hand() == src)
				user.drop_from_inventory(src)

			new /obj/effect/decal/cleanable/ash(src.loc)
			qdel(src)

		else
			update_icon()
			to_chat(user, "<span class='warning'>You must hold \the [P] steady to burn \the [src].</span>")


/obj/item/weapon/paper/Topic(href, href_list)
	..()
	if(!usr || usr.incapacitated())
		return
	if(href_list["write"])
		var/id = href_list["write"]

		if(free_space <= 0)
			usr << "<span class='info'>There isn't enough space left on \the [src] to write anything.</span>"
			return

		var/t = ""
		if(href_list["sign"])
			if(tgui_alert(usr, "Are you sure you want to sign this paper?",, list("Yes","No")) == "No")
				return
			t = "\[sign\] "
		else if (href_list["form"])
			for(var/department in predefined_forms_list)
				if(t)
					break
				for(var/premade_form in predefined_forms_list[department]["content"])
					var/datum/form/form = new premade_form
					if(form.index == href_list["form"])
						t = sanitize(form.content, free_space, extra = FALSE)
						break
		else
			if (is_skill_competent(usr, list(/datum/skill/command = SKILL_LEVEL_NOVICE)) && id == "end" )
				if(tgui_alert(usr, "You want to write text of create form?",, list("Text","Form")) == "Form")
					select_form(usr)
				else
					t = sanitize(input("Enter what you want to write:", "Write", null, null)  as message, free_space, extra = FALSE)
			else
				t = sanitize(input("Enter what you want to write:", "Write", null, null)  as message, free_space, extra = FALSE)

		if(!t)
			return

		var/obj/item/i = usr.get_active_hand() // Check to see if he still got that darn pen, also check if he's using a crayon or pen.
		var/iscrayon = 0
		if(!istype(i, /obj/item/weapon/pen))
			if(!istype(i, /obj/item/toy/crayon))
				return
			iscrayon = 1

		// If the paper is near usr. If the paper is in clipboard it is checked inside of Adjacent()
		if(!Adjacent(usr)) // Some check to see if he's allowed to write
			return

		var/last_fields_value = fields
		var/last_sfields_value = sfields

		t = parsepencode(t, i, usr, iscrayon) // Encode everything from pencode to html

		if((fields + sfields) > 50)
			to_chat(usr, "<span class='warning'>Too many fields. Sorry, you can't do this.</span>")
			fields = last_fields_value
			sfields = last_sfields_value
			return

		if(isIAN(usr))
			t = GibberishAll(t)

		if(href_list["sign"])
			addtofield(text2num(id), t, type = "sign")
		else if(id!="end")
			addtofield(text2num(id), t) // He wants to edit a field, let him.
		else
			info += t // Oh, he wants to edit to the end of the file, let him.
			last_info_change = world.time
			updateinfolinks()

		playsound(src, pick(SOUNDIN_PEN), VOL_EFFECTS_MASTER, null, FALSE)
		update_space(t)
		show_content(usr, forceshow = TRUE, infolinks = TRUE)
		update_icon()


/obj/item/weapon/paper/attackby(obj/item/I, mob/user, params)
	user.SetNextMove(CLICK_CD_INTERACT)
	var/clown = 0
	if(user.mind && (user.mind.assigned_role == "Clown"))
		clown = 1

	if(istype(I, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/paper = I
		if(paper.crumpled)
			to_chat(user, "<span class='notice'>Paper too crumpled for anything.</span>")
			return

	if(crumpled)
		if(!(istype(I, /obj/item/weapon/lighter)))
			to_chat(user, "<span class='notice'>Paper too crumpled for anything.</span>")
			return
		else
			burnpaper(I, user)

	else if(istype(I, /obj/item/weapon/paper) || istype(I, /obj/item/weapon/photo))
		if (istype(I, /obj/item/weapon/paper/carbon))
			var/obj/item/weapon/paper/carbon/C = I
			if (!C.iscopy && !C.copied)
				to_chat(user, "<span class='notice'>Take off the carbon copy first.</span>")
				add_fingerprint(user)
				return
		var/old_loc = loc
		var/obj/item/weapon/paper_bundle/B = new(loc)
		if (name != "paper")
			B.name = name
		else if(I.name != "paper" && I.name != "photo")
			B.name = I.name
		user.drop_from_inventory(I)
		if (ishuman(user))
			var/mob/living/carbon/human/h_user = user
			if (h_user.r_hand == src)
				h_user.drop_from_inventory(src)
				h_user.put_in_r_hand(B)
			else if (h_user.l_hand == src)
				h_user.drop_from_inventory(src)
				h_user.put_in_l_hand(B)
			else if (h_user.l_store == src)
				h_user.drop_from_inventory(src)
				h_user.equip_to_slot_if_possible(B, SLOT_L_STORE)
			else if (h_user.r_store == src)
				h_user.drop_from_inventory(src)
				h_user.equip_to_slot_if_possible(B, SLOT_R_STORE)
			else if (h_user.head == src)
				h_user.u_equip(src)
				h_user.put_in_hands(B)
			else if (!istype(loc, /turf))
				src.loc = get_turf(h_user)
				if(h_user.client)	h_user.client.screen -= src
				h_user.put_in_hands(B)
		to_chat(user, "<span class='notice'>You clip the [I.name] to [(src.name == "paper") ? "the paper" : name].</span>")
		forceMove(B)
		I.forceMove(B)
		B.pages.Add(src)
		B.pages.Add(I)
		B.update_icon()
		if (istype(old_loc, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/s = old_loc
			s.update_ui_after_item_removal()

	else if(istype(I, /obj/item/weapon/pen) || istype(I, /obj/item/toy/crayon))
		if ( istype(I, /obj/item/weapon/pen/robopen) && I:mode == 2 )
			I:RenamePaper(user,src)
		else
			show_content(user, forceshow = TRUE, infolinks = TRUE)
		//openhelp(user)

	else if(istype(I, /obj/item/weapon/stamp))
		if(!Adjacent(user))
			return

		if(istype(I, /obj/item/weapon/stamp/clown))
			if(!clown)
				to_chat(user, "<span class='notice'>You are totally unable to use the stamp. HONK!</span>")
				return

		var/obj/item/weapon/stamp/S = I
		S.stamp_paper(src)
		add_stamp(S.stamp_message)

		playsound(src, 'sound/effects/stamp.ogg', VOL_EFFECTS_MASTER)
		visible_message("<span class='notice'>[user] stamp the paper.</span>", "<span class='notice'>You stamp the paper with your rubber stamp.</span>")

	else if(istype(I, /obj/item/weapon/lighter))
		burnpaper(I, user)

	else
		return ..()

/*
 * Premade paper
 */
/obj/item/weapon/paper/Court
	name = "Judgement"
	info = "For crimes against the station, the offender is sentenced to:<BR>\n<BR>\n"

/obj/item/weapon/paper/Toxin
	name = "Chemical Information"
	info = "Known Onboard Toxins:<BR>\n\tGrade A Semi-Liquid Phoron:<BR>\n\t\tHighly poisonous. You cannot sustain concentrations above 15 units.<BR>\n\t\tA gas mask fails to filter phoron after 50 units.<BR>\n\t\tWill attempt to diffuse like a gas.<BR>\n\t\tFiltered by scrubbers.<BR>\n\t\tThere is a bottled version which is very different<BR>\n\t\t\tfrom the version found in canisters!<BR>\n<BR>\n\t\tWARNING: Highly Flammable. Keep away from heat sources<BR>\n\t\texcept in a enclosed fire area!<BR>\n\t\tWARNING: It is a crime to use this without authorization.<BR>\nKnown Onboard Anti-Toxin:<BR>\n\tAnti-Toxin Type 01P: Works against Grade A Phoron.<BR>\n\t\tBest if injected directly into bloodstream.<BR>\n\t\tA full injection is in every regular Med-Kit.<BR>\n\t\tSpecial toxin Kits hold around 7.<BR>\n<BR>\nKnown Onboard Chemicals (other):<BR>\n\tRejuvenation T#001:<BR>\n\t\tEven 1 unit injected directly into the bloodstream<BR>\n\t\t\twill cure paralysis and sleep phoron.<BR>\n\t\tIf administered to a dying patient it will prevent<BR>\n\t\t\tfurther damage for about units*3 seconds.<BR>\n\t\t\tit will not cure them or allow them to be cured.<BR>\n\t\tIt can be administeredd to a non-dying patient<BR>\n\t\t\tbut the chemicals disappear just as fast.<BR>\n\tSleep Toxin T#054:<BR>\n\t\t5 units wilkl induce precisely 1 minute of sleep.<BR>\n\t\t\tThe effect are cumulative.<BR>\n\t\tWARNING: It is a crime to use this without authorization"

/obj/item/weapon/paper/courtroom
	name = "A Crash Course in Legal SOP on SS13"
	info = "<B>Roles:</B><BR>\nThe Detective is basically the investigator and prosecutor.<BR>\nThe Staff Assistant can perform these functions with written authority from the Detective.<BR>\nThe Captain/HoP/Warden is ct as the judicial authority.<BR>\nThe Security Officers are responsible for executing warrants, security during trial, and prisoner transport.<BR>\n<BR>\n<B>Investigative Phase:</B><BR>\nAfter the crime has been committed the Detective's job is to gather evidence and try to ascertain not only who did it but what happened. He must take special care to catalogue everything and don't leave anything out. Write out all the evidence on paper. Make sure you take an appropriate number of fingerprints. IF he must ask someone questions he has permission to confront them. If the person refuses he can ask a judicial authority to write a subpoena for questioning. If again he fails to respond then that person is to be jailed as insubordinate and obstructing justice. Said person will be released after he cooperates.<BR>\n<BR>\nONCE the FT has a clear idea as to who the criminal is he is to write an arrest warrant on the piece of paper. IT MUST LIST THE CHARGES. The FT is to then go to the judicial authority and explain a small version of his case. If the case is moderately acceptable the authority should sign it. Security must then execute said warrant.<BR>\n<BR>\n<B>Pre-Pre-Trial Phase:</B><BR>\nNow a legal representative must be presented to the defendant if said defendant requests one. That person and the defendant are then to be given time to meet (in the jail IS ACCEPTABLE). The defendant and his lawyer are then to be given a copy of all the evidence that will be presented at trial (rewriting it all on paper is fine). THIS IS CALLED THE DISCOVERY PACK. With a few exceptions, THIS IS THE ONLY EVIDENCE BOTH SIDES MAY USE AT TRIAL. IF the prosecution will be seeking the death penalty it MUST be stated at this time. ALSO if the defense will be seeking not guilty by mental defect it must state this at this time to allow ample time for examination.<BR>\nNow at this time each side is to compile a list of witnesses. By default, the defendant is on both lists regardless of anything else. Also the defense and prosecution can compile more evidence beforehand BUT in order for it to be used the evidence MUST also be given to the other side.\nThe defense has time to compile motions against some evidence here.<BR>\n<B>Possible Motions:</B><BR>\n1. <U>Invalidate Evidence-</U> Something with the evidence is wrong and the evidence is to be thrown out. This includes irrelevance or corrupt security.<BR>\n2. <U>Free Movement-</U> Basically the defendant is to be kept uncuffed before and during the trial.<BR>\n3. <U>Subpoena Witness-</U> If the defense presents god reasons for needing a witness but said person fails to cooperate then a subpoena is issued.<BR>\n4. <U>Drop the Charges-</U> Not enough evidence is there for a trial so the charges are to be dropped. The FT CAN RETRY but the judicial authority must carefully reexamine the new evidence.<BR>\n5. <U>Declare Incompetent-</U> Basically the defendant is insane. Once this is granted a medical official is to examine the patient. If he is indeed insane he is to be placed under care of the medical staff until he is deemed competent to stand trial.<BR>\n<BR>\nALL SIDES MOVE TO A COURTROOM<BR>\n<B>Pre-Trial Hearings:</B><BR>\nA judicial authority and the 2 sides are to meet in the trial room. NO ONE ELSE BESIDES A SECURITY DETAIL IS TO BE PRESENT. The defense submits a plea. If the plea is guilty then proceed directly to sentencing phase. Now the sides each present their motions to the judicial authority. He rules on them. Each side can debate each motion. Then the judicial authority gets a list of crew members. He first gets a chance to look at them all and pick out acceptable and available jurors. Those jurors are then called over. Each side can ask a few questions and dismiss jurors they find too biased. HOWEVER before dismissal the judicial authority MUST agree to the reasoning.<BR>\n<BR>\n<B>The Trial:</B><BR>\nThe trial has three phases.<BR>\n1. <B>Opening Arguments</B>- Each side can give a short speech. They may not present ANY evidence.<BR>\n2. <B>Witness Calling/Evidence Presentation</B>- The prosecution goes first and is able to call the witnesses on his approved list in any order. He can recall them if necessary. During the questioning the lawyer may use the evidence in the questions to help prove a point. After every witness the other side has a chance to cross-examine. After both sides are done questioning a witness the prosecution can present another or recall one (even the EXACT same one again!). After prosecution is done the defense can call witnesses. After the initial cases are presented both sides are free to call witnesses on either list.<BR>\nFINALLY once both sides are done calling witnesses we move onto the next phase.<BR>\n3. <B>Closing Arguments</B>- Same as opening.<BR>\nThe jury then deliberates IN PRIVATE. THEY MUST ALL AGREE on a verdict. REMEMBER: They mix between some charges being guilty and others not guilty (IE if you supposedly killed someone with a gun and you unfortunately picked up a gun without authorization then you CAN be found not guilty of murder BUT guilty of possession of illegal weaponry.). Once they have agreed they present their verdict. If unable to reach a verdict and feel they will never they call a deadlocked jury and we restart at Pre-Trial phase with an entirely new set of jurors.<BR>\n<BR>\n<B>Sentencing Phase:</B><BR>\nIf the death penalty was sought (you MUST have gone through a trial for death penalty) then skip to the second part. <BR>\nI. Each side can present more evidence/witnesses in any order. There is NO ban on emotional aspects or anything. The prosecution is to submit a suggested penalty. After all the sides are done then the judicial authority is to give a sentence.<BR>\nII. The jury stays and does the same thing as I. Their sole job is to determine if the death penalty is applicable. If NOT then the judge selects a sentence.<BR>\n<BR>\nTADA you're done. Security then executes the sentence and adds the applicable convictions to the person's record.<BR>\n"

/obj/item/weapon/paper/hydroponics
	name = "Greetings from Billy Bob"
	info = "<B>Hey fellow botanist!</B><BR>\n<BR>\nI didn't trust the station folk so I left<BR>\na couple of weeks ago. But here's some<BR>\ninstructions on how to operate things here.<BR>\nYou can grow plants and each iteration they become<BR>\nstronger, more potent and have better yield, if you<BR>\nknow which ones to pick. Use your botanist's analyzer<BR>\nfor that. You can turn harvested plants into seeds<BR>\nat the seed extractor, and replant them for better stuff!<BR>\nSometimes if the weed level gets high in the tray<BR>\nmutations into different mushroom or weed species have<BR>\nbeen witnessed. On the rare occassion even weeds mutate!<BR>\n<BR>\nEither way, have fun!<BR>\n<BR>\nBest regards,<BR>\nBilly Bob Johnson.<BR>\n<BR>\nPS.<BR>\nHere's a few tips:<BR>\nIn nettles, potency = damage<BR>\nIn amanitas, potency = deadliness + side effect<BR>\nIn Liberty caps, potency = drug power + effect<BR>\nIn chilis, potency = heat<BR>\n<B>Nutrients keep mushrooms alive!</B><BR>\n<B>Water keeps weeds such as nettles alive!</B><BR>\n<B>All other plants need both.</B>"

/obj/item/weapon/paper/djstation
	name = "DJ Listening Outpost"
	info = "<B>Welcome new owner!</B><BR><BR>You have purchased the latest in listening equipment. The telecommunication setup we created is the best in listening to common and private radio fequencies. Here is a step by step guide to start listening in on those saucy radio channels:<br><ol><li>Equip yourself with a multi-tool</li><li>Use the multitool on each machine, that is the broadcaster, receiver and the relay.</li><li>Turn all the machines on, it has already been configured for you to listen on.</li></ol> Simple as that. Now to listen to the private channels, you'll have to configure the intercoms, located on the front desk. Here is a list of frequencies for you to listen on.<br><ul><li>145.7 - Common Channel</li><li>144.7 - Private AI Channel</li><li>135.9 - Security Channel</li><li>135.7 - Engineering Channel</li><li>135.5 - Medical Channel</li><li>135.3 - Command Channel</li><li>135.1 - Science Channel</li><li>134.9 - Mining Channel</li><li>134.7 - Cargo Channel</li>"

/obj/item/weapon/paper/flag
	icon_state = "flag_neutral"
	item_state = "paper"
	anchored = TRUE

/obj/item/weapon/paper/jobs
	name = "Job Information"
	info = "Information on all formal jobs that can be assigned on Space Station 13 can be found on this document.<BR>\nThe data will be in the following form.<BR>\nGenerally lower ranking positions come first in this list.<BR>\n<BR>\n<B>Job Name</B>   general access>lab access-engine access-systems access (atmosphere control)<BR>\n\tJob Description<BR>\nJob Duties (in no particular order)<BR>\nTips (where applicable)<BR>\n<BR>\n<B>Research Assistant</B> 1>1-0-0<BR>\n\tThis is probably the lowest level position. Anyone who enters the space station after the initial job\nassignment will automatically receive this position. Access with this is restricted. Head of Personnel should\nappropriate the correct level of assistance.<BR>\n1. Assist the researchers.<BR>\n2. Clean up the labs.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Staff Assistant</B> 2>0-0-0<BR>\n\tThis position assists the security officer in his duties. The staff assisstants should primarily br\npatrolling the ship waiting until they are needed to maintain ship safety.\n(Addendum: Updated/Elevated Security Protocols admit issuing of low level weapons to security personnel)<BR>\n1. Patrol ship/Guard key areas<BR>\n2. Assist security officer<BR>\n3. Perform other security duties.<BR>\n<BR>\n<B>Technical Assistant</B> 1>0-0-1<BR>\n\tThis is yet another low level position. The technical assistant helps the engineer and the statian\ntechnician with the upkeep and maintenance of the station. This job is very important because it usually\ngets to be a heavy workload on station technician and these helpers will alleviate that.<BR>\n1. Assist Station technician and Engineers.<BR>\n2. Perform general maintenance of station.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Medical Assistant</B> 1>1-0-0<BR>\n\tThis is the fourth position yet it is slightly less common. This position doesn't have much power\noutside of the med bay. Consider this position like a nurse who helps to upkeep medical records and the\nmaterials (filling syringes and checking vitals)<BR>\n1. Assist the medical personnel.<BR>\n2. Update medical files.<BR>\n3. Prepare materials for medical operations.<BR>\n<BR>\n<B>Research Technician</B> 2>3-0-0<BR>\n\tThis job is primarily a step up from research assistant. These people generally do not get their own lab\nbut are more hands on in the experimentation process. At this level they are permitted to work as consultants to\nthe others formally.<BR>\n1. Inform superiors of research.<BR>\n2. Perform research alongside of official researchers.<BR>\n<BR>\n<B>Detective</B> 3>2-0-0<BR>\n\tThis job is in most cases slightly boring at best. Their sole duty is to\nperform investigations of crine scenes and analysis of the crime scene. This\nalleviates SOME of the burden from the security officer. This person's duty\nis to draw conclusions as to what happened and testify in court. Said person\nalso should stroe the evidence ly.<BR>\n1. Perform crime-scene investigations/draw conclusions.<BR>\n2. Store and catalogue evidence properly.<BR>\n3. Testify to superiors/inquieries on findings.<BR>\n<BR>\n<B>Station Technician</B> 2>0-2-3<BR>\n\tPeople assigned to this position must work to make sure all the systems aboard Space Station 13 are operable.\nThey should primarily work in the computer lab and repairing faulty equipment. They should work with the\natmospheric technician.<BR>\n1. Maintain SS13 systems.<BR>\n2. Repair equipment.<BR>\n<BR>\n<B>Atmospheric Technician</B> 3>0-0-4<BR>\n\tThese people should primarily work in the atmospheric control center and lab. They have the very important\njob of maintaining the delicate atmosphere on SS13.<BR>\n1. Maintain atmosphere on SS13<BR>\n2. Research atmospheres on the space station. (safely please!)<BR>\n<BR>\n<B>Engineer</B> 2>1-3-0<BR>\n\tPeople working as this should generally have detailed knowledge as to how the propulsion systems on SS13\nwork. They are one of the few classes that have unrestricted access to the engine area.<BR>\n1. Upkeep the engine.<BR>\n2. Prevent fires in the engine.<BR>\n3. Maintain a safe orbit.<BR>\n<BR>\n<B>Medical Researcher</B> 2>5-0-0<BR>\n\tThis position may need a little clarification. Their duty is to make sure that all experiments are safe and\nto conduct experiments that may help to improve the station. They will be generally idle until a new laboratory\nis constructed.<BR>\n1. Make sure the station is kept safe.<BR>\n2. Research medical properties of materials studied of Space Station 13.<BR>\n<BR>\n<B>Scientist</B> 2>5-0-0<BR>\n\tThese people study the properties, particularly the toxic properties, of materials handled on SS13.\nTechnically they can also be called Phoron Technicians as phoron is the material they routinly handle.<BR>\n1. Research phoron<BR>\n2. Make sure all phoron is properly handled.<BR>\n<BR>\n<B>Medical Doctor (Officer)</B> 2>0-0-0<BR>\n\tPeople working this job should primarily stay in the medical area. They should make sure everyone goes to\nthe medical bay for treatment and examination. Also they should make sure that medical supplies are kept in\norder.<BR>\n1. Heal wounded people.<BR>\n2. Perform examinations of all personnel.<BR>\n3. Moniter usage of medical equipment.<BR>\n<BR>\n<B>Security Officer</B> 3>0-0-0<BR>\n\tThese people should attempt to keep the peace inside the station and make sure the station is kept safe. One\nside duty is to assist in repairing the station. They also work like general maintenance personnel. They are not\ngiven a weapon and must use their own resources.<BR>\n(Addendum: Updated/Elevated Security Protocols admit issuing of weapons to security personnel)<BR>\n1. Maintain order.<BR>\n2. Assist others.<BR>\n3. Repair structural problems.<BR>\n<BR>\n<B>Head of Security</B> 4>5-2-2<BR>\n\tPeople assigned as Head of Security should issue orders to the security staff. They should\nalso carefully moderate the usage of all security equipment. All security matters should be reported to this person.<BR>\n1. Oversee security.<BR>\n2. Assign patrol duties.<BR>\n3. Protect the station and staff.<BR>\n<BR>\n<B>Head of Personnel</B> 4>4-2-2<BR>\n\tPeople assigned as head of personnel will find themselves moderating all actions done by personnel. \nAlso they have the ability to assign jobs and access levels.<BR>\n1. Assign duties.<BR>\n2. Moderate personnel.<BR>\n3. Moderate research. <BR>\n<BR>\n<B>Captain</B> 5>5-5-5 (unrestricted station wide access)<BR>\n\tThis is the highest position youi can aquire on Space Station 13. They are allowed anywhere inside the\nspace station and therefore should protect their ID card. They also have the ability to assign positions\nand access levels. They should not abuse their power.<BR>\n1. Assign all positions on SS13<BR>\n2. Inspect the station for any problems.<BR>\n3. Perform administrative duties.<BR>\n"

/obj/item/weapon/paper/bloody_notes
	info = "Космос. Он прекрасен. Почему они говорят что мне туда нельзя? Почему они говорят что я сумашедший? Он тянет меня... Он... Зовет меня... Я слышу его голос... Я больше так не могу..."
	layer = 3
	name = "Окровавленные Записи"

/obj/item/weapon/paper/photograph
	name = "photo"
	icon_state = "photo"
	var/photo_id = 0.0
	item_state = "paper"

/obj/item/weapon/paper/sop
	name = "paper- 'Standard Operating Procedure'"
	info = "Alert Levels:<BR>\nBlue- Emergency<BR>\n\t1. Caused by fire<BR>\n\t2. Caused by manual interaction<BR>\n\tAction:<BR>\n\t\tClose all fire doors. These can only be opened by reseting the alarm<BR>\nRed- Ejection/Self Destruct<BR>\n\t1. Caused by module operating computer.<BR>\n\tAction:<BR>\n\t\tAfter the specified time the module will eject completely.<BR>\n<BR>\nEngine Maintenance Instructions:<BR>\n\tShut off ignition systems:<BR>\n\tActivate internal power<BR>\n\tActivate orbital balance matrix<BR>\n\tRemove volatile liquids from area<BR>\n\tWear a fire suit<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nToxin Laboratory Procedure:<BR>\n\tWear a gas mask regardless<BR>\n\tGet an oxygen tank.<BR>\n\tActivate internal atmosphere<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nDisaster Procedure:<BR>\n\tFire:<BR>\n\t\tActivate sector fire alarm.<BR>\n\t\tMove to a safe area.<BR>\n\t\tGet a fire suit<BR>\n\t\tAfter:<BR>\n\t\t\tAssess Damage<BR>\n\t\t\tRepair damages<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tMeteor Shower:<BR>\n\t\tActivate fire alarm<BR>\n\t\tMove to the back of ship<BR>\n\t\tAfter<BR>\n\t\t\tRepair damage<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tAccidental Reentry:<BR>\n\t\tActivate fire alarms in front of ship.<BR>\n\t\tMove volatile matter to a fire proof area!<BR>\n\t\tGet a fire suit.<BR>\n\t\tStay secure until an emergency ship arrives.<BR>\n<BR>\n\t\tIf ship does not arrive-<BR>\n\t\t\tEvacuate to a nearby safe area!"

/obj/item/weapon/paper/crumpled
	icon_state = "scrap"

/obj/item/weapon/paper/crumpled/update_icon()
	return

/obj/item/weapon/paper/crumpled/bloody
	icon_state = "scrap_bloodied"

/obj/item/weapon/paper/wires
	name = "paper - 'Airlock wires documentation'"

/obj/item/weapon/paper/wires/atom_init()
	. = ..()
	identify_wires()

/obj/item/weapon/paper/wires/proc/identify_wires()
	info = get_airlock_wires_identification()

	var/obj/item/weapon/stamp/centcomm/S = new
	S.stamp_paper(src, "Centcomm Engineer Department")

	update_icon()
	updateinfolinks()

/obj/item/weapon/paper/brig_arsenal
	name = "Armory Inventory"
	info = "<b>Armory Inventory:</b><ul>6 Deployable Barriers<br>4 Portable Flashers<br>3 Riot Sets:<small><ul><li>Riot Shield<li>Stun Baton<li>Riot Helmet<li>Riot Suit</ul></small>3 Bulletproof Helmets<br>3 Bulletproof Vests<br>3 Ablative Helmets <br>3 Ablative Vests <br>1 Bomb Suit <br>1 Biohazard Suit<br>8 Security Masks<br>3 Pistols Glock 17<br>6 Magazines (9mm rubber)</ul><b>Secure Armory Inventory:</b><ul>3 Energy Guns<br>2 Ion Rifle<br>3 Laser rifles <br>1 L10-c Carbine<br>1 104-sass Shotgun<br>2 Plasma weapon battery packs<br>1 M79 Grenade Launcher<br>2 Shotguns<br>6 Magazines (9mm)<br>2 Shotgun Shell Boxes (beanbag, 20 shells)<br>1 m79 Grenade Box (40x46 teargas, 7 rounds)<br>1 m79 Grenade Box (40x46 rubber, 7 rounds)<br>1 m79 Grenade Box (40x46 EMP, 7 rounds)<br>1 Chemical Implant Kit<br>1 Tracking Implant Kit<br>1 Mind Shield Implant Kit<br>1 Death Alarm Implant Kit<br>1 Box of Flashbangs<br>2 Boxes of teargas grenades<br>1 Space Security Set:<small><ul><li>Security Hardsuit<li>Security Hardsuit Helmet<li>Magboots<li>Breath Mask</ul></small></ul>"

/obj/item/weapon/paper/brig_arsenal/atom_init()
	. = ..()
	if(HAS_ROUND_ASPECT(ROUND_ASPECT_REARM_ENERGY) || HAS_ROUND_ASPECT(ROUND_ASPECT_REARM_BULLETS))
		info = "A program is underway to re-equip NanoTrasen security. The current list has not yet been compiled, we apologize."

/obj/item/weapon/paper/firing_range
	name = "Firing Range Instructions"
	info = "Directions:<br><i>First you'll want to make sure there is a target stake in the center of the magnetic platform. Next, take an aluminum target from the crates back there and slip it into the stake. Make sure it clicks! Next, there should be a control console mounted on the wall somewhere in the room.<br><br> This control console dictates the behaviors of the magnetic platform, which can move your firing target around to simulate real-world combat situations. From here, you can turn off the magnets or adjust their electromagnetic levels and magnetic fields. The electricity level dictates the strength of the pull - you will usually want this to be the same value as the speed. The magnetic field level dictates how far the magnetic pull reaches.<br><br>Speed and path are the next two settings. Speed is associated with how fast the machine loops through the designated path. Paths dictate where the magnetic field will be centered at what times. There should be a pre-fabricated path input already. You can enable moving to observe how the path affects the way the stake moves. To script your own path, look at the following key:</i><br><br>N: North<br>S: South<br>E: East<br>W: West<br>C: Center<br>R: Random (results may vary)<br>; or &: separators. They are not necessary but can make the path string better visible."

/obj/item/weapon/paper/space_structures
	name = "NSS Exodus Sensor Readings"

/obj/item/weapon/paper/space_structures/atom_init()
	. = ..()
	name = "[station_name()] Sensor Readings"
	info = get_space_structures_info()

	var/obj/item/weapon/stamp/centcomm/S = new
	S.stamp_paper(src, "Centcomm Science Department")

	update_icon()
	updateinfolinks()

/obj/item/weapon/paper/space_structures/proc/get_space_structures_info()
	var/paper_text = "<center><img src = bluentlogo.png /><br /><font size = 3><b>[station_name()]</b> Sensor Readings:</font></center><br /><hr>"
	paper_text += "Scan results show the following points of interest:<br />"
	for(var/list/structure in SSmapping.spawned_structures)
		paper_text += "<li><b>[structure["desc"]]</b>: x = [structure["x"]], y = [structure["y"]], z = [prob(50) ? structure["z"] : "unknown"]</li>"
	return paper_text

/obj/item/weapon/paper/cloning_lab
	name = "paper - 'H-11 Cloning Apparatus Manual"
	info = {"<h4>Getting Started</h4>
	Congratulations, you are testing the H-11 experimental cloning device!<br>
	Using the H-11 is almost as simple as brain surgery! Simply insert the target humanoid into the scanning chamber and select the clone option to initiate cloning!<br>
	<b>That's all there is to it!</b><br>
	<i>Notice, cloning system cannot scan inorganic life or small primates.  Scan may fail if subject has suffered extreme brain damage.</i><br>
	<p>The provided CLONEPOD SYSTEM will produce the desired clone.  Standard clone maturation times are roughly 90 seconds.
	The cloning pod may be unlocked early after initial maturation is complete.</p><br>
	<i>Please note that resulting clones will have a DEVELOPMENTAL DEFECT as a result of genetic drift. We hope to reduce this through further testing.<br>
	Clones may also experience memory loss and radical changes in personality as a result of the cloning process.</i><br>
	<br>
	<font size=1>This technology produced under license from Thinktronic Systems, LTD.</font>"}

/obj/item/weapon/paper/cloning_log
	name = "experiment log"
	info = {"<h4>Day 1</h4>
	We are very excited to be part of the first crew of the SC Irmanda!<br>
	This ship is made to test an innovative FTL technology. I had some concerns at first, \
	but the engineers assure me that it is safe and there is absolutely no risk of the external wings breaking off from the acceleration.<br>
	We've been tasked with testing the latest model of the Thinktronic Cloning Pod. We'll stay in dock for a week before launching, but we're going to get started right away. \
	If the engine is as fast as they say, we might not have the time to run all the routine tests on the cloned subject!<br>
	<br>
	<h4>Day 2</h4>
	We cloned an unknown corpse that was given to us by the medical crew. The genetic replication is good enough to let the subject survive outside of the pod, \
	but the cellular damage remains a concern for his long-term survival. For safety we will be keeping him in quarantine.<br>
	We left him some books, but clearly we were too optimistic about his mental faculties. His brain seems to suffer from the same cloning decay that was caused by \
	the previous models. We will run further tests to see if there are improvements.<br>
	<h4>Day 4</h4>
	It seems we'll be launching even sooner than expected! Apparently the press is starting to lose interest, so we have to cut short the pre-flight checks \
	and give them something to talk about. Hopefully this will end up with increased funding...<br>
	The crew has all been invited to the main hall, where we have seats for the initial FTL acceleration. Unfortunately the clone cannot leave the quarantine room \
	without risking infection, so we will strap him into the bed and hope for the best. We can grow another clone if anything goes wrong, anyway.
	<br>
	<i>Professor Galen Linkovich</i>"}

/obj/item/weapon/paper/psyops_starting_guide
	name = "Добро пожаловать в \"СИПсО\""
	info = {"Добро пожаловать в отряд \"СИПсО\"!<br>
	Успешно пройдя все тренировки Скрельской Инициативы Пси Операций, тобой была получена необходимая экипировка:<br>
	- Посох с проектором силового щита<br>
	- Набор психоактивных веществ<br>
	- Экстренный набор еды<br>
	- Пси-усиляющая корона<br>
	- Перчатки тишины<br>
	<br>
	Напоминание о процедурах и методах работы с пси-короной:<br>
	- Мысленный тычёк по предмету в режиме захвата - сфокусирует разум на нём.<br>
	- Во всех остальных случаях мысленный тычёк отправит волны твоей воли для совершения действия.<br>
	- В режиме броска мысленный тычёк по чему-либо сфокусированным объектом бросит его туда.<br>
	- Активация фокуса, или мысленный тычёк фокуса самим по себе активирует сфокусированный объект.<br>
	- Психологически активные вещества усиляют способности, позволяя, к примеру брать в фокус живых существ.<br>
	- Телекинетическая активность быстро расходует запасы питательных веществ организма, особенно если не применять психоактивные вещества. Не забывайте иметь достаточный запас еды.<br>
	- Применение психоактивных веществ позволяет взаимодействовать с миром вопреки активации силового щита.<br>
	- Использование брони крайне нежелательно, так как может негативно влиять на ваши пси-способности.<br>"}

/obj/item/weapon/paper/lovenote
	name = "mysterious note"
	icon = 'icons/obj/valentines.dmi'
	icon_state = "lovenote"

/obj/item/weapon/paper/lovenote/atom_init()
	. = ..()
	icon_state = "lovenote"
	info = pick("Roses are red / Violets are good / One day while Andy...",
	"My love for you is like the singularity. It cannot be contained.",
	"Will you be my lusty xenomorph maid?",
	"We go together like the clown and the external airlock.",
	"Roses are red / Liches are wizards / I love you more than a whole squad of lizards.",
	"Be my valentine. Law 2.",
	"You must be a mime, because you leave me speechless.",
	"I love you like Ian loves the HoP.",
	"You're hotter than a plasma fire in toxins.",
	"Could I have all access... to your heart?",
	"Call me the doctor, because I'm here to inspect your johnson.",
	"Quick, get the defibrillator! I saw you and my heart stopped.",
	"I'm not a changeling, but you make my proboscis extend.",
	"I just can't get EI NATH of you.",
	"You must be a nuke op, because you make my heart explode.",
	"Roses are red / Botany is a farm / Not being my Valentine / causes human harm.",
	"I want you more than an assistant wants the captain's spare.",
	"Good thing I wore insulated gloves, because you're too hot to handle!",
	"If I was a security officer, I'd brig you all shift.",
	"Are you the janitor? Because I think I've fallen for you.",
	"You look as beautiful now as the last time you were cloned.",
	"If I were the warden I'd always let you into my armory.",
	"The virologist is rogue, and the only cure is a kiss from you.",
	"Would you spend some time in my upgraded sleeper?",
	"You must be a silicon, because you've unbolted my heart.",
	"Are you Nar'Sie? Because there's nar-one else I sie.",
	"If you were a taser, you'd be set to stunning.",
	"Do you have stamina damage from running through my dreams?",
	"If I were a xenomorph, would you let me hug you?",
	"My love for you is stronger than a reinforced wall.",
	"This must be the captain's office, because I see a fox.",
	"I'm no highlander, but there can only be one for me.",
	"Are you bluespace artillery? Because you blow me away.",
	"If you were an abandoned station you'd be the DEARelict.",
	"If you had an ore bag you'd be a shaft FINEr.",
	"I must be the CMO, 'cause I saw you on my CUTE sensors.",
	"Let's call the emergency CUDDLE.",
	"If you were an engineer you'd have insulated LOVEs.",
	"Could you put your DNA inside my vault?",
	"Roses are red, tide is gray, if I were an assistant I'd steal you away.",
	"Roses are red, text is green, I love you more than cleanbots clean.",
	"Roses are red, shuttles go dockside, I want to know you better than carbon dioxide.",
	"Roses are red, carnations are pink. Let's go out like the lights in a powersink.",
	"If you were a carp I'd fi-lay you.",
	"I'm a nuke op, and my pinpointer leads to your heart.",
	"Is that an esword in your pocket, or are you excited to see me?",
	"I've been chasing you like Dusty chases a laser pointer.",
	"I'm no cat, but you've got me in my feel-inids.",
	"If you were a disposal bin I'd ride you all day.",
	"You're the vomit to my flyperson.",
	"Get the ore redemptor, because I've just discovered girlfriend material.",
	"You must be liquid dark matter, because you're pulling me closer.",
	"Are you powering the station? Because you super matter to me.",
	"I wish science could make me a bag of holding you.",
	"Did you visit the medbay after you fell from heaven?",
	"Your beauty is rarer than an aurora caelus.",
	"Wanna raid my tool storage?",
	"You must be a moth, because you set my heart aflutter.")
	updateinfolinks()

/obj/item/weapon/paper/lovenote/update_icon()
	icon_state = "lovenote"

/obj/item/weapon/paper/nuclear_code
	name = "NSS Exodus Nuclear Detonation Device Code (TOP SECRET)"

/obj/item/weapon/paper/nuclear_code/atom_init(mapload, nukecode)
	. = ..()
	name = "[station_name()] Nuclear Detonation Device Code (TOP SECRET)"
	info = "<b>Nuclear Authentication Code:</b> [nukecode]"

	var/obj/item/weapon/stamp/centcomm/S = new
	S.stamp_paper(src, "CentComm Security Department")

	update_icon()
	updateinfolinks()

/obj/item/weapon/paper/cmf_manual
	name = "CMF manipulation manual"
	info = {"<h1 style="text-align: center;">Руководство пользователя</h1>
	<h2>Введение</h2>
	<p>Благодаря разработкам наших ученых мы смогли изготовить около стабильные прототипы картриджей USP. Эти картриджи позволяют изменять когнитивно-моторные способности существ.&nbsp;</p>
	<p>Эта технология состоит из четырех частей</p>
	<div>
	<ul>
	<li>CMF Modifier Access Console - используется для настройки картриджей. Показывает информацию о IQ (коэффициент интеллекта) и MDI (индекс моторного развития).</li>
	</ul>
	</div>
	<ul>
	<li>CMF manipulation table - получает данные с консоли и устанавливает имплант CMF с нужными параметрами. Он также может служить хирургическим операционным столом для лечения черепно-мозговых травм.</li>
	<li>USP cartridge - <span style="text-decoration: line-through;"><strong>\[секретно\]</strong></span></li>
	<li>Имплант CMF - изменяет навыки существа, позволяя ему быть более полезным работником.</li>
	</ul>
	<h2>Процедура</h2>
	<ol>
	<li>Поместите пациента на CMF manipulation table</li>
	<li>Спросите пациента о его знаниях и навыках. Проверьте показатели IQ и MDI</li>
	<li>Вставьте картридж в стол</li>
	<li>Распакуйте картридж (процедура не является обратимой)</li>
	<li>Используйте консоль для установки желаемых параметров импланта</li>
	<li>Имплантируйте пациента с помощью консоли</li>
	<li>В случае повреждения головного мозга направьте пациента на лечение к квалифицированному специалисту</li>
	<li>Окончание процедуры. Теперь работник готов к выполнению своих обязанностей.</li>
	</ol>
	<h2>Опасности и противопоказания</h2>
	<ul>
	<li>Из-за особенностей работы имплантов защиты разума и лояльности их нельзя использовать вместе с имплантами CMF.</li>
	<li>Консоль не позволит вам ввести этот имплантат существу неподходящей расы. Если такое произойдет, существо получит серьезные повреждения мозга, а имплант будет уничтожен.</li>
	<li>Импланты CMF все еще находятся на стадии прототипа, сильный ЭМИ может разрушить его.</li>
	<li>Поскольку эта технология является совершенно секретной, любое удаление импланта приведет к его уничтожению.</li>
	</ul>
	<h1 style="text-align: center;">Техническая информация</h1>
	<h2>Подключение оборудования</h2>
	<p>Чтобы подключить манипуляционный стол CMF к консоли, откройте панель обслуживания стола с помощью отвертки, затем с помощью мультиинструмента подсоедините стол к консоли и закройте панель обслуживания после этого.</p>
	<h2>Потребляемая мощность</h2>
	<p>После распаковки картриджа оборудование потребляет гораздо больше энергии, поэтому в консоли был установлен датчик заряда APC. Следите за зарядом во время манипуляций CMF.</p>
	<h2>Стоимость производства картриджей USP</h2>
	<p>Поскольку эти картриджи являются прототипами, которые еще не поступили в массовое производство, каждый картридж собирается вручную, и их распространение ограничено станциями, где гибель экипажа или наличие неквалифицированного персонала является обычным явлением. Используйте их с умом и не тратьте впустую. Внимательно изучите показатели IQ и MDI пациентов, чтобы определить, какой картридж необходим. Один базовый зеленый картридж стоил двадцать пять человеко-лет. Мы также не можем допустить, чтобы эти технологии попали в руки наших конкурентов.</p>
	"}

var/global/list/contributor_names
// https://docs.github.com/en/rest/repos/repos#list-repository-contributors
/proc/get_github_contributers(per_page = 100, anon = FALSE)
	if(global.contributor_names && global.contributor_names?.len)
		return global.contributor_names
	global.contributor_names = list()

	var/page = 1

	var/owner = config.github_repository_owner
	var/name = config.github_repository_name
	while(TRUE)
		var/list/response = get_webpage("https://api.github.com/repos/[owner]/[name]/contributors?anon=[anon]&per_page=[per_page]&page=[page]")
		if(!response)
			return
		response = json_decode(response)
		if(response.len == 0)
			break
		for(var/list/user in response)
			if(user["type"] == "User" && !(user["login"] in global.contributor_names))
				global.contributor_names += user["login"]
			else if(anon && user["type"] == "Anonymous" && !(user["name"] in global.contributor_names))
				global.contributor_names += user["name"]
		page++

	return global.contributor_names

/obj/item/weapon/paper/github_easter_egg
	name = "Department of Paranormal Activity"

/obj/item/weapon/paper/github_easter_egg/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/weapon/paper/github_easter_egg/atom_init_late()
	write_info()

/obj/item/weapon/paper/github_easter_egg/proc/write_info()
	set waitfor = FALSE

	var/list/names = get_github_contributers()
	info = "<h1 style='text-align: center;'>Department of Paranormal Activity</h1>"
	info += "<h2>List of callsigns of employees:</h2>"
	info += "<div>"
	info += "<ul>"
	for(var/name in names)
		info += "<li>[name]</li>"
	info += "</ul>"
	info += "</div>"

	var/obj/item/weapon/stamp/centcomm/S = new
	S.stamp_paper(src, "CentComm DPA")

	update_icon()

/obj/item/weapon/paper/psc
	name = "Разрешение на работу ЧОП"
	info = {"<h1 style="text-align: center;"Разрешение на работу ЧОП></h1>
	<p>Данный документ подтверждает, что держатель документа (далее Сотрудник) является сотрудником частного охранного предприятия, нанятого для охраны активов Карго.</p>
	<p>Сотрудник имеет право на владение и использование пистолета W&J PP и/или флешера и средств личной защиты в целях охраны активов Карго.</p>
	<p>При неправомерном применении спецсредств офицеры охраны имеют право изъять пистолет, флешер и средства личной защиты.</p>"}

/obj/item/weapon/paper/psc/atom_init()
	. = ..()
	var/obj/item/weapon/stamp/centcomm/S = new
	S.stamp_paper(src, "CentComm Logistics Department")

/obj/item/weapon/paper/depacc
	name = "Реквизиты счёта отдела "
	var/department_name = ""

/obj/item/weapon/paper/depacc/atom_init()
	. = ..()
	if(!department_name)
		qdel(src)
		return

	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(on_round_start))

/obj/item/weapon/paper/depacc/Destroy()
	UnregisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING)
	return ..()

/obj/item/weapon/paper/depacc/proc/on_round_start()
	var/datum/money_account/dep = global.department_accounts[department_name]
	if(!dep)
		qdel(src)
		return

	info = {"<h2>Бухгалтерия Центрального Коммитета «ЦК»</h2>
	<blockquote style=\"line-height:normal; margin-bottom:10px; font-style:italic; letter-spacing: 1.25px; text-align:right;\">[current_date_string]</blockquote>
	<table align="center" border="3" cellpadding="10" width="100%">
  		<caption><b><big>Реквизиты счёта отдела</big></b></caption>
  		<tr><td>Отдел:</td><td>«[department_name]»</td></tr>
  		<tr><td>Номер счёта:</td><td>№ [dep.account_number]</td></tr>
  		<tr><td>Пин-код:</td><td>PIN: [dep.remote_access_pin]</td></tr>
 	 	<tr><td>Бюджет:</td><td>[dep.money] $</td></tr>
	</table>
	<hr>"}

	var/obj/item/weapon/stamp/centcomm/Stamp1 = new
	Stamp1.stamp_paper(src, "CentComm")
	var/obj/item/weapon/stamp/copy_correct/Stamp2 = new
	Stamp2.stamp_paper(src)

	UnregisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING)
