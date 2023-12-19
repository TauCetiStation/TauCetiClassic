import { useBackend } from '../backend';
import { Blink, Box, Button, Flex, Input, LabeledList, Section, Table,  ProgramComponent, ProcessProgrammComponent, GetTypeProgramComponent} from '../components';
import { TableCell, TableRow } from '../components/Table';
import { Window } from '../layouts';

type Data = {
  selected_component?: ProgramComponent;
  saved_components?: Map<string, ProgramComponent>
  tree_selected_component?: ProgramComponent;
  console_output?: [string];
};

export const Terminal = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.

  const datatype : Data = data

  const TypeProgramComponent = GetTypeProgramComponent(datatype.selected_component?.id_component)

  let saved_components = []
  // let map : Map<string, ProgramComponent> = data.saved_components as Map<string, ProgramComponent>

  // map.forEach((value, key) => {
  //   saved_components.push(value)
  // });

  return (
    <Window resizable>
      <Window.Content>

        <Section title="Terminal Output" width="100%" height="100%">
          <Flex direction="column">

            <Flex direction="row" height="50%">

              <Section title="Terminal Output" width="100%" height="100%">
                <Flex.Item fill={true} grow={0} backgroundColor={"#000622"} scrollable={true} overflowY="scroll">
                  <Table>
                    {datatype.console_output.map((element, i) => (
                      <TableRow>{element}</TableRow>
                    ))}
                    <TableRow><Blink>_</Blink></TableRow>
                  </Table>
                </Flex.Item>

                <Flex.Item fill={false} grow={0} backgroundColor={"#000622"} scrollable={true} overflowY="scroll" overflowX="hidden" mt={2}>
                  <Input backgroundColor={"#000622"} width="100%" fontSize={1.5} onChange={() => act('clear_console')}></Input>
                </Flex.Item>

              </Section>

              <Section title="Selected Program Component" width="50%" height="100%">
                  <Flex.Item fill={true} grow={0} height={10} backgroundColor={"#000622"} scrollable={true} maxHeight={50} overflowY="scroll">
                      <TypeProgramComponent act={act} onlyObject={true} component={data.selected_component}/>
                  </Flex.Item>
              </Section>

            </Flex>

            <Flex direction="row"  height="100%">

              <Section title="Selected Program" height="100%">
                  <Flex.Item fill={true} grow={1} backgroundColor={"#000622"} scrollable={false} overflowY="scroll">
                      <ProcessProgrammComponent component = {data.tree_selected_component} selected_component={data.selected_component} act={act}></ProcessProgrammComponent>
                  </Flex.Item>
              </Section>

              <Section title="Saved Program Components"  width="50%" height="100%">
                <Flex direction="column">
                  <Flex.Item fill={true} grow={1} backgroundColor={"#000622"} scrollable={true} overflowY="scroll">
                      {Object.keys(data.saved_components)?.map((key) => {
                        return(
                          <ProcessProgrammComponent component = {data.saved_components[key]} act={act}></ProcessProgrammComponent>
                        )
                      })}
                  </Flex.Item>
                </Flex>
              </Section>

            </Flex>

          </Flex>
        </Section>

      </Window.Content>
    </Window>
  );
};
