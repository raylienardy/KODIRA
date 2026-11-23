import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { handleOptions, jsonResponse, readJsonObject } from '../_shared/cors.ts';

Deno.serve(async (req: Request) => {
  const methodResponse = handleOptions(req);
  if (methodResponse) return methodResponse;

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) return jsonResponse({ error: 'No authorization header' }, 401);

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    const supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: { user }, error: userError } = await supabaseClient.auth.getUser();
    if (userError || !user) return jsonResponse({ error: 'Unauthorized' }, 401);

    const body = await readJsonObject(req);
    const newNim = body.new_nim;
    if (!newNim) return jsonResponse({ error: 'new_nim is required' }, 400);

    const role = user.user_metadata?.role || 'student';

    // Validasi regex: Student (12-13 digit), Teacher (10 digit)
    const regex = role === 'teacher' ? /^\d{10}$/ : /^\d{12,13}$/;
    if (!regex.test(newNim)) {
      return jsonResponse(
        { error: role === 'teacher' ? 'NIDN harus 10 digit angka' : 'NIM harus 12-13 digit angka' },
        400
      );
    }

    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

    // Cek keunikan NIM di public.users
    const { data: existingUser, error: checkError } = await supabaseAdmin
      .from('users')
      .select('id')
      .eq('nim', newNim)
      .maybeSingle();

    if (checkError) throw checkError;

    if (existingUser && existingUser.id !== user.id) {
      return jsonResponse({ error: 'NIM sudah digunakan oleh akun lain' }, 409);
    }

    const newEmail = `nim_${newNim}@kodira.local`;

    // 1. Update Auth User
    const { error: authError } = await supabaseAdmin.auth.admin.updateUserById(
      user.id,
      {
        email: newEmail,
        email_confirm: true,
        user_metadata: { ...user.user_metadata, nim: newNim }
      }
    );
    if (authError) throw authError;

    // 2. Update Public User Table
    const { error: dbError } = await supabaseAdmin
      .from('users')
      .update({
        nim: newNim,
        email: newEmail
      })
      .eq('id', user.id);
    if (dbError) throw dbError;

    return jsonResponse({ success: true, message: 'NIM berhasil diupdate' });
  } catch (error: any) {
    console.error('update-nim error:', error);
    return jsonResponse({ error: error.message || 'Terjadi kesalahan server' }, 500);
  }
});
