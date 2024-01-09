/* Filing cabinets!
 * Contains:
 *		Filing Cabinets
 *		Security Record Cabinets
 *		Medical Record Cabinets
 */


/*
 * Filing Cabinets
 */
/obj/structure/filingcabinet
	name = "filing cabinet"
	desc = "A large cabinet with drawers."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "filingcabinet"
	density = TRUE
	anchored = TRUE
	throwpass = TRUE//You can throw objects over this, despite it's density.")
	climbable = TRUE

	resistance_flags = CAN_BE_HIT


/obj/structure/filingcabinet/chestdrawer
	name = "chest drawer"
	icon_state = "chestdrawer"

/obj/structure/filingcabinet/chestdrawer/black
	icon_state = "chestdrawer_black"

/obj/structure/filingcabinet/filingcabinet	//not changing the path to avoid unecessary map issues, but please don't name stuff like this in the future -Pete
	icon_state = "tallcabinet"

/obj/structure/filingcabinet/verb/rotate()
	set name = "Rotate"
	set category = "Object"
	set src in oview(1)

	if (usr.incapacitated())
		return
	if (anchored)
		to_chat(usr,"<span class='notice'>It is fastened to the floor!</span>")
		return
	set_dir(turn(dir, 90))


/obj/structure/filingcabinet/atom_init()
	. = ..()
	for(var/obj/item/I in loc)
		if(istype(I, /obj/item/weapon/paper) || istype(I, /obj/item/weapon/folder) || istype(I, /obj/item/weapon/photo) || istype(I, /obj/item/weapon/paper_bundle))
			I.loc = src


/obj/structure/filingcabinet/attackby(obj/item/P, mob/user)
	if(!allowed(usr))
		to_chat(usr, "[bicon(src)] [name] <span class='warning'>Доступ запрещён</span>")
		return FALSE

	if(istype(P, /obj/item/weapon/paper) || istype(P, /obj/item/weapon/folder) || istype(P, /obj/item/weapon/photo) || istype(P, /obj/item/weapon/paper_bundle))
		to_chat(user, "<span class='notice'>You put [P] in [src].</span>")
		user.drop_from_inventory(P, src)
		flick("[initial(icon_state)]-open", src)
		updateUsrDialog()

	else if(iswrenching(P))
		user.SetNextMove(CLICK_CD_INTERACT)
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")

	else if(isscrewing(P))
		if(P.use_tool(src, user, 15))
			deconstruct(TRUE)
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
	else
		to_chat(user, "<span class='notice'>You can't put [P] in [src]!</span>")
		..()

/obj/structure/filingcabinet/deconstruct(disassembled)
	for(var/obj/item/I as anything in contents)
		I.forceMove(loc)
	if(flags & NODECONSTRUCT)
		return ..()
	new /obj/item/stack/sheet/metal(loc, 4)
	..()

/obj/structure/filingcabinet/attack_hand(mob/user)
	if(!allowed(usr))
		to_chat(usr, "[bicon(src)] [name] <span class='warning'>Доступ запрещён</span>")
		return FALSE

	if(contents.len <= 0)
		to_chat(user, "<span class='notice'>\The [src] is empty.</span>")
		return

	user.set_machine(src)
	var/dat = "<center><table>"
	var/i
	for(i=contents.len, i>=1, i--)
		var/obj/item/P = contents[i]
		dat += "<tr><td><a href='?src=\ref[src];retrieve=\ref[P]'>[sanitize(P.name)]</a></td></tr>"
	dat += "</table></center>"

	var/datum/browser/popup = new(user, "filingcabinet", src.name, 350, 300)
	popup.set_content(dat)
	popup.open()

/obj/structure/filingcabinet/Topic(href, href_list)
	if(href_list["retrieve"])
		usr << browse(null, "window=filingcabinet") // Close the menu

		//var/retrieveindex = text2num(href_list["retrieve"])
		var/obj/item/P = locate(href_list["retrieve"]) in src //contents[retrieveindex]
		if(P && Adjacent(usr))
			usr.put_in_hands(P)
			updateUsrDialog()
			flick("[initial(icon_state)]-open", src)


/*
 * Security Record Cabinets
 */
/obj/structure/filingcabinet/security
	var/virgin = 1


/obj/structure/filingcabinet/security/proc/populate()
	if(virgin)
		for(var/datum/data/record/G in data_core.general)
			var/datum/data/record/S
			for(var/datum/data/record/R in data_core.security)
				if((R.fields["name"] == G.fields["name"] || R.fields["id"] == G.fields["id"]))
					S = R
					break
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(src)
			P.info = "<CENTER><B>Security Record</B></CENTER><BR>"
			P.info += "Name: [G.fields["name"]] ID: [G.fields["id"]]<BR>\nSex: [G.fields["sex"]]<BR>\nAge: [G.fields["age"]]<BR>\nFingerprint: [G.fields["fingerprint"]]<BR>\nPhysical Status: [G.fields["p_stat"]]<BR>\nMental Status: [G.fields["m_stat"]]<BR>"
			P.info += "<BR>\n<CENTER><B>Security Data</B></CENTER><BR>\nCriminal Status: [S.fields["criminal"]]<BR>\n<BR>\nMinor Crimes: [S.fields["mi_crim"]]<BR>\nDetails: [S.fields["mi_crim_d"]]<BR>\n<BR>\nMajor Crimes: [S.fields["ma_crim"]]<BR>\nDetails: [S.fields["ma_crim_d"]]<BR>\n<BR>\nImportant Notes:<BR>\n\t[S.fields["notes"]]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
			var/counter = 1
			while(S.fields["com_[counter]"])
				P.info += "[S.fields["com_[counter]"]]<BR>"
				counter++
			P.info += "</TT>"
			P.name = "Security Record ([G.fields["name"]])"
			P.update_icon()
			virgin = 0	//tabbing here is correct- it's possible for people to try and use it
						//before the records have been generated, so we do this inside the loop.

/obj/structure/filingcabinet/security/attack_hand()
	populate()
	..()

/*
 * Medical Record Cabinets
 */
/obj/structure/filingcabinet/medical
	var/virgin = 1

/obj/structure/filingcabinet/medical/proc/populate()
	if(virgin)
		for(var/datum/data/record/G in data_core.general)
			var/datum/data/record/M
			for(var/datum/data/record/R in data_core.medical)
				if((R.fields["name"] == G.fields["name"] || R.fields["id"] == G.fields["id"]))
					M = R
					break
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(src)
			P.info = "<CENTER><B>Medical Record</B></CENTER><BR>"
			P.info += "Name: [G.fields["name"]] ID: [G.fields["id"]]<BR>\nSex: [G.fields["sex"]]<BR>\nAge: [G.fields["age"]]<BR>\nFingerprint: [G.fields["fingerprint"]]<BR>\nPhysical Status: [G.fields["p_stat"]]<BR>\nMental Status: [G.fields["m_stat"]]<BR>"
			P.info += "<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: [M.fields["b_type"]]<BR>\nDNA: [M.fields["b_dna"]]<BR>\n<BR>\nMinor Disabilities: [M.fields["mi_dis"]]<BR>\nDetails: [M.fields["mi_dis_d"]]<BR>\n<BR>\nMajor Disabilities: [M.fields["ma_dis"]]<BR>\nDetails: [M.fields["ma_dis_d"]]<BR>\n<BR>\nAllergies: [M.fields["alg"]]<BR>\nDetails: [M.fields["alg_d"]]<BR>\n<BR>\nCurrent Diseases: [M.fields["cdi"]] (per disease info placed in log/comment section)<BR>\nDetails: [M.fields["cdi_d"]]<BR>\n<BR>\nImportant Notes:<BR>\n\t[M.fields["notes"]]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
			var/counter = 1
			while(M.fields["com_[counter]"])
				P.info += "[M.fields["com_[counter]"]]<BR>"
				counter++
			P.info += "</TT>"
			P.name = "Medical Record ([G.fields["name"]])"
			P.update_icon()
			virgin = 0	//tabbing here is correct- it's possible for people to try and use it
						//before the records have been generated, so we do this inside the loop.

/obj/structure/filingcabinet/medical/attack_hand()
	populate()
	..()
