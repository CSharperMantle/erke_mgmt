import invokeFetch from "../invokeFetch"

interface AuditPutRequest {
  data: {
    auditor_id: string
    activity_id: number
    audit_comment: string
    audit_passed: boolean
  }
}

interface AuditPutResponse {
  message: string
}

const invoke = async (request: AuditPutRequest) => {
  const result = await invokeFetch<AuditPutRequest, AuditPutResponse>(
    "/api/auditor/my_audit",
    "PUT",
    request
  )
  return result
}

export default invoke
