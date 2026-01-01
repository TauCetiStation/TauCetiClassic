#define GUEST_FORBIDDEN 0
#define GUEST_LOBBY 1
#define GUEST_GAME 2

var/global/list/guest_modes = list(
	"Вход на сервер запрещен" = GUEST_FORBIDDEN,
	"Только лобби" = GUEST_LOBBY,
	"Разрешен вход в игру" = GUEST_GAME,
)

