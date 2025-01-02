import invokeFetch from "../invokeFetch"

export interface AvailActivity {
  activity_id: number
}

interface GetAvailActivityResponse {
  message: string
  data: AvailActivity[]
}

const invoke = async () => {
  const result = await invokeFetch<never, GetAvailActivityResponse>(
    "/api/student/available_activity",
    "GET"
  )
  return result
}

export default invoke
