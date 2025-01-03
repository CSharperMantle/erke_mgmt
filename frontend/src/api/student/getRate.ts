import invokeFetch from "../invokeFetch"

export interface Rate {
  student_id: string
  activity_id: number
  rate_value: number | null
}

interface GetRateResponse {
  message: string
  data: Rate[]
}

const invoke = async () => {
  const result = await invokeFetch<never, GetRateResponse>(
    "/api/student/my_rate",
    "GET"
  )
  return result
}

export default invoke
