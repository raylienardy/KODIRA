import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.8';
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

    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

    const body = await readJsonObject(request);
    const levelId = requireInteger(body.levelId, 'levelId', 1, 1000);
    const topic = requireBoundedString(body.topic, 'topic', 120, 1);
    const userCode = requireBoundedString(body.userCode, 'userCode', 12_000);
    const expectedAnswer = requireBoundedString(body.expectedAnswer, 'expectedAnswer', 6_000);
    const isCorrect = body.isCorrect;
    if (typeof isCorrect !== 'boolean') {
      throw new RequestError(400, 'Field isCorrect harus berupa boolean.');
    }

    const classId = typeof body.class_id === 'string' ? body.class_id.trim() : null;

    rejectPersonallyIdentifiableInformation(topic, 'topic');
    rejectPersonallyIdentifiableInformation(userCode, 'userCode');
    rejectPersonallyIdentifiableInformation(expectedAnswer, 'expectedAnswer');

    let pdfContextText = '';

    // Fetch max 2 material chunks from class_material_chunks if classId available
    if (supabaseUrl && supabaseServiceKey && classId) {
      const supabase = createClient(supabaseUrl, supabaseServiceKey, { auth: { persistSession: false } });

      const { data: chunkRows } = await supabase
        .from('class_material_chunks')
        .select('content_text, topic_title')
        .eq('class_id', classId)
        .eq('level_id', levelId)
        .order('chunk_order', { ascending: true })
        .limit(2);

      if (chunkRows && chunkRows.length > 0) {
        pdfContextText = chunkRows.map(c => `[Materi Dosen: ${c.topic_title || 'Konsep'}]: ${c.content_text}`).join('\n\n');
      } else {
        // Fallback to materials slide text
        const { data: materialRows } = await supabase
          .from('materials')
          .select('title, content')
          .eq('level_id', levelId)
          .order('slide_order', { ascending: true });

        if (materialRows && materialRows.length > 0) {
          pdfContextText = materialRows.map(m => `[Slide ${m.title}]: ${m.content}`).join('\n\n');
        }
      }
    }

    const systemPrompt = `Kamu mentor pemrograman dasar KODIRA berbahasa Indonesia. Berikan feedback atau hint bertahap yang ramah dan spesifik tentang konsep yang sudah benar dan satu hal yang perlu diperbaiki berdasarkan referensi materi dosen.
Guardrails Penting:
1. JANGAN PERNAH berikan jawaban lengkap atau kode solusi final.
2. JANGAN meminta data pribadi.
3. Berikan hint bertahap secara konseptual.
4. Maksimal 400 karakter.
5. Balas hanya feedback.`;

    const userPrompt = `Topik: ${topic}
Level: ${levelId}
Hasil dinilai benar: ${isCorrect}
Kode mahasiswa:
${userCode || '(belum ada kode)'}
Referensi konsep/jawaban yang diharapkan:
${expectedAnswer}
${pdfContextText ? `\nReferensi Materi Dosen Kelas:\n${pdfContextText}` : ''}`;

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
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt },
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
