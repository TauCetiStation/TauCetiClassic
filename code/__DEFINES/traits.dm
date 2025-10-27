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
			ispath(trait, /datum/element) && target.AddElement(trait); \
			SEND_SIGNAL(target, SIGNAL_ADDTRAIT(trait), trait); \
		} else { \
			_L = target.status_traits; \
			if (_L[trait]) { \
				_L[trait] |= list(source); \
			} else { \
				_L[trait] = list(source); \
				ispath(trait, /datum/element) && target.AddElement(trait); \
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
				ispath(trait, /datum/element) && target.RemoveElement(trait); \
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
				ispath(trait, /datum/element) && target.RemoveElement(trait); \
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
					ispath(trait, /datum/element) && target.RemoveElement(trait); \
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
					ispath(trait, /datum/element) && target.RemoveElement(trait); \
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
/// Prevents involuntary movement.
#define TRAIT_IMMOVABLE "immovable"
/// Prevents hands and legs usage
#define TRAIT_INCAPACITATED "incapacitated"
/// This mob overrides certian SSlag_switch measures with this special trait
#define TRAIT_BYPASS_MEASURES "bypass_lagswitch_measures"

#define TRAIT_ALCOHOL_TOLERANCE   "alcohol_tolerance"
#define TRAIT_BLIND               "blind"
#define TRAIT_COUGH               "cough"
#define TRAIT_DEAF                "deaf"
#define TRAIT_EPILEPSY            "epilepsy"
/// mob is fat and should use fat icons if possible
#define TRAIT_FAT                 "fatness"
/// can't become fat, should prevent previous trait
/// note: you can screw things up if you give TRAIT_FAT
/// without checking TRAIT_NEWER_FAT first
#define TRAIT_NEVER_FAT           "never_fat"
#define TRAIT_HIGH_PAIN_THRESHOLD "high_pain_threshold"
#define TRAIT_LIGHT_DRINKER       "light_drinker"
#define TRAIT_LOW_PAIN_THRESHOLD  "low_pain_threshold"
#define TRAIT_TOURETTE            "tourette"
#define TRAIT_NEARSIGHT           "nearsighted"
#define TRAIT_NERVOUS             "nervous"
#define TRAIT_STRESS_EATER        "stresseater"
#define TRAIT_MULTITASKING        "multitasking"
#define TRAIT_CAVE_EXPLORER       "cave_explorer"
#define TRAIT_SHIFTY              "shifty"
#define TRAIT_ADAMANTIUM_SKELETON "adamantium_skeleton"
#define TRAIT_FRAGILE_BONES       "fragile_bones"
#define TRAIT_BAD_BACK            "bad_back"
#define TRAIT_NATURECHILD         "child_of_nature"
#define TRAIT_MUTE                "mute"
#define TRAIT_STRONGMIND          "strong_mind"
#define TRAIT_EXTERNAL_VENTILATION "external_ventilation"
#define TRAIT_EXTERNAL_COOLING    "external_cooling"
#define TRAIT_EXTERNAL_HEART      "external_heart"
#define TRAIT_LIGHT_STEP          "light_step"
#define TRAIT_FREERUNNING         "freerunning"
#define TRAIT_AGEUSIA             "ageusia"
#define TRAIT_DALTONISM           "daltonism"
#define TRAIT_NO_RUN              "no_run"
#define TRAIT_FAST_EQUIP          "fast_equip"
#define TRAIT_FRIENDLY            "friendly"
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
#define TRAIT_PLUVIAN_BLESSED     "pluvian_blessed"
#define TRAIT_HEALS_FROM_PYLONS   "heals_from_pylons"
#define TRAIT_HEMOCOAGULATION     "hemocoagulation"
#define TRAIT_CLUMSY              "clumsy"
#define TRAIT_CLUMSY_IMMUNE       "clumsy_immune"
#define TRAIT_SHOCK_IMMUNE         "shockimmune"
#define TRAIT_NATURAL_AGILITY     "natural_agility"
#define TRAIT_BLUESPACE_MOVING    "bluespace_moving"
#define TRAIT_STEEL_NERVES        "steel_nerves"
#define TRAIT_ARIBORN             "ariborn"
#define TRAIT_NO_CRAWL            "nocrawl"
#define TRAIT_HIDDEN_TRASH_GUN    "hidden_trash_gun"
#define TRAIT_HEMOPHILIAC         "hemophiliac"
#define TRAIT_NO_DISPOSALS_DAMAGE "no_disposals_damage"
#define TRAIT_FAKELOYAL_VISUAL    "fakeloyal_visual"
#define TRAIT_CHANGELING_ABSORBING "changeling_absorbing"
#define TRAIT_FAST_WALKER         "fast_walker"
#define TRAIT_BORK_SKILLCHIP      "bork_skillchip"
#define TRAIT_MIMING              "miming"
#define TRAIT_CAN_LEAP            "can_leap"
#define TRAIT_AUTOFIRE_SHOOTS     "autofire_shoots"
#define TRAIT_AIRBAG_PROTECTION   "airbag_protection"
#define TRAIT_DYSLALIA            "dyslalia"
#define TRAIT_NO_BREATHE          "no_breathe"
/// Mod has DNA that is not compatible with station (genetics) machinery, also prevents changeling from targeting some mobs
#define TRAIT_INCOMPATIBLE_DNA    "incompatible_dna"
/// Character can't be cloned
#define TRAIT_NO_CLONE            "no_clone"
/// Character can't change his DNA, prevents new mutations
#define TRAIT_NO_DNA_MUTATIONS    "no_dna_mutations"
#define TRAIT_NO_PAIN             "no_pain"
#define TRAIT_RADIATION_IMMUNE    "radiation_immune"
#define TRAIT_VIRUS_IMMUNE        "virus_immune"
/// Prevents mob from unintentional transformation into another mob
#define TRAIT_MORPH_IMMUNE        "morph_immune"
#define TRAIT_NO_FINGERPRINT      "no_fingerprint"
/// Prevents things like axe or shrapnel from embedding mob (pls rename)
#define TRAIT_NO_EMBED            "no_embed"
#define TRAIT_NO_MINORCUTS        "no_minorcuts"
#define TRAIT_EMOTIONLESS         "emotionless"
#define TRAIT_NO_VOMIT            "no_vomit"
/// mob doesn't have and doesn't need blood
#define TRAIT_NO_BLOOD            "no_blood"
/// prevents mob from spawning bloody mess when gibbed, they still drop limbs if they have them
#define TRAIT_NO_MESSY_GIBS       "no_messy_gibs"
#define TRAIT_GLOWING_EYES        "glowing_eyes"
// todo: this enables night vision filter, but we also need to set see_in_dark for it to work in the dark, need to rework or rename this trait
#define TRAIT_NIGHT_EYES          "night_eyes"
/// grayscale body and white hair, for changeling victims
#define TRAIT_HUSK                "husk"
/// no hair, scorched body
#define TRAIT_BURNT               "burnt"



/*
 * Elements traits - these will attach trait and corresponding /datum/element
 * to the object, and detach element when no trait sources left
 * useful for elements with multiple sources
 * (similar to AddElementTrait() on tg, easier to manage but no support for arguments)
 */

/// makes mob immune to damage and some harmful effects, resets all accumulated damage (ex GODMODE status)
#define ELEMENT_TRAIT_GODMODE     /datum/element/mutation/godmode
#define ELEMENT_TRAIT_SKELETON    /datum/element/mutation/skeleton
#define ELEMENT_TRAIT_SLIME       /datum/element/mutation/slime
#define ELEMENT_TRAIT_ZOMBIE      /datum/element/mutation/zombie

/*
 * Used for movables that need to be updated, via COMSIG_ENTER_AREA and COMSIG_EXIT_AREA, when transitioning areas.
 * Use [/atom/movable/proc/become_area_sensitive(trait_source)] to properly enable it. How you remove it isn't as important.
 */
#define TRAIT_AREA_SENSITIVE "area-sensitive"
#define TRAIT_COOKING_AREA "cooking_area"

/*
 * Used for items that have different behaviour when they are two-hand wielded
 */
#define TRAIT_DOUBLE_WIELDED "double_wielded"

// item trait
#define TRAIT_NO_SACRIFICE "religion_no_sacrifice"

/// Visible on t-ray scanners if the atom is under tile
#define TRAIT_T_RAY_VISIBLE "t-ray-visible"

// idk why this exists on TG
#define GENERIC_TRAIT "generic"
// common trait sources
#define ROUNDSTART_TRAIT   "roundstart" //cannot be removed without admin intervention
#define QUALITY_TRAIT      "quality"
#define TWOHANDED_TRAIT    "twohanded"
#define RELIGION_TRAIT     "religion"

// self explanatory
#define BEAUTY_ELEMENT_TRAIT "beauty_element"
#define BLUESPACE_MOVE_COMPONENT_TRAIT "bluespace_move_component_trait"
#define MOOD_COMPONENT_TRAIT "mood_component"
#define SPAWN_AREA_TRAIT "spawn_area_trait"
// medical stuff I guess
#define OBESITY_TRAIT      "obesity"
#define LIFE_ASSIST_MACHINES_TRAIT            "life_assist_machines"
#define FEAR_TRAIT         "fear"

// atom traits
#define TRAIT_XENO_FUR "xeno_fur"
// Trait from being under the floor in some manner
#define TRAIT_UNDERFLOOR "underfloor"
#define TRAIT_CONDUCT "conduct"

// trait sources
#define TRAIT_FROM_ELEMENT(source) "element_trait_[source]"
#define INNATE_TRAIT "innate"
#define ADMIN_TRAIT "admin"
#define EYE_DAMAGE_TRAIT "eye_damage"
#define EYE_DAMAGE_TEMPORARY_TRAIT "eye_damage_temporary"
#define GENETIC_MUTATION_TRAIT "genetic_mutation_trait"
#define QUIRK_TRAIT "quirk"
#define VIRUS_TRAIT "virus"
#define STATUS_EFFECT_TRAIT "status_effect"
#define IMPLANT_TRAIT "implant"
#define FAKE_IMPLANT_TRAIT "fake_implant"
#define SPECIES_TRAIT      "species"

// airborn trait surces
#define TRAIT_ARIBORN_FLYING "trait_ariborn_flying" // mob can fly by itself
#define TRAIT_ARIBORN_AIRFLOW "trait_ariborn_airflow" // from atmos
#define TRAIT_ARIBORN_THROWN "trait_ariborn_trown" // if someone thrown it
//#define TRAIT_ARIBORN_NO_GRAVITY "trait_ariborn_no_gravity" // todo?
