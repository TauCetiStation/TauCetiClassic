import { InfernoNode } from 'inferno';
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

type Data = {
  scan?: string;
  authenticated: boolean;
  sendCooldown: number;
  paper: string;
  paperName?: string;
  destination: string;
  allDepartments: string[];
};

export const Fax = (props, context) => {
  const { act, data } = useBackend<Data>(context);
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
        <Box>
          {authenticated
            ? 'Authentication was successful.'
            : 'This device required to authenticate.'}
        </Box>
        {authenticated ? (
          <Stack mt={2} width="100%">
            <Stack.Item>Currently sending:</Stack.Item>
            <Stack.Item>
              <Button
                icon="fa fa-file"
                content={paperName ? paperName : 'No content found'}
                onClick={() => act('removeitem')}
                disabled={!paper}
              />
            </Stack.Item>
            <Stack.Item grow>
              <Button
                icon="fa fa-reply"
                content={'Send Message'}
                onClick={() => act('send')}
                disabled={sendCooldown || !paper}
              />
            </Stack.Item>
          </Stack>
        ) : null}
      </Window.Content>
    </Window>
  );
};
