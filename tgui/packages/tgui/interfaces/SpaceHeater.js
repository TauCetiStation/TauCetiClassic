import { useBackend } from '../backend';
import {
  AnimatedNumber,
  Button,
  Knob,
  LabeledControls,
  LabeledList,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

export const SpaceHeater = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    open,
    on,
    mode,
    hasPowercell,
    powercellName,
    powerLevel,
    targetTemp,
    minTemp,
    maxTemp,
    currentTemp,
  } = data;
  return (
    <Window width={420} height={270}>
      <Window.Content>
        <Section
          title="Power"
          buttons={
            <Button
              icon={on ? 'power-off' : 'times'}
              content={on ? 'On' : 'Off'}
              selected={on}
              onClick={() => act('power')}
            />
          }>
          <LabeledList>
            {!!open && (
              <LabeledList.Item label="Powercell">
                <Button
                  content={powercellName ? powercellName : '-----'}
                  tooltip={
                    hasPowercell ? 'Eject powercell' : 'Insert powercell'
                  }
                  onClick={() => act('operateCell')}
                />
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Stored energy">
              <ProgressBar
                ranges={{
                  good: [50, Infinity],
                  average: [25, 50],
                  bad: [-Infinity, 25],
                }}
                minValue={0}
                maxValue={100}
                value={powerLevel}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Thermostat">
          <LabeledControls>
            <LabeledControls.Item label="Current temperature">
              <AnimatedNumber value={currentTemp} />
              {currentTemp !== 'N/A' && '℃'}
            </LabeledControls.Item>
            <LabeledControls.Item label="Target temperature">
              <Knob
                size={2}
                value={targetTemp}
                unit={'℃'}
                minValue={minTemp}
                maxValue={maxTemp}
                onChange={(e, value) =>
                  act('setTemp', {
                    temperature: value,
                  })
                }
              />
              <AnimatedNumber value={targetTemp} />
              {targetTemp !== 'N/A' && '℃'}
            </LabeledControls.Item>
            <LabeledControls.Item label="Operational mode">
              <Button content={mode} onClick={() => act('mode')} />
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
      </Window.Content>
    </Window>
  );
};
