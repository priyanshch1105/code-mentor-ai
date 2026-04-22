# API Documentation

## Base URL

```
http://localhost:8000/api
```

## Authentication

All endpoints (except `/auth/login` and `/auth/register`) require JWT token in header:

```
Authorization: Bearer {token}
```

## Endpoints

### Authentication

#### Register
```
POST /auth/register
Content-Type: application/json

{
  "username": "user123",
  "email": "user@example.com",
  "password": "password123"
}

Response: 201
{
  "message": "User registered successfully"
}
```

#### Login
```
POST /auth/login
Content-Type: application/x-www-form-urlencoded

username=user123&password=password123

Response: 200
{
  "access_token": "eyJ0eXAi...",
  "token_type": "bearer"
}
```

### Chat

#### Create Session
```
POST /chat/sessions
Content-Type: application/json

{
  "subject": "coding",
  "session_name": "Python Basics"
}

Response: 201
{
  "id": "uuid",
  "subject": "coding",
  "session_name": "Python Basics"
}
```

#### Send Message
```
POST /chat/messages
Content-Type: application/json

{
  "session_id": "uuid",
  "content": "How do I sort a list in Python?"
}

Response: 200
{
  "id": "uuid",
  "user_message": "How do I sort a list in Python?",
  "ai_response": "You can use the sorted() function...",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

#### Get Session Messages
```
GET /chat/sessions/{session_id}/messages?page=1&limit=20

Response: 200
{
  "messages": [
    {
      "id": "uuid",
      "role": "user",
      "content": "...",
      "timestamp": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 5,
  "page": 1
}
```

### Quiz

#### Create Quiz
```
POST /quiz/create
Content-Type: application/json

{
  "subject": "coding",
  "difficulty": "beginner",
  "num_questions": 10
}

Response: 201
{
  "quiz_id": "uuid",
  "questions": [...]
}
```

#### Submit Quiz
```
POST /quiz/{quiz_id}/submit
Content-Type: application/json

{
  "answers": {
    "question_1": "answer_text",
    "question_2": "B"
  }
}

Response: 200
{
  "score": 85,
  "passed": true,
  "analysis": "..."
}
```

### Recommendations

#### Get Recommendations
```
GET /recommend/?subject=coding

Response: 200
{
  "recommendations": "Focus on error handling...",
  "progress": {
    "coding": 45,
    "math": 30
  }
}
```

## Error Responses

```
400 Bad Request
{
  "detail": "Invalid input"
}

401 Unauthorized
{
  "detail": "Authentication required"
}

500 Internal Server Error
{
  "detail": "Server error"
}
```

## Rate Limiting

- 100 requests per minute per user
- WebSocket connections: 10 per user

## Pagination

```
GET /endpoint?page=1&limit=20

Response headers:
X-Total-Count: 100
X-Page: 1
X-Limit: 20
```

## Interactive API Documentation

Visit `http://localhost:8000/docs` for Swagger UI
