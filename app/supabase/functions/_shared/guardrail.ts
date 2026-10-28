import { RequestError } from './cors.ts';

const MAX_PII_SCAN_LENGTH = 20_000;
const PII_PATTERNS: Array<[string, RegExp]> = [
  ['email', /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i],
  ['nomor telepon', /(?<!\d)(?:\+?62|0)\s?(?:\d[\s.-]?){8,13}\d/],
  ['NIM', /\b\d{10,20}\b/],
];

export function requireBoundedString(
  value: unknown,
  field: string,
  maximum: number,
  minimum = 0,
): string {
  if (typeof value !== 'string') {
    throw new RequestError(400, `Field ${field} harus berupa teks.`);
  }
  const trimmed = value.trim();
  if (trimmed.length < minimum) {
    throw new RequestError(400, `Field ${field} minimal ${minimum} karakter.`);
  }
  if (trimmed.length > maximum) {
    throw new RequestError(400, `Field ${field} maksimal ${maximum} karakter.`);
  }
  return trimmed;
}

export function requireInteger(
  value: unknown,
  field: string,
  minimum: number,
  maximum: number,
): number {
  if (typeof value !== 'number' || !Number.isInteger(value)) {
    throw new RequestError(400, `Field ${field} harus berupa bilangan bulat.`);
  }
  if (value < minimum || value > maximum) {
    throw new RequestError(400, `Field ${field} harus antara ${minimum} dan ${maximum}.`);
  }
  return value;
}

export function rejectPersonallyIdentifiableInformation(
  value: string,
  field: string,
): void {
  if (value.length > MAX_PII_SCAN_LENGTH) {
    throw new RequestError(400, `Field ${field} melebihi batas pemeriksaan.`);
  }
  for (const [description, pattern] of PII_PATTERNS) {
    if (pattern.test(value)) {
      throw new RequestError(400, `Field ${field} tidak boleh memuat ${description}.`);
    }
  }
}

export function requireOneOf<T extends string>(
  value: unknown,
  field: string,
  allowed: readonly T[],
): T {
  if (typeof value !== 'string' || !allowed.includes(value as T)) {
    throw new RequestError(400, `Field ${field} memiliki nilai yang tidak didukung.`);
  }
  return value as T;
}
