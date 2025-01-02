import invokeFetch from "../invokeFetch"

interface SignUp {
  student_id: string
  activity_id: number
}

interface SignUpRequest {
  data: SignUp
}

interface SignUpResponse {
  message: string
}

const invoke = async (request: SignUpRequest) => {
  const result = await invokeFetch<SignUpRequest, SignUpResponse>(
    "/api/student/my_signup",
    "PUT",
    request
  )
  return result
}

export default invoke
