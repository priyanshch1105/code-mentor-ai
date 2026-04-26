// src/components/MessageBar.jsx (Enhanced with better UI and functionality)
import React, { useState } from 'react';
import { Send, Paperclip } from 'lucide-react';
import { toast } from 'react-toastify';
import VoiceInput from './VoiceInput';

const MessageBar = ({ input, setInput, sendMessage }) => {
  const [isTyping, setIsTyping] = useState(false);
  
  const handleVoiceTranscript = (transcript) => {
    setInput(transcript);
    setIsTyping(true);
    // Removed toast notification - user doesn't want toast here
  };

  const handleSend = async () => {
    if (input.trim()) {
      const messageText = input.trim();
      setInput(''); // Clear input immediately
      try {
        await sendMessage(messageText);
      } catch (error) {
        // Check if it's a quota exceeded error
        if (error.response?.data?.response?.includes('high demand') || 
            error.response?.data?.response?.includes('quota exceeded') ||
            error.response?.data?.response?.includes('429')) {
          toast.info('API quota exceeded. You\'re getting helpful fallback responses from our knowledge base!');
        }
      }
    }
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <div className="pt-2">
      <div className="theme-surface theme-border border rounded-3xl px-2 py-2 lg:px-3 lg:py-3 shadow-sm">
        <div className="flex items-end space-x-2 lg:space-x-3">
        {/* Attachment Button */}
        <button className="p-2 theme-muted hover:opacity-75 hover:bg-black/5 rounded-lg transition-colors">
          <Paperclip size={18} className="lg:w-5 lg:h-5" />
        </button>

        {/* Voice Input Button */}
        <VoiceInput onTranscript={handleVoiceTranscript} disabled={false} />

        {/* Text Input */}
        <div className="flex-1 relative">
          <textarea
            value={input}
            onChange={(e) => {
              setInput(e.target.value);
              setIsTyping(e.target.value.length > 0);
            }}
            onKeyPress={handleKeyPress}
            className="w-full p-2 lg:p-3 bg-transparent rounded-lg theme-text placeholder:text-slate-500 focus:outline-none resize-none min-h-[40px] lg:min-h-[44px] max-h-32 text-sm lg:text-base"
            placeholder="Type your message or paste code..."
            rows={1}
            style={{
              height: 'auto',
              minHeight: '40px',
              maxHeight: '128px'
            }}
            onInput={(e) => {
              e.target.style.height = 'auto';
              e.target.style.height = Math.min(e.target.scrollHeight, 128) + 'px';
            }}
          />
        </div>

        {/* Send Button */}
        <button 
          onClick={handleSend}
          disabled={!input.trim()}
          className="p-2 lg:p-3 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 disabled:from-gray-500 disabled:to-gray-600 rounded-xl text-white transition-all duration-200 flex items-center justify-center shadow-sm"
        >
          <Send size={18} className="lg:w-5 lg:h-5" />
        </button>
      </div>

      {/* Helper Text */}
      <div className="mt-2 text-xs theme-muted text-center">
        Press Enter to send • Shift+Enter for new line
      </div>
      </div>
    </div>
  );
};

export default MessageBar;