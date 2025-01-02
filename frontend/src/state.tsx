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
}

export const LoginStateContext = createContext<LoginStateContextType>({
  loginState: LoginState.NotLoggedIn,
  setLoginState: () => {},
})

import { ReactNode } from "react"

export const LoginStateContextProvider = ({
  children,
}: {
  children?: ReactNode
}) => {
  const [loginState, setLoginState] = useState(LoginState.NotLoggedIn)

  return (
    <LoginStateContext.Provider value={{ loginState, setLoginState }}>
      {children}
    </LoginStateContext.Provider>
  )
}
