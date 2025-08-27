import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  Section,
  Box,
  ProgressBar,
  Divider,
} from '../components';
import { Window } from '../layouts';

export const DisposalUnit = (props, context) => {
  const { act, data } = useBackend(context);
  let stateColor;
  let stateText;
  if (data.mode === 2) {
    stateColor = 'good';
    stateText = 'Готов к работе';
  } else if (data.mode === 0) {
    stateColor = 'bad';
    stateText = 'Отключён';
  } else if (data.mode < 0) {
    stateColor = 'bad';
    stateText = 'N/A';
  } else if (data.mode === 1) {
    stateColor = 'average';
    stateText = 'Подготовка';
  } else {
    stateColor = 'average';
    stateText = 'Не активен';
  }
  return (
    <Window width={400} height={200}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Статус" color={stateColor}>
              {stateText}
            </LabeledList.Item>
            <LabeledList.Item label="Переработка">
              <ProgressBar
                ranges={{
                  bad: [-Infinity, 0],
                  average: [0, 99],
                  good: [99, Infinity],
                }}
                value={data.pressure}
                minValue={0}
                maxValue={100}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Статус переработки">
              <Button
                icon="toggle-off"
                disabled={data.isAI || data.panel_open}
                content="Отключена"
                selected={data.flushing ? null : 'selected'}
                onClick={() => act('handle-0')}
              />
              <Button
                icon="toggle-on"
                disabled={data.isAI || data.panel_open}
                content="Включена"
                selected={data.flushing ? 'selected' : null}
                onClick={() => act('handle-1')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Питание">
              <Button
                icon="toggle-off"
                disabled={data.mode === -1}
                content="Выкл"
                selected={data.mode ? null : 'selected'}
                onClick={() => act('pump-0')}
              />
              <Button
                icon="toggle-on"
                disabled={data.mode === -1}
                content="Включить"
                selected={data.mode ? 'selected' : null}
                onClick={() => act('pump-1')}
              />
            </LabeledList.Item>
          </LabeledList>
          <Box textAlign={'center'} mt={2}>
            <Divider />
            <Button
              icon="sign-out-alt"
              disabled={data.isAI}
              content="Вытащить содержимое"
              onClick={() => act('eject')}
            />
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
