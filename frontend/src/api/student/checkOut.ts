import invokeFetch from "../invokeFetch"

interface CheckOut {
  student_id: string
  code: string
}

interface CheckOutRequest {
  data: CheckOut
}

interface CheckInResponse {
  message: string
}

const invoke = async (request: CheckOutRequest) => {
  const result = await invokeFetch<CheckOutRequest, CheckInResponse>(
    "/api/student/do_check_in",
    "POST",
    request
  )
  return result
}

export default invoke
