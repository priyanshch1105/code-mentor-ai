#!/usr/bin/env python3
"""
Database Migration Script for AI Tutor Platform
This script handles database schema updates for production deployment.
"""

import os
import sys
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
from dotenv import load_dotenv
from pathlib import Path

# Load environment variables from backend/.env
env_path = Path(__file__).parent.parent / "backend" / ".env"
load_dotenv(env_path)

def get_db_connection():
    """Get database connection using environment variables."""
    try:
        db_password = os.getenv('DB_PASSWORD')
        if not db_password:
            raise ValueError("DB_PASSWORD environment variable not set")
        
        connection = psycopg2.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            port=os.getenv('DB_PORT', '5432'),
            database=os.getenv('DB_NAME', 'aittutor'),
            user=os.getenv('DB_USER', 'postgres'),
            password=db_password
        )
        connection.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        return connection
    except Exception as e:
        print(f"Error connecting to database: {e}")
        sys.exit(1)

def check_column_exists(cursor, table_name, column_name):
    """Check if a column exists in a table."""
    cursor.execute("""
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = %s AND column_name = %s
    """, (table_name, column_name))
    return cursor.fetchone() is not None

def run_migration():
    """Run database migration."""
    print("🚀 Starting database migration...")
    
    connection = get_db_connection()
    cursor = connection.cursor()
    
    try:
        # Migration 1: Add history column to users table
        print("📝 Checking users.history column...")
        if not check_column_exists(cursor, 'users', 'history'):
            print("   Adding history column to users table...")
            cursor.execute("""
                ALTER TABLE users 
                ADD COLUMN history JSON DEFAULT '[]'::json
            """)
            print("   ✅ users.history column added successfully")
        else:
            print("   ✅ users.history column already exists")
        
        # Migration 2: Add response_roman column to code_sessions table
        print("📝 Checking code_sessions.response_roman column...")
        if not check_column_exists(cursor, 'code_sessions', 'response_roman'):
            print("   Adding response_roman column to code_sessions table...")
            cursor.execute("""
                ALTER TABLE code_sessions 
                ADD COLUMN response_roman TEXT
            """)
            print("   ✅ code_sessions.response_roman column added successfully")
        else:
            print("   ✅ code_sessions.response_roman column already exists")
        
        # Migration 3: Create indexes for better performance
        print("📝 Creating performance indexes...")
        
        # Index on users.current_subject for faster subject filtering
        try:
            cursor.execute("""
                CREATE INDEX IF NOT EXISTS idx_users_current_subject 
                ON users(current_subject)
            """)
            print("   ✅ Index on users.current_subject created")
        except Exception as e:
            print(f"   ⚠️  Index on users.current_subject already exists or error: {e}")
        
        # Index on sessions.user_id for faster session queries
        try:
            cursor.execute("""
                CREATE INDEX IF NOT EXISTS idx_sessions_user_id 
                ON sessions(user_id)
            """)
            print("   ✅ Index on sessions.user_id created")
        except Exception as e:
            print(f"   ⚠️  Index on sessions.user_id already exists or error: {e}")
        
        # Index on messages.session_id for faster message queries
        try:
            cursor.execute("""
                CREATE INDEX IF NOT EXISTS idx_messages_session_id 
                ON messages(session_id)
            """)
            print("   ✅ Index on messages.session_id created")
        except Exception as e:
            print(f"   ⚠️  Index on messages.session_id already exists or error: {e}")
        
        # Index on code_sessions.user_id for faster code session queries
        try:
            cursor.execute("""
                CREATE INDEX IF NOT EXISTS idx_code_sessions_user_id 
                ON code_sessions(user_id)
            """)
            print("   ✅ Index on code_sessions.user_id created")
        except Exception as e:
            print(f"   ⚠️  Index on code_sessions.user_id already exists or error: {e}")
        
        # Migration 4: Update existing data if needed
        print("📝 Updating existing data...")
        
        # Set default history for users who don't have it
        cursor.execute("""
            UPDATE users 
            SET history = '[]'::json 
            WHERE history IS NULL
        """)
        updated_users = cursor.rowcount
        if updated_users > 0:
            print(f"   ✅ Updated {updated_users} users with default history")
        else:
            print("   ✅ All users already have history data")
        
        # Set default progress for users who don't have it
        cursor.execute("""
            UPDATE users 
            SET progress = '{}'::json 
            WHERE progress IS NULL
        """)
        updated_progress = cursor.rowcount
        if updated_progress > 0:
            print(f"   ✅ Updated {updated_progress} users with default progress")
        else:
            print("   ✅ All users already have progress data")
        
        print("\n🎉 Database migration completed successfully!")
        print("\n📊 Migration Summary:")
        print("   - Added users.history column for chat history tracking")
        print("   - Added code_sessions.response_roman column for Roman Urdu translations")
        print("   - Created performance indexes for faster queries")
        print("   - Updated existing data with default values")
        
    except Exception as e:
        print(f"❌ Migration failed: {e}")
        connection.rollback()
        sys.exit(1)
    finally:
        cursor.close()
        connection.close()

def verify_migration():
    """Verify that migration was successful."""
    print("\n🔍 Verifying migration...")
    
    connection = get_db_connection()
    cursor = connection.cursor()
    
    try:
        # Check if all required columns exist
        required_columns = [
            ('users', 'history'),
            ('users', 'progress'),
            ('code_sessions', 'response_roman')
        ]
        
        for table, column in required_columns:
            if check_column_exists(cursor, table, column):
                print(f"   ✅ {table}.{column} exists")
            else:
                print(f"   ❌ {table}.{column} missing")
                return False
        
        # Check if indexes exist
        cursor.execute("""
            SELECT indexname 
            FROM pg_indexes 
            WHERE tablename IN ('users', 'sessions', 'messages', 'code_sessions')
            AND indexname LIKE 'idx_%'
        """)
        indexes = cursor.fetchall()
        print(f"   ✅ Found {len(indexes)} performance indexes")
        
        print("✅ Migration verification successful!")
        return True
        
    except Exception as e:
        print(f"❌ Verification failed: {e}")
        return False
    finally:
        cursor.close()
        connection.close()

if __name__ == "__main__":
    print("🤖 AI Tutor Platform - Database Migration Tool")
    print("=" * 50)
    
    if len(sys.argv) > 1 and sys.argv[1] == "--verify":
        verify_migration()
    else:
        run_migration()
        verify_migration()
    
    print("\n✨ Migration process completed!")
