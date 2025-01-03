import { useContext, useState } from "react"

import ExpandMoreIcon from "@mui/icons-material/ExpandMore"
import RefreshIcon from "@mui/icons-material/Refresh"
import Accordion from "@mui/material/Accordion"
import AccordionDetails from "@mui/material/AccordionDetails"
import Backdrop from "@mui/material/Backdrop"
import Box from "@mui/material/Box"
import Button from "@mui/material/Button"
import CircularProgress from "@mui/material/CircularProgress"
import Container from "@mui/material/Container"
import Divider from "@mui/material/Divider"
import FormControlLabel from "@mui/material/FormControlLabel"
import FormGroup from "@mui/material/FormGroup"
import Grid2 from "@mui/material/Grid2"
import Stack from "@mui/material/Stack"
import Switch from "@mui/material/Switch"
import TextField from "@mui/material/TextField"
import Typography from "@mui/material/Typography"
import { DataGrid, GridColDef } from "@mui/x-data-grid"
import { useSnackbar } from "notistack"

import invokeGetRatingAgg, { RatingAgg } from "../api/auditor/getRatingAgg"
import invokePutAudit from "../api/auditor/putAudit"
import { LoginState, LoginStateContext } from "../state"
import GrayAccordionSummary from "./GrayAccordionSummary"

const ActivityDisplay = () => {
  const { enqueueSnackbar } = useSnackbar()

  const [loading, setLoading] = useState(false)
  const [ratingAgg, setRatingAgg] = useState<RatingAgg[]>([])

  const colDefs: GridColDef[] = [
    { field: "activity_id", type: "number", headerName: "活动编号" },
    {
      field: "activity_name",
      type: "string",
      headerName: "活动名称",
      width: 150,
    },
    { field: "rate_cnt", type: "number", headerName: "评分人数" },
    { field: "rate_avg", type: "number", headerName: "平均评分" },
    { field: "rate_max", type: "number", headerName: "最高评分" },
    { field: "rate_min", type: "number", headerName: "最低评分" },
  ]

  return (
    <Box sx={{ width: "100%" }}>
      <Stack direction="row-reverse" spacing={1} sx={{ mb: 1 }}>
        <Button
          size="small"
          variant="outlined"
          onClick={async () => {
            setLoading(true)
            try {
              setRatingAgg((await invokeGetRatingAgg()).data)
            } catch (ex) {
              const ex_ = ex as Error
              enqueueSnackbar(ex_.message, { variant: "error" })
            } finally {
              setLoading(false)
            }
          }}
        >
          <RefreshIcon />
        </Button>
      </Stack>
      <div style={{ display: "flex", flexDirection: "column" }}>
        <DataGrid
          rows={ratingAgg}
          columns={colDefs}
          getRowId={(row) => row.activity_id}
          disableRowSelectionOnClick
        />
      </div>
      <Backdrop
        sx={(theme) => ({ color: "#fff", zIndex: theme.zIndex.drawer + 1 })}
        open={loading}
      >
        <CircularProgress color="inherit" />
      </Backdrop>
    </Box>
  )
}

const Audit = () => {
  const ctx = useContext(LoginStateContext)

  const { enqueueSnackbar } = useSnackbar()

  const [loading, setLoading] = useState(false)
  const [activityId, setActivityId] = useState("")
  const [comment, setComment] = useState("")
  const [passed, setPassed] = useState(false)

  return (
    <>
      <Grid2 container spacing={2} columns={4}>
        <Grid2 size={4}>
          <TextField
            label="活动编号"
            variant="standard"
            required
            fullWidth
            type="number"
            autoComplete="off"
            value={activityId}
            onChange={(e) => setActivityId(e.target.value)}
          />
        </Grid2>
        <Grid2 size={4}>
          <TextField
            label="审核意见"
            variant="standard"
            required
            fullWidth
            type="text"
            multiline
            minRows={4}
            maxRows={10}
            autoComplete="off"
            value={comment}
            onChange={(e) => setComment(e.target.value)}
          />
        </Grid2>
        <Grid2 size={{ xs: 4, sm: 2 }}>
          <Stack direction="column" alignItems="center">
            <FormGroup>
              <FormControlLabel
                control={
                  <Switch
                    checked={passed}
                    onChange={(_, newVal) => setPassed(newVal)}
                  />
                }
                label="同意通过"
              />
            </FormGroup>
          </Stack>
        </Grid2>
        <Grid2 size={{ xs: 4, sm: 2 }}>
          <Container maxWidth="sm">
            <Button
              fullWidth
              variant="contained"
              color="primary"
              type="submit"
              disabled={
                loading ||
                [activityId, comment].some((field) => field.length === 0)
              }
              onClick={async () => {
                setLoading(true)
                try {
                  await invokePutAudit({
                    data: {
                      auditor_id: ctx.username ?? "",
                      activity_id: parseInt(activityId),
                      audit_comment: comment,
                      audit_passed: passed,
                    },
                  })
                  enqueueSnackbar("提交成功", { variant: "success" })
                } catch (ex) {
                  const ex_ = ex as Error
                  enqueueSnackbar(ex_.message, { variant: "error" })
                } finally {
                  setLoading(false)
                }
              }}
            >
              提交
            </Button>
          </Container>
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

const AuditorAccordion = () => {
  const ctx = useContext(LoginStateContext)

  return (
    <Accordion
      disabled={
        ![LoginState.AsAuditor, LoginState.AsAdmin].includes(ctx.loginState)
      }
    >
      <GrayAccordionSummary
        expandIcon={<ExpandMoreIcon />}
        aria-controls="auditor-panel-content"
        id="auditor-panel-header"
      >
        <Typography component="span">审核员端</Typography>
      </GrayAccordionSummary>
      <AccordionDetails>
        <Stack direction="column" spacing={2} sx={{ pt: 2, pb: 2 }}>
          <ActivityDisplay />
          <Divider variant="fullWidth" sx={{ color: "darkgray" }} />
          <Audit />
        </Stack>
      </AccordionDetails>
    </Accordion>
  )
}

export default AuditorAccordion
