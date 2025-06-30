import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const SampleInterface = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const { scan, color } = data;
  return (
    <Window width={300} height={405}>
      <Window.Content>
        <Section
          title="Аутентификация в систему"
          minHeight="82px"
          buttons={
            <Button
              icon="eject"
              content={scan ? scan.name : '--------'}
              onClick={() => act('confirm')}
            />
          }
        />
      </Window.Content>
    </Window>
  );
};
