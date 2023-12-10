import { round } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import {
  AnimatedNumber,
  Box,
  Button,
  Flex,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Table,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

const stats = [
  ['good', 'Alive'],
  ['average', 'Critical'],
  ['bad', 'DEAD'],
];

const abnormalities = [
  ['hasBorer', 'bad', 'Subject suffering from aberrant brain activity. Recommend further incision.'],
  ['hasVirus', 'bad', 'Viral pathogen detected in blood stream.'],
  ['blind', 'average', 'Cataracts detected.'],
  ['colourblind', 'average', 'Photoreceptor abnormalities detected.'],
  ['nearsighted', 'average', 'Retinal misalignment detected.'],
];

const damages = [
  ['Respiratory', 'oxyLoss'],
  ['Brain', 'brainLoss'],
  ['Toxin', 'toxLoss'],
  ['Radiation', 'radLoss'],
  ['Brute', 'bruteLoss'],
  ['Clone', 'cloneLoss'],
  ['Burn', 'fireLoss'],
  ['Drunkenness', 'drunkenness'],
];

const damageRange = {
  average: [0.25, 0.5],
  bad: [0.5, Infinity],
};

const mapTwoByTwo = (a, c) => {
  let result = [];
  for (let i = 0; i < a.length; i += 2) {
    result.push(c(a[i], a[i + 1], i));
  }
  return result;
};

const reduceOrganStatus = (A) => {
  return A.length > 0
    ? A.filter((s) => !!s).reduce(
      (a, s) => (
        <Fragment>
          {a}
          <Box key={s}>{s}</Box>
        </Fragment>
      ),
      null
    )
    : null;
};

export const BodyScanner = (props, context) => {
  const { data } = useBackend(context);
  const { occupied, occupant = {} } = data;
  const body = occupied ? (
    <BodyScannerMain occupant={occupant} />
  ) : (
    <BodyScannerEmpty />
  );
  return (
    <Window resizable>
      <Window.Content scrollable className="Layout__content--flexColumn">
        {body}
      </Window.Content>
    </Window>
  );
};

const BodyScannerMain = (props) => {
  const { occupant } = props;
  return (
    <Box>
      <BodyScannerMainOccupant occupant={occupant} />
      <BodyScannerMainAbnormalities occupant={occupant} />
      <BodyScannerMainDamage occupant={occupant} />
      <BodyScannerMainOrgansExternal organs={occupant.extOrgan} />
      <BodyScannerMainOrgansInternal organs={occupant.intOrgan} />
    </Box>
  );
};

const BodyScannerMainOccupant = (props, context) => {
  const { act, data } = useBackend(context);
  const { occupant } = data;
  return (
    <Section
      title="Occupant"
      buttons={
        <Fragment>
          <Button icon="print" onClick={() => act('print_p')}>
            Print Report
          </Button>
          <Button icon="user-slash" onClick={() => act('ejectify')}>
            Eject
          </Button>
        </Fragment>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Name">{occupant.name}</LabeledList.Item>
        <LabeledList.Item label="Health">
          <ProgressBar
            min="0"
            max={occupant.maxHealth}
            value={occupant.health / occupant.maxHealth}
            ranges={{
              good: [0.5, Infinity],
              average: [0, 0.5],
              bad: [-Infinity, 0],
            }}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Blood">
          {occupant.blood.hasBlood ? (
            <ProgressBar
              min="0"
              max={occupant.blood.bloodNormal}
              value={occupant.blood.bloodLevel / occupant.blood.bloodNormal}
              ranges={{
                good: [0.8, Infinity],
                average: [0.6, 0.8],
                bad: [-Infinity, 0.6],
              }}>
              <Box inline
                style={{
                  float: 'left',
                }}>
                {occupant.blood.pulse} BPM
              </Box>
              <Box inline>
                {occupant.blood.percent}%
              </Box>
            </ProgressBar>
          ) : (
            <Box color="average">
              Not detected
            </Box>
          )}

        </LabeledList.Item>
        <LabeledList.Item label="Status" color={stats[occupant.stat][0]}>
          {stats[occupant.stat][1]}
        </LabeledList.Item>
        <LabeledList.Item label="Temperature">
          <AnimatedNumber value={round(occupant.bodyTempC, 0)} />
          &deg;C,&nbsp;
          <AnimatedNumber value={round(occupant.bodyTempF, 0)} />
          &deg;F
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const BodyScannerMainAbnormalities = (props) => {
  const { occupant } = props;
  if (
    !(
      occupant.hasBorer
      || occupant.blind
      || occupant.colourblind
      || occupant.nearsighted
      || occupant.hasVirus
    )
  ) {
    return (
      <Section title="Abnormalities">
        <Box color="label">No abnormalities found.</Box>
      </Section>
    );
  }

  return (
    <Section title="Abnormalities">
      {abnormalities.map((a, i) => {
        if (occupant[a[0]]) {
          return (
            <Box key={a[2]} color={a[1]} bold={a[1] === 'bad'}>
              {a[2]}
            </Box>
          );
        }
      })}
    </Section>
  );
};

const BodyScannerMainDamage = (props) => {
  const { occupant } = props;
  return (
    <Section title="Damage">
      <Table>
        {mapTwoByTwo(damages, (d1, d2, i) => (
          <Fragment>
            <Table.Row color="label">
              <Table.Cell>{d1[0]}:</Table.Cell>
              <Table.Cell>{!!d2 && d2[0] + ':'}</Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <BodyScannerMainDamageBar
                  value={occupant[d1[1]]}
                  marginBottom={i < damages.length - 2}
                />
              </Table.Cell>
              <Table.Cell>
                {!!d2 && <BodyScannerMainDamageBar value={occupant[d2[1]]} />}
              </Table.Cell>
            </Table.Row>
          </Fragment>
        ))}
      </Table>
    </Section>
  );
};

const BodyScannerMainDamageBar = (props) => {
  return (
    <ProgressBar
      min="0"
      max="100"
      value={props.value / 100}
      mt="0.5rem"
      mb={!!props.marginBottom && '0.5rem'}
      ranges={damageRange}
    >
      {round(props.value, 0)}
    </ProgressBar>
  );
};

const BodyScannerMainOrgansExternal = (props) => {
  if (props.organs.length === 0) {
    return (
      <Section title="External Organs">
        <Box color="label">N/A</Box>
      </Section>
    );
  }

  return (
    <Section title="External Organs">
      <Table>
        <Table.Row header>
          <Table.Cell>Name</Table.Cell>
          <Table.Cell textAlign="center">Damage</Table.Cell>
          <Table.Cell textAlign="right">Additional Information</Table.Cell>
        </Table.Row>
        {props.organs.map((o, i) => (
          <Table.Row key={i} textTransform="capitalize">
            <Table.Cell
              color={
                ((!!o.status.dead
                  || !!o.internalBleeding
                  || !!o.stump)
                  && 'bad')
                || ((!!o.lungRuptured
                  || !!o.status.broken
                  || !!o.open
                  || !!o.germ_level
                  || !!o.impant_len)
                  && 'average')
                || (!!o.status.robotic && 'label')
              }
              width="33%"
            >
              {o.name}
            </Table.Cell>
            <Table.Cell textAlign="center" q>
              <ProgressBar
                min="0"
                max={o.maxHealth}
                mt={i > 0 && '0.5rem'}
                value={o.totalLoss / o.maxHealth}
                ranges={damageRange}
              >
                <Box inline
                  style={{
                    float: 'left',
                  }}>
                  {!!o.bruteLoss && (
                    <Box inline position="relative">
                      <Icon name="bone" />
                      {round(o.bruteLoss, 0)}&nbsp;
                      <Tooltip position="top" content="Brute damage" />
                    </Box>
                  )}
                  {!!o.fireLoss && (
                    <Box inline position="relative">
                      <Icon name="fire" />
                      {round(o.fireLoss, 0)}
                      <Tooltip position="top" content="Burn damage" />
                    </Box>
                  )}
                </Box>
                <Box inline>{round(o.totalLoss, 0)}</Box>
              </ProgressBar>
            </Table.Cell>
            <Table.Cell
              textAlign="right"
              verticalAlign="top"
              width="33%"
              pt={i > 0 && 'calc(0.5rem + 2px)'}
            >
              <Box inline>
                <Box color="bad" bold>
                  {reduceOrganStatus([
                    !!o.internalBleeding && 'Internal bleeding',
                    !!o.status.dead && 'DEAD',
                  ])}
                </Box>
                <Box color="average">
                  {reduceOrganStatus([
                    !!o.lungRuptured && 'Ruptured lung',
                    !!o.status.broken && o.status.broken,
                    !!o.germ_level && o.germ_level,
                    !!o.open && 'Open incision',
                  ])}
                </Box>
                {o.implant.map((s) => (s.name ? (
                  <Box color="good">
                    {s.name}
                  </Box>
                ) : (
                  <Box color="average">
                    Unknown body present
                  </Box>
                )))}
                {reduceOrganStatus([
                  !!o.status.splinted && <Box color="good">Splinted</Box>,
                  !!o.status.robotic && <Box color="label">Robotic</Box>,
                ])}
              </Box>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const BodyScannerMainOrgansInternal = (props) => {
  if (props.organs.length === 0) {
    return (
      <Section title="Internal Organs">
        <Box color="label">N/A</Box>
      </Section>
    );
  }

  return (
    <Section title="Internal Organs">
      <Table>
        <Table.Row header>
          <Table.Cell>Name</Table.Cell>
          <Table.Cell textAlign="center">Damage</Table.Cell>
          <Table.Cell textAlign="right">Additional Information</Table.Cell>
        </Table.Row>
        {props.organs.map((o, i) => (
          <Table.Row key={i} textTransform="capitalize">
            <Table.Cell
              color={
                ((!!o.dead || !!o.broken) && 'bad')
                || (!!o.robotic && 'label')
                || ((!!o.germ_level || !!o.bruised) && 'average')
              }
              width="33%"
            >
              {o.name}
            </Table.Cell>
            <Table.Cell textAlign="center">
              <ProgressBar
                min="0"
                max={o.maxHealth}
                value={o.damage / o.maxHealth}
                mt={i > 0 && '0.5rem'}
                ranges={damageRange}
              >
                {round(o.damage, 0)}
              </ProgressBar>
            </Table.Cell>
            <Table.Cell
              textAlign="right"
              verticalAlign="top"
              width="33%"
              pt={i > 0 && 'calc(0.5rem + 2px)'}
            >
              <Box inline>
                <Box color="average">
                  {reduceOrganStatus([!!o.germ_level && o.germ_level])}
                </Box>
                {reduceOrganStatus([
                  !!o.robotic && <Box color="label">Robotic</Box>,
                  !!o.assisted && <Box color="label">Assisted</Box>,
                  !!o.dead && (
                    <Box color="bad" bold>
                      DEAD
                    </Box>
                  ),
                ])}
              </Box>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const BodyScannerEmpty = () => {
  return (
    <Section fill textAlign="center">
      <Flex height="100%">
        <Flex.Item grow="1" align="center" color="label">
          <Icon name="user-slash" mb="0.5rem" size="5" />
          <br />
          No occupant detected.
        </Flex.Item>
      </Flex>
    </Section>
  );
};
