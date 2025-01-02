import invokeFetch from "../invokeFetch"

export interface Rate {
  student_id: string
  activity_id: number
  rate_value: number
}

interface PutRateRequest {
  data: Rate
}

interface PutRateResponse {
  message: string
}

const invoke = async (request: PutRateRequest) => {
  const result = await invokeFetch<PutRateRequest, PutRateResponse>(
    "/api/student/my_rate",
    "PUT",
    request
  )
  return result
}

export default invoke
