-- RPC: join_class(p_code)
-- SECURITY DEFINER → bypass RLS to lookup class by code
-- Returns minimal data for preview + joins user to class

CREATE OR REPLACE FUNCTION public.join_class(p_code TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_class RECORD;
  v_uid UUID := auth.uid();
  v_already_member BOOLEAN;
  v_result JSONB;
BEGIN
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('error', 'not_authenticated');
  END IF;

  IF p_code IS NULL OR LENGTH(p_code) <> 6 THEN
    RETURN jsonb_build_object('error', 'invalid_code_format');
  END IF;

  SELECT id, name, code, description 
  INTO v_class 
  FROM public.classes 
  WHERE code = UPPER(p_code);
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object('error', 'class_not_found');
  END IF;

  SELECT EXISTS (
    SELECT 1 FROM public.class_students 
    WHERE class_id = v_class.id AND student_id = v_uid
  ) INTO v_already_member;

  IF v_already_member THEN
    RETURN jsonb_build_object(
      'success', true,
      'already_member', true,
      'class', jsonb_build_object(
        'id', v_class.id,
        'name', v_class.name,
        'code', v_class.code,
        'description', v_class.description
      )
    );
  END IF;

  INSERT INTO public.class_students (class_id, student_id, is_primary)
  VALUES (v_class.id, v_uid, false);

  RETURN jsonb_build_object(
    'success', true,
    'already_member', false,
    'class', jsonb_build_object(
      'id', v_class.id,
      'name', v_class.name,
      'code', v_class.code,
      'description', v_class.description
    )
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.join_class(TEXT) TO authenticated;
