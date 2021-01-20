import { useBackend } from '../backend';
import { Button, Box, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const Lootcrate = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    attempts,
    buttons_pressed,
  } = data;
  return (
    <Window width={300} height={180}>
      <Window.Content>
        <Section title="Secret crate">
          {attempts >= 3 && (
            <Box color="good">
              You have {attempts} attempts to get a prize!
            </Box>
          )}
          {attempts === 2 && (
            <Box color="average">
              You have {attempts} attempts to get a prize!
            </Box>
          )}
          {attempts === 1 && (
            <Box color="bad">
              You have LAST chance to get a prize!
            </Box>
          )}
          <LabeledList>
            <LabeledList.Item label="Numbers">
              <Button
                top="+4px"
                right="+5px"
                icon=""
                content={1}
                selected={data.buttons_pressed[0] ? "selected" : null}
                onClick={() => act('test_for_luck', { number: 1 })} />
              <Button
                top="+4px"
                right="0px"
                icon=""
                content={2}
                selected={data.buttons_pressed[1] ? "selected" : null}
                onClick={() => act('test_for_luck', { number: 2 })} />
              <Button
                top="+4px"
                right="-5px"
                icon=""
                content={3}
                selected={data.buttons_pressed[2] ? "selected" : null}
                onClick={() => act('test_for_luck', { number: 3 })} />
            </LabeledList.Item>

            <LabeledList.Item>
              <Button
                top="+3px"
                right="+5px"
                icon=""
                content={4}
                selected={data.buttons_pressed[3] ? "selected" : null}
                onClick={() => act('test_for_luck', { number: 4 })} />
              <Button
                top="+3px"
                right="0px"
                icon=""
                content={5}
                selected={data.buttons_pressed[4] ? "selected" : null}
                onClick={() => act('test_for_luck', { number: 5 })} />
              <Button
                top="+3px"
                right="-5px"
                icon=""
                content={6}
                selected={data.buttons_pressed[5] ? "selected" : null}
                onClick={() => act('test_for_luck', { number: 6 })} />
            </LabeledList.Item>

            <LabeledList.Item>
              <Button
                top="+2px"
                right="+5px"
                icon=""
                content={7}
                selected={data.buttons_pressed[6] ? "selected" : null}
                onClick={() => act('test_for_luck', { number: 7 })} />
              <Button
                top="+2px"
                right="0px"
                icon=""
                content={8}
                selected={data.buttons_pressed[7] ? "selected" : null}
                onClick={() => act('test_for_luck', { number: 8 })} />
              <Button
                top="+2px"
                right="-5px"
                icon=""
                content={9}
                selected={data.buttons_pressed[8] ? "selected" : null}
                onClick={() => act('test_for_luck', { number: 9 })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
