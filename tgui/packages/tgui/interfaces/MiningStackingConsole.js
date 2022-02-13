import { toTitleCase } from 'common/string';
import { useBackend } from "../backend";
import { Button, Section, LabeledList, AnimatedNumber, NumberInput } from '../components';
import { Window } from "../layouts";

export const MiningStackingConsole = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    stacktypes,
    stackingAmt,
  } = data;

  return (
    <Window width={400} height={500}>
      <Window.Content>
        <Section title="Stacker Controls">
          <LabeledList>
            <LabeledList.Item label="Stacking">
              <NumberInput
                fluid
                value={stackingAmt}
                minValue={1}
                maxValue={50}
                stepPixelSize={5}
                onChange={(e, val) => act("change_stack", { amt: val })} />
            </LabeledList.Item>
            <LabeledList.Divider />
            {stacktypes.length && stacktypes.sort().map(stack => (
              <LabeledList.Item key={stack.type}
                label={toTitleCase(stack.type)} buttons={
                  <Button
                    icon="eject"
                    onClick={() => act("release_stack", { stack: stack.type })}>
                    Eject
                  </Button>
                }>
                <AnimatedNumber value={stack.amt} />
              </LabeledList.Item>
            )) || (
              <LabeledList.Item label="Empty" color="average">
                No stacks in machine.
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
