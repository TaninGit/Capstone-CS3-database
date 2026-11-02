# Capstone-CS3-database
Repository นี้ทำหน้าที่จัดเก็บโครงสร้างฐานข้อมูล (Database Schema), SQL Scripts, และข้อมูลตัวอย่าง (Mockup) สำหรับระบบวางแผนการเรียนและรีวิวรายวิชา เทคโนโลยีสารสนเทศ (SIT KMUTT)

คำอธิบายตาราง ความสัมพันธ์ และเคส mock ทั้งหมด: [docs/SCHEMA.md](docs/SCHEMA.md)

## ลำดับการรัน (PostgreSQL, DB เปล่า)
1. `scripts/init.sql` — สร้างตาราง
2. `mockdata/mock.sql` — หลักสูตร IT 2567, รายวิชา, หมวด, tracks
3. `mockdata/mock_02_prerequisites_free_electives.sql` — วิชาเลือกเสรี + วิชาบังคับก่อน
4. `mockdata/mock_03_registrar_users_plans.sql` — mock ทะเบียน, users, study plans, เกรด

เช็คว่าลงครบ: รัน `scripts/check.sql` แล้วทุกแถวใน query แรกต้องเป็น ✅

## ล้าง DB แล้วรันใหม่
```sql
DROP SCHEMA public CASCADE;
CREATE SCHEMA public AUTHORIZATION planit;
```
(หยุด backend ก่อน ไม่งั้นอาจติด lock)

## Login ด้วยบัญชีจริงแล้วให้มีข้อมูลทะเบียน
Backend ดึง `student_id` จากอีเมล แล้วหาใน `registrar_students` — copy ข้อมูลทะเบียนของนักศึกษา mock ให้รหัสตัวเอง:
```sql
SELECT mock_clone_student('67130500004', '<รหัสนักศึกษาของเรา>');
```
