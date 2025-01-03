import { useContext, useRef, useState } from "react"

import CheckCircleIcon from "@mui/icons-material/CheckCircle"
import ExpandMoreIcon from "@mui/icons-material/ExpandMore"
import RefreshIcon from "@mui/icons-material/Refresh"
import Accordion from "@mui/material/Accordion"
import AccordionDetails from "@mui/material/AccordionDetails"
import Backdrop from "@mui/material/Backdrop"
import Box from "@mui/material/Box"
import Button from "@mui/material/Button"
import Chip from "@mui/material/Chip"
import CircularProgress from "@mui/material/CircularProgress"
import Container from "@mui/material/Container"
import Divider from "@mui/material/Divider"
import Grid2 from "@mui/material/Grid2"
import Stack from "@mui/material/Stack"
import TextField from "@mui/material/TextField"
import ToggleButton from "@mui/material/ToggleButton"
import ToggleButtonGroup from "@mui/material/ToggleButtonGroup"
import Typography from "@mui/material/Typography"
import {
  DataGrid,
  GridActionsCellItem,
  GridColDef,
  GridRenderCellParams,
  GridRowParams,
} from "@mui/x-data-grid"
import { useSnackbar } from "notistack"

import { LoginState, LoginStateContext } from "../state"
import GrayAccordionSummary from "./GrayAccordionSummary"
import invokeGetActivity, {
  Activity as GetActivity,
} from "../api/organizer/getActivity"
import invokePutActivity from "../api/organizer/putActivity"
import invokeGetTag, { Tag } from "../api/organizer/getTag"
import invokeInitiateCheckIn from "../api/organizer/initiateCheckIn"
import invokeInitiateCheckOut from "../api/organizer/initiateCheckOut"

const CreateActivity = () => {
  const ctx = useContext(LoginStateContext)

  const { enqueueSnackbar } = useSnackbar()

  const [loading, setLoading] = useState(false)
  const [activityName, setActivityName] = useState("")
  const [activityLocation, setActivityLocation] = useState("")
  const [signupStartTime, setSignupStartTime] = useState("")
  const [signupEndTime, setSignupEndTime] = useState("")
  const [startTime, setStartTime] = useState("")
  const [endTime, setEndTime] = useState("")
  const [maxParticpCount, setMaxParticpCount] = useState("")
  const [tags, setTags] = useState("")
  const [openTo, setOpenTo] = useState("")
  const [description, setDescription] = useState("")

  return (
    <>
      <Grid2 container spacing={2} columns={4}>
        <Grid2 size={4}>
          <TextField
            id="organizer-panel-activity-name-input"
            label="活动名称"
            variant="standard"
            required
            fullWidth
            type="text"
            autoComplete="off"
            value={activityName}
            onChange={(e) => setActivityName(e.target.value)}
          />
        </Grid2>
        <Grid2 size={4}>
          <TextField
            id="organizer-panel-activity-location-input"
            label="活动地点"
            variant="standard"
            required
            fullWidth
            type="text"
            autoComplete="off"
            value={activityLocation}
            onChange={(e) => setActivityLocation(e.target.value)}
          />
        </Grid2>
        <Grid2 size={{ xs: 4, sm: 2 }}>
          <TextField
            id="organizer-panel-activity-signup-start-time-input"
            label="报名开始时间"
            variant="standard"
            required
            slotProps={{ inputLabel: { shrink: true } }}
            fullWidth
            type="datetime-local"
            autoComplete="off"
            value={signupStartTime}
            onChange={(e) => setSignupStartTime(e.target.value)}
          />
        </Grid2>
        <Grid2 size={{ xs: 4, sm: 2 }}>
          <TextField
            id="organizer-panel-activity-signup-end-time-input"
            label="报名结束时间"
            variant="standard"
            required
            slotProps={{ inputLabel: { shrink: true } }}
            fullWidth
            type="datetime-local"
            autoComplete="off"
            value={signupEndTime}
            onChange={(e) => setSignupEndTime(e.target.value)}
          />
        </Grid2>
        <Grid2 size={{ xs: 4, sm: 2 }}>
          <TextField
            id="organizer-panel-activity-start-time-input"
            label="活动开始时间"
            variant="standard"
            required
            slotProps={{ inputLabel: { shrink: true } }}
            fullWidth
            type="datetime-local"
            autoComplete="off"
            value={startTime}
            onChange={(e) => setStartTime(e.target.value)}
          />
        </Grid2>
        <Grid2 size={{ xs: 4, sm: 2 }}>
          <TextField
            id="organizer-panel-activity-end-time-input"
            label="活动结束时间"
            variant="standard"
            required
            slotProps={{ inputLabel: { shrink: true } }}
            fullWidth
            type="datetime-local"
            autoComplete="off"
            value={endTime}
            onChange={(e) => setEndTime(e.target.value)}
          />
        </Grid2>
        <Grid2 size={{ xs: 4, sm: 2 }}>
          <TextField
            id="organizer-panel-activity-max-particp-count-input"
            label="最大参与人数"
            variant="standard"
            required
            fullWidth
            type="number"
            autoComplete="off"
            value={maxParticpCount}
            onChange={(e) => setMaxParticpCount(e.target.value)}
          />
        </Grid2>
        <Grid2 size={{ xs: 4, sm: 2 }}>
          <TextField
            id="organizer-panel-activity-tags-input"
            label="标签"
            variant="standard"
            required
            fullWidth
            type="text"
            autoComplete="off"
            value={tags}
            onChange={(e) => setTags(e.target.value)}
          />
        </Grid2>
        <Grid2 size={{ xs: 4, sm: 2 }}>
          <TextField
            id="organizer-panel-activity-open-to-input"
            label="开放年级"
            variant="standard"
            required
            fullWidth
            type="text"
            autoComplete="off"
            value={openTo}
            onChange={(e) => setOpenTo(e.target.value)}
          />
        </Grid2>
        <Grid2 size={4}>
          <TextField
            id="organizer-panel-activity-description-input"
            label="活动描述"
            variant="standard"
            required
            fullWidth
            multiline
            minRows={4}
            maxRows={12}
            autoComplete="off"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
          />
        </Grid2>
        <Grid2 size={4}>
          <Container maxWidth="sm">
            <Button
              fullWidth
              variant="contained"
              color="primary"
              type="submit"
              disabled={
                loading ||
                [
                  activityName,
                  activityLocation,
                  signupStartTime,
                  signupEndTime,
                  startTime,
                  endTime,
                  maxParticpCount,
                  tags,
                  openTo,
                  description,
                ].some((field) => field.length === 0)
              }
              onClick={async () => {
                const tagsArr = tags.split(",").map((tag) => parseInt(tag))
                const openToArr = openTo
                  .split(",")
                  .map((grade) => parseInt(grade))
                setLoading(true)
                try {
                  await invokePutActivity({
                    data: {
                      organizer_id: ctx.username ?? "",
                      name: activityName,
                      description: description,
                      location: activityLocation,
                      signup_start_time: Date.parse(signupStartTime),
                      signup_end_time: Date.parse(signupEndTime),
                      start_time: Date.parse(startTime),
                      end_time: Date.parse(endTime),
                      max_particp_count: parseInt(maxParticpCount),
                      tags: tagsArr,
                      open_to: openToArr,
                    },
                  })
                  enqueueSnackbar("创建成功", { variant: "success" })
                } catch (ex) {
                  const ex_ = ex as Error
                  enqueueSnackbar(ex_.message, { variant: "error" })
                } finally {
                  setLoading(false)
                }
              }}
            >
              创建活动
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

const ActivityDisplay = () => {
  const { enqueueSnackbar } = useSnackbar()

  const [loading, setLoading] = useState(false)
  const [activities, setActivities] = useState<GetActivity[]>([])
  const [tags, setTags] = useState<Tag[]>([])

  const colDefs: GridColDef[] = [
    { field: "id", type: "number", headerName: "编号", width: 50 },
    { field: "name", type: "string", headerName: "名称" },
    {
      field: "state",
      type: "string",
      headerName: "状态",
      valueGetter: (v: number) => {
        switch (v) {
          case 0:
            return "未开始签到"
          case 1:
            return "已开放签到"
          case 2:
            return "已开放签退"
          case 3:
            return "完结已审核"
          default:
            return "?"
        }
      },
    },
    {
      field: "tags",
      headerName: "标签",
      renderCell: (params: GridRenderCellParams<any, number[]>) => (
        <Stack direction="row" spacing={1} alignItems="center" height="100%">
          {params.value?.map((tid) => (
            <Chip
              variant="outlined"
              label={tags.find((tag) => tag.id === tid)?.name ?? "?"}
            />
          ))}
        </Stack>
      ),
      width: 150,
      sortable: false,
    },
    {
      field: "open_to",
      headerName: "开放年级",
      renderCell: (params: GridRenderCellParams<any, number[]>) => (
        <Stack direction="row" spacing={1} alignItems="center" height="100%">
          {params.value?.map((grade) => (
            <Chip variant="outlined" label={`${grade}级`} />
          ))}
        </Stack>
      ),
      width: 300,
      sortable: false,
    },
    { field: "organizer_id", type: "string", headerName: "组织者" },
    { field: "description", type: "string", headerName: "描述" },
    { field: "location", headerName: "地点" },
    {
      field: "signup_start_time",
      type: "dateTime",
      headerName: "报名开始时间",
      valueGetter: (v: number) => new Date(v),
      width: 175,
    },
    {
      field: "signup_end_time",
      type: "dateTime",
      headerName: "报名结束时间",
      valueGetter: (v: number) => new Date(v),
      width: 175,
    },
    {
      field: "start_time",
      type: "dateTime",
      headerName: "开始时间",
      valueGetter: (v: number) => new Date(v),
      width: 175,
    },
    {
      field: "end_time",
      type: "dateTime",
      headerName: "结束时间",
      valueGetter: (v: number) => new Date(v),
      width: 175,
    },
    {
      field: "max_particp_count",
      type: "number",
      headerName: "人数上限",
      width: 75,
    },
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
              setActivities((await invokeGetActivity()).data)
              setTags((await invokeGetTag()).data)
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
          rows={activities}
          columns={colDefs}
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

const InitiateCheckInOut = () => {
  const ctx = useContext(LoginStateContext)

  const { enqueueSnackbar } = useSnackbar()

  const activityIdRef = useRef<HTMLInputElement>()
  const validSecRef = useRef<HTMLInputElement>()

  const [codeValue, setCodeValue] = useState<string | null>(null)
  const [checkInOut, setCheckInOut] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  return (
    <>
      <Grid2 container spacing={2} columns={6} alignItems="center">
        <Grid2 size={{ xs: 3, sm: 2 }}>
          <TextField
            label="活动编号"
            variant="standard"
            fullWidth
            type="number"
            required
            disabled={checkInOut === null}
            inputRef={activityIdRef}
          />
        </Grid2>
        <Grid2 size={{ xs: 3, sm: 2 }}>
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
        <Grid2 size={{ xs: 3, sm: 2 }}>
          <TextField
            label="有效秒数"
            variant="standard"
            fullWidth
            type="number"
            required
            disabled={checkInOut === null}
            inputRef={validSecRef}
          />
        </Grid2>
        <Grid2 size={3}>
          <Container maxWidth="sm">
            <Button
              variant="contained"
              color="primary"
              fullWidth
              disabled={checkInOut === null}
              onClick={async () => {
                setLoading(true)
                try {
                  let code
                  if (checkInOut === "check_in") {
                    code = await invokeInitiateCheckIn({
                      data: {
                        organizer_id: ctx.username ?? "",
                        activity_id: parseInt(activityIdRef.current!.value),
                        valid_duration: parseInt(validSecRef.current!.value),
                      },
                    })
                  } else {
                    code = await invokeInitiateCheckOut({
                      data: {
                        organizer_id: ctx.username ?? "",
                        activity_id: parseInt(activityIdRef.current!.value),
                        valid_duration: parseInt(validSecRef.current!.value),
                      },
                    })
                  }
                  setCodeValue(code.data.code)
                } catch (ex) {
                  const ex_ = ex as Error
                  enqueueSnackbar(ex_.message, { variant: "error" })
                } finally {
                  setLoading(false)
                }
              }}
            >
              生成密令
            </Button>
          </Container>
        </Grid2>
        <Grid2 size={3}>
          <Container maxWidth="xs">
            <TextField
              label="密令"
              variant="standard"
              fullWidth
              type="text"
              value={codeValue}
              disabled={checkInOut === null}
              slotProps={{
                input: {
                  readOnly: true,
                },
                inputLabel: { shrink: true },
              }}
            />
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

const OrganizerAccordion = () => {
  const ctx = useContext(LoginStateContext)

  return (
    <Accordion
      disabled={
        ![LoginState.AsOrganizer, LoginState.AsAdmin].includes(ctx.loginState)
      }
    >
      <GrayAccordionSummary
        expandIcon={<ExpandMoreIcon />}
        aria-controls="organizer-panel-content"
        id="organizer-panel-header"
      >
        <Typography component="span">组织者端</Typography>
      </GrayAccordionSummary>
      <AccordionDetails>
        <Stack direction="column" spacing={2} sx={{ pt: 2, pb: 2 }}>
          <CreateActivity />
          <Divider variant="fullWidth" sx={{ color: "darkgray" }} />
          <ActivityDisplay />
          <Divider variant="fullWidth" sx={{ color: "darkgray" }} />
          <InitiateCheckInOut />
        </Stack>
      </AccordionDetails>
    </Accordion>
  )
}

export default OrganizerAccordion
