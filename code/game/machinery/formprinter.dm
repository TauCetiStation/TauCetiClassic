/obj/machinery/formprinter
	name = "form printer"
	desc = "A machine to print all theese forms HoP's asking for."
	icon = 'icons/obj/library.dmi'
	icon_state = "forms"
	density = TRUE
	anchored = TRUE
	var/ready = TRUE
	var/wiki_namespace = "Guide_to_Paperwork"
	var/list/wiki_forms = list()

/obj/machinery/formprinter/atom_init()
	. = ..()
	if(!config.wikiurl)
		return
	var/form_list = get_webpage("[config.wikiurl]/[wiki_namespace]/List?action=raw")
	wiki_forms = splittext(form_list, "\n")

/obj/machinery/formprinter/ui_interact(mob/user)
	var/dat = "<h1>Form printer</h1><BR><BR>"
	if(length(wiki_forms) != 0)
		dat += "Choose form from database:<BR>"
		var/regex/spaces = new("\\s", "g")
		for(var/F in wiki_forms)
			dat += "<a href='byond://?src=\ref[src];form=[spaces.Replace(F, "_")]'>[F]</a><BR>"
	else
		dat += "ERROR: FORM DATABASE UNAVAILABLE"
	user << browse(entity_ja(dat), "window=forms")
	onclose(user, "forms")

/obj/machinery/formprinter/is_operational_topic()
	return TRUE

/obj/machinery/formprinter/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if(href_list["form"])
		print(href_list["form"])
		sleep(15)

/obj/machinery/formprinter/attackby(obj/item/O, mob/user)
	if(iswrench(O))
		default_unfasten_wrench(user, O)

/obj/machinery/formprinter/proc/print(form_name)
	var/contents = get_webpage("[config.wikiurl]/[wiki_namespace]/[form_name]?action=raw")
	var/obj/item/weapon/paper/P = new(src.loc)
	P.name = replacetext(form_name, "_", " ")
	contents = parsebbcode(contents)
	contents = replacetext(contents, "\[field\]", "<span class=\"paper_field\"></span>")
	P.info = contents

	//count fields
	var/laststart = 1
	while(TRUE)
		var/i = findtext(contents, "<span class=\"paper_field\">", laststart) //</span>
		if(i==0)
			break
		laststart = i+1
		P.fields++

	P.updateinfolinks()
	P.update_icon()
	P.pixel_y = rand(-8, 8)
	P.pixel_x = rand(-9, 9)