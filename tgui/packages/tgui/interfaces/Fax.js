import { useBackend } from '../backend';
import {
  Button,
  Box,
  LabeledList,
  Section,
  Divider,
  Dropdown,
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
        <Box bold={1} m={1}>
          {authenticated
            ? 'Logged in to: Central Command Quantum Entaglement Network'
            : 'This device required to authenticate'}
        </Box>
        <Box bold={1} m={1}>
          {paperName
            ? 'Currently sending:' + paperName
            : 'Please insert paper, photo or bundle to send via secure connection.'}
        </Box>
        <Button
          icon="eject"
          content={'Remove Item'}
          onClick={() => act('removeitem')}
        />
        <Button
          icon="eject"
          content={'Send Message'}
          onClick={() => act('sendmessage')}
        />
        <Divider />
        <LabeledList>
          <LabeledList.Item
            label="Sending to"
            buttons={
              <Dropdown
                inline
                width={20}
                selected={destination}
                options={allDepartments}
                onSelected={(dept) => act('setDestination', { to: dept })}
              />
            }
          />
        </LabeledList>
      </Window.Content>
    </Window>
  );
};
