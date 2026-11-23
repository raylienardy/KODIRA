import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.8';
import { handleOptions, jsonResponse, readJsonObject, RequestError } from '../_shared/cors.ts';
import { rejectPersonallyIdentifiableInformation, requireBoundedString, requireInteger, requireOneOf } from '../_shared/guardrail.ts';

const GROQ_ENDPOINT = 'https://api.groq.com/openai/v1/chat/completions';
const MODEL = 'openai/gpt-oss-120b';
const MAX_QUESTIONS = 10;

interface QuizQuestion {
  question: string;
  options: string[];
  answer: number;
  explanation: string;
}

interface ExerciseQuestion {
  type: 'drag_drop' | 'fill_in_the_blank';
  prompt: string;
  payload: Record<string, unknown>;
  difficulty: number;
  alternative_answers: string[];
}

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
    const language = requireOneOf(body.language, 'language', ['cpp', 'java'] as const);
    const questionCount = body.questionCount === undefined
      ? 5
      : requireInteger(body.questionCount, 'questionCount', 1, MAX_QUESTIONS);
    const context = body.context === undefined
      ? ''
      : requireBoundedString(body.context, 'context', 4_000);
    
    // Optional parameters for adaptive/session-based variation
    const mode = body.mode === 'exercise' ? 'exercise' : 'quiz';
    const classId = typeof body.class_id === 'string' ? body.class_id.trim() : null;
    const userId = typeof body.user_id === 'string' ? body.user_id.trim() : null;
    const sessionNonce = body.session_nonce ? String(body.session_nonce) : Date.now().toString();

    rejectPersonallyIdentifiableInformation(topic, 'topic');
    rejectPersonallyIdentifiableInformation(context, 'context');

    let pdfContextText = '';

    // If Supabase client available and classId/levelId provided, fetch context chunks or material slides
    if (supabaseUrl && supabaseServiceKey && classId) {
      const supabase = createClient(supabaseUrl, supabaseServiceKey, { auth: { persistSession: false } });

      // 1. Fetch max 2 material chunks from class_material_chunks
      const { data: chunkRows } = await supabase
        .from('class_material_chunks')
        .select('content_text, topic_title')
        .eq('class_id', classId)
        .eq('level_id', levelId)
        .order('chunk_order', { ascending: true })
        .limit(2);

      if (chunkRows && chunkRows.length > 0) {
        pdfContextText = chunkRows.map(c => `[${c.topic_title || 'Materi'}]: ${c.content_text}`).join('\n\n');
      } else {
        // Fallback: fetch slide materials for this level
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

    // Optional personalization context from user mastery / past error history
    let studentWeaknessContext = '';
    if (supabaseUrl && supabaseServiceKey && userId) {
      const supabase = createClient(supabaseUrl, supabaseServiceKey, { auth: { persistSession: false } });
      const { data: masteryRows } = await supabase
        .from('user_mastery')
        .select('topic, error_count, mastery_score')
        .eq('user_id', userId)
        .lt('mastery_score', 0.7)
        .order('error_count', { ascending: false })
        .limit(3);

      if (masteryRows && masteryRows.length > 0) {
        studentWeaknessContext = `Mahasiswa memiliki kelemahan di konsep: ${masteryRows.map(m => m.topic).join(', ')}. Buat soal yang melatih konsep ini secara spesifik.`;
      }
    }

    const effectiveContext = [
      pdfContextText ? `Konteks Materi Dosen:\n${pdfContextText}` : '',
      context ? `Konteks Tambahan:\n${context}` : '',
      studentWeaknessContext ? `Profil Mahasiswa:\n${studentWeaknessContext}` : '',
      `Session Nonce / Variasi Sesi: ${sessionNonce}`,
    ].filter(Boolean).join('\n\n');

    const systemPrompt = mode === 'exercise'
      ? `Buat tepat ${questionCount} soal latihan interaktif ('drag_drop' atau 'fill_in_the_blank') untuk pembelajaran pemrograman ${language === 'cpp' ? 'C++' : 'Java'}. Balas sebagai satu objek JSON valid dengan bentuk {"exercises":[{"type":"drag_drop"|"fill_in_the_blank","prompt":"...","payload":{...},"difficulty":1,"alternative_answers":["..."]}]}. Setiap soal wajib punya alternative_answers untuk variasi susunan token setara. Berbahasa Indonesia, ramah, dan unik untuk sesi ini.`
      : `Buat tepat ${questionCount} soal pilihan ganda untuk pembelajaran pemrograman ${language === 'cpp' ? 'C++' : 'Java'} dasar. Balas sebagai satu objek JSON valid dengan bentuk {"questions":[{"question":"...","options":["...","...","...","..."],"answer":0,"explanation":"..."}]}. Setiap soal wajib punya tepat 4 opsi, answer adalah indeks integer 0 sampai 3, dan explanation ringkas. Soal harus sesuai level, unik per sesi, satu jawaban benar, berbahasa Indonesia. Jangan sertakan markdown atau field tambahan. Jangan buat soal yang meminta data pribadi.`;

    const upstream = await fetch(GROQ_ENDPOINT, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: MODEL,
        temperature: 0.7,
        max_tokens: 3_000,
        response_format: { type: 'json_object' },
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: `Level: ${levelId}\nTopik: ${topic}\n${effectiveContext || '(Gunakan pengetahuan pemrograman dasar yang sesuai)'}` },
        ],
      }),
      signal: AbortSignal.timeout(35_000),
    });

    if (!upstream.ok) {
      return jsonResponse({ error: 'Layanan AI gagal membuat soal.' }, 502);
    }

    const content = extractContent(await upstream.json());
    const parsed = parseStrictJson(content);

    if (mode === 'exercise') {
      const exercises = validateExercises(parsed, questionCount);
      return jsonResponse({ exercises });
    } else {
      const questions = validateQuestions(parsed, questionCount);
      return jsonResponse({ questions });
    }
  } catch (error) {
    if (error instanceof RequestError) {
      return jsonResponse({ error: error.message }, error.status);
    }
    if (error instanceof DOMException && error.name === 'TimeoutError') {
      return jsonResponse({ error: 'Pembuatan soal melewati batas waktu.' }, 504);
    }
    return jsonResponse({ error: 'Layanan AI menghasilkan format soal yang tidak valid.' }, 502);
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
  const parsed: unknown = JSON.parse(clean.trim());
  if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) {
    throw new Error('Quiz response must be a JSON object.');
  }
  return parsed;
}

function validateQuestions(value: unknown, expectedCount: number): QuizQuestion[] {
  const questionsValue = (value as { questions?: unknown }).questions;
  if (!Array.isArray(questionsValue) || questionsValue.length !== expectedCount) {
    throw new Error('Generated question count does not match request.');
  }

  const questions: QuizQuestion[] = [];
  for (const item of questionsValue) {
    if (item === null || typeof item !== 'object' || Array.isArray(item)) {
      throw new Error('Question item must be an object.');
    }
    const question = item as Record<string, unknown>;
    if (typeof question.question !== 'string' || !question.question.trim() || question.question.length > 500) {
      throw new Error('Question text is invalid.');
    }
    if (!Array.isArray(question.options) || question.options.length < 2 || question.options.length > 5) {
      throw new Error('Question options are invalid.');
    }
    const options: string[] = [];
    for (const option of question.options) {
      if (typeof option !== 'string' || !option.trim() || option.length > 300) {
        throw new Error('Option text is invalid.');
      }
      rejectPersonallyIdentifiableInformation(option, 'option');
      options.push(option.trim());
    }
    if (typeof question.answer !== 'number' || !Number.isInteger(question.answer) || question.answer < 0 || question.answer >= options.length) {
      throw new Error('Answer index is invalid.');
    }
    if (typeof question.explanation !== 'string' || !question.explanation.trim() || question.explanation.length > 600) {
      throw new Error('Question explanation is invalid.');
    }
    rejectPersonallyIdentifiableInformation(question.question, 'question');
    rejectPersonallyIdentifiableInformation(question.explanation, 'explanation');
    questions.push({
      question: question.question.trim(),
      options,
      answer: question.answer,
      explanation: question.explanation.trim(),
    });
  }
  return questions;
}

function validateExercises(value: unknown, expectedCount: number): ExerciseQuestion[] {
  const exercisesValue = (value as { exercises?: unknown }).exercises;
  if (!Array.isArray(exercisesValue) || exercisesValue.length !== expectedCount) {
    throw new Error('Generated exercise count does not match request.');
  }

  const exercises: ExerciseQuestion[] = [];
  for (const item of exercisesValue) {
    if (item === null || typeof item !== 'object' || Array.isArray(item)) {
      throw new Error('Exercise item must be an object.');
    }
    const exercise = item as Record<string, unknown>;
    const type = exercise.type === 'fill_in_the_blank' ? 'fill_in_the_blank' : 'drag_drop';
    if (typeof exercise.prompt !== 'string' || !exercise.prompt.trim()) {
      throw new Error('Exercise prompt is invalid.');
    }
    if (typeof exercise.payload !== 'object' || exercise.payload === null) {
      throw new Error('Exercise payload is invalid.');
    }
    const difficulty = typeof exercise.difficulty === 'number' ? exercise.difficulty : 1;
    const alternativeAnswers = Array.isArray(exercise.alternative_answers)
      ? exercise.alternative_answers.map(a => String(a).trim()).filter(Boolean)
      : [];

    exercises.push({
      type,
      prompt: exercise.prompt.trim(),
      payload: exercise.payload as Record<string, unknown>,
      difficulty,
      alternative_answers: alternativeAnswers,
    });
  }
  return exercises;
}
