import { useBackend } from '../backend';
import { Button, Box, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const Fax = (props, context) => {
  const { act, data } = useBackend(context);
  const { scan, authenticated, sendCooldown, paperName, destination } = data;

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
            }>
            <Box style={{ marginTop: '0.5rem' }}>
              Proper authentication is required to use this device
            </Box>
          </LabeledList.Item>
        </LabeledList>
      </Window.Content>
    </Window>
  );
};
