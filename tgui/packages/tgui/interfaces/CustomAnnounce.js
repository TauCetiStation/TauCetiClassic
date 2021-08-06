import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Section, Box, Button, Flex, NumberInput, LabeledList } from "../components";

export const CustomAnnounce = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      width={600}
      height={500}>
      <Flex
        height="100%"
        direction="column">
        <Flex.Item
          grow={1}
          position="relative">
          <Window.Content>
            <Section title="Preview" fill>
              <Box bold fontSize="24px">
                {data.title === null ? "<NO TITLE>" : data.title}
              </Box>
              <Box fontSize="18px">
                {data.subtitle === null ? "<NO SUBTITLE>" : data.subtitle}
              </Box>
              <Box mt={2}>
                {data.message === null ? "<NO MESSAGE>" : data.message}
              </Box>
              <Box italic>
                {(data.announcer !== null) && "-"} {data.announcer}
              </Box>
              <Box mt={2}>
                Current sound is &quot;{data.sound}&quot;
              </Box>
            </Section>
          </Window.Content>
        </Flex.Item>
        <Flex.Item mx={1} mb={1}>
          <Section title="Settings">
            <LabeledList>
              <LabeledList.Item label="Content">
                <Button
                  content="Title"
                  icon="heading"
                  onClick={() => act('title')}
                />
                <Button ml={1}
                  content="Subtitle"
                  icon="paragraph"
                  onClick={() => act('subtitle')}
                />
                <Button ml={1}
                  content="Message"
                  icon="pencil-alt"
                  onClick={() => act('message')}
                />
                <Button ml={1} mr={2}
                  content="Announcer"
                  icon="bullhorn"
                  onClick={() => act('announcer')}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Output">
                <Button
                  content="Chat"
                  icon="comments"
                  selected={data.flags.text}
                  onClick={() => act('flag_text')}
                />
                <Button mx={1}
                  content="Sound"
                  icon="volume-up"
                  selected={data.flags.sound}
                  onClick={() => act('flag_sound')}
                />
                <Button
                  content="Consoles"
                  icon="sticky-note"
                  selected={data.flags.comms}
                  onClick={() => act('flag_comms')}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Sound">
                <Button
                  content="Existing"
                  icon="list"
                  disabled={!data.rights.funevent}
                  onClick={() => act('sound_select')}
                />
                <Button ml={1}
                  content="Upload"
                  icon="file-upload"
                  disabled={!(data.rights.sound && data.rights.funevent)}
                  onClick={() => act('sound_upload')}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Volume">
                <NumberInput animated ml={1}
                  value={parseInt(data.volume, 10)}
                  disabled={!(data.rights.sound && data.rights.funevent)}
                  width="60px"
                  step={1}
                  unit="%"
                  minValue={0}
                  maxValue={200}
                  onChange={(e, value) => act('volume', {
                    volume: value,
                  })}
                />
                <Button ml={1}
                  content="Test"
                  icon="user"
                  onClick={() => act('test', {
                    source: "admin",
                  })}
                />
                <Button ml={1}
                  content="Sample"
                  icon="closed-captioning"
                  onClick={() => act('test', {
                    source: "sample",
                  })}
                />
              </LabeledList.Item>
            </LabeledList>
            <Box mt={2} mb={1}>
              <Button
                content="Select preset"
                icon="archive"
                disabled={!data.rights.funevent}
                onClick={() => act('preset_select')}
              />
            </Box>
            <Box>
              <Button
                content="Make an announcement"
                onClick={() => act('announce')}
              />
            </Box>
          </Section>
        </Flex.Item>
      </Flex>
    </Window>
  );
};
