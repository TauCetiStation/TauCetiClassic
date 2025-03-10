import { Fragment } from 'inferno';
import { useBackend } from "../backend";
import { AnimatedNumber, Box, Button, Flex, Icon, LabeledList, ProgressBar, Section } from "../components";
import { Window } from "../layouts";

const damageTypes = [
  {
    label: "Асфиксия",
    type: "oxyLoss",
  },
  {
    label: "Интоксикация",
    type: "toxLoss",
  },
  {
    label: "Механические",
    type: "bruteLoss",
  },
  {
    label: "Термические",
    type: "fireLoss",
  },
  {
    label: "Генетические",
    type: "cloneLoss",
  },
];

const statNames = [
  ["good", "В сознании"],
  ["average", "Без сознания"],
  ["bad", "Мёртв"],
];

export const Cryo = (props, context) => {
  return (
    <Window
      width={400}
      height={425}>
      <Window.Content className="Layout__content--flexColumn">
        <CryoContent />
      </Window.Content>
    </Window>
  );
};

const CryoContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    isOperating,
    hasOccupant,
    occupant = [],
    cellTemperature,
    cellTemperatureStatus,
    isBeakerLoaded,
    isOpen,
    hasAir,
  } = data;
  return (
    <Fragment>
      <Section
        title="Пациент"
        flexGrow="1"
        buttons={(
          <Button
            icon={isOpen ? "toggle-off" : "toggle-on"}
            onClick={() => act(isOpen ? 'close' : 'open')}
            selected={!isOpen}>
            {isOpen ? "Открыто" : "Закрыто"}
          </Button>
        )}>
        {hasOccupant ? (
          <LabeledList>
            <LabeledList.Item label="Пациент">
              {occupant.name || "Неизвестно"}
            </LabeledList.Item>
            <LabeledList.Item label="Здоровье">
              <ProgressBar
                min={occupant.health}
                max={occupant.maxHealth}
                value={occupant.health / occupant.maxHealth}
                color={occupant.health > 0 ? 'good' : 'average'}>
                <AnimatedNumber
                  value={Math.round(occupant.health)} />
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item
              label="Состояние"
              color={statNames[occupant.stat][0]}>
              {statNames[occupant.stat][1]}
            </LabeledList.Item>
            <LabeledList.Item label="Температура">
              <AnimatedNumber
                value={Math.round(occupant.bodyTemperature)} />
              {' K'}
            </LabeledList.Item>
            <LabeledList.Divider />
            {(damageTypes.map(damageType => (
              <LabeledList.Item
                key={damageType.id}
                label={damageType.label}>
                <ProgressBar
                  value={occupant[damageType.type]/100}
                  ranges={{ bad: [0.25, Infinity] }}>
                  <AnimatedNumber
                    value={Math.round(occupant[damageType.type])} />
                </ProgressBar>
              </LabeledList.Item>
            )))}
          </LabeledList>
        ) : (
          <Flex height="100%" textAlign="center">
            <Flex.Item grow="1" align="center" color="label">
              <Icon
                name="user-slash"
                mb="0.5rem"
                size="5"
              /><br />
              Пациент не обнаружен.
            </Flex.Item>
          </Flex>
        )}
      </Section>
      <Section
        title="Капсула"
        buttons={(
          <Button
            icon="eject"
            onClick={() => act('ejectBeaker')}
            disabled={!isBeakerLoaded}>
            Извлечь сосуд
          </Button>
        )}>
        <LabeledList>
          <LabeledList.Item label="Питание">
            <Button
              icon="power-off"
              onClick={() => act(isOperating ? 'switchOff' : 'switchOn')}
              selected={isOperating}
              disabled={isOpen || !hasAir}>
              {isOperating ? "Вкл" : "Выкл"}
            </Button>
          </LabeledList.Item>
          {hasAir ? (
            <LabeledList.Item label="Температура воздуха" color={cellTemperatureStatus}>
              <AnimatedNumber value={cellTemperature} /> K
            </LabeledList.Item>
          ) : (
            <LabeledList.Item label="Состояние воздуха" color="bad">
              Нет воздуха
            </LabeledList.Item>)}
          <LabeledList.Item label="Сосуд">
            <CryoBeaker />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};

const CryoBeaker = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    isBeakerLoaded,
    beakerVolume,
  } = data;
  if (isBeakerLoaded) {
    return (
      <Box color={!beakerVolume && "bad"}>
        {beakerVolume ? (
          <AnimatedNumber
            value={beakerVolume}
            format={v => Math.round(v) + " юнитов осталось"}
          />
        ) : "Сосуд пуст"}
      </Box>
    );
  } else {
    return (
      <Box color="average">
        Отсутствует
      </Box>
    );
  }
};

