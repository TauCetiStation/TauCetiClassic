// trait accessor defines
#define ADD_TRAIT(target, trait, source) \
	do { \
		var/list/_L; \
		if (!target.status_traits) { \
			target.status_traits = list(); \
			_L = target.status_traits; \
			_L[trait] = list(source); \
		} else { \
			_L = target.status_traits; \
			if (_L[trait]) { \
				_L[trait] |= list(source); \
			} else { \
				_L[trait] = list(source); \
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
				_L -= trait \
			}; \
			if (!length(_L)) { \
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
					_L -= _T } \
				};\
				if (!length(_L)) { \
					target.status_traits = null\
				};\
		}\
	} while (0)
#define HAS_TRAIT(target, trait) (target.status_traits ? (target.status_traits[trait] ? TRUE : FALSE) : FALSE)
#define HAS_TRAIT_FROM(target, trait, source) (target.status_traits ? (target.status_traits[trait] ? (source in target.status_traits[trait]) : FALSE) : FALSE)

//mob traits
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
#define TRAIT_COOLED              "external_cooling_device"
#define TRAIT_NO_RUN              "no_run"

// common trait sources
#define ROUNDSTART_TRAIT   "roundstart" //cannot be removed without admin intervention
#define OBESITY_TRAIT      "obesity"
#define LIFE_ASSIST_MACHINES_TRAIT            "life_assist_machines"

#define FEAR_TRAIT         "fear"
