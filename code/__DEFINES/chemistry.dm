#define SOLID  1
#define LIQUID 2
#define GAS    3

#define MINIMUM_CHEMICAL_VOLUME 0.01

#define REAGENTS_FREE_SPACE(R) (R?.maximum_volume - R?.total_volume)

#define GET_ABSTRACT_REAGENT(R) (global.chemical_reagents_list[R])
