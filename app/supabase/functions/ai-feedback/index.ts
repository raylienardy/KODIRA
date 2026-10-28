import { handleOptions, jsonResponse, readJsonObject, RequestError } from '../_shared/cors.ts';
import { rejectPersonallyIdentifiableInformation, requireBoundedString, requireInteger } from '../_shared/guardrail.ts';

const GROQ_ENDPOINT = 'https://api.groq.com/openai/v1/chat/completions';
const MODEL = 'openai/gpt-oss-120b';

Deno.serve(async (request: Request): Promise<Response> => {
  const methodResponse = handleOptions(request);
  if (methodResponse) return methodResponse;

  try {
    const apiKey = Deno.env.get('GROQ_API_KEY');
    if (!apiKey) return jsonResponse({ error: 'Layanan AI belum dikonfigurasi.' }, 503);

    const body = await readJsonObject(request);
    const levelId = requireInteger(body.levelId, 'levelId', 1, 1000);
    const topic = requireBoundedString(body.topic, 'topic', 120, 1);
    const userCode = requireBoundedString(body.userCode, 'userCode', 12_000);
    const expectedAnswer = requireBoundedString(body.expectedAnswer, 'expectedAnswer', 6_000);
    const isCorrect = body.isCorrect;
    if (typeof isCorrect !== 'boolean') {
      throw new RequestError(400, 'Field isCorrect harus berupa boolean.');
    }
    rejectPersonallyIdentifiableInformation(topic, 'topic');
    rejectPersonallyIdentifiableInformation(userCode, 'userCode');
    rejectPersonallyIdentifiableInformation(expectedAnswer, 'expectedAnswer');

    const upstream = await fetch(GROQ_ENDPOINT, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: MODEL,
        temperature: 0.35,
        max_tokens: 220,
        messages: [
          {
            role: 'system',
            content: 'Kamu mentor pemrograman dasar berbahasa Indonesia. Berikan feedback yang ramah dan spesifik tentang konsep yang sudah benar dan satu hal yang perlu diperbaiki. Jangan berikan jawaban lengkap, jangan meminta data pribadi. Maksimal 400 karakter. Balas hanya feedback.',
          },
          {
            role: 'user',
            content: `Topik: ${topic}\nLevel: ${levelId}\nHasil dinilai benar: ${isCorrect}\nKode mahasiswa:\n${userCode || '(belum ada kode)'}\nReferensi konsep/jawaban yang diharapkan:\n${expectedAnswer}`,
          },
        ],
      }),
      signal: AbortSignal.timeout(25_000),
    });
    if (!upstream.ok) {
      return jsonResponse({ error: 'Layanan AI gagal memproses permintaan.' }, 502);
    }

    const feedback = extractContent(await upstream.json()).trim().slice(0, 400);
    if (!feedback) return jsonResponse({ error: 'Layanan AI menghasilkan feedback kosong.' }, 502);
    return jsonResponse({ feedback });
  } catch (error) {
    if (error instanceof RequestError) {
      return jsonResponse({ error: error.message }, error.status);
    }
    if (error instanceof DOMException && error.name === 'TimeoutError') {
      return jsonResponse({ error: 'Permintaan AI melewati batas waktu.' }, 504);
    }
    return jsonResponse({ error: 'Terjadi kesalahan saat membuat feedback.' }, 500);
  }
});

function extractContent(value: unknown): string {
  if (value === null || typeof value !== 'object') return '';
  const choices = (value as { choices?: unknown }).choices;
  if (!Array.isArray(choices) || choices.length === 0) return '';
  const message = (choices[0] as { message?: unknown } | null)?.message;
  if (message === null || typeof message !== 'object') return '';
  const content = (message as { content?: unknown }).content;
  return typeof content === 'string' ? content : '';
}
