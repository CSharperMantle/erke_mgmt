import invokeFetch from "./invokeFetch"

export interface LoginRequest {
  username: string
  password: string
}

export interface LoginResponse {
  message: string
}

const invoke = async (request: LoginRequest) => {
  const result = await invokeFetch<LoginRequest, LoginResponse>(
    "/api/login",
    "POST",
    request
  )
  return result
}

export default invoke
