import { useBackend } from '../backend';
import { Button, Flex, Section } from '../components';
import { Window } from '../layouts';

// Код нельзя передавать на фронт но да ладно.
export const Lootcrate = (props, context) => {
  const { act, data } = useBackend(context);
  const { code, buttons_pressed } = data;
  const inCode = (number) => code.includes(number);
  const createKey = (number) => (
    <Button
      key={number}
      content={number}
      color={
        buttons_pressed[number - 1] ? (inCode(number) ? 'good' : 'bad') : null
      }
      onClick={() => act('test_for_luck', { number })}
    />
  );
  const KeyRow = (start, end) => {
    const buttons = [];
    for (let i = start; i < end + 1; i++) buttons.push(createKey(i));
    return <Flex.Item>{buttons}</Flex.Item>;
  };
  return (
    <Window width={235} height={140} theme="ntos">
      <Window.Content>
        <Section>
          <Flex my={1} direction="column" align="center" justify="center">
            {KeyRow(1, 3)}
            {KeyRow(4, 6)}
            {KeyRow(7, 9)}
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
