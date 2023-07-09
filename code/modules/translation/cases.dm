#define GENITIVE_CASE      1 //родительный
#define DATIVE_CASE        2 //дательный
#define ACCUSATIVE_CASE    3 //винительный
#define ABLATIVE_CASE      4 //творительный
#define PREPOSITIONAL_CASE 5 //предложный

#define CASE(item, case) (item.cases && item.cases[case] ? item.cases[case] : item.name)

/atom
	var/list/cases = list(GENITIVE_CASE = null, DATIVE_CASE = null, ACCUSATIVE_CASE = null, ABLATIVE_CASE = null, PREPOSITIONAL_CASE = null)
