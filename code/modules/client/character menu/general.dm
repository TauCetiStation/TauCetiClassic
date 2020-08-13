/datum/preferences/proc/ShowGeneral(mob/user)
	var/datum/species/specie_obj = all_species[species]
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
			if(!specie_obj.flags[NO_BLOOD])
				. += "<br>Blood Type: <a href='byond://?src=\ref[user];preference=b_type;task=input'>[b_type]</a>"
			if(specie_obj.flags[HAS_SKIN_TONE])
				. += "<br>Skin Tone: <a href='?_src_=prefs;preference=s_tone;task=input'>[-s_tone + 35]/220</a>"

		//Organs
		if("organs")
			. += "Limbs & Internal Organs: <a href='byond://?src=\ref[user];preference=organs;task=input'>Adjust</a>"

			//(display limbs below)
			var/ind = 0
			for(var/name in organ_data)
				//world << "[ind] \ [organ_data.len]"
				var/status = organ_data[name]
				var/organ_name = parse_zone(name)
				switch(name)
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

				if(status == "cyborg")
					++ind
					. += "<li>Mechanical [organ_name] prothesis</li>"
				else if(status == "amputated")
					++ind
					. += "<li>Amputated [organ_name]</li>"
				else if(status == "mechanical")
					++ind
					. += "<li>Mechanical [organ_name]</li>"
				else if(status == "assisted")
					++ind
					switch(organ_name)
						if("heart")
							. += "<li>Pacemaker-assisted [organ_name]</li>"
						if("eyes")
							. += "<li>Retinal overlayed [organ_name]</li>"
						else
							. += "<li>Mechanically assisted [organ_name]</li>"
			if(species == IPC)
				. += "<br>Head: <a href='byond://?src=\ref[user];preference=ipc_head;task=input'>[ipc_head]</a>"

			if(!ind)
				. += "<br>\[...\]"
		//Appearance
		if("appearance")
			if(species == IPC)
				. += "<b>IPC screen</b>"
			else
				. += "<b>Hair</b>"
			. += "<br>"
			if(specie_obj.flags[HAS_HAIR_COLOR])
				. += "<a href='?_src_=prefs;preference=hair;task=input'>Change Color</a> [color_square(r_hair, g_hair, b_hair)]"
				. += " Style: <a class='white' href='?_src_=prefs;preference=h_style_left;task=input'><</a> <a class='white' href='?_src_=prefs;preference=h_style_right;task=input'>></a> <a href='?_src_=prefs;preference=h_style;task=input'>[h_style]</a><br>"
				. += "<b>Gradient</b>"
				. += "<br><a href='?_src_=prefs;preference=grad_color;task=input'>Change Color</a> [color_square(r_grad, g_grad, b_grad)] "
				. += " Style: <a class='white' href='?_src_=prefs;preference=grad_style_left;task=input'><</a> <a class='white' href='?_src_=prefs;preference=grad_style_right;task=input'>></a> <a href='?_src_=prefs;preference=grad_style;task=input'>[grad_style]</a><br>"
			else
				. += " Style: <a class='white' href='?_src_=prefs;preference=h_style_left;task=input'><</a> <a class='white' href='?_src_=prefs;preference=h_style_right;task=input'>></a> <a href='?_src_=prefs;preference=h_style;task=input'>[h_style]</a><br>"
			. += "<b>Facial</b>"
			. += "<br><a href='?_src_=prefs;preference=facial;task=input'>Change Color</a> [color_square(r_facial, g_facial, b_facial)]"
			. += " Style: <a class='white' href='?_src_=prefs;preference=f_style_left;task=input'><</a> <a class='white' href='?_src_=prefs;preference=f_style_right;task=input'>></a> <a href='?_src_=prefs;preference=f_style;task=input'>[f_style]</a><br>"
			. += "<b>Eyes</b>"
			. += "<br><a href='?_src_=prefs;preference=eyes;task=input'>Change Color</a> [color_square(r_eyes, g_eyes, b_eyes)]<br>"
			
			if(specie_obj.flags[HAS_SKIN_COLOR])
				. += "<b>Body Color</b>"
				. += "<br><a href='?_src_=prefs;preference=skin;task=input'>Change Color</a> [color_square(r_skin, g_skin, b_skin)]"

		//Gear
		if("gear")
			. += "<b>Gear:</b><br>"
			if(specie_obj.flags[HAS_UNDERWEAR])
				if(gender == MALE)
					. += "Underwear: <a href ='?_src_=prefs;preference=underwear;task=input'>[underwear_m[underwear]]</a><br>"
				else
					. += "Underwear: <a href ='?_src_=prefs;preference=underwear;task=input'>[underwear_f[underwear]]</a><br>"
				. += "Undershirt: <a href='?_src_=prefs;preference=undershirt;task=input'>[undershirt_t[undershirt]]</a><br>"
				. += "Socks: <a href='?_src_=prefs;preference=socks;task=input'>[socks_t[socks]]</a><br>"
			. += "Backpack Type: <a href ='?_src_=prefs;preference=bag;task=input'>[backbaglist[backbag]]</a><br>"
			. += "Using skirt uniform: <a href ='?_src_=prefs;preference=use_skirt;task=input'>[use_skirt ? "Yes" : "No"]</a>"

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
		. += 					" <a href=\"byond://?src=\ref[user];preference=records;task=med_record\">[length(med_record)>0?"[copytext_char(med_record, 1, 3)]...":"\[...\]"]</a>"
		. += 					"<br>Security Records:"
		. += 					" <a href=\"byond://?src=\ref[user];preference=records;task=sec_record\">[length(sec_record)>0?"[copytext_char(sec_record, 1, 3)]...":"\[...\]"]</a>"
		. += 					"<br>Employment Records:"
		. += 					" <a href=\"byond://?src=\ref[user];preference=records;task=gen_record\">[length(gen_record)>0?"[copytext_char(gen_record, 1, 3)]...":"\[...\]"]</a>"

	. += 						"<br><br>"

	. += 						"<b>Flavor:</b>"
	. += 						" <a href='byond://?src=\ref[user];preference=flavor_text;task=input'>[length(flavor_text)>0?"[copytext_char(flavor_text, 1, 3)]...":"\[...\]"]</a>"
	. += 					"</td>"
	. += 				"</tr>"
	. += 			"</table>"	//Backstory table end
	. += 		"</td>"
	. += 	"</tr>"
	. += "</table>"	//Main body table end

/proc/color_square(red, green, blue, hex)
	var/color = hex ? hex : "#[num2hex(red, 2)][num2hex(green, 2)][num2hex(blue, 2)]"
	return "<font face='fixedsys' size='3' color='[color]'><table border cellspacing='0' style='display:inline;' bgcolor='[color]'><tr><td width='20' height='15'></td></tr></table></font>"

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

	var/datum/species/specie_obj = all_species[species]

	switch(href_list["task"])
		if("random")
			switch(href_list["preference"])
				if("name")
					real_name = random_name(gender)
				if("age")
					age = rand(specie_obj.min_age, specie_obj.max_age)
				if("hair")
					r_hair = rand(0,255)
					g_hair = rand(0,255)
					b_hair = rand(0,255)
				if("h_style")
					h_style = random_hair_style(gender, species, ipc_head)
				if("facial")
					r_facial = rand(0,255)
					g_facial = rand(0,255)
					b_facial = rand(0,255)
				if("f_style")
					f_style = random_facial_hair_style(gender, species)
				if("underwear")
					if(gender == MALE)
						underwear = rand(1, underwear_m.len)
					else
						underwear = rand(1, underwear_f.len)
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
					backbag = rand(1, backbaglist.len)
				if("use_skirt")
					use_skirt = pick(TRUE, FALSE)
				if("all")
					randomize_appearance_for()	//no params needed
		if("input")
			switch(href_list["preference"])
				if("name")
					var/new_name = sanitize_name(input(user, "Choose your character's name:", "Character Name", real_name) as text|null)
					if(new_name)
						real_name = new_name
					else
						to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")

				if("age")
					var/new_age = input(user, "Choose your character's age:\n([specie_obj.min_age]-[specie_obj.max_age])", "Character Age", age) as num|null
					if(new_age)
						age = max(min( round(text2num(new_age)), specie_obj.max_age), specie_obj.min_age)

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

					species = input("Please select a species", "Character Generation", prev_species) in new_species

					if(prev_species != species)
						f_style = random_facial_hair_style(gender, species)
						h_style = random_hair_style(gender, species, ipc_head)
						ResetJobs()
						UpdateAllowedQuirks()
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

					language = input("Please select a secondary language", "Character Generation", language) in new_languages

				if("b_type")
					if(specie_obj.flags[NO_BLOOD])
						return
					var/new_b_type = input(user, "Choose your character's blood-type:", "Character Blood-type", b_type) as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )
					if(new_b_type)
						b_type = new_b_type

				if("hair")
					if(!specie_obj.flags[HAS_HAIR_COLOR])
						return
					var/new_hair = input(user, "Choose your character's hair colour:", "Character Hair Colour", rgb(r_hair, g_hair, b_hair)) as color|null
					if(new_hair)
						r_hair = hex2num(copytext(new_hair, 2, 4))
						g_hair = hex2num(copytext(new_hair, 4, 6))
						b_hair = hex2num(copytext(new_hair, 6, 8))

				if("h_style")
					var/list/valid_hairstyles = get_valid_styles_from_cache(hairs_cache)
					var/new_h_style = input(user, "Choose your character's hair style:", "Character Hair Style", h_style) as null|anything in valid_hairstyles
					if(new_h_style)
						h_style = new_h_style

				if("h_style_left")
					var/list/valid_hairstyles = get_valid_styles_from_cache(hairs_cache)
					h_style = valid_hairstyles[h_style][LEFT]

				if("h_style_right")
					var/list/valid_hairstyles = get_valid_styles_from_cache(hairs_cache)
					h_style = valid_hairstyles[h_style][RIGHT]

				if("grad_color")
					if(!specie_obj.flags[HAS_HAIR_COLOR])
						return
					var/new_grad = input(user, "Choose your character's secondary hair color:", "Character Gradient Color", rgb(r_grad, g_grad, b_grad)) as color|null
					if(new_grad)
						r_grad = hex2num(copytext(new_grad, 2, 4))
						g_grad = hex2num(copytext(new_grad, 4, 6))
						b_grad = hex2num(copytext(new_grad, 6, 8))

				if("grad_style")
					var/list/valid_gradients = hair_gradients
					var/new_grad_style = input(user, "Choose a color pattern for your hair:", "Character Gradient Style", grad_style) as null|anything in valid_gradients
					if(new_grad_style)
						grad_style = new_grad_style

				if("grad_style_left")
					var/list/valid_gradients = hair_gradients
					var/grad_style_num = get_left_right_style_num(LEFT, valid_gradients, grad_style)
					grad_style = valid_gradients[grad_style_num]

				if("grad_style_right")
					var/list/valid_gradients = hair_gradients
					var/grad_style_num = get_left_right_style_num(RIGHT, valid_gradients, grad_style)
					grad_style = valid_gradients[grad_style_num]

				if("facial")
					var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character facial-hair colour", rgb(r_facial, g_facial, b_facial)) as color|null
					if(new_facial)
						r_facial = hex2num(copytext(new_facial, 2, 4))
						g_facial = hex2num(copytext(new_facial, 4, 6))
						b_facial = hex2num(copytext(new_facial, 6, 8))

				if("f_style")
					var/list/valid_facialhairstyles = get_valid_styles_from_cache(facial_hairs_cache)
					var/new_f_style = input(user, "Choose your character's facial-hair style:", "Character facial-hair style", f_style) as null|anything in valid_facialhairstyles
					if(new_f_style)
						f_style = new_f_style

				if("f_style_left")
					var/list/valid_facialhairstyles = get_valid_styles_from_cache(facial_hairs_cache)
					f_style = valid_facialhairstyles[f_style][LEFT]

				if("f_style_right")
					var/list/valid_facialhairstyles = get_valid_styles_from_cache(facial_hairs_cache)
					f_style = valid_facialhairstyles[f_style][RIGHT]

				if("underwear")
					if(!specie_obj.flags[HAS_UNDERWEAR])
						return
					var/list/underwear_options
					if(gender == MALE)
						underwear_options = underwear_m
					else
						underwear_options = underwear_f

					var/new_underwear = input(user, "Choose your character's underwear:", "Character Preference", underwear_options[underwear]) as null|anything in underwear_options
					if(new_underwear)
						underwear = underwear_options.Find(new_underwear)

				if("undershirt")
					var/list/undershirt_options
					undershirt_options = undershirt_t

					var/new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference", undershirt_options[undershirt]) as null|anything in undershirt_options
					if (new_undershirt)
						undershirt = undershirt_options.Find(new_undershirt)
				if("socks")
					var/list/socks_options
					socks_options = socks_t
					var/new_socks = input(user, "Choose your character's socks:", "Character Preference", socks_options[socks]) as null|anything in socks_options
					if(new_socks)
						socks = socks_options.Find(new_socks)

				if("eyes")
					var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference", rgb(r_eyes, g_eyes, b_eyes)) as color|null
					if(new_eyes)
						r_eyes = hex2num(copytext(new_eyes, 2, 4))
						g_eyes = hex2num(copytext(new_eyes, 4, 6))
						b_eyes = hex2num(copytext(new_eyes, 6, 8))

				if("s_tone")
					if(!specie_obj.flags[HAS_SKIN_TONE])
						return
					var/new_s_tone = input(user, "Choose your character's skin-tone:\n(Light 1 - 220 Dark)", "Character Preference", 35 - s_tone ) as num|null
					if(new_s_tone)
						s_tone = 35 - max(min( round(new_s_tone), 220),1)

				if("skin")
					if(!specie_obj.flags[HAS_SKIN_COLOR])
						return
					var/new_skin = input(user, "Choose your character's skin colour: ", "Character Preference", rgb(r_skin, g_skin, b_skin)) as color|null
					if(new_skin)
						r_skin = hex2num(copytext(new_skin, 2, 4))
						g_skin = hex2num(copytext(new_skin, 4, 6))
						b_skin = hex2num(copytext(new_skin, 6, 8))

				if("bag")
					var/new_backbag = input(user, "Choose your character's style of bag:", "Character Preference", backbaglist[backbag]) as null|anything in backbaglist
					if(new_backbag)
						backbag = backbaglist.Find(new_backbag)

				if("use_skirt")
					use_skirt = !use_skirt

				if("nt_relation")
					var/new_relation = input(user, "Choose your relation to NT. Note that this represents what others can find out about your character by researching your background, not what your character actually thinks.", "Nanotrasen Relation", nanotrasen_relation) as null|anything in list("Loyal", "Supportive", "Neutral", "Skeptical", "Opposed")
					if(new_relation)
						nanotrasen_relation = new_relation

				if("home_system")
					var/choice = input(user, "Please choose a home system.", "Home System", home_system) as null|anything in home_system_choices + list("None","Other") + home_system
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = sanitize_name(input(user, "Please enter a home system.", "Home System", home_system) as text|null)
						if(raw_choice)
							home_system = raw_choice
						else
							to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
						return
					home_system = choice

				if("citizenship")
					var/choice = input(user, "Please choose your current citizenship.", "Citizenship", citizenship) as null|anything in citizenship_choices + list("None","Other") + citizenship
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = sanitize_name(input(user, "Please enter your current citizenship.", "Citizenship", citizenship) as text|null)
						if(raw_choice)
							citizenship = raw_choice
						else
							to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
						return
					citizenship = choice

				if("faction")
					var/choice = input(user, "Please choose a faction to work for.", "Faction", faction) as null|anything in faction_choices + list("None","Other") + faction
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = sanitize_name(input(user, "Please enter a faction.", "Faction", faction) as text|null)
						if(raw_choice)
							faction = raw_choice
						else
							to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
						return
					faction = choice

				if("religion")
					var/choice = input(user, "Please choose a religion.", "Religion", religion) as null|anything in religion_choices + list("None","Other") + religion
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = sanitize_name(input(user, "Please enter a religion.", "Religion", religion) as text|null)
						if(raw_choice)
							religion = raw_choice
						else
							to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
						return
					religion = choice

				if("flavor_text")
					var/msg = sanitize(input(usr,"Set the flavor text in your 'examine' verb.","Flavor Text", input_default(flavor_text)) as message)

					if(msg != null)
						flavor_text = msg

				if("organs")
					var/menu_type = input(user, "Menu") as null|anything in list("Limbs", "Organs")
					if(!menu_type) return

					switch(menu_type)
						if("Limbs")
							var/limb_name = input(user, "Which limb do you want to change?") as null|anything in list("Left Leg","Right Leg","Left Arm","Right Arm")
							if(!limb_name) return

							var/limb = null
							switch(limb_name)
								if("Left Leg")
									limb = BP_L_LEG
								if("Right Leg")
									limb = BP_R_LEG
								if("Left Arm")
									limb = BP_L_ARM
								if("Right Arm")
									limb = BP_R_ARM

							var/new_state = input(user, "What state do you wish the limb to be in?") as null|anything in list("Normal","Amputated","Prothesis")
							if(!new_state) return

							switch(new_state)
								if("Normal")
									organ_data[limb] = null
								if("Amputated")
									organ_data[limb] = "amputated"
								if("Prothesis")
									organ_data[limb] = "cyborg"

						if("Organs")
							var/organ_name = input(user, "Which internal function do you want to change?") as null|anything in list("Heart", "Eyes")
							if(!organ_name) return

							var/organ = null
							switch(organ_name)
								if("Heart")
									organ = O_HEART
								if("Eyes")
									organ = O_EYES

							var/new_state = input(user, "What state do you wish the organ to be in?") as null|anything in list("Normal","Assisted","Mechanical")
							if(!new_state) return

							switch(new_state)
								if("Normal")
									organ_data[organ] = null
								if("Assisted")
									organ_data[organ] = "assisted"
								if("Mechanical")
									organ_data[organ] = "mechanical"
				// Choosing a head for an IPC
				if("ipc_head")
					var/list/ipc_heads = list("Default", "Alien", "Double", "Pillar", "Human")
					ipc_head = input("Please select a head type", "Character Generation", null) in ipc_heads
					h_style = random_hair_style(gender, species, ipc_head)

		else
			switch(href_list["preference"])
				if("gender")
					if(gender == MALE)
						gender = FEMALE
					else
						gender = MALE

					f_style = random_facial_hair_style(gender, species)
					h_style = random_hair_style(gender, species, ipc_head)

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

/datum/preferences/proc/get_valid_styles_from_cache(list/styles_cache)
	var/hash = "[species][gender][species == IPC ? ipc_head : ""]"
	return styles_cache[hash] || list()

/proc/get_valid_styles_from_cache(styles_cache, species, gender, ipc_head = "Default")
	var/hash = "[species][gender][species == IPC ? ipc_head : ""]"
	return styles_cache[hash] || list()

/datum/preferences/proc/get_left_right_style_num(direction, list/styles_list, style)
	var/style_num = styles_list.Find(style)
	switch(direction)
		if(LEFT)
			style_num = (style_num != 1) ? style_num - 1 : styles_list.len
		if(RIGHT)
			style_num = (style_num != styles_list.len) ? style_num + 1 : 1
	return style_num
