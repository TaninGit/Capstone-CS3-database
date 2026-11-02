# Capstone-CS3-database
Repository นี้ทำหน้าที่จัดเก็บโครงสร้างฐานข้อมูล (Database Schema), SQL Scripts, และข้อมูลตัวอย่าง (Mockup) สำหรับระบบวางแผนการเรียนและรีวิวรายวิชา เทคโนโลยีสารสนเทศ (SIT KMUTT)

## ลำดับการรัน
1. `scripts/init.sql` — สร้างตาราง
2. `mockdata/mock.sql` — หลักสูตร IT 2567, รายวิชา, tracks
3. `mockdata/mock_02_prerequisites_free_electives.sql` — วิชาเลือกเสรี + วิชาบังคับก่อน
4. `mockdata/mock_03_registrar_users_plans.sql` — mock ทะเบียน, users, study plans, เกรด

ให้รหัสนักศึกษาจริงของตัวเองมีข้อมูลทะเบียน (login แล้วเห็นข้อมูลใน planner):
```sql
SELECT mock_clone_student('67130500004', '<รหัสนักศึกษาของเรา>');
```
