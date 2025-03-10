import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';
import { PortableBasicInfo } from './common/PortableAtmos';

export const PortableScrubber = (props, context) => {
  const { act, data } = useBackend(context);
  const filter_types = data.filter_types || [];
  const {
    target_rate,
    default_rate,
    min_rate,
    max_rate,
  } = data;
  return (
    <Window
      width={300}
      height={405}>
      <Window.Content>
        <PortableBasicInfo />
        <Section title="Scrubber">
          <LabeledList>
            <LabeledList.Item label="Volume Rate">
              <NumberInput
                value={target_rate}
                unit="L/s"
                width="75px"
                minValue={min_rate}
                maxValue={max_rate}
                step={10}
                onChange={(e, value) => act('rate', {
                  rate: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Presets">
              <Button
                icon="minus"
                disabled={target_rate === min_rate}
                onClick={() => act('rate', {
                  rate: 'min',
                })} />
              <Button
                icon="sync"
                disabled={target_rate === default_rate}
                onClick={() => act('rate', {
                  rate: 'reset',
                })} />
              <Button
                icon="plus"
                disabled={target_rate === max_rate}
                onClick={() => act('rate', {
                  rate: 'max',
                })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};