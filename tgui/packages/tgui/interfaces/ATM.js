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
  Flex,
  Table,
  Icon,
} from '../components';
import { Window } from '../layouts';

const ATMRoutes = [
  {
    key: 'index',
    title: 'ATM | Authorization',
    mayBack: false,
    component: () => ATMIndex,
  },
  {
    key: 'profile',
    title: 'ATM | Welcome, %name',
    replaceble: true,
    component: () => ATMProfile,
  },
  {
    key: 'transact',
    title: 'ATM | Transaction Logs',
    mayBack: true,
    component: () => ATMTransact,
  },
  {
    key: 'transfer',
    title: 'ATM | Transferring funds',
    mayBack: true,
    component: () => ATMTransfer,
  },
  {
    key: 'withdrawal',
    title: 'ATM | Withdrawal',
    mayBack: true,
    component: () => ATMWithdrawal,
  },
  {
    key: 'sec',
    title: 'ATM | Change security level',
    mayBack: true,
    component: () => ATMSec,
  },
];

export const ATM = (props, context) => {
  return (
    <Window width={650} height={350}>
      <Window.Content>
        <ATMContent />
      </Window.Content>
    </Window>
  );
};

const ATMContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { authenticated, suspended, emagged } = data;
  const style = {
    display: 'block',
  };
  const currentRoute = data.viewScreen ?? 'index';
  let route = ATMRoutes.find((route) => route.key === currentRoute);
  const RouteComponent = route.component();
  const title = (routeTitle) => {
    return route.replaceble
      ? routeTitle.replace('%name', data.heldName.split("'")[0])
      : routeTitle;
  };
  const mayBack = route.mayBack && (
    <Button content="Back" onClick={() => act('toMenu')} icon="chevron-left" />
  );
  if (emagged)
    return (
      <NoticeBox danger>
        Unauthorized terminal access detected! This
        <span> ATM</span> has been locked. Please contact NanoTrasen IT Support.
      </NoticeBox>
    );
  if (suspended && authenticated) {
    return (
      <NoticeBox danger>
        Access to this account has been suspended, and the funds within frozen.
        <Button
          icon="eject"
          color="bad"
          mt={1}
          onClick={() => {
            act('insert_card');
            act('changepage', { page: 'index' });
          }}
          content={data.heldName}
        />
      </NoticeBox>
    );
  }
  // Suspended account create
  if (currentRoute !== 'index' && !authenticated) {
    return (
      <NoticeBox position="relative" danger>
        <Box mb={1} textAlign="center" inline>
          Requires re-authorization as session expired
          <Box mr={1} inline position="absolute" right="0">
            <Button
              content="Re-auth!"
              color="bad"
              onClick={() => act('changepage', { page: 'index' })}
            />
          </Box>
        </Box>
      </NoticeBox>
    );
  }
  return (
    <>
      <NoticeBox info>
        <span className="text-center" style={style}>
          For all your monetary needs!
        </span>
      </NoticeBox>
      <Section title={title(route.title)} buttons={mayBack}>
        <RouteComponent />
      </Section>
    </>
  );
};

const ATMIndex = (props, context) => {
  const { act, data } = useBackend(context);
  const [num, setNum] = useLocalState(context, 'num', 0);
  const [pin, setPin] = useLocalState(context, 'pin', 0);
  return (
    <LabeledList>
      <LabeledList.Item label="Card">
        <Button
          icon="eject"
          onClick={() => act('insert_card')}
          content={data.heldName}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Account">
        <Input value={num} onChange={(e, value) => setNum(value)} />
      </LabeledList.Item>
      <LabeledList.Item label="PIN">
        <Input value={pin} onChange={(e, value) => setPin(value)} />
      </LabeledList.Item>
      <LabeledList.Item label="Control">
        <Button
          mt={1}
          onClick={() => act('attemp_auth', { num, pin })}
          content="Authenticate"
          icon="chevron-right"
        />
      </LabeledList.Item>
    </LabeledList>
  );
};

const ATMTransact = (props, context) => {
  const { act, data } = useBackend(context);
  const { logs = [] } = data;
  if (!logs) {
    return <NoticeBox danger>Transactions not found!</NoticeBox>;
  } else {
    return (
      <>
        <Box mb={1}>
          <Table>
            <Table.Row>
              <Table.Cell bold>Date</Table.Cell>
              <Table.Cell bold>Time</Table.Cell>
              <Table.Cell bold>Target</Table.Cell>
              <Table.Cell bold>Purpose</Table.Cell>
              <Table.Cell bold>Value</Table.Cell>
              <Table.Cell bold>Machine ID</Table.Cell>
            </Table.Row>
            {logs.map((transact, i) => (
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
        <Button
          onClick={() => act('print_transaction')}
          content="Print transactions"
        />
      </>
    );
  }
};

const ATMTransfer = (props, context) => {
  const { act, data } = useBackend(context);
  const [num, setNum] = useLocalState(context, 'num', 0);
  const [money, setMoney] = useLocalState(context, 'money', 0);
  const [purpose, setPurpose] = useLocalState(
    context,
    'purpose',
    'Without a goal'
  );
  return (
    <LabeledList>
      <LabeledList.Item label="Balance">
        <b>{data.money}$</b>
      </LabeledList.Item>
      <LabeledList.Item label="Target account number">
        <Input
          placeholder="Number"
          value={num}
          onChange={(e, value) => setNum(value)}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Funds to transfer">
        <Input
          placeholder="Amount"
          value={money}
          onChange={(e, value) => setMoney(value)}
        />
      </LabeledList.Item>
      <LabeledList.Item
        label="Transaction purpose"
        buttons={
          <Button
            content="Transfer funds"
            onClick={() =>
              act('transferTo', {
                funds_amount: money,
                target_acc_number: num,
                purpose: purpose,
              })
            }
          />
        }>
        <Input
          fluid
          value={purpose}
          placeholder="Purpose"
          onChange={(e, value) => setPurpose(value)}
        />
      </LabeledList.Item>
    </LabeledList>
  );
};

const ATMSec = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <LabeledList>
      <LabeledList.Item label="New security level">
        <Button
          selected={data.secLvl === 0}
          content="Zero"
          onClick={() => act('setSecLvl', { lvl: 0 })}
          tooltip="Either the account number or card is required to access this account. EFTPOS transactions will require a card and ask for a pin, but not verify the pin is correct"
        />
        <Button
          selected={data.secLvl === 1}
          content="One"
          onClick={() => act('setSecLvl', { lvl: 1 })}
          tooltip="An account number and pin must be manually entered to access this account and process transactions."
        />
        <Button
          selected={data.secLvl === 2}
          onClick={() => act('setSecLvl', { lvl: 2 })}
          content="Two"
          tooltip="In addition to account number and pin, a card is required to access this account and process transactions."
        />
      </LabeledList.Item>
    </LabeledList>
  );
};

const ATMProfile = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <>
      <LabeledList>
        <LabeledList.Item label="Balance">
          <b>{data.money}$</b>
        </LabeledList.Item>
        <LabeledList.Item label="Stock of money in ATM">
          <b>{data.moneyStock}$</b>
        </LabeledList.Item>
      </LabeledList>
      <Section
        fluid
        mt={1}
        title="Menu"
        buttons={
          <Button
            icon="sign-out-alt"
            onClick={() => act('logout')}
            content="Sign out"
          />
        }>
        <Flex direction="column">
          <Button
            fluid
            color="grey"
            onClick={() => act('balance_statement')}
            content="Print balance statement"
          />
          <Button
            fluid
            onClick={() => act('changepage', { page: 'sec' })}
            content="Change account security level"
          />
          <Button
            fluid
            onClick={() => act('changepage', { page: 'transact' })}
            content="View transaction log"
          />
          <Button
            fluid
            onClick={() => act('changepage', { page: 'transfer' })}
            content="Make transfer"
          />
          <Button
            fluid
            onClick={() => act('changepage', { page: 'withdrawal' })}
            content="Withdrawal"
          />
        </Flex>
      </Section>
    </>
  );
};

const ATMWithdrawal = (props, context) => {
  const { act, data } = useBackend(context);
  const [MoneyFormat, setMoneyFormat] = useLocalState(
    context,
    'MoneyFormat',
    'Chip'
  );
  const [funds, setFunds] = useLocalState(context, 'funds', 0);
  return (
    <LabeledList>
      <LabeledList.Item label="Balance">
        <b>{data.money}$</b>
      </LabeledList.Item>
      <LabeledList.Item label="Select money format">
        <Button
          selected={MoneyFormat === 'Chip'}
          content="Chip"
          onClick={() => setMoneyFormat('Chip')}
        />
        <Button
          selected={MoneyFormat === 'Cash'}
          content="Cash"
          onClick={() => setMoneyFormat('Cash')}
        />
      </LabeledList.Item>
      <LabeledList.Item
        label="Funds amount"
        buttons={
          <Button
            content="Withdraw"
            onClick={() =>
              act('withdrawal', {
                moneyFormat: MoneyFormat,
                funds_amount: funds,
              })
            }
          />
        }>
        <Input value={funds} onChange={(e, value) => setFunds(value)} />
      </LabeledList.Item>
    </LabeledList>
  );
};
