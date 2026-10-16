cd /e/kampus/Belajar/multimedia/KODIRA
cat > CATATAN-LOGIN.md << 'EOF'

# Catatan Login Test KODIRA

## User Test 1

- NIM: 2402095010141
- Password: password123
- Nama: Muhammad Ridho S.

## Supabase

- Project: vnmrivutawqxcoklamcb
- URL: https://vnmrivutawqxcoklamcb.supabase.co

## Cara Reset Password

Jika lupa, buka Supabase SQL Editor:

```sql
UPDATE auth.users
SET encrypted_password = crypt('password123', gen_salt('bf')),
    updated_at = NOW()
WHERE email = 'nim_2402095010141@kodira.local';
```
