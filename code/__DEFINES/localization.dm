#define EN "EN"
#define RU "RU"
#define LOCALIZATIONS list(EN, RU)

#define TRANSLATE(word) SSlocalization.localization.translation[word] || word
