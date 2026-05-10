#!/usr/bin/env python3
"""
Test script to verify login flow works correctly
"""
import requests
import json
import sys

BASE_URL = "http://localhost:8000"

def test_login():
    """Test the complete login flow"""
    print("=" * 60)
    print("Testing Login Flow")
    print("=" * 60)
    
    # Test 1: Register a test user
    print("\n1. Testing user registration...")
    register_data = {
        "username": "testuser_flow",
        "email": "testuser_flow@test.com",
        "password": "testpass123"
    }
    
    try:
        # Try to register
        resp = requests.post(f"{BASE_URL}/api/auth/register", json=register_data)
        if resp.status_code == 400:
            print("   ✓ User already exists (previous test run)")
        elif resp.status_code == 200:
            print("   ✓ User registered successfully")
            print(f"   Response: {resp.json()}")
        else:
            print(f"   ✗ Unexpected response: {resp.status_code}")
            print(f"   Error: {resp.text}")
            return False
    except Exception as e:
        print(f"   ✗ Registration failed: {e}")
        return False
    
    # Test 2: Login with credentials
    print("\n2. Testing user login...")
    login_data = {
        "username": "testuser_flow",
        "password": "testpass123"
    }
    
    try:
        # Use form-urlencoded format as the frontend does
        from urllib.parse import urlencode
        form_data = urlencode(login_data)
        
        resp = requests.post(
            f"{BASE_URL}/api/auth/login",
            data=form_data,
            headers={"Content-Type": "application/x-www-form-urlencoded"}
        )
        
        if resp.status_code == 200:
            token_data = resp.json()
            token = token_data.get("access_token")
            print("   ✓ Login successful!")
            print(f"   Token type: {token_data.get('token_type')}")
            print(f"   Token (first 50 chars): {token[:50]}...")
            
            # Test 3: Verify token by getting user info
            print("\n3. Testing token validation with /api/auth/me...")
            try:
                user_resp = requests.get(
                    f"{BASE_URL}/api/auth/me",
                    headers={"Authorization": f"Bearer {token}"}
                )
                
                if user_resp.status_code == 200:
                    user_data = user_resp.json()
                    print("   ✓ Token is valid!")
                    print(f"   User ID: {user_data.get('id')}")
                    print(f"   Username: {user_data.get('username')}")
                    print(f"   Email: {user_data.get('email')}")
                    return True
                else:
                    print(f"   ✗ Token validation failed: {user_resp.status_code}")
                    print(f"   Error: {user_resp.text}")
                    return False
            except Exception as e:
                print(f"   ✗ Token verification failed: {e}")
                return False
        else:
            print(f"   ✗ Login failed with status: {resp.status_code}")
            print(f"   Error: {resp.text}")
            return False
            
    except Exception as e:
        print(f"   ✗ Login failed: {e}")
        return False

if __name__ == "__main__":
    print("\n" + "="*60)
    print("Code Mentor AI - Login Flow Test")
    print("="*60)
    
    success = test_login()
    
    print("\n" + "="*60)
    if success:
        print("✓ All tests PASSED! Login flow is working correctly.")
        print("\nFixes Applied:")
        print("1. Added setTimeout delay for navigation after setIsLoggedIn")
        print("2. Added re-auth check when token appears after component mount")
        print("\nYou can now test the UI at: http://localhost:5174")
    else:
        print("✗ Some tests FAILED. Check the errors above.")
        sys.exit(1)
    print("="*60 + "\n")
