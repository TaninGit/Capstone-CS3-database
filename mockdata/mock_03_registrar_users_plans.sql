-- ============================================================
-- รันต่อจาก mock_02_prerequisites_free_electives.sql
-- Mock ระบบทะเบียน + users + study plans + เกรด สำหรับทดสอบ Planner
--
-- สมมติว่าตอนนี้คือ ปีการศึกษา 2569 ภาค 1 (เทอมปัจจุบัน = ลงทะเบียนแล้ว ยังไม่มีเกรด)
--
-- นักศึกษา mock (หลักสูตร 2567 ทุกคน)
--  69130500001  ปี 1 เทอม 1  ยังไม่เลือก track, ยังไม่มี plan (ทดสอบ BE สร้าง plan ครั้งแรก)
--  68130500002  ปี 2 เทอม 1  ยังไม่เลือก track (study_plans.track_id = NULL)
--  67130500003  ปี 3 เทอม 1  แผน 3 Full-Stack  เรียนตามแผนปกติ
--  67130500004  ปี 3 เทอม 1  แผน 4 AI          ติด F INT133 (2567/2) ลงซ้ำ 2568/1, W INT185 (2568/2) ลงใหม่ 2569/1
--                                                 มี 2 แผน: AI (แผนหลัก) + 'ลองสาย Data Scientist'
--  67130500005  ปี 3 เทอม 1  แผน 7 Data Eng.   มีวิชาที่วางแผนไว้ในเทอมที่ผ่านมาแต่ไม่ได้ลงจริง (GEN341)
--
-- อยากให้ account ตัวเอง (login จริง) มีข้อมูล: ดูฟังก์ชัน mock_clone_student ท้ายไฟล์
-- ============================================================
BEGIN;

-- 1) registrar_students
INSERT INTO registrar_students (student_id, first_name_th, last_name_th, admission_year, curriculum_version_id, current_year, current_semester)
SELECT v.student_id, v.fn, v.ln, v.admission_year, cv.curriculum_version_id, v.cur_year, v.cur_sem
FROM (VALUES
  ('69130500001', 'ภูมิ', 'ใจดี', 2569, 1, 1),
  ('68130500002', 'ปลายฟ้า', 'สุขสันต์', 2568, 2, 1),
  ('67130500003', 'กันต์', 'รักเรียน', 2567, 3, 1),
  ('67130500004', 'มิ้นท์', 'ตั้งใจ', 2567, 3, 1),
  ('67130500005', 'ธาม', 'ขยันยิ่ง', 2567, 3, 1)
) AS v(student_id, fn, ln, admission_year, cur_year, cur_sem)
JOIN curriculum_versions cv ON cv.academic_year = 2567;

-- 2) registrar_enrollments: วิชาบังคับตามแผนมาตรฐาน + วิชาบังคับของ track ตั้งแต่เทอมแรกถึงเทอมปัจจุบัน
WITH student_track AS (
  SELECT v.student_id, t.track_id
  FROM (VALUES
    ('67130500003', 'Full-Stack Developer'),
    ('67130500004', 'AI Developer'),
    ('67130500005', 'Data Engineer')
  ) AS v(student_id, track_en)
  JOIN tracks t ON t.track_name_en = v.track_en
),
std_courses AS (
  SELECT cc.curriculum_version_id, ccc.course_id, ccc.standard_year, ccc.standard_semester, NULL::int AS track_id
  FROM curriculum_category_courses ccc
  JOIN curriculum_categories cc ON cc.curriculum_category_id = ccc.curriculum_category_id
  WHERE ccc.is_required AND ccc.standard_year IS NOT NULL
  UNION ALL
  SELECT t.curriculum_version_id, tc.course_id, tc.standard_year, tc.standard_semester, t.track_id
  FROM track_courses tc
  JOIN tracks t ON t.track_id = tc.track_id
  WHERE tc.is_required
)
INSERT INTO registrar_enrollments (student_id, course_id, academic_year, semester, status)
SELECT s.student_id, x.course_id, s.admission_year + x.standard_year - 1, x.standard_semester, 'registered'
FROM registrar_students s
LEFT JOIN student_track st ON st.student_id = s.student_id
JOIN std_courses x ON x.curriculum_version_id = s.curriculum_version_id
  AND (x.track_id IS NULL OR x.track_id = st.track_id)
WHERE (x.standard_year - 1) * 2 + x.standard_semester <= (s.current_year - 1) * 2 + s.current_semester
  AND s.student_id IN ('69130500001', '68130500002', '67130500003', '67130500004', '67130500005');

-- 2.1) เคสพิเศษ
-- 67130500004: ติด F INT133 ใน 2567/2 (เกรดใส่ข้อ 5) แล้วลงซ้ำ 2568/1
INSERT INTO registrar_enrollments (student_id, course_id, academic_year, semester, status)
SELECT '67130500004', course_id, 2568, 1, 'registered' FROM courses WHERE course_code = 'INT133';

-- 67130500004: W INT185 ใน 2568/2 แล้วลงใหม่เทอมปัจจุบัน 2569/1
UPDATE registrar_enrollments e SET status = 'withdrawn'
FROM courses c
WHERE e.course_id = c.course_id AND c.course_code = 'INT185'
  AND e.student_id = '67130500004' AND e.academic_year = 2568 AND e.semester = 2;
INSERT INTO registrar_enrollments (student_id, course_id, academic_year, semester, status)
SELECT '67130500004', course_id, 2569, 1, 'registered' FROM courses WHERE course_code = 'INT185';

-- วิชาเลือก IT / เลือกเสรีที่ลงจริง
INSERT INTO registrar_enrollments (student_id, course_id, academic_year, semester, status)
SELECT v.student_id, c.course_id, v.ay, v.sem, 'registered'
FROM (VALUES
  ('67130500003', 'GEN331', 2568, 2),
  ('67130500003', 'INT341', 2569, 1),
  ('67130500004', 'GEN311', 2568, 1),
  ('67130500004', 'INT380', 2569, 1),
  ('67130500005', 'GEN224', 2568, 2),
  ('67130500005', 'INT390', 2569, 1)
) AS v(student_id, course_code, ay, sem)
JOIN courses c ON c.course_code = v.course_code;

-- 3) users (นักศึกษา mock + staff/admin) — ปกติ BE สร้างตอน login (POST /v1/auth/sync)
INSERT INTO users (student_id, email, first_name, last_name, display_name, role, created_at, updated_at) VALUES
  ('69130500001', '69130500001@ad.sit.kmutt.ac.th', 'Phum', 'Jaidee', 'Phum', 'student', now(), now()),
  ('68130500002', '68130500002@ad.sit.kmutt.ac.th', 'Plaifah', 'Suksan', 'Plaifah', 'student', now(), now()),
  ('67130500003', '67130500003@ad.sit.kmutt.ac.th', 'Kan', 'Rakrian', 'Kan', 'student', now(), now()),
  ('67130500004', '67130500004@ad.sit.kmutt.ac.th', 'Mint', 'Tangjai', 'Mint', 'student', now(), now()),
  ('67130500005', '67130500005@ad.sit.kmutt.ac.th', 'Tham', 'Khayanying', 'Tham', 'student', now(), now()),
  (NULL, 'staff.mock@ad.sit.kmutt.ac.th', 'Staff', 'Mock', 'Staff Mock', 'staff', now(), now()),
  (NULL, 'admin.mock@ad.sit.kmutt.ac.th', 'Admin', 'Mock', 'Admin Mock', 'admin', now(), now());

INSERT INTO users_invitations (email, role) VALUES
  ('staff.mock@ad.sit.kmutt.ac.th', 'staff'),
  ('staff.pending@ad.sit.kmutt.ac.th', 'staff');  -- เชิญแล้วแต่ยังไม่เคย login

-- 4) study_plans + study_plan_courses
-- plan เก็บเฉพาะวิชาที่นักศึกษาเพิ่มเอง (วิชาบังคับ planner ดึงจากหลักสูตร/track อัตโนมัติ)
-- study_year/study_semester เป็นชั้นปี/เทอมของนักศึกษา (1-4 / 1-2) ไม่ใช่ปีการศึกษา
INSERT INTO study_plans (user_id, curriculum_version_id, track_id, plan_name, is_default, created_at, updated_at)
SELECT u.user_id, cv.curriculum_version_id, t.track_id, 'แผนการเรียนของฉัน', true, now(), now()
FROM (VALUES
  ('68130500002', NULL),
  ('67130500003', 'Full-Stack Developer'),
  ('67130500004', 'AI Developer'),
  ('67130500005', 'Data Engineer')
) AS v(student_id, track_en)
JOIN users u ON u.student_id = v.student_id
JOIN curriculum_versions cv ON cv.academic_year = 2567
LEFT JOIN tracks t ON t.track_name_en = v.track_en;

INSERT INTO study_plan_courses (study_plan_id, course_id, study_year, study_semester)
SELECT sp.study_plan_id, c.course_id, v.y, v.s
FROM (VALUES
  ('68130500002', 'GEN224', 2, 2),
  ('68130500002', 'LNG272', 3, 1),
  ('67130500003', 'GEN331', 2, 2),   -- วางแผนแล้วลงจริง
  ('67130500003', 'GEN352', 3, 2),
  ('67130500003', 'INT505', 3, 2),
  ('67130500003', 'INT331', 4, 1),
  ('67130500003', 'INT506', 4, 1),
  ('67130500004', 'INT370', 3, 2),
  ('67130500004', 'GEN301', 4, 1),
  ('67130500005', 'GEN341', 2, 1),   -- เทอมผ่านไปแล้วแต่ไม่ได้ลงจริง (planned, not registered)
  ('67130500005', 'LNG224', 3, 2),
  ('67130500005', 'INT380', 4, 1)
) AS v(student_id, course_code, y, s)
JOIN users u ON u.student_id = v.student_id
JOIN study_plans sp ON sp.user_id = u.user_id AND sp.is_default
JOIN courses c ON c.course_code = v.course_code;

-- 4.1) แผนที่ 2 (ไม่ใช่แผนหลัก) ของ 67130500004: ลองดูสาย Data Scientist — ทดสอบ GET /v1/plans หลายแผน
INSERT INTO study_plans (user_id, curriculum_version_id, track_id, plan_name, is_default, created_at, updated_at)
SELECT u.user_id, cv.curriculum_version_id, t.track_id, 'ลองสาย Data Scientist', false, now(), now()
FROM users u
JOIN curriculum_versions cv ON cv.academic_year = 2567
JOIN tracks t ON t.track_name_en = 'Data Scientist'
WHERE u.student_id = '67130500004';

INSERT INTO study_plan_courses (study_plan_id, course_id, study_year, study_semester)
SELECT sp.study_plan_id, c.course_id, 4, 1
FROM users u
JOIN study_plans sp ON sp.user_id = u.user_id AND sp.plan_name = 'ลองสาย Data Scientist'
JOIN courses c ON c.course_code = 'INT381'
WHERE u.student_id = '67130500004';

-- 5) student_course_grades: เทอมที่จบแล้วเท่านั้น (เกรดแบบสุ่มคงที่) — 68130500002 ยังไม่กรอกเกรด
INSERT INTO student_course_grades (user_id, enrollment_id, grade, created_at, updated_at)
SELECT u.user_id, e.enrollment_id,
       (ARRAY['A', 'B+', 'B', 'A', 'C+', 'B+', 'B', 'C'])[1 + (e.course_id * 7 + RIGHT(e.student_id, 1)::int) % 8],
       now(), now()
FROM registrar_enrollments e
JOIN registrar_students s ON s.student_id = e.student_id
JOIN users u ON u.student_id = e.student_id
WHERE e.status = 'registered'
  AND (e.academic_year, e.semester) < (s.admission_year + s.current_year - 1, s.current_semester)
  AND e.student_id IN ('67130500003', '67130500004', '67130500005');

UPDATE student_course_grades g SET grade = 'F'
FROM registrar_enrollments e
JOIN courses c ON c.course_id = e.course_id
WHERE g.enrollment_id = e.enrollment_id
  AND e.student_id = '67130500004' AND c.course_code = 'INT133'
  AND e.academic_year = 2567 AND e.semester = 2;

COMMIT;

-- ============================================================
-- Helper สำหรับ dev: ให้รหัสนักศึกษาจริงของเรามีข้อมูลทะเบียนเหมือนนักศึกษา mock
-- (login ด้วย Microsoft จริง → BE ดึง student_id จากอีเมล → ไปหาใน registrar_students)
--   SELECT mock_clone_student('67130500004', '66130500xxx');
-- copy เฉพาะข้อมูลทะเบียน (ไม่ copy plan/เกรด เพราะเป็นข้อมูลที่ user สร้างเอง)
-- รันซ้ำได้: ลบข้อมูลทะเบียนเดิมของรหัสปลายทางก่อน (ถ้ามีเกรดผูกอยู่จะลบให้ด้วย)
-- ============================================================
CREATE OR REPLACE FUNCTION mock_clone_student(p_src varchar, p_dst varchar)
RETURNS int LANGUAGE plpgsql AS $$
DECLARE n int;
BEGIN
  DELETE FROM student_course_grades WHERE enrollment_id IN
    (SELECT enrollment_id FROM registrar_enrollments WHERE student_id = p_dst);
  DELETE FROM registrar_enrollments WHERE student_id = p_dst;
  DELETE FROM registrar_students WHERE student_id = p_dst;

  INSERT INTO registrar_students (student_id, first_name_th, last_name_th, admission_year, curriculum_version_id, current_year, current_semester)
  SELECT p_dst, first_name_th, last_name_th, admission_year, curriculum_version_id, current_year, current_semester
  FROM registrar_students WHERE student_id = p_src;
  IF NOT FOUND THEN RAISE EXCEPTION 'source student % not found', p_src; END IF;

  INSERT INTO registrar_enrollments (student_id, course_id, academic_year, semester, status)
  SELECT p_dst, course_id, academic_year, semester, status
  FROM registrar_enrollments WHERE student_id = p_src;
  GET DIAGNOSTICS n = ROW_COUNT;
  RETURN n;
END $$;
