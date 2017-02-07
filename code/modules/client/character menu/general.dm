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
	. += 						"<table width='100%' cellpadding='1' cellspacing='0'>"
	. += 							"<td background='dossier_photos.png' style='background-repeat: no-repeat'>"
	. += 							"<img src=previewicon.png width=[preview_icon.Width()] height=[preview_icon.Height()]>"
	. += 							"</td>"
	. += 						"</table>"
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
	. += 						"[submenu_type=="disabil_menu"?"<b>Disabilities</b>":"<a href=\"byond://?src=\ref[user];preference=disabil_menu\">Disabilities</a>"] - "
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
				//world << "[ind] \ [organ_data.len]"
				var/status = organ_data[name]
				var/organ_name = null
				switch(name)
					if("l_arm")
						organ_name = "left arm"
					if("r_arm")
						organ_name = "right arm"
					if("l_leg")
						organ_name = "left leg"
					if("r_leg")
						organ_name = "right leg"
					if("l_foot")
						organ_name = "left foot"
					if("r_foot")
						organ_name = "right foot"
					if("l_hand")
						organ_name = "left hand"
					if("r_hand")
						organ_name = "right hand"
					if("heart")
						organ_name = "heart"
					if("eyes")
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

		//Adjustment
		if("disabil_menu")
			. += "<b>Disabilities:</b>"
			. += "<br>"
			. += ShowDisabilityState(user,DISABILITY_NEARSIGHTED,"Needs Glasses")
			. += ShowDisabilityState(user,DISABILITY_COUGHING,"Coughing")
			. += ShowDisabilityState(user,DISABILITY_EPILEPTIC,"Seizures")
			. += ShowDisabilityState(user,DISABILITY_TOURETTES,"Twitching")
			. += ShowDisabilityState(user,DISABILITY_NERVOUS,"Nervousness")
			. += ShowDisabilityState(user,DISABILITY_FATNESS,"Fatness")

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
	. += 						"<br>Home system</b>: <a href='byond://?src=\ref[user];preference=home_system;task=input'>[home_system]</a>"
	. += 						"<br>Citizenship</b>: <a href='byond://?src=\ref[user];preference=citizenship;task=input'>[citizenship]</a>"
	. += 						"<br>Faction: <a href='byond://?src=\ref[user];preference=faction;task=input'>[faction]</a>"
	. += 						"<br>Religion: <a href='byond://?src=\ref[user];preference=religion;task=input'>[religion]</a>"
	. += 						"<br>"

	if(jobban_isbanned(user, "Records"))
		. += 					"<br><b>You are banned from using character records.</b><br>"
	else
		. += 					"<br><b>Records:</b>"
		. += 					"<br>Medical Records:"
		. += 					" <a href=\"byond://?src=\ref[user];preference=records;task=med_record\">[length(med_record)>0?"[sanitize_popup(copytext(med_record, 1, 3))]...":"\[...\]"]</a>"
		. += 					"<br>Security Records:"
		. += 					" <a href=\"byond://?src=\ref[user];preference=records;task=sec_record\">[length(sec_record)>0?"[sanitize_popup(copytext(sec_record, 1, 3))]...":"\[...\]"]</a>"
		. += 					"<br>Employment Records:"
		. += 					" <a href=\"byond://?src=\ref[user];preference=records;task=gen_record\">[length(gen_record)>0?"[sanitize_popup(copytext(gen_record, 1, 3))]...":"\[...\]"]</a>"

	. += 						"<br><br>"

	. += 						"<b>Flavor:</b>"
	. += 						" <a href='byond://?src=\ref[user];preference=flavor_text;task=input'>[length(flavor_text)>0?"[sanitize_popup(copytext(flavor_text, 1, 3))]...":"\[...\]"]</a>"
	. += 					"</td>"
	. += 				"</tr>"
	. += 			"</table>"	//Backstory table end
	. += 		"</td>"
	. += 	"</tr>"
	. += "</table>"	//Main body table end


/datum/preferences/proc/ShowDisabilityState(mob/user,flag,label)
	return "[label]: <a href=\"?_src_=prefs;task=input;preference=disabilities;disability=[flag]\">[disabilities & flag ? "<b>Yes</b>" : "No"]</a><br>"

/datum/preferences/proc/process_link_general(mob/user, list/href_list)
	switch(href_list["preference"])
		if("disabilities")
			if(href_list["task"] == "input")
				var/dflag=text2num(href_list["disability"])
				if(dflag >= 0)
					disabilities ^= text2num(href_list["disability"]) //MAGIC

		if("records")
			switch(href_list["task"])
				if("med_record")
					var/medmsg = sanitize(copytext(input(usr,"Set your medical notes here.","Medical Records",html_decode(revert_ja(med_record))) as message, 1, MAX_PAPER_MESSAGE_LEN), list("ÿ"=LETTER_255))

					if(medmsg != null)
						med_record = medmsg

				if("sec_record")
					var/secmsg = sanitize(copytext(input(usr,"Set your security notes here.","Security Records",html_decode(revert_ja(sec_record))) as message, 1, MAX_PAPER_MESSAGE_LEN), list("ÿ"=LETTER_255))

					if(secmsg != null)
						sec_record = secmsg

				if("gen_record")
					var/genmsg = sanitize(copytext(input(usr,"Set your employment notes here.","Employment Records",html_decode(revert_ja(gen_record))) as message, 1, MAX_PAPER_MESSAGE_LEN), list("ÿ"=LETTER_255))

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
					var/new_name = reject_bad_name( input(user, "Choose your character's name:", "Character Preference")  as text|null )
					if(new_name)
						real_name = new_name
					else
						to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")

				if("age")
					var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Character Preference") as num|null
					if(new_age)
						age = max(min( round(text2num(new_age)), AGE_MAX),AGE_MIN)

				if("species")
					var/list/new_species = list("Human")
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
						f_style = random_facial_hair_style(gender, species)
						h_style = random_hair_style(gender, species)

				if("language")
					var/languages_available
					var/list/new_languages = list("None")
					var/datum/species/S = all_species[species]

					//I don't understant, how it works(and does not), so..
					if(config.usealienwhitelist)
						for(var/L in all_languages)
							var/datum/language/lang = all_languages[L]
							if((!(lang.flags & RESTRICTED)) && (is_alien_whitelisted(user, L)||(!( lang.flags & WHITELISTED ))||(S && (L in S.secondary_langs))))
								new_languages += lang.name
								languages_available = 1

						if(!(languages_available))
							alert(user, "There are not currently any available secondary languages.")
					else
						for(var/L in all_languages)
							var/datum/language/lang = all_languages[L]
							if(!(lang.flags & RESTRICTED))
								new_languages += lang.name
					for(var/L in all_languages)
						var/datum/language/lang = all_languages[L]
						if(!(lang.flags & RESTRICTED))
							new_languages += lang.name

					language = input("Please select a secondary language", "Character Generation", null) in new_languages

				if("b_type")
					var/new_b_type = input(user, "Choose your character's blood-type:", "Character Preference") as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )
					if(new_b_type)
						b_type = new_b_type

				if("hair")
					if(species == "Human" || species == "Unathi" || species == "Tajaran" || species == "Skrell")
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
					if(species != "Human")
						return
					var/new_s_tone = input(user, "Choose your character's skin-tone:\n(Light 1 - 220 Dark)", "Character Preference")  as num|null
					if(new_s_tone)
						s_tone = 35 - max(min( round(new_s_tone), 220),1)

				if("skin")
					if(species == "Unathi" || species == "Tajaran" || species == "Skrell")
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
						var/raw_choice = input(user, "Please enter a home system.")  as text|null
						if(raw_choice)
							home_system = sanitize(copytext(raw_choice,1,MAX_MESSAGE_LEN))
						return
					home_system = choice

				if("citizenship")
					var/choice = input(user, "Please choose your current citizenship.") as null|anything in citizenship_choices + list("None","Other")
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = input(user, "Please enter your current citizenship.", "Character Preference") as text|null
						if(raw_choice)
							citizenship = sanitize(copytext(raw_choice,1,MAX_MESSAGE_LEN))
						return
					citizenship = choice

				if("faction")
					var/choice = input(user, "Please choose a faction to work for.") as null|anything in faction_choices + list("None","Other")
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = input(user, "Please enter a faction.")  as text|null
						if(raw_choice)
							faction = sanitize(copytext(raw_choice,1,MAX_MESSAGE_LEN))
						return
					faction = choice

				if("religion")
					var/choice = input(user, "Please choose a religion.") as null|anything in religion_choices + list("None","Other")
					if(!choice)
						return
					if(choice == "Other")
						var/raw_choice = input(user, "Please enter a religon.")  as text|null
						if(raw_choice)
							religion = sanitize(copytext(raw_choice,1,MAX_MESSAGE_LEN))
						return
					religion = choice

				if("flavor_text")
					var/msg = sanitize(copytext(input(usr,"Set the flavor text in your 'examine' verb.","Flavor Text",html_decode(revert_ja(flavor_text))) as message, 1, MAX_MESSAGE_LEN))

					if(msg != null)
						flavor_text = msg

				if("organs")
					var/menu_type = input(user, "Menu") as null|anything in list("Limbs", "Internal Organs")
					if(!menu_type) return

					switch(menu_type)
						if("Limbs")
							var/limb_name = input(user, "Which limb do you want to change?") as null|anything in list("Left Leg","Right Leg","Left Arm","Right Arm","Left Foot","Right Foot","Left Hand","Right Hand")
							if(!limb_name) return

							var/limb = null
							var/second_limb = null // if you try to change the arm, the hand should also change
							var/third_limb = null  // if you try to unchange the hand, the arm should also change
							switch(limb_name)
								if("Left Leg")
									limb = "l_leg"
									second_limb = "l_foot"
								if("Right Leg")
									limb = "r_leg"
									second_limb = "r_foot"
								if("Left Arm")
									limb = "l_arm"
									second_limb = "l_hand"
								if("Right Arm")
									limb = "r_arm"
									second_limb = "r_hand"
								if("Left Foot")
									limb = "l_foot"
									third_limb = "l_leg"
								if("Right Foot")
									limb = "r_foot"
									third_limb = "r_leg"
								if("Left Hand")
									limb = "l_hand"
									third_limb = "l_arm"
								if("Right Hand")
									limb = "r_hand"
									third_limb = "r_arm"

							var/new_state = input(user, "What state do you wish the limb to be in?") as null|anything in list("Normal","Amputated","Prothesis")
							if(!new_state) return

							switch(new_state)
								if("Normal")
									organ_data[limb] = null
									if(third_limb)
										organ_data[third_limb] = null
								if("Amputated")
									organ_data[limb] = "amputated"
									if(second_limb)
										organ_data[second_limb] = "amputated"
								if("Prothesis")
									organ_data[limb] = "cyborg"
									if(second_limb)
										organ_data[second_limb] = "cyborg"

						if("Internal Organs")
							var/organ_name = input(user, "Which internal function do you want to change?") as null|anything in list("Heart", "Eyes")
							if(!organ_name) return

							var/organ = null
							switch(organ_name)
								if("Heart")
									organ = "heart"
								if("Eyes")
									organ = "eyes"

							var/new_state = input(user, "What state do you wish the organ to be in?") as null|anything in list("Normal","Assisted","Mechanical")
							if(!new_state) return

							switch(new_state)
								if("Normal")
									organ_data[organ] = null
								if("Assisted")
									organ_data[organ] = "assisted"
								if("Mechanical")
									organ_data[organ] = "mechanical"

				if("skin_style")
					var/skin_style_name = input(user, "Select a new skin style") as null|anything in list("default1", "default2", "default3")
					if(!skin_style_name) return

		else
			switch(href_list["preference"])
				if("gender")
					if(gender == MALE)
						gender = FEMALE
					else
						gender = MALE

					f_style = random_facial_hair_style(gender, species)
					h_style = random_hair_style(gender, species)

				if("disabilities")				//please note: current code only allows nearsightedness as a disability
					disabilities = !disabilities//if you want to add actual disabilities, code that selects them should be here

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

				if("disabil_menu")
					submenu_type = "disabil_menu"

				if("gear")
					submenu_type = "gear"
