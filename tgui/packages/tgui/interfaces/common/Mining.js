import { Fragment } from 'inferno';
import { useBackend } from "../../backend";
import { Box, Button, Input, NoticeBox } from '../../components';

export const MiningUser = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    insertIdText,
  } = props;
  const {
    has_id,
    id,
  } = data;
  return (
    <NoticeBox success={has_id}>
      {has_id ? (
        <Fragment>
          <Box
            display="inline-block"
            verticalAlign="middle"
            style={{
              float: 'left',
            }}>
            Logged in as {id.name}.<br />
            You have {id.points.toLocaleString('en-US')} points.
          </Box>
          <Button
            icon="eject"
            content="Eject ID"
            style={{
              float: 'right',
            }}
            onClick={() => act('logoff')}
          />
          <Box
            style={{
              clear: "both",
            }}
          />
        </Fragment>
      ) : insertIdText}
    </NoticeBox>
  );
};
