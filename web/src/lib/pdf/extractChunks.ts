import * as pdfjs from 'pdfjs-dist'
import type { PDFDocumentProxy } from 'pdfjs-dist'

export interface MaterialChunk {
  chunk_order: number
  topic_title: string
  content_text: string
  keywords: string[]
}

const TARGET_WORDS_PER_CHUNK = 500
const MIN_WORDS_PER_CHUNK = 400
const MAX_WORDS_PER_CHUNK = 600
const TOPIC_TITLE_MAX_CHARS = 120

/**
 * Konfigurasi worker pdfjs-dist agar aman dijalankan di sisi klien
 * Next.js (client component). Worker di-bundle oleh webpack sehingga
 * tidak perlu unggah file PDF apa pun ke server.
 */
function configureWorker(): void {
  try {
    pdfjs.GlobalWorkerOptions.workerSrc = new URL(
      'pdfjs-dist/build/pdf.worker.min.mjs',
      import.meta.url,
    ).toString()
  } catch {
    // Fallback: jatuhkan ke fake worker (main thread). Tetap aman karena
    // tidak ada file biner yang dikirim ke server, hanya diproses di browser.
    pdfjs.GlobalWorkerOptions.workerSrc = ''
  }
}

function extractIdentifiersFromText(text: string): string[] {
  const identifiers = new Set<string>()
  const words = text.match(/[A-Za-z_][A-Za-z0-9_]*/g) || []

  for (const word of words) {
    if (word.length >= 2 && word.length <= 24) {
      identifiers.add(word.toLowerCase())
    }
  }

  const keywords = Array.from(identifiers)
  // Urutkan berdasarkan panjang identifier untuk memberi bobot pada
  // kata teknis (int, double, while, class, dll).
  keywords.sort((a, b) => b.length - a.length)
  return keywords.slice(0, 15)
}

function buildTopicTitle(chunkText: string, keywords: string[]): string {
  const lines = chunkText
    .split('\n')
    .map((line) => line.replace(/\s+/g, ' ').trim())
    .filter(Boolean)

  if (lines.length > 0) {
    const firstLine = lines[0].slice(0, TOPIC_TITLE_MAX_CHARS)
    if (firstLine.length >= 4) {
      return firstLine
    }
  }

  if (keywords.length > 0) {
    const joined = keywords.slice(0, 3).join(', ')
    return `Topik: ${joined}`.slice(0, TOPIC_TITLE_MAX_CHARS)
  }

  return 'Materi Modul Kuliah'.slice(0, TOPIC_TITLE_MAX_CHARS)
}

function splitWordsIntoChunks(
  words: string[],
  chunkOrderStart: number,
): MaterialChunk[] {
  const chunks: MaterialChunk[] = []
  let currentBatch: string[] = []
  let order = chunkOrderStart

  for (const word of words) {
    currentBatch.push(word)

    if (currentBatch.length >= TARGET_WORDS_PER_CHUNK) {
      const text = currentBatch.join(' ').trim()
      const keywords = extractIdentifiersFromText(text)
      chunks.push({
        chunk_order: order,
        topic_title: buildTopicTitle(text, keywords),
        content_text: text,
        keywords,
      })
      order += 1
      currentBatch = []
    }
  }

  if (currentBatch.length > 0) {
    // Gabung sisa kata dengan chunk terakhir jika masih terlalu kecil,
    // atau simpan sebagai chunk baru jika melebihi batas minimum.
    const remainingWords = currentBatch
    const previous = chunks[chunks.length - 1]

    if (
      previous &&
      remainingWords.length < MIN_WORDS_PER_CHUNK &&
      previous.content_text.split(' ').length + remainingWords.length <= MAX_WORDS_PER_CHUNK
    ) {
      const mergedText = `${previous.content_text} ${remainingWords.join(' ')}`.trim()
      const keywords = extractIdentifiersFromText(mergedText)
      chunks[chunks.length - 1] = {
        ...previous,
        topic_title: buildTopicTitle(mergedText, keywords),
        content_text: mergedText,
        keywords,
      }
    } else if (remainingWords.length >= MIN_WORDS_PER_CHUNK) {
      const text = remainingWords.join(' ').trim()
      const keywords = extractIdentifiersFromText(text)
      chunks.push({
        chunk_order: order,
        topic_title: buildTopicTitle(text, keywords),
        content_text: text,
        keywords,
      })
      order += 1
    }
  }

  return chunks
}

async function getDocumentFromPdf(file: File): Promise<PDFDocumentProxy> {
  const arrayBuffer = await file.arrayBuffer()
  return pdfjs.getDocument({
    data: new Uint8Array(arrayBuffer),
  }).promise
}

async function extractTextFromDocument(doc: PDFDocumentProxy): Promise<string> {
  const pageTexts: string[] = []

  for (let pageNumber = 1; pageNumber <= doc.numPages; pageNumber++) {
    const page = await doc.getPage(pageNumber)
    const textContent = await page.getTextContent()

    const pageWords: string[] = []
    for (const item of textContent.items) {
      if ('str' in item && typeof item.str === 'string') {
        const cleaned = item.str.replace(/\s+/g, ' ').trim()
        if (cleaned) {
          pageWords.push(cleaned)
        }
      }
    }

    if (pageWords.length > 0) {
      pageTexts.push(pageWords.join(' '))
    }
  }

  return pageTexts.join('\n\n').replace(/[ \t]+/g, ' ').replace(/\n{3,}/g, '\n\n').trim()
}

/**
 * Membaca file PDF di sisi browser, mengekstrak teksnya, lalu memecahnya
 * menjadi potongan teks (chunks) ±400–600 kata.
 *
 * File PDF TIDAK pernah diunggah atau disimpan ke Supabase Storage /
 * database. Hanya teks hasil ekstraksi yang dijadikan output.
 */
export async function extractChunksFromFile(
  file: File,
): Promise<MaterialChunk[]> {
  if (typeof window === 'undefined') {
    throw new Error('Ekstraksi PDF hanya dapat dijalankan di browser.')
  }

  if (!file.name.toLowerCase().endsWith('.pdf') && file.type !== 'application/pdf') {
    throw new Error('File harus berupa PDF.')
  }

  configureWorker()

  let doc: PDFDocumentProxy | null = null
  try {
    doc = await getDocumentFromPdf(file)
    const fullText = await extractTextFromDocument(doc)

    if (!fullText || fullText.trim().length === 0) {
      throw new Error('PDF tidak memuat teks yang dapat diekstrak.')
    }

    const words = fullText.split(/\s+/).filter(Boolean)
    if (words.length === 0) {
      throw new Error('PDF tidak memuat teks yang dapat diekstrak.')
    }

    return splitWordsIntoChunks(words, 1)
  } catch (error) {
    if (error instanceof Error) {
      throw new Error(`Gagal mengekstrak PDF: ${error.message}`)
    }
    throw new Error('Gagal mengekstrak PDF.')
  } finally {
    if (doc) {
      await doc.cleanup()
    }
  }
}
