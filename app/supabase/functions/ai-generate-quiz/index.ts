import { handleOptions, jsonResponse, readJsonObject, RequestError } from '../_shared/cors.ts';
import { rejectPersonallyIdentifiableInformation, requireBoundedString, requireInteger, requireOneOf } from '../_shared/guardrail.ts';

const GROQ_ENDPOINT = 'https://api.groq.com/openai/v1/chat/completions';
const MODEL = 'openai/gpt-oss-120b';
const MAX_QUESTIONS = 10;
const MAX_OPTIONS = 5;

interface QuizQuestion {
  question: string;
  options: string[];
  answer: number;
  explanation: string;
}

Deno.serve(async (request: Request): Promise<Response> => {
  const methodResponse = handleOptions(request);
  if (methodResponse) return methodResponse;

  try {
    const apiKey = Deno.env.get('GROQ_API_KEY');
    if (!apiKey) return jsonResponse({ error: 'Layanan AI belum dikonfigurasi.' }, 503);

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
    rejectPersonallyIdentifiableInformation(topic, 'topic');
    rejectPersonallyIdentifiableInformation(context, 'context');

    const upstream = await fetch(GROQ_ENDPOINT, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: MODEL,
        temperature: 0.45,
        max_tokens: 2_500,
        response_format: { type: 'json_object' },
        messages: [
          {
            role: 'system',
            content: `Buat tepat ${questionCount} soal pilihan ganda untuk pembelajaran pemrograman ${language === 'cpp' ? 'C++' : 'Java'} dasar. Balas sebagai satu objek JSON valid dengan bentuk {"questions":[{"question":"...","options":["...","...","...","..."],"answer":0,"explanation":"..."}]}. Setiap soal wajib punya tepat 4 opsi, answer adalah indeks integer 0 sampai 3, dan explanation ringkas. Soal harus sesuai level, unik, satu jawaban benar, berbahasa Indonesia. Jangan sertakan markdown atau field tambahan. Jangan buat soal yang meminta data pribadi.`,
          },
          {
            role: 'user',
            content: `Level: ${levelId}\nTopik: ${topic}\nKonteks pembelajaran:\n${context || '(gunakan pengetahuan pemrograman dasar yang sesuai topik)'}`,
          },
        ],
      }),
      signal: AbortSignal.timeout(35_000),
    });
    if (!upstream.ok) {
      return jsonResponse({ error: 'Layanan AI gagal membuat soal.' }, 502);
    }

    const content = extractContent(await upstream.json());
    const parsed = parseStrictJson(content);
    const questions = validateQuestions(parsed, questionCount);
    return jsonResponse({ questions });
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
  if (!trimmed || trimmed.startsWith('```') || trimmed.endsWith('```')) {
    throw new Error('Model response is not raw JSON.');
  }
  const parsed: unknown = JSON.parse(trimmed);
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
    if (!Array.isArray(question.options) || question.options.length < 2 || question.options.length > MAX_OPTIONS) {
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
