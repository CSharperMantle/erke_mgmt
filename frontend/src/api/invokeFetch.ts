export class FetchError<Resp> extends Error {
  constructor(
    public status: number,
    public message: string,
    public response?: Resp
  ) {
    super(message)
  }
}

export default async function invokeFetch<Req, Resp>(
  url: string,
  method: string,
  request?: Req
): Promise<Resp> {
  const reqHasBody = request !== undefined
  const result = await fetch(url, {
    method,
    headers: reqHasBody ? { "Content-Type": "application/json" } : {},
    body: reqHasBody ? JSON.stringify(request) : undefined,
  })
  const obj = await result.json()
  if (!result.ok) {
    const msg = obj.message !== undefined ? `: ${obj.message}` : ""
    throw new FetchError(result.status, `${result.statusText}${msg}`, obj)
  }
  return obj
}
