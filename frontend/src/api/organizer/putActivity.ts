import invokeFetch from "../invokeFetch"

interface ActivityPutRequest {
  data: {
    organizer_id: string
    name: string
    description: string
    location: string
    signup_start_time: number
    signup_end_time: number
    start_time: number
    end_time: number
    max_particp_count: number
    tags: number[]
    open_to: number[]
  }
}

interface ActivityPutResponse {
  message: string
}

const invoke = async (request: ActivityPutRequest) => {
  const result = await invokeFetch<ActivityPutRequest, ActivityPutResponse>(
    "/api/organizer/activity",
    "PUT",
    request
  )
  return result
}

export default invoke
