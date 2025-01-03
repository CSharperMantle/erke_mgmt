import { useContext, useState } from "react"

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
import Rating from "@mui/material/Rating"
import { useSnackbar } from "notistack"

import invokeCheckIn from "../api/student/checkIn"
import invokeCheckOut from "../api/student/checkOut"
import invokeGetActivity, { Activity } from "../api/student/getActivity"
import invokeGetAvailActivity, {
  AvailActivity,
} from "../api/student/getAvailActivity"
import invokeGetTag, { Tag } from "../api/student/getTag"
import invokePutSignUp from "../api/student/putSignUp"
import invokePutRate from "../api/student/putRate"
import { LoginState, LoginStateContext } from "../state"
import GrayAccordionSummary from "./GrayAccordionSummary"

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

const ActivityDisplay = () => {
  const ctx = useContext(LoginStateContext)

  const { enqueueSnackbar } = useSnackbar()

  const [loading, setLoading] = useState(false)
  const [activities, setActivities] = useState<Activity[]>([])
  const [availActivities, setAvailActivities] = useState<AvailActivity[]>([])
  const [tags, setTags] = useState<Tag[]>([])

  const colDefs: GridColDef[] = [
    {
      field: "actions",
      type: "actions",
      getActions: (params: GridRowParams) => {
        if (
          params.row.id === undefined ||
          !availActivities.map((a) => a.activity_id).includes(params.row.id)
        ) {
          return []
        } else {
          return [
            <GridActionsCellItem
              icon={<CheckCircleIcon />}
              label="报名"
              onClick={async () => {
                setLoading(true)
                try {
                  await invokePutSignUp({
                    data: {
                      student_id: ctx.username ?? "",
                      activity_id: params.row.id,
                    },
                  })
                  enqueueSnackbar("报名成功", { variant: "success" })
                } catch (ex) {
                  const ex_ = ex as Error
                  enqueueSnackbar(ex_.message, { variant: "error" })
                } finally {
                  setLoading(false)
                }
              }}
            />,
          ]
        }
      },
      width: 50,
    },
    { field: "id", type: "number", headerName: "编号", width: 50 },
    { field: "name", type: "string", headerName: "名称" },
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
              setAvailActivities((await invokeGetAvailActivity()).data)
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

const RateActivity = () => {
  const ctx = useContext(LoginStateContext)

  const { enqueueSnackbar } = useSnackbar()

  const [loading, setLoading] = useState(false)
  const [activityId, setActivityId] = useState<string | null>(null)
  const [rating, setRating] = useState<number | null>(null)

  return (
    <>
      <Grid2
        container
        columns={{ sm: 3, xs: 1 }}
        spacing={2}
        alignItems="center"
      >
        <Grid2 size={1}>
          <TextField
            label="活动编号"
            variant="standard"
            fullWidth
            type="number"
            required
            value={activityId}
            onChange={(e) => setActivityId(e.target.value)}
          />
        </Grid2>
        <Grid2 size={1}>
          <Stack alignItems="center">
            <Rating
              size="large"
              value={rating}
              precision={1}
              onChange={(_, newValue) => {
                setRating(newValue)
              }}
            />
          </Stack>
        </Grid2>
        <Grid2 size={1}>
          <Container maxWidth="xs">
            <Button
              variant="contained"
              color="primary"
              fullWidth
              disabled={activityId === null || rating === null}
              onClick={async () => {
                setLoading(true)
                try {
                  await invokePutRate({
                    data: {
                      student_id: ctx.username ?? "",
                      activity_id: parseInt(activityId ?? "0"),
                      rate_value: rating ?? 0,
                    },
                  })
                  enqueueSnackbar("评分成功", { variant: "success" })
                } catch (ex) {
                  const ex_ = ex as Error
                  enqueueSnackbar(ex_.message, { variant: "error" })
                } finally {
                  setLoading(false)
                }
              }}
            >
              提交评分
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
          <Divider variant="fullWidth" sx={{ color: "darkgray" }} />
          <ActivityDisplay />
          <Divider variant="fullWidth" sx={{ color: "darkgray" }} />
          <RateActivity />
        </Stack>
      </AccordionDetails>
    </Accordion>
  )
}

export default StudentAccordion
