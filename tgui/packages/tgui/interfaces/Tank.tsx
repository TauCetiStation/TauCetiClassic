import {
  Button,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  tankPressure: number;
  releasePressure: number;
  defaultReleasePressure: number;
  minReleasePressure: number;
  maxReleasePressure: number;
  connected: boolean;
};

export const Tank = () => {
  const { act, data } = useBackend<Data>();
  const {
    tankPressure,
    releasePressure,
    defaultReleasePressure,
    minReleasePressure,
    maxReleasePressure,
    connected,
  } = data;

  return (
    <Window width={400} height={120}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Pressure">
              <ProgressBar
                value={tankPressure / 1013}
                ranges={{
                  good: [0.35, Infinity],
                  average: [0.15, 0.35],
                  bad: [-Infinity, 0.15],
                }}
              >
                {tankPressure} kPa
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Pressure Regulator">
              <Button
                icon="fast-backward"
                disabled={releasePressure === minReleasePressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'min',
                  })
                }
              />
              <NumberInput
                animated
                value={releasePressure}
                step={1}
                tickWhileDragging
                width="100px"
                unit="kPa"
                minValue={minReleasePressure}
                maxValue={maxReleasePressure}
                onChange={(value) =>
                  act('pressure', {
                    pressure: value,
                  })
                }
              />
              <Button
                icon="fast-forward"
                disabled={releasePressure === maxReleasePressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'max',
                  })
                }
              />
              <Button
                icon="undo"
                disabled={releasePressure === defaultReleasePressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'reset',
                  })
                }
              />
              <Button
                icon={connected ? 'toggle-on' : 'toggle-off'}
                selected={connected}
                onClick={() => act('internal')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
