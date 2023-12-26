import { useBackend } from '../backend';
import { Blink, Box, Button, Flex, Input, LabeledList, Section, Table, ProgramComponent, ProcessProgrammComponent, GetTypeProgramComponent } from '../components';
import { TableCell, TableRow } from '../components/Table';
import { Window } from '../layouts';

type Data = {
  selected_component?: ProgramComponent;
  saved_components?: Map<string, ProgramComponent>
  selected_program?: ProgramComponent;
  console_output?: [string];
  target_component?:ProgramComponent;
};

export const Terminal = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.

  const datatype : Data = data;

  const TypeProgramComponent = GetTypeProgramComponent(datatype.target_component?.id_component);

  return (
    <Window resizable width={500}>
      <Window.Content>
        <Flex direction="column">
          <Flex direction="row">
            <Section title="Selected Program" width="75vw" fill grow={1}>
              <Box height="40vh" backgroundColor={"#000622"} overflowX="scroll" overflowY="scroll">
                <ProcessProgrammComponent
                  component={datatype.selected_program}
                  selected_component={datatype.selected_component}
                  act={act} thisEditProgram
                />
              </Box>
            </Section>
            <Section title="Terminal Output" width="25vw">
              <Box height="35vh" backgroundColor={"#000622"} overflowY="scroll">
                <LabeledList>
                  {datatype.console_output.map((element, i) => (
                    <div key={i}>
                      <LabeledList.Item label="log">
                        {element}
                      </LabeledList.Item>
                    </div>
                  ))}
                  <LabeledList.Item>
                    <Blink>_</Blink>
                  </LabeledList.Item>
                </LabeledList>
              </Box>

              <Flex.Item fill={false} grow={1} backgroundColor={"#000622"} scrollable overflowY="scroll" overflowX="hidden" mt={2}>
                <Input backgroundColor={"#000622"} width="100%" fontSize={1.5} onChange={() => act('clear_console')} />
              </Flex.Item>
            </Section>
          </Flex>
          <Flex direction="row">
            <Section title="Saved Program Components" width="75vw" fill grow={1}>
              <Box height="40vh" backgroundColor={"#000622"} overflowX="scroll" overflowY="scroll">
                <Flex direction="row">
                  {Object.values(datatype.saved_components)?.map((element) => {
                    return (
                      <ProcessProgrammComponent key={element.link_component} component={element} act={act} />
                    );
                  })}
                </Flex>
              </Box>
            </Section>
            <Section title="Target Program Component" width="25vw">
              <Box height="40vh" backgroundColor={"#000622"} overflowX="scroll" overflowY="scroll">
                <TypeProgramComponent act={act} onlyObject component={datatype.target_component} />
              </Box>
            </Section>
          </Flex>
        </Flex>

      </Window.Content>
    </Window>
  );
};
