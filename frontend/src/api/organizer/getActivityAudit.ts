import invokeFetch from "../invokeFetch"

export interface ActivityAudit {
  id: number
  auditor_id: string
  auditor_name: string
  activity_id: number
  activity_name: string
  audit_comment: string
  audit_passed: boolean
}

interface GetActivityAuditResponse {
  message: string
  data: ActivityAudit[]
}

const invoke = async () => {
  const result = await invokeFetch<never, GetActivityAuditResponse>(
    "/api/organizer/my_activity_audit",
    "GET"
  )
  return result
}

export default invoke
