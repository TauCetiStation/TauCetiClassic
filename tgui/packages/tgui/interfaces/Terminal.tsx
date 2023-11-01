import { useBackend } from '../backend';
import { Blink, Box, Button, Flex, Input, LabeledList, Section, Table,  ProgramComponent, ProcessProgrammComponent, GetTypeProgramComponent} from '../components';
import { TableCell, TableRow } from '../components/Table';
import { Window } from '../layouts';

type Data = {
  selected_component?: ProgramComponent;
  tree_selected_component?: ProgramComponent;
  console_output?: [string];
};

export const Terminal = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.

  const datatype : Data = data

  const TypeProgramComponent = GetTypeProgramComponent(datatype.selected_component?.id_component)

  return (
    <Window resizable>
      <Window.Content>
        <Flex direction="row" width={100}>
          <Flex direction="column" width={60}>
            <Section title="Terminal Output">
              <Section >
                <Flex.Item fill={true} grow={1} backgroundColor={"#000622"} scrollable={true} maxHeight={20} overflowY="scroll">
                  <Table>
                    {datatype.console_output.map((element, i) => (
                      <TableRow>{element}</TableRow>
                    ))}
                    <TableRow><Blink>_</Blink></TableRow>
                  </Table>
                </Flex.Item>
                <Flex.Item fill={false} grow={0} backgroundColor={"#000622"} scrollable={true} maxHeight={20} overflowY="scroll" overflowX="hidden" mt={2}>
                  <Input backgroundColor={"#000622"} width="100%" fontSize={1.5} onChange={() => act('clear_console')}></Input>
                </Flex.Item>
              </Section>
            </Section>
            <Section title="Selected Program">
              <Section >
                <Flex.Item fill={true} grow={1} backgroundColor={"#000622"} scrollable={false} overflowY="scroll">
                    <ProcessProgrammComponent component = {data.tree_selected_component} selected_component={data.selected_component} act={act}></ProcessProgrammComponent>
                </Flex.Item>
              </Section>
            </Section>
          </Flex>
          <Flex direction="column">
            <Section title="Selected Program Component">
              <Section >
                <Flex.Item fill={true} grow={1} backgroundColor={"#000622"} scrollable={true} maxHeight={20} overflowY="scroll">
                    <TypeProgramComponent act={act} onlyObject={true} component={data.selected_component}/>
                </Flex.Item>
              </Section>
            </Section>
          </Flex>
        </Flex>

      </Window.Content>
    </Window>
  );
};
