-- ============================================================
-- รันต่อจาก mock.sql
-- 1) รายวิชาเลือกเสรี (วิชาของมหาวิทยาลัยที่นำมานับหมวดวิชาเลือกเสรีได้)
-- 2) วิชาบังคับก่อน (course_prerequisites + courses.prerequisite_note)
--
-- ที่มา
--  - วิชาบังคับก่อน: เอกสารรายละเอียดหลักสูตร วท.บ. IT 2567 ฉบับย่อ (อนุมัติสภา มจธ. ครั้งที่ 291)
--    https://www.sit.kmutt.ac.th/wp-content/uploads/2025/07/รายละเอียดฉบับย่อ-BSC-IT-2567.pdf
--  - รหัส/ชื่ออังกฤษ/หน่วยกิตวิชาเลือกเสรี: สำนักงานทะเบียน มจธ. (รายงานเกรดเฉลี่ยคณะศิลปศาสตร์ 1/2564)
--    https://regis.kmutt.ac.th/service/meangpa/164/art164.pdf
--  - ชื่อไทยวิชา GEN: https://gened.kmutt.ac.th/allcourse/
--  หมายเหตุ: ชื่อไทยของวิชา LNG/SSC และชื่ออังกฤษ/หน่วยกิตของ GEN212, GEN222, GEN225, GEN354
--  ยังไม่ได้ตรวจกับเอกสารทางการ (แปล/คาดเอง) ให้ Staff แก้ได้ภายหลัง
-- ============================================================
BEGIN;

-- 1) courses: วิชาเลือกเสรี
INSERT INTO courses (course_code, name_th, name_en, credits, is_active, created_at, updated_at) VALUES
  -- GEN วิชาเลือก (หลักสูตร IT 2567 กำหนดวิชา GEN ในแต่ละกลุ่มไว้แล้ว วิชาเหล่านี้จึงนับเป็นเลือกเสรี)
  ('GEN101', 'พลศึกษา', 'Physical Education', 1, true, now(), now()),
  ('GEN201', 'ศาสตร์และศิลป์ในการปรุงและบริโภคอาหาร', 'Art and Science of Cooking and Eating', 3, true, now(), now()),
  ('GEN211', 'ปรัชญาเศรษฐกิจพอเพียง', 'The Philosophy of Sufficiency Economy', 3, true, now(), now()),
  ('GEN212', 'การพัฒนาจิตเพื่อชีวิตที่สมบูรณ์ด้วยวิถีพุทธ', 'Buddhist Mind Development for a Fulfilling Life', 3, true, now(), now()),
  ('GEN222', 'สังคมวัฒนธรรมไทยและประเด็นร่วมสมัย', 'Thai Society, Culture and Contemporary Issues', 3, true, now(), now()),
  ('GEN223', 'การเตรียมพร้อมรับภัยพิบัติ', 'Disaster Preparedness', 3, true, now(), now()),
  ('GEN224', 'เมืองน่าอยู่', 'Liveable City', 3, true, now(), now()),
  ('GEN225', 'การเขียนบันทึกสะท้อนคิดเพื่อการพัฒนาตนเอง', 'Reflective Writing for Self-Development', 3, true, now(), now()),
  ('GEN226', 'สิ่งเล็ก ๆ ที่เรียกว่าพอลิเมอร์', 'Small Things We Call Polymers', 3, true, now(), now()),
  ('GEN232', 'การวิจัยและนวัตกรรมบนฐานชุมชน', 'Community Based Research and Innovation', 3, true, now(), now()),
  ('GEN242', 'ปรัชญาจีนกับการดำเนินชีวิต', 'Chinese Philosophy and Ways of Life', 3, true, now(), now()),
  ('GEN301', 'การพัฒนาสุขภาพแบบองค์รวม', 'Holistic Health Development', 3, true, now(), now()),
  ('GEN311', 'จริยศาสตร์ในสังคมฐานวิทยาศาสตร์', 'Ethics in Science-Based Society', 3, true, now(), now()),
  ('GEN321', 'ประวัติศาสตร์อารยธรรม', 'The History of Civilization', 3, true, now(), now()),
  ('GEN331', 'มนุษย์กับการใช้เหตุผล', 'Man and Reasoning', 3, true, now(), now()),
  ('GEN332', 'การเล่าเรื่องวิทยาศาสตร์', 'Science Storytelling', 3, true, now(), now()),
  ('GEN341', 'ภูมิปัญญาท้องถิ่นไทย', 'Thai Indigenous Knowledge', 3, true, now(), now()),
  ('GEN352', 'เทคโนโลยีและนวัตกรรมเพื่อการพัฒนาอย่างยั่งยืน', 'Technology and Innovation for Sustainable Development', 3, true, now(), now()),
  ('GEN353', 'จิตวิทยาการจัดการ', 'Managerial Psychology', 3, true, now(), now()),
  ('GEN354', 'นวัตกรรมผลิตภัณฑ์ดิจิทัลและการสร้างให้เป็นธุรกิจ', 'Digital Product Innovation and Commercialization', 3, true, now(), now()),
  ('GEN411', 'การพัฒนาบุคลิกภาพและการพูดในที่สาธารณะ', 'Personality Development and Public Speaking', 3, true, now(), now()),
  ('GEN412', 'ศาสตร์และศิลป์ในการดำเนินชีวิตและการทำงาน', 'Science and Art of Living and Working', 3, true, now(), now()),
  ('GEN421', 'สังคมศาสตร์บูรณาการ', 'Integrative Social Sciences', 3, true, now(), now()),
  ('GEN441', 'วัฒนธรรมและการท่องเที่ยว', 'Culture and Excursion', 3, true, now(), now()),
  -- ภาษา
  ('LNG120', 'ภาษาอังกฤษทั่วไป', 'General English', 3, true, now(), now()),
  ('LNG200', 'การฟังอย่างมีประสิทธิภาพ', 'Effective Listening', 1, true, now(), now()),
  ('LNG201', 'การอ่านอย่างกว้างขวาง', 'Extensive Reading', 1, true, now(), now()),
  ('LNG206', 'การเรียนรู้ด้วยตนเอง', 'Self-Directed Learning', 1, true, now(), now()),
  ('LNG221', 'ภาษาอังกฤษเชิงวิชาการในบริบทนานาชาติ', 'Academic English in International Contexts', 3, true, now(), now()),
  ('LNG223', 'ภาษาอังกฤษเพื่อการสื่อสารในที่ทำงาน', 'English for Workplace Communication', 3, true, now(), now()),
  ('LNG224', 'การสื่อสารด้วยวาจา 1', 'Oral Communication I', 3, true, now(), now()),
  ('LNG250', 'ภาษาไทยเพื่อการสื่อสารและอาชีพ', 'Thai for Communication and Careers', 3, true, now(), now()),
  ('LNG251', 'ทักษะการพูดภาษาไทย', 'Speaking Skills in Thai', 3, true, now(), now()),
  ('LNG252', 'ทักษะการเขียนภาษาไทย', 'Writing Skills in Thai', 3, true, now(), now()),
  ('LNG270', 'ภาษาเยอรมัน 1', 'German I', 3, true, now(), now()),
  ('LNG272', 'ภาษาญี่ปุ่น 1', 'Japanese I', 3, true, now(), now()),
  ('LNG275', 'ภาษาจีน 1', 'Chinese I', 3, true, now(), now()),
  ('LNG281', 'ภาษาเกาหลีเบื้องต้น', 'Basic Korean', 3, true, now(), now()),
  ('LNG301', 'การเขียนบทคัดย่อ', 'Abstract Writing', 1, true, now(), now()),
  ('LNG302', 'การเขียนรายงานการทดลอง', 'Laboratory Report Writing', 1, true, now(), now()),
  ('LNG303', 'ทักษะการนำเสนอด้วยวาจา', 'Oral Presentation Skills', 1, true, now(), now()),
  ('LNG307', 'การเขียนอีเมลระหว่างประเทศ', 'International Emailing', 1, true, now(), now()),
  ('LNG321', 'การอ่านและการเขียนเชิงวิชาการในบริบทนานาชาติ', 'Academic Reading and Writing in International Contexts', 3, true, now(), now()),
  ('LNG322', 'การเขียนเชิงวิชาการ 1', 'Academic Writing I', 3, true, now(), now()),
  ('LNG328', 'การแปลเบื้องต้น', 'Basic Translation', 3, true, now(), now()),
  ('LNG331', 'ภาษาอังกฤษเพื่อการสมัครงาน', 'English for Employment', 3, true, now(), now()),
  ('LNG422', 'การอ่านเชิงวิจักษ์', 'Reading Appreciation', 3, true, now(), now()),
  ('LNG425', 'การสื่อสารระหว่างวัฒนธรรม', 'Intercultural Communication', 3, true, now(), now()),
  -- สังคมศาสตร์และมนุษยศาสตร์
  ('SSC131', 'มนุษยสัมพันธ์ในโลกดิจิทัล', 'Human Relations in Digital World', 3, true, now(), now()),
  ('SSC132', 'จิตวิทยาไซเบอร์', 'Cyberpsychology', 3, true, now(), now()),
  ('SSC162', 'สังคมและวัฒนธรรม', 'Society and Culture', 3, true, now(), now()),
  ('SSC211', 'ปรัชญาทั่วไป', 'General Philosophy', 3, true, now(), now()),
  ('SSC232', 'การปรับพฤติกรรม', 'Behavior Modification', 3, true, now(), now()),
  ('SSC233', 'ครอบครัวสัมพันธ์', 'Family Relations', 3, true, now(), now()),
  ('SSC251', 'นิติศาสตร์เบื้องต้น', 'Introduction to Jurisprudence', 3, true, now(), now()),
  ('SSC271', 'การบัญชีเพื่อการจัดการเบื้องต้น', 'Introduction to Managerial Accounting', 3, true, now(), now()),
  ('SSC273', 'นวัตกรรมบริการทางธุรกิจ', 'Business Service Innovation', 3, true, now(), now()),
  ('SSC281', 'เศรษฐศาสตร์เบื้องต้น', 'Introduction to Economics', 3, true, now(), now()),
  ('SSC290', 'สิ่งแวดล้อมและการพัฒนา', 'Environment and Development', 3, true, now(), now()),
  ('SSC333', 'จิตวิทยาอุตสาหกรรมและองค์การ', 'Industrial and Organization Psychology', 3, true, now(), now()),
  ('SSC337', 'การทำงานเป็นทีม', 'Team Working', 3, true, now(), now()),
  ('SSC375', 'การจัดการทรัพย์สินทางปัญญา', 'Intellectual Property Management', 3, true, now(), now());

-- ผูกวิชาเลือกเสรีเข้าหมวด FREE_ELECTIVE (ไม่บังคับ ไม่มีปี/เทอมมาตรฐาน)
-- หมายเหตุ BE: ตามหลักสูตร วิชาใดก็ได้ใน มจธ. นับเป็นเลือกเสรีได้ ตารางนี้เป็นแค่ pool สำหรับแนะนำ/ค้นหา
INSERT INTO curriculum_category_courses (curriculum_category_id, course_id, is_required, standard_year, standard_semester)
SELECT cc.curriculum_category_id, c.course_id, false, NULL, NULL
FROM courses c
JOIN curriculum_versions cv ON cv.academic_year = 2567
JOIN categories ca ON ca.code = 'FREE_ELECTIVE'
JOIN curriculum_categories cc ON cc.category_id = ca.category_id AND cc.curriculum_version_id = cv.curriculum_version_id
WHERE c.course_code IN (
  'GEN101','GEN201','GEN211','GEN212','GEN222','GEN223','GEN224','GEN225','GEN226','GEN232','GEN242',
  'GEN301','GEN311','GEN321','GEN331','GEN332','GEN341','GEN352','GEN353','GEN354','GEN411','GEN412','GEN421','GEN441',
  'LNG120','LNG200','LNG201','LNG206','LNG221','LNG223','LNG224','LNG250','LNG251','LNG252','LNG270','LNG272','LNG275',
  'LNG281','LNG301','LNG302','LNG303','LNG307','LNG321','LNG322','LNG328','LNG331','LNG422','LNG425',
  'SSC131','SSC132','SSC162','SSC211','SSC232','SSC233','SSC251','SSC271','SSC273','SSC281','SSC290','SSC333','SSC337','SSC375'
);

-- 2) course_prerequisites
-- (course, prerequisite, group_no, is_corequisite)
INSERT INTO course_prerequisites (course_id, prerequisite_course_id, group_no, is_corequisite)
SELECT c.course_id, p.course_id, v.group_no, v.is_coreq
FROM (VALUES
  ('DSI206', 'DSI205', 1, false),
  ('INT111', 'INT110', 1, false),
  ('INT131', 'INT130', 1, false),
  ('INT134', 'INT132', 1, false),
  ('INT136', 'INT133', 1, false),
  ('INT147', 'INT144', 1, false),
  ('INT151', 'INT141', 1, false),
  ('INT151', 'INT150', 2, false),
  ('INT161', 'INT141', 1, false),
  ('INT161', 'INT150', 2, false),
  ('INT191', 'INT190', 1, false),
  ('INT220', 'INT120', 1, false),
  ('INT221', 'INT120', 1, false),
  ('INT222', 'INT120', 1, false),
  ('INT240', 'INT141', 1, false),
  ('INT241', 'INT140', 1, false),
  ('INT242', 'INT141', 1, false),
  ('INT243', 'INT141', 1, false),
  ('INT250', 'INT150', 1, false),
  ('INT251', 'INT151', 1, false),
  ('INT261', 'INT242', 1, false),
  ('INT270', 'INT101', 1, false),
  ('INT271', 'INT270', 1, false),
  ('INT272', 'INT270', 1, false),
  ('INT273', 'INT270', 1, false),
  ('INT282', 'INT102', 1, true),
  ('INT285', 'INT185', 1, false),
  ('INT290', 'INT190', 1, false),
  ('INT291', 'INT191', 1, false),
  ('INT292', 'INT190', 1, false),
  ('INT293', 'INT190', 1, false),
  ('INT294', 'INT191', 1, false),
  ('INT294', 'INT290', 2, false),
  ('INT296', 'INT294', 1, false),
  ('INT330', 'INT134', 1, false),
  ('INT331', 'INT151', 1, false),
  ('INT331', 'INT161', 2, false),
  ('INT332', 'INT133', 1, false),
  ('INT334', 'INT131', 1, false),
  ('INT334', 'INT133', 2, false),
  ('INT341', 'INT143', 1, false),
  ('INT342', 'INT143', 1, false),
  ('INT343', 'INT141', 1, false),
  ('INT343', 'INT150', 2, false),
  ('INT344', 'INT141', 1, false),
  ('INT370', 'INT243', 1, false),
  ('INT371', 'INT243', 1, false),
  ('INT380', 'INT141', 1, false),
  ('INT380', 'INT182', 2, false),
  ('INT381', 'INT102', 1, false),
  ('INT381', 'INT185', 2, false),
  ('INT390', 'INT190', 1, false),
  ('INT504', 'INT134', 1, true),
  ('INT504', 'INT151', 2, true),
  ('INT504', 'INT161', 3, true),
  ('INT505', 'INT504', 1, false),
  ('INT506', 'INT505', 1, true),   -- INT505 หรือ INT507
  ('INT506', 'INT507', 1, true),
  ('INT507', 'INT504', 1, false),
  ('INT508', 'INT505', 1, true),   -- INT505 หรือ INT507
  ('INT508', 'INT507', 1, true),
  ('INT509', 'INT115', 1, false),
  ('LNG202', 'LNG220', 1, false),
  ('LNG220', 'LNG120', 1, false),
  ('LNG304', 'LNG220', 1, false),
  ('LNG308', 'LNG220', 1, false),
  ('LNG320', 'LNG220', 1, false),
  ('LNG332', 'LNG220', 1, false)
) AS v(course_code, prereq_code, group_no, is_coreq)
JOIN courses c ON c.course_code = v.course_code
JOIN courses p ON p.course_code = v.prereq_code;

-- prerequisite_note: เงื่อนไขที่เก็บเป็นแถวในตารางไม่ได้ (หน่วยกิตสะสม, การอนุมัติ, วิชานอกหลักสูตร IT)
UPDATE courses c SET prerequisite_note = v.note, updated_at = now()
FROM (VALUES
  ('CSC233', 'CSC102 การเขียนโปรแกรมเบื้องต้น (วิชาของหลักสูตรวิทยาการคอมพิวเตอร์)'),
  ('CSC234', 'CSC213 การวิเคราะห์และออกแบบระบบ (วิชาของหลักสูตรวิทยาการคอมพิวเตอร์)'),
  ('CSC335', 'CSC209 โครงสร้างข้อมูล (วิชาของหลักสูตรวิทยาการคอมพิวเตอร์)'),
  ('CSC371', 'CSC203 สถาปัตยกรรมและองค์ประกอบคอมพิวเตอร์ และ CSC220 เครือข่ายคอมพิวเตอร์ (วิชาของหลักสูตรวิทยาการคอมพิวเตอร์)'),
  ('CSC536', 'CSC209 โครงสร้างข้อมูล (วิชาของหลักสูตรวิทยาการคอมพิวเตอร์)'),
  ('CSC561', 'CSC261 สถิติสำหรับนักวิทยาศาสตร์ (วิชาของหลักสูตรวิทยาการคอมพิวเตอร์)'),
  ('DSI117', 'DSI107 สถิติสำหรับบริการดิจิทัล (วิชาของหลักสูตรนวัตกรรมบริการดิจิทัล)'),
  ('INT105', 'ผ่านการศึกษาวิชาหมวด 2.1 ไม่น้อยกว่า 30 หน่วยกิต หรือได้รับความเห็นชอบจากคณะกรรมการประจำหลักสูตร'),
  ('INT115', 'ผ่านการศึกษาไม่น้อยกว่า 60 หน่วยกิต หรือได้รับความเห็นชอบจากคณะกรรมการประจำหลักสูตร'),
  ('INT504', 'หรือได้รับความเห็นชอบจากคณะกรรมการประจำหลักสูตร'),
  ('INT505', 'และผ่านการศึกษาวิชาหมวด 2.2 ไม่น้อยกว่า 9 หน่วยกิต หรือได้รับความเห็นชอบจากคณะกรรมการประจำหลักสูตร'),
  ('INT506', 'หรือได้รับความเห็นชอบจากคณะกรรมการประจำหลักสูตร'),
  ('INT507', 'และผ่านการศึกษาวิชาหมวด 2.2 ไม่น้อยกว่า 9 หน่วยกิต หรือได้รับความเห็นชอบจากคณะกรรมการประจำหลักสูตร'),
  ('INT508', 'หรือได้รับความเห็นชอบจากคณะกรรมการประจำหลักสูตร'),
  ('INT509', 'และได้รับความเห็นชอบจากคณะกรรมการประจำหลักสูตร'),
  ('LNG220', 'หรือได้รับการยกเว้นไม่ต้องเรียน LNG120 กรณีคะแนน O-NET สูงกว่า 40 คะแนน')
) AS v(course_code, note)
WHERE c.course_code = v.course_code;

-- วิชาหัวข้อพิเศษ / ศึกษาค้นคว้าอิสระ INT401-INT499
UPDATE courses SET prerequisite_note = 'ขึ้นอยู่กับอาจารย์ผู้สอน', updated_at = now()
WHERE course_code ~ '^INT4[0-9]{2}$';

COMMIT;
