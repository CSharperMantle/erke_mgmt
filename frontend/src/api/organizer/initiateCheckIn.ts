import invokeFetch from "../invokeFetch"

interface InitiateCheckInRequest {
  data: {
    organizer_id: string
    activity_id: number
    valid_duration: number
  }
}

interface InitiateCheckInResponse {
  message: string
  data: {
    code: string
  }
}

const invoke = async (request: InitiateCheckInRequest) => {
  const result = await invokeFetch<
    InitiateCheckInRequest,
    InitiateCheckInResponse
  >("/api/organizer/initiate_check_in", "POST", request)
  return result
}

export default invoke
