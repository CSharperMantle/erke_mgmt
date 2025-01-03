import invokeFetch from "./invokeFetch"

interface LoginRequest {
  username: string
  password: string
}

interface LoginResponse {
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
