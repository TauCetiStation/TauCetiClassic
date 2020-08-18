/obj/item/weapon/dnainjector
	name = "DNA-Injector"
	desc = "This injects the person with DNA."
	icon = 'icons/obj/items.dmi'
	icon_state = "dnainjector"
	var/block=0
	var/datum/dna2/record/buf=null
	var/s_time = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_TINY
	var/uses = 1
	var/nofail
	var/is_bullet = 0
	var/inuse = 0

	// USE ONLY IN PREMADE SYRINGES.  WILL NOT WORK OTHERWISE.
	var/datatype=0
	var/value=0

/obj/item/weapon/dnainjector/atom_init()
	. = ..()
	if(datatype && block)
		buf = new
		buf.dna = new
		buf.types = datatype
		buf.dna.ResetSE()
		//testing("[name]: DNA2 SE blocks prior to SetValue: [english_list(buf.dna.SE)]")
		SetValue(value)
		//testing("[name]: DNA2 SE blocks after SetValue: [english_list(buf.dna.SE)]")

/obj/item/weapon/dnainjector/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/weapon/dnainjector/proc/GetRealBlock(selblock)
	if(selblock==0)
		return block
	else
		return selblock

/obj/item/weapon/dnainjector/proc/GetState(selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.GetSEState(real_block)
	else
		return buf.dna.GetUIState(real_block)

/obj/item/weapon/dnainjector/proc/SetState(on, selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.SetSEState(real_block,on)
	else
		return buf.dna.SetUIState(real_block,on)

/obj/item/weapon/dnainjector/proc/GetValue(selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.GetSEValue(real_block)
	else
		return buf.dna.GetUIValue(real_block)

/obj/item/weapon/dnainjector/proc/SetValue(val,selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.SetSEValue(real_block,val)
	else
		return buf.dna.SetUIValue(real_block,val)

/obj/item/weapon/dnainjector/proc/inject(mob/M, mob/user)
	user.remove_from_mob(src)
	loc = null

	if(istype(M,/mob/living))
		M.radiation += rand(15,45)
		M.dna_inject_count += rand(1,3)

	if (!(NOCLONE in M.mutations)) // prevents drained people from having their DNA changed
		if (buf.types & DNA2_BUF_UI)
			if (!block) //isolated block?
				M.UpdateAppearance(buf.dna.UI.Copy())
				if (buf.types & DNA2_BUF_UE) //unique enzymes? yes
					M.real_name = buf.dna.real_name
					M.name = buf.dna.real_name
					M.dna.unique_enzymes = buf.dna.unique_enzymes // bullshit
				uses--
			else
				M.dna.SetUIValue(block,src.GetValue())
				M.UpdateAppearance()
				uses--
		if (buf.types & DNA2_BUF_SE)
			if (!block) //isolated block?
				M.dna.SE = buf.dna.SE.Copy()
				M.dna.UpdateSE()
			else
				M.dna.SetSEValue(block,src.GetValue())
			domutcheck(M, null, block!=null, 0) //#Z2 We go thru chance check
			uses--

			if(M && prob(5 + M.dna_inject_count))
				M.dna_inject_count = 0
				trigger_side_effect(M)

	qdel(src)

/obj/item/weapon/dnainjector/attack(mob/living/carbon/M, mob/living/user)
	if (!istype(M))
		return
	if(!M.try_inject(user, TRUE))
		return

	M.log_combat(user, "injected with [name]")

	if (buf.types & DNA2_BUF_SE)
		if(block)// Isolated injector
			//testing("Isolated block [block] injector with contents: [GetValue()]")
			if (GetState() && block == MONKEYBLOCK)
				message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name] (MONKEY) [ADMIN_JMP(user)]")
				log_attack("[key_name(user)] injected [key_name(M)] with the Isolated [name] (MONKEY)")
				log_game("[key_name(user)] injected [key_name(M)] with the Isolated [name] (MONKEY)")
			else
				message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name] ([assigned_blocks[block]]) [ADMIN_JMP(user)]")
				log_attack("[key_name(user)] injected [key_name(M)] with the Isolated [name] ([assigned_blocks[block]])")

		else
			//testing("DNA injector with contents: [english_list(buf.dna.SE)]")
			if (GetState(MONKEYBLOCK))
				message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] (MONKEY) [ADMIN_JMP(user)]")
				log_attack("[key_name(user)] injected [key_name(M)] with the [name] (MONKEY)")
				log_game("[key_name(user)] injected [key_name(M)] with the [name] (MONKEY)")
			else
				//message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name]")
				log_attack("[key_name(user)] injected [key_name(M)] with the [name]")
	else if (buf.types & DNA2_BUF_UE)
		message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] (UE of [buf.dna.real_name])")
		log_attack("[key_name(user)] injected [key_name(M)] with the [name] (UE of [buf.dna.real_name])")
		user.visible_message("<span class='warning'>[user] injects [M] with the DNA Injector!</span>")
	else
		//message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name]")
		log_attack("[key_name(user)] injected [key_name(M)] with the [name]")
		user.visible_message("<span class='warning'>[user] injects [M] with the DNA Injector!</span>")

	add_fingerprint(user)
	inject(M, user)


/obj/item/weapon/dnainjector/hulkmut
	name = "DNA-Injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/weapon/dnainjector/hulkmut/atom_init()
	block = HULKBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antihulk
	name = "DNA-Injector (Anti-Hulk)"
	desc = "Cures green skin."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/weapon/dnainjector/antihulk/atom_init()
	block = HULKBLOCK
	. = ..()

/obj/item/weapon/dnainjector/xraymut
	name = "DNA-Injector (Xray)"
	desc = "Finally you can see what the Captain does."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 8

/obj/item/weapon/dnainjector/xraymut/atom_init()
	block = XRAYBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antixray
	name = "DNA-Injector (Anti-Xray)"
	desc = "It will make you see harder."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 8

/obj/item/weapon/dnainjector/antixray/atom_init()
	block = XRAYBLOCK
	. = ..()

/obj/item/weapon/dnainjector/firemut
	name = "DNA-Injector (Fire)"
	desc = "Gives you fire."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 10


/obj/item/weapon/dnainjector/firemut/atom_init()
	block = FIREBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antifire
	name = "DNA-Injector (Anti-Fire)"
	desc = "Cures fire."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 10

/obj/item/weapon/dnainjector/antifire/atom_init()
	block = FIREBLOCK
	. = ..()

/obj/item/weapon/dnainjector/telemut
	name = "DNA-Injector (Tele.)"
	desc = "Super brain man!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 12

/obj/item/weapon/dnainjector/telemut/atom_init()
	block = TELEBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antitele
	name = "DNA-Injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 12

/obj/item/weapon/dnainjector/antitele/atom_init()
	block = TELEBLOCK
	. = ..()

/obj/item/weapon/dnainjector/nobreath
	name = "DNA-Injector (No Breath)"
	desc = "Hold your breath and count to infinity."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/weapon/dnainjector/nobreath/atom_init()
	block = NOBREATHBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antinobreath
	name = "DNA-Injector (Anti-No Breath)"
	desc = "Hold your breath and count to 100."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/weapon/dnainjector/antinobreath/atom_init()
	block = NOBREATHBLOCK
	. = ..()

/obj/item/weapon/dnainjector/remoteview
	name = "DNA-Injector (Remote View)"
	desc = "Stare into the distance for a reason."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/weapon/dnainjector/remoteview/atom_init()
	block = REMOTEVIEWBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antiremoteview
	name = "DNA-Injector (Anti-Remote View)"
	desc = "Cures green skin."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/weapon/dnainjector/antiremoteview/atom_init()
	block = REMOTEVIEWBLOCK
	. = ..()

/obj/item/weapon/dnainjector/regenerate
	name = "DNA-Injector (Regeneration)"
	desc = "Healthy but hungry."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/weapon/dnainjector/regenerate/atom_init()
	block = REGENERATEBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antiregenerate
	name = "DNA-Injector (Anti-Regeneration)"
	desc = "Sickly but sated."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/weapon/dnainjector/antiregenerate/atom_init()
	block = REGENERATEBLOCK
	. = ..()

/obj/item/weapon/dnainjector/runfast
	name = "DNA-Injector (Increase Run)"
	desc = "Running Man."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/weapon/dnainjector/runfast/atom_init()
	block = INCREASERUNBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antirunfast
	name = "DNA-Injector (Anti-Increase Run)"
	desc = "Walking Man."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/weapon/dnainjector/antirunfast/atom_init()
	block = INCREASERUNBLOCK
	. = ..()

/obj/item/weapon/dnainjector/morph
	name = "DNA-Injector (Morph)"
	desc = "A total makeover."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/weapon/dnainjector/morph/atom_init()
	block = MORPHBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antimorph
	name = "DNA-Injector (Anti-Morph)"
	desc = "Cures identity crisis."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/weapon/dnainjector/antimorph/atom_init()
	block = MORPHBLOCK
	. = ..()

/* No COLDBLOCK on bay
/obj/item/weapon/dnainjector/cold
	name = "DNA-Injector (Cold)"
	desc = "Feels a bit chilly."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/weapon/dnainjector/cold/atom_init()
	block = COLDBLOCK
	. = ..()

/obj/item/weapon/dnainjector/anticold
	name = "DNA-Injector (Anti-Cold)"
	desc = "Feels room-temperature."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/weapon/dnainjector/anticold/atom_init()
	block = COLDBLOCK
	. = ..()
*/

/obj/item/weapon/dnainjector/noprints
	name = "DNA-Injector (No Prints)"
	desc = "Better than a pair of budget insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/weapon/dnainjector/noprints/atom_init()
	block = NOPRINTSBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antinoprints
	name = "DNA-Injector (Anti-No Prints)"
	desc = "Not quite as good as a pair of budget insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/weapon/dnainjector/antinoprints/atom_init()
	block = NOPRINTSBLOCK
	. = ..()

/obj/item/weapon/dnainjector/insulation
	name = "DNA-Injector (Shock Immunity)"
	desc = "Better than a pair of real insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/weapon/dnainjector/insulation/atom_init()
	block = SHOCKIMMUNITYBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antiinsulation
	name = "DNA-Injector (Anti-Shock Immunity)"
	desc = "Not quite as good as a pair of real insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/weapon/dnainjector/antiinsulation/atom_init()
	block = SHOCKIMMUNITYBLOCK
	. = ..()

/obj/item/weapon/dnainjector/midgit
	name = "DNA-Injector (Small Size)"
	desc = "Makes you shrink."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/weapon/dnainjector/midgit/atom_init()
	block = SMALLSIZEBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antimidgit
	name = "DNA-Injector (Anti-Small Size)"
	desc = "Makes you grow. But not too much."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/weapon/dnainjector/antimidgit/atom_init()
	block = SMALLSIZEBLOCK
	. = ..()

/////////////////////////////////////
/obj/item/weapon/dnainjector/antiglasses
	name = "DNA-Injector (Anti-Glasses)"
	desc = "Toss away those glasses!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 1

/obj/item/weapon/dnainjector/antiglasses/atom_init()
	block = GLASSESBLOCK
	. = ..()

/obj/item/weapon/dnainjector/glassesmut
	name = "DNA-Injector (Glasses)"
	desc = "Will make you need dorkish glasses."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 1

/obj/item/weapon/dnainjector/glassesmut/atom_init()
	block = GLASSESBLOCK
	. = ..()

/obj/item/weapon/dnainjector/epimut
	name = "DNA-Injector (Epi.)"
	desc = "Shake shake shake the room!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 3

/obj/item/weapon/dnainjector/epimut/atom_init()
	block = HEADACHEBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antiepi
	name = "DNA-Injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 3

/obj/item/weapon/dnainjector/antiepi/atom_init()
	block = HEADACHEBLOCK
	. = ..()

/obj/item/weapon/dnainjector/anticough
	name = "DNA-Injector (Anti-Cough)"
	desc = "Will stop that awful noise."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 5

/obj/item/weapon/dnainjector/anticough/atom_init()
	block = COUGHBLOCK
	. = ..()

/obj/item/weapon/dnainjector/coughmut
	name = "DNA-Injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 5

/obj/item/weapon/dnainjector/coughmut/atom_init()
	block = COUGHBLOCK
	. = ..()

/obj/item/weapon/dnainjector/clumsymut
	name = "DNA-Injector (Clumsy)"
	desc = "Makes clumsy minions."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 6

/obj/item/weapon/dnainjector/clumsymut/atom_init()
	block = CLUMSYBLOCK
	. = ..()

/obj/item/weapon/dnainjector/anticlumsy
	name = "DNA-Injector (Anti-Clumy)"
	desc = "Cleans up confusion."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 6

/obj/item/weapon/dnainjector/anticlumsy/atom_init()
	block = CLUMSYBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antitour
	name = "DNA-Injector (Anti-Tour.)"
	desc = "Will cure tourrets."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 7

/obj/item/weapon/dnainjector/antitour/atom_init()
	block = TWITCHBLOCK
	. = ..()

/obj/item/weapon/dnainjector/tourmut
	name = "DNA-Injector (Tour.)"
	desc = "Gives you a nasty case off tourrets."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 7

/obj/item/weapon/dnainjector/tourmut/atom_init()
	block = TWITCHBLOCK
	. = ..()

/obj/item/weapon/dnainjector/stuttmut
	name = "DNA-Injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 9

/obj/item/weapon/dnainjector/stuttmut/atom_init()
	block = NERVOUSBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antistutt
	name = "DNA-Injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 9

/obj/item/weapon/dnainjector/antistutt/atom_init()
	block = NERVOUSBLOCK
	. = ..()

/obj/item/weapon/dnainjector/blindmut
	name = "DNA-Injector (Blind)"
	desc = "Makes you not see anything."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 11

/obj/item/weapon/dnainjector/blindmut/atom_init()
	block = BLINDBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antiblind
	name = "DNA-Injector (Anti-Blind)"
	desc = "ITS A MIRACLE!!!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 11

/obj/item/weapon/dnainjector/antiblind/atom_init()
	block = BLINDBLOCK
	. = ..()

/obj/item/weapon/dnainjector/deafmut
	name = "DNA-Injector (Deaf)"
	desc = "Sorry, what did you say?"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 13

/obj/item/weapon/dnainjector/deafmut/atom_init()
	block = DEAFBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antideaf
	name = "DNA-Injector (Anti-Deaf)"
	desc = "Will make you hear once more."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 13

/obj/item/weapon/dnainjector/antideaf/atom_init()
	block = DEAFBLOCK
	. = ..()

/obj/item/weapon/dnainjector/hallucination
	name = "DNA-Injector (Halluctination)"
	desc = "What you see isn't always what you get."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2

/obj/item/weapon/dnainjector/hallucination/atom_init()
	block = HALLUCINATIONBLOCK
	. = ..()

/obj/item/weapon/dnainjector/antihallucination
	name = "DNA-Injector (Anti-Hallucination)"
	desc = "What you see is what you get."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2

/obj/item/weapon/dnainjector/antihallucination/atom_init()
	block = HALLUCINATIONBLOCK
	. = ..()

/obj/item/weapon/dnainjector/h2m
	name = "DNA-Injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14

/obj/item/weapon/dnainjector/h2m/atom_init()
	block = MONKEYBLOCK
	. = ..()

/obj/item/weapon/dnainjector/m2h
	name = "DNA-Injector (Monkey > Human)"
	desc = "Will make you...less hairy."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14

/obj/item/weapon/dnainjector/m2h/atom_init()
	block = MONKEYBLOCK
	. = ..()
