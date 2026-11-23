import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.8';
import { handleOptions, jsonResponse, readJsonObject, RequestError } from '../_shared/cors.ts';
import { rejectPersonallyIdentifiableInformation, requireBoundedString, requireInteger, requireOneOf } from '../_shared/guardrail.ts';

const GROQ_ENDPOINT = 'https://api.groq.com/openai/v1/chat/completions';
const MODEL = 'openai/gpt-oss-120b';

interface ChunkInput {
  chunk_order: number;
  topic_title?: string;
  content_text: string;
  keywords?: string[];
}

interface ExistingLevel {
  id: number;
  level_number: number;
  title: string;
  topic: string | null;
  difficulty: number | null;
}

interface MaterialInput {
  slide_order: number;
  title: string;
  content: string;
  code_snippet?: string;
}

interface ExerciseInput {
  type: 'drag_drop' | 'fill_in_the_blank' | 'multiple_choice';
  prompt: string;
  payload: Record<string, unknown>;
  difficulty: number;
  alternative_answers?: string[];
}

interface TopicPlan {
  chunk_indices: number[];
  action: 'attach' | 'insert';
  existing_level_id?: number;
  target_level_number?: number;
  title?: string;
  description?: string;
  topic?: string;
  difficulty?: number;
  materials?: MaterialInput[];
  exercises?: ExerciseInput[];
}

Deno.serve(async (request: Request): Promise<Response> => {
  const methodResponse = handleOptions(request);
  if (methodResponse) return methodResponse;

  try {
    const apiKey = Deno.env.get('GROQ_API_KEY');
    if (!apiKey) return jsonResponse({ error: 'Layanan AI belum dikonfigurasi.' }, 503);

    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    if (!supabaseUrl || !supabaseServiceKey) {
      return jsonResponse({ error: 'Supabase client belum dikonfigurasi.' }, 500);
    }

    const authHeader = request.headers.get('Authorization');
    if (!authHeader) {
      return jsonResponse({ error: 'Header Authorization diperlukan.' }, 401);
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { persistSession: false },
    });

    // Verify JWT
    const token = authHeader.replace('Bearer ', '').trim();
    const { data: { user }, error: userError } = await supabase.auth.getUser(token);
    if (userError || !user) {
      return jsonResponse({ error: 'Pengguna tidak terautentikasi atau token kadaluwarsa.' }, 401);
    }

    const body = await readJsonObject(request);
    const classId = requireBoundedString(body.class_id, 'class_id', 36, 36);
    const sourceTitle = requireBoundedString(body.source_title, 'source_title', 255, 1);
    const language = requireOneOf(body.language, 'language', ['cpp', 'java'] as const);

    if (!Array.isArray(body.chunks) || body.chunks.length === 0) {
      throw new RequestError(400, 'Field chunks harus berupa array yang tidak kosong.');
    }

    // Verify User is Teacher in this class
    const { data: teacherRow, error: teacherError } = await supabase
      .from('class_teachers')
      .select('id')
      .eq('class_id', classId)
      .eq('teacher_id', user.id)
      .maybeSingle();

    if (teacherError || !teacherRow) {
      return jsonResponse({ error: 'Anda bukan pengajar di kelas ini.' }, 403);
    }

    // Parse and validate chunks
    const chunks: ChunkInput[] = [];
    for (let i = 0; i < body.chunks.length; i++) {
      const item = body.chunks[i];
      if (typeof item !== 'object' || item === null) {
        throw new RequestError(400, `Chunk indeks ${i} tidak valid.`);
      }
      const raw = item as Record<string, unknown>;
      const chunkOrder = requireInteger(raw.chunk_order, `chunks[${i}].chunk_order`, 1, 1000);
      const contentText = requireBoundedString(raw.content_text, `chunks[${i}].content_text`, 20000, 10);
      rejectPersonallyIdentifiableInformation(contentText, `chunks[${i}].content_text`);

      const topicTitle = typeof raw.topic_title === 'string' ? raw.topic_title.trim().slice(0, 120) : undefined;
      const keywords = Array.isArray(raw.keywords) ? raw.keywords.map(k => String(k).trim()).filter(Boolean) : [];

      chunks.push({
        chunk_order: chunkOrder,
        topic_title: topicTitle,
        content_text: contentText,
        keywords,
      });
    }

    // Fetch Existing Levels for Class
    const { data: existingLevelsData } = await supabase
      .from('levels')
      .select('id, level_number, title, topic, difficulty')
      .eq('class_id', classId)
      .order('level_number', { ascending: true });

    const existingLevels: ExistingLevel[] = existingLevelsData || [];

    // Call Groq API to Map Chunks & Generate Draft Curriculum
    const upstreamPrompt = `Anda adalah instruktur kurikulum pemrograman ${language === 'cpp' ? 'C++' : 'Java'}.
Diberikan daftar level eksisting di kelas ini dan daftar potongan materi (chunks) dari PDF dosen.

Level eksisting di kelas ini:
${JSON.stringify(existingLevels, null, 2)}

Daftar potongan materi PDF:
${JSON.stringify(chunks.map((c, idx) => ({ index: idx, chunk_order: c.chunk_order, topic_title: c.topic_title, snippet: c.content_text.slice(0, 300) })), null, 2)}

Tugas Anda:
1. Kelompokkan chunks berdasarkan kesamaan topik.
2. Untuk setiap kelompok topik:
   - Jika topik sudah tercakup oleh level eksisting, buat action "attach" dengan "existing_level_id".
   - Jika topik baru, buat action "insert" dengan menentukan "target_level_number", "title", "description", "topic", "difficulty" (1-5), serta susun:
     * Tepat 5 slide materi (materials) yang memuat slide_order (1-5), title, content, dan code_snippet (opsional).
     * Tepat 5 soal latihan (exercises) yang memuat type ('drag_drop' atau 'fill_in_the_blank'), prompt, payload (objek JSON valid), difficulty (1-3), dan alternative_answers (array string variasi jawaban setara).
     * Tepat 3 soal kuis (exercises) yang memuat type 'multiple_choice', prompt, payload (objek JSON valid dengan options, answer 0-3, explanation), dan difficulty (1-3).

Balas HANYA satu objek JSON valid dengan struktur:
{
  "plans": [
    {
      "chunk_indices": [0],
      "action": "attach",
      "existing_level_id": 12
    },
    {
      "chunk_indices": [1, 2],
      "action": "insert",
      "target_level_number": 3,
      "title": "...",
      "description": "...",
      "topic": "...",
      "difficulty": 1,
      "materials": [
        {"slide_order": 1, "title": "...", "content": "...", "code_snippet": "..."}
      ],
      "exercises": [
        {
          "type": "drag_drop",
          "prompt": "...",
          "payload": {"tokens": [{"id": "t1", "text": "..."}], "answer": ["t1"]},
          "difficulty": 1,
          "alternative_answers": ["int x = 5;"]
        }
      ]
    }
  ]
}`;

    const upstream = await fetch(GROQ_ENDPOINT, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: MODEL,
        temperature: 0.3,
        max_tokens: 4000,
        response_format: { type: 'json_object' },
        messages: [
          { role: 'system', content: 'Balas hanya objek JSON valid sesuai instruksi.' },
          { role: 'user', content: upstreamPrompt },
        ],
      }),
      signal: AbortSignal.timeout(60_000),
    });

    if (!upstream.ok) {
      return jsonResponse({ error: 'Gagal menghubungi AI untuk memproses PDF.' }, 502);
    }

    const upstreamJson = await upstream.json();
    const content = extractContent(upstreamJson);
    const parsed = parseStrictJson(content) as { plans?: TopicPlan[] };

    if (!Array.isArray(parsed.plans) || parsed.plans.length === 0) {
      return jsonResponse({ error: 'AI tidak menghasilkan rencana pemrosesan PDF.' }, 502);
    }

    let processedChunks = 0;
    let createdLevels = 0;
    let attachedLevels = 0;
    const finalLevelsSummary: Array<{ id: number; level_number: number; title: string }> = [];

    for (const plan of parsed.plans) {
      if (plan.action === 'attach' && plan.existing_level_id) {
        // Attach chunks to existing level
        for (const idx of plan.chunk_indices) {
          const chunk = chunks[idx];
          if (!chunk) continue;

          await supabase.from('class_material_chunks').insert({
            class_id: classId,
            level_id: plan.existing_level_id,
            source_title: sourceTitle,
            chunk_order: chunk.chunk_order,
            topic_title: chunk.topic_title || 'Materi PDF',
            content_text: chunk.content_text,
            keywords: chunk.keywords || [],
          });
          processedChunks++;
        }
        attachedLevels++;
      } else if (plan.action === 'insert' && plan.target_level_number && plan.title) {
        // Check if level_number collides with existing level_number
        const targetNum = plan.target_level_number;
        const existsCollision = existingLevels.some(l => l.level_number >= targetNum);

        if (existsCollision) {
          // Shift existing levels down using RPC shift_class_levels
          const { error: shiftError } = await supabase.rpc('shift_class_levels', {
            p_class_id: classId,
            p_from_level_number: targetNum,
            p_delta: 1,
          });
          if (shiftError) {
            console.error('Error shifting levels:', shiftError);
          }
        }

        // Insert new level
        const { data: newLevel, error: levelErr } = await supabase
          .from('levels')
          .insert({
            class_id: classId,
            level_number: targetNum,
            title: plan.title,
            description: plan.description || '',
            topic: plan.topic || plan.title,
            language: language,
            difficulty: plan.difficulty || 1,
          })
          .select('id, level_number, title')
          .single();

        if (levelErr || !newLevel) {
          console.error('Error creating new level:', levelErr);
          continue;
        }

        createdLevels++;
        finalLevelsSummary.push(newLevel);

        // Insert 5 slide materials
        if (Array.isArray(plan.materials) && plan.materials.length > 0) {
          const materialsToInsert = plan.materials.map(m => ({
            level_id: newLevel.id,
            slide_order: m.slide_order,
            title: m.title,
            content: m.content,
            code_snippet: m.code_snippet || null,
          }));
          await supabase.from('materials').insert(materialsToInsert);
        }

        // Insert exercises & quizzes
        if (Array.isArray(plan.exercises) && plan.exercises.length > 0) {
          const exercisesToInsert = plan.exercises.map(e => ({
            level_id: newLevel.id,
            type: e.type,
            prompt: e.prompt,
            payload: e.payload,
            difficulty: e.difficulty || 1,
            alternative_answers: e.alternative_answers || [],
          }));
          await supabase.from('exercises').insert(exercisesToInsert);
        }

        // Attach associated chunks to new level
        for (const idx of plan.chunk_indices) {
          const chunk = chunks[idx];
          if (!chunk) continue;

          await supabase.from('class_material_chunks').insert({
            class_id: classId,
            level_id: newLevel.id,
            source_title: sourceTitle,
            chunk_order: chunk.chunk_order,
            topic_title: chunk.topic_title || plan.title,
            content_text: chunk.content_text,
            keywords: chunk.keywords || [],
          });
          processedChunks++;
        }
      }
    }

    return jsonResponse({
      success: true,
      processed_chunks: processedChunks,
      created_levels: createdLevels,
      attached_levels: attachedLevels,
      levels: finalLevelsSummary,
    });
  } catch (error) {
    if (error instanceof RequestError) {
      return jsonResponse({ error: error.message }, error.status);
    }
    if (error instanceof DOMException && error.name === 'TimeoutError') {
      return jsonResponse({ error: 'Pemrosesan PDF melewati batas waktu.' }, 504);
    }
    return jsonResponse({ error: 'Terjadi kesalahan saat memproses PDF.' }, 500);
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

function parseStrictJson(content: string): unknown {
  const trimmed = content.trim();
  let clean = trimmed;
  if (clean.startsWith('```json')) {
    clean = clean.slice(7);
  }
  if (clean.startsWith('```')) {
    clean = clean.slice(3);
  }
  if (clean.endsWith('```')) {
    clean = clean.slice(0, -3);
  }
  const parsed = JSON.parse(clean.trim());
  if (parsed === null || typeof parsed !== 'object') {
    throw new Error('Response is not a valid JSON object.');
  }
  return parsed;
}
