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
    paperName,
    destination,
    allDepartments,
  } = data;

  return (
    <Window width={300} height={405}>
      <Window.Content>
        <LabeledList>
          <LabeledList.Item
            label="Confirm Identify"
            buttons={
              <Button
                icon="eject"
                content={scan ? scan : '-------'}
                onClick={() => act('scan')}
              />
            }
          />
          <LabeledList.Item
            label="Auth"
            buttons={
              <Button
                icon="eject"
                content={authenticated ? 'Log Out' : 'Log In'}
                onClick={() => act('authenticated')}
              />
            }
          />
        </LabeledList>
        <Divider />
        <Box bold={1}>
          {authenticated
            ? 'Logged in to: Central Command Quantum Entaglement Network'
            : 'This device required to authenticate.'}
        </Box>
        {authenticated ? (
          <Box bold={1} mt={1}>
            {paperName
              ? 'Currently sending:' + paperName
              : 'Please insert paper, photo or bundle to send via secure connection.'}
          </Box>
        ) : null}
        <Button
          mt={1}
          icon="eject"
          content={'Remove Item'}
          onClick={() => act('removeitem')}
        />
        <Button
          icon="eject"
          content={'Send Message'}
          onClick={() => act('sendmessage')}
          disabled={sendCooldown}
        />
        <Divider />
        <Stack>
          <Stack.Item>Sending to:</Stack.Item>
          <Stack.Item>
            <Dropdown
              width={12}
              selected={destination}
              options={allDepartments}
              onSelected={(dept) => act('setDestination', { to: dept })}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
