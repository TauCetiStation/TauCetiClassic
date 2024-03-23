import { Fragment } from "inferno";
import { useBackend } from "../backend";
import { Box, Button, LabeledList, Section, Tabs } from "../components";
import { Window } from "../layouts";
import { AccessList } from './common/AccessList';

export const ComputerCard = (props, context) => {
  const { act, data } = useBackend(context);
  let menuBlock = (
    <Tabs>
      <Tabs.Tab
        icon="id-card"
        selected={data.mode === 0}
        onClick={() => act("mode", { mode: 0 })} >
        Access Modification
      </Tabs.Tab>
      <Tabs.Tab
        icon="folder-open"
        selected={data.mode === 1}
        onClick={() => act("mode", { mode: 1 })}>
        Crew Manifest
      </Tabs.Tab>
      <Tabs.Tab
        icon="scroll"
        selected={data.mode === 2}
        onClick={() => act("mode", { mode: 2 })}>
        Records
      </Tabs.Tab>
    </Tabs>
  );


  let authBlock = (
    <Section title="Authentication">
      <LabeledList>
        <LabeledList.Item label="Target Identity">
          <Button
            icon={data.modify_name ? 'eject' : 'id-card'}
            selected={data.modify_name}
            content={data.modify_name ? data.modify_name : "-----"}
            tooltip={data.modify_name ? "Eject ID" : "Insert ID"}
            onClick={() => act("modify")} />
        </LabeledList.Item>
        <LabeledList.Item label="Authorized Identity">
          <Button
            icon={data.scan_name ? 'eject' : 'id-card'}
            selected={data.scan_name}
            content={data.scan_name ? data.scan_name : "-----"}
            tooltip={data.scan_name ? "Eject ID" : "Insert ID"}
            onClick={() => act("scan")} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );

  let bodyBlock;

  switch (data.mode) {
    case 1: // Access Modification
      if (!data.authenticated || !data.scan_name) {
        bodyBlock = (
          <Section title="Warning" color="red">
            Not logged in.
          </Section>
        );
      } else if (!data.modify_name) {
        bodyBlock = (
          <Section title="Card Missing" color="red">
            No card to modify.
          </Section>
        );
      } else {
        <Fragment>
          <AccessList
            accesses={data.regions}
            selectedList={data.selectedAccess}
            accessMod={ref => act('access', {
              access: ref,
            })}
            grantAll={() => act('grant_all')}
            denyAll={() => act('clear_all')}
            grantDep={ref => act('grant_region', {
              region: ref,
            })}
            denyDep={ref => act('deny_region', {
              region: ref,
            })} />
          <Button
            icon="id-card"
            content={data.printmsg}
            disabled={!data.canprint}
            onClick={() => act("issue")} />
        </Fragment>      }
      break;

    case 2: // Crew Manifest
      if (!data.authenticated || !data.scan_name) {
        bodyBlock = (
          <Section title="Warning" color="red">
            Not logged in.
          </Section>
        );
        bodyBlock = (
          <Section color={data.manifest ? "red" : ""}>
            Crew Manifest:
            {data.manifest ? data.manifest : "Now"}
          </Section>
        );
      }
      break;

    case 3: // records
      if (!data.authenticated) {
        bodyBlock = (
          <Section title="Warning" color="red">
            Not logged in.
          </Section>
        );
      } else if (!data.records.length) {
        bodyBlock = (
          <Section title="Records">
            No records.
          </Section>
        );
      } else {
        bodyBlock = (
          <Section title="Records" buttons={
            <Button
              icon="times"
              content="Delete All Records"
              disabled={!data.authenticated
                || data.records.length === 0
                || data.target_dept}
              onClick={() => act('wipe_all_logs')} />
          }>
            <Table>
              <Table.Row>
                <Table.Cell bold>Crewman</Table.Cell>
                <Table.Cell bold>Old Rank</Table.Cell>
                <Table.Cell bold>New Rank</Table.Cell>
                <Table.Cell bold>Authorized By</Table.Cell>
                <Table.Cell bold>Time</Table.Cell>
                <Table.Cell bold>Reason</Table.Cell>
                {!!data.iscentcom && (
                  <Table.Cell bold>
                    Deleted By
                  </Table.Cell>
                )}
              </Table.Row>
              {data.records(record => (
                <Table.Row key={record.timestamp}>
                  <Table.Cell>{record.transferee}</Table.Cell>
                  <Table.Cell>{record.oldvalue}</Table.Cell>
                  <Table.Cell>{record.newvalue}</Table.Cell>
                  <Table.Cell>{record.whodidit}</Table.Cell>
                  <Table.Cell>{record.timestamp}</Table.Cell>
                  <Table.Cell>{record.reason}</Table.Cell>
                  {!!data.iscentcom && (
                    <Table.Cell>
                      {record.deletedby}
                    </Table.Cell>
                  )}
                </Table.Row>
              ))}
            </Table>
            {!!data.iscentcom && (
              <Box>
                <Button
                  icon="pencil-alt"
                  content="Delete MY Records"
                  color="purple"
                  disabled={!data.authenticated
                    || data.records.length === 0}
                  onClick={() => act('wipe_my_logs')} />
              </Box>
            )}
          </Section>
        );
      }
      break;

    default:
      bodyBlock = (
        <Section title="Warning" color="red">
          ERROR: Unknown Mode.
        </Section>
      );
  }

  return (
    <Window resizable>
      <Window.Content scrollable>
        {menuBlock}
        {authBlock}
        {bodyBlock}
      </Window.Content>
    </Window>
  );

};
