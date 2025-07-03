import { useBackend } from '../backend';
import {
  Button,
  Box,
  LabeledList,
  Section,
  Divider,
  Dropdown,
  Stack,
} from '../components';
import { Window } from '../layouts';

export const Fax = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    scan,
    authenticated,
    sendCooldown,
    paper,
    paperName,
    destination,
    allDepartments,
  } = data;

  return (
    <Window width={400} height={270}>
      <Window.Content>
        <Stack width="100%" textAlign="base">
          <Stack.Item grow italic>
            Confirm Identify:
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="fa fa-sign-in"
              content={scan ? scan : '-------'}
              onClick={() => act('scan')}
            />
          </Stack.Item>
        </Stack>
        <Stack mt={1} width="100%" textAlign="base">
          <Stack.Item grow italic>
            Sending to:
          </Stack.Item>
          <Stack.Item>
            <Dropdown
              width={12}
              selected={destination}
              options={allDepartments}
              onSelected={(dept) => act('setDestination', { to: dept })}
            />
          </Stack.Item>
        </Stack>
        <Divider />
        <Box bold={1}>
          {authenticated
            ? 'Logged in to: Central Command Quantum Entaglement Network'
            : 'This device required to authenticate.'}
        </Box>
        {authenticated ? (
          <>
            <Box bold={1} mt={1}>
              {paperName
                ? 'Currently sending:' + paperName
                : 'Please insert paper, photo or bundle to send via secure connection.'}
            </Box>
            <Stack>
              <Stack.Item>
                <Button
                  mt={1}
                  icon="eject"
                  content={'Remove Paper'}
                  color="red"
                  onClick={() => act('removeitem')}
                  disabled={!paper}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  mt={1}
                  icon="fa fa-reply"
                  content={'Send Message'}
                  color="green"
                  onClick={() => act('send')}
                  disabled={sendCooldown || !paper}
                />
              </Stack.Item>
            </Stack>
          </>
        ) : null}
      </Window.Content>
    </Window>
  );
};
