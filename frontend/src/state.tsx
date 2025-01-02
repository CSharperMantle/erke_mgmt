import { createContext, useState } from "react"

export const enum LoginState {
  NotLoggedIn,
  AsStudent,
  AsOrganizer,
  AsAuditor,
  AsAdmin,
}

export interface LoginStateContextType {
  loginState: LoginState
  setLoginState: (loginState: LoginState) => void
  username: string | null
  setUsername: (username: string | null) => void
}

export const LoginStateContext = createContext<LoginStateContextType>({
  loginState: LoginState.NotLoggedIn,
  setLoginState: () => {},
  username: null,
  setUsername: () => {},
})

import { ReactNode } from "react"

export const LoginStateContextProvider = ({
  children,
}: {
  children?: ReactNode
}) => {
  const [loginState, setLoginState] = useState(LoginState.NotLoggedIn)
  const [username, setUsername] = useState<string | null>(null)

  return (
    <LoginStateContext.Provider
      value={{ loginState, setLoginState, username, setUsername }}
    >
      {children}
    </LoginStateContext.Provider>
  )
}
