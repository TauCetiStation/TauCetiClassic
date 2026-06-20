import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  Section,
  ProgressBar,
  AnimatedNumber,
  Slider,
} from '../components';
import { Window } from '../layouts';

export const Sleeper = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    occupied,
    insurance_type,
    medical_access,
    dialyzing,
    dialysis_report = [],
    freezing,
    freezing_time,
    dialysis_beaker,
    cryo_beaker,
    regular_beakers = {},
    premium_beakers = {},
  } = data;

  return (
    <Window resizable>
      <Window.Content fitted scrollable className="Layout__content--flexColumn">
        {occupied ? (
          <Box className="Background">
            <Box className="Header">
              <div className="Title">
                <Box className="HeaderLogo">
                  <Icon name="asterisk" className="HeaderIcon" />
                </Box>
                <span className="TitleText">WayMed мед.капсула</span>
              </div>
              <div className="Menu">
                <Button
                  className="Header_Button"
                  icon="sign-out"
                  content="открыть"
                  onClick={() => act('open')}
                />
                <Button
                  className="Header_Button"
                  icon={medical_access ? 'lock' : 'unlock'}
                  content={medical_access ? 'заблок.' : 'разблок.'}
                  onClick={() => act('access')}
                />
              </div>
            </Box>
            <Box className="Contents">
              <Box className="Contents_Part">
                <Box className="Contents_Half">
                  <span className="Contents_Title">
                    Стандартный страховой план
                  </span>
                  <Beakers beakers={regular_beakers} type={'regular'} />
                </Box>
                <Box className="Contents_Half">
                  <span className="Contents_Title">Гемодиализ:</span>
                  {!dialysis_beaker ? (
                    <Button
                      className="EmptyBeaker"
                      disabled={!medical_access}
                      content="пусто"
                      onClick={() => act('put_dialyzing_beaker')}
                    />
                  ) : (
                    <Box className="Beaker">
                      <Button
                        className="SubButton"
                        disabled={!medical_access}
                        content={
                          dialysis_beaker.name ? dialysis_beaker.name : 'пусто'
                        }
                        onClick={() => act('eject_dialyzing_beaker')}
                      />
                      <ProgressBar
                        value={dialysis_beaker.amount / 100}
                        ranges={{
                          good: [0.7, Infinity],
                          average: [0.3, 0.7],
                          bad: [0, 0.3],
                        }}>
                        <AnimatedNumber
                          value={Math.round(dialysis_beaker.amount) + '%'}
                        />
                      </ProgressBar>
                      <Button
                        className="ConfigButton"
                        selected={dialyzing ? 1 : 0}
                        content={dialyzing ? 'откл.' : 'вкл.'}
                        onClick={() => act('dialyze')}
                      />
                    </Box>
                  )}
                  <Box className="ConfigBox">
                    <span className="ConfigText">
                      {dialysis_report
                        ? 'Обнаружены следы: ' + dialysis_report.join(', ')
                        : 'Следы не обнаружены'}
                    </span>
                  </Box>
                </Box>
              </Box>
              <Box className="Contents_Part">
                <Box className="Contents_Half">
                  <span className="Contents_Title">
                    Премиальный страховой план
                  </span>
                  <Beakers beakers={premium_beakers} type={'premium'} />
                </Box>
                <Box className="Contents_Half">
                  <span className="Contents_Title">Заморозка:</span>
                  {!cryo_beaker ? (
                    <Button
                      className="EmptyBeaker"
                      disabled={!medical_access}
                      content="пусто"
                      onClick={() => act('put_cryo_beaker')}
                    />
                  ) : (
                    <Box className="Beaker">
                      <Button
                        className="SubButton"
                        disabled={!medical_access}
                        content={cryo_beaker.name ? cryo_beaker.name : 'пусто'}
                        onClick={() => act('eject_cryo_beaker')}
                      />
                      <ProgressBar
                        value={cryo_beaker.amount / 100}
                        ranges={{
                          good: [0.7, Infinity],
                          average: [0.3, 0.7],
                          bad: [0, 0.3],
                        }}>
                        <AnimatedNumber
                          value={Math.round(cryo_beaker.amount) + '%'}
                        />
                      </ProgressBar>
                      <Button
                        className="ConfigButton"
                        selected={freezing ? 1 : 0}
                        content={freezing ? 'откл.' : 'вкл.'}
                        onClick={() => act('freeze')}
                      />
                    </Box>
                  )}
                  <Box className="ConfigBox">
                    <span className="ConfigText">
                      Статус: {freezing ? 'Заморожен' : 'Разморожен'}
                    </span>
                    <span className="ConfigText">
                      Длительность: {freezing_time}
                    </span>
                  </Box>
                </Box>
              </Box>
            </Box>
          </Box>
        ) : (
          <Section fill textAlign="center">
            <Flex height="100%">
              <Flex.Item grow="1" align="center" color="label">
                <Icon name="user-slash" mb="0.5rem" size="5" />
                <br />
                Пациент не обнаружен.
              </Flex.Item>
            </Flex>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

const Beakers = (props, context) => {
  const { beakers = {}, type } = props;
  return (
    <Box className="Contents_Beakers">
      {beakers.map((beaker, index) =>
        beaker ? (
          <Beaker key={index} beaker={beaker} type={type} />
        ) : (
          <BeakerNone key={index} type={type} />
        )
      )}
    </Box>
  );
};

const Beaker = (props, context) => {
  const { act, data } = useBackend(context);
  const { insurance_type, medical_access } = data;
  const { beaker = {}, type } = props;
  const { id, name, amount, injecting_amount } = beaker;
  return (
    <Box className="Beaker">
      <Button
        className="SubButton"
        disabled={!medical_access}
        content={name ? name : 'пусто'}
        onClick={() =>
          act('eject_beaker', {
            beaker_type: type,
            beaker_id: id,
          })
        }
      />
      <ProgressBar
        value={amount / 100}
        ranges={{
          good: [0.7, Infinity],
          average: [0.3, 0.7],
          bad: [0, 0.3],
        }}>
        <AnimatedNumber value={Math.round(amount) + '%'} />
      </ProgressBar>
      <Slider
        value={injecting_amount}
        format={(value) => value + ' куб/с'}
        fillValue={injecting_amount}
        minValue={0}
        maxValue={5}
        step={1}
        stepPixelSize={20}
        color={'bad'}
        onDrag={(e, value) =>
          act('change_injection_amount', {
            beaker_type: type,
            beaker_id: id,
            new_injection_amount: value,
          })
        }
      />
    </Box>
  );
};

const BeakerNone = (props, context) => {
  const { act, data } = useBackend(context);
  const { type } = props;
  const { insurance_type, medical_access } = data;
  return (
    <Button
      className="EmptyBeaker"
      disabled={!medical_access}
      content="свободный слот"
      onClick={() =>
        act('put_beaker', {
          beaker_type: type,
        })
      }
    />
  );
};
