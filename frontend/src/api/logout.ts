import invokeFetch from "./invokeFetch"

export interface LogoutResponse {
  message: string
}

const invoke = async () => {
  const result = await invokeFetch<never, LogoutResponse>("/api/logout", "POST")
  return result
}

export default invoke
