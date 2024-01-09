import { Box } from './Box';

export const SegmentDisplay = props => {
  const {
    display_text,
    display_cells_amount,
    display_height,
    ...rest
  } = props;

  const segment_height = display_height;
  const segment_width = display_height*0.641;
  const segments_count = display_cells_amount;
  const segments_width = segments_count*segment_width;

  const segments = [];

  for (let i = 0; i < segments_count; i++) {
    segments.push("#");
  }

  return (
    <Box width={segments_width+"px"} height={display_height+"px"} overflow="hidden" position="relative" {...rest}>
      <Box width={segments_width+"px"} height={segment_height+"px"} position="absolute" top="0px" textColor="#261f16" fontSize={display_height+"px"} textAlign="right" fontFamily="Gys14Segment" bold={0}> {segments} </Box>
      <Box width={segments_width+"px"} height={segment_height+"px"} position="absolute" top="0px" textColor="#D0330f" fontSize={display_height+"px"} textAlign="right" fontFamily="Gys14Segment" bold={0}> {display_text} </Box>
    </Box>
  );
};
