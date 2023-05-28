#define SIGNAL_ADDTRAIT(trait_ref) "addtrait [trait_ref]"
#define SIGNAL_REMOVETRAIT(trait_ref) "removetrait [trait_ref]"

// trait accessor defines
#define ADD_TRAIT(target, trait, source) \
	do { \
		var/list/_L; \
		if (!target.status_traits) { \
			target.status_traits = list(); \
			_L = target.status_traits; \
			_L[trait] = list(source); \
			SEND_SIGNAL(target, SIGNAL_ADDTRAIT(trait), trait); \
		} else { \
			_L = target.status_traits; \
			if (_L[trait]) { \
				_L[trait] |= list(source); \
			} else { \
				_L[trait] = list(source); \
				SEND_SIGNAL(target, SIGNAL_ADDTRAIT(trait), trait); \
			} \
		} \
	} while (0)
#define REMOVE_TRAIT(target, trait, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources\
		}; \
		if (_L && _L[trait]) { \
			for (var/_T in _L[trait]) { \
				if ((!_S && (_T != ROUNDSTART_TRAIT)) || (_T in _S)) { \
					_L[trait] -= _T \
				} \
			};\
			if (!length(_L[trait])) { \
				_L -= trait; \
				SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(trait), trait); \
			}; \
			if (!length(_L)) { \
				target.status_traits = null \
			}; \
		} \
	} while (0)
#define REMOVE_TRAIT_NOT_FROM(target, trait, sources) \
	do { \
		var/list/_traits_list = target.status_traits; \
		var/list/_sources_list; \
		if (sources && !islist(sources)) { \
			_sources_list = list(sources); \
		} else { \
			_sources_list = sources\
		}; \
		if (_traits_list && _traits_list[trait]) { \
			for (var/_trait_source in _traits_list[trait]) { \
				if (!(_trait_source in _sources_list)) { \
					_traits_list[trait] -= _trait_source \
				} \
			};\
			if (!length(_traits_list[trait])) { \
				_traits_list -= trait; \
				SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(trait), trait); \
			}; \
			if (!length(_traits_list)) { \
				target.status_traits = null \
			}; \
		} \
	} while (0)
#define REMOVE_TRAITS_NOT_IN(target, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S = sources; \
		if (_L) { \
			for (var/_T in _L) { \
				_L[_T] &= _S;\
				if (!length(_L[_T])) { \
					_L -= _T; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_T), _T); \
					}; \
				};\
			if (!length(_L)) { \
				target.status_traits = null\
			};\
		}\
	} while (0)

#define REMOVE_TRAITS_IN(target, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S = sources; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources\
		}; \
		if (_L) { \
			for (var/_T in _L) { \
				_L[_T] -= _S;\
				if (!length(_L[_T])) { \
					_L -= _T; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_T)); \
					}; \
				};\
			if (!length(_L)) { \
				target.status_traits = null\
			};\
		}\
	} while (0)

#define HAS_TRAIT(target, trait) (target.status_traits ? (target.status_traits[trait] ? TRUE : FALSE) : FALSE)
#define HAS_TRAIT_FROM(target, trait, source) (target.status_traits ? (target.status_traits[trait] ? (source in target.status_traits[trait]) : FALSE) : FALSE)
#define HAS_TRAIT_FROM_ONLY(target, trait, source) (\
	target.status_traits ?\
		(target.status_traits[trait] ?\
			((source in target.status_traits[trait]) && (length(target.status_traits) == 1))\
			: FALSE)\
		: FALSE)
#define HAS_TRAIT_NOT_FROM(target, trait, source) (target.status_traits ? (target.status_traits[trait] ? (length(target.status_traits[trait] - source) > 0) : FALSE) : FALSE)


//mob traits
/// Forces user to be unmovable
#define TRAIT_ANCHORED "anchored"
/// Prevents voluntary movement.
#define TRAIT_IMMOBILIZED "immobilized"
/// Prevents hands and legs usage
#define TRAIT_INCAPACITATED "incapacitated"
/// This mob overrides certian SSlag_switch measures with this special trait
#define TRAIT_BYPASS_MEASURES "bypass_lagswitch_measures"

#define TRAIT_ALCOHOL_TOLERANCE   "alcohol_tolerance"
#define TRAIT_BLIND               "blind"
#define TRAIT_COUGH               "cough"
#define TRAIT_DEAF                "deaf"
#define TRAIT_EPILEPSY            "epilepsy"
#define TRAIT_FAT                 "fatness"
#define TRAIT_HIGH_PAIN_THRESHOLD "high_pain_threshold"
#define TRAIT_LIGHT_DRINKER       "light_drinker"
#define TRAIT_LOW_PAIN_THRESHOLD  "low_pain_threshold"
#define TRAIT_TOURETTE            "tourette"
#define TRAIT_NEARSIGHT           "nearsighted"
#define TRAIT_NERVOUS             "nervous"
#define TRAIT_STRESS_EATER        "stresseater"
#define TRAIT_MULTITASKING        "multitasking"
#define TRAIT_NATURECHILD         "child_of_nature"
#define TRAIT_MUTE                "mute"
#define TRAIT_STRONGMIND          "strong_mind"
#define TRAIT_AV                  "artifical_ventilation"
#define TRAIT_CPB                 "cardiopulmonary_bypass"
#define TRAIT_LIGHT_STEP          "light_step"
#define TRAIT_FREERUNNING         "freerunning"
#define TRAIT_AGEUSIA             "ageusia"
#define TRAIT_DALTONISM           "daltonism"
#define TRAIT_COOLED              "external_cooling_device"
#define TRAIT_NO_RUN              "no_run"
#define TRAIT_FAST_EQUIP          "fast_equip"
#define TRAIT_FRIENDLY            "friendly"
#define TRAIT_NO_CLONE            "no_clone"
#define TRAIT_VACCINATED          "vaccinated"
#define TRAIT_DWARF               "dwarf"
#define TRAIT_NO_SOUL             "no_soul"
#define TRAIT_SEE_GHOSTS          "see_ghosts"
#define TRAIT_SYRINGE_FEAR        "syringe_fear"
#define TRAIT_WET_HANDS           "wet_hands"
#define TRAIT_GREASY_FINGERS      "greasy_fingers"
#define TRAIT_ANATOMIST           "anatomist"
#define TRAIT_SOULSTONE_IMMUNE    "soulstone_immune"
#define TRAIT_PICKY_EATER         "picky_eater"
#define TRAIT_CULT_EYES           "cult_eyes"
#define TRAIT_CULT_HALO           "cult_halo"
#define TRAIT_HEALS_FROM_PYLONS   "heals_from_pylons"
#define TRAIT_HEMOCOAGULATION     "hemocoagulation"
#define TRAIT_CLUMSY              "clumsy"
#define TRAIT_SHOCKIMMUNE         "shockimmune"
#define TRAIT_NATURAL_AGILITY     "natural_agility"
#define TRAIT_BLUESPACE_MOVING    "bluespace_moving"
#define TRAIT_STEEL_NERVES        "steel_nerves"
#define TRAIT_ARIBORN             "ariborn"

/*
 * Used for movables that need to be updated, via COMSIG_ENTER_AREA and COMSIG_EXIT_AREA, when transitioning areas.
 * Use [/atom/movable/proc/become_area_sensitive(trait_source)] to properly enable it. How you remove it isn't as important.
 */
#define TRAIT_AREA_SENSITIVE "area-sensitive"

/*
 * Used for items that have different behaviour when they are two-hand wielded
 */
// atom traits
#define TRAIT_XENO_FUR "xeno_fur"

#define TRAIT_DOUBLE_WIELDED "double_wielded"

// item trait
#define TRAIT_NO_SACRIFICE "religion_no_sacrifice"

// gamemodes roles traits
/// overall
#define TRAIT_ABDUCTOR_MEMBER "abductor_member"
/// child
#define TRAIT_ABDUCTOR_OP "abductor_op"
#define TRAIT_ABDUCTOR_ABDUCTED "abductor_abducted"
/// variables
#define TRAIT_ABDUCTOR_OP_AGENT "abductor_op_agent"
#define TRAIT_ABDUCTOR_OP_SCIENTIST "abductor_op_scientist"
#define TRAIT_ABDUCTOR_ASSISTANT "abductor_assistant"
#define TRAIT_ABDUCTOR_VISITOR "abductor_visitor"
#define TRAIT_ABDUCTOR_RESEARCH_MISSION "abductor_research_mission"

/// overall
#define TRAIT_ALIEN_HIVEPART "alien_hivepart"
/// child
#define TRAIT_ALIEN_SPECIMEN "alien_specimen"
/// variables
#define TRAIT_ALIEN_ROUNDSTART "alien_roundstart"
#define TRAIT_ALIEN_MIDROUND "alien_midround"
#define TRAIT_ALIEN_REAL_INFESTATION "alien_real_infestation"

/// overall
#define TRAIT_BLOB_HIVEMIND_MEMBER "blob_hivemind_member"
/// child
#define TRAIT_BLOB_HIVEMIND_CORE "blob_hivemind_core"
#define TRAIT_BLOB_HIVEMIND_PAWN "blob_hivemind_pawn"
/// variables
#define TRAIT_BLOB_HIVEMIND_CORE_MIDROUND "blob_hivemind_core_midround"

/// overall
#define TRAIT_BORER_CREATURE "borer_creature"
/// child
#define TRAIT_BORER_PARASITE "borer_parasite"
/// variables
#define TRAIT_BORER_MIDROUND "borer_midround"
#define TRAIT_BORER_REAL_INFESTATION "borer_real_infestation"

/// overall
#define TRAIT_CHANGELING_INDIVIDUAL "changeling_individual"
/// child
#define TRAIT_CHANGELING_HIVEMIND_MEMBER "changeling_hivemind_member"
/// variables
#define TRAIT_CHANGELING_SYNDICATE_AGENT "changeling_syndicate_agent"
#define TRAIT_CHANGELING_RESEARCH_MISSION "changeling_research_mission"
#define TRAIT_CHANGELING_REAL_INFESTATION "changeling_real_infestation"

/// overall
#define TRAIT_COP_PERSON "cop_person"
/// child
#define TRAIT_COP_UNDERCOVER "cop_undercover"
#define TRAIT_COP_SWAT "cop_swat"
/// variables
#define TRAIT_COP_ARMED_OFFICER "cop_armed_officer"
#define TRAIT_COP_TACTICAL_GROUP_FIGHTER "cop_tactical_group_fighter"
#define TRAIT_COP_INSPECTOR "cop_inspector"
#define TRAIT_COP_MFNT_FIGHTER "cop_mfnt_fighter"
#define TRAIT_COP_ROUNDSTART "cop_roundstart"
#define TRAIT_COP_LATEJOIN "cop_latejoin"

/// overall
#define TRAIT_CULTIST_MEMBER "cultist_member"
/// child
#define TRAIT_CULTIST_DEDICATED "cultist_dedicated"
#define TRAIT_CULTIST_HIGHPRIEST "cultist_highpriest"
/// variables
#define TRAIT_CULTIST_HARBINGER "cultist_harbinger"
#define TRAIT_CULTIST_ROUNDSTART "cultist_roundstart"
#define TRAIT_CULTIST_REVOLUTION_OF_NARSIE "cultist_revolution_of_narsie"
#define TRAIT_CULTIST_CONFLUX "cultist_conflux"

/// overall
#define TRAIT_CUSTOM_ROLE "custom_role"
/// variables
#define TRAIT_CUSTOM_ROLE_ROUNDSTART "custom_role_roundstart"

/// overall
#define TRAIT_FAMILIES_MEMBER "families_member"
/// child
#define TRAIT_FAMILIES_GANGSTER "families_gangster"
#define TRAIT_FAMILIES_LEADER "families_leader"
/// variables
#define TRAIT_FAMILIES_DUTCH "families_dutch"
#define TRAIT_FAMILIES_GREEN "families_green"
#define TRAIT_FAMILIES_HENCHMEN "families_henchmen"
#define TRAIT_FAMILIES_ITALIAN_MOB "families_italian_mob"
#define TRAIT_FAMILIES_JACKBROS "families_jackbros"
#define TRAIT_FAMILIES_PURPLE "families_purple"
#define TRAIT_FAMILIES_RED "families_red"
#define TRAIT_FAMILIES_RUSSIAN_MAFIA "families_russian_mafia"
#define TRAIT_FAMILIES_SNAKES "families_snakes"
#define TRAIT_FAMILIES_VAGOS "families_vagos"
#define TRAIT_FAMILIES_YAKUZA "families_yakuza"

/// overall
#define TRAIT_HEIST_CREWMEMBER "heist_crewmember"
/// variables
#define TRAIT_HEIST_RAIDER_MIDROUND "heist_raider_midround"
#define TRAIT_HEIST_SABOTEUR "heist_saboteur"

/// overall
#define TRAIT_MALFUNCTION_SILICON "malfunction_silicon"
/// child
#define TRAIT_MALFUNCTION_AI "malfunction_ai"
#define TRAIT_MALFUNCTION_BOT "malfunction_bot"

/// overall
#define TRAIT_SPRIDER_CLAN_MEMBER "spider_clan_member"
/// child
#define TRAIT_SPRIDER_CLAN_NINJA "spider_clan_ninja"

/// overall
#define TRAIT_PROP_INDIVIDUAL "prop_individual"

/// overall
#define TRAIT_REPLICATOR_HIVEMIND_MEMBER "replicator_hivemind_member"
/// child
#define TRAIT_REPLICATOR_UNIT "replicator_unit"

/// overall
#define TRAIT_REVOLUTION_PARTICIPANT "revolution_participant"
/// child
#define TRAIT_REVOLUTION_LEADER "revolution_leader"
#define TRAIT_REVOLUTION_PROTESTER "revolution_protester"
/// variables
#define TRAIT_REVOLUTION_NARSIE_REVOLUTIONEER "revolution_narsie_revolutioneer"

/// overall
#define TRAIT_SHADOWLING_GROUP_MEMBER "shadowling_group_member"
/// child
#define TRAIT_SHADOWLING_MASTER "shadowling_master"
#define TRAIT_SHADOWLING_CREWSLAVE "shadowling_crewslave"

/// overall
#define TRAIT_SLAVE_PERSON "slave_person"

/// overall
#define TRAIT_NUKE_OP "nuke_op"
/// child
#define TRAIT_NUKE_TEAMSTRIKE_MEMBER "nuke_teamstrike_member"
#define TRAIT_NUKE_OP_LONE "nuke_op_lone"
/// variables
#define TRAIT_NUKE_TEAMSTRIKE_LEADER "nuke_teamstrike_leader"
#define TRAIT_NUKE_OP_ROUNDSTART "nuke_op_roundstart"
#define TRAIT_NUKE_OP_MIDROUND "nuke_op_midround"
#define TRAIT_NUKE_OP_CROSSFIRE "nuke_op_crossfire"

/// overall
#define TRAIT_STRIKE_TEAMMATE "strike_teammate"
/// child
#define TRAIT_STRIKE_TEAM_MEMBER "strike_team_member"
#define TRAIT_STRIKE_TEAM_LEADER "strike_team_leader"

/// overall
#define TRAIT_SYNDICATE_AGENT "syndicate_agent"
/// child
#define TRAIT_SYNDICATE_TRAITOR "syndicate_traitor"
#define TRAIT_SYNDICATE_GUN_DEALER "syndicate_gun_dealer"
/// variables
#define TRAIT_SYNDICATE_ROUNDSTART "syndicate_roundstart"
#define TRAIT_SYNDICATE_MIDROUND "syndicate_midround"
#define TRAIT_SYNDICATE_SLEEPER "syndicate_sleeper"
#define TRAIT_SYNDICATE_WISHGRANTED "syndicate_wishgranted"
#define TRAIT_SYNDICATE_BEACONED "syndicate_beaconed"
#define TRAIT_SYNDICATE_CHANGELING_TEAMMATE "syndicate_changeling_teammate"
#define TRAIT_SYNDICATE_FUSS "syndicate_fuss"

/// overall
#define TRAIT_WIZARD_PARTY "wizard_party"
/// child
#define TRAIT_WIZARD_MASTER "wizard_master"
#define TRAIT_WIZARD_APPERENTICE "wizard_apprentice"
/// variables
#define TRAIT_WIZARD_CONFLUX "wizard_conflux"
#define TRAIT_WIZARD_VISITOR "wizard_visitor"
#define TRAIT_WIZARD_FUSS "wizard_fuss"

/// overall
#define TRAIT_ZOMBIETIDE_MEMBER "zombietide_member"
/// variables
#define TRAIT_ZOMBIE_ROUNDSTART "zombietide_roundstart"

/// overall
#define TRAIT_ELITE_SQUAD_MEMBER "elite_squad_member"
/// child
#define TRAIT_ELITE_SQUAD_OP "elite_squad_op"

/// overall
#define TRAIT_DEATHSQUAD_MEMBER "deathsquad_member"
/// child
#define TRAIT_DEATHSQUAD_OP "deathsquad_op"

// trait sources
// idk why this exists on TG
#define GENERIC_TRAIT "generic"
// common trait sources
#define ROUNDSTART_TRAIT   "roundstart" //cannot be removed without admin intervention
#define QUALITY_TRAIT      "quality"
#define TWOHANDED_TRAIT    "twohanded"
#define RELIGION_TRAIT     "religion"
#define GAMEMODE_TRAIT     "gamemode"

// self explanatory
#define BEAUTY_ELEMENT_TRAIT "beauty_element"
#define BLUESPACE_MOVE_COMPONENT_TRAIT "bluespace_move_component_trait"
#define MOOD_COMPONENT_TRAIT "mood_component"
#define SPAWN_AREA_TRAIT "spawn_area_trait"
// medical stuff I guess
#define OBESITY_TRAIT      "obesity"
#define LIFE_ASSIST_MACHINES_TRAIT            "life_assist_machines"
#define FEAR_TRAIT         "fear"
#define EYE_DAMAGE_TRAIT "eye_damage"
#define EYE_DAMAGE_TEMPORARY_TRAIT "eye_damage_temporary"
#define GENETIC_MUTATION_TRAIT "genetic"
#define QUIRK_TRAIT "quirk"
#define VIRUS_TRAIT "virus"

// airborn trait surces
#define TRAIT_ARIBORN_FLYING "trait_ariborn_flying" // mob can fly by itself
#define TRAIT_ARIBORN_AIRFLOW "trait_ariborn_airflow" // from atmos
#define TRAIT_ARIBORN_THROWN "trait_ariborn_trown" // if someone thrown it
//#define TRAIT_ARIBORN_NO_GRAVITY "trait_ariborn_no_gravity" // todo?
