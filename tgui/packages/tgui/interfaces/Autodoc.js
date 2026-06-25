import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  Section,
  ProgressBar,
  AnimatedNumber,
} from '../components';
import { CSS_COLORS } from '../constants';
import { Window } from '../layouts';

export const Autodoc = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    medical_access,
    operating,
    blood_beaker = {},
    antibiotic_beaker = {},
    anesthetic_tank,
    chosen_surgeries = [],
    operations = [],
    chosen_zone,
  } = data;

  const chosen_operations = chosen_surgeries.filter(
    (surgery) => surgery.target_zone === chosen_zone
  );
  const available_operations = operations.reduce((ops, operation) => {
    if (operation.target_zone !== chosen_zone) return ops;
    ops.push({
      target_zone: operation.target_zone,
      name: operation.name,
      type: operation.type,
      selected: chosen_operations.some(
        (op) => op.surgery_type === operation.type
      ),
    });
    return ops;
  }, []);

  return (
    <Window resizable>
      <Window.Content fitted scrollable className="Layout__content--flexColumn">
        <Box className="Background">
          <Box className="Header">
            <div className="Title">
              <Box className="HeaderLogo">
                <Icon name="asterisk" className="HeaderIcon" />
              </Box>
              <span className="TitleText">WayMed автодок</span>
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
              <span className="Contents_Title">Расходные материалы</span>
              <Box className="ContentsItem">
                <span className="Beaker_Title">Кровь для работы:</span>
                {!blood_beaker ? (
                  <Button
                    className="EmptyBeaker"
                    disabled={!medical_access}
                    content="свободный слот"
                    onClick={() => act('put_blood_beaker')}
                  />
                ) : (
                  <Box className="Beaker">
                    <Button
                      className="SubButton"
                      disabled={!medical_access}
                      content={blood_beaker.name ? blood_beaker.name : 'пусто'}
                      onClick={() => act('eject_blood_beaker')}
                    />
                    <ProgressBar
                      value={blood_beaker.amount / 100}
                      ranges={{
                        good: [0.7, Infinity],
                        average: [0.3, 0.7],
                        bad: [0, 0.3],
                      }}>
                      <AnimatedNumber
                        value={Math.round(blood_beaker.amount) + '%'}
                      />
                    </ProgressBar>
                  </Box>
                )}
              </Box>
              <Box className="ContentsItem">
                <span className="Beaker_Title">Послеоперационная смесь:</span>
                {!antibiotic_beaker ? (
                  <Button
                    className="EmptyBeaker"
                    disabled={!medical_access}
                    content="свободный слот"
                    onClick={() => act('put_antibiotic_beaker')}
                  />
                ) : (
                  <Box className="Beaker">
                    <Button
                      className="SubButton"
                      disabled={!medical_access}
                      content={
                        antibiotic_beaker.name
                          ? antibiotic_beaker.name
                          : 'пусто'
                      }
                      onClick={() => act('eject_antibiotic_beaker')}
                    />
                    <ProgressBar
                      value={antibiotic_beaker.amount / 100}
                      ranges={{
                        good: [0.7, Infinity],
                        average: [0.3, 0.7],
                        bad: [0, 0.3],
                      }}>
                      <AnimatedNumber
                        value={Math.round(antibiotic_beaker.amount) + '%'}
                      />
                    </ProgressBar>
                  </Box>
                )}
              </Box>
              <Box className="ContentsItem">
                <span className="Beaker_Title">Баллон для анастезии:</span>
                {!anesthetic_tank ? (
                  <Button
                    className="EmptyBeaker"
                    disabled={!medical_access}
                    content="свободный слот"
                    onClick={() => act('put_tank')}
                  />
                ) : (
                  <Button
                    className="TankButton"
                    disabled={!medical_access}
                    content={anesthetic_tank}
                    onClick={() => act('eject_tank')}
                  />
                )}
              </Box>
              <Button
                className="FinishButton"
                disabled={operating}
                content="Начать операцию"
                onClick={() => act('operate')}
              />
            </Box>
            <Box className="Contents_Part">
              <span className="Contents_Title">Область операции</span>
              <HumanDoll />
            </Box>
            <Box className="Contents_Part">
              <span className="Contents_Title">Возможные процедуры</span>
              <Procedures operations={available_operations} />
            </Box>
          </Box>
        </Box>
      </Window.Content>
    </Window>
  );
};

const Procedures = (props, context) => {
  const { act, data } = useBackend(context);
  const { operating } = data;
  const { operations } = props;
  return (
    <Box className="Operations">
      {operations.map((operation, index) => (
        <Button
          key={index}
          className="OperationButton"
          selected={operation.selected ? 1 : 0}
          disabled={operating}
          content={operation.name}
          onClick={() =>
            act('add_operation', {
              surgery_zone: operation.target_zone,
              surgery_type: operation.type,
            })
          }
        />
      ))}
    </Box>
  );
};

const HumanDoll = (props, context) => {
  return (
    <Box className="SurgeryDoll">
      <svg width="100%" height="100%" viewBox="0 0 89 153" fill="none">
        <path
          d="M39.125 151.5V103.286L44.5 108.643L49.875 103.286V151.5H76.75V146.143L71.375 140.786H66V65.7857L71.375 60.4286L76.75 71.1429V76.5L71.375 81.8571V92.5714L76.75 97.9286H82.125L87.5 92.5714V65.7857L82.125 55.0714L66 39H60.625L55.25 33.6429L66 22.9286V17.5714L49.875 1.5H39.125L23 17.5714V22.9286L33.75 33.6429L28.375 39H23L6.875 55.0714L1.5 65.7857V92.5714L6.875 97.9286H12.25L17.625 92.5714V81.8571L12.25 76.5V71.1429L17.625 60.4286L23 65.7857V140.786H17.625L12.25 146.143V151.5H39.125Z"
          stroke="#5ca928"
          stroke-width="0.25vw"
          stroke-linejoin="bevel"
        />
      </svg>
      <ButtonSurgeryPart
        this_zone="head"
        width="11vw"
        height="9vw"
        left="6vw"
        top="1vw"
      />
      <ButtonSurgeryPart
        this_zone="chest"
        width="11vw"
        height="11vw"
        left="6vw"
        top="9.5vw"
      />
      <ButtonSurgeryPart
        this_zone="groin"
        width="11vw"
        height="5.5vw"
        left="6vw"
        top="20vw"
      />
      <ButtonSurgeryPart
        this_zone="r_arm"
        width="5vw"
        height="15vw"
        left="1.5vw"
        top="9.5vw"
      />
      <ButtonSurgeryPart
        this_zone="l_arm"
        width="5vw"
        height="15vw"
        left="16.5vw"
        top="9.5vw"
      />
      <ButtonSurgeryPart
        this_zone="r_leg"
        width="5vw"
        height="10.5vw"
        left="6vw"
        top="25vw"
      />
      <ButtonSurgeryPart
        this_zone="l_leg"
        width="5vw"
        height="10.5vw"
        left="12vw"
        top="25vw"
      />
      <Box className="DollLetter" position="absolute" bottom="1vw" left="1vw">
        R
      </Box>
      <Box className="DollLetter" position="absolute" bottom="1vw" right="1vw">
        L
      </Box>
    </Box>
  );
};

const ButtonSurgeryPart = (props, context) => {
  const { act, data } = useBackend(context);
  const { chosen_surgeries, chosen_zone } = data;
  const { this_zone, width, height, left, top } = props;

  let amount = chosen_surgeries.filter(
    (surgery) => surgery.target_zone === this_zone
  ).length;

  return (
    <Button
      className="SurgeryPart"
      width={width}
      height={height}
      position="absolute"
      left={left}
      top={top}
      selected={chosen_zone === this_zone ? 1 : 0}
      onClick={() => act('choose_zone', { zone: this_zone })}
      content={amount ? amount : ''}
    />
  );
};
