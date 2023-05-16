import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, ProgressBar, Section } from '../components';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

export const Apc = (props, context) => {
  return (
    <Window
      width={450}
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
    externalPowerText: 'External Power',
    chargingText: 'Fully Charged',
  },
  1: {
    color: 'average',
    externalPowerText: 'Low External Power',
    chargingText: 'Charging',
  },
  0: {
    color: 'bad',
    externalPowerText: 'No External Power',
    chargingText: 'Not Charging',
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
      <Section title="Power Status">
        <LabeledList>
          <LabeledList.Item
            label="Main Breaker"
            color={externalPowerStatus.color}
            buttons={(
              <Button
                icon={isOperating ? 'power-off' : 'times'}
                content={isOperating ? 'On' : 'Off'}
                selected={isOperating && !isLocked}
                disabled={isLocked}
                onClick={() => act('breaker')} />
            )}>
            [ {externalPowerStatus.externalPowerText} ]
          </LabeledList.Item>
          <LabeledList.Item label="Power Cell">
            {!!powerCellStatus && (
              <ProgressBar
                color="good"
                fractionDigits={1}
                value={powerCellCharge * 0.01} />
            ) || (
              <Box color="bad">
                Power cell removed
              </Box>
            )}
          </LabeledList.Item>
          <LabeledList.Item
            label="Charge Mode"
            color={chargingStatus.color}
            buttons={(
              <Button
                icon={chargeMode ? 'sync' : 'times'}
                content={chargeMode ? 'Auto' : 'Off'}
                disabled={isLocked}
                onClick={() => act('charge')} />
            )}>
            [ {chargingStatus.chargingText} ]
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Power Channels">
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
                      {channel.status >= 2 ? 'On' : 'Off'}
                    </Box>
                    <Button
                      icon="sync"
                      content="Auto"
                      selected={!isLocked && (
                        channel.status === 1 || channel.status === 3
                      )}
                      disabled={isLocked}
                      onClick={() => act('channel', topicParams.auto)} />
                    <Button
                      icon="power-off"
                      content="On"
                      selected={!isLocked && channel.status === 2}
                      disabled={isLocked}
                      onClick={() => act('channel', topicParams.on)} />
                    <Button
                      icon="times"
                      content="Off"
                      selected={!isLocked && channel.status === 0}
                      disabled={isLocked}
                      onClick={() => act('channel', topicParams.off)} />
                  </>
                )}>
                {channel.powerLoad}
              </LabeledList.Item>
            );
          })}
          <LabeledList.Item label="Total Load">
            <b>{totalLoad}</b>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Misc"
        buttons={!!siliconUser && (
          <>
            {!!malfCanHack && (
              <Button
                icon="terminal"
                content="Override Programming"
                color="bad"
                onClick={() => act('hack')} />
            )}
            <Button
              icon="lightbulb-o"
              content="Overload"
              onClick={() => act('overload')} />
          </>
        )}>
        <LabeledList>
          <LabeledList.Item
            label="Cover Lock"
            buttons={(
              <Button
                icon={coverLocked ? 'lock' : 'unlock'}
                content={coverLocked ? 'Engaged' : 'Disengaged'}
                disabled={isLocked}
                onClick={() => act('cover')} />
            )} />
          <LabeledList.Item
            label="Night Shift Lighting"
            buttons={(
              <Button
                icon="lightbulb-o"
                content={nightshiftLights ? 'Enabled' : 'Disabled'}
                onClick={() => act('toggle_nightshift')} />
            )} />
          <LabeledList.Item
            label="Current Lighting Mode"
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
