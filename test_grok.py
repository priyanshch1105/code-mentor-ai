#!/usr/bin/env python3
import os
import sys
sys.path.insert(0, 'backend')

from dotenv import load_dotenv
load_dotenv('backend/.env')

from openai import OpenAI

api_key = os.getenv('GROQ_API_KEY')
print(f'API Key: {api_key[:20]}...' if api_key else 'NO API KEY')
print(f'API Key Length: {len(api_key) if api_key else 0}')

try:
    client = OpenAI(api_key=api_key, base_url='https://api.groq.com/openai/v1')
    
    # Try to list models
    print('\nListing available models...')
    models = client.models.list()
    print(f'Found {len(models.data)} models:')
    for model in models.data:
        print(f'  - {model.id}')
        
    # Test a simple completion
    print('\nTesting API call...')
    response = client.chat.completions.create(
        model='llama-3.1-8b-instant',
        messages=[{'role': 'user', 'content': 'Hello, who are you?'}],
        max_tokens=50
    )
    print('✅ Groq API is working!')
    print(f'Response: {response.choices[0].message.content[:100]}...')
        
except Exception as e:
    error_msg = str(e)
    print(f'\n❌ Error: {error_msg}')
    if 'Unauthorized' in error_msg or '401' in error_msg:
        print('⚠️ API Key is INVALID or EXPIRED')
    elif 'quota' in error_msg.lower():
        print('⚠️ API Quota exceeded')
