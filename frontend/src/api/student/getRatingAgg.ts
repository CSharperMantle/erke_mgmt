import invokeFetch from "../invokeFetch"

export interface RatingAgg {
  activity_id: number
  activity_name: string
  rate_cnt: number
  rate_avg: number | null
  rate_max: number | null
  rate_min: number | null
}

interface GetRatingAggResponse {
  message: string
  data: RatingAgg[]
}

const invoke = async () => {
  const result = await invokeFetch<never, GetRatingAggResponse>(
    "/api/student/rating_agg",
    "GET"
  )
  return result
}

export default invoke
