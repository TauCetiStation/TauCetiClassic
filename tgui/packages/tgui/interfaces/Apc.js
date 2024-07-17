import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, ProgressBar, Section } from '../components';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

export const Apc = (props, context) => {
  return (
    <Window
      width={500}
      height={445}>
      <Window.Content scrollable>
        <ApcContent />
      </Window.Content>
    </Window>
  );
};

const powerStatusMap = {
  2: {
    color: 'good',
    externalPowerText: 'Питание от сети',
    chargingText: 'Заряжен',
  },
  1: {
    color: 'average',
    externalPowerText: 'Низкое напряжение в сети',
    chargingText: 'Идёт зарядка...',
  },
  0: {
    color: 'bad',
    externalPowerText: 'Нет внешнего питания',
    chargingText: 'Не заряжается',
  },
};

const ApcContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    locked,
    isOperating,
    externalPower,
    powerCellStatus,
    powerCellCharge,
    chargeMode,
    charging,
    totalLoad,
    coverLocked,
    siliconUser,
    malfCanHack,
    nightshiftLights,
    smartlightMode,
    powerChannels,
  } = data;
  const isLocked = locked && !siliconUser;
  const externalPowerStatus = powerStatusMap[externalPower]
    || powerStatusMap[0];
  const chargingStatus = powerStatusMap[charging]
    || powerStatusMap[0];
  const channelArray = powerChannels || [];
  return (
    <>
      <InterfaceLockNoticeBox />
      <Section title="Сеть">
        <LabeledList>
          <LabeledList.Item
            label="Вводный автомат"
            color={externalPowerStatus.color}
            buttons={(
              <Button
                icon={isOperating ? 'power-off' : 'times'}
                content={isOperating ? 'Вкл.' : 'Выкл.'}
                selected={isOperating && !isLocked}
                disabled={isLocked}
                onClick={() => act('breaker')} />
            )}>
            [ {externalPowerStatus.externalPowerText} ]
          </LabeledList.Item>
          <LabeledList.Item label="Аккумулятор">
            {!!powerCellStatus && (
              <ProgressBar
                color="good"
                fractionDigits={1}
                value={powerCellCharge * 0.01} />
            ) || (
              <Box color="bad">
                Извлечён
              </Box>
            )}
          </LabeledList.Item>
          <LabeledList.Item
            label="Режим зарядки"
            color={chargingStatus.color}
            buttons={(
              <Button
                icon={chargeMode ? 'sync' : 'times'}
                content={chargeMode ? 'Авт.' : 'Выкл.'}
                disabled={isLocked}
                onClick={() => act('charge')} />
            )}>
            [ {chargingStatus.chargingText} ]
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Автоматы">
        <LabeledList>
          {channelArray.map(channel => {
            const { topicParams } = channel;
            return (
              <LabeledList.Item
                key={channel.title}
                label={channel.title}
                buttons={(
                  <>
                    <Box inline mx={2}
                      color={channel.status >= 2 ? 'good' : 'bad'}>
                      {channel.status >= 2 ? 'Вкл.' : 'Выкл.'}
                    </Box>
                    <Button
                      icon="sync"
                      content="Авт."
                      selected={!isLocked && (
                        channel.status === 1 || channel.status === 3
                      )}
                      disabled={isLocked}
                      onClick={() => act('channel', topicParams.auto)} />
                    <Button
                      icon="power-off"
                      content="Вкл."
                      selected={!isLocked && channel.status === 2}
                      disabled={isLocked}
                      onClick={() => act('channel', topicParams.on)} />
                    <Button
                      icon="times"
                      content="Выкл."
                      selected={!isLocked && channel.status === 0}
                      disabled={isLocked}
                      onClick={() => act('channel', topicParams.off)} />
                  </>
                )}>
                {channel.powerLoad}
              </LabeledList.Item>
            );
          })}
          <LabeledList.Item label="Общая нагрузка">
            <b>{totalLoad}</b>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Разное"
        buttons={!!siliconUser && (
          <>
            {!!malfCanHack && (
              <Button
                icon="terminal"
                content="Перепрошить"
                color="bad"
                onClick={() => act('hack')} />
            )}
            <Button
              icon="lightbulb-o"
              content="Перегрузить"
              onClick={() => act('overload')} />
          </>
        )}>
        <LabeledList>
          <LabeledList.Item
            label="Крышка"
            buttons={(
              <Button
                icon={coverLocked ? 'lock' : 'unlock'}
                content={coverLocked ? 'Заблокирована' : 'Разблокирована'}
                disabled={isLocked}
                onClick={() => act('cover')} />
            )} />
          <LabeledList.Item
            label="Ночной режим"
            buttons={(
              <Button
                icon="lightbulb-o"
                content={nightshiftLights ? 'Вкл' : 'Выкл'}
                onClick={() => act('toggle_nightshift')} />
            )} />
          <LabeledList.Item
            label="Текущий режим освещения"
            buttons={(
              <Button
                icon="lightbulb-o"
                content={smartlightMode}
                onClick={() => act('change_smartlight')} />
            )} />
        </LabeledList>
      </Section>
    </>
  );
};
