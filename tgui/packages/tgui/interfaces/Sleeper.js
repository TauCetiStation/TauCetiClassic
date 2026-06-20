import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  Section
} from '../components';
import { Window } from '../layouts';

export const Sleeper = (props, context) => {
  const { act, data } = useBackend(context);
  const { occupied, insurance_type, medical_access, dialyzing, dialysis_report, freezing, freezing_time, dialysis_beaker, dialysis_fill, cryo_beaker, cryo_fill, regular_beakers, premium_beakers } = data;

  return (
    <Window resizable>
      <Window.Content scrollable className="Layout__content--flexColumn">
        {!occupied ? (
          <Box className="Background">
            <Box className="Header">
              <div className="Title">
                <Box className="HeaderLogo">
                  <Icon name="astrisk" className="HeaderIcon"/>
                </Box>
                <span className="Title">WayMed мед.капсула</span>
              </div>
              <div className="Menu">
                <Button className="Header_Button"
                  icon="sign-out"
                  content="открыть"
                  onClick={() => act('open')}
                />
                <Button className="Header_Button"
                  icon={medical_access ? 'lock' : 'unlock'}
                  content = {medical_access ? 'забл.' : 'разбл.'}
                  onClick={() => act('access')}
                />
              </div>
            </Box>
            <Box className="Contents">
              <Box className="Contents_Part">
                <Box className="Contents_Top">

                </Box>
                <Box className="Contents_Bottom">

                </Box>
              </Box>
              <Box className="Contents_Part">
                <Box className="Contents_Top">

                </Box>
                <Box className="Contents_Bottom">

                </Box>
              </Box>
            </Box>
          </Box>
        ) : (
          <Box>
            <Section fill textAlign="center">
              <Flex height="100%">
                <Flex.Item grow="1" align="center" color="label">
                  <Icon name="user-slash" mb="0.5rem" size="5" />
                  <br />
                  Пациент не обнаружен.
                </Flex.Item>
              </Flex>
            </Section>
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};
