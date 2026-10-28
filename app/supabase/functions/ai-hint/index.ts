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
    const hintLevel = requireInteger(body.hintLevel, 'hintLevel', 1, 3);
    rejectPersonallyIdentifiableInformation(topic, 'topic');
    rejectPersonallyIdentifiableInformation(userCode, 'userCode');

    const stageInstruction = hintLevel === 1
      ? 'Berikan petunjuk konseptual ringan yang mengarahkan perhatian, tanpa menulis kode solusi.'
      : hintLevel === 2
      ? 'Berikan petunjuk lebih spesifik tentang konsep atau langkah yang perlu diperiksa, tanpa memberikan jawaban akhir atau kode lengkap.'
      : 'Berikan petunjuk paling terarah dengan menjelaskan langkah berikutnya atau kesalahan konsep yang perlu diperbaiki, tetapi jangan menulis solusi lengkap.';

    const upstream = await fetch(GROQ_ENDPOINT, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: MODEL,
        temperature: 0.4,
        max_tokens: 180,
        messages: [
          {
            role: 'system',
            content: `Kamu mentor pemrograman dasar berbahasa Indonesia. ${stageInstruction} Jangan mengulang pertanyaan. Jangan meminta data pribadi. Balas hanya teks petunjuk singkat, maksimal 300 karakter.`,
          },
          {
            role: 'user',
            content: `Topik: ${topic}\nLevel: ${levelId}\nKode mahasiswa:\n${userCode || '(belum ada kode)'}`,
          },
        ],
      }),
      signal: AbortSignal.timeout(25_000),
    });
    if (!upstream.ok) {
      return jsonResponse({ error: 'Layanan AI gagal memproses permintaan.' }, 502);
    }

    const result: unknown = await upstream.json();
    const hint = extractContent(result).trim().slice(0, 300);
    if (!hint) return jsonResponse({ error: 'Layanan AI menghasilkan petunjuk kosong.' }, 502);
    return jsonResponse({ hint });
  } catch (error) {
    if (error instanceof RequestError) {
      return jsonResponse({ error: error.message }, error.status);
    }
    if (error instanceof DOMException && error.name === 'TimeoutError') {
      return jsonResponse({ error: 'Permintaan AI melewati batas waktu.' }, 504);
    }
    return jsonResponse({ error: 'Terjadi kesalahan saat membuat petunjuk.' }, 500);
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
