import { InfernoNode } from 'inferno';
import { useBackend } from '../backend';
import { Component } from 'inferno';

import {
  Button,
  Box,
  LabeledList,
  Section,
  Divider,
  Dropdown,
  Stack,
  Tooltip,
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
              icon="eject"
              content={scan ? scan : '-------'}
              onClick={() => act('scan')}
              color={authenticated ? 'green' : 'red'}
              tooltip={
                'Green means authorization to the system. Red means lack of access.'
              }
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
        {authenticated ? (
          <Component>
            <Stack width="100%" textAlign="base">
              <Stack.Item>Currently sending:</Stack.Item>
              <Stack.Item>
                <Button
                  mt={1}
                  icon="fa fa-file"
                  content={paperName ? paperName : 'No content found'}
                  onClick={() => act('removeitem')}
                  disabled={!paper}
                />
              </Stack.Item>
            </Stack>
            <Button
              textAlign={'center'}
              icon="fa fa-reply"
              content={'Send Message'}
              onClick={() => act('send')}
              disabled={sendCooldown || !paper}
            />
          </Component>
        ) : null}
      </Window.Content>
    </Window>
  );
};
