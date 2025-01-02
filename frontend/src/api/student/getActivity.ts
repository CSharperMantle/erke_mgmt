import invokeFetch from "../invokeFetch"

export interface Activity {
  id: number
  organizer_id: string
  name: string
  description: string
  location: string
  signup_start_time: number
  signup_end_time: number
  start_time: number
  end_time: number
  max_particp_count: number
  state: number
  tags: number[]
  open_to: number[]
}

interface GetActivityResponse {
  message: string
  data: Activity[]
}

const invoke = async () => {
  const result = await invokeFetch<never, GetActivityResponse>(
    "/api/student/activity",
    "GET"
  )
  return result
}

export default invoke
