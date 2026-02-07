import React from 'react'
import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'

export default function RemarkViewer({ content, className = '' }) {
  return (
    <article className={`prose prose-invert prose-lg max-w-none prose-headings:text-white prose-p:text-white prose-li:text-white prose-strong:text-white prose-td:text-white prose-th:text-white prose-a:text-blue-400 ${className}`}>
      <ReactMarkdown remarkPlugins={[remarkGfm]}>
        {content}
      </ReactMarkdown>
    </article>
  )
}
