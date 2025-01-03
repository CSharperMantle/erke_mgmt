import invokeFetch from "../invokeFetch"

interface CheckIn {
  student_id: string
  code: string
}

interface CheckInRequest {
  data: CheckIn
}

interface CheckInResponse {
  message: string
}

const invoke = async (request: CheckInRequest) => {
  const result = await invokeFetch<CheckInRequest, CheckInResponse>(
    "/api/student/do_check_in",
    "POST",
    request
  )
  return result
}

export default invoke
