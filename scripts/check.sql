WITH checks (sort, item, actual, expected) AS (
  VALUES
    (101, 'rows: curriculum_versions',         (SELECT count(*) FROM curriculum_versions),         1),
    (102, 'rows: categories',                  (SELECT count(*) FROM categories),                  5),
    (103, 'rows: curriculum_categories',       (SELECT count(*) FROM curriculum_categories),       5),
    (104, 'rows: courses',                     (SELECT count(*) FROM courses),                     213),
    (105, 'rows: curriculum_category_courses', (SELECT count(*) FROM curriculum_category_courses), 213),
    (106, 'rows: track_groups',                (SELECT count(*) FROM track_groups),                3),
    (107, 'rows: tracks',                      (SELECT count(*) FROM tracks),                      9),
    (108, 'rows: track_courses',               (SELECT count(*) FROM track_courses),               55),
    (109, 'rows: related_tracks',              (SELECT count(*) FROM related_tracks),              18),
    (110, 'rows: course_prerequisites',        (SELECT count(*) FROM course_prerequisites),        68),
    (111, 'rows: courses.prerequisite_note',   (SELECT count(*) FROM courses WHERE prerequisite_note IS NOT NULL), 52),
    (112, 'rows: registrar_students',          (SELECT count(*) FROM registrar_students),          5),
    (113, 'rows: registrar_enrollments',       (SELECT count(*) FROM registrar_enrollments),       167),
    (114, 'rows: users',                       (SELECT count(*) FROM users),                       7),
    (115, 'rows: users_invitations',           (SELECT count(*) FROM users_invitations),           2),
    (116, 'rows: study_plans',                 (SELECT count(*) FROM study_plans),                 5),
    (117, 'rows: study_plan_courses',          (SELECT count(*) FROM study_plan_courses),          13),
    (118, 'rows: student_course_grades',       (SELECT count(*) FROM student_course_grades),       104),
    (120, 'plans: user ที่มีแผนหลักไม่ครบ 1', (SELECT count(*) FROM (SELECT user_id FROM study_plans GROUP BY user_id HAVING count(*) FILTER (WHERE is_default) <> 1) z), 0),
    (121, 'plans: user ที่มีเกิน 5 แผน',      (SELECT count(*) FROM (SELECT user_id FROM study_plans GROUP BY user_id HAVING count(*) > 5) z), 0),
    (119, 'fn: mock_clone_student',            (SELECT count(*) FROM pg_proc WHERE proname = 'mock_clone_student'), 1),
    (201, 'credits: รวมทุกหมวด = total_credits', (SELECT sum(required_credits) FROM curriculum_categories),
                                                 (SELECT total_credits FROM curriculum_versions WHERE academic_year = 2567))
),
cat AS (
  SELECT 210 + cc.sort_order AS sort,
         'credits: วิชาบังคับหมวด ' || ca.code AS item,
         COALESCE(sum(c.credits) FILTER (WHERE ccc.is_required), 0) AS actual,
         CASE ca.code WHEN 'PROJECT' THEN 8 WHEN 'MAJOR_ADVANCED' THEN 0 WHEN 'FREE_ELECTIVE' THEN 0
                      ELSE cc.required_credits END AS expected
  FROM curriculum_categories cc
  JOIN categories ca ON ca.category_id = cc.category_id
  LEFT JOIN curriculum_category_courses ccc ON ccc.curriculum_category_id = cc.curriculum_category_id
  LEFT JOIN courses c ON c.course_id = ccc.course_id
  GROUP BY cc.sort_order, ca.code, cc.required_credits
),
trk AS (
  SELECT 300 + t.sort_order AS sort,
         'track: ' || t.track_name_en || ' (' || g.group_name_th || ')' AS item,
         sum(c.credits) FILTER (WHERE tc.is_required)
           + COALESCE(max(c.credits) FILTER (WHERE tc.choice_group IS NOT NULL), 0) AS actual,
         t.required_credits AS expected
  FROM tracks t
  JOIN track_groups g ON g.track_group_id = t.track_group_id
  JOIN track_courses tc ON tc.track_id = t.track_id
  JOIN courses c ON c.course_id = tc.course_id
  GROUP BY t.track_id, t.sort_order, t.track_name_en, g.group_name_th, t.required_credits
),
rel AS (
  SELECT 401 AS sort, 'related: track ที่ไม่มี track ใกล้เคียง' AS item,
         (SELECT count(*) FROM tracks t WHERE NOT EXISTS (SELECT 1 FROM related_tracks r WHERE r.track_id = t.track_id)) AS actual,
         0 AS expected
)
SELECT item, actual, expected,
       CASE WHEN actual = expected THEN '✅' ELSE '❌' END AS ok
FROM (
  SELECT * FROM checks
  UNION ALL SELECT * FROM cat
  UNION ALL SELECT * FROM trk
  UNION ALL SELECT * FROM rel
) x
ORDER BY sort;
