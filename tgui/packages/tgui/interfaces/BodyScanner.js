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
} from '../components';
import { Window } from '../layouts';

const stats = [
  ['good', 'Стабильное'],
  ['average', 'Критическое'],
  ['bad', 'Мёртв'],
];

const abnormalities = [
  ['hasBorer', 'bad', 'В лобной доле злокачественное новообразование.'],
  ['blind', 'bad', 'Катаракта.'],
  ['hasVirus', 'average', 'В кровотоке вирусный патоген.'],
  ['nearsighted', 'average', 'Смещение сетчатки.'],
];

const damages = [
  ['Асфиксия', 'oxyLoss'],
  ['Мозговые', 'brainLoss'],
  ['Интоксикация', 'toxLoss'],
  ['Облучение', 'radLoss'],
  ['Механические', 'bruteLoss'],
  ['Генетические', 'cloneLoss'],
  ['Термические', 'fireLoss'],
  ['Опьянение', 'drunkenness'],
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
      title="Пациент"
      buttons={
        <Fragment>
          <Button icon="print" onClick={() => act('print_p')}>
            Распечатать отчет
          </Button>
          <Button icon="user-slash" onClick={() => act('ejectify')}>
            Извлечь
          </Button>
        </Fragment>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Имя">{occupant.name}</LabeledList.Item>
        <LabeledList.Item label="Здоровье">
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
        <LabeledList.Item label="Кровь">
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
                {occupant.blood.pulse} уд/мин
              </Box>
              <Box inline>
                {occupant.blood.percent}%
              </Box>
            </ProgressBar>
          ) : (
            <Box color="average">
              Не обнаружена
            </Box>
          )}

        </LabeledList.Item>
        <LabeledList.Item label="Состояние" color={stats[occupant.stat][0]}>
          {stats[occupant.stat][1]}
        </LabeledList.Item>
        <LabeledList.Item label="Температура">
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
      || occupant.nearsighted
      || occupant.hasVirus
    )
  ) {
    return (
      <Section title="Отклонения">
        <Box color="label">Не обнаружено.</Box>
      </Section>
    );
  }

  return (
    <Section title="Отклонения">
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
    <Section title="Повреждения">
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
      <Section title="Внешние органы">
        <Box color="label">Нет сведений</Box>
      </Section>
    );
  }

  return (
    <Section title="Внешние органы">
      <Table>
        <Table.Row header>
          <Table.Cell>Название</Table.Cell>
          <Table.Cell textAlign="center">Повреждения</Table.Cell>
          <Table.Cell textAlign="right">Дополнительные сведения</Table.Cell>
        </Table.Row>
        {props.organs.map((o, i) => (
          <Table.Row key={i}
            textTransform="capitalize"
            backgroundColor={(i % 2 !== 0) && "rgba(255, 255, 255, 0.05)"}>
            <Table.Cell
              color={
                ((!!o.status.dead
                  || !!o.internalBleeding
                  || !!o.stump
                  || !!o.missing)
                  && 'bad')
                || ((!!o.lungRuptured
                  || !!o.status.broken
                  || !!o.open
                  || !!o.germ_level
                  || !!o.unknown_implant)
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
                    </Box>
                  )}
                  {!!o.fireLoss && (
                    <Box inline position="relative">
                      <Icon name="fire" />
                      {round(o.fireLoss, 0)}
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
                    !!o.internalBleeding && 'Артериальное кровотечение',
                    !!o.status.dead && 'Отказ',
                    !!o.stump && 'Культя',
                    !!o.missing && 'Отсутствует',
                  ])}
                </Box>
                <Box color="average">
                  {reduceOrganStatus([
                    !!o.lungRuptured && 'Разрыв легкого',
                    !!o.status.broken && o.status.broken,
                    !!o.germ_level && o.germ_level,
                    !!o.open && 'Открытый разрез',
                  ])}
                </Box>
                {o.implant?.map((s) => (s.name ? (
                  <Box color="good">
                    {s.name}
                  </Box>
                ) : (
                  <Box color="average">
                    Инородный объект
                  </Box>
                )))}
                {reduceOrganStatus([
                  !!o.status.splinted && <Box color="good">Наложена шина</Box>,
                  !!o.status.robotic && <Box color="label">Протез</Box>,
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
      <Section title="Внутренние органы">
        <Box color="label">Нет сведений</Box>
      </Section>
    );
  }

  return (
    <Section title="Внутренние органы">
      <Table>
        <Table.Row header>
          <Table.Cell>Название</Table.Cell>
          <Table.Cell textAlign="center">Повреждения</Table.Cell>
          <Table.Cell textAlign="right">Дополнительные сведения</Table.Cell>
        </Table.Row>
        {props.organs.map((o, i) => (
          <Table.Row key={i}
            textTransform="capitalize"
            backgroundColor={(i % 2 !== 0) && "rgba(255, 255, 255, 0.05)"}>
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
                  !!o.robotic && <Box color="label">Протез</Box>,
                  !!o.assisted && <Box color="label">Вспомогательный имплант</Box>,
                  !!o.dead && <Box color="bad" bold>Отказ</Box>,
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
          Пациент не обнаружен.
        </Flex.Item>
      </Flex>
    </Section>
  );
};
