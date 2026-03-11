# DealFlow — AI Document Search & Chat (Future Phase)

## Goal
Replace traditional full-text search with vector DB + LLM for semantic search and chat-with-docs.

## Features
1. **Semantic search** — query by meaning, not just keywords (e.g. "对赌条款" finds "估值调整机制")
2. **Chat with documents (RAG)** — ask questions, get answers with source references
3. **Cross-deal comparison** — compare clauses across different deals' documents

## Implementation Approach
- Chunk documents on upload (text extraction from Word/PDF/Excel)
- Generate embeddings via LLM API
- Store in pgvector (PostgreSQL extension) or dedicated vector DB (Pinecone/Qdrant)
- RAG pipeline: retrieve relevant chunks → feed to LLM → return answer with citations

## Dependencies
- Core DMS must be built first (document upload, storage, metadata)
- Chinese text chunking strategy needed (legal document structure awareness)

## Status
- **Phase**: Future (after core DMS v1)
