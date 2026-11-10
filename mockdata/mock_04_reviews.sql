-- ============================================================
-- รันต่อจาก mock_03_registrar_users_plans.sql
-- Mock รีวิวรายวิชา สำหรับทดสอบ GET /v1/courses/{courseCode}/reviews (SCRUM-206)
--
-- กติกาเดียวกับ POST (SCRUM-203): รีวิวได้เฉพาะวิชาที่ลงทะเบียนจริง (ไม่ใช่ W)
-- ในเทอมที่จบแล้ว (ก่อน 2569/1) และ 1 คน 1 รีวิวต่อวิชา
-- แถวที่ไม่ผ่านกติกานี้จะถูกข้ามอัตโนมัติ (WHERE EXISTS ด้านล่าง)
--
-- ผู้เขียนรีวิว: 68130500002 (Plaifah), 67130500004 (Mint), 67130500005 (Tham)
-- 67130500003 (Kan) ไม่มีรีวิวเลย — ใช้ทดสอบ POST เขียนรีวิวใหม่
--
-- วิชาที่มีรีวิว:
--   INT100 3 รีวิว | INT101 3 รีวิว (1 hidden → แสดง 2) | INT110 3 | INT120 3
--   GEN121 2 | INT130 1 | INT131 1
--   วิชาอื่นทั้งหมด = ยังไม่มีรีวิว
-- ============================================================

INSERT INTO reviews (user_id, course_id, overall_rating, difficulty_rating, workload_rating, comment, status, created_at, updated_at)
SELECT u.user_id, c.course_id, v.overall, v.difficulty, v.workload, v.comment, v.status::review_status, v.written_at, v.written_at
FROM (VALUES
  -- INT100 Design Thinking
  ('68130500002', 'INT100', 5, 2, 3, 'สนุกมาก ได้ลงมือทำจริงตั้งแต่สัปดาห์แรก ทำงานกลุ่มเยอะหน่อยแต่ได้เพื่อนใหม่', 'visible', timestamp '2026-02-20 10:15'),
  ('67130500004', 'INT100', 4, 2, 2, 'เนื้อหาไม่ยาก เน้นกระบวนการคิดมากกว่าทฤษฎี', 'visible', timestamp '2025-11-03 19:40'),
  ('67130500005', 'INT100', 4, 1, 3, NULL, 'visible', timestamp '2025-10-28 08:05'),

  -- INT101 Discrete Mathematics
  ('68130500002', 'INT101', 3, 5, 4, 'ยากพอสมควร โดยเฉพาะเรื่องพิสูจน์ ต้องทำแบบฝึกหัดเยอะๆ', 'visible', timestamp '2026-02-25 21:30'),
  ('67130500004', 'INT101', 2, 5, 5, 'การบ้านทุกสัปดาห์ สอบหนัก แนะนำให้อ่านล่วงหน้า', 'visible', timestamp '2025-11-10 13:00'),
  ('67130500005', 'INT101', 1, 5, 5, 'อาจารย์สอนแย่มาก ไม่แนะนำให้ลงกับอาจารย์คนนี้', 'hidden', timestamp '2025-11-12 23:55'),  -- ถูก Staff ซ่อน (วิจารณ์ผู้สอน) ต้องไม่แสดง/ไม่นับ

  -- INT110 Programming
  ('68130500002', 'INT110', 5, 3, 4, 'พื้นฐานสำคัญมาก lab ช่วยให้เข้าใจเร็ว', 'visible', timestamp '2026-03-01 16:20'),
  ('67130500004', 'INT110', 4, 3, 4, 'ถ้าไม่เคยเขียนโปรแกรมมาก่อนจะเหนื่อยช่วงแรก แต่ไล่ทันได้', 'visible', timestamp '2025-11-15 11:45'),
  ('67130500005', 'INT110', 5, 4, 4, 'ชอบโจทย์ project ท้ายเทอม ได้ใช้ทุกอย่างที่เรียนมา', 'visible', timestamp '2025-11-16 09:10'),

  -- INT120
  ('68130500002', 'INT120', 4, 3, 3, 'เนื้อหาเป็นระบบดี มีตัวอย่างให้ลองทำตาม', 'visible', timestamp '2026-03-02 18:00'),
  ('67130500004', 'INT120', 3, 3, 4, 'งานเยอะช่วงกลางเทอม จัดเวลาดีๆ', 'visible', timestamp '2025-11-20 20:30'),
  ('67130500005', 'INT120', 4, 2, 3, NULL, 'visible', timestamp '2025-11-21 07:50'),

  -- GEN121 Learning and Problem Solving Skills
  ('67130500004', 'GEN121', 4, 1, 2, 'ได้ฝึกคิดและนำเสนอ ไม่เครียด', 'visible', timestamp '2025-10-30 15:00'),
  ('67130500005', 'GEN121', 3, 1, 3, 'ทำโปรเจกต์กลุ่มตลอดเทอม', 'visible', timestamp '2025-10-31 12:25'),

  -- INT130, INT131
  ('67130500004', 'INT130', 5, 4, 3, 'ชอบมาก อยากให้มีวิชาต่อยอด', 'visible', timestamp '2026-03-10 10:00'),
  ('67130500005', 'INT131', 4, 3, 4, 'เนื้อหาเยอะแต่ใช้งานได้จริง', 'visible', timestamp '2026-03-12 14:40')
) AS v(student_id, course_code, overall, difficulty, workload, comment, status, written_at)
JOIN users u ON u.student_id = v.student_id
JOIN courses c ON c.course_code = v.course_code
WHERE EXISTS (
  SELECT 1 FROM registrar_enrollments e
  WHERE e.student_id = v.student_id
    AND e.course_id = c.course_id
    AND e.status = 'registered'
    AND (e.academic_year, e.semester) < (2569, 1)
);
