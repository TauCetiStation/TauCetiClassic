import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const SampleInterface = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    health,
    color,
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Health status">
          <LabeledList>
            <LabeledList.Item label="Health">
              {health}
            </LabeledList.Item>
            <LabeledList.Item label="Color">
              {color}
            </LabeledList.Item>
            <LabeledList.Item label="Button">
              <Button
                content="Dispatch a 'test' action"
                onClick={() => act('test')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
