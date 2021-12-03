import { classes } from 'common/react';
import { multiline } from 'common/string';
import { useBackend } from '../backend';
import { Box, Button, Collapsible, Flex, NoticeBox, Section, TimeDisplay, Tooltip } from '../components';
import { Window } from '../layouts';

export const MafiaPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    lobbydata,
    players,
    actions,
    phase,
    roleinfo,
    role_theme,
    admin_controls,
    judgement_phase,
    timeleft,
    all_roles,
  } = data;
  const playerAddedHeight = roleinfo ? players.length * 10 : 0;
  const readyGhosts = lobbydata ? lobbydata.filter(
    player => player.status === "Готов" && player.spectating === "Игрок") : null;
  return (
    <Window
      title="Мафия"
      theme={role_theme}
      width={650} // 414 or 415 / 444 or 445
      height={580 + playerAddedHeight}>
      <Window.Content scrollable={admin_controls}>
        {!roleinfo && (
          <Flex scrollable
            overflowY="scroll"
            direction="column"
            height="100%"
            grow={1}>
            <Section
              title="Лобби"
              mb={1}
              buttons={
                <LobbyDisplay
                  phase={phase}
                  timeleft={timeleft}
                  admin_controls={admin_controls} />
              }>
              <Box textAlign="center">
                <NoticeBox info>
                  В лобби {readyGhosts.length}/12 валидных игроков.
                </NoticeBox>
                <Flex
                  direction="column">
                  {!!lobbydata && lobbydata.map(lobbyist => (
                    <Flex.Item
                      key={lobbyist}
                      basis={2}
                      className="Section__title candystripe">
                      <Flex
                        height={2}
                        align="center"
                        justify="space-between">
                        <Flex.Item basis={0}>
                          {lobbyist.name}
                        </Flex.Item>
                        <Flex.Item width="30%">
                          <Section>
                            <Box
                              color={
                                lobbyist.status === "Готов" ? "green" : "red"
                              }
                              textAlign="center">
                              {lobbyist.spectating} {lobbyist.status}
                            </Box>
                          </Section>
                        </Flex.Item>
                      </Flex>
                    </Flex.Item>
                  ))}
                </Flex>
              </Box>
            </Section>
          </Flex>
        )}
        {!!roleinfo && (
          <Section
            title={phase}
            minHeight="100px"
            buttons={
              <Box>
                {!!admin_controls && (
                  <Button
                    color="red"
                    icon="gavel"
                    tooltipPosition="bottom-left"
                    tooltip={multiline`
                    Привет админ! Если ты ищешь админскую панель управления, пожалуйста,
                    обрати внимание на дополнительный скроллбар, которого нет у
                    обычных пользователей!`}
                  />
                )} <TimeDisplay auto="down" value={timeleft} />
              </Box>
            }>
            <Flex
              justify="space-between">
              <Flex.Item
                align="center"
                textAlign="center"
                maxWidth="500px">
                <b>Вы - {roleinfo.role}</b><br />
                <b>{roleinfo.desc}</b>
              </Flex.Item>
              <Flex.Item>
                <Box
                  className={classes([
                    'mafia32x32',
                    roleinfo.revealed_icon,
                  ])}
                  style={{
                    'transform': 'scale(2) translate(0px, 10%)',
                    'vertical-align': 'middle',
                  }} />
                <Box
                  className={classes([
                    'mafia32x32',
                    roleinfo.hud_icon,
                  ])}
                  style={{
                    'transform': 'scale(2) translate(-5px, -5px)',
                    'vertical-align': 'middle',
                  }} />
              </Flex.Item>
            </Flex>
          </Section>
        )}
        <Flex>
          {!!actions && actions.map(action => (
            <Flex.Item key={action}>
              <Button
                onClick={() => act("mf_action", { atype: action })}>
                {action}
              </Button>
            </Flex.Item>
          ))}
        </Flex>
        {!!roleinfo && (
          <Section
            title="Суд"
            buttons={
              <Button
                color="transparent"
                icon="info"
                tooltipPosition="left"
                tooltip={multiline`
                Когда кого-то судят, вы решаете его судьбу.
                Победа НЕВИНОВЕН означает, что человек сможет увидеть ещё один день,
                но... в случае поражения этого уже не случится.
                Вы можете не голосовать, нажав на среднюю кнопку.`}
              />
            }>
            <Flex justify="space-around">
              <Button
                icon="smile-beam"
                content="НЕВИНОВЕН!"
                color="good"
                disabled={!judgement_phase}
                onClick={() => act("vote_innocent")} />
              {!judgement_phase && (
                <Box>
                  В данный момент никто не судится.
                </Box>
              )}
              {!!judgement_phase && (
                <Box>
                  Время голосования. Проголосуй или воздержись.
                </Box>
              )}
              <Button
                icon="angry"
                content="ВИНОВЕН!"
                color="bad"
                disabled={!judgement_phase}
                onClick={() => act("vote_guilty")} />
            </Flex>
            <Flex justify="center">
              <Button
                icon="meh"
                content="Воздержаться"
                color="white"
                disabled={!judgement_phase}
                onClick={() => act("vote_abstain")} />
            </Flex>
          </Section>
        )}
        {phase !== "Нет Игры" && (
          <Flex spacing={1}>
            <Flex.Item grow={2}>
              <Section title="Игроки"
                buttons={
                  <Button
                    color="transparent"
                    icon="info"
                    tooltip={multiline`
                    Это список всех игроков.
                    В течение игры вы сможете за них голосовать или,
                    в зависимости от своей роли, выбирать, чтобы использовать свои способности.`}
                  />
                }>
                <Flex
                  direction="column">
                  {!!players && players.map(player => (
                    <Flex.Item
                      height="30px"
                      className="Section__title candystripe"
                      key={player.ref}>
                      <Flex
                        height="18px"
                        justify="space-between"
                        align="center">
                        <Flex.Item basis={16} >
                          {!!player.alive && (<Box>{player.name}</Box>)}
                          {!player.alive && (
                            <Box color="red">{player.name}</Box>)}
                        </Flex.Item>
                        <Flex.Item>
                          {!player.alive && (<Box color="red">МЁРТВ</Box>)}
                        </Flex.Item>
                        <Flex.Item>
                          {player.votes !== undefined && !!player.alive
                            && (<>Голоса : {player.votes} </>)}
                        </Flex.Item>
                        <Flex.Item grow={1} />
                        <Flex.Item>
                          {
                            !!player.actions && player.actions.map(action => {
                              return (
                                <Button
                                  key={action}
                                  onClick={() => act('mf_targ_action', {
                                    atype: action,
                                    target: player.ref,
                                  })}>
                                  {action}
                                </Button>);
                            })
                          }
                        </Flex.Item>
                      </Flex>
                    </Flex.Item>)
                  )}
                </Flex>
              </Section>
            </Flex.Item>
            <Flex.Item grow={2}>
              <Flex
                direction="column"
                height="100%">
                <Section
                  title="Роли и Заметки"
                  buttons={
                    <>
                      <Button
                        color="transparent"
                        icon="address-book"
                        tooltipPosition="bottom-left"
                        tooltip={multiline`
                        Верхний раздел - это роли в игре. Вы можете нажать на знак вопроса,
                        чтобы узнать информацию о роли.`}
                      />
                      <Button
                        color="transparent"
                        icon="edit"
                        tooltipPosition="bottom-left"
                        tooltip={multiline`
                        Нижний раздел - ваши текущие заметки. На некоторых ролях он будет пустой,
                        но на других туда будут записываться ваши действия(детективные расследования)`}
                      />
                    </>
                  }>
                  <Flex
                    direction="column">
                    {!!all_roles && all_roles.map(r => (
                      <Flex.Item
                        key={r}
                        height="30px"
                        className="Section__title candystripe">
                        <Flex
                          height="18px"
                          align="center"
                          justify="space-between">
                          <Flex.Item>
                            {r}
                          </Flex.Item>
                          <Flex.Item
                            textAlign="right">
                            <Button
                              color="transparent"
                              icon="question"
                              onClick={() => act("mf_lookup", {
                                atype: r.slice(0, -3),
                              })}
                            />
                          </Flex.Item>
                        </Flex>
                      </Flex.Item>
                    ))}
                  </Flex>
                </Section>
                {!!roleinfo && (
                  <Flex.Item grow={1}>
                    <Section scrollable
                      fill
                      overflowY="scroll">
                      {roleinfo?.action_log?.map(line => (
                        <Box key={line}>{line}</Box>
                      ))}
                    </Section>
                  </Flex.Item>
                )}
              </Flex>
            </Flex.Item>
          </Flex>
        )}
        <Flex mt={1} direction="column">
          <Flex.Item>
            {!!admin_controls && (
              <Section textAlign="center">
                <Collapsible
                  title="АДМИНСКАЯ ПАНЕЛЬ УПРАВЛЕНИЯ"
                  color="red">
                  <Button
                    icon="exclamation-triangle"
                    color="black"
                    tooltipPosition="top"
                    tooltip={multiline`
                    Почти все это создано для того, чтобы помочь мне отладить
                    игру (ой, отладка игры на 12 игроков!). Так что, оно все
                    грубоватое и склонно ломаться по малейшему поводу.
                    Убедитесь, что Вы знаете действие кнопки, когда жмёте на неё.
                    Так же(один из администраторов это сделал), никого не гибайте и не удаляйте любыми способами!
                    Это приведёт к рантайму, который сломает всю игру, которая сломает сервер!`}
                    content="Предупреждение от Кодеров!"
                    onClick={() => act("next_phase")} /><br />
                  <Button
                    icon="arrow-right"
                    tooltipPosition="top"
                    tooltip={multiline`
                    Это продвинет игру на следующую стадию
                    (дневное обсуждение > дневное голосование, дневное голосование > ночь)
                    довольно забавно это нажимать и Выводить людей из себя,
                    попробуй это в конце раунда!`}
                    content="Следующая Стадия"
                    onClick={() => act("next_phase")} />
                  <Button
                    icon="home"
                    tooltipPosition="top"
                    tooltip={multiline`
                    Надеюсь, Вы не будете нажимать эту кнопку очень часто,
                    это нужно на тот случай, если какой-то игрок
                    каким-то образом сбегает (nullspace, телепортации, открытая дверь).
                    В любом случае, ОЧЕНЬ ПЛОХО ЕСЛИ ЭТО ПРОИЗОЙДЕТ.
                    Используй это, чтобы игроков вернуть, а затем сообщи на гитхаб.`}
                    content="Отправить Всех Домой"
                    onClick={() => act("players_home")} />
                  <Button
                    icon="sync-alt"
                    tooltipPosition="top"
                    tooltip={multiline`
                    Это незамедлительно завершает текущую игру и попытается начать новую`}
                    content="Новая Игра"
                    onClick={() => act("new_game")} />
                  <Button
                    icon="skull"
                    tooltipPosition="top"
                    tooltip={multiline`
                    Удаляет датумы, очищает все landmarks, убивает всех жителей и мафию,
                    стирает место игры. Нажми это, если действительно всё поломано.
                    Ты ведь уже всё сломал, не так ли?`}
                    content="Nuke"
                    onClick={() => act("nuke")} />
                  <br />
                  <Button
                    icon="paint-brush"
                    tooltipPosition="top"
                    tooltip={multiline`
                    Это позволит создать свою настройку для игры, это так... просто.
                    Вы добавляете роль до тех пор, пока не нажмёте CANCEL или FINISH.
                    Сбрасывается после завершения раунда, возвращая случайные настройки.`}
                    content="Создать Свою Настройку"
                    onClick={() => act("debug_setup")} />
                  <Button
                    icon="paint-roller"
                    tooltipPosition="top"
                    tooltip={multiline`
                    Если вы что-то напутали, то можете сюда нажать, чтобы сбросить свою настройку.
                    Игра автоматически сбрасывает её после каждой игры.`}
                    content="Сбросить Свою Настройку"
                    onClick={() => act("cancel_setup")} />
                </Collapsible>
              </Section>
            )}
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const LobbyDisplay = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    phase,
    timeleft,
    admin_controls,
  } = data;
  return (
    <Box>
      [Стадия = {phase} | <TimeDisplay auto="down" value={timeleft} />]{' '}
      <Button
        icon="clipboard-check"
        tooltipPosition="bottom-left"
        tooltip={multiline`
        Регистрация в игру. Если она уже идёт, то
        Вы войдёте в следующую.`}
        content="Войти"
        onClick={() => act("mf_signup")} />
      <Button
        icon="eye"
        tooltipPosition="bottom-left"
        tooltip={multiline`
        Вы будете наблюдателем, пока не Выключите это.
        Автоматически включается, когда Вы умираете, чтобы увидеть результат игры.
        Сообщения не будут приходить, если Вы войдёте в раунд.`}
        content="Наблюдать"
        onClick={() => act("mf_spectate")} />
      {!!admin_controls && (
        <Button
          color="red"
          icon="gavel"
          tooltipPosition="bottom-left"
          tooltip={multiline`
          Привет админ! Если ты ищешь админскую панель управления, пожалуйста,
          обрати внимание на дополнительный скроллбар, которого нет у
          обычных пользователей!`}
        />
      )}
    </Box>
  );
};