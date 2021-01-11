import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const Tank = (props, context) => {
  const { act, data } = useBackend(context);
  const {code,
  } = data;
  return (
    <Window
      width={400}
      height={120}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Pressure Regulator">
              <Button
                icon={data.connected ? "toggle-on" : "toggle-off"}
                content=""
                onClick={() => act('test_for_luck'), {
                  number: 1,
                }} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
