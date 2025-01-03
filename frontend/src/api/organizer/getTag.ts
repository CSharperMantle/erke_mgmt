import invokeFetch from "../invokeFetch"

export interface Tag {
  id: number
  name: string
}

interface GetTagResponse {
  message: string
  data: Tag[]
}

const invoke = async () => {
  const result = await invokeFetch<never, GetTagResponse>(
    "/api/student/tag",
    "GET"
  )
  return result
}

export default invoke
