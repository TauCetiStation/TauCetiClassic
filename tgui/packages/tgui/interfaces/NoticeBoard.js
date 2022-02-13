import { useBackend } from "../backend";
import { Box, Button, Flex, Section } from "../components";
import { Window } from "../layouts";

export const NoticeBoard = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    notices = {},
  } = data;

  return (
    <Window
      width={425}
      height={176}>
      <Window.Content backgroundColor="#704D25">
        {!notices.length ? (
          <Section>
            <Box color="white" align="center">
              The notice board is empty!
            </Box>
          </Section>
        ) : (
          notices.map(notice => (
            <Flex
              key={notice.ref}
              color="black"
              backgroundColor="white"
              style={{ padding: "2px 2px 0 2px" }}
              mb={0.5}>
              <Flex.Item align="center" grow={1}>
                <Box align="center">
                  {notice.name}
                </Box>
              </Flex.Item>
              <Flex.Item>
                {notice.isphoto && (
                  <Button
                    icon="image"
                    content="Look"
                    onClick={() => act("look", { ref: notice.ref })} />
                ) || notice.ispaper && (
                  <>
                    <Button
                      icon="eye"
                      onClick={() => act("read", { ref: notice.ref })}
                    />
                    <Button
                      icon="pen"
                      onClick={() => act("write", { ref: notice.ref })}
                    />
                  </>
                ) || "Unknown Entity"}
                <Button
                  icon="eject"
                  onClick={() => act("remove", { ref: notice.ref })}
                />
              </Flex.Item>
            </Flex>
          )))}
      </Window.Content>
    </Window>
  );
};
