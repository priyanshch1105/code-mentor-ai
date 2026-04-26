import React, { memo, useCallback } from 'react';
import UserMessage from './UserMessage';
import AssistantMessage from './AssistantMessage';

const ChatHistory = memo(({ messages, onEditMessage }) => {
  const handleEditMessage = useCallback((index, newContent) => {
    if (onEditMessage) {
      onEditMessage(index, newContent);
    }
  }, [onEditMessage]);

  return (
    <div className="space-y-6">
      {messages.length === 0 ? (
        <div className="min-h-[46vh] flex items-center justify-center">
          <div className="max-w-2xl w-full text-center">
            <div className="text-4xl mb-4">✨</div>
            <h3 className="text-3xl font-semibold mb-2">How can I help you today?</h3>
            <p className="text-sm theme-muted">Ask anything about coding, quizzes, or debugging.</p>
            <div className="mt-8 grid gap-3 sm:grid-cols-2 text-left">
              <div className="theme-surface theme-border border rounded-xl p-4">
                <p className="text-sm font-medium">Debug my Python code</p>
                <p className="text-xs theme-muted mt-1">Find issue and explain fix step-by-step</p>
              </div>
              <div className="theme-surface theme-border border rounded-xl p-4">
                <p className="text-sm font-medium">Create a quiz from this topic</p>
                <p className="text-xs theme-muted mt-1">Generate MCQs with answers and hints</p>
              </div>
              <div className="theme-surface theme-border border rounded-xl p-4">
                <p className="text-sm font-medium">Explain concept in simple words</p>
                <p className="text-xs theme-muted mt-1">Use beginner-friendly analogies</p>
              </div>
              <div className="theme-surface theme-border border rounded-xl p-4">
                <p className="text-sm font-medium">Review my approach</p>
                <p className="text-xs theme-muted mt-1">Suggest cleaner and faster solution</p>
              </div>
            </div>
          </div>
        </div>
      ) : (
        messages.map((msg, i) => (
          <div key={i}>
            {msg.role === 'user' ? (
              <UserMessage
                content={msg.content}
                timestamp={msg.timestamp}
                onEdit={(newContent) => handleEditMessage(i, newContent)}
              />
            ) : (
              <AssistantMessage
                content={msg.content}
                timestamp={msg.timestamp}
              />
            )}
          </div>
        ))
      )}
    </div>
  );
});

ChatHistory.displayName = 'ChatHistory';

export default ChatHistory;