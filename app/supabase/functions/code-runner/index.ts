import { handleOptions, jsonResponse, readJsonObject, RequestError } from '../_shared/cors.ts';
import { requireBoundedString, requireOneOf } from '../_shared/guardrail.ts';

const JUDGE0_BASE_URL = 'https://ce.judge0.com';
const LANGUAGE_IDS = { cpp: 54, java: 62 } as const;
const POLL_INTERVAL_MS = 1_000;
const MAX_POLLS = 20;

interface Judge0Submission {
  token?: unknown;
}

interface Judge0Result {
  stdout?: unknown;
  stderr?: unknown;
  compile_output?: unknown;
  message?: unknown;
  time?: unknown;
  status?: { id?: unknown; description?: unknown };
}

Deno.serve(async (request: Request): Promise<Response> => {
  const methodResponse = handleOptions(request);
  if (methodResponse) return methodResponse;

  try {
    const body = await readJsonObject(request);
    const sourceCode = requireBoundedString(body.sourceCode, 'sourceCode', 30_000, 1);
    const language = requireOneOf(body.language, 'language', ['cpp', 'java'] as const);

    const submissionResponse = await fetch(
      `${JUDGE0_BASE_URL}/submissions?base64_encoded=true&wait=false`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          language_id: LANGUAGE_IDS[language],
          source_code: encodeBase64(sourceCode),
        }),
        signal: AbortSignal.timeout(20_000),
      },
    );
    if (!submissionResponse.ok) {
      return jsonResponse({ error: 'Judge0 gagal menerima kode.' }, 502);
    }

    const submission = await submissionResponse.json() as Judge0Submission;
    if (typeof submission.token !== 'string' || !submission.token) {
      return jsonResponse({ error: 'Judge0 tidak mengembalikan token submission.' }, 502);
    }

    let result: Judge0Result | null = null;
    for (let attempt = 0; attempt < MAX_POLLS; attempt++) {
      await delay(POLL_INTERVAL_MS);
      const pollResponse = await fetch(
        `${JUDGE0_BASE_URL}/submissions/${encodeURIComponent(submission.token)}?base64_encoded=true`,
        { method: 'GET', signal: AbortSignal.timeout(15_000) },
      );
      if (!pollResponse.ok) {
        return jsonResponse({ error: 'Gagal membaca hasil eksekusi dari Judge0.' }, 502);
      }
      result = await pollResponse.json() as Judge0Result;
      const statusId = result.status?.id;
      if (typeof statusId === 'number' && statusId !== 1 && statusId !== 2) break;
      result = null;
    }

    if (!result) {
      return jsonResponse({ error: 'Waktu tunggu eksekusi kode habis.' }, 504);
    }

    return jsonResponse({
      stdout: decodeOptionalBase64(result.stdout),
      stderr: decodeOptionalBase64(result.stderr),
      compile_output: decodeOptionalBase64(result.compile_output),
      message: decodeOptionalBase64(result.message),
      status: result.status?.description ?? 'Unknown',
      time: result.time ?? null,
    });
  } catch (error) {
    if (error instanceof RequestError) {
      return jsonResponse({ error: error.message }, error.status);
    }
    if (error instanceof DOMException && error.name === 'TimeoutError') {
      return jsonResponse({ error: 'Permintaan ke Judge0 melewati batas waktu.' }, 504);
    }
    return jsonResponse({ error: 'Terjadi kesalahan saat menjalankan kode.' }, 500);
  }
});

function encodeBase64(value: string): string {
  const bytes = new TextEncoder().encode(value);
  let binary = '';
  for (let offset = 0; offset < bytes.length; offset += 0x8000) {
    binary += String.fromCharCode(...bytes.subarray(offset, offset + 0x8000));
  }
  return btoa(binary);
}

function decodeOptionalBase64(value: unknown): string | null {
  if (typeof value !== 'string') return null;
  try {
    const binary = atob(value);
    const bytes = Uint8Array.from(binary, (character) => character.charCodeAt(0));
    return new TextDecoder().decode(bytes);
  } catch {
    return value;
  }
}

function delay(milliseconds: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, milliseconds));
}
