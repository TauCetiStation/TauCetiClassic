/area/pluvia_heaven
	name = "Pluvia Heaven"
	icon_state = "unexplored"

/var/global/social_credit_threshold = 5

/mob/living/carbon/human/proc/bless()
	to_chat(src, "<span class='notice'>\ <font size=4>Высшая сила засвидетельствовала ваш подвиг. Врата рая ожидают вас.</span></font>")
	src.blessed = 1
	playsound_local(null, 'sound/effects/blessed.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	var/image/eye = image('icons/mob/human_face.dmi', icon_state = "pluvia_ms_s")
	eye.plane = ABOVE_LIGHTING_PLANE
	add_overlay(eye)

/obj/item/weapon/bless_vote
	name = "Рекомендательное письмо"
	desc = "Билет до рая." // я лучше сам напишу сразу по русски, чем придет кринж-депортамент и напереводит по-свойму
	w_class = SIZE_TINY
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	var/mob/living/carbon/human/owner

/obj/item/weapon/bless_vote/attack_self(mob/living/carbon/user)
	user.set_machine(src)
	var/dat
	dat = "<B><font color = ##ff0000>Рекомендательное письмо для прохода в рай</B><BR>"
	dat += "<I><font color = ##ff0000>Подписывая эту бумагу, вы подтверждаете что считаете [owner] достойным(ой) попасть в рай, после его(её) смерти</I><BR><BR>"
	dat += "<I><font color = ##ff0000>Просто поднесите палец к месту для подписи и слегка надколите об шип на бумаге.</I><BR>"
	dat += "<A href='byond://?src=\ref[src];choice=yes'>ПОДПИСАТЬ</A><BR>"
	var/datum/browser/popup = new(user, "window=radio", "Рекомендательное письмо")
	popup.set_content(dat)
	popup.open()

/obj/item/weapon/bless_vote/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/H = usr
	if(href_list["choice"] == "yes")
		if(H.bless_vote > 0)
			to_chat(usr, "<span class='notice'>Подписано!</span>")
			H.bless_vote -= 1
			owner.social_credit += 1
			to_chat(owner, "<span class='notice'>Ваш уровень кармы повышен!</span>")
			qdel(src)
		else
			to_chat(usr, "<span class='notice'>У вас нет права голоса</span>")
