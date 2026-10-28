const allowedHeaders =
  'authorization, x-client-info, apikey, content-type, x-requested-with';

export const corsHeaders: Record<string, string> = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': allowedHeaders,
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Max-Age': '86400',
};

export function jsonResponse(
  body: unknown,
  status = 200,
  headers: HeadersInit = {},
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json; charset=utf-8',
      ...Object.fromEntries(new Headers(headers).entries()),
    },
  });
}

export function handleOptions(request: Request): Response | null {
  if (request.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: corsHeaders });
  }
  if (request.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405, {
      Allow: 'POST, OPTIONS',
    });
  }
  return null;
}

export async function readJsonObject(request: Request): Promise<Record<string, unknown>> {
  const contentType = request.headers.get('content-type') ?? '';
  if (!contentType.toLowerCase().includes('application/json')) {
    throw new RequestError(415, 'Content-Type harus application/json.');
  }

  let value: unknown;
  try {
    value = await request.json();
  } catch {
    throw new RequestError(400, 'Body JSON tidak valid.');
  }

  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    throw new RequestError(400, 'Body harus berupa objek JSON.');
  }
  return value as Record<string, unknown>;
}

export class RequestError extends Error {
  constructor(readonly status: number, message: string) {
    super(message);
    this.name = 'RequestError';
  }
}
