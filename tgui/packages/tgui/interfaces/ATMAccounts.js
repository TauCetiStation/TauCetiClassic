/**
 * @file
 * @copyright 2021 0xAF
 * @license MIT
 */

import { useBackend, useLocalState } from '../backend';
import {
  Button,
  LabeledList,
  Section,
  NoticeBox,
  Input,
  Box,
  Table,
} from '../components';
import { Window } from '../layouts';

const ATMRoutes = [
  {
    key: 'home',
    title: 'ATM Accounts | Home',
    component: () => ATMHome,
  },
  {
    key: 'account',
    title: 'ATM Accounts',
    replaceble: true,
    component: () => ATMAccount,
  },
  {
    key: 'new-account',
    title: 'ATM Accounts | Create New Account',
    component: () => ATMCreateAccount,
  },
];

export const ATMAccounts = (props, context) => {
  return (
    <Window width={600} height={640}>
      <Window.Content scrollable>
        <ATMAccountsContent />
      </Window.Content>
    </Window>
  );
};

export const ATMAccountsContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { id_inserted, id_card, viewPage, access_level } = data;
  const currentRoute = viewPage ?? 'index';
  let route = ATMRoutes.find((route) => route.key === currentRoute);
  let RouteComponent = null;
  if (route) RouteComponent = route.component();
  if (id_inserted && access_level <= 0) {
    return (
      <>
        <Section title="ATM Accounts DB | Authorization">
          <LabeledList>
            <LabeledList.Item label="ID">
              <Button
                content={id_card}
                icon="eject"
                onClick={() => act('insert_card')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <NoticeBox danger>Access level too low</NoticeBox>
      </>
    );
  }
  return (
    <>
      <Section title={route?.title ?? 'ATM Accounts DB | Authorization'}>
        <LabeledList>
          <LabeledList.Item label="ID">
            <Button
              content={id_card}
              icon="eject"
              onClick={() => act('insert_card')}
            />
          </LabeledList.Item>
          {id_inserted !== 0 && access_level > 0 && (
            <LabeledList.Item label="Menu">
              <Button
                content="Home"
                selected={route.key === 'home'}
                onClick={() => act('setPage', { page: 'home' })}
              />
              <Button
                content="New Account"
                selected={route.key === 'new-account'}
                onClick={() => act('setPage', { page: 'create-account' })}
              />
              <Button
                content="Print"
                color="grey"
                onClick={() => act('print')}
              />
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>
      {id_inserted !== 0 && <RouteComponent />}
    </>
  );
};

export const ATMHome = (props, context) => {
  const { act, data } = useBackend(context);
  const { accounts } = data;
  return (
    <Section title="NanoTrasen Accounts">
      <Table>
        <Table.Row header>
          <Table.Cell>ID</Table.Cell>
          <Table.Cell>Name</Table.Cell>
          <Table.Cell>Status</Table.Cell>
        </Table.Row>
        {accounts.map((account, i) => (
          <Table.Row key={i}>
            <Table.Cell>
              <Button
                content={`#${account.account_number}`}
                onClick={() =>
                  act('setPage', {
                    page: 'account',
                    account_index: account.account_index,
                  })
                }
              />
            </Table.Cell>
            <Table.Cell textAlign="center">
              <h4>{account.owner_name}</h4>
            </Table.Cell>
            <Table.Cell>
              {account.suspended ? (
                <NoticeBox textAlign="center" danger>
                  Suspended
                </NoticeBox>
              ) : (
                <NoticeBox textAlign="center" success>
                  Active
                </NoticeBox>
              )}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

export const ATMAccount = (props, context) => {
  const { act, data } = useBackend(context);
  const [funds, setFunds] = useLocalState(context, 'funds', 0);
  const {
    account_number,
    owner_name,
    money,
    suspended,
    transactions,
    station_account_number,
    access_level,
  } = data;
  return (
    <Section
      title={`Account Details | #${account_number}`}
      buttons={
        <Button
          icon="chevron-left"
          content="Back"
          onClick={() => act('setPage', { page: 'home' })}
        />
      }>
      <LabeledList>
        <LabeledList.Item label="Holder">
          <h4>{owner_name}</h4>
        </LabeledList.Item>
        <LabeledList.Item label="Balance">{money}$</LabeledList.Item>
        <LabeledList.Item label="Status">
          {suspended ? (
            <NoticeBox textAlign="center" danger>
              Suspended
            </NoticeBox>
          ) : (
            <NoticeBox textAlign="center" success>
              Active
            </NoticeBox>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Controls">
          <Button
            content="Revoke"
            color="bad"
            disabled={account_number === station_account_number}
            onClick={() => act('revoke_payroll')}
          />
          <Button
            content={suspended ? 'Unsuspend' : 'Suspend'}
            color={suspended ? 'average' : 'blue'}
            onClick={() => act('toggle_suspension')}
          />
        </LabeledList.Item>
        {access_level >= 2 && (
          <LabeledList.Item label="Silent Fund Adjustment">
            <Input value={funds} onChange={(e, value) => setFunds(value)} />
            <Button icon="plus" onClick={() => act('add_funds', { funds })} />
            <Button
              icon="minus"
              onClick={() => act('remove_funds', { funds })}
            />
          </LabeledList.Item>
        )}
      </LabeledList>
      <Box my={1}>
        <Table>
          <Table.Row header>
            <Table.Cell>Date</Table.Cell>
            <Table.Cell>Time</Table.Cell>
            <Table.Cell>Target</Table.Cell>
            <Table.Cell>Purpose</Table.Cell>
            <Table.Cell>Value</Table.Cell>
            <Table.Cell>Machine ID</Table.Cell>
          </Table.Row>
          {transactions.map((transact, i) => (
            <Table.Row key={i}>
              <Table.Cell>{transact.date}</Table.Cell>
              <Table.Cell>{transact.time}</Table.Cell>
              <Table.Cell>{transact.target_name}</Table.Cell>
              <Table.Cell>{transact.purpose}</Table.Cell>
              <Table.Cell>{transact.amount}$</Table.Cell>
              <Table.Cell>{transact.source_terminal}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Box>
    </Section>
  );
};
export const ATMCreateAccount = (props, context) => {
  const { act, data } = useBackend(context);
  const [holder, setHolder] = useLocalState(context, 'holder', '');
  const [deposit, setDeposit] = useLocalState(context, 'deposit', 0);
  return (
    <Section title="Account Creation">
      <LabeledList>
        <LabeledList.Item label="Holder">
          <Input
            value={holder}
            onChange={(e, value) => setHolder(value)}
            placeholder="Name"
          />
        </LabeledList.Item>
        <LabeledList.Item
          label="Deposit"
          buttons={
            <Button
              content="Create"
              onClick={() =>
                act('finalise_create_account', {
                  holder_name: holder,
                  starting_funds: deposit,
                })
              }
            />
          }>
          <Input
            value={deposit}
            onChange={(e, value) => setDeposit(value)}
            placeholder="Number"
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
