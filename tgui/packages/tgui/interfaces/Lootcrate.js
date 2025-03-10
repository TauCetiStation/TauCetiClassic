import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const Lootcrate = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    code,
    buttons_pressed,
  } = data;
  return (
    <Window width={235} height={140} theme="ntos">
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item>
              <Button
                top="+6px"
                right="-9px"
                content={1}
                color={buttons_pressed[0] ? (code[0] === 1 || code[1] === 1
                  || code[2] === 1 ? "good" : "bad") : null}
                onClick={() => act('test_for_luck', { number: 1 })} />
              <Button
                top="+6px"
                right="-14px"
                content={2}
                color={buttons_pressed[1] ? (code[0] === 2 || code[1] === 2
                  || code[2] === 2 ? "good" : "bad") : null}
                onClick={() => act('test_for_luck', { number: 2 })} />
              <Button
                top="+6px"
                right="-19px"
                content={3}
                color={buttons_pressed[2] ? (code[0] === 3 || code[1] === 3
                  || code[2] === 3 ? "good" : "bad") : null}
                onClick={() => act('test_for_luck', { number: 3 })} />
            </LabeledList.Item>

            <LabeledList.Item>
              <Button
                top="+5px"
                right="-9px"
                content={4}
                color={buttons_pressed[3] ? (code[0] === 4 || code[1] === 4
                  || code[2] === 4 ? "good" : "bad") : null}
                onClick={() => act('test_for_luck', { number: 4 })} />
              <Button
                top="+5px"
                right="-14px"
                content={5}
                color={buttons_pressed[4] ? (code[0] === 5 || code[1] === 5
                  || code[2] === 5 ? "good" : "bad") : null}
                onClick={() => act('test_for_luck', { number: 5 })} />
              <Button
                top="+5px"
                right="-19px"
                content={6}
                color={buttons_pressed[5] ? (code[0] === 6 || code[1] === 6
                  || code[2] === 6 ? "good" : "bad") : null}
                onClick={() => act('test_for_luck', { number: 6 })} />
            </LabeledList.Item>

            <LabeledList.Item>
              <Button
                top="+4px"
                right="-9px"
                content={7}
                color={buttons_pressed[6] ? (code[0] === 7 || code[1] === 7
                  || code[2] === 7 ? "good" : "bad") : null}
                onClick={() => act('test_for_luck', { number: 7 })} />
              <Button
                top="+4px"
                right="-14px"
                content={8}
                color={buttons_pressed[7] ? (code[0] === 8 || code[1] === 8
                  || code[2] === 8 ? "good" : "bad") : null}
                onClick={() => act('test_for_luck', { number: 8 })} />
              <Button
                top="+4px"
                right="-19px"
                content={9}
                color={buttons_pressed[8] ? (code[0] === 9 || code[1] === 9
                  || code[2] === 9 ? "good" : "bad") : null}
                onClick={() => act('test_for_luck', { number: 9 })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
