import { colors } from "@mui/material"
import MuiAccordionSummary, {
  AccordionSummaryProps,
} from "@mui/material/AccordionSummary"
import { styled } from "@mui/material/styles"

const GrayAccordionSummary = styled((props: AccordionSummaryProps) => (
  <MuiAccordionSummary {...props} />
))<AccordionSummaryProps>(() => ({
  backgroundColor: colors.grey[200],
}))

export default GrayAccordionSummary
