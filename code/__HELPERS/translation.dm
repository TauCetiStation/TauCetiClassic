#define NOMINATIVE_CASE    1 //delete when names get translated... or dont.
#define GENITIVE_CASE      2
#define DATIVE_CASE        3
#define ACCUSATIVE_CASE    4
#define ABLATIVE_CASE      5
#define PREPOSITIONAL_CASE 6

#define CASE(item, case) (item.cases && item.cases[case] ? item.cases[case] : item.name)

/atom
	var/list/cases = null
// 	var/list/cases = list("атом", "атома", "атому", "атом", "атомом", "атоме")
