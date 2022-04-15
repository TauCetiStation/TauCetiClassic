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
//                 Местоимение                //
////////////////////////////////////////////////
// И Кто/что
// "[THEY_RU(src)] падает без признаков жизни"
#define THEY_RU(g) g == MALE && "он" \
               || g == FEMALE && "она" \
               || g == NEUTER && "оно" \
               || "они"
// Р Кого/чего
// "У вас больше нет [THEIR_RU(src)]"
#define THEIR_RU(g) g == MALE && "его" \
               || g == FEMALE && "её" \
               || g == NEUTER && "этого" \
               || "их"
// Д Кому/чему
// "Вы передали [TO_RU(src)] предмет"
#define TO_RU(g) g == MALE && "ему" \
               || g == FEMALE && "ей" \
               || g == NEUTER && "этому" \
               || "им"
// Д К кому/к чему
// "По [TO2_RU(src)] сразу видно"
#define TO2_RU(g) g == MALE && "нему" \
               || g == FEMALE && "ней" \
               || g == NEUTER && "этому" \
               || "ним"
// В Кого/что
// "Вы больше не видите [THEM_RU(src)]"
#define THEM_RU(g) g == MALE && "его" \
               || g == FEMALE && "её" \
               || g == NEUTER && "это" \
               || "их"
// Т Кем/чем
// "Вы пытаетесь ударить [BY_RU(src)]"
#define BY_RU(g) g == MALE && "им" \
               || g == FEMALE && "ею" \
               || g == NEUTER && "этим" \
               || "ими"
// П (В) ком/чём
// "Вы полностью уверены в [IN_RU(src)]"
#define IN_RU(g) g == MALE && "нём" \
               || g == FEMALE && "ней" \
               || g == NEUTER && "этом" \
               || "них"
// П О ком/о чём
// "Вы всё время думаете [ABOUT_RU(src)]"
#define ABOUT_RU(g) g == MALE && "о нём" \
               || g == FEMALE && "о ней" \
               || g == NEUTER && "об этом" \
               || "о них"
// Чьё
// "[MY_RU(src)] сознание уходит"
#define MY_RU(g) g == MALE && "мой" \
               || g == FEMALE && "моя" \
               || g == NEUTER && "моё" \
               || "мои"
// Чьё
// "[YOURS_RU(src)] нога болит"
#define YOURS_RU(g) g == MALE && "ваш" \
               || g == FEMALE && "ваша" \
               || g == NEUTER && "ваше" \
               || "ваши"
// Который
// "[WHICH_RU(src)] бикер не помещается в сумку"
#define WHICH_RU(g) g == MALE && "этот" \
               || g == FEMALE && "эта" \
               || g == NEUTER && "это" \
               || "эти"
////////////////////////////////////////////////
//                  Глагол                    //
////////////////////////////////////////////////
// Прошедшее время глагола
// "делал[VERB_RU(src)]"
#define VERB_RU(g) g == MALE && "" \
               || g == FEMALE && "а" \
               || g == NEUTER && "о" \
               || "и"
// Прошедшее время возвратного глагола
// "отказал[VERB2_RU(src)] взять предмет"
#define VERB2_RU(g) g == MALE && "ся" \
               || g == FEMALE && "ась" \
               || g == NEUTER && "ось" \
               || "ись"
