import invokeFetch from "../invokeFetch"

interface InitiateCheckOutRequest {
  data: {
    organizer_id: string
    activity_id: number
    valid_duration: number
  }
}

interface InitiateCheckOutResponse {
  message: string
  data: {
    code: string
  }
}

const invoke = async (request: InitiateCheckOutRequest) => {
  const result = await invokeFetch<
    InitiateCheckOutRequest,
    InitiateCheckOutResponse
  >("/api/organizer/initiate_check_out", "POST", request)
  return result
}

export default invoke
