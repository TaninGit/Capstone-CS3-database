-- 1) จำนวนแถวแต่ละตาราง
SELECT t.tbl, t.actual, t.expected,
       CASE WHEN t.actual = t.expected THEN '✅' ELSE '❌' END AS ok
FROM (VALUES
  ('curriculum_versions',         (SELECT count(*) FROM curriculum_versions),         1),
  ('categories',                  (SELECT count(*) FROM categories),                  5),
  ('curriculum_categories',       (SELECT count(*) FROM curriculum_categories),       5),
  ('courses',                     (SELECT count(*) FROM courses),                     213),
  ('curriculum_category_courses', (SELECT count(*) FROM curriculum_category_courses), 213),
  ('track_groups',                (SELECT count(*) FROM track_groups),                3),
  ('tracks',                      (SELECT count(*) FROM tracks),                      9),
  ('track_courses',               (SELECT count(*) FROM track_courses),               55),
  ('related_tracks',              (SELECT count(*) FROM related_tracks),              18),
  ('course_prerequisites',        (SELECT count(*) FROM course_prerequisites),        68),
  ('courses.prerequisite_note',   (SELECT count(*) FROM courses WHERE prerequisite_note IS NOT NULL), 52),
  ('registrar_students',          (SELECT count(*) FROM registrar_students),          5),
  ('registrar_enrollments',       (SELECT count(*) FROM registrar_enrollments),       167),
  ('users',                       (SELECT count(*) FROM users),                       7),
  ('users_invitations',           (SELECT count(*) FROM users_invitations),           2),
  ('study_plans',                 (SELECT count(*) FROM study_plans),                 4),
  ('study_plan_courses',          (SELECT count(*) FROM study_plan_courses),          12),
  ('student_course_grades',       (SELECT count(*) FROM student_course_grades),       104),
  ('fn mock_clone_student',       (SELECT count(*) FROM pg_proc WHERE proname = 'mock_clone_student'), 1)
) AS t(tbl, actual, expected);

-- 2) หน่วยกิตแต่ละหมวด: required_credits ต้องเป็น 27/60/21/14/6 รวม 128
--    GE กับ MAJOR_FOUNDATION ผลรวมวิชาบังคับต้องเท่ากับ required_credits พอดี
SELECT cc.sort_order, ca.code, cc.required_credits,
       COALESCE(sum(c.credits) FILTER (WHERE ccc.is_required), 0) AS required_course_credits,
       count(ccc.course_id) AS courses
FROM curriculum_categories cc
JOIN categories ca ON ca.category_id = cc.category_id
LEFT JOIN curriculum_category_courses ccc ON ccc.curriculum_category_id = cc.curriculum_category_id
LEFT JOIN courses c ON c.course_id = ccc.course_id
GROUP BY cc.sort_order, ca.code, cc.required_credits
ORDER BY cc.sort_order;

-- 3) track: กลุ่ม + หน่วยกิตวิชาบังคับต้องตรง required_credits (AI รวมวิชาเลือก 1 ตัวจาก choice_group อีก 3 หน่วยกิต)
SELECT g.group_name_th, t.track_name_th, t.track_name_en, t.required_credits,
       sum(c.credits) FILTER (WHERE tc.is_required)
         + COALESCE(max(c.credits) FILTER (WHERE tc.choice_group IS NOT NULL), 0) AS computed,
       (SELECT string_agg(r.track_name_en, ', ' ORDER BY rt.sort_order)
          FROM related_tracks rt JOIN tracks r ON r.track_id = rt.related_track_id
         WHERE rt.track_id = t.track_id) AS related
FROM tracks t
JOIN track_groups g ON g.track_group_id = t.track_group_id
JOIN track_courses tc ON tc.track_id = t.track_id
JOIN courses c ON c.course_id = tc.course_id
GROUP BY g.sort_order, g.group_name_th, t.track_id, t.sort_order, t.track_name_th, t.track_name_en, t.required_credits
ORDER BY g.sort_order, t.sort_order;
