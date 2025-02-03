import { useBackend } from '../backend';
import { Box, Button, Flex, Grid, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

const NukeKeypad = (props, context) => {
  const { act, data } = useBackend(context);
  const keypadKeys = [
    ['1', '4', '7', 'R'],
    ['2', '5', '8', '0'],
    ['3', '6', '9', 'E'],
  ];
  const { locked, l_setshort, code, emagged } = data;
  return (
    <Box width="185px">
      <Grid width="1px">
        {keypadKeys.map((keyColumn) => (
          <Grid.Column key={keyColumn[0]}>
            {keyColumn.map((key) => (
              <Button
                fluid
                bold
                key={key}
                mb="6px"
                content={key}
                textAlign="center"
                fontSize="40px"
                height="50px"
                lineHeight={1.25}
                disabled={
                  !!emagged ||
                  (!!l_setshort && 1) ||
                  (key !== 'R' && !locked) ||
                  (code === 'ERROR' && key !== 'R' && 1)
                }
                onClick={() => act('type', { digit: key })}
              />
            ))}
          </Grid.Column>
        ))}
      </Grid>
    </Box>
  );
};

export const SecureSafe = (props, context) => {
  const { act, data } = useBackend(context);
  const { code, l_setshort, l_set, emagged, locked } = data;

  let new_code = !(!!l_set || !!l_setshort);

  return (
    <Window width={250} height={380}>
      <Window.Content>
        <Box m="6px">
          {new_code && (
            <NoticeBox textAlign="center" info={1}>
              ENTER NEW 5-DIGIT PASSCODE.
            </NoticeBox>
          )}
          {!!emagged && (
            <NoticeBox textAlign="center" danger={1}>
              LOCKING SYSTEM ERROR - 1701
            </NoticeBox>
          )}
          {!!l_setshort && (
            <NoticeBox textAlign="center" danger={1}>
              ALERT: MEMORY SYSTEM ERROR - 6040 201
            </NoticeBox>
          )}
          <Section height="60px">
            <Box textAlign="center" position="center" fontSize="35px">
              {(code && code) || (
                <Box textColor={locked ? 'red' : 'green'}>
                  {locked ? 'LOCKED' : 'UNLOCKED'}
                </Box>
              )}
            </Box>
          </Section>
          <Flex ml="3px">
            <Flex.Item>
              <NukeKeypad />
            </Flex.Item>
            <Flex.Item ml="6px" width="129px" />
          </Flex>
        </Box>
      </Window.Content>
    </Window>
  );
};
