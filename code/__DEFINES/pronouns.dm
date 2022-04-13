#define P_THEY(g) g == MALE && "he" \
               || g == FEMALE && "she" \
               || g == NEUTER && "it" \
               || "they"

#define P_THEM(g) g == MALE && "him" \
               || g == FEMALE && "her" \
               || "them"

#define P_THEIR(g) g == MALE && "his" \
               || g == FEMALE && "her" \
               || "their"
////////////////////////////////////////////////

////////////////////////////////////////////////
//И Кто/что
#define P_THEY_RU(g) g == MALE && "он" \
               || g == FEMALE && "она" \
               || g == NEUTER && "оно" \
               || "они"
//Р Кого/чего
#define P_THEIR_RU(g) g == MALE && "его" \
               || g == FEMALE && "её" \
               || g == NEUTER && "этого" \
               || "их"
//Д Кому/чему
#define P_TO_RU(g) g == MALE && "ему" \
               || g == FEMALE && "ей" \
               || g == NEUTER && "этому" \
               || "им"
//Д К кому/к чему
#define P_TO2_RU(g) g == MALE && "нему" \
               || g == FEMALE && "ней" \
               || g == NEUTER && "этому" \
               || "ним"
//В Кого/что
#define P_THEM_RU(g) g == MALE && "его" \
               || g == FEMALE && "её" \
               || g == NEUTER && "это" \
               || "их"
//Т Кем/чем
#define P_BY_RU(g) g == MALE && "им" \
               || g == FEMALE && "ею" \
               || g == NEUTER && "этим" \
               || "ими"
//П (В) ком/чём
#define P_IN_RU(g) g == MALE && "нём" \
               || g == FEMALE && "ней" \
               || g == NEUTER && "этом" \
               || "них"
//П О ком/о чём
#define P_ABOUT_RU(g) g == MALE && "о нём" \
               || g == FEMALE && "о ней" \
               || g == NEUTER && "об этом" \
               || "о них"
//Чьё
#define P_MY_RU(g) g == MALE && "мой" \
               || g == FEMALE && "моя" \
               || g == NEUTER && "моё" \
               || "мои"
//Чьё
#define P_YOURS_RU(g) g == MALE && "ваш" \
               || g == FEMALE && "ваша" \
               || g == NEUTER && "ваше" \
               || "ваши"
//Который
#define P_WHICH_RU(g) g == MALE && "этот" \
               || g == FEMALE && "эта" \
               || g == NEUTER && "это" \
               || "эти"
////////////////////////////////////////////////

////////////////////////////////////////////////
//Прошедшее время глагола
#define P_VERB_RU(g) g == MALE && "" \
               || g == FEMALE && "а" \
               || g == NEUTER && "о" \
               || "и"
