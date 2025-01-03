import { useContext, useState } from "react"

import ExpandMoreIcon from "@mui/icons-material/ExpandMore"
import Accordion from "@mui/material/Accordion"
import AccordionActions from "@mui/material/AccordionActions"
import AccordionDetails from "@mui/material/AccordionDetails"
import Backdrop from "@mui/material/Backdrop"
import Button from "@mui/material/Button"
import CircularProgress from "@mui/material/CircularProgress"
import FormControl from "@mui/material/FormControl"
import Grid2 from "@mui/material/Grid2"
import InputLabel from "@mui/material/InputLabel"
import MenuItem from "@mui/material/MenuItem"
import Select from "@mui/material/Select"
import TextField from "@mui/material/TextField"
import Typography from "@mui/material/Typography"
import { useSnackbar } from "notistack"

import invokeLogin from "../api/login"
import invokeLogout from "../api/logout"
import { LoginState, LoginStateContext } from "../state"
import GrayAccordionSummary from "./GrayAccordionSummary"

const LoginAccordion = () => {
  const ctx = useContext(LoginStateContext)

  const { enqueueSnackbar } = useSnackbar()

  const [username, setUsername] = useState("")
  const [password, setPassword] = useState("")

  const [accountType, setAccountType] = useState("")
  const [loading, setLoading] = useState(false)

  const loggedIn = ctx.loginState !== LoginState.NotLoggedIn

  return (
    <Accordion defaultExpanded>
      <GrayAccordionSummary
        expandIcon={<ExpandMoreIcon />}
        aria-controls="login-panel-content"
        id="login-panel-header"
      >
        <Typography component="span">登录</Typography>
      </GrayAccordionSummary>
      <AccordionDetails>
        <Grid2 container spacing={2} columns={4}>
          <Grid2
            size={{
              xs: 4,
              sm: 2,
            }}
          >
            <TextField
              id="login-panel-username-input"
              label="用户名"
              variant="standard"
              fullWidth
              type="text"
              autoComplete="username"
              required={accountType !== "admin"}
              disabled={loggedIn}
              value={username}
              onChange={(e) => setUsername(e.target.value)}
            />
          </Grid2>
          <Grid2
            size={{
              xs: 4,
              sm: 2,
            }}
          >
            <FormControl variant="standard" fullWidth>
              <InputLabel id="login-panel-type-select-label">身份</InputLabel>
              <Select
                id="login-panel-type-select"
                labelId="login-panel-type-select-label"
                label="身份"
                value={accountType}
                disabled={loggedIn}
                onChange={(e) => setAccountType(e.target.value as string)}
              >
                <MenuItem value={"student"}>学生</MenuItem>
                <MenuItem value={"organizer"}>组织者</MenuItem>
                <MenuItem value={"auditor"}>审核员</MenuItem>
                <MenuItem value={"admin"}>管理员</MenuItem>
              </Select>
            </FormControl>
          </Grid2>
          <Grid2 size={4}>
            <TextField
              id="login-panel-password-input"
              label="密码"
              variant="standard"
              fullWidth
              type="password"
              autoComplete="current-password"
              required
              disabled={loggedIn}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </Grid2>
        </Grid2>
      </AccordionDetails>
      <AccordionActions>
        <Button
          variant="contained"
          color="secondary"
          type="button"
          disabled={!loggedIn}
          onClick={async (e) => {
            e.preventDefault()
            setLoading(true)
            try {
              await invokeLogout()
            } catch (ex) {
              const ex_ = ex as Error
              enqueueSnackbar(ex_.message, { variant: "error" })
              return
            } finally {
              setLoading(false)
            }
            ctx.setLoginState(LoginState.NotLoggedIn)
            ctx.setUsername(null)
          }}
        >
          注销
        </Button>
        <Button
          variant="contained"
          color="primary"
          type="submit"
          disabled={loggedIn}
          onClick={async (e) => {
            e.preventDefault()
            setLoading(true)
            try {
              const dbUsername =
                accountType === "admin" ? "admin" : `${accountType}_${username}`
              await invokeLogin({
                username: dbUsername,
                password,
              })
            } catch (ex) {
              const ex_ = ex as Error
              enqueueSnackbar(ex_.message, { variant: "error" })
              return
            } finally {
              setLoading(false)
            }
            let newState = LoginState.NotLoggedIn
            switch (accountType) {
              case "student":
                newState = LoginState.AsStudent
                break
              case "organizer":
                newState = LoginState.AsOrganizer
                break
              case "auditor":
                newState = LoginState.AsAuditor
                break
              case "admin":
                newState = LoginState.AsAdmin
                break
              default:
                break
            }
            ctx.setLoginState(newState)
            ctx.setUsername(username)
          }}
        >
          登录
        </Button>
      </AccordionActions>
      <Backdrop
        sx={(theme) => ({ color: "#fff", zIndex: theme.zIndex.drawer + 1 })}
        open={loading}
      >
        <CircularProgress color="inherit" />
      </Backdrop>
    </Accordion>
  )
}

export default LoginAccordion
