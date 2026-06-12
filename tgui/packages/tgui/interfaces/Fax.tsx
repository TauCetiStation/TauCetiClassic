import { useBackend } from '../backend';
import { Button, Box, Divider, Dropdown, Stack } from '../components';
import { Window } from '../layouts';

// For symmetrical backend defines look in code\game\machinery\fax.dm
enum PaperType {
  Paper = 1,
  Photo = 2,
  Bundle = 3,
}

type Data = {
  scan?: string;
  authenticated: boolean;
  sendCooldown: number;
  paper: string;
  paperName?: string;
  paperType: number;
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
    paperType,
    destination,
    allDepartments,
  } = data;

  let paperIcon = '';
  switch (paperType) {
    case PaperType.Paper:
      paperIcon = 'file';
      break;
    case PaperType.Photo:
      paperIcon = 'image';
      break;
    case PaperType.Bundle:
      paperIcon = 'paperclip';
      break;
  }

  return (
    <Window width={480} height={320}>
      <Window.Content>
        <Stack width="100%" textAlign="base">
          <Stack.Item grow bold={1}>
            Confirm identity:
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="eject"
              content={scan ? scan : '-------'}
              onClick={() => act('scan')}
              color={!scan ? 'default' : authenticated ? 'green' : 'red'}
              tooltip={
                !scan
                  ? 'Insert the ID-card'
                  : authenticated
                    ? 'Access granted'
                    : 'Access denied'
              }
            />
          </Stack.Item>
        </Stack>
        <Stack mt={1} width="100%" textAlign="base">
          <Stack.Item grow bold={1}>
            Sending to:
          </Stack.Item>
          <Stack.Item>
            <Dropdown
              minWidth={12}
              textAlign="base"
              selected={destination}
              options={allDepartments}
              onSelected={(dept) => act('setDestination', { to: dept })}
            />
          </Stack.Item>
        </Stack>
        <Stack>
          <Stack.Item width="100%" textAlign="base" mt={1} bold={1}>
            Currently sending:
          </Stack.Item>
          <Stack.Item>
            <Button
              mt={1}
              icon={paperIcon}
              content={paper ? paperName : 'Nothing'}
              tooltip={!paper ? 'Add attachment' : 'Remove attachment'}
              onClick={() => act('paperinteraction')}
            />
          </Stack.Item>
        </Stack>
        <Box textAlign={'center'} mt={2}>
          <Divider />
          <Button
            icon="fa-solid fa-paper-plane"
            content={'Send message'}
            onClick={() => act('send')}
            disabled={sendCooldown || !paper || !authenticated}
          />
        </Box>
      </Window.Content>
    </Window>
  );
};
