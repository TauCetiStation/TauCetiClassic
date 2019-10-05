/datum/preferences/proc/ShowGeneral(mob/user)
	. =  "<table cellspacing='0' width='100%'>"	//Main body table start
	. += 	"<tr>"
	. += 		"<td width='340px' height='320px' style='padding-left:25px'>"

	//General
	. += 			"<table width='100%' cellpadding='5' cellspacing='0'>"	//General table start
	. += 				"<tr valign='top'>"
	. += 					"<td colspan='2'>"
	. += 						"<b>Name:</b> "
	. += 						"<a href='?_src_=prefs;preference=name;task=input'><b>[real_name]</b></a>"
	. += 						"<br>(<a href='?_src_=prefs;preference=name;task=random'>Random Name</a>)"
	. += 						"(<a href='?_src_=prefs;preference=name'>Always Random Name: [be_random_name ? "Yes" : "No"]</a>)"
	. += 						"<b>Gender:</b> <a href='?_src_=prefs;preference=gender'><b>[gender == MALE ? "Male" : "Female"]</b></a>"
	. += 						"<br><b>Age:</b> <a href='?_src_=prefs;preference=age;task=input'>[age]</a>"
	. += 						"<br><b>Randomized Character Slot:</b> <a href='?_src_=prefs;preference=randomslot'><b>[randomslot ? "Yes" : "No"]</b></a>"
	. += 						"<hr>"
	. += 					"</td>"
	. += 				"</tr>"

	//Character setup menu
	. += 				"<tr>"
	. += 					"<td>"
	. += 						"<center>"
	. += 						"<b>Character setup</b>"
	. += 						"<br>"
	. += 						"[submenu_type=="body"?"<b>Body</b>":"<a href=\"byond://?src=\ref[user];preference=body\">Body</a>"] - "
	. += 						"[submenu_type=="organs"?"<b>Organs</b>":"<a href=\"byond://?src=\ref[user];preference=organs\">Organs</a>"] - "
	. += 						"[submenu_type=="appearance"?"<b>Appearance</b>":"<a href=\"byond://?src=\ref[user];preference=appearance\">Appearance</a>"] - "
	. += 						"[submenu_type=="gear"?"<b>Gear</b>":"<a href=\"byond://?src=\ref[user];preference=gear\">Gear</a>"]"
	. += 						"</center>"
	. += 						"<br>"
	. += 						"<table border width='100%' background='opacity7.png' bordercolor='5A6E7D' cellspacing='0'>"	//Submenu table start
	. += 							"<tr valign='top'>"
	. += 								"<td height='180px'>"

	switch(submenu_type)	//Submenu
		//Body
		if("body")
			. += "Body: <a href='?_src_=prefs;preference=all;task=random'>&reg;</a>"
			. += "<br>Species: <a href='byond://?src=\ref[user];preference=species;task=input'>[species]</a>"
			. += "<br>Secondary Language: <a href='byond://?src=\ref[user];preference=language;task=input'>[language]</a>"
			. += "<br>Blood Type: <a href='byond://?src=\ref[user];preference=b_type;task=input'>[b_type]</a>"
			. += "<br>Skin Tone: <a href='?_src_=prefs;preference=s_tone;task=input'>[-s_tone + 35]/220</a>"

		//Organs
		if("organs")
			. += "Limbs & Internal Organs: <a href='byond://?src=\ref[user];preference=organs;task=input'>Adjust</a>"

			//(display limbs below)
			var/ind = 0
			for(var/name in organ_data)
				var/status = organ_data[name]
				var/company = organ_prost_data[name]
				var/organ_name = parse_zone(name)
				switch(name)
					if(BP_HEAD)
						organ_name = "head"
					if(BP_CHEST)
						organ_name = "chest"
					if(BP_GROIN)
						organ_name = "groin"
					if(BP_L_ARM)
						organ_name = "left arm"
					if(BP_R_ARM)
						organ_name = "right arm"
					if(BP_L_LEG)
						organ_name = "left leg"
					if(BP_R_LEG)
						organ_name = "right leg"
					if(O_HEART)
						organ_name = "heart"
					if(O_EYES)
						organ_name = "eyes"

				switch(status)
					if("Prothesis")
						++ind
						. += "<li>[company] [organ_name] prothesis</li>"
					if("Amputated")
						++ind
						. += "<li>Amputated [organ_name]</li>"
					if("Mechanical")
						++ind
						. += "<li>Mechanical [organ_name]</li>"
					if("Assisted")
						++ind
						switch(organ_name)
							if("heart")
								. += "<li>Pacemaker-assisted [organ_name]</li>"
							if("voicebox") //on adding voiceboxes for speaking skrell/similar replacements
								. += "<li>Surgically altered [organ_name]</li>"
							if("eyes")
								. += "<li>Retinal overlayed [organ_name]</li>"
							else
								. += "<li>Mechanically assisted [organ_name]</li>"
			if(!ind)
				. += "<br>\[...\]"

		//Appearance
		if("appearance")
			. += "<b>Hair</b>"
			. += "<br><a href='?_src_=prefs;preference=hair;task=input'>Change Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair, 2)]'><table border cellspacing='0' style='display:inline;' bgcolor='#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair)]'><tr><td width='20' height='15'></td></tr></table></font>"
			. += " Style: <a href='?_src_=prefs;preference=h_style;task=input'>[h_style]</a><br>"
			. += "<b>Facial</b>"
			. += "<br><a href='?_src_=prefs;preference=facial;task=input'>Change Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial, 2)]'><table border cellspacing='0' style='display:inline;' bgcolor='#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial)]'><tr><td width='20' height='15'></td></tr></table></font>"
			. += " Style: <a href='?_src_=prefs;preference=f_style;task=input'>[f_style]</a><br>"
			. += "<b>Eyes</b>"
			. += "<br><a href='?_src_=prefs;preference=eyes;task=input'>Change Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes, 2)]'><table border cellspacing='0' style='display:inline;' bgcolor='#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes)]'><tr><td width='20' height='15'></td></tr></table></font><br>"
			. += "<b>Body Color</b>"
			. += "<br><a href='?_src_=prefs;preference=skin;task=input'>Change Color</a> <font face='fixedsys' size='3' color='#[num2hex(r_skin, 2)][num2hex(g_skin, 2)][num2hex(b_skin, 2)]'><table border cellspacing='0' style='display:inline;' bgcolor='#[num2hex(r_skin, 2)][num2hex(g_skin, 2)][num2hex(b_skin)]'><tr><td width='20' height='15'></td></tr></table></font>"

		//Gear
		if("gear")
			. += "<b>Gear:</b><br>"
			if(gender == MALE)
				. += "Underwear: <a href ='?_src_=prefs;preference=underwear;task=input'>[underwear_m[underwear]]</a><br>"
			else
				. += "Underwear: <a href ='?_src_=prefs;preference=underwear;task=input'>[underwear_f[underwear]]</a><br>"
			. += "Undershirt: <a href='?_src_=prefs;preference=undershirt;task=input'>[undershirt_t[undershirt]]</a><br>"
			. += "Socks: <a href='?_src_=prefs;preference=socks;task=input'>[socks_t[socks]]</a><br>"
			. += "Backpack Type: <a href ='?_src_=prefs;preference=bag;task=input'>[backbaglist[backbag]]</a>"

	. += 								"</td>"
	. += 							"</tr>"
	. += 						"</table>"	//Submenu table end
	. += 					"</td>"
	. += 				"</tr>"

	. += 			"</table>"	//General table end
	. += 		"</td>"

	. += 		"<td width='300px' height='300px' valign='top'>"
	. += 			"<table width='100%' cellpadding='5'>"	//Backstory table start
	. += 				"<tr>"
	. += 					"<td>"

	//Backstory
	. += 						"<b>Background information:</b>"
	. += 						"<br>Nanotrasen Relation: <a href ='?_src_=prefs;preference=nt_relation;task=input'>[nanotrasen_relation]</a>"
	. += 						"<br>Home system: <a href='byond://?src=\ref[user];preference=home_system;task=input'>[home_system]</a>"
	. += 						"<br>Citizenship: <a href='byond://?src=\ref[user];preference=citizenship;task=input'>[citizenship]</a>"
	. += 						"<br>Faction: <a href='byond://?src=\ref[user];preference=faction;task=input'>[faction]</a>"
	. += 						"<br>Religion: <a href='byond://?src=\ref[user];preference=religion;task=input'>[religion]</a>"
	. += 						"<br>"

	if(jobban_isbanned(user, "Records"))
		. += 					"<br><b>You are banned from using character records.</b><br>"
	else
		. += 					"<br><b>Records:</b>"
		. += 					"<br>Medical Records:"
		. += 					" <a href=\"byond://?src=\ref[user];preference=records;task=med_record\">[length(med_record)>0?"[copytext(med_record, 1, 3)]...":"\[...\]"]</a>"
		. += 					"<br>Security Records:"
		. += 					" <a href=\"byond://?src=\ref[user];preference=records;task=sec_record\">[length(sec_record)>0?"[copytext(sec_record, 1, 3)]...":"\[...\]"]</a>"
		. += 					"<br>Employment Records:"
		. += 					" <a href=\"byond://?src=\ref[user];preference=records;task=gen_record\">[length(gen_record)>0?"[copytext(gen_record, 1, 3)]...":"\[...\]"]</a>"

	. += 						"<br><br>"

	. += 						"<b>Flavor:</b>"
	. += 						" <a href='byond://?src=\ref[user];preference=flavor_text;task=input'>[length(flavor_text)>0?"[copytext(flavor_text, 1, 3)]...":"\[...\]"]</a>"
	. += 					"</td>"
	. += 				"</tr>"
	. += 			"</table>"	//Backstory table end
	. += 		"</td>"
	. += 	"</tr>"
	. += "</table>"	//Main body table end

/datum/preferences/proc/update_bodypart_selection(mob/user, bodypart, chosen_state)
	var/datum/species/species_obj = all_species[species]

	var/tot_mental_load = 0
	var/list/langs_processing = list()

	if(species != IPC)
		for(var/organ_name in organ_data)
			if(organ_data[organ_name] == "Prothesis")
				var/company_name = organ_prost_data[organ_name]
				var/company_type = global.robotic_controllers_by_company[company_name]
				var/datum/bodypart_controller/robot/R_cont = new company_type()
				tot_mental_load += R_cont.mental_load
				if(!(R_cont.processing_language in langs_processing))
					langs_processing += R_cont.processing_language
				if(R_cont.processing_language != language && R_cont.processing_language != species_obj.language && !(R_cont.processing_language in species_obj.additional_languages))
					tot_mental_load += 20
		tot_mental_load += langs_processing.len * 10

	var/dat = "<center><b>Possible Limb Modifications.</b></center>"
	dat += "<p style='text-align:right'>ML: [tot_mental_load]/[species_obj.mental_capability]</p>"
	var/bodypart_name = ""
	switch(bodypart)
		if(O_HEART)
			bodypart_name = "Heart"
		if(O_EYES)
			bodypart_name = "Eyes"
		if(BP_HEAD)
			bodypart_name = "Head"
		if(BP_CHEST)
			bodypart_name = "Chest"
		if(BP_GROIN)
			bodypart_name = "Groin"
		if(BP_L_ARM)
			bodypart_name = "Left arm"
		if(BP_R_ARM)
			bodypart_name = "Right arm"
		if(BP_L_LEG)
			bodypart_name = "Left leg"
		if(BP_R_LEG)
			bodypart_name = "Right leg"
	dat += "<A href='?_src_=prefs;preference=bp_change;task=change_bp_sel;bodypart=[bodypart];organ_type=[chosen_state]'>\[[bodypart_name]\]</A>"
	dat += "<A href='?_src_=prefs;preference=bp_change;task=change_bp_state;bodypart=[bodypart];organ_type=[chosen_state]'>\[[chosen_state]\]</A>"

	switch(chosen_state)
		if("Prothesis", "Assisted", "Mechanical")
			for(var/company_name in global.robotic_controllers_by_company)
				var/company_type = global.robotic_controllers_by_company[company_name]
				var/datum/bodypart_controller/robot/R_cont = new company_type()
				if(("exclude" in R_cont.restrict_species) == (species in R_cont.restrict_species))
					continue
				if(!(bodypart in R_cont.get_pos_parts(species)))
					continue
				if(!(chosen_state in R_cont.allowed_states))
					continue

				dat += "<hr><p>"
				dat += "<b>Company:</b> <i>[R_cont.company]</i><br>"
				dat += "<b>Desc:</b> [R_cont.desc]<br>"

				if(chosen_state == "Prothesis")
					dat += "<b>Mental load:</b> [R_cont.mental_load]%<br>"
					dat += "<b>Processing language:</b> <i>[R_cont.processing_language]</i><br>"

				var/tier_txt
				switch(R_cont.tech_tier)
					if(LOW_TECH_PROSTHETIC)
						tier_txt = "<font color='red'>Low</font>"
					if(MEDIUM_TECH_PROSTHETIC)
						tier_txt = "<font color='yellow'>Medium</font>"
					if(HIGH_TECH_PROSTHETIC)
						tier_txt = "<font color='dodgerblue'>High</font>"

				if(tier_txt)
					dat += "<b>Tech tier:</b> [tier_txt]<br>"

				if(R_cont.protected)
					dat += "\t<font color='dodgerblue'>* Is EMP protected.</font><br>"
				if(R_cont.monitor)
					dat += "\t<font color='dodgerblue'>* Has an in-built display-screen.</font><br>"
				if(R_cont.default_cell_type)
					var/obj/item/weapon/stock_parts/cell/C = new R_cont.default_cell_type
					dat += "\t<font color='dodgerblue'>* Comes pre-loaded with a [C.name].</font><br>"
				if(R_cont.arr_consume_amount != 0.0)
					dat += "\t<font color='red'>* Requires a dose of [R_cont.arr_consume_amount] ARR each [R_cont.rejection_time / (1 MINUTE)] minutes.</font><br>"
				if(R_cont.passive_cell_use > 0)
					dat += "\t<font color='red'>* Requires [R_cont.passive_cell_use] charge per worktime unit.</font><br>"
				if(R_cont.action_cell_use > 0)
					dat += "\t<font color='red'>* Requires [R_cont.action_cell_use] charge per action.</font><br>"
				if(R_cont.low_quality)
					dat += "\t<font color='red'>* Can arrive with defects.</font><br>"

				var/bp_status = organ_data[bodypart] ? organ_data[bodypart] : "Normal"
				dat += "<A href='?_src_=prefs;preference=bp_change;task=save_bp;bodypart=[bodypart];organ_type=[chosen_state];add_data=[R_cont.company]'>\[Change from [bp_status] to [chosen_state].\]</A>"
				dat += "</p></hr>"

		if("Amputated")
			dat += "<hr><p>"
			dat += "<b>Desc:</b> An amputated limb, what an eyesore.<br>"
			var/bp_status = organ_data[bodypart] ? organ_data[bodypart] : "Normal"
			dat += "<A href='?_src_=prefs;preference=bp_change;task=save_bp;bodypart=[bodypart];organ_type=[chosen_state]'>\[Change from [bp_status] to [chosen_state].\]</A>"
			dat += "</p></hr>"
		if("Normal")
			dat += "<hr><p>"
			dat += "<b>Desc:</b> A normal limb, what a bore.<br>"
			var/bp_status = organ_data[bodypart] ? organ_data[bodypart] : "Normal"
			dat += "<A href='?_src_=prefs;preference=bp_change;task=save_bp;bodypart=[bodypart];organ_type=[chosen_state]'>\[Change from [bp_status] to [chosen_state].\]</A>"
			dat += "</p></hr>"

	var/datum/browser/popup = new /datum/browser(user, "bodypart_state_pick", "Allowed Bodypart States", 500, 350)
	popup.set_content(dat)
	popup.open()

/datum/preferences/proc/process_link_general(mob/user, list/href_list)
	switch(href_list["preference"])
		if("records")
			switch(href_list["task"])
				if("med_record")
					var/medmsg = sanitize(input(usr,"Set your medical notes here.","Medical Records",input_default(med_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = FALSE)

					if(medmsg != null)
						med_record = medmsg

				if("sec_record")
					var/secmsg = sanitize(input(usr,"Set your security notes here.","Security Records",input_default(sec_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = FALSE)

					if(secmsg != null)
						sec_record = secmsg

				if("gen_record")
					var/genmsg = sanitize(input(usr,"Set your employment notes here.","Employment Records",input_default(gen_record)) as message, MAX_PAPER_MESSAGE_LEN, extra = FALSE)

					if(genmsg != null)
						gen_record = genmsg

	switch(href_list["task"])
		if("random")
			switch(href_list["preference"])
				if("name")
					real_name = random_name(gender)
				if("age")
					age = rand(AGE_MIN, AGE_MAX)
				if("hair")
					r_hair = rand(0,255)
					g_hair = rand(0,255)
					b_hair = rand(0,255)
				if("h_style")
					h_style = random_hair_style(gender, species)
				if("facial")
					r_facial = rand(0,255)
					g_facial = rand(0,255)
					b_facial = rand(0,255)
				if("f_style")
					f_style = random_facial_hair_style(gender, species)
				if("underwear")
					underwear = rand(1,underwear_m.len)
				if("undershirt")
					undershirt = rand(1,undershirt_t.len)
				if("socks")
					socks = rand(1,socks_t.len)
				if("eyes")
					r_eyes = rand(0,255)
					g_eyes = rand(0,255)
					b_eyes = rand(0,255)
				if("s_tone")
					s_tone = random_skin_tone()
				if("s_color")
					r_skin = rand(0,255)
					g_skin = rand(0,255)
					b_skin = rand(0,255)
				if("bag")
					backbag = rand(1,4)
				if("all")
					randomize_appearance_for()	//no params needed
		if("input")
			switch(href_list["preference"])
				if("name")
					var/new_name = sanitize_name(input(user, "Choose your character's name:", "Character Preference")  as text|null)
					if(new_name)
						real_name = new_name
					else
						to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")

				if("age")
					var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Character Preference") as num|null
					if(new_age)
						age = max(min( round(text2num(new_age)), AGE_MAX),AGE_MIN)

				if("species")
					var/list/new_species = list(HUMAN)
					var/prev_species = species
					var/whitelisted = 0

					if(config.usealienwhitelist) //If we're using the whitelist, make sure to check it!
						for(var/S in whitelisted_species)
							if(is_alien_whitelisted(user,S))
								new_species += S
								whitelisted = 1
						if(!whitelisted)
							alert(user, "You cannot change your species as you need to be whitelisted. If you wish to be whitelisted contact an admin in-game, on the forums, or on IRC.")
					else //Not using the whitelist? Aliens for everyone!
						new_species = whitelisted_species

					species = input("Please select a species", "Character Generation", null) in new_species

					if(prev_species != species)
						var/list/to_check = list() + organ_data
						for(var/organ_name in to_check)
							var/company = organ_prost_data[organ_name]
							var/company_type = global.robotic_controllers_by_company[company]
							var/datum/bodypart_controller/robot/R_cont = new company_type()
							if(("exclude" in R_cont.restrict_species) == (species in R_cont.restrict_species))
								organ_data -= organ_name
								organ_prost_data -= organ_name

						f_style = random_facial_hair_style(gender, species)
						h_style = random_hair_style(gender, species)
						ResetJobs()
						ResetQuirks()
						if(language && language != "None")
							var/datum/language/lang = all_languages[language]
							if(!(species in lang.allowed_species))
								language = "None"

				if("language")
					var/list/new_languages = list("None")
					var/datum/species/S = all_species[species]
					for(var/L in all_languages)
						var/datum/language/lang = all_languages[L]
						if(!(lang.flags & RESTRICTED) && (S.name in lang.allowed_species))
							new_languages += lang.name

					language = input("Please select a secondary language", "Character Generation", null) in new_languages

				if("b_type")
					var/new_b_type = input(user, "Choose your character's blood-type:", "Character Preference") as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )
					if(new_b_type)
						b_type = new_b_type

				if("hair")
					if(species in list(HUMAN, UNATHI, TAJARAN, SKRELL, IPC))
						var/new_hair = input(user, "Choose your character's hair colour:", "Character Preference") as color|null
						if(new_hair)
							r_hair = hex2num(copytext(new_hair, 2, 4))
							g_hair = hex2num(copytext(new_hair, 4, 6))
							b_hair = hex2num(copytext(new_hair, 6, 8))

				if("h_style")
					var/list/valid_hairstyles = list()
					for(var/hairstyle in hair_styles_list)
						var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
						if( !(species in S.species_allowed))
							if(gender == MALE && S.gender == FEMALE)
								continue
							if(gender == FEMALE && S.gender == MALE)
								continue
							if(!(species in S.species_allowed))
								continue

							var/datum/bodypart_controller/robot/monitor = new global.robotic_controllers_by_company[organ_prost_data[BP_HEAD]]
							if(species != IPC && monitor.monitor)
								continue

						valid_hairstyles[hairstyle] = hair_styles_list[hairstyle]

					var/new_h_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in valid_hairstyles
					if(new_h_style)
						h_style = new_h_style

				if("facial")
					var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference") as color|null
					if(new_facial)
						r_facial = hex2num(copytext(new_facial, 2, 4))
						g_facial = hex2num(copytext(new_facial, 4, 6))
						b_facial = hex2num(copytext(new_facial, 6, 8))

				if("f_style")
					var/list/valid_facialhairstyles = list()
					for(var/facialhairstyle in facial_hair_styles_list)
						var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
						if(gender == MALE && S.gender == FEMALE)
							continue
						if(gender == FEMALE && S.gender == MALE)
							continue
						if(!(species in S.species_allowed))
							continue

						valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]

					var/new_f_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in valid_facialhairstyles
					if(new_f_style)
						f_style = new_f_style

				if("underwear")
					var/list/underwear_options
					if(gender == MALE)
						underwear_options = underwear_m
					else
						underwear_options = underwear_f

					var/new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in underwear_options
					if(new_underwear)
						underwear = underwear_options.Find(new_underwear)

				if("undershirt")
					var/list/undershirt_options
					undershirt_options = undershirt_t

					var/new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in undershirt_options
					if (new_undershirt)
						undershirt = undershirt_options.Find(new_undershirt)
				if("socks")
					var/list/socks_options
					socks_options = socks_t
					var/new_socks = input(user, "Choose your character's socks:", "Character Preference") as null|anything in socks_options
					if(new_socks)
						socks = socks_options.Find(new_socks)

				if("eyes")
					var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference") as color|null
					if(new_eyes)
						r_eyes = hex2num(copytext(new_eyes, 2, 4))
						g_eyes = hex2num(copytext(new_eyes, 4, 6))
						b_eyes = hex2num(copytext(new_eyes, 6, 8))

				if("s_tone")
					if(species != HUMAN)
						return
					var/new_s_tone = input(user, "Choose your character's skin-tone:\n(Light 1 - 220 Dark)", "Character Preference")  as num|null
					if(new_s_tone)
						s_tone = 35 - max(min( round(new_s_tone), 220),1)

				if("skin")
					if(species == UNATHI || species == TAJARAN || species == SKRELL)
						var/new_skin = input(user, "Choose your character's skin colour: ", "Character Preference") as color|null
						if(new_skin)
							r_skin = hex2num(copytext(new_skin, 2, 4))
							g_skin = hex2num(copytext(new_skin, 4, 6))
							b_skin = hex2num(copytext(new_skin, 6, 8))

				if("bag")
					var/new_backbag = input(user, "Choose your character's style of bag:", "Character Preference")  as null|anything in backbaglist
					if(new_backbag)
						backbag = backbaglist.Find(new_backbag)

				if("nt_relation")
					var/new_relation = input(user, "Choose your relation to NT. Note that this represents what others can find out about your character by researching your background, not what your character actually thinks.", "Character Preference")  as null|anything in list("Loyal", "Supportive", "Neutral", "Skeptical", "Opposed")
					if(new_relation)
						nanotrasen_relation = new_relation

				if("home_system")
					var/choice = input(user, "Please choose a home system.") as null|anything in home_system_choices + list("None","Other")
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = sanitize(input(user, "Please enter a home system.")  as text|null)
						if(raw_choice)
							home_system = raw_choice
						return
					home_system = choice

				if("citizenship")
					var/choice = input(user, "Please choose your current citizenship.") as null|anything in citizenship_choices + list("None","Other")
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = sanitize(input(user, "Please enter your current citizenship.", "Character Preference") as text|null)
						if(raw_choice)
							citizenship = raw_choice
						return
					citizenship = choice

				if("faction")
					var/choice = input(user, "Please choose a faction to work for.") as null|anything in faction_choices + list("None","Other")
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = sanitize(input(user, "Please enter a faction.")  as text|null)
						if(raw_choice)
							faction = raw_choice
						return
					faction = choice

				if("religion")
					var/choice = input(user, "Please choose a religion.") as null|anything in religion_choices + list("None","Other")
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = sanitize(input(user, "Please enter a religon.")  as text|null)
						if(raw_choice)
							religion = raw_choice
						return
					religion = choice

				if("flavor_text")
					var/msg = sanitize(input(usr,"Set the flavor text in your 'examine' verb.","Flavor Text", input_default(flavor_text)) as message)

					if(msg != null)
						flavor_text = msg

				if("organs")
					update_bodypart_selection(user, BP_CHEST, "Normal")

				if("skin_style")
					var/skin_style_name = input(user, "Select a new skin style") as null|anything in list("default1", "default2", "default3")
					if(!skin_style_name) return

		if("save_bp")
			var/list/allowed_states = list("Normal", "Amputated", "Prothesis")

			switch(href_list["bodypart"])
				if(O_HEART)
					allowed_states = list("Normal", "Assisted", "Mechanical")
				if(O_EYES)
					allowed_states = list("Normal", "Assisted", "Mechanical")
				if(BP_HEAD)
					allowed_states = list("Normal", "Prothesis")
				if(BP_CHEST)
					allowed_states = list("Normal", "Prothesis")
				if(BP_GROIN)
					allowed_states = list("Normal", "Prothesis")

			if(!(href_list["organ_type"] in allowed_states))
				update_bodypart_selection(usr, BP_CHEST, "Normal")
				return

			if(href_list["add_data"])
				var/company_name = href_list["add_data"]
				var/company_type = global.robotic_controllers_by_company[company_name]
				var/datum/bodypart_controller/robot/R_cont = new company_type()

				if(!(href_list["bodypart"] in R_cont.get_pos_parts(species)))
					update_bodypart_selection(usr, BP_CHEST, "Normal")
					return
				if(!(href_list["organ_type"] in R_cont.allowed_states))
					update_bodypart_selection(usr, BP_CHEST, "Normal")
					return
				if(("exclude" in R_cont.restrict_species) == (species in R_cont.restrict_species))
					update_bodypart_selection(usr, BP_CHEST, "Normal")
					return

			var/bodypart = href_list["bodypart"]
			var/organ_type = href_list["organ_type"]

			switch(organ_type)
				if("Normal")
					organ_data -= bodypart
					if(bodypart in organ_prost_data)
						organ_prost_data -= bodypart
				if("Amputated")
					organ_data[bodypart] = "Amputated"
					if(bodypart in organ_prost_data)
						organ_prost_data -= bodypart
				if("Prothesis")
					organ_data[bodypart] = "Prothesis"
					organ_prost_data[bodypart] = href_list["add_data"]
				if("Mechanical")
					organ_data[bodypart] = "Mechanical"
					organ_prost_data[bodypart] = href_list["add_data"]
				if("Assisted")
					organ_data[bodypart] = "Assisted"
					organ_prost_data[bodypart] = href_list["add_data"]

			update_bodypart_selection(usr, bodypart, organ_type)

		if("change_bp_sel")
			var/prev_bodypart = href_list["bodypart"]
			var/organ_type = href_list["organ_type"]

			var/menu_type = input(user, "Menu") as null|anything in list("Limbs", "Organs")
			if(!menu_type)
				return

			var/list/pos_bodyparts = list()
			switch(menu_type)
				if("Limbs")
					pos_bodyparts = list("Head", "Chest", "Groin", "Left Leg", "Right Leg", "Left Arm", "Right Arm")
				if("Organs")
					pos_bodyparts = list("Heart", "Eyes")

			var/bodypart_name = input(user, "Which limb do you want to change?") as null|anything in pos_bodyparts
			if(!bodypart_name)
				return

			var/bodypart = ""
			var/allowed_states = list("Normal", "Amputated", "Prothesis")

			switch(bodypart_name)
				if("Heart")
					bodypart = O_HEART
					allowed_states = list("Normal", "Assisted", "Mechanical")
				if("Eyes")
					bodypart = O_EYES
					allowed_states = list("Normal", "Assisted", "Mechanical")
				if("Head")
					bodypart = BP_HEAD
					allowed_states = list("Normal", "Prothesis")
				if("Chest")
					bodypart = BP_CHEST
					allowed_states = list("Normal", "Prothesis")
				if("Groin")
					bodypart = BP_GROIN
					allowed_states = list("Normal", "Prothesis")
				if("Left Leg")
					bodypart = BP_L_LEG
				if("Right Leg")
					bodypart = BP_R_LEG
				if("Left Arm")
					bodypart = BP_L_ARM
				if("Right Arm")
					bodypart = BP_R_ARM

			var/chosen_state = organ_type
			if(!(chosen_state in allowed_states))
				chosen_state = allowed_states[1]

			if(prev_bodypart != bodypart)
				update_bodypart_selection(user, bodypart, chosen_state)

		if("change_bp_state")
			var/bodypart = href_list["bodypart"]
			var/organ_type = href_list["organ_type"]

			var/allowed_states = list("Normal", "Amputated", "Prothesis")

			switch(bodypart)
				if(O_HEART)
					allowed_states = list("Normal", "Assisted", "Mechanical")
				if(O_EYES)
					allowed_states = list("Normal", "Assisted", "Mechanical")
				if(BP_HEAD)
					allowed_states = list("Normal", "Prothesis")
				if(BP_CHEST)
					allowed_states = list("Normal", "Prothesis")
				if(BP_GROIN)
					allowed_states = list("Normal", "Prothesis")

			var/chosen_state = input(user, "What state do you wish the bodypart to be in?") as null|anything in allowed_states
			if(!chosen_state)
				return

			if(chosen_state != organ_type)
				update_bodypart_selection(user, bodypart, chosen_state)

		else
			switch(href_list["preference"])
				if("gender")
					if(gender == MALE)
						gender = FEMALE
					else
						gender = MALE

					f_style = random_facial_hair_style(gender, species)
					h_style = random_hair_style(gender, species)

				if("randomslot")
					randomslot = !randomslot

				if("name")
					be_random_name = !be_random_name

				if("body")
					submenu_type = "body"

				if("organs")
					submenu_type = "organs"

				if("appearance")
					submenu_type = "appearance"

				if("gear")
					submenu_type = "gear"
