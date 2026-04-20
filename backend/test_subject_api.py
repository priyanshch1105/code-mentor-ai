import requests
import time

base = 'http://localhost:8000'
user = f'testuser_{int(time.time())}'
email = f'{user}@local'
password = 'TestPass123'

print('Registering', user)
r = requests.post(base + '/api/auth/register', json={'username': user, 'email': email, 'password': password})
print('register', r.status_code, r.text)
r = requests.post(base + '/api/auth/login', data={'username': user, 'password': password}, headers={'Content-Type': 'application/x-www-form-urlencoded'})
print('login', r.status_code, r.text)
if r.status_code == 200:
    token = r.json()['access_token']
    print('Token', token[:20] + '...')
    r2 = requests.post(base + '/api/auth/select-subject', json={'subject': 'coding'}, headers={'Authorization': f'Bearer {token}'})
    print('select-subject', r2.status_code, r2.text)
    r3 = requests.get(base + '/api/auth/me', headers={'Authorization': f'Bearer {token}'})
    print('me', r3.status_code, r3.text)
else:
    print('login failed')
