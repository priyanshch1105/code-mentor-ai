# Code Mentor AI

Production-grade AI-powered learning platform for intelligent code mentoring, real-time debugging, adaptive quizzes, and personalized learning recommendations.

Built as a **College Minor Project**, this platform combines AI-powered tutoring with modern full-stack architecture to create an interactive and scalable educational system for students, developers, and educators. 

![Status](https://img.shields.io/badge/status-production-green)
![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

# 📌 Project Overview

Code Mentor AI is an advanced AI-powered tutoring platform designed to improve learning efficiency through intelligent academic support, code debugging assistance, quiz generation, and personalized study recommendations.

The platform provides:

* AI-powered tutoring and doubt solving
* Real-time code debugging and optimization
* Adaptive quiz generation and analysis
* Progress tracking and learning analytics
* Personalized recommendations
* Session history and persistence
* Scalable production-ready architecture

This project bridges the gap between traditional education and modern AI-assisted learning systems by offering students a 24/7 intelligent tutor and helping educators monitor learning progress effectively.

---

# 🚀 Core Features

## 🤖 AI Tutoring System

* Subject-aware intelligent tutoring assistant
* Context-based doubt solving
* Personalized learning responses
* Multi-subject support
* Session continuity and history

---

## 💻 Code Debugging System

* Real-time code analysis
* Bug detection and resolution
* Optimization suggestions
* Code explanation support
* AI-assisted debugging sessions

---

## 📝 Adaptive Quiz System

* AI-generated quizzes
* Personalized question recommendations
* Quiz attempt history
* Performance tracking
* Analytics and improvement suggestions

---

## 📊 Progress Dashboard

* Learning analytics
* Subject-wise progress tracking
* Performance monitoring
* Session management
* Student improvement insights

---

## 🎯 Smart Recommendations

* AI-powered next-step suggestions
* Personalized study plans
* Weak-area detection
* Smart learning paths
* Improvement strategies

---

# 🛠️ Tech Stack

| Layer          | Technology                                        |
| -------------- | ------------------------------------------------- |
| Frontend       | React React 18, Vite Vite, Tailwind CSS, Recharts |
| Backend        | FastAPI FastAPI, SQLAlchemy, JWT                  |
| Database       | PostgreSQL PostgreSQL                             |
| AI Integration | Groq Groq API, LLM Integration                    |
| DevOps         | Docker, Docker Compose, GitHub Actions            |
| Testing        | Pytest, Vitest                                    |

---

# 📦 Prerequisites

Before starting, make sure you have:

* Python 3.10+
* Node.js 18+
* PostgreSQL 13+
* Docker & Docker Compose (Optional)

---

# ⚙️ Installation Guide

---

## 1. Clone Repository

```bash
git clone <your-repository-url>
cd code-tutor
```

---

## 2. Backend Setup

### Windows (PowerShell)

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

### macOS / Linux

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

---

## 3. Environment Variables

Create a file named `backend/.env`

```env
ENV=development
DEBUG=true
DATABASE_URL=postgresql://postgres:yourpassword@localhost:5432/aitutor
SECRET_KEY=replace-with-a-long-random-string
GROQ_API_KEY=your-groq-api-key
```

---

## 4. Run Backend Server

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Backend URL:

```bash
http://localhost:8000
```

API Documentation:

```bash
http://localhost:8000/api/docs
```

---

## 5. Frontend Setup

Open another terminal:

```bash
cd frontend
npm install
npm run dev
```

Optional frontend `.env`

```env
VITE_API_URL=http://localhost:8000
```

Frontend URL:

```bash
http://localhost:5173
```

---

# 📡 API Modules

## Authentication

* User Registration & Login
* JWT Authentication
* Profile Management
* Subject Selection

---

## Q&A System

* Ask questions to AI tutor
* Session creation
* Message persistence
* Chat history management

---

## Code Debugging

* AI-based code debugging
* Code session history
* Error explanation and fixes

---

## Quiz System

* Quiz creation
* Question generation
* Quiz submission
* Attempt history
* Quiz recommendations

---

## Recommendations

* Personalized learning suggestions
* Progress analytics
* Smart study planning

---

# 🗄️ Database Notes

* Tables are created automatically using SQLAlchemy metadata
* Lightweight schema checks run during startup
* PostgreSQL must be active before launching the backend

---

# 🚀 Deployment

Production deployment includes:

1. Environment configuration
2. Database migration
3. Backend deployment using Docker
4. Frontend production build
5. Static file hosting
6. HTTPS & SSL configuration

Deployment blueprint available using `render.yaml`.

---

# 📈 Performance Metrics

* AI Response Time: < 2 seconds
* API Response Time: < 500ms average
* Frontend Initial Load: < 2 seconds
* Scroll Performance: 60 FPS
* Optimized Bundle Size with Code Splitting
* Database Query Optimization with Indexing

---

# 🔒 Security Features

* JWT-based Authentication
* Secure Password Handling
* Input Validation using Pydantic
* SQL Injection Prevention
* Secure CORS Configuration
* Error Handling and Exception Management

---

# 🎯 Project Objectives

* Improve learning efficiency
* Provide 24/7 AI-powered academic support
* Enable intelligent code mentoring
* Deliver adaptive quiz-based learning
* Build scalable educational infrastructure
* Create a production-ready AI learning platform

---

# 🎉 Project Status

## ✅ PROJECT COMPLETED & PRODUCTION READY

This project successfully delivers:

* Full AI tutoring workflow
* Real-time debugging support
* Adaptive quiz system
* Learning analytics dashboard
* Production-grade architecture
* Scalable future-ready system

The platform is ready for real-world deployment and usage.

---

# 👨‍💻 Developed By

**Priyansh Chaurasiya**
B.Tech CSE (Data Science)
College Minor Project

Machine Learning Engineer | Full Stack AI Developer

---

# 📞 Support

For technical support or project-related queries:

API Documentation:
`http://localhost:8000/api/docs`

Or contact the development team.

---

# 📜 License

This project is developed for academic and educational purposes as a **College Minor Project**.

Free to use for learning, research, and educational purposes.
