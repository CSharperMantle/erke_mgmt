import ExpandMoreIcon from "@mui/icons-material/ExpandMore"
import Accordion from "@mui/material/Accordion"
import AccordionDetails from "@mui/material/AccordionDetails"
import Typography from "@mui/material/Typography"
import { useContext } from "react"

import { LoginState, LoginStateContext } from "../state"
import GrayAccordionSummary from "./GrayAccordionSummary"

const StudentAccordion = () => {
  const ctx = useContext(LoginStateContext)

  return (
    <Accordion
      disabled={
        ![LoginState.AsStudent, LoginState.AsAdmin].includes(ctx.loginState)
      }
    >
      <GrayAccordionSummary
        expandIcon={<ExpandMoreIcon />}
        aria-controls="student-panel-content"
        id="student-panel-header"
      >
        <Typography component="span">学生端</Typography>
      </GrayAccordionSummary>
      <AccordionDetails>
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse
        malesuada lacus ex, sit amet blandit leo lobortis eget.
      </AccordionDetails>
    </Accordion>
  )
}

export default StudentAccordion
