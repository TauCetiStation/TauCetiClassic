import { useBackend } from '../backend';
import { Button, Section, Flex } from '../components';
import { Window } from '../layouts';

export const OutfitManager = (props, context) => {
  const { act, data } = useBackend(context);
  const { outfits } = data;
  return (
    <Window
      title="Outfit Manager"
      width={300}
      height={300}>
      <Window.Content>
        <Section
          fill
          scrollable
          title="Custom Outfit Manager"
          buttons={
            <>
              <Button
                icon="file-upload"
                tooltip="Load an outfit from a file"
                tooltipPosition="left"
                onClick={() => act("load")} />
              <Button
                icon="copy"
                tooltip="Copy an already existing outfit"
                tooltipPosition="left"
                onClick={() => act("copy")} />
              <Button
                icon="plus"
                tooltip="Create a new outfit"
                tooltipPosition="left"
                onClick={() => act("new")} />
            </>
          }>
          <Flex direction="column">
            {outfits?.map(outfit => (
              <Flex.Item key={outfit.ref}>
                <Flex width="100%">
                  <Flex.Item grow={1} shrink={1}
                    style={{
                      'overflow': 'hidden',
                      'white-space': 'nowrap',
                      'text-overflow': 'ellipsis',
                    }}>
                    <Button
                      fluid
                      style={{
                        'overflow': 'hidden',
                        'white-space': 'nowrap',
                        'text-overflow': 'ellipsis',
                      }}
                      content={outfit.name}
                      onClick={() => act("edit", { outfit: outfit.ref })} />
                  </Flex.Item>
                  <Flex.Item ml={0.5}>
                    <Button
                      icon="save"
                      tooltip="Save this outfit to a file"
                      tooltipPosition="left"
                      onClick={() => act("save", { outfit: outfit.ref })} />
                  </Flex.Item>
                  <Flex.Item ml={0.5}>
                    <Button
                      color="bad"
                      icon="trash-alt"
                      tooltip="Delete this outfit"
                      tooltipPosition="left"
                      onClick={() => act("delete", { outfit: outfit.ref })} />
                  </Flex.Item>
                </Flex>
              </Flex.Item>
            ))}
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};

