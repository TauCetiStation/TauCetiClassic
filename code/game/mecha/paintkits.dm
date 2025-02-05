/obj/item/paintkit //Please don't use this for anything, it's a base type for custom mech paintjobs.
	name = "mecha customisation kit"
	desc = "A generic kit containing all the needed tools and parts to turn a mech into another mech."
	icon = 'icons/obj/paintkit.dmi'
	icon_state = "paintkit" //What sprite will your paintkit use?

	var/new_name = "mech"    //What is the variant called?
	var/new_desc = "A mech." //How is the new mech described?
	var/new_icon = "ripley"  //What base icon will the new mech use?
	var/removable = null     //Can the kit be removed?
	var/allowed_types = NONE //Types of mech that the kit will work on.

	/// if there it is, instead of replacing initial_icon, will just add this before icon_state
	var/new_prefix
	/// if there it is, instead of replacing name, will just add this before name
	var/name_prefix
	/// if it contains an icon_state for a specific mech type, then instead of adding a prefix or replacing it with a general paintkit icon, take the initial_icon from here
	var/list/icon_states = list()

//If you want to add new paintkit, grab a paintkit sprite from: "icons/obj/paintkit.dmi" or make a new one
//Then throw the sprites of the new mecha skin to the "icons/obj/mecha/mecha.dmi and add a new object below"

/obj/item/paintkit/ripley_titansfist
	name = "APLU \"Titan's Fist\" customisation kit"
	icon_state = "paintkit_titan"
	desc = "A kit containing all the needed tools and parts to turn a Ripley into a Titan's Fist worker mech."

	new_name = "APLU \"Titan's Fist\""
	new_desc = "This ordinary mining Ripley has been customized to look like a unit of the Titans Fist."
	new_icon = "titan"
	allowed_types = MECH_TYPE_RIPLEY

/obj/item/paintkit/ripley_mercenary
	name = "APLU \"Strike the Earth!\" customisation kit"
	icon_state = "paintkit_earth"
	desc = "A kit containing all the needed tools and parts to turn a Ripley into an old Mercenaries APLU."


	new_name = "APLU \"Strike the Earth!\""
	new_desc = "Looks like an over worked, under maintained Ripley with some horrific damage."
	new_icon = "earth"
	allowed_types = MECH_TYPE_RIPLEY

/obj/item/paintkit/gygax_syndie
	name = "Syndicate Gygax customisation kit"
	icon_state = "paintkit_Black"
	desc = "A very suspicious kit containing all the needed tools and parts to turn a Gygax into a infamous Black Gygax"

	new_name = "Black Gygax"
	new_desc = "Why does this thing have a Syndicate logo on it? Wait a second..."
	new_icon = "gygax_black"
	allowed_types = MECH_TYPE_GYGAX

/obj/item/paintkit/gygax_alt
	name = "Old gygax customisation kit"
	icon_state = "paintkit_alt"
	desc = "A kit containing all the needed tools and parts to turn a Gygax into an outdated version of itself. Why would you do that?"

	new_name = "Old Gygax"
	new_desc = "An outdated security exosuit. It is a real achievement to find a preserved exosuit of this model."
	new_icon = "gygax_alt"
	allowed_types = MECH_TYPE_GYGAX

/obj/item/paintkit/ripley_red
	name = "APLU \"Firestarter\" customisation kit"
	icon_state = "paintkit_red"
	desc = "A kit containing all the needed tools and parts to turn a Ripley into APLU \"Firestarter\""

	new_name = "APLU \"Firestarter\""
	new_desc = "A standard APLU exosuit with stylish orange flame decals."
	new_icon = "ripley_flames_red"
	allowed_types = MECH_TYPE_RIPLEY

/obj/item/paintkit/firefighter_Hauler
	name = "APLU \"Hauler\" customisation kit"
	icon_state = "paintkit_hauler"
	desc = "A kit containing all the needed tools and parts to turn an Ripley into an old engineering exosuit"

	new_name = "APLU \"Hauler\""
	new_desc = "An old engineering exosuit. For lovers of classics."
	new_icon = "hauler"
	allowed_types = MECH_TYPE_RIPLEY

/obj/item/paintkit/durand_shire
	name = "Durand \"Shire\" modification kit"
	icon_state = "paintkit_shire"
	desc = "A kit containing all the needed tools and parts to turn a Durand into incredibly heavy war machine."

	new_name = "Shire"
	new_desc = "An incredibly heavy-duty war machine derived from an Interstellar War design."
	new_icon = "shire"
	allowed_types = MECH_TYPE_DURAND

/obj/item/paintkit/durand_executor
	name = "Durand \"Executioner\" modification kit"
	icon_state = "paintkit_executor"
	desc = "A kit containing all the needed tools and parts to turn a Durand into holy machine of Doom and Purge! For The Mankind! For the Imperator!"

	new_name = "mk.V Executioner"
	new_desc = "Dreadnought of the Executioner Order, heavy fire support configuration, made for purge evil and heretics."
	new_icon = "executor"
	allowed_types = MECH_TYPE_DURAND

/obj/item/paintkit/firefighter_zairjah
	name = "APLU \"Zairjah\" customisation kit"
	icon_state = "paintkit_zairjah"
	desc = "A kit containing all the needed tools and parts to turn a Firefighter into weird-looking mining exosuit"

	new_name = "APLU \"Zairjah\""
	new_desc = "A mining mecha of custom design, a closed cockpit with powerloader appendages."
	new_icon = "ripley_zairjah"
	allowed_types = MECH_TYPE_RIPLEY

/obj/item/paintkit/firefighter_combat
	name = "APLU \"Combat Ripley\" customisation kit"
	icon_state = "paintkit_combat"
	desc = "A kit containing all the needed tools and parts to turn a Firefighter into a real combat exosuit. Weapons are not included!"

	new_name = "APLU \"Combat Ripley\""
	new_desc = "Wait a second, why does his equipment slots spark so dangerously?"
	new_icon = "combatripley"
	allowed_types = MECH_TYPE_RIPLEY

/obj/item/paintkit/firefighter_Reaper
	name = "APLU \"Reaper\" customisation kit"
	icon_state = "paintkit_death"
	desc = "A kit containing all the needed tools and parts to turn a Firefighter into a famous DeathSquad ripley!"

	new_name = "APLU \"Reaper\""
	new_desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA D- Stop, it's just a painted firefighter."
	new_icon = "deathripley"
	allowed_types = MECH_TYPE_RIPLEY

/obj/item/paintkit/odysseus_hermes
	name = "Odysseus \"Hermes\" customisation kit"
	icon_state = "paintkit_hermes"
	desc = "A kit containing all the needed tools and parts to turn a Odysseus into a alien-like diving exosuit"

	new_name = "Hermes"
	new_desc = "Heavy-duty diving exosuit developed and produced for for highly specialized underwater operations. How did he end up here?"
	new_icon = "hermes"
	allowed_types = MECH_TYPE_ODYSSEUS

/obj/item/paintkit/durand_unathi
	name = "Durand \"Kharn MK. IV\" customisation kit"
	icon_state = "paintkit_unathi"
	desc = "A kit containing all the needed tools and parts to turn a Durand into an alien-like lizard mech"

	new_name = "Kharn MK. IV"
	new_desc = "My life for the empress!"
	new_icon = "unathi"
	allowed_types = MECH_TYPE_DURAND

/obj/item/paintkit/phazon_blanco
	name = "Phazon \"Blanco\" customisation kit"
	icon_state = "paintkit_white"
	desc = "A kit containing all the needed tools and parts to paint your Phazon white"

	new_name = "Blanco"
	new_desc = "It took more than six months of work to find the perfect pastel colors for this mech"
	new_icon = "phazon_blanco"
	allowed_types = MECH_TYPE_PHAZON

/obj/item/paintkit/firefighter_aluminizer
	name = "APLU \"Aluminizer\" customisation kit"
	icon_state = "paintkit"
	desc = "A kit containing all the needed tools and parts to paint a Firefighter white"

	new_name = "Aluminizer"
	new_desc = "Did you just painted your Ripley white? It looks good."
	new_icon = "aluminizer"
	allowed_types = MECH_TYPE_RIPLEY

/obj/item/paintkit/odysseus_death
	name = "Odysseus \"Reaper\" customisation kit"
	icon_state = "paintkit_death"
	desc = "A kit containing all the needed tools and parts to turn a Odysseus into terrifying mech"

	new_name = "Reaper"
	new_desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA... get a bad medical treatment?"
	new_icon = "murdysseus"
	allowed_types = MECH_TYPE_ODYSSEUS

/obj/item/paintkit/durand_soviet
	name = "Durand \"Dollhouse\" customisation kit"
	icon_state = "paintkit_doll"
	desc = "A kit containing all the needed tools and parts to turn a Durand into soviet mecha. Glory to Space Russia!"

	new_name = "Doll House"
	new_desc = "A extremely heavy-duty combat mech designed in USSP. Glory to Space Russia!"
	new_icon = "dollhouse"
	allowed_types = MECH_TYPE_DURAND

/obj/item/paintkit/clarke_orangey
	name = "Clarke \"Orangey\" customisation kit"
	icon_state = "paintkit_red"
	desc = "A kit containing all the needed tools and parts to paint a Clarke white"

	new_name = "Orangey"
	new_desc = "Did you just painted your Clarke orange? It looks quite nice."
	new_icon = "orangey"
	allowed_types = MECH_TYPE_CLARKE

/obj/item/paintkit/clarke_spiderclarke
	name = "Clarke \"Spiderclarke\" customisation kit"
	icon_state = "paintkit_spider"
	desc = "A kit containing all the needed tools and parts to turn a Clarke into terrifying... thing"

	new_name = "Spiderclarke"
	new_desc = "Heavy mining exo-suit coated with chitin. Isn't that a giant spider's scalp on his visor?"
	new_icon = "spiderclarke"
	allowed_types = MECH_TYPE_CLARKE

/obj/item/paintkit/gygax_pobeda
	name = "Gygax \"Pobeda\" customisation kit"
	icon_state = "paintkit_pobeda"
	desc = "A kit containing all the needed tools and parts to turn a Gygax into a soviet exosuit."

	new_name = "Pobeda"
	new_desc = "A heavy-duty old Gygax designed and painted in USSP. Glory to Space Russia!"
	new_icon = "pobeda"
	allowed_types = MECH_TYPE_GYGAX

/obj/item/paintkit/gygax_white
	name = "White Gygax customisation kit"
	icon_state = "paintkit_white"
	desc = "A kit containing all the needed tools and parts to paint a Gygax white"

	new_name = "White Gygax"
	new_desc = "Did you just painted your Gygax white? I like it."
	new_icon = "medigax"
	allowed_types = MECH_TYPE_GYGAX

/obj/item/paintkit/gygax_medgax
	name = "Gygax \"medgax\" customisation kit"
	icon_state = "paintkit_white"
	desc = "A kit containing all the needed tools and parts to turn a Gygax into old \"medical\" gygax"

	new_name = "Medgax"
	new_desc = "OH SHIT THERE IS A COMBAT MECH IN THE HOSPITAL IT'S GONNA KILL US"
	new_icon = "medgax"
	allowed_types = MECH_TYPE_GYGAX

/obj/item/paintkit/gygax_pirate
	name = "Pirate Gygax customisation kit"
	icon_state = "paintkit_pirate"
	desc = "A kit containing all the needed tools and parts to paint a Gygax Pirate"

	new_name = "Pirate Gygax"
	new_icon = "piratgygax"
	allowed_types = MECH_TYPE_GYGAX

/obj/item/paintkit/durand_pirate
	name = "Pirate Durand customisation kit"
	icon_state = "paintkit_pirate"
	desc = "A kit containing all the needed tools and parts to turn a Durand into a Pirate"

	new_name = "Pirate Durand"
	new_icon = "piratdurand"
	allowed_types = MECH_TYPE_DURAND


/obj/item/paintkit/durand_nt
	name = "NT Special Durand customisation kit"
	icon_state = "paintkit_nt"
	desc = "A kit containing all the needed tools and parts to show that Durand it is the property of NT"

	new_name = "NT Special Durand"
	new_icon = "ntdurand"
	allowed_types = MECH_TYPE_DURAND

/obj/item/paintkit/ripley_nt
	name = "NT Special APLU customisation kit"
	icon_state = "paintkit_nt"
	desc = "A kit containing all the needed tools and parts to show that APLU it is the property of NT"

	new_name = "NT Special APLU"
	new_icon = "ntripley"
	allowed_types = MECH_TYPE_RIPLEY

/obj/item/paintkit/ashed
	name = "Ashed customisation kit"
	icon_state = "paintkit_ash"
	desc = "Набор, позволяющий вам переделать многие экзокостюмы в их более шахтерский аналог! По крайней мере, расцветкой."

	new_name = "Ashed Mech"
	name_prefix = "Ashed"
	allowed_types = MECH_TYPE_RIPLEY|MECH_TYPE_GYGAX|MECH_TYPE_DURAND|MECH_TYPE_PHAZON

/obj/item/paintkit/ashed/New(mapload)
    ..()
    icon_states["[MECH_TYPE_RIPLEY]"] = "ashedripley"
    icon_states["[MECH_TYPE_GYGAX]"] = "ashedgygax"
    icon_states["[MECH_TYPE_DURAND]"] = "asheddurand"

// Universal paintkit
/obj/item/universal_paintkit
	name = "universal customisation kit"
	desc = "A kit containing all the needed tools and parts to repaint the mech as many times as they wish."
	icon = 'icons/obj/paintkit.dmi'
	icon_state = "paintkit"

/obj/item/universal_paintkit/afterattack(obj/object, mob/living/user, params)
    if(!istype(object, /obj/mecha))
        return ..()

    var/obj/mecha/mech = object
    if(mech.occupant)
        to_chat(user, "<span class='warning'>You can't customize a mech while someone is piloting it - that would be unsafe!</span>")
        return ATTACK_CHAIN_PROCEED

    var/list/possibilities = list()
    for(var/path in subtypesof(/obj/item/paintkit))
        var/obj/item/paintkit/kit = new path

        if(kit.allowed_types & mech.mech_type)
            possibilities += kit

    if(isemptylist(possibilities))
        to_chat(user, "<span class='warning'>There are no skins for this mech type!</span>")
        return ATTACK_CHAIN_PROCEED

    INVOKE_ASYNC(src, PROC_REF(choose_paint), user, mech, possibilities)
    return ATTACK_CHAIN_BLOCKED_ALL

/obj/item/universal_paintkit/proc/choose_paint(mob/living/user, obj/mecha/mech, list/possibilities)
	var/choice = tgui_input_list(user, "Pick your skin for mech.", "Paints", possibilities)
	if(!choice || user.incapacitated() || !user.is_in_hands(src) || !user.Adjacent(mech))
		return

	user.visible_message("<span class='notice'>[user] opens [src] and customises [mech.name].</span>")

	var/obj/item/paintkit/chosen_kit = choice
	var/mech_type = "[mech.mech_type]"
	var/list/icon_states = chosen_kit.icon_states

	if(mech_type in icon_states)
		mech.initial_icon = icon_states[mech_type]
	else
		mech.initial_icon = chosen_kit.new_icon

	if(chosen_kit.name_prefix)
		mech.name = "[chosen_kit.name_prefix] [name]"
	else
		mech.name = chosen_kit.new_name
	mech.desc = chosen_kit.new_desc
	mech.update_icon(TRUE)
