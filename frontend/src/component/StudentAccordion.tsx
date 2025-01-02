import { createRef, useContext, useState } from "react"

import ExpandMoreIcon from "@mui/icons-material/ExpandMore"
import Paper from "@mui/material/Paper"
import Accordion from "@mui/material/Accordion"
import AccordionDetails from "@mui/material/AccordionDetails"
import Typography from "@mui/material/Typography"
import Stack from "@mui/material/Stack"
import Grid2 from "@mui/material/Grid2"
import ToggleButtonGroup from "@mui/material/ToggleButtonGroup"
import ToggleButton from "@mui/material/ToggleButton"
import TextField from "@mui/material/TextField"
import Container from "@mui/material/Container"
import Backdrop from "@mui/material/Backdrop"
import CircularProgress from "@mui/material/CircularProgress"
import { useSnackbar } from "notistack"

import { LoginState, LoginStateContext } from "../state"
import GrayAccordionSummary from "./GrayAccordionSummary"
import invokeCheckIn from "../api/student/checkIn"
import invokeCheckOut from "../api/student/checkOut"
import Divider from "@mui/material/Divider"

const CheckInOut = () => {
  const ctx = useContext(LoginStateContext)

  const { enqueueSnackbar } = useSnackbar()

  const [checkInOut, setCheckInOut] = useState<string | null>(null)
  const [codeValue, setCodeValue] = useState("")
  const [loading, setLoading] = useState(false)

  return (
    <>
      <Grid2 container spacing={2} columns={6}>
        <Grid2 size={{ xs: 6, sm: 2 }}>
          <Container>
            <ToggleButtonGroup
              color="primary"
              value={checkInOut}
              fullWidth
              exclusive
              onChange={(_, newVal) => setCheckInOut(newVal)}
            >
              <ToggleButton value="check_in">签到</ToggleButton>
              <ToggleButton value="check_out">签退</ToggleButton>
            </ToggleButtonGroup>
          </Container>
        </Grid2>
        <Grid2 size={{ xs: 6, sm: 4 }}>
          <TextField
            id="student-panel-check-in-out-input"
            label="密令"
            variant="standard"
            fullWidth
            type="text"
            value={codeValue}
            disabled={checkInOut === null}
            slotProps={{
              htmlInput: {
                pattern: "^[0-9]*$",
              },
            }}
            error={codeValue.match(/^[0-9]*$/) === null}
            onChange={async (e) => {
              setCodeValue(e.target.value)
              if (e.target.value.length >= 8 && checkInOut !== null) {
                setLoading(true)
                try {
                  if (checkInOut === "check_in") {
                    await invokeCheckIn({
                      data: {
                        student_id: ctx.username ?? "",
                        code: e.target.value,
                      },
                    })
                  } else {
                    await invokeCheckOut({
                      data: {
                        student_id: ctx.username ?? "",
                        code: e.target.value,
                      },
                    })
                  }
                } catch (ex) {
                  const ex_ = ex as Error
                  enqueueSnackbar(ex_.message, { variant: "error" })
                  return
                } finally {
                  setLoading(false)
                  setCodeValue("")
                }
                enqueueSnackbar("操作成功", { variant: "success" })
              }
            }}
          />
        </Grid2>
      </Grid2>
      <Backdrop
        sx={(theme) => ({ color: "#fff", zIndex: theme.zIndex.drawer + 1 })}
        open={loading}
      >
        <CircularProgress color="inherit" />
      </Backdrop>
    </>
  )
}

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
        <Stack direction="column" spacing={2} sx={{ pt: 2, pb: 2 }}>
          <CheckInOut />
          <Divider variant="fullWidth" />
        </Stack>
      </AccordionDetails>
    </Accordion>
  )
}

export default StudentAccordion
