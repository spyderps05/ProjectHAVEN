export type HavenOllamaModel = {
  id: string
  name: string
  description: string
  estimated_pulls: string
  model_last_updated: string
  first_seen: string
  tags: HavenOllamaModelTag[]
}

export type HavenOllamaModelTag = {
  name: string
  size: string
  context: string
  input: string
  cloud: boolean
  thinking: boolean
}

export type HavenOllamaModelAPIResponse = {
  success: boolean
  message: string
  models: HavenOllamaModel[]
}

export type OllamaChatMessage = {
  role: 'system' | 'user' | 'assistant'
  content: string
}

export type OllamaChatRequest = {
  model: string
  messages: OllamaChatMessage[]
  stream?: boolean
  sessionId?: number
}

export type OllamaChatResponse = {
  model: string
  created_at: string
  message: {
    role: string
    content: string
  }
  done: boolean
}
