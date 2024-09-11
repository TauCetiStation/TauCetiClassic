/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. Filters harmful gases from the air."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "gas_mask_tc"
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	body_parts_covered = FACE|EYES
	w_class = SIZE_SMALL
	item_state = "gas_mask_tc"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	siemens_coefficient = 0.9
	var/gas_filter_strength = 1			//For gas mask filters
	var/filter = list("phoron", "sleeping_agent", "fractol")

// **** Welding gas mask ****

/obj/item/clothing/mask/gas/welding
	name = "welding mask"
	desc = "A gas mask with built-in welding goggles and a face shield. Looks like a skull - clearly designed by a nerd."
	icon_state = "weldingmask"
	item_state = "weldingmask"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags_inv = (HIDEEARS|HIDEEYES|HIDEFACE)
	origin_tech = "materials=2;engineering=2"
	siemens_coefficient = 0.9
	body_parts_covered = FACE|EYES
	w_class = SIZE_SMALL
	flash_protection = FLASHES_FULL_PROTECTION
	flash_protection_slots = list(SLOT_WEAR_MASK)
	var/up = 0
	item_action_types = list(/datum/action/item_action/hands_free/toggle_welding_mask)

/datum/action/item_action/hands_free/toggle_welding_mask
	name = "Toggle Welding Mask"

/obj/item/clothing/mask/gas/welding/attack_self()
	toggle()

/obj/item/clothing/mask/gas/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding mask"
	set src in usr

	if(!usr.incapacitated())
		if(src.up)
			src.up = !src.up
			src.flags |= (HEADCOVERSEYES | HEADCOVERSMOUTH)
			flags_inv |= (HIDEEARS|HIDEEYES|HIDEFACE)
			body_parts_covered |= EYES
			icon_state = initial(icon_state)
			flash_protection = FLASHES_FULL_PROTECTION
			to_chat(usr, "You adjust \the [src] down to protect your eyes.")
		else
			src.up = !src.up
			src.flags &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
			flags_inv &= ~(HIDEEARS|HIDEEYES|HIDEFACE)
			body_parts_covered &= ~EYES
			icon_state = "[initial(icon_state)]up"
			flash_protection = NONE
			to_chat(usr, "You push \the [src] up out of your face.")

		update_inv_mob()
		update_item_actions()

// ********************************************************************

// **** Security gas mask (TG-stuff) ****
/obj/item/clothing/mask/gas/sechailer
	name = "security gas mask"
	desc = "Стандартный противогаз охраны с модификацией Compli-o-nator 3000. Применяется для убеждения не двигаться, пока офицер забивает преступника насмерть."
	icon_state = "secmask"
	item_state = "secmask"
	var/cooldown = 0
	var/last_phrase_text = ""
	var/shitcurity_mode = FALSE
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	item_action_types = list(/datum/action/item_action/hands_free/toggle_mask)


	var/static/list/phrases_lawful = list(
		"Не двигаться!" = 'sound/voice/complionator/lawful_ne_dvigatsya.ogg',
		"Ни с места!" = 'sound/voice/complionator/lawful_ni_s_mesta.ogg',
		"Стоять!" = 'sound/voice/complionator/lawful_stoyat.ogg',
		"Стоять на месте!" = 'sound/voice/complionator/lawful_stoyat_na_meste.ogg')

	var/static/list/pharses_shitcurity = list(
		"Давай, попробуй побежать. Безмозглый идиот." = 'sound/voice/complionator/davai_poprobui_pobejat.ogg',
		"Неудачник выбрал не тот день для нарушения закона." = 'sound/voice/complionator/neudachnik_vybral.ogg',
		"Сейчас узнаешь что такое настоящее правосудие, мудак." = 'sound/voice/complionator/seychas_uznaesh.ogg',
		"Стой! Преступное отродье." = 'sound/voice/complionator/stoy_prestupnoe.ogg',
		"Только двинешься и я оторву тебе бошку." = 'sound/voice/complionator/tolko_dvineshsya.ogg',
		"Укрыться от правосудия у тебя удастся только крышкой гроба." = 'sound/voice/complionator/ukrytsya_ot_pravosudia.ogg',
		"Упал мордой в пол, тварь." = 'sound/voice/complionator/upal_mordoy_v.ogg',
		"У вас есть только право закрыть свой пиздак нахуй." = 'sound/voice/complionator/u_vas_est_tolko.ogg',
		"Виновен или невиновен - это лишь вопрос времени." = 'sound/voice/complionator/vinoven_ili_nevinoven.ogg',
		"Я - закон. Ты - убогое ничтожество." = 'sound/voice/complionator/ya_zakon_ty.ogg',
		"Живым или мертвым - ты пиздуешь со мной." = 'sound/voice/complionator/zhivym_ili_mertvym.ogg')

/datum/action/item_action/hands_free/toggle_mask
	name = "Toggle Mask"

/obj/item/clothing/mask/gas/sechailer/attackby(obj/item/I, mob/user, params)
	if(isscrewing(I))
		var/obj/item/weapon/screwdriver/S = I
		if(S.use_tool(src, user, SKILL_TASK_TRIVIAL, volume = 40))
			shitcurity_mode = !shitcurity_mode
			to_chat(user, "<span class='notice'>Вы подкрутили встроенный Compli-o-nator 3000.</span>")
	else
		return ..()

/obj/item/clothing/mask/gas/sechailer/attack_self()
	halt()

/obj/item/clothing/mask/gas/sechailer/verb/halt()
	set category = "Object"
	set name = "HALT"
	set src in usr
	if(!isliving(usr)) return
	if(usr.incapacitated())
		return

	if(cooldown < world.time)
		var/phrase_sound
		var/phrase_text

		if(shitcurity_mode)
			do
				phrase_text = pick(pharses_shitcurity)
			while(last_phrase_text == phrase_text)
			phrase_sound = pharses_shitcurity[phrase_text]
			cooldown = world.time + 4 SECOND
		else
			do
				phrase_text = pick(phrases_lawful)
			while(last_phrase_text == phrase_text)
			phrase_sound = phrases_lawful[phrase_text]
			cooldown = world.time + 2 SECOND
		last_phrase_text = phrase_text

		playsound(src, phrase_sound, VOL_EFFECTS_MASTER, 100, FALSE, falloff = 5)
		usr.visible_message("[usr] compli-o-nator, <font color='red' size='4'><b>\"[phrase_text]\"</b></font>")

/obj/item/clothing/mask/gas/sechailer/police
	name = "police respirator"
	desc = "Стандартный распиратор полиции с модификацией Compli-o-nator 3000. Применяется для убеждения не двигаться, пока полицейский забивает преступника насмерть."
	icon_state = "police_mask"
	item_state = "police_mask"
	flags = MASKCOVERSMOUTH | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS

//Plague Dr suit can be found in clothing/suits/bio.dm
/obj/item/clothing/mask/gas/plaguedoctor
	name = "plague doctor mask"
	desc = "A modernised version of the classic design, this mask will not only filter out phoron but it can also be connected to an air supply."
	icon_state = "plaguedoctor"
	item_state = "gas_mask"
	armor = list(melee = 0, bullet = 0, laser = 2,energy = 2, bomb = 0, bio = 75, rad = 0)
	body_parts_covered = HEAD|FACE

/obj/item/clothing/mask/gas/swat
	name = "SWAT mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "swat"
	item_state = "swat"
	siemens_coefficient = 0.7
	body_parts_covered = FACE|EYES

/obj/item/clothing/mask/gas/syndicate
	name = "syndicate mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "mask_syndi"
	item_state = "mask_syndi"
	siemens_coefficient = 0.7

/obj/item/clothing/mask/gas/voice
	name = "gas mask"
	icon_state = "gas_mask_orange"
	//desc = "A face-covering mask that can be connected to an air supply. It seems to house some odd electronics."
	var/mode = 0// 0==Scouter | 1==Night Vision | 2==Thermal | 3==Meson
	var/voice = "Unknown"
	var/vchange = 0//This didn't do anything before. It now checks if the mask has special functions/N
	origin_tech = "syndicate=4"

/obj/item/clothing/mask/gas/voice/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	vchange = 1
	siemens_coefficient = 0.2
	var/hud = FALSE

/obj/item/clothing/mask/gas/clown_hat
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	icon_state = "clown"
	item_state = "clown_hat"
	flags = MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS

/obj/item/clothing/mask/gas/sexyclown
	name = "sexy-clown wig and mask"
	desc = "A feminine clown mask for the dabbling crossdressers or female entertainers."
	icon_state = "sexyclown"
	item_state = "sexyclown"
	flags = MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS

/obj/item/clothing/mask/gas/mime
	name = "mime mask"
	desc = "The traditional mime's mask. It has an eerie facial posture."
	icon_state = "mime"
	flags = MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS

/obj/item/clothing/mask/gas/fawkes //--getup1
	name = "strange mask"
	desc = "Remember, remember, the fifth of November"
	icon_state = "fawkes"

/obj/item/clothing/mask/gas/monkeymask
	name = "monkey mask"
	desc = "A mask used when acting as a monkey."
	icon_state = "monkeymask"
	item_state = "monkeymask"
	body_parts_covered = HEAD|FACE|EYES

/obj/item/clothing/mask/gas/sexymime
	name = "sexy mime mask"
	desc = "A traditional female mime's mask."
	icon_state = "sexymime"
	flags = MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS

/obj/item/clothing/mask/gas/death_commando
	name = "death commando mask"
	icon_state = "death_commando_mask"
	item_state = "death_commando_mask"
	siemens_coefficient = 0.2

/obj/item/clothing/mask/gas/cyborg
	name = "cyborg visor"
	desc = "Beep boop."
	icon_state = "death"

/obj/item/clothing/mask/gas/owl_mask
	name = "owl mask"
	desc = "Twoooo!"
	icon_state = "owl"

/obj/item/clothing/mask/gas/coloured
	icon_state = "gas_mask_orange"

/obj/item/clothing/mask/gas/coloured/examine(mob/user)
	..()
	if(src in user)
		to_chat(user, "The small label on the back side tells: \"Designed by W&J Company\".")

/obj/item/clothing/mask/gas/coloured/atom_init()
	. = ..()
	var/color = pick("orange", "blue")
	icon_state = "gas_mask_[color]"

/obj/item/clothing/mask/gas/vox
	name = "vox breath mask"
	desc = "A weirdly-shaped breath mask."
	icon_state = "voxmask"
	item_state = "voxmask"
	flags = MASKCOVERSMOUTH | MASKINTERNALS | BLOCK_GAS_SMOKE_EFFECT
	flags_inv = 0
	body_parts_covered = 0
	w_class = SIZE_TINY
	gas_transfer_coefficient = 0.10
	filter = list("phoron", "sleeping_agent", "oxygen", "fractol")
	species_restricted = list(VOX , VOX_ARMALIS)

/obj/item/clothing/mask/gas/German
	name = "German Gas Mask"
	desc = "Soldier's black gas mask."
	icon_state = "German_gasmask"
