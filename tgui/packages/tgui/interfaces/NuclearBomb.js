import { useBackend } from '../backend';
import { Button, Box, Grid, LabeledList, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

const NukeKeypad = (props, context) => {
  const { act, data } = useBackend(context);
  const keypadKeys = [
    ['1', '4', '7', 'R'],
    ['2', '5', '8', '0'],
    ['3', '6', '9', 'E'],
  ];
  const {
    code,
    hasDisk,
    deployed,
  } = data;
  return (
    <Box
      width="306px"
      align="center">
      <Grid width="35%">
        {keypadKeys.map(keyColumn => (
          <Grid.Column key={keyColumn[0]}>
            {keyColumn.map(key => (
              <Button
                fluid
                bold
                key={key}
                mb="6px"
                content={key}
                textAlign="center"
                fontSize="20px"
                height="25px"
                lineHeight={1.25}
                disabled={code==="ERROR" && key!=="R" || !hasDisk || !deployed}
                onClick={() => act('type', { digit: key })} />
            ))}
          </Grid.Column>
        ))}
      </Grid>
    </Box>
  );
};

export const NuclearBomb = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    deployed,
    timing,
    timeLeft,
    safety,
    hasDisk,
    authorized,
    code,
    timerMin,
    timerMax,
  } = data;
  return (
    <Window
      width={326}
      height={400}>
      <Window.Content>
        <Section title="Статус" fill buttons={(
          <Box textAlign="right">
            <Button
              color={deployed ? "green" : "red"}
              content={deployed ? "Развернута" : "Не развернута"}
              icon={"power-off"}
              disabled={!safety || timing}
              onClick={() => act('deploy')}
            />
          </Box>
        )}>
          <LabeledList>
            <LabeledList.Item label="Диск аутентификации">
              <Box textAlign="right">
                <Button
                  selected={hasDisk}
                  icon={"eject"}
                  content={hasDisk ? "Вставлен" : "Не вставлен"}
                  disabled={!deployed}
                  onClick={() => act(hasDisk ? 'ejectDisk' : 'insertDisk')}
                />
              </Box>
            </LabeledList.Item>
          </LabeledList>
          <br />
          <Box
            fontSize="25px"
            textAlign="center"
            position="center">
            {code && (code) || (
              <Box textColor={authorized ? "green" : "red"}>
                {authorized ? "ДОСТУП РАЗРЕШЁН" : hasDisk ? "ВВЕДИТЕ КОД" : deployed ? "ВСТАВЬТЕ ДИСК" : "ДИСК НЕ ВСТАВЛЕН"}
              </Box>)}
          </Box>
          <NukeKeypad />
          <br />
          <LabeledList>
            <LabeledList.Item label="Осталось времени">
              <ProgressBar
                value={timeLeft / timerMax}
                ranges={{
                  good: [0.65, Infinity],
                  average: [0.25, 0.65],
                  bad: [-Infinity, 0.25],
                }}>
                {timeLeft} секунд
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Регулятор таймера">
              <Button
                icon="fast-backward"
                disabled={!authorized || timeLeft <= timerMin}
                width="23.5%"
                onClick={() => act('adjustTimer', { time: timerMin })}
              />
              <Button
                icon="backward"
                disabled={!authorized || timeLeft <= timerMin}
                width="23.5%"
                onClick={() => act('adjustTimer', { time: timeLeft - 5 })}
              />
              <Button
                icon="forward"
                disabled={!authorized || timeLeft >= timerMax}
                width="23.5%"
                onClick={() => act('adjustTimer', { time: timeLeft + 5 })}
              />
              <Button
                icon="fast-forward"
                disabled={!authorized || timeLeft >= timerMax}
                width="23.5%"
                onClick={() => act('adjustTimer', { time: timerMax })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Предохранитель">
              <Button
                selected={safety}
                icon={safety ? "toggle-on" : "toggle-off"}
                content={safety ? "Включён" : "Отключён"}
                disabled={!authorized || timing && !safety}
                onClick={() => act('toggleSafety')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Таймер">
              <Button
                selected={timing}
                icon={"power-off"}
                disabled={!authorized || safety}
                content={timing ? "Включён" : "Отключён"}
                onClick={() => act('bombSet')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
