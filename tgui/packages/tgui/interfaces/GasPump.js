import { useBackend } from '../backend';
import {
  AnimatedNumber,
  Button,
  LabeledList,
  NumberInput,
  Section,
} from '../components';
import { Window } from '../layouts';

export const GasPump = (props, context) => {
  const { act, data } = useBackend(context);
  const { on, pressure_set, max_pressure, last_power_draw, max_power_draw } =
    data;
  return (
    <Window width={300} height={130}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                icon={on ? 'toggle-on' : 'toggle-off'}
                content={on ? 'On' : 'Off'}
                tooltip={on ? 'Toggle off' : 'Toggle on'}
                selected={on}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Target pressure">
              <Button
                icon="fast-backward"
                textAlign="center"
                disabled={pressure_set === 0}
                width={2.2}
                onClick={() => act('min')}
              />
              <NumberInput
                animated
                unit="kPa"
                width={6.1}
                lineHeight={1.5}
                step={10}
                minValue={0}
                maxValue={max_pressure}
                value={pressure_set}
                onChange={(e, value) =>
                  act('set', {
                    rate: value,
                  })
                }
              />
              <Button
                icon="fast-forward"
                textAlign="center"
                disabled={pressure_set === max_pressure}
                width={2.2}
                onClick={() => act('max')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Power load">
              <AnimatedNumber value={last_power_draw + ' W'} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
